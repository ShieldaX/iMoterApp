-- Constants List:
local oX = display.screenOriginX
local oY = display.screenOriginY
local vW = display.viewableContentWidth
local vH = display.viewableContentHeight

local class = require 'libs.middleclass'
local Stateful = require 'libs.stateful'
local inspect = require 'libs.inspect'

local util = require 'util'
local d = util.print_r
--util.show_fps()

-- local forward references should go here --
local screenW, screenH, halfW, halfH = display.contentWidth, display.contentHeight, display.contentWidth*0.5, display.contentHeight*0.5
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

local function tribleNum(num)
	local prefix = '00'
	if num >= 10 then
		prefix = '0'
	elseif num >= 100 then
		prefix = ''
	end
	return prefix .. tostring( num )
end

-- 根据远端资源命名规则解析图集所包含的图片
local function resolveImages(album)
	local numPieces, uris, names = 1, {}, {}
	numPieces = album.pieces
	local prefix = 'https://t1.onvshen.com:85/gallery/'
  local subfix = '0.jpg'
  local moterId, albumId = album.moters[1]._id, album._id
  uris[1] = prefix .. moterId .. '/' .. albumId .. '/' .. subfix
  names[1] = moterId .. '_' .. albumId .. '_' .. subfix
	for i = 2, numPieces do
		local idx = i - 1
		uris[i] = prefix .. moterId .. '/' .. albumId .. '/' .. tribleNum(idx) .. '.jpg'
		names[i] = moterId .. '_' .. albumId .. '_' .. tribleNum(idx) .. '.jpg'
	end
	return uris, names
end

-- 将图片自适应屏幕宽度
local function fitScreenW(p, top, bottom)
	top = top or 0
	bottom = bottom or 0
	local h = viewableScreenH-(top+bottom)
	if p.width > viewableScreenW or p.height > h then
		if p.width/viewableScreenW > p.height/h then
				p.xScale = viewableScreenW/p.width
				p.yScale = viewableScreenW/p.width
		else
				p.xScale = h/p.height
				p.yScale = h/p.height
		end
	end
	p.x = screenW*.5
	p.y = h*.5
end

-- Classes
local AlbumView = class 'AlbumView'
local Piece = require 'views.piece'

Piece.static.directory = system.CachesDirectory

function Piece:initialize(uri, fname, parent, index)
  print('创建图片对象: '..fname)
  self.uri = uri
  self.fileName = fname
  self.parent = parent
  self.indexOfAlbum = indexOfAlbum
end

function Piece:preload(albumView)
	local function networkListener( event )
	    if ( event.isError ) then
	        print ( "Network error - download failed" )
          return false
	    else
	        event.target.alpha = 0
	        fitScreenW(event.target, 0, 0)
          event.target.x, event.target.y = display.screenOriginX, display.screenOriginY
          self.parent.container:insert(event.target)
	        transition.to( event.target, { alpha = 1.0 } )
          self.imageView = event.target
          --d(self.imageView.xScale .. ':' .. self.imageView.yScale)
          self.targetScale = self.imageView.xScale
	    end
	    print ( "event.response.fullPath: ", event.response.fullPath )
	    print ( "event.response.filename: ", event.response.filename )
	    print ( "event.response.baseDirectory: ", event.response.baseDirectory )
      self.fileName = event.response.filename
      self.baseDir = event.response.baseDirectory
      self:block()
      self.imageView:toBack()
      self.parent._bg:toBack()
      --self:gotoState('Preloaded')
	end
  display.loadRemoteImage( self.uri, "GET", networkListener, self.fileName, system.CachesDirectory, 50, 50 )
end

function Piece:block()
  self.imageView.xScale = self.targetScale * 0.618
  self.imageView.yScale = self.targetScale * 0.618
end

function Piece:unblock()
  self.imageView.xScale = self.targetScale
  self.imageView.yScale = self.targetScale  
end

function Piece:touch(event)
  d("touch listener works!")
end

function Piece:reload(image)
  d(self.fileName)
  if not self.baseDir then
    self.baseDir = Piece.directory
  end
  --local reImage = display.newImage( self.parent, self.fileName, self.baseDir )
  --fitScreenW(reImage)
end

function Piece:stop()
  self.imageView:removeEventListener('touch', self)
  self.imageView:removeEventListener('tap', self)
end

function Piece:cleanup()
  if self.imageView and self.imageView.removeSelf and type(self.imageView.removeSelf) == 'function' then
    self.imageView:removeSelf()
    self.imageView = nil
  end
end

