local widget = require( "widget" )
local widgetExtras = require("libs.widget-extras")
local mui = require( "materialui.mui" )
local muiData = require( "materialui.mui-data" )
-- Set a default theme
widget.setTheme("widget_theme_ios7")

-- Constants List:
local oX = display.screenOriginX
local oY = display.screenOriginY
local vW = display.viewableContentWidth
local vH = display.viewableContentHeight
local visibleAspectRatio = vW/vH

local class = require 'libs.middleclass'
--local Stateful = require 'libs.stateful'
--local inspect = require 'libs.inspect'
local colorHex = require('libs.convertcolor').hex
local util = require 'util'
local d = util.print_r
--local _ = require 'libs.underscore'

-- local forward references should go here --
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
  --
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
  local tabButtons = {
    {
      labelFont = fontSHSans,
      labelFontSize = 24,
      labelColor = { default={colorHex('6C6C6C')}, over={colorHex('C7A680')} },
      onPress = handleTabBarEvent
    },
    {
      id = "tab_xplr",
      label = {text = "Explore", font = fontMorganiteSemiBold, fontSize = 32, xOffset = 30},
      icon = {name = 'pages', fontSize = 36},
      xOffset = vW*0.32, yOffset = 0,
      selected = true
    },
    {
      id = "tab_search",
      icon = {name = 'search', fontSize = 36},
      xOffset = 32, yOffset = 6
    },
    {
      id = "tab_mine",
      icon = {
        name = { default = 'person_outline', over = 'person'},
        fontSize = 36
      },
      xOffset = vW*0.32, yOffset = 5,
    }
  }

  local panel = widget.newPanel{
    location = "bottom",
    onComplete = panelTransDone,
    width = display.contentWidth,
    height = 80,
    speed = 420,
    inEasing = easing.outCubic,
    outEasing = easing.inCirc
  }
  local backgroundRect = display.newRoundedRect( 0, 0, panel.width, 80, 36 )
  backgroundRect:setFillColor(colorHex('1A1A19'))
  local beyondRect = display.newRect(0, 20, panel.width, 40)
  beyondRect:setFillColor(colorHex('1A1A19'))
  local background = display.newGroup()
  background:insert(beyondRect)
  background:insert(backgroundRect)
  panel.background = background
  panel:insert( panel.background )
  --[[
  local xplrIcon = createIcon {
    x = -vW*0.32, y = 0,
    text = 'pages',
    fontSize = 36
  }
  xplrIcon:setFillColor(colorHex('C7A680'))
  local labelExplr = display.newText( "Explore", xplrIcon.x + 50, 0, fontMorganiteSemiBold, 32 )
  labelExplr:setFillColor(colorHex('C7A680'))
  panel.labelExplr = labelExplr
  panel:insert(xplrIcon)
  panel:insert( panel.labelExplr )
  --
  local iconSearch = createIcon {
    x = 32, y = 6,
    text = 'search',
    fontSize = 36
  }
  iconSearch:setFillColor(colorHex('6C6C6C'))
  panel.tabSearch = iconSearch
  panel:insert(iconSearch)

  local iconUser = createIcon {
    x = vW*0.32, y = 5,
    text = 'person_outline',
    fontSize = 36
  }
  iconUser:setFillColor(colorHex('6C6C6C'))
  panel.tabMine = iconUser
  panel:insert(iconUser)
  ]]
  self:_attach(panel, 'TabBar')
  self:createTab(tabButtons[3])
  self:show()
  --timer.performWithDelay(200, function() self:show() end)
  -- END VISUAL INITIALIING
  -- -------------------
end

function Footer:createTab(options)
  local tab = display.newGroup()
  --tab.anchorChildren = true
  local selected = options.selected
  local defaultColor = options.defaultColor or {colorHex('6C6C6C')}
  local overColor = options.overColor or {colorHex('C7A680')}
  local fillColor = selected and overColor or defaultColor
  
  local icon
  if options.icon and type(options.icon) == 'table' then
    local opts = options.icon
    d(opts)
    local iconName = type(opts.name) == 'table' and opts.name.default or opts.name
    icon = createIcon {
      x = opts.xOffset or options.xOffset, y = opts.yOffset or options.yOffset,
      text = iconName,
      fontSize = opts.fontSize or 32
    }
    icon:setFillColor(unpack(fillColor))
    tab:insert(icon)
    d(icon.x .. ':' ..icon.y)
  end

  if options.label and type(options.label) == 'table' then
    local opts = options.label
    d(opts)
    if icon then opts.xOffset = icon.x + icon.contentWidth + opts.xOffset end
    local label = display.newText(tab, opts.text, opts.xOffset, opts.yOffset or 0, opts.font or fontMorganiteSemiBold, opts.fontSize or 32 )
    label:setFillColor(unpack(fillColor))
    tab:insert(label)
  end

  local bar = self.elements.TabBar
  bar:insert(tab)
end

function Footer:show()
  self.hidden = false
  self.elements.TabBar:show()
end

function Footer:hide()
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