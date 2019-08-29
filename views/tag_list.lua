local composer = require( "composer" )
local widget = require( "widget" )
local mui = require( "materialui.mui" )

local _ = require 'libs.underscore'
local class = require 'libs.middleclass'
local Stateful = require 'libs.stateful'
local inspect = require 'libs.inspect'
local colorHex = require('libs.convertcolor').hex

local util = require 'util'
local d = util.print_r

-- Classes
local View = require 'libs.view'
local Tag = require 'views.album_tag'
local TagList = class('TagListView', View)
local APP = require("classes.application")

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

local function createIcon(options)
  local fontPath = "icon-font/"
  local materialFont = fontPath .. "MaterialIcons-Regular.ttf"
  options.font = materialFont
  options.text = mui.getMaterialFontCodePointByName(options.text)
  local icon = display.newText(options)
  return icon
end

-- 利用获取的图集信息实例化一个图集对象
function TagList:initialize(obj, topPadding, sceneGroup)
  View.initialize(self, sceneGroup)
  -- -------------------
  -- DATA BINDING
  self.rawData = obj
  self._tags = obj.tags
  self.name = 'tagSearchResult'
  self.tags = {}
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  -- ScrollView listener
  local function onScrollComplete()
    print( "Scroll complete!" )
  end
  
  local function scrollListener( event )
    local _t = event.target
    local phase = event.phase
    if ( phase == "began" ) then
      _t.xStart, _t.yStart = _t:getContentPosition()
    elseif ( phase == "moved" ) then
      _t.xLast, _t.yLast = _t:getContentPosition()
      _t.motion = _t.yLast - _t.yStart
      local isTabBarHidden = APP.Footer.hidden
      if _t.motion <= -30 and not isTabBarHidden then
--        APP.Footer:hide()
      elseif _t.motion >= 30 and isTabBarHidden then
--        APP.Footer:show()
      end
    elseif ( phase == "ended" ) then
      print( "Scroll view was released" )
    end
    -- In the event a scroll limit is reached...
    if ( event.limitReached ) then
      local slider = self.elements.slider
      if ( event.direction == "up" ) then
        print( "Reached bottom limit" )
      elseif ( event.direction == "down" ) then print( "Reached top limit" )
      elseif ( event.direction == "left" ) then
        print( "Reached right limit" )
      elseif ( event.direction == "right" ) then print( "Reached left limit" )
      end
    end
    return true
  end
  local padding = topPadding or 0
  local scrollContainer = widget.newScrollView{
    top = oY, left = oX,
    width = vW, height = vH - padding,
    scrollWidth = vW, scrollHeight = vH,
    hideBackground = true,
    hideScrollBar = true,
    friction = 0.946,
    listener = scrollListener,
    horizontalScrollDisabled = true
  }
  self:_attach(scrollContainer, 'slider')
  -- END VISUAL INITIALIING
  -- -------------------
end

function TagList:buildTags(tags, left, top)
  local tagslider = self.elements.slider
  top = top or 60
  left = left or 20
  tags = tags or self._tags
  if not next(tags) then
    local notFoundLabel = display.newText {
      parent = self.layer,
      text = '未找到匹配的标签，请尝试其他关键词',
      x = cX, y = cY - vH*.32,
      width = vW*.9, height = 0,
      font = fontSHSansBold, fontSize = 16,
      align = 'center'
    }
    notFoundLabel:setFillColor(colorHex('6C6C6C'))
    return
  end
  for k, _tag in pairs(tags) do
    _tag.size = 16
    local tag = Tag:new(_tag, self.elements.slider)
    local tagL = tag.layer
    tagL.x = left
    tagL.y = top
    left = left + tagL.contentWidth + 16
    if tagL.x + tagL.contentWidth >= vW then
      left = 20
      top = top + 48
      tagL.x = left
      tagL.y = top
      left = left + tagL.contentWidth + 16
    end
    tag:start()
    table.insert(self._elements, tag)
  end
end

function TagList:onTagTapped(event)
  APP.Footer:hide()
  local options = {
    effect = "slideLeft",
    time = 300,
    params = {tag_id = event.tagID, tag_name = event.tagName, tab = 'search'}
  }
  d(options)
  d('打开搜索后标签页面...')
  composer.gotoScene( "scenes.tag", options )
  -- recycle album scene while switching to tagged album list scene
--  composer.setVariable('sceneToRemove', 'scenes.album')
end

function TagList:start()
  if self.state == 30 then return false end
  --local e = self.elements
  self:setState('STARTED')
end

function TagList:stop()
  self:cleanup()
end

return TagList