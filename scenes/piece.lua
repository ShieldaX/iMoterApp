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
local touchListener, cancelMove, tween, tapListener
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

local PieceImage = require("views.piece_image")

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
  
  _pieceImage = PieceImage:new(currentPieceId, baseDir, cX, cY)
  _pieceImage.layer.alpha = 0
--  _pieceImage = display.newImage( sceneGroup, currentPieceId, baseDir, cX, cY )
  sceneGroup:insert(_pieceImage.layer)
  
  title = display.newText { text = currentPieceId, x = cX, y = screenOffsetH + 20, fontSize = 18, align = 'center', font = Helvetica }
  title:setFillColor(1, 1, 1, 0.9)
  sceneGroup:insert(title)
  -- -----------------
  -- -----------------
  --_pieceImage.touch = touchListener
	--_pieceImage:addEventListener( "touch", self)
  --_pieceImage:addEventListener("tap", self)
end

-- show()
function scene:show( event )
  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    self.bgTransiton = transition.to( background, { alpha = 0.9 } )
    self.imageTransiton = transition.to( _pieceImage.layer, { alpha = 1 } )
  elseif ( phase == "did" ) then

  end
end
 
 
-- hide()
function scene:hide( event )
 
  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    self.imageTransiton = transition.to( _pieceImage.layer, { alpha = 0 } )
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