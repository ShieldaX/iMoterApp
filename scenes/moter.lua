----------------------------------------------------------------------------------
--      Main App
--      Scene notes
---------------------------------------------------------------------------------
local mui = require( "materialui.mui" )
local muiData = require( "materialui.mui-data" )

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

local fontDMFT = 'assets/fonts/DMFT1541427649707.ttf'
local fontSHSans = 'assets/fonts/SourceHanSansK-Regular.ttf'
local fontSHSansBold = 'assets/fonts/SourceHanSansK-Bold.ttf'
local fontMorganiteBook = 'assets/fonts/Morganite-Book-4.ttf'
local fontMorganiteSemiBold = 'assets/fonts/Morganite-SemiBold-9.ttf'
local fontZcoolHuangYou = 'assets/fonts/站酷庆科黄油体.ttf'

local colorHex = require('libs.convertcolor').hex
local widget = require( "widget" )
local util = require 'util'
local d = util.print_r

local background = nil

local inspect = require('libs.inspect')
local iMoterAPI = require( "classes.iMoter" )

local AlbumView = require("views.album")
local MoterView = require("views.moter_ui")
local IconButton = require("views.icon_button")
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

-- @usage: https://material.io/tools/icons
local function createIcon(options)
  local fontPath = "icon-font/"
  local materialFont = fontPath .. "MaterialIcons-Regular.ttf"
  options.font = materialFont
  options.text = mui.getMaterialFontCodePointByName(options.text)
  local icon = display.newText(options)
  return icon
end

local function leftButtonEvent( event )
	if event.phase == "ended" then
    composer.hideOverlay('slideRight', 420)
	end
	return true
end

-- Called when the scene's view does not exist:
function scene:create( event )
  local sceneGroup = self.view
  local params = event.params
  mui.init(nil, { parent=self.view })
  -----------------------------------------------------------------------------
  -- Create a vector rectangle sized exactly to the "safe area"
  local background = display.newRect(sceneGroup, oX, oY, vW, vH)
  background:setFillColor(colorHex('1A1A19'))
  background:translate( background.contentWidth*0.5, background.contentHeight*0.5 )
  
  self.header = HeaderView:new({name = 'NavBar', onEvent = leftButtonEvent}, sceneGroup)
  
  local moter_id = params.moter_id
  
  local function showMoterWithData(res)
    if not res or not res.data then
      native.showAlert("Oops!", "This moter currently not avaialble!", { "Okay" } )
      return false -- no need to try and run the rest of the function if we don't have our forecast.the
    end
    local _moter = res.data.moter
    local _data = res.data
--    d(_data)
    self.header.elements.navBar:setLabel(_moter.name)
    local moterView = MoterView:new(_data, sceneGroup)
    self.moterView = moterView
    self.moterView:layout()
    self.header.layer:toFront()
  end
  iMoter:getMoterById(moter_id, {fetchcover = true}, showMoterWithData) -- 19702; 22162; 27180
--  iMoter:getMoterById('18229', {}, showMoterWithData)
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
    --
  elseif event.phase == "did" then
    --self.moterView:stop()
  end

end

function scene:destroy( event )
  local sceneGroup = self.view
  -- nothing to do here
  self.header:cleanup()
  self.moterView:stop()
  d('Moter scene destoried success!')
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene
