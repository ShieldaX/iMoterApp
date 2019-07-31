local class = require 'libs.middleclass'
local Stateful = require 'libs.stateful'
local inspect = require 'libs.inspect'
local colorHex = require('libs.convertcolor').hex

local util = require 'util'
local d = util.print_r
-- --------------------------
local remoteImg = class('remoteImg');


--The 'display.loadRemoteImage()' API call is a convenience method around the 'network.request()' API.
--The code below is the implementation of 'display.loadRemoteImage()'. If you need to cancel your call,
--feel free to use the code below and modify it to your needs.
 
local function networkListener( event )
    if ( event.isError ) then
        print ( "Network error - download failed" )
    else
        event.target.alpha = 0
        transition.to( event.target, { alpha = 1.0 } )
    end
 
    print ( "event.response.fullPath: ", event.response.fullPath )
    print ( "event.response.filename: ", event.response.filename )
    print ( "event.response.baseDirectory: ", event.response.baseDirectory )
end
 
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
            network.download( url, method, options, params, destFilename, baseDir )
        else
            network.download( url, method, options, destFilename, baseDir )
        end
    else
        print( "ERROR: no destination filename supplied to display.loadRemoteImage()" )
    end
end
