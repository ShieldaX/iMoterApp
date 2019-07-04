local composer = require( "composer" )
 
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
--local widget = require( "widget" ) 
--widget.setTheme( "widget_theme_ios7" )

local APP = require("classes.application")

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
--util.show_fps()

-- local forward references should go here --
local screenW, screenH, halfW, halfH = display.contentWidth, display.contentHeight, display.contentWidth*0.5, display.contentHeight*0.5
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight
local cX, cY = screenOffsetW + halfW, screenOffsetH + halfH

local DEFAULT_DIRECTORY = system.CachesDirectory
local background, _pieceImage = nil
local touchListener, cancelMove, tween
local imageNumberText, imageNumberTextShadow
local backbutton

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

local function goBack( event )
	print(event.phase)
  transition.to(background, {time = 400, alpha = 0, transition = easing.outExpo})
	if event.phase == "ended" then
		composer.hideOverlay( "crossFade", 500 )
	end
	return true
end

local currentPieceId, baseDir, title = nil

-- create()
function scene:create( event )
  local sceneGroup = self.view
  local params = event.params
  currentPieceId = params.pieceId
  baseDir = params.baseDir
  -- Gather insets (function returns these in the order of top, left, bottom, right)
  local topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()
  -- Create a vector rectangle sized exactly to the "safe area"
  background = display.newRect(
    oX + leftInset,
    oY + topInset,
    vW - ( leftInset + rightInset ),
    vH - ( topInset + bottomInset )
  )
  background:setFillColor( 0, 0, 0 )
  background:translate( background.contentWidth*0.5, background.contentHeight*0.5 )
  sceneGroup:insert( background )
  
  _pieceImage = display.newImage( sceneGroup, currentPieceId, baseDir, cX, cY )
  util.resize(_pieceImage)
  if params.pieceAutoRotate then util.autoRotate(_pieceImage, params.pieceAutoRotate) end
  _pieceImage.alpha = 0
  util.center(_pieceImage)
  sceneGroup:insert(_pieceImage)
  
  title = display.newText { text = currentPieceId, x = cX, y = screenOffsetH + 20, fontSize = 18, align = 'center', font = Helvetica }
  --title:setFillColor(0)
  sceneGroup:insert(title)
 -- --------------- 
  function touchListener (self, touch)
    local phase = touch.phase
    local dragDistanceX, dragDistanceY
    print("slides", phase)
    if ( phase == "began" ) then
      -- Subsequent touch events will target button even if they are outside the contentBounds of button
      display.getCurrentStage():setFocus( self )
      self.isFocus = true
      startPosX, startPosY = touch.x, touch.y
      prevPosX, prevPosY = touch.x, touch.y
    elseif self.isFocus then
      local dragDistanceX = touch.x - startPosX
      local dragDistanceY = touch.y - startPosY
      if dragDistanceX > vW*0.1 or dragDistanceY > vH*0.1 then
        print("dragDistanceX: " .. dragDistanceX)
        print("dragDistanceY: " .. dragDistanceY)
        goBack(event)
      end
      if ( phase == "moved" ) then
        if tween then transition.cancel(tween) end
        local deltaX, deltaY = touch.x - prevPosX, touch.y - prevPosY
        prevPosX, prevPosY = touch.x, touch.y
        _pieceImage.x = _pieceImage.x + deltaX
        _pieceImage.y = _pieceImage.y + deltaY
      elseif ( phase == "ended" or phase == "cancelled" ) then
        
        if ( phase == "cancelled" ) then	
          --cancelMove()
        end
        cancelMove()
        -- Allow touch events to be sent normally to the objects they "hit"
        display.getCurrentStage():setFocus( nil )
        self.isFocus = false
      end
    end   
    return true
  end
-- -----------------
  function cancelMove()
    tween = transition.to( _pieceImage, {time=400, x=cX, y=cY, transition=easing.outExpo } )
  end
  
  _pieceImage.touch = touchListener
	_pieceImage:addEventListener( "touch", _pieceImage )
  background:addEventListener("tap", goBack)
end

-- show()
function scene:show( event )
  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    self.bgTransiton = transition.to( background, { alpha = 0.95 } )
    self.imageTransiton = transition.to( _pieceImage, { alpha = 1 } )
  elseif ( phase == "did" ) then

  end
end
 
 
-- hide()
function scene:hide( event )
 
  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    self.imageTransiton = transition.to( _pieceImage, { alpha = 0 } )
  elseif ( phase == "did" ) then
    
  end
end
 
 
-- destroy()
function scene:destroy( event )
  local sceneGroup = self.view
  background:removeSelf()
  _pieceImage:removeSelf()
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene