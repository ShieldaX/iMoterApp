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
--local Stateful = require 'libs.stateful'
--local inspect = require 'libs.inspect'

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
  -- Configure topbar
  -- Function to handle button events
  local function handleTabBarEvent( event )
    print( event.target.id )  -- Reference to button's 'id' parameter
  end
  -- Configure the tab buttons to appear within the bar
  local tabButtons = {
    {
      label = "Tab1",
      id = "tab1",
      selected = true,
      onPress = handleTabBarEvent
    },
    {
      label = "Tab2",
      id = "tab2",
      onPress = handleTabBarEvent
    },
    {
      label = "Tab3",
      id = "tab3",
      onPress = handleTabBarEvent
    }
  }
  -- Create the widget
  local tabBar = widget.newTabBar(
    {
      top = vH - 62, left = 10,
      width = vW - 20,
      buttons = tabButtons
    }
  )
  self:_attach(tabBar, 'tabBar')
  -- END VISUAL INITIALIING
  -- -------------------
end

return Footer