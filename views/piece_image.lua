--local widget = require( "widget" ) 
--widget.setTheme( "widget_theme_ios7" )
local APP = require("classes.application")
local composer = require( "composer" )

-- Constants List:
local oX = display.screenOriginX
local oY = display.screenOriginY
local vW = display.viewableContentWidth
local vH = display.viewableContentHeight
local visibleAspectRatio = vW/vH

local class = require 'libs.middleclass'
local Stateful = require 'libs.stateful'
--local inspect = require 'libs.inspect'

local util = require 'util'
local d = util.print_r

-- local forward references should go here --
local screenW, screenH, halfW, halfH = display.contentWidth, display.contentHeight, display.contentWidth*0.5, display.contentHeight*0.5
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight
local cX, cY = screenOffsetW + halfW, screenOffsetH + halfH

local DEFAULT_DIRECTORY = system.CachesDirectory
local cancelMove, tween

-- ------------------
-- Fit the size to full fill screen
local function fullFillScreen(displayObject)
  local scaleFactor = vH / displayObject.contentHeight
  displayObject:scale(scaleFactor, scaleFactor)
end

local function resize(obj)
  d(display.contentScaleX..':'..display.contentScaleY)
  local scaleFactor
  local ratioImage = obj.width/obj.height
  --resize properly
  if visibleAspectRatio >= ratioImage then
    scaleFactor = vH/obj.contentWidth
  else
    scaleFactor = vW/obj.contentHeight
  end
  d(display.contentScaleX..':'..display.contentScaleY)
  d(scaleFactor)
  obj:scale(scaleFactor, scaleFactor)
end

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

function cancelMove(displayObject)
  tween = transition.to( displayObject, {time=400, x=cX, y=cY, transition=easing.outExpo } )
end
-- ---
-- CLASSES Declaration
--
local View = require "libs.view"
local PieceImage = class('PieceImageView', View)
PieceImage:include(Stateful)

PieceImage.static.defaultDurationBetweenTaps = 500

-- -----------------------
-- Piece Image View which interaction varies between its statements
--
function PieceImage:initialize(imageFile, baseDir, x, y, autoRotate)
  if  imageFile == nil or type(imageFile) ~= 'string' then return end
  View.initialize(self)
  -- -------------------
  -- DATA BINDING
  self.imageFile = imageFile
  self.name = 'piece_image_view'
  d('图片查看对象: '..self.imageFile)
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  local _pieceImage = display.newImage( imageFile, baseDir, cX, cY )
  --util.resize(_pieceImage)
  if autoRotate then util.autoRotate(_pieceImage, autoRotate) end
  fullFillScreen(_pieceImage)
  util.center(_pieceImage)
  self:_attach(_pieceImage, 'displayImage')
  -- END VISUAL INITIALIING
  -- -------------------
	_pieceImage:addEventListener( "touch", self)
  _pieceImage:addEventListener("tap", self)
  --self:gotoState('FullFilled')
end

function PieceImage:touch(touch)
  local phase = touch.phase
  local dragDistanceX, dragDistanceY
  if ( phase == "began" ) then
    -- Subsequent touch events will target button even if they are outside the contentBounds of button
    display.getCurrentStage():setFocus( touch.target )
    self.isFocus = true
    startPosX, startPosY = touch.x, touch.y
    prevPosX, prevPosY = touch.x, touch.y
  elseif self.isFocus then
    local _pieceImage = touch.target
    local dragDistanceX = touch.x - startPosX
    local dragDistanceY = touch.y - startPosY
    if dragDistanceX > vW*0.5 or dragDistanceY > vH*0.5 then
      print("dragDistanceX: " .. dragDistanceX)
      print("dragDistanceY: " .. dragDistanceY)
      --goBack(event)
    end
    if ( phase == "moved" ) then
      if tween then transition.cancel(tween) end
      local deltaX, deltaY = touch.x - prevPosX, touch.y - prevPosY
      prevPosX, prevPosY = touch.x, touch.y
      _pieceImage.x = _pieceImage.x + deltaX
      _pieceImage.y = _pieceImage.y + deltaY
    elseif ( phase == "ended" or phase == "cancelled" ) then
      cancelMove(touch.target)
      -- Allow touch events to be sent normally to the objects they "hit"
      display.getCurrentStage():setFocus( nil )
      self.isFocus = false
    end
  end   
  return true
