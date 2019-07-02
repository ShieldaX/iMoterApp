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
  local subfix = '0'
  local moterId, albumId = album.moters[1]._id, album._id
  uris[1] = prefix .. moterId .. '/' .. albumId .. '/' .. subfix
  names[1] = moterId .. '_' .. albumId .. '_' .. subfix
	for i = 2, numPieces do
		local idx = i - 1
		uris[i] = prefix .. moterId .. '/' .. albumId .. '/' .. tribleNum(idx)
		names[i] = moterId .. '_' .. albumId .. '_' .. tribleNum(idx)
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
local View = require 'libs.view'
local Piece = require 'views.piece'
local Album = class('AlbumView', View)

-- 利用获取的图集信息实例化一个图集对象
function Album:initialize(obj, sceneGroup)
  d('-*-*-*-*-*-*-*-*-*-*-*-*-*-*')
  d('- Prototype of Album View -')
  d('- ======================== -')
  View.initialize(self, sceneGroup)
  -- -------------------
  -- DATA BINDING
  self.rawData = obj
  self.imgURIs, self.imgNames = resolveImages(obj)
  self.currentPieceId = nil
  self.paintedPieceId = nil
  self.pieceAutoRotate = false
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  local _bg = display.newRoundedRect(
    self.layer,
    display.screenOriginX, display.screenOriginY,
    display.viewableContentWidth, display.viewableContentHeight,
    8
  )
  _bg:setFillColor(1) -- Pure White
  util.center(_bg)
  self:_attach(_bg, '_bg')
  -- TODO: Configure topbar
  -- -- local _topbar = widget.newProgressBar()
  -- END VISUAL INITIALIING
  -- -------------------
end

function Album:open(index)
  index = index or 1
  self.currentPieceId = nil
  self:createPiece(index)
  -- First Initialize: Update Pieces (C/P) Reference Manually
  self.currentPieceId, self.paintedPieceId = self.paintedPieceId, nil
  self:setState('STARTED')
end

-- ---
-- 清除其他预加载的Piece View，（重）新创建一个Piece对象，
-- 如果预加载的Piece View 和目标一致则直接返回
-- 如果有预加载回调任务则置入Piece View的预加载中
function Album:createPiece(index)
  if self.paintedPieceId then
    d('FOUND EXISIST IN MEMORY: ' .. self.paintedPieceId)
    if self.elements[self.paintedPieceId] then
      d('ALREADY ATTACHED: @' .. self.elements[self.paintedPieceId].state)
      return false
    end
  end
  self:turnOut()
  local _piece = Piece:new(self.imgURIs[index], self.imgNames[index])
  self:_attach(_piece)
  _piece:preload()
  --d(_piece.name)
  self.paintedPieceId = _piece.name
end

-- ---
-- load another of piece
-- @param direction: 1(scroll down), -1(scroll up)
--
function Album:switchPiece(direction)
  d('当前显示的Piece ID：' .. self.currentPieceId)
  if direction == 0 or self.currentPieceId == nil then return false end
  direction = tonumber(direction) or 1
  assert(math.abs(direction) == 1, "invalid direction while call ':switchPiece'")
  -- Try to drop older painted piece
  self:turnOut()
  -- Get target piece id
  local currentIndex = table.indexOf(self.imgNames, self.currentPieceId)
  local targetIndex = currentIndex + direction
  local pieceId = self.imgNames[targetIndex]
  --TODO: prompt head or foot page if any
  if pieceId == nil then
    if direction == -1 then d('This is already the first pix!') elseif direction == 1 then d('This is already the foot pix!') end
    return false
  end
  self:createPiece(targetIndex)
end

-- ---
-- change current piece after switching properly
-- STOP any interactions
function Album:turnOver()
  if self.paintedPieceId == nil or self.currentPieceId == nil then return false end
  local transTime, easeType = 400, easing.outQuad --ms
  local currentPiece = self.elements[self.currentPieceId]
  local targetPiece = self.elements[self.paintedPieceId]
  -- ------------------
  -- Current Piece is Fading Out
  currentPiece:stop()
  transition.to( currentPiece.layer, {time = transTime - 50, y = - currentPiece.layer.direction*vH, transition = easeType} )
  -- ------------------
  -- Target Piece is Fading In (Comes Up)
  local isPreloaded = (targetPiece.state >= View.STATUS.PRELOADED)
  if not isPreloaded then -- 图片未加载的情况下：需要重新定位View的Layer
    d('REPOSITION Target Piece View Group')
    local _layer = targetPiece.layer
    _layer.x = (1 - _layer.xScale)*vW*.5
    _layer.y = (1 - _layer.yScale)*vH*.5
    --targetPiece.isBlocked = true
  end
  -- Blocking Piece to Avoid Unexpect Interaction while Transition (Moving)
  targetPiece.isBlocked = true
  transition.to( targetPiece.layer, {
    --onStart = function() targetPiece.isBlocked = true end,
    time = transTime,
    x = 0, y = 0,
    xScale = 1, yScale = 1,
    alpha = 1,
    transition = easeType,
    onComplete = function()
      targetPiece.isBlocked = false
      currentPiece:cleanup()
      self.elements[self.currentPieceId] = nil
      -- exchange avatars in plus view
      self.currentPieceId, self.paintedPieceId = self.paintedPieceId, nil
      if self.currentPieceId and self.elements[self.currentPieceId].state >= View.STATUS.PRELOADED then
        self.elements[self.currentPieceId]:start()
      end
    end
    }
  )
end

-- ---
-- 清除预加载的（目标）Piece View对象并重置预加载索引
-- Album:rebase()
-- clean the new piece object on album view
-- @return 'boolean' False if nothing need clean.
function Album:turnOut()
  if self.paintedPieceId and self.elements[self.paintedPieceId] then
    self.elements[self.paintedPieceId]:cleanup() -- RELEASE Painted Piece
    self.elements[self.paintedPieceId] = nil
    self.paintedPieceId = nil
    return true
  else
    return false
  end
end

function Album:board()
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

function Album:start()
  if self.state == 30 then return false end
  --local e = self.elements
  self:setState('STARTED')
end

function Album:stop()
  self:cleanup()
end

return Album