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

--local AlbumView = require("views.album")
local AlbumList = require("views.moter_album_list")
local MoterView = require("views.moter_ui")
--local IconButton = require("views.icon_button")
local HeaderView = require("views.header")
--local FooterView = require("views.footer")

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
local iMoter = iMoterAPI:new()
APP.iMoterAPI = iMoter

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
--[[
local function leftButtonEvent( event )
	if event.phase == "ended" then
		local prevScene = composer.getSceneName( "previous" )
		if prevScene then
			composer.gotoScene( prevScene, {effect = 'slideRight', time = 420} )
		end
	end
	return true
end
]]
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
  self.bg = background
  self.header = HeaderView:new({name = 'NavBar'}, sceneGroup)
  
  local moter_id = params.moter_id
  self.moter_id = moter_id
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
  APP.pushScene({name = composer.getSceneName('current'), params = params})
  -----------------------------------------------------------------------------
end

-- Called BEFORE scene has moved onscreen:
function scene:show( event )
  local sceneGroup = self.view
  --APP.Footer.layer:toFront()
  if event.phase == "did" then
    d('moter showing...')
    local sceneName = APP.currentScene().name
    local currentScene = composer.getSceneName('current')
    if not (sceneName == currentScene) then
      d('remove '..sceneName)
      composer.removeScene(sceneName)
    else
      d('not remove '..sceneName)
    end
    APP._scenes()
  end
end

function scene:loadMoterAlbumList()
  if self.moterAlbumListView then return end
  local oldLabel = self.header.elements.navBar:getLabel()
  self.header.elements.navBar:setLabel(oldLabel..'·图集')
  local sceneGroup = self.view
  local labelFSize = 20
  local padding = labelFSize*.618
  local function showAlbumsWithData(res)
    if not res or not res.data then
      native.showAlert("Oops!", "Album list currently not avaialble!", { "Okay" } )
      return false
    end
    local _albumList = res.data.albums
    local _data = res.data
    _data.moter_id = self.moter_id
    local topPadding = topInset
    local albumListView = AlbumList:new(_data, topPadding, sceneGroup)
    self.moterAlbumListView = albumListView
--    albumListView.layer.y = self.moterView.elements.hint.y
    albumListView.layer.y = self.header.layer.contentHeight + padding
    albumListView:open()
  end
  iMoter:listAlbumsOfMoter(self.moter_id, {skip = 0, limit = 6}, showAlbumsWithData)
end

function scene:unloadMoterAlbumList()
  if not self.moterAlbumListView then return end
  local sceneGroup = self.view
  local oldLabel = self.header.elements.navBar:getLabel()
  self.header.elements.navBar:setLabel(string.gsub(oldLabel, '·图集', ''))
  local albumListView = self.moterAlbumListView
  albumListView:stop()
  if albumListView.layer then sceneGroup:remove(albumListView.layer) end
  albumListView = nil
  self.moterAlbumListView = nil
end

function scene:hide( event )
  local sceneGroup = self.view
  -- nothing to do here
  if event.phase == "will" then
    --
  elseif event.phase == "did" then

  end
end

function scene:destroy( event )
  local sceneGroup = self.view
  -- nothing to do here
  self.header:cleanup()
  self.moterView:stop()
  if self.moterAlbumListView then self.moterAlbumListView:stop() end
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
