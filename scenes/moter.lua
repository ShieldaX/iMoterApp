----------------------------------------------------------------------------------
--      Main App
--      Scene notes
---------------------------------------------------------------------------------
local mui = require( "materialui.mui" )
local muiData = require( "materialui.mui-data" )

local composer = require( "composer" )

local util = require 'util'
local d = util.print_r
-- forward declarations and other locals
local screenW, screenH, halfW, halfH = display.contentWidth, display.contentHeight, display.contentWidth*0.5, display.contentHeight*0.5
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight
local cX, cY = screenOffsetW + halfW, screenOffsetH + halfH

-- Constants List:
local oX = display.screenOriginX
local oY = display.screenOriginY
local vW = display.viewableContentWidth
local vH = display.viewableContentHeight

local background = nil
local widget = require( "widget" )
local colorHex = require('libs.convertcolor').hex

local inspect = require('libs.inspect')
local iMoterAPI = require( "classes.iMoter" )

--local mui = require( "materialui.mui" )
local AlbumView = require("views.album")
local MoterView = require("views.moter_ui")
local IconButton = require("views.icon_button")
--local HeaderView = require("views.header")
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

-- Called when the scene's view does not exist:
function scene:create( event )
  local sceneGroup = self.view
  local params = event.params
  mui.init(nil, { parent=self.view })
  -----------------------------------------------------------------------------

  --      CREATE display objects and add them to 'group' here.

  -- Gather insets (function returns these in the order of top, left, bottom, right)
  local topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()
  -- Create a vector rectangle sized exactly to the "safe area"
  background = display.newRect(
    oX + leftInset,
    oY + topInset,
    vW - ( leftInset + rightInset ),
    vH - ( topInset + bottomInset )
  )
  background:setFillColor( 1, 1, 1, 0.8 )
  background:translate( background.contentWidth*0.5, background.contentHeight*0.5 )
  sceneGroup:insert( background )
  
  local iconDownArrow = IconButton {
    name = 'btn_arrow_down',
    x = 0, y = 0,
    text = 'expand_more',
    fontSize = 20,
  }
  --APP.Header = HeaderView:new({name = 'TopBar' }, sceneGroup)
  local moter_id = params.moter_id
  local function showMoterWithData(res)
    if not res or not res.data then
      native.showAlert("Oops!", "This moter currently not avaialble!", { "Okay" } )
      return false -- no need to try and run the rest of the function if we don't have our forecast.the
    end
    local _moter = res.data.moter
    local _data = res.data
    --APP.Header.elements.TopBar:setLabel(_moter.name)
    --APP.Header.elements.TopBar._title:setFillColor(unpack(colorsRGB.RGBA('white')))
    d(_data)
    local moterView = MoterView:new(_data, sceneGroup)
    self.moterView = moterView
    --APP.Header.layer:toFront()
    self.moterView:layout()
    sceneGroup:insert(iconDownArrow.layer)
    self.backBtnG = iconDownArrow
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
    self.moterView:stop()
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
