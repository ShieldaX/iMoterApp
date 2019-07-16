local widget = require( "widget" )
local widgetExtras = require("libs.widget-extras")
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

-- ---
-- CLASSES Declaration
--
local View = require "libs.view"
local Footer = class('FooterView', View)

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
  -- END VISUAL INITIALIING
  -- -------------------
end

return Footer