end

local ACTRPiece = PieceImage:addState('ActualSize')

function PieceImage:tap(event)
  local duration = PieceImage.defaultDurationBetweenTaps
  if event.numTaps == 1  then
    d("Display Object Single-tapped: " .. tostring(event.target))
    self.timer = timer.performWithDelay(duration, function()
      if self.timer then
        composer.hideOverlay('crossFade', 500)
      end
    end)    
  elseif event.numTaps == 2 then
    if self.timer then 
      timer.cancel(self.timer)
      self.timer = nil
    end
    d("Display Object Double-tapped: " .. tostring(event.target))
    local image = event.target
    --image.xScale, image.yScale = 1, 1
    self.FFxScale = image.xScale
    self.FFyScale = image.yScale
    transition.cancel(tween)
    tween = transition.to(image, {time = 200, xScale = 1, yScale = 1, x = cX, y = cY})
    --util.center(image)
    self:gotoState('ActualSize')
  else
    return true
  end
end

function ACTRPiece:tap(event)
  if ( event.numTaps ) then
    print( "Display Object Double-tapped: " .. tostring(event.target) )
    local image = event.target
    d(image.x..':'..image.y)
    d(event.x..':'..event.y)
    --fullFillScreen(image, vW, vH)
    transition.cancel(tween)
    tween = transition.to(image, {time = 200, xScale = self.FFxScale, yScale = self.FFyScale, x = cX, y = cY})
    --util.center(image)
    self:gotoState(nil)
  else
    return true
  end
end

local topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()
local scrLeft, scrTop, scrRight, scrBottom = oX+leftInset, oY+topInset, oX+vW-(leftInset+rightInset), oY+vH-(topInset+bottomInset)
local function limitInBounds(displayObject, inBounds)
  local scrTop, scrLeft, scrBottom, scrRight = inBounds[1], inBounds[2], inBounds[3], inBounds[4]
  local bounds = displayObject.contentBounds
  local halfWidth, halfHeight = displayObject.contentWidth*.5, displayObject.contentHeight*.5
  if bounds.xMin >= scrLeft or bounds.xMax <= scrRight or bounds.yMin >= scrTop or bounds.yMax <= scrBottom then
    if bounds.xMin >= scrLeft then displayObject.x = scrLeft + halfWidth end
    if bounds.xMax <= scrRight then displayObject.x = scrRight - halfWidth end
    if bounds.yMin >= scrTop then displayObject.y = scrTop + halfHeight end 
    if bounds.yMax <= scrBottom then displayObject.y = scrBottom - halfHeight end 
  end
end

function ACTRPiece:touch(touch)
  local phase = touch.phase
  local dragDistanceX, dragDistanceY
  if ( phase == "began" ) then
    -- Subsequent touch events will target button even if they are outside the contentBounds of button
    display.getCurrentStage():setFocus( touch.target )
    self.isFocus = true
    startPosX, startPosY = touch.x, touch.y
    prevPosX, prevPosY = touch.x, touch.y
  elseif self.isFocus then
    local _pieceImage = touch.target
    if ( phase == "moved" ) then
--      if tween then transition.cancel(tween) end
      local deltaX, deltaY = touch.x - prevPosX, touch.y - prevPosY
      prevPosX, prevPosY = touch.x, touch.y
      _pieceImage.x = _pieceImage.x + deltaX
      _pieceImage.y = _pieceImage.y + deltaY
      limitInBounds(_pieceImage, {scrTop, scrLeft, scrBottom, scrRight})
    elseif ( phase == "ended" or phase == "cancelled" ) then
      --limitInBounds(_pieceImage, {scrTop, scrLeft, scrBottom, scrRight})
      if ( phase == "cancelled" ) then	
        cancelMove(touch.target)
      end
      -- Allow touch events to be sent normally to the objects they "hit"
      display.getCurrentStage():setFocus( nil )
      self.isFocus = false
    end
  end   
  return true
end

return PieceImage