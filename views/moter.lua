local composer = require( "composer" )
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
local cX, cY = screenOffsetW + halfW, screenOffsetH + halfH

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

-- ---
-- Resize Image Display Object to Fit Screen WIDTH
--
function util.fitWidth(obj, W)
  local scaleFactor = W/obj.width
  obj.width = obj.width*scaleFactor
  obj.height = obj.height*scaleFactor
  --obj:scale(scaleFactor, scaleFactor)
end

-- Classes
local View = require 'libs.view'
local Piece = require 'views.piece'
local Indicator = require 'views.indicator'
local Moter = class('MoterView', View)
local APP = require("classes.application")

local LayoutManager = require( "libs.layout" )
-- layout manager object
local Layout

-- Group to hold rects that display the regions
local Regions

-- Content grid size; change these to change the size of the generated grid
local ContentGridSize = 4
local GridPixelPadding = 8

-- 利用获取的图集信息实例化一个图集对象
function Moter:initialize(obj, sceneGroup)
  d('-*-*-*-*-*-*-*-*-*-*-*-*-*-*')
  d('- Prototype of Moter View -')
  d('- ======================== -')
  View.initialize(self, sceneGroup)
  -- -------------------
  -- DATA BINDING
  self.rawData = obj
  self.name = obj.name
  local _id = obj._id
  self.avatarImgURI = "https://img.onvshen.com:85/girl/".._id.."/".._id..".jpg"
  self.avatarFileName = _id.."_".._id..".jpg"
  --APP.CurrentMoter = self
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  local _bg = display.newRoundedRect(self.layer, oX, oY, vW, vH, 8)
--  local _bg = display.newRect(self.layer, oX, oY, vW, vH)
  _bg:setFillColor(1) -- Pure White
  util.center(_bg)
--  _bg.y = _bg.y+50
  self:_attach(_bg, '_bg')
  --self.elements._bg:toBack()
  -- END VISUAL INITIALIING
  -- -------------------
end

function Moter:layout()
  --local indicator = Indicator:new({total= #self.imgURIs, name= 'progbar', top= 0}, self)
  --self:addView(indicator)
  local _data = self.rawData
  local labelAge = display.newText {text = _data.birthday, x = cX, y = cY, fontSize = 18}
  labelAge:setFillColor(0)
  
  if self.state > View.STATUS.INITIALIZED then
    d("Try to preload Moter already @ "..self.getState())
    return false
  end
  -- Load image
	local function networkListener( event )
    if event.phase == 'began' or event.phase == 'progress' then
      self._requestId = event.requestId
      print('Image is Loading')
      return
    elseif event.phase == 'ended' then
      print('Image Loading Ended')
      self._requestId = nil
    end
    if ( event.isError ) then
      print ( "Network error - download failed" )
      return false
    else
      --self:signal('onAavatrLoaded')
      local _image = event.target
      util.fitWidth(_image, vW/3)
      _image.alpha = 0
      util.center(_image)
      _image.x = cX - _image.width*.5
      self.imageTransiton = transition.to( _image, { time = 500, alpha = 1, y = _image.contentHeight*.5 + vH*.1, transition = easing.outExpo} )
      self:_attach(_image, 'avatar')
      
    end
    self.avatarFileName = event.response.filename
    self.baseDir = event.response.baseDirectory
    -- When self is RELEASED by Parent View
    if self.state >= View.STATUS.PRELOADED then
      --self:cleanup()
    else
      self:setState('PRELOADED')
      if not self.isBlocked then
        d('Start Piece '..self.name..' '..self:getState()..' and Not Blocked')
        self:start()
      else
        d(self.name .. ' ' .. self:getState())
      end
    end
	end
  display.loadRemoteImage( self.avatarImgURI, "GET", networkListener, {progress = true}, self.avatarFileName, Piece.DEFAULT_DIRECTORY, oX, oY)
end

function Moter:onPieceTapped(event)
  event.labelText = table.indexOf(self.imgNames, self.currentPieceId) .. '/' .. self.rawData.pieces
  local options = {
      effect = "fade",
      time = 500,
      isModal = true,
      params = event
  }
  composer.showOverlay( "scenes.piece", options )
end

--local ActiveAlbum = AlbumView:addState('Actived')
--function ActiveAlbum:start() end

function Moter:start()
  if self.state == 30 then return false end
  --local e = self.elements
  self:setState('STARTED')
end

function Moter:stop()
  self:cleanup()
end

return Moter