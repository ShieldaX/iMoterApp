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
-- Gather insets (function returns these in the order of top, left, bottom, right)
local topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()

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

local AlbumList = require("views.tag_album_list")
local HeaderView = require("views.header")
--local Indicator = require 'views.indicator'
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
  local tag_id = params.tag_id or 'meitui'
  local tag_name = params.tag_name or '美腿'
  
  local onTab = params.onTab or 'home'
--  mui.init(nil, { parent=self.view })
  -----------------------------------------------------------------------------
  -- Create a vector rectangle sized exactly to the "safe area"
  background = display.newRect(sceneGroup, oX, oY, vW, vH)
  background:setFillColor(colorHex('1A1A19'))
  background:translate( background.contentWidth*0.5, background.contentHeight*0.5 )
  sceneGroup:insert( background )
  self.header = HeaderView:new({name = 'TopBar', onTab = onTab}, sceneGroup)
--  local _lgray = {colorHex('6C6C6C')}
  local labelFSize = 20
  local padding = labelFSize*.618
  local function showAlbumsWithData(res)
    if not res or not res.data then
      native.showAlert("Oops!", "Album list currently not avaialble!", { "Okay" } )
      return false -- no need to try and run the rest of the function if we don't have our forecast.the
    end
    local _albumList = res.data.albums
    local _data = res.data
    d(_data)
    self.header.elements.navBar:setLabel(tag_name)
    local topPadding = topInset
    local albumListView = AlbumList:new(_data, topPadding, sceneGroup)
    self.albumListView = albumListView
    albumListView.layer.y = albumListView.layer.y + self.header.layer.contentHeight
    albumListView:open()
    albumListView.bumper = iMoter
    self.header.layer:toFront()
  end
  iMoter:listAlbumsByTag(tag_id, {skip = 0, limit = 10}, showAlbumsWithData)
  APP:sceneForwards(params)
  -----------------------------------------------------------------------------
end

-- Called BEFORE scene has moved onscreen:
function scene:show( event )
  local sceneGroup = self.view
  if event.phase == "did" then
    d('tag showing...')
    local sceneToRemove = composer.getVariable('sceneToRemove')
    if sceneToRemove then
      composer.removeScene(sceneToRemove)
      composer.setVariable('sceneToRemove', false)
    end
--    APP._scenes()
  end
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