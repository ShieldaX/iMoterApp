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
local Footer = class('FooterView', View)

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
function Footer:initialize(opts, parent)
  d('-*-*-*-*-*-*-*-*-*-*-*-*-*-*')
  d('- Prototype of Footer View -')
  d('- ======================== -')
  assert(type(opts) == 'table' and next(opts) ~= nil, "a named option hash table need to create a footer")
  View.initialize(self, parent)
  assert(self.layer, 'Piece View Initialized Failed!')
  self.name = opts.name or '_FOOT' -- timestamp
  d('创建底部对象: '..self.name)
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
    --native.showAlert( "Panel", "Complete", { "Okay" } )
    if ( target.completeState ) then
      print( "PANEL STATE IS: "..target.completeState )
    end
  end

  -- Function to handle button events
  local function handleTabBarEvent( event )
    print( event.target.id )  -- Reference to button's 'id' parameter
  end
-- Configure the tab buttons to appear within the bar
  local tabOptions = {
    {
      labelFont = fontSHSans,
      labelFontSize = 24,
      labelColor = { default={colorHex('6C6C6C')}, over={colorHex('C7A680')} },
      onPress = handleTabBarEvent
    },
    {
      id = "tab_xplr",
      label = {text = "Explore", font = fontMorganiteSemiBold, fontSize = 32, xOffset = 5},
      icon = {name = 'pages', fontSize = 36},
      xOffset = -vW*0.32, yOffset = 4,
      selected = true
    },
    {
      id = "tab_search",
      icon = {name = 'search', fontSize = 36},
      xOffset = vW*0.06, yOffset = 4
    },
    {
      id = "tab_mine",
      icon = {
        name = { default = 'person_outline', over = 'person'},
        fontSize = 36
      },
      xOffset = vW*0.3, yOffset = 4,
    }
  }

  local panel = widget.newPanel{
    location = "bottom",
    onComplete = panelTransDone,
    width = self.barWidth,
    height = self.barHeight + bottomInset,
    speed = 360,
    inEasing = easing.outCubic,
    outEasing = easing.inCirc
  }
  local backgroundRect = display.newRoundedRect( 0, 0, panel.width, panel.height, panel.height*.4 )
  backgroundRect:setFillColor(colorHex('1A1A19'))
  local _patchRect = display.newRect(0, backgroundRect.y + backgroundRect.height*.25, panel.width, backgroundRect.height*.5)
  _patchRect:setFillColor(colorHex('1A1A19'))
  local background = display.newGroup()
  background:insert(_patchRect)
  background:insert(backgroundRect)
  panel.background = background
  panel:insert( panel.background )
  self:_attach(panel, 'TabBar')
  self:buildTabs(tabOptions)
  self.hidden = true
  self:show()
  -- END VISUAL INITIALIING
  -- -------------------
end

function Footer:buildTabs(options)
  local commonOpts = _.first(options)
  local tabButtons = _.rest(options)
  self.tabs = {}
  _.each(tabButtons,
    function(tabOption)
      _.extend(tabOption, commonOpts)
      self:createTab(tabOption)
    end
  )
end

function Footer:createTab(options)
  local tab = display.newGroup()
  tab.anchorChildren = true
  local selected = options.selected
  local defaultColor = options.labelColor.default or {colorHex('6C6C6C')}
  local overColor = options.labelColor.over or {colorHex('C7A680')}
  local fillColor = selected and overColor or defaultColor

  tab.defaultColor = defaultColor
  tab.overColor = overColor
  tab.yOffset = options.yOffset - bottomInset*.5
  local icon
  if options.icon and type(options.icon) == 'table' then
    local _icon = options.icon
    local iconName = type(_icon.name) == 'table' and _icon.name.default or _icon.name
    icon = createIcon {
      x = 0, y = 0,
      text = iconName,
      fontSize = _icon.fontSize or 32
    }
    icon:setFillColor(unpack(fillColor))
    tab:insert(icon)
    tab.x = _icon.xOffset or options.xOffset
    tab.y = _icon.yOffset or options.yOffset
    tab.y = tab.y - bottomInset*.5

    if type(_icon.name) == 'table' then
      local overIcon = createIcon{
        x = 0, y = 0,
        text = _icon.name.over,
        fontSize = _icon.fontSize or 32
      }
      overIcon:setFillColor(unpack(fillColor))
      tab:insert(overIcon)
      tab.overIcon = overIcon
      tab.hasOverIcon = true
      overIcon.alpha = 0
    end
  end
  local label
  if options.label and type(options.label) == 'table' then
    local _label = options.label
    if icon then _label.xOffset = icon.x + icon.contentWidth + (_label.xOffset or 10) end
    label = display.newText(
      tab,
      _label.text,
      _label.xOffset or options.xOffset, _label.yOffset or 0,
      _label.font or options.labelFont, _label.fontSize or options.labelFontSize
    )
    label:setFillColor(unpack(fillColor))
  end

  if icon and label then
    tab.x = tab.x + icon.contentWidth*.5 
  end

--  local bounds = tab.contentBounds
--  local touchDelegate = display.newRect(tab, bounds.xMin, bounds.yMin, tab.contentWidth, tab.contentHeight)
--  touchDelegate:toBack()

  local id = options.id
  self.tabs[id] = tab
  tab.id = id
  self.elements.TabBar:insert(tab)
  if selected then
    --self.tabSeleted = id
    self:selectTab(id)
  end
  tab:addEventListener('touch', self)
  tab:addEventListener('tap', self)
end

function Footer:touch(event)
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

function Footer:tap(event)
--  stop any tap/touch propgation
  return true
end

local function animateTab(tab, isSelect)
  local fillColor = isSelect and tab.overColor or tab.defaultColor
  local scaleFactor = isSelect and 1.1 or 1
  local offSet = isSelect and  - bottomInset*.5 or tab.yOffset
  for i=1, tab.numChildren, 1 do
    tab[i]:setFillColor(unpack(fillColor))
  end
  if tab.overIcon then
    transition.to(tab.overIcon, {time = 200, transition = easing.outBack, alpha = isSelect and 1 or 0})
  end
  transition.to(tab, {time = 460, transition = easing.outBack, xScale = scaleFactor, yScale = scaleFactor, y = offSet})
end

function Footer:selectTab(tab_id)
  local tabs = self.tabs
  for id, tab in pairs(tabs) do
    local isSelect = false
    if id == tab_id then
      isSelect = true
      animateTab(tab, isSelect)
    elseif self.tabSelected == id then
      animateTab(tab, isSelect)
    end
  end
  self.tabSelected = tab_id
end

function Footer:show()
  if not self.hidden then return end
  self.hidden = false
  self.elements.TabBar:show()
end

function Footer:hide()
  if self.hidden then return end
  self.hidden = true
  self.elements.TabBar:hide()
end

function Footer:toggle()
  if self.hidden then
    self:show()
  else
    self:hide()
  end
end

function Footer:setSelected(tab_id)
  if self.selection == tab_id then return end
  local tabBtn = self.elements[tab_id]
  --tabBtn:active()
end

return Footer