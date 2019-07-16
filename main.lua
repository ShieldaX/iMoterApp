-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- show default status bar (iOS)
display.setStatusBar(display.HiddenStatusBar)
display.setDefault("background", 0)
--
-- utility - various handy add on functions
--
--local utility = require("libs.utility")
--
-- appData -- an emtpy table that can be required in multiple modules/scenes
--           to allow easy passing of data between modules
local APP = require("classes.application")
require "libs.colors-rgb"
-- turn on/off mui debug output
_mui_debug = true

local widget = require( "widget" )
local widgetExtras = require("libs.widget-extras")
-- Set a default theme
widget.setTheme("widget_theme_ios7")

local colorHex = require('libs.convertcolor').hex

-- include the Corona "composer" module
local composer = require "composer"
-- load app screen
composer.gotoScene("scenes.app")
--composer.gotoScene("scenes.album_list")

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
  inEasing = easing.outBack,
  outEasing = easing.outCubic
}
local backgroundRect = display.newRoundedRect( 0, 0, panel.width, 80, 36 )
backgroundRect:setFillColor(colorHex('1A1A19'))
local beyondRect = display.newRect(0, 40, panel.width, 40)
beyondRect:setFillColor(colorHex('1A1A19'))
panel.background = display.newGroup()
panel.background.anchorChildren = true
background:insert(beyondRect)
background:insert(backgroundRect)
panel:insert( panel.background )

panel.title = display.newText( "Explore", 0, 0, native.systemFontBold, 20 )
panel.title:setFillColor(colorHex('C7A680'))
panel:insert( panel.title )
timer.performWithDelay(800, function() panel:show() end)