-- 利用获取的图集信息实例化一个图集对象
function AlbumView:initialize(obj, sceneGroup)
  d('-*-*-*-*-*-*-*-*-*-*-*-*-*-*')
  d('- Prototype of Album View -')
  d('- ======================== -')
  self.container = display.newContainer(sceneGroup, display.viewableContentWidth, display.viewableContentHeight)
  --self.container:translate(halfW, halfH)
  util.center(self.container)
  --self.container.anchorChildren = true
  self._bg = display.newRoundedRect(
    self.container,
    display.screenOriginX, display.screenOriginY,
    display.viewableContentWidth, display.viewableContentHeight,
    8
  )
  self._bg:setFillColor(1)
  util.center(self._bg)

  self.rawData = obj
  self.imgURIs, self.imgNames = resolveImages(obj)
  --d(self.imgNames)
  self.currentPieceId = nil
  self.paintedPieceId = nil
  self.elements = {}
end

function AlbumView:stage(i)
  if self.imgURIs and self.imgNames then
    --d(self.imgNames[i])
    local pic = Piece:new(self.imgURIs[i], self.imgNames[i], self.container)
    timer.performWithDelay(3000, function()
      pic:reload() 
    end)
  end
end

function AlbumView:open(index)
  index = index or 1
  --local image = self.imgURIs[index]
  self:loadPiece(index)
  self.currentPieceId = index
  --self.elements[index]:start()
end

function AlbumView:loadPiece(pieceId)
  --self:turnOut()
  local this = self
  local i = pieceId
  local pic = Piece:new(self.imgURIs[i], self.imgNames[i], self)
  --self.container:insert(pieceId, pic)
  --table.insert(self.elements, pic)
  self.elements[i] = pic
  pic:preload(self)
  self.paintedPieceId = i
end

function AlbumView:switchPiece(direction)
  d('当前显示的Piece ID：' .. self.currentPieceId)
  if direction == 0 or self.currentPieceId == nil then return false end
  direction = tonumber(direction) or 1
  assert(math.abs(direction) == 1, "invalid call on ':switchPiece'")
  -- Try to drop older painted piece
  self:turnOut()
  -- Get target piece id
  local targetPieceId = self.currentPieceId + direction
  -- Assert target is reachable
  local pieceNum = self.rawData.pieces
  if pieceNum < targetPieceId or targetPieceId < 1 then -- beyond
    if direction == -1 then
      d('This is already the first pic!')
    elseif direction == 1 then
      d('This is already the last pic!')
    end
    return false
  end
  self:loadPiece(targetPieceId)
end

-- ---
-- clean the new piece object on album view
-- @return 'boolean' False if nothing need clean.
function AlbumView:turnOut()
  if self.paintedPieceId and self.elements[self.paintedPieceId] then
    self.elements[self.paintedPieceId]:cleanup()
    self.elements[self.paintedPieceId] = nil
    self.paintedPieceId = nil
    return true
  else
    return false
  end
end

-- change current pix after switching properly
function AlbumView:turnOver()
  if self.paintedPieceId == nil or self.currentPieceId == nil then return false end
  local transTime, easeType = 400, easing.outQuad --ms
  local currentPiece = self.elements[self.currentPieceId]
  local targetPiece = self.elements[self.paintedPieceId]
  currentPiece:stop()
  transition.to( currentPiece.imageView, {time = transTime - 50, y = - 1*vH, transition = easeType} )
  --transition.to( new_pix.elements['shade'], {time = transT, alpha = 0, transition = easing.inExpo})
  transition.to( targetPiece.imageView,
      {time = transTime, x = 0, y = 0, xScale = targetPiece.targetScale, yScale = targetPiece.targetScale, transition = easeType, onComplete = function()
          currentPiece:cleanup()
          self.elements[self.currentPieceId] = nil
          -- exchange avatars in plus view
          self.currentPieceId, self.paintedPieceId = self.paintedPieceId, nil
          --if self.currentPieceId ~= nil then return self.elements[self.currentPieceId]:start() end
      end}
    )
end


function AlbumView:board()
	if self.elements['board'] == nil then
		local board = board.new()
		--board:board()
		self:_attach(board, 'board')
	end
	local board = self.elements.board
	--board:changeDisplayStatus()
end

--local ActiveAlbum = AlbumView:addState('Actived')
--function ActiveAlbum:start() end

function AlbumView:start()
  if self.state == 30 then return false end
  --local e = self.elements
  self:set_state('started')
end

function AlbumView:stop()
  self:cleanup()
end

function AlbumView:cleanup()
  self._elements = {}
  self.elements = {}
  self:set_state('created')
end

return AlbumView