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
local StarRating = class('StarRating', View)
--local Toast = require 'views.toast'
local APP = require("classes.application")
StarRating:include(Stateful)

-- Enum of Indicator Types
StarRating.static.TYPE = {
    DEFAULT = 10,
    STATIC = 10, -- DEFAULT
    ACTIVE = 20
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
-- StarRating View Class
--
function StarRating:initialize(score, opts, parent)
  if not score then return false end
  assert(type(opts) == 'table' and next(opts) ~= nil, "a named option hash table need to create a button")
  self.name = opts.name or '_StarRating'..os.time() -- timestamped
  View.initialize(self, parent)
  assert(self.layer, 'StarRating View Initialized Failed!')
  d('创建评分对象: '..self.name) -- Key =>（按）键; StarRating => 按钮 
  -- -------------------
  -- DATA BINDING
  local config = opts
  self.config = config
  self.labelText = opts.text or 'StarRating'
  -- Set UI constructor data by Custom Configuration or Default
  self.iconSize = config.iconSize or 20
  self.fillColor = config.fillColor or colorsRGB.RGBA('gold')
  self.strokeColor = config.strokeColor or colorsRGB.RGBA('gray')
  self.textColor = config.textColor or colorsRGB.RGBA('royalblue')
  self.font = config.font or native.systemFontBold
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  -- Configure UI  
  local score2Local = score*.5
  d('Local score: '..score2Local)
  for i=1, 5, 1 do
    if score2Local > i then
      --d('create star')
      self:_attach(util.createIcon{text = 'star', width = self.iconSize, height = self.iconSize, x = 0, y = 0, textColor = self.fillColor})
    elseif score2Local < i and math.ceil(score2Local) == i then
      --d('create star_half')
      self:_attach(util.createIcon{text = 'star_half', width = self.iconSize, height = self.iconSize, x = 0, y = 0, textColor = self.fillColor})
    else
      --d('create star_border')
      self:_attach(util.createIcon{text = 'star_border', width = self.iconSize, height = self.iconSize, x = 0, y = 0, textColor = self.strokeColor})
    end
  end
  --self.layer.anchorChildren = true
  --self.layer.anchorY = 0.5
  self.layer.alpha = 0
  -- END VISUAL INITIALIING
  -- -------------------
end

function StarRating:animate(direction)
  --direction = direction or 1
  self.layer.alpha = self.layer.alpha == 1 and 1 or 1
  local elements = self._elements
  local timeInterval = 200
  local padding = elements[1].width*.6
  for i, element in ipairs(elements) do
    element.x = (i-1)*padding
    transition.from(element, {x = 0, y = -20*i, xScale = 4, yScale = 4, alpha = 0, time = 400, delay = (i-1)*timeInterval, transition = easing.outBack})
  end
end

function StarRating:onProgress(event)
  local i = event.index
  self.elements.bar:setProgress(i/self.total)
end

return StarRating