local composer = require( "composer" )
local widget = require( "widget" ) 
-- Set a default theme
widget.setTheme( "widget_theme_ios7" )
local mui = require( "materialui.mui" )

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
local utility = require 'libs.utility'
local Stateful = require 'libs.stateful'
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
local fontZcoolHuangYou = 'assets/fonts/站酷庆科黄油体.ttf'

-- Functions
local function createIcon(options)
  local fontPath = "icon-font/"
  local materialFont = fontPath .. "MaterialIcons-Regular.ttf"
  options.font = materialFont
  options.text = mui.getMaterialFontCodePointByName(options.text)
  local icon = display.newText(options)
  return icon
end

-- ---
-- CLASSES Declaration
--
local View = require "libs.view"
local Button = class('Button', View)
local APP = require("classes.application")
Button:include(Stateful)
-- ---
-- Button View Class
--
function Button:initialize(opts)
  assert(type(opts) == 'table' and next(opts) ~= nil, "a named option hash table need to create a button")
  self.name = opts.name or '_Button'..os.time() -- timestamped
  View.initialize(self)
  assert(self.layer, 'Button View Initialized Failed!')
  d('创建按钮对象: '..self.name) -- Key =>（按）键; Button => 按钮 
  -- -------------------
  -- DATA BINDING
  self.config = opts
  self.labelText = opts.text or 'Button'
  -- Set UI constructor data by Custom Configuration or Default
  self.fillColor = opts.fillColor or colorsRGB.RGBA('black')
  self.strokeColor = opts.strokeColor or colorsRGB.RGBA('royalblue')
  self.strokeWidth = opts.strokeWidth or 0
  
  self.labelColor = opts.labelColor or colorsRGB.RGBA('white', 0.9)
  --self.font = opts.font or native.systemFontBold
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  -- Configure UI  
  self:ui()
  -- END VISUAL INITIALIING
  -- -------------------
end

-- overridable visual constructor
function Button:ui()
  local btnG = self.layer
  local iconDownArrow = createIcon {
    name = 'btn_arrow_down',
    x = 0, y = 0,
    text = 'expand_more',
    fontSize = 20,
  }
  local iconBg = display.newCircle(0, 0, 16)
  iconBg:setFillColor(colorHex('1A1A19'))
  self:_attach(iconBg)
  self:_attach(iconDownArrow)
  btnG.anchorChildren = true
  btnG.anchorX = .5
  btnG.anchorY = .5
  btnG.x = 30
  btnG.y = topInset + 45
  self.touchDelegate = iconBg
  self:send('start')
  self:gotoState('Active')
end

function Button:start()
  if not self.touchDelegate then return false end
  self.touchDelegate:addEventListener('tap', self)
end

function Button:stop()
  if not self.touchDelegate then return false end
  self.touchDelegate:removeEventListener('tap', self)
end

local activeButton = Button:addState('Active')
  
function activeButton:tap(event)
  local phase = event.phase
  composer.hideOverlay('slideDown')
end

return Button

--https://github.com/luapower/ui/blob/master/ui_button.lua