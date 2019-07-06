----------------------------------------------------------------------------------
--      Main App
--      Scene notes
---------------------------------------------------------------------------------
local composer = require( "composer" )
-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

local background = nil
local widget = require( "widget" )

local inspect = require('libs.inspect')
local iMoterAPI = require( "classes.iMoter" )

--local mui = require( "materialui.mui" )
local AlbumView = require("views.album")
local MoterView = require("views.moter")
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

local iMoter = iMoterAPI:new()

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:create( event )
	local sceneGroup = self.view

  --Hide status bar from the beginning
  display.setStatusBar( display.HiddenStatusBar )
  display.setDefault("background", 0, 1, 1)

  --mui.init(nil, { parent=self.view })
  -----------------------------------------------------------------------------

  --      CREATE display objects and add them to 'group' here.

  -- Gather insets (function returns these in the order of top, left, bottom, right)
  local topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()
  -- Create a vector rectangle sized exactly to the "safe area"
  background = display.newRect(
    display.screenOriginX + leftInset,
    display.screenOriginY + topInset,
    display.viewableContentWidth - ( leftInset + rightInset ),
    display.viewableContentHeight - ( topInset + bottomInset )
  )
  background:setFillColor( 0 )
  background:translate( background.contentWidth*0.5, background.contentHeight*0.5 )
  sceneGroup:insert( background )
  
  APP.Header = HeaderView:new({name = 'TopBar' }, sceneGroup)
  --APP.Footer = FooterView:new({name = 'AppTabs'}, sceneGroup)
  
  local function showMoterWithData(res)
    if not res or not res.data then
      native.showAlert("Oops!", "This moter currently not avaialble!", { "Okay" } )
      return false -- no need to try and run the rest of the function if we don't have our forecast.the
    end
    local _moter = res.data.moter
    APP.Header.elements.TopBar:setLabel(_moter.name)
    print(inspect(_moter))
    APP.moterView = MoterView:new(_moter, sceneGroup)
    APP.Header.layer:toFront()
    --APP.Footer.layer:toFront()
    APP.moterView:layout()
  end
  iMoter:getMoterById('22162', showMoterWithData)
  -----------------------------------------------------------------------------
end



-- Called BEFORE scene has moved onscreen:
function scene:show( event )
	local sceneGroup = self.view
  --APP.Footer.layer:toFront()
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
