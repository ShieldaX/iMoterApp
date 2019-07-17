-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- show default status bar (iOS)
display.setStatusBar(display.HiddenStatusBar)
display.setDefault("background", 1)
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
local FooterView = require("views.footer")

-- include the Corona "composer" module
local composer = require "composer"
-- load app screen
composer.gotoScene("scenes.album")
--composer.gotoScene("scenes.album_list")
--APP.Footer:toFront()

-- Create a vector rectangle sized exactly to the "safe area"
local safeArea = display.newRect(
    display.safeScreenOriginX,
    display.safeScreenOriginY,
    display.safeActualContentWidth,
    display.safeActualContentHeight
)
safeArea.alpha = 0
safeArea:translate( safeArea.width*0.5, safeArea.height*0.5 )