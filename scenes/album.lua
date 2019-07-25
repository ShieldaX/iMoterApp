----------------------------------------------------------------------------------
--      Main App
--      Scene notes
---------------------------------------------------------------------------------
local composer = require( "composer" )

--Display Constants List:
local oX = display.safeScreenOriginX
local oY = display.safeScreenOriginY
local vW = display.viewableContentWidth
local vH = display.viewableContentHeight
local visibleAspectRatio = vW/vH
local screenW, screenH, halfW, halfH = display.contentWidth, display.contentHeight, display.contentWidth*0.5, display.contentHeight*0.5
local cX, cY = display.contentCenterX, display.contentCenterY
local sW, sH = display.safeActualContentWidth, display.safeActualContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight
local topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()

local background = nil
local widget = require( "widget" )
local util = require 'util'
local d = util.print_r

local inspect = require('libs.inspect')
local iMoterAPI = require( "classes.iMoter" )

--local mui = require( "materialui.mui" )
local AlbumView = require("views.album")
local HeaderView = require("views.header")
local FooterView = require("views.footer")

-- mui
--local muiData = require( "materialui.mui-data" )

----------------------------------------------------------------------------------
--
--      NOTE:
--
--      Code outside of listener functions (below) will only be executed once,
--      unless storyboard.removeScene() is called.
--
---------------------------------------------------------------------------------
local scene = composer.newScene()
-- Our modules
local APP = require( "classes.application" )
--local utility = require( "libs.utility" )
local mui = require( "materialui.mui" )
local iMoter = iMoterAPI:new()

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:create( event )
	local sceneGroup = self.view
  local params = event.params
  --Hide status bar from the beginning
--  display.setStatusBar( display.HiddenStatusBar )
--  display.setDefault("background", 0, 1, 1)

  mui.init(nil, { parent=self.view })
  -----------------------------------------------------------------------------
  --      CREATE display objects and add them to 'group' here.
  background = display.newRect(sceneGroup, oX, oY, vW, vH)
  background:setFillColor( 0 )
  background:translate( background.contentWidth*0.5, background.contentHeight*0.5 )
  
  APP.Header = HeaderView:new({name = 'TopBar'}, sceneGroup)
--  APP.Footer = FooterView:new({name = 'AppTabs', barHeight = 64}, display.getCurrentStage())
  
  local album_id = params.album_id
  local title = util.GetMaxLenString(params.title, 30)
  local function openAlbumWithData(res)
    if not res or not res.data then
      native.showAlert("Oops!", "This album currently not avaialble!", { "Okay" } )
      return false -- no need to try and run the rest of the function if we don't have our forecast.the
    end
    composer.setVariable( "autoRotate", 1 )
    local _album = res.data.album
--    local title = util.GetMaxLenString(_album.title, 34)
    APP.Header.elements.TopBar:setLabel(title)
    print(inspect(_album))
    APP.albumView = AlbumView:new(_album, sceneGroup)
    APP.Header.layer:toFront()
    APP.albumView:open()
    --APP.Footer.layer:toFront()
  end
  iMoter:getAlbumById(album_id, openAlbumWithData)
--  iMoter:getAlbumById('29711', openAlbumWithData)
  -----------------------------------------------------------------------------
end



-- Called BEFORE scene has moved onscreen:
function scene:show( event )
	local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then

  elseif ( phase == "did" ) then

  end
  --timer.performWithDelay(2000, function() composer.gotoScene('scenes.moter', options) end)
  -----------------------------------------------------------------------------

  --      This event requires build 2012.782 or later.

  -----------------------------------------------------------------------------

end

function scene:hide( event )
	local sceneGroup = self.view
	-- nothing to do here
	if event.phase == "will" then

	end

end

function scene:destroy( event )
	local sceneGroup = self.view
	-- nothing to do here
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene
