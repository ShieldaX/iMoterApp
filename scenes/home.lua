----------------------------------------------------------------------------------
--      Main App
--      Scene notes
---------------------------------------------------------------------------------
local mui = require( "materialui.mui" )
local muiData = require( "materialui.mui-data" )

local composer = require( "composer" )

local util = require 'util'
local d = util.print_r
local colorHex = require('libs.convertcolor').hex

-- Constants List:
local oX = display.screenOriginX
local oY = display.screenOriginY
local vW = display.viewableContentWidth
local vH = display.viewableContentHeight
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
local fontZcoolHuangYou = 'assets/fonts/站酷庆科黄油体.ttf'

local background = nil
local widget = require( "widget" )

local inspect = require('libs.inspect')
local iMoterAPI = require( "classes.iMoter" )

--local mui = require( "materialui.mui" )
local AlbumView = require("views.album")
local AlbumList = require("views.home")
local MoterView = require("views.moter_ui")
local HeaderView = require("views.header")
local FooterView = require("views.footer")
local Indicator = require 'views.indicator'

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

local indicator = Indicator:new({name= 'loadingIn', top= 0}, scene.view)
indicator.elements.spinner.y = vH*.36
--indicator:send('onPieceLoad')

function indicator:onMoterLoad(event)
  self:onPieceLoad(event)
end

function indicator:onMoterLoaded(event)
  self:onPieceLoaded(event)
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
  background:setFillColor(colorHex('1A1A19'))
  background:translate( background.contentWidth*0.5, background.contentHeight*0.5 )
  sceneGroup:insert( background )
  APP.Header = HeaderView:new({name = 'TopBar'}, sceneGroup)
  APP.Footer = FooterView:new({name = 'AppTabs', barHeight = 64}, display.getCurrentStage())
  
  local _lgray = {colorHex('6C6C6C')}
  local titleFSize = 12
  local labelFSize = 20
  local padding = labelFSize*.618
  local gY = APP.Header.elements.TopBar.contentBounds.yMax + padding*2

  local labelScoreCount = display.newText {text = '最新', x = vW*.24, y = gY, fontSize = labelFSize, font = fontZcoolHuangYou}
  local labelNumAlbum = display.newText {text = '热门', x = vW*.5, y = gY, fontSize = labelFSize, font = fontZcoolHuangYou}
  local labelNumHot = display.newText {text = ' ', x = vW*.76, y = gY, fontSize = labelFSize, font = fontZcoolHuangYou}
  sceneGroup:insert(labelScoreCount)
  sceneGroup:insert(labelNumAlbum)
  sceneGroup:insert(labelNumHot)
  local cursorRect = display.newRect(cX, cY, vW*.2, 4)
  cursorRect:setFillColor(colorHex('C7A680'))
  cursorRect.anchorY = 1
  cursorRect.y = labelScoreCount.y + padding*2
  sceneGroup:insert(cursorRect)
  cursorRect.x = labelScoreCount.x  
  
--  TODO: Show Indicator Before Moter View Really Loaded
  indicator:send('onAlbumListLoad')
  local function showAlbumsWithData(res)
    if not res or not res.data then
      native.showAlert("Oops!", "Album list currently not avaialble!", { "Okay" } )
      return false -- no need to try and run the rest of the function if we don't have our forecast.the
    end
    local _albumList = res.data.albums
    local _data = res.data
    APP.Header.elements.TopBar:setLabel('模图云') --TODO: show _data.moter.name
    APP.Header.elements.TopBar._title:setFillColor(unpack(colorsRGB.RGBA('white')))
    print(inspect(_data))
    local albumListView = AlbumList:new(_data, sceneGroup)
    APP.albumListView = albumListView
    APP.Header.layer:toFront()
    --APP.Footer.layer:toFront()
    --APP.moterView:layout()
    albumListView:open()
  end
  iMoter:listAlbums('22162', {skip = 0, limit = 10}, showAlbumsWithData) -- 19702; 22162; 27180
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