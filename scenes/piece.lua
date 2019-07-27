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

local currentPieceId, baseDir, label = nil

local PieceImage = require("views.piece_image")

-- create()
function scene:create( event )
  local sceneGroup = self.view
  local params = event.params
  currentPieceId = params.pieceId
  baseDir = params.baseDir
  
  background = display.newRect(sceneGroup, oX, oY, vW, vH)
  background:setFillColor( 0 )
  background:translate( background.contentWidth*0.5, background.contentHeight*0.5 )
  
  _pieceImage = PieceImage:new(currentPieceId, baseDir, cX, cY, composer.getVariable( "autoRotate" ))
  _pieceImage.layer.alpha = 0
  sceneGroup:insert(_pieceImage.layer)
  
  label = display.newText { text = params.labelText, x = cX, y = screenOffsetH + 20, fontSize = 18, align = 'center', font = Helvetica }
  label:setFillColor(1, 1, 1, 0.9)
  sceneGroup:insert(label)
  -- -----------------
end

-- show()
function scene:show( event )
  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    self.bgTransiton = transition.to( background, { alpha = 0.9 } )
    self.imageTransiton = transition.to( _pieceImage.layer, { alpha = 1 } )
    self.hideFooter = APP.Footer.hidden
    APP.Footer:hide()
  elseif ( phase == "did" ) then

  end
end
 
-- hide()
function scene:hide( event )
 
  local sceneGroup = self.view
  local phase = event.phase
  if ( phase == "will" ) then
    self.imageTransiton = transition.to( _pieceImage.layer, { alpha = 0 } )
    if not self.hideFooter then APP.Footer:show() end
  elseif ( phase == "did" ) then
    
  end
end

-- destroy()
function scene:destroy( event )
  local sceneGroup = self.view
  background:removeSelf()
  _pieceImage:cleanup()
  background, _pieceImage = nil
  d('Piece scene destoried success!')
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