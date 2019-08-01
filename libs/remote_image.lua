-- Constants List:
local oX = display.screenOriginX
local oY = display.screenOriginY
local vW = display.viewableContentWidth
local vH = display.viewableContentHeight

local class = require 'libs.middleclass'
local Stateful = require 'libs.stateful'
local inspect = require 'libs.inspect'

local util = require 'util'
local d = util.print_r

-- local forward references should go here --
local screenW, screenH, halfW, halfH = display.contentWidth, display.contentHeight, display.contentWidth*0.5, display.contentHeight*0.5
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

local View = require "libs.view"
local RemoteImage = class('RemoteImageView', View)

RemoteImage.static.STATUS.UNLOAD = 100
RemoteImage.static.DEFAULT = {
    METHOD = 'GET',
    DIRECTORY = system.CachesDirectory
  }

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

RemoteImage.static.networkListener = networkListener

-- 利用获取的信息实例化一个动态资源对象
function RemoteImage:initialize(url, method, listener, ...)
  d('-*-*-*-*-*-*-*-*-*-*-*-*-*-*')
  d('- Prototype of RemoteImage Image View -')
  d('- ======================== -')
  View.initialize(self)
  self.layer.anchorChildren = true
  self.layer.anchorX = .5
  self.layer.anchorY = .5
  self.isBlocked = true
  
  local arg = { ... }
  d(arg)

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
  else
    d('No x and y specified!!!')
    d(arg[nextArg])
  end

  if ( destFilename ) then
    self.x = x
    self.y = y
    self.filename = destFilename
    self.baseDir = baseDir
    self.listener = listener

    if ( params ) then
      self.requestId = network.download( url, method, self, params, destFilename, baseDir )
    else
      self.requestId = network.download( url, method, self, destFilename, baseDir )
    end
  else
    print( "ERROR: no destination filename supplied to display.loadRemoteImage()" )
  end
end

function RemoteImage:networkRequest(event)
  local listener = self.listener
  local target
  if ( not event.isError and event.phase == "ended" ) then
    target = display.newImage( self.filename, self.baseDir, 0, 0 )
    self:_attach(target, 'image')
    self.layer.x = self.x
    self.layer.y = self.y
    d('image loaded on: '..self.layer.x)
    event.target = target
    self.isBlocked = false
    self:setState(self.class.STATUS.PRELOADED)
  end
  listener( event )
  --self:send('listener', event)
end

function RemoteImage:isAlready(state)
  return (self.state >= state)
end

function RemoteImage:isNotYet(state)
  return not (self:isAlready(state))
end

function RemoteImage:cleanup()
  if self.state < View.STATUS.PRELOADED then
    if self.requestId then
      network.cancel(self.requestId)
      d("Remote Image Loading Cancelled")
    end
    self:setState('UNLOAD')
    --return false
  end
  --self:setState('DESTROYED')
  d(self.name..' '..self:getState())
  View.cleanup(self)
end

return RemoteImage