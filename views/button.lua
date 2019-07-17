local widget = require( "widget" ) 
-- Set a default theme
widget.setTheme( "widget_theme_ios7" )

-- Constants List:
local oX = display.screenOriginX
local oY = display.screenOriginY
local vW = display.viewableContentWidth
local vH = display.viewableContentHeight
local visibleAspectRatio = vW/vH

local class = require 'libs.middleclass'
local Stateful = require 'libs.stateful'
--local inspect = require 'libs.inspect'

local util = require 'util'
local d = util.print_r

-- local forward references should go here --
local screenW, screenH, halfW, halfH = display.contentWidth, display.contentHeight, display.contentWidth*0.5, display.contentHeight*0.5
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

-- ---
-- CLASSES Declaration
--
local View = require "libs.view"
local Button = class('Button', View)
--local Toast = require 'views.toast'
local APP = require("classes.application")
Button:include(Stateful)

-- Enum of Indicator Types
Button.static.TYPE = {
    DEFAULT = 10,
    PLAIN = 10, -- DEFAULT
    BAR = 20,
    CUSTOMED = 100
  }
  
--[[
 options..
    name: name of button
    width: width
    height: height
    radius: radius of the corners
    strokeColor: {r, g, b}
    fillColor: {r, g, b}
    x: x
    y: y
    text: text for button
    textColor: {r, g, b}
    font: font to use
    fontSize:
    textMargin: used to pad around button and determine font size,
    circleColor: {r, g, b} (optional, defaults to textColor)
    touchpoint: boolean, if true circle touch point is user based else centered
    callBack: method to call passing the "e" to it
]]
-- ---
-- Button View Class
--
function Button:initialize(opts, parent)
  assert(type(opts) == 'table' and next(opts) ~= nil, "a named option hash table need to create a button")
  self.name = opts.name or '_Button'..os.time() -- timestamped
  View.initialize(self, parent)
  assert(self.layer, 'Button View Initialized Failed!')
  d('创建按钮对象: '..self.name) -- Key =>（按）键; Button => 按钮 
  -- -------------------
  -- DATA BINDING
  self.config = opts
  self.padding = opts.padding or 40
  self.labelText = opts.text or 'Button'
  self.type = Button.TYPE.DEFAULT
  -- Set UI constructor data by Custom Configuration or Default
  self.fillColor = opts.fillColor or colorsRGB.RGBA('white')
  self.strokeColor = opts.strokeColor or colorsRGB.RGBA('royalblue')
  self.strokeWidth = opts.strokeWidth or 0
  
  self.textColor = opts.textColor or colorsRGB.RGBA('royalblue')
  self.font = opts.font or native.systemFontBold
  
  self:send('label')
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  -- Configure UI  
  self:ui(Button.TYPE.DEFAULT)
  -- END VISUAL INITIALIING
  -- -------------------
end

-- overridable visual constructor
function Button:ui(btnType)
  local btnTypeList = Button.TYPE
  btnType = table.indexOf(btnTypeList, btnType) or btnTypeList.DEFUALT
  if btnType == btnTypeList.DEFUALT or btnType == btnTypeList.PLAIN then
    -- 普通文字按钮
    local touchArea = display.newRect(0, 0, self.width or 200, self.height or 100)
    touchArea:setFillColor(colorsRGB.RGBA('gray', 0.6))
    touchArea.anchorX, touchArea.anchorY = .5, .5
    if not Button.DEBUG then
      touchArea.isVisible = true
    else
      touchArea.isVisible = false
    end
    touchArea.isHitTestable = true
    local label = display.newText { -- TODO: Use embossed text constructor
        text = self.labelText,
        x = 0, y = 0,
        font = native.systemFontBold,
        fontSize = self.fontSize or 16
      }
    touchArea.width = self.padding*2+label.width
    touchArea.height = self.padding*2+label.height
    --
    self.touchDelegate = touchArea
  end
  self:send('start')
  --self:gotoState('TOUCHABLE')
end

function Button:start()
  if not self.touchDelegate then return false end
  self.touchDelegate:addEventListener('touch', self)
end

function Button:touch(touch)
  d(touch.phase)
end

local activeButton = Button:addState('Active')
  
function activeButton:touch(touch)
  local phase = touch.phase
  self:send('active')
  
end

function activeButton:active()
  
end

return Button

--https://github.com/luapower/ui/blob/master/ui_button.lua
