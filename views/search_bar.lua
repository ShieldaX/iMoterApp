-- Use top dropdown panel
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
local Bar = class('SearchBar', View)

local function createIcon(options)
  local fontPath = "icon-font/"
  local materialFont = fontPath .. "MaterialIcons-Regular.ttf"
  options.font = materialFont
  options.text = mui.getMaterialFontCodePointByName(options.text)
  local icon = display.newText(options)
  return icon
end
-- ---
-- Resize Image Display Object to Fit Screen WIDTH
--
function Bar:initialize(opts, parent)
  assert(type(opts) == 'table' and next(opts) ~= nil, "a named option hash table need to create a search bar")
  View.initialize(self, parent)
  assert(self.layer, 'Piece View Initialized Failed!')
  self.name = opts.name or '_search_bar' -- timestamp
  d('创建搜索条对象: '..self.name)
  -- -------------------
  -- DATA BINDING
  self.barHeight = opts.barHeight or 64
  self.barWidth = opts.barWidth or vW
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  -- Configure Bottom Panel
  local function panelTransDone( target )
    if ( target.completeState ) then
--      print( "PANEL STATE IS: "..target.completeState )
    end
  end

  -- Function to handle button events
  local function handleTabBarEvent( event )
    print( event.target.id )  -- Reference to button's 'id' parameter
  end
  local backgroundColor = colorsRGB.RGBA('black', 0.9)
  local panel = widget.newPanel{
    location = "top",
    onComplete = panelTransDone,
    width = self.barWidth,
    height = self.barHeight + topInset,
    speed = 200,
    inEasing = easing.outCubic,
    outEasing = easing.inCirc
  }
  local backgroundRect = display.newRect( 0, -1, panel.width, panel.height - 2 )
  backgroundRect:setFillColor(unpack(backgroundColor))
  local strokeLine = display.newLine(-vW*.5, panel.height*.5, vW*.5, panel.height*.5)
  strokeLine.anchorX = 1
  strokeLine.anchorY = .5
  strokeLine:setStrokeColor(colorHex('C7A680'))
  strokeLine.strokeWidth = 1
--  backgroundRect:setStrokeColor(colorHex('C7A680'))
--  backgroundRect.strokeWidth = 1
  local background = display.newGroup()
  background:insert(backgroundRect)
  background:insert(strokeLine)
  panel.background = background
  panel:insert( background )
  
  local iconOption =  {
      id = "search_icon",
      icon = {name = 'search', fontSize = 36},
      xOffset = vW*0.36, yOffset = topInset*.5
    }
  local defaultColor = {colorHex('6C6C6C')}
  local overColor = {colorHex('C7A680')}
  local fillColor = overColor
  local icon = createIcon {
    x = 0, y = 0,
    text = 'search',
    fontSize = 32
  }
  icon:setFillColor(unpack(fillColor))
  icon.x = iconOption.xOffset
  icon.y = iconOption.yOffset
  panel:insert(icon)
  icon:addEventListener('tap', self)
  
  local input = widget.newTextField {
      id = 'search_field',
      left = -vW*.4, top = -18,
      width = vW*.69, height= 32,
      label = '搜索',
      labelFontSize = 12, labelFontColor = {colorHex('C7A680')},
      labelWidth = 46
    }
  panel:insert(input)
  
  self:_attach(panel, 'bar')
  self.hidden = true
--  self:show()
  -- END VISUAL INITIALIING
  -- -------------------
end

function Bar:tap(event)
--  stop any tap/touch propgation
  return true
end

function Bar:show()
  if not self.hidden then return end
  self.hidden = false
  self.elements.bar:show()
end

function Bar:hide()
  if self.hidden then return end
  self.hidden = true
  self.elements.bar:hide()
end

function Bar:toggle()
  if self.hidden then
    self:show()
  else
    self:hide()
  end
end

return Bar