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

local panel = widget.newPanel{
  location = "bottom",
  onComplete = panelTransDone,
  width = display.contentWidth,
  height = 62,
  speed = 250,
  inEasing = easing.outBack,
  outEasing = easing.outCubic
}
panel.background = display.newRoundedRect( 0, 0, panel.width, 62, 20 )
panel.background:setFillColor(colorHex('1A1A19'))
panel:insert( panel.background )

panel.title = display.newText( "menu", 0, 0, native.systemFontBold, 18 )
panel.title:setFillColor( 1, 1, 1 )
panel:insert( panel.title )
timer.performWithDelay(800, function() panel:show() end)