--local widget = require( "widget" ) 
--widget.setTheme( "widget_theme_ios7" )

local APP = require("classes.application")

-- Constants List:
local oX = display.screenOriginX
local oY = display.screenOriginY
local vW = display.viewableContentWidth
local vH = display.viewableContentHeight
local visibleAspectRatio = vW/vH
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

local class = require 'libs.middleclass'
--local Stateful = require 'libs.stateful'
--local inspect = require 'libs.inspect'
local colorHex = require('libs.convertcolor').hex
local util = require 'util'
local d = util.print_r

-- ---
-- CLASSES Declaration
--
local View = require "libs.view"
local Toast = class('ToastView', View)

Toast.static.LENGTH_SHORT = 1000 --ms
Toast.static.LENGTH_LONG = 2000 --ms
Toast.static.instance = {calledTimes = 0}

-- -----------------------
-- TOAST View Singleton Pattern
--
function Toast:allocate()
  Toast.instance.class = self
  return setmetatable(Toast.instance, self.__instanceDict)
end

function Toast:initialize(text, duration, delay)
  if text == nil or type(text) ~= 'string' then return end
  if Toast.instance.state and Toast.instance.state >= View.STATUS.INITIALIZED then
    if self.transitionId then
      d('Repeating!')
      transition.cancel(self.transitionId)
    end
    self:cleanup()
    self.calledTimes = self.calledTimes + 1
  end
  View.initialize(self)
  -- -------------------
  -- DATA BINDING
  self.text = text
  self.name = name or 'toaster' -- timestamp
  self.cornerRadius = radius or 10
  self.duration = duration or Toast.LENGTH_LONG
  self.delay = delay
  d('消息框对象: '..self.duration)
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  local _text = display.newText { text = text, x = cX, y = cY, fontSize = 18, align = 'center', font = fontSHSansBold }
--  _text.alpha = 0
  _text:setFillColor(colorHex('C7A680'))
  local _bg_width, _bg_height = _text.width + 25, _text.height + 20
  local _bg = display.newRoundedRect(self.layer, cX, cY, _bg_width, _bg_height, self.cornerRadius)
--  _bg:setFillColor(unpack( colorsRGB.RGBA('royalblue', 0.8) )) -- Pure White
  _bg:setFillColor(colorHex('1A1A19'), 0.8) -- Golden
  util.center(_bg)
  self:_attach(_bg, '_bg')
  self:_attach(_text, '_text')
  self.layer.alpha = 0
  -- END VISUAL INITIALIING
  -- -------------------
  APP.Toast = self
  d('Toast called times:: '..self.calledTimes)
end

function Toast:getInstance()
  return Toast.instance
end

function Toast:makeText(text)
  local olderTextWidth = self.elements._text.width
  self.elements._text.text = text
  self.elements._bg.width = self.elements._bg.width + (self.elements._text.width - olderTextWidth)
end

function Toast:show(x, y)
  x = x or 0
  y = y or 0
  self.layer.x = self.layer.x + x
  self.layer.y = self.layer.y + y
  self.transitionId = transition.to(self.layer, { alpha = 1, time = 100, tag = 'Toast'} )
  timer.performWithDelay(self.duration + 100, function() self:hide() end)
end

function Toast:hide()
  self = self:getInstance()
  if self.transitionId then
    transition.cancel(self.transitionId)
  end
  self.transitionId = transition.to(self.layer, { alpha = 0, time = 100, tag = 'Toast'})
end

return Toast