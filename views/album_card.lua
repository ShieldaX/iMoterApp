local widget = require( "widget" )
local widgetExtras = require("libs.widget-extras")
local mui = require( "materialui.mui" )
local muiData = require( "materialui.mui-data" )
-- Set a default theme
widget.setTheme("widget_theme_ios7")

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

local class = require 'libs.middleclass'
--local Stateful = require 'libs.stateful'
--local inspect = require 'libs.inspect'
local colorHex = require('libs.convertcolor').hex
local util = require 'util'
local d = util.print_r
local _ = require 'libs.underscore'

-- Fonts
local fontDMFT = 'assets/fonts/DMFT1541427649707.ttf'
local fontSHSans = 'assets/fonts/SourceHanSansK-Regular.ttf'
local fontSHSansBold = 'assets/fonts/SourceHanSansK-Bold.ttf'
local fontMorganiteBook = 'assets/fonts/Morganite-Book-4.ttf'
local fontMorganiteSemiBold = 'assets/fonts/Morganite-SemiBold-9.ttf'
-- ---
-- CLASSES Declaration
--
local View = require "libs.view"
local Tag = require("views.album_tag")
local Card = class('AlbumCardView', View)

local function createIcon(options)
  local fontPath = "icon-font/"
  local materialFont = fontPath .. "MaterialIcons-Regular.ttf"
  options.font = materialFont
  options.text = mui.getMaterialFontCodePointByName(options.text)
  local icon = display.newText(options)
  return icon
end

-- ---
--
function Card:initialize(opts, parent)
  d('-*-*-*-*-*-*-*-*-*-*-*-*-*-*')
  d('- Prototype of Card View -')
  d('- ======================== -')
  assert(type(opts) == 'table' and next(opts) ~= nil, "a named option hash table need to create a footer")
  self.name = opts.name or 'infoCard'-- timestamp
  View.initialize(self, parent)
  assert(self.layer, 'Card View Initialized Failed!')
  d('创建卡片对象: '..self.name)
  -- -------------------
  -- DATA BINDING
  self.barHeight = opts.barHeight or 64
  self.barWidth = opts.barWidth or vW
  self.excerpt = opts.excerpt
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  local function panelTransDone( target )
    if ( target.completeState ) then
      --print( "PANEL STATE IS: "..target.completeState )
    end
  end
  -- Function to handle button events
  local function handleTabBarEvent( event )
    print( event.target.id )  -- Reference to button's 'id' parameter
  end
  local labelFont = fontSHSans
  local labelFontSize = 24
  local labelColor = { default={colorHex('6C6C6C')}, over={colorHex('C7A680')} }
  local onRelease = handleTabBarEvent
  
  local leftPadding, topPadding = 20, 24
  local infoCard = display.newGroup()
  infoCard.anchorChildren = true
  infoCard.anchorX = 0
  infoCard.anchorY = 0.5
  local bg = display.newRect(infoCard, 0, 0, vW, vH*.36)
  bg:setFillColor(colorHex('1A1A19'))
  local excerptText = display.newText {
      parent = infoCard,
      text = self.excerpt,
      x = bg.width*.05, y = topPadding,
      width = bg.width*.9, height = 0,
      font = fontSHSans, fontSize = 16,
      align = 'left'
    }
  bg.anchorX, bg.anchorY = 0, 0
  excerptText.anchorX, excerptText.anchorY = 0, 0
  local textHeight = excerptText.height
  bg.height = textHeight + topPadding*3 + bottomInset
  infoCard.x = -vW*.5
  local panel = widget.newPanel{
    location = "bottom",
    onComplete = panelTransDone,
    width = self.barWidth,
    height = bg.height,
    speed = 300,
    inEasing = easing.outCubic,
    outEasing = easing.inCirc
  }
  panel:insert(infoCard)
  self:_attach(panel, 'panel')
  self:buildTags(opts.tags, 20, 12)
  self.hidden = true
  self:show()
  -- END VISUAL INITIALIING
  -- -------------------
end

function Card:buildTags(tags, left, top)
  local tagslider = display.newGroup()
  top = top or 0
  left = left or 20
  local panel = self.elements.panel
  for k, _tag in pairs(tags) do
    d(_tag)
    local tag = Tag:new(_tag, tagslider)
    tag.layer.x = left
    tag.layer.y = top
    left = left + tag.layer.contentWidth + 10
    tag:start()
    table.insert(self._elements, tag)
  end
  panel:insert(tagslider)
  tagslider.anchorChildren = true
  tagslider.anchorX = 0
  tagslider.anchorY = 1
  tagslider.x = -vW*.5 + vW*.05
  tagslider.y = panel.height*.5 - bottomInset - top
end

function Card:touch(event)
--  local id = event.target.id or event.target.parent.id
  local _t = event.target
  local id = _t.id
  if ( event.phase == "began" ) then
    display.getCurrentStage():setFocus( _t )
    _t.isFocus = true
    print( "Touch event began on: " .. event.target.id )
  elseif _t.isFocus then
    if ( event.phase == "ended" ) then
      print( "Touch event ended on: " .. event.target.id )
      if self.tabSelected == id then
        d('Tab already seleted')
      else
        self:selectTab(event.target.id)
      end
      display.getCurrentStage():setFocus( nil )
      _t.isFocus = false
    end
  end
  return true
end

function Card:tap(event)
--  stop any tap/touch propgation
  return true
end

function Card:show()
  if not self.hidden then return end
  self.hidden = false
  self.elements.panel:show()
end

function Card:hide()
  if self.hidden then return end
  self.hidden = true
  self.elements.panel:hide()
end

function Card:toggle()
  if self.hidden then
    self:show()
  else
    self:hide()
  end
end

function Card:stop()
  d('Try to destroy Album Card')
  self:destroy()
end

return Card