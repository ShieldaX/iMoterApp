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
local convertColor = require('libs.convertcolor')
--local utility = require( "libs.utility" )
local inspect = require('libs.inspect')
local iMoterAPI = require( "classes.iMoter" )

local TagList = require("views.tag_list")
local SearchBar = require("views.search_bar")
--local Indicator = require 'views.indicator'

local scene = composer.newScene()
-- Our modules
local APP = require( "classes.application" )
local iMoter = iMoterAPI:new()

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
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
--  mui.init(nil, { parent=self.view })
  background = display.newRect(sceneGroup, oX, oY, vW, vH)
  background:setFillColor(colorHex('1A1A19'))
  background:translate( background.contentWidth*0.5, background.contentHeight*0.5 )
  sceneGroup:insert( background )

  self.searchBar = SearchBar:new({name = 'searchBar'}, sceneGroup)
--  self.searchBar:show()
  -- Push scene on to search tab [root]
  APP.pushScene({name = composer.getSceneName('current'), params = params}, 'search')
  -----------------------------------------------------------------------------
end

function scene:search(name)
  if self.tagListView then
    self.tagListView:cleanup()
    self.tagListView = nil
  end
  local sceneGroup = self.view
  local labelFSize = 20
  local padding = labelFSize*.618
  local function showTagsWithSearchResult(res)
    if not res or not res.data then
      native.showAlert("Oops!", "Tag list currently not avaialble!", { "Okay" } )
      return false -- no need to try and run the rest of the function if we don't have our forecast.the
    end
--    local _tagList = res.data.tags
--    if not next(_tagList) then 
      
--    end
    local _data = res.data
    local topPadding = self.searchBar.layer.contentHeight + 10
    local tagListView = TagList:new(_data, topPadding, sceneGroup)
    self.searchBar.layer:toFront()
    self.tagListView = tagListView
    local cursor = APP.Header.elements.cursor
    tagListView.layer.y = tagListView.layer.y + cursor.y + padding
    tagListView:buildTags()
--    tagListView.bumper = iMoter
  end
--  TODO: check/validate searching name
  iMoter:searchTags(name, showTagsWithSearchResult)
end

-- Called BEFORE scene has moved onscreen:
function scene:show( event )
  local sceneGroup = self.view
  if event.phase == "did" then
    APP.Footer:show()
    self.searchBar:show()
    d('search showing...')
    function background:tap(event)
      native.setKeyboardFocus(nil)
      if self.tagListView then
        self.tagListView:cleanup()
        self.tagListView = nil
      end
    end
    background:addEventListener("tap", background)
    
    local sceneToRemove = composer.getVariable('sceneToRemove')
    if sceneToRemove then
      composer.removeScene(sceneToRemove)
      d(sceneToRemove)
      composer.setVariable('sceneToRemove', false)
    end
    APP._scenes()
  end
end

function scene:hide( event )
  local sceneGroup = self.view
  -- nothing to do here
  if event.phase == "will" then
--    self.searchBar:hide()
  end

end

function scene:destroy( event )
  local sceneGroup = self.view
  -- nothing to do here
--  mui.destroy()
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene