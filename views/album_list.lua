local composer = require( "composer" )
-- Constants List:
local oX = display.screenOriginX
local oY = display.screenOriginY
local vW = display.viewableContentWidth
local vH = display.viewableContentHeight

local class = require 'libs.middleclass'
local Stateful = require 'libs.stateful'
local inspect = require 'libs.inspect'
local colorHex = require('libs.convertcolor').hex

local util = require 'util'
local d = util.print_r
--util.show_fps()

-- Classes
local View = require 'libs.view'
local Piece = require 'views.piece'
local Album = require 'views.album'
local Indicator = require 'views.indicator'
local AlbumList = class('AlbumListView', View)
local APP = require("classes.application")

-- local forward references should go here --
local screenW, screenH, halfW, halfH = display.contentWidth, display.contentHeight, display.contentWidth*0.5, display.contentHeight*0.5
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight
local cX, cY = screenOffsetW + halfW, screenOffsetH + halfH

-- Fonts
local fontDMFT = 'assets/fonts/DMFT1541427649707.ttf'
local fontSHSans = 'assets/fonts/SourceHanSansK-Regular.ttf'
local fontMorganiteBook = 'assets/fonts/Morganite-Book-4.ttf'
local fontMorganiteSemiBold = 'assets/fonts/Morganite-SemiBold-9.ttf'

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

-- 利用获取的图集信息实例化一个图集对象
function AlbumList:initialize(obj, sceneGroup)
  d('-*-*-*-*-*-*-*-*-*-*-*-*-*-*')
  d('- Prototype of AlbumList View -')
  d('- ======================== -')
  View.initialize(self, sceneGroup)
  -- -------------------
  -- DATA BINDING
  self.rawData = obj
  self._albums = obj.albums
  self.name = 'album list'
  APP.CurrentAlbumList = self
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  local _lgray = {colorHex('6C6C6C')}
  local titleAlbum = display.newText {text = '图集', x = vW*.24, y = 60, fontSize = 12, font = fontSHSans}
  titleAlbum:setFillColor(unpack(_lgray))
  local labelNumAlbum = display.newText {text = '162', x = vW*.24, y = titleAlbum.contentBounds.yMax + 16, fontSize = 26, font = fontSHSans}
  local _bg = display.newRect(self.layer, oX, oY, vW, vH*.6)
  _bg:setFillColor(unpack(_lgray)) -- golden gray 
  util.center(_bg)
  self:_attach(_bg, '_bg')
  --self.elements._bg:toBack()
  local triangleShape = display.newPolygon(cX, cY, {-10, 5, 0, -10, 10, 5})
  triangleShape:setFillColor(unpack(_lgray))
  triangleShape.anchorY = 1
  triangleShape.y = _bg.y - _bg.contentHeight*.5
  self:_attach(triangleShape, '_tabCursor')
  triangleShape.x = vW*.24
  --util.center(triangleShape)
  -- END VISUAL INITIALIING
  -- -------------------
end

function AlbumList:open(index)
  index = index or 1
  self.currentPieceId = nil
--  local indicator = Indicator:new({total= #self.imgURIs, name= 'progbar', top= APP.Header.elements.TopBar.height}, self)
  local indicator = Indicator:new({total= #self.imgURIs, name= 'progbar', top= 0}, self)
  --self:addView(indicator)
  self:createPiece(index)
  -- First Initialize: Update Pieces (C/P) Reference Manually
  self.currentPieceId, self.paintedPieceId = self.paintedPieceId, nil
  self:setState('STARTED')
  self:signal('onProgress', {index = index})
end

-- ---
-- 清除其他预加载的Piece View，（重）新创建一个Piece对象，
-- 如果预加载的Piece View 和目标一致则直接返回
-- 如果有预加载回调任务则置入Piece View的预加载中
function AlbumList:loadAlbum(index)
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

function AlbumList:onAlbumTapped(event)
  event.labelText = table.indexOf(self.imgNames, self.currentPieceId) .. '/' .. self.rawData.pieces
  local options = {
      effect = "fade",
      time = 500,
      isModal = true,
      params = event
  }
  composer.showOverlay( "scenes.piece", options )
end

function AlbumList:start()
  if self.state == 30 then return false end
  --local e = self.elements
  self:setState('STARTED')
end

function AlbumList:stop()
  self:cleanup()
end

return AlbumList