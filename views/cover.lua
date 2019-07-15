-- Constants List:
local oX = display.screenOriginX
local oY = display.screenOriginY
local vW = display.viewableContentWidth
local vH = display.viewableContentHeight
local visibleAspectRatio = vW/vH

local class = require 'libs.middleclass'
--local Stateful = require 'libs.stateful'
--local inspect = require 'libs.inspect'
local colorHex = require('libs.convertcolor').hex
local util = require 'util'
local d = util.print_r

-- local forward references should go here --
local screenW, screenH, halfW, halfH = display.contentWidth, display.contentHeight, display.contentWidth*0.5, display.contentHeight*0.5
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight
local cX, cY = screenOffsetW + halfW, screenOffsetH + halfH

-- Fonts
local fontDMFT = 'assets/fonts/DMFT1541427649707.ttf'
local fontSHSans = 'assets/fonts/SourceHanSansK-Regular.ttf'
local fontSHSansBold = 'assets/fonts/SourceHanSansK-Bold.ttf'
local fontMorganiteBook = 'assets/fonts/Morganite-Book-4.ttf'
local fontMorganiteSemiBold = 'assets/fonts/Morganite-SemiBold-9.ttf'

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

function Cover:initialize(opts, parent)
  d('创建封面对象: '..opts.name)
  self.uri = opts.uri .. '.jpg'
  self.fileName = opts.name .. '.jpg'
  self.name = opts.name
  self.title = opts.title
  self.index = opts.index or 1
  View.initialize(self, parent)
  parent.elements.scroller:insert(self.layer)
  assert(self.layer, 'Cover View Initialized Failed!')
  --self.layer:toFront()
  --self.layer.anchorChildren = true
  -- =============================
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
  self:signal('onImageLoad')
  -- Load image
  local scaleFactor = 0.36
  local _index = self.index
  self.layer.x = oX + (vW*scaleFactor)*.618 + (_index - 1)*(vW*scaleFactor*1.14)
	local function networkListener( event )
    if ( event.isError ) then
      print ( "Network error - download failed" )
      return false
    else
      local _image = event.target
      fitImage(_image, vW*scaleFactor, vH*scaleFactor)
      _image.alpha = 0
      self.imageTransiton = transition.to( _image, { alpha = 1, time = 1000 } )
      self:_attach(_image, 'image')
      local nextBG = self.parent.elements.nextBG
      --util.center(self.layer)
      self.layer.y = nextBG.contentHeight*.42
      --self.layer.x = oX + _image.contentWidth*.618
      self:send('onImageLoaded')
    end
    self.fileName = event.response.filename
    self.baseDir = event.response.baseDirectory
    -- When self is RELEASED by Parent View
    if self.state >= View.STATUS.PRELOADED then
      self:cleanup()
    else
      self:setState('PRELOADED')
      d('Start Cover '..self.name..' '..self:getState())
      self.isBlocked = false
      self:start()
    end
	end
  display.loadRemoteImage( self.uri, "GET", networkListener, self.fileName, Cover.DEFAULT_DIRECTORY, oX, oY)
end

function Cover:onImageLoaded()
  local cImage = self.elements.image
  if not cImage then return false end
  local bounds = cImage.contentBounds
  local boundRect = display.newRect(bounds.xMin, bounds.yMin, cImage.contentWidth, cImage.contentHeight)
  boundRect.strokeWidth = 5
  boundRect:setStrokeColor(colorHex('C7A680')) --golden
  self:_attach(boundRect)
  boundRect.x = cImage.x
  boundRect.y = cImage.y
  boundRect:toBack()
  -- ---------------------------
  local labelFSize = 12
  local label = display.newText {
    text = self.title,
    x = cX, y = cY, 
    fontSize = labelFSize, font = fontSHSans,
    width = cImage.contentWidth*.96,
    --algin = 'left'
  }
  label:setFillColor(colorHex('C7A680'))
--  local labelBG = display.newRect(cImage.contentBounds.xMin, cImage.y + cImage.contentHeight*.2, label.contentWidth, label.contentHeight)
--  labelBG:setFillColor(unpack(colorsRGB.RGBA('black', 0.6)))
  --labelBG.anchorX = 0
--  labelBG.anchorY = 0
--  self:_attach(labelBG)
  self:_attach(label, 'label')
  label.x = cImage.x
  label.y = cImage.y + cImage.contentHeight*.5 + label.contentHeight*.5 + 10
  --self.layer.anchorChildren = true
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
    --self:unblock()
  end
  -- Add touch event handler
  self.layer:addEventListener('touch', self)
  self.layer:addEventListener('tap', self)
  self:setState('STARTED')
  d(self.name..' '..self:getState())
--}}}
end

function Cover:tap(tap)
  d('TODO: open album: '..self.title)
end

return Cover
