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
--util.show_fps()

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
  -- Function to handle button events

--[[
  local function handleTabBarEvent( event )
    print( event.target.id )  -- Reference to button's 'id' parameter
  end
  -- Configure the tab buttons to appear within the bar
  local tabButtons = {
    {
      label = "Explore",
      id = "tab_xplr",
      selected = true,
      labelYOffset = -8,
      labelColor = { default={ 0, 0, 0, 0.4 }, over={colorHex('C7A680')} },
      onPress = handleTabBarEvent
    },
    {
      label = "Search",
      id = "tab_search",
      labelYOffset = -8,
      labelColor = { default={ 0, 0, 0, 0.4 }, over={colorHex('C7A680')} }, 
      onPress = handleTabBarEvent
    },
    {
      label = "User",
      id = "tab_mine",
      labelYOffset = -8,
      labelColor = { default={ 0, 0, 0, 0.4 }, over={colorHex('C7A680')} },
      onPress = handleTabBarEvent
    }
  }
  -- Create the widget
  local tabBar = widget.newTabBar(
    {
      top = vH - 62, left = oX,
      width = vW, height = 62,
      backgroundColor = colorHex('1A1A19'),
      buttons = tabButtons
    }
  )
  self:_attach(tabBar, 'tabBar')
  ]]
  --self:_attach(panel, 'tabBar')

  local function panelTransDone( target )
    --native.showAlert( "Panel", "Complete", { "Okay" } )
    if ( target.completeState ) then
      print( "PANEL STATE IS: "..target.completeState )
    end
  end

-- Configure the tab buttons to appear within the bar
  local tabButtons = {
    {
      label = "Explore",
      id = "tab_xplr",
      selected = true,
      labelYOffset = -8,
      labelColor = { default={ 0, 0, 0, 0.4 }, over={colorHex('C7A680')} },
      onPress = handleTabBarEvent
    },
    {
      label = "Search",
      id = "tab_search",
      labelYOffset = -8,
      labelColor = { default={ 0, 0, 0, 0.4 }, over={colorHex('C7A680')} }, 
      onPress = handleTabBarEvent
    },
    {
      label = "User",
      id = "tab_mine",
      labelYOffset = -8,
      labelColor = { default={ 0, 0, 0, 0.4 }, over={colorHex('C7A680')} },
      onPress = handleTabBarEvent
    }
  }

  local panel = widget.newPanel{
    location = "bottom",
    onComplete = panelTransDone,
    width = display.contentWidth,
    height = 80,
    speed = 420,
    inEasing = easing.outCubic,
    outEasing = easing.inOutBack
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
  self:_attach(panel, 'TabBar')
  self:show()
  --timer.performWithDelay(200, function() self:show() end)
  -- END VISUAL INITIALIING
  -- -------------------
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

return Footer