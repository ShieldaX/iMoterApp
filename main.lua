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

local function remoteImageListener( self, event )
  local listener = self.listener

  local target
  if ( not event.isError and event.phase == "ended" ) then
    target = display.newImage( self.filename, self.baseDir, self.x, self.y )
    event.target = target
  end
  listener( event )
end

-- display.loadRemoteImage( url, method, listener [, params], destFilename [, baseDir] [, x, y] )
display.loadRemoteImage = function( url, method, listener, ... )
  local arg = { ... }

  local params, destFilename, baseDir, x, y
  local nextArg = 1

  if ( "table" == type( arg[nextArg] ) ) then
    params = arg[nextArg]
    nextArg = nextArg + 1
  end

  if ( "string" == type( arg[nextArg] ) ) then
    destFilename = arg[nextArg]
    nextArg = nextArg + 1
  end

  if ( "userdata" == type( arg[nextArg] ) ) then
    baseDir = arg[nextArg]
    nextArg = nextArg + 1
  else
    baseDir = system.DocumentsDirectory
  end

  if ( "number" == type( arg[nextArg] ) and "number" == type( arg[nextArg + 1] ) ) then
    x = arg[nextArg]
    y = arg[nextArg + 1]
  end

  if ( destFilename ) then
    local options = {
      x=x, 
      y=y,
      filename=destFilename, 
      baseDir=baseDir,
      networkRequest=remoteImageListener, 
      listener=listener 
    }    

    if ( params ) then
      return network.download( url, method, options, params, destFilename, baseDir )
    else
      return network.download( url, method, options, destFilename, baseDir )
    end
  else
    print( "ERROR: no destination filename supplied to display.loadRemoteImage()" )
  end
end

local FooterView = require("views.footer")

-- include the Corona "composer" module
local composer = require "composer"

-- load app screen
composer.gotoScene("scenes.home")

--[[ Create a vector rectangle sized exactly to the "safe area"
local safeArea = display.newRect(
    display.safeScreenOriginX,
    display.safeScreenOriginY,
    display.safeActualContentWidth,
    display.safeActualContentHeight
)
safeArea.alpha = 0
safeArea:translate( safeArea.width*0.5, safeArea.height*0.5 )
]]