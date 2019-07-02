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
--util.show_fps()

-- local forward references should go here --
local screenW, screenH, halfW, halfH = display.contentWidth, display.contentHeight, display.contentWidth*0.5, display.contentHeight*0.5
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

local View = require "libs.view"
local Resource = class('ResourceView', View)

-- 利用获取的信息实例化一个动态资源对象
function Resource:initialize(obj, sceneGroup)
  d('-*-*-*-*-*-*-*-*-*-*-*-*-*-*')
  d('- Prototype of Resource View -')
  d('- ======================== -')
  View.initialize(self, sceneGroup)
  self.STATUS.UNLOAD = 100
  self.STATUS.FINAL = 1000
  d(self.STATUS)
  d(self.class.STATUS)
end

function Resource:isAlready(state)
  return (self.state >= state)
end

function Resource:isNotYet(state)
  return not (self:isAlready(state))
end

function Resource:cleanup()
  if self.state < Resource.STATUS.PRELOADED then
    if self._requestId then
      network.cancel(self._requestId)
      d("Resource Loading Cancelled")
    end
    self:setState('UNLOAD')
    return false
  end
  --self:setState('DESTROYED')
  d(self.name..' '..self:getState())
  View.cleanup(self)
end

return Resource