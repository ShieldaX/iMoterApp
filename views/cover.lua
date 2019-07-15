-- Constants List:
local oX = display.screenOriginX
local oY = display.screenOriginY
local vW = display.viewableContentWidth
local vH = display.viewableContentHeight
local visibleAspectRatio = vW/vH

local class = require 'libs.middleclass'
--local Stateful = require 'libs.stateful'
--local inspect = require 'libs.inspect'

local util = require 'util'
local d = util.print_r

-- local forward references should go here --
local screenW, screenH, halfW, halfH = display.contentWidth, display.contentHeight, display.contentWidth*0.5, display.contentHeight*0.5
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

local function fitImage( displayObject, fitWidth, fitHeight, enlarge )
	--
	-- first determine which edge is out of bounds
	--
	local scaleFactor = fitHeight / displayObject.contentHeight 
	local newWidth = displayObject.contentWidth * scaleFactor
	if newWidth > fitWidth then
		scaleFactor = fitWidth / displayObject.contentWidth 
	end
	if not enlarge and scaleFactor > 1 then
		return
	end
	displayObject:scale( scaleFactor, scaleFactor )
end

-- ---
-- CLASSES Declaration
--
local View = require "libs.view"
local Cover = class('AlbumCoverView', View)
Cover.STATUS.RELEASED = 100

-- ---
-- Default Image File Cache Directory
-- TODO: Try to load piece image from this dir firstly
Cover.static.DEFAULT_DIRECTORY = system.CachesDirectory

function Cover:initialize(uri, name, title, parent)
  d('创建封面对象: '..name)
  self.uri = uri .. '.jpg'
  self.fileName = name .. '.jpg'
  self.name = name
  View.initialize(self, parent)
  assert(self.layer, 'Cover View Initialized Failed!')
  self.layer:toFront()
  -- =============================
  local label = display.newText {
    text = title,
    x = cX, y = cY, 
    fontSize = labelFSize, font = fontSHSansBold,
    width = vH*.24,
    algin = 'center'
  }
  --self.label = label
  local labelBG = display.newRect(label.contentBounds.xMin - 10, label.y, vW*.4, label.contentHeight+10)
  labelBG:setFillColor(unpack(colorsRGB.RGBA('black', 0.6)))
  labelBG.anchorX = 0
  labelBG.anchorY = 0
  self:_attach(labelBG)
  self:_attach(label, 'label')
  self.layer.anchorChildren = true
  d(self.name..' '..self:getState())
end

-- ---
-- Preload Image Display Object
-- Then Try to Start Self if not blocked
--
function Cover:preload()
  if self.state > View.STATUS.INITIALIZED then
    d("Try to preload Cover already @ "..self.getState())
    return false
  end
  -- ------------------
  -- Block view while preloading image
  self.isBlocked = true
  self:signal('onCoverLoad')
  -- Load image
	local function networkListener( event )
    if event.phase == 'began' or event.phase == 'progress' then
      self._requestId = event.requestId
      print('Cover Image is Loading')
      return
    elseif event.phase == 'ended' then
      print('Cover Image Loading Ended')
      self._requestId = nil
    end
    if ( event.isError ) then
      print ( "Network error - download failed" )
      return false
    else
      self:signal('onCoverLoaded')
      local _image = event.target
      fitImage(_image, vW*0.5, vH*0.5)
      _image.alpha = 0
      --util.center(_image)
      --_image.y = vH*0.8
      self.imageTransiton = transition.to( _image, { alpha = .9, time = 1000 } )
      self:_attach(_image, 'image')
      _image:toBack()
      local nextBG = self.parent.elements.nextBG
      util.center(self.layer)
      self.layer.y = nextBG.y + nextBG.contentHeight*.5 
    end
    self.fileName = event.response.filename
    self.baseDir = event.response.baseDirectory
    -- When self is RELEASED by Parent View
    if self.state >= View.STATUS.PRELOADED then
      self:cleanup()
    else
      self:setState('PRELOADED')
      d('Start Cover '..self.name..' '..self:getState())
      self:start()
    end
	end
  display.loadRemoteImage( self.uri, "GET", networkListener, {progress = true}, self.fileName, Cover.DEFAULT_DIRECTORY, oX, oY)
end


-- ---
-- Begin to receive touch or tap events, then give reflection back properly
--
function Cover:start()
--{{{
  d('Try to start Cover '..self.name..' @ '..self:getState())
  if (self.state < View.STATUS.PRELOADED) or self.isBlocked then
    d(self.name .. ' is Not Ready to Start!')
    return false
  elseif (self.state >= View.STATUS.STARTED) then
    d(self.name .. ' already Started!')
    return false
  end
  
  if (self.state <= View.STATUS.STOPPED) then
    self:unblock()
  end
  -- Add touch event handler
  self.layer:addEventListener('touch', self)
  self.layer:addEventListener('tap', self)
  self:setState('STARTED')
  d(self.name..' '..self:getState())
--}}}
end

return Cover
