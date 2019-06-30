-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
require("mobdebug").start()

-- show default status bar (iOS)
display.setStatusBar(display.HiddenStatusBar)
display.setDefault("background", 0)
--
-- utility - various handy add on functions
--
local utility = require("libs.utility")
--
-- myData -- an emtpy table that can be required in multiple modules/scenes
--           to allow easy passing of data between modules
local myData = require("classes.mydata")

-- turn on/off mui debug output
_mui_debug = true


-- include the Corona "composer" module
local composer = require "composer"

-- load app screen
composer.gotoScene("scenes.app")