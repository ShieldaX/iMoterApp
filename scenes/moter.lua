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

local inspect = require('libs.inspect')
local iMoterAPI = require( "classes.iMoter" )

--local mui = require( "materialui.mui" )
local AlbumView = require("views.album")
local MoterView = require("views.moter_ui")
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
function util.createIcon(options)
  local fontPath = "icon-font/"
  local materialFont = fontPath .. "MaterialIcons-Regular.ttf"
  options.font = materialFont
  local x,y = 160, 240
  if options.x ~= nil then
      x = options.x
  end
  if options.y ~= nil then
      y = options.y
  end  
  local fontSize = options.height
  if options.fontSize ~= nil then
      fontSize = options.fontSize
  end
  fontSize = math.floor(tonumber(fontSize))
  
  local font = native.systemFont
  if options.font ~= nil then
      font = options.font
  end
  local textColor = { 0, 0.82, 1 }
  if options.textColor ~= nil then
      textColor = options.textColor
  end
  local fillColor = { 0, 0, 0 }
  if options.fillColor ~= nil then
      fillColor = options.fillColor
  end
  options.isFontIcon = true
  -- scale font
  -- Calculate a font size that will best fit the given text field's height
  local checkbox = {contentHeight=options.height, contentWidth=options.width}
  local textToMeasure = display.newText( options.text, 0, 0, font, fontSize )
  fontSize = math.floor(fontSize * ( ( checkbox.contentHeight ) / textToMeasure.contentHeight ))
  local tw = textToMeasure.contentWidth
  local th = textToMeasure.contentHeight
  tw = fontSize
  options.text = mui.getMaterialFontCodePointByName(options.text)
  textToMeasure:removeSelf()
  textToMeasure = nil
  local options2 =
    {
      --parent = textGroup,
      text = options.text,
      x = x,
      y = y,
      font = font,
      width = tw * 1.5,
      fontSize = fontSize,
      align = "center"
    }
  local _icon = display.newText( options2 )
  _icon:setFillColor(unpack(textColor))
  return _icon
end

-- Called when the scene's view does not exist:
function scene:create( event )
	local sceneGroup = self.view
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

  local options2 = {
    --parent = mui.getParent(),
    name = "plus",
    text = "menu",
    width = 25,
    height = 25,
    x = 30,
    y = 25,
    isFontIcon = true,
    font = mui.materialFont,
    textColor = { 0.25, 0.75, 1, 1 }
  }
  local iconFace = util.createIcon( options2 )
  iconFace:setFillColor(unpack(colorsRGB.RGBA('white', 0.9)))
  
  local buttonG = display.newGroup()
  local _text = display.newText { text = '女神图集', x = cX, y = cY, fontSize = 18, align = 'center', font = 'Helvetica' }
  local moreIcon = util.createIcon {
      name = "plus",
      text = "expand_more",
      width = 40,
      height = 40,
      x = cX, y = vH*.9,
      isFontIcon = true,
      font = mui.materialFont,
      textColor = { 0.25, 0.75, 1, 1 }
    }
  _text:setFillColor(unpack(colorsRGB.RGBA('white', 0.9)))
  moreIcon:setFillColor(unpack(colorsRGB.RGBA('white', 0.9)))
  util.center(moreIcon)
  moreIcon.y = _text.y + _text.height*1.5
  buttonG:insert(_text)
  buttonG:insert(moreIcon)
  buttonG.anchorChildren = true
  util.center(buttonG)
  buttonG.y = vH*.94
  
  --transition.blink(buttonG, {transition = easing.outExpo, time = 6000})
  local contentH = _text.contentHeight
  transition.from(buttonG, {delay = 1200, time = 1000, y = buttonG.y+(contentH*-1), alpha = 0, transition = easing.outBack})
  transition.to(buttonG, {iterations = -1, delay = 2200, time = 2400, y = buttonG.y+(contentH*0.2), alpha = 0.5, transition = easing.continuousLoop})
  
  sceneGroup:insert(buttonG)
  
  APP.Header = HeaderView:new({name = 'TopBar' }, sceneGroup)
  --APP.Footer = FooterView:new({name = 'AppTabs'}, sceneGroup)
  
  local function showMoterWithData(res)
    if not res or not res.data then
      native.showAlert("Oops!", "This moter currently not avaialble!", { "Okay" } )
      return false -- no need to try and run the rest of the function if we don't have our forecast.the
    end
    local _moter = res.data.moter
    APP.Header.elements.TopBar:setLabel(_moter.name)
    APP.Header.elements.TopBar._title:setFillColor(unpack(colorsRGB.RGBA('white')))
    print(inspect(_moter))
    APP.moterView = MoterView:new(_moter, sceneGroup)
    APP.Header.layer:toFront()
    --APP.Footer.layer:toFront()
    APP.moterView:layout()
  end
--  iMoter:getMoterById('22162', showMoterWithData)
  iMoter:getMoterById('27180', showMoterWithData)
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
