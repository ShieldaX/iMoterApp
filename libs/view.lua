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

local View = class "View"
--View:include(Stateful)

-- status code
View.static.STATUS = {
    INITIALIZED = 10, -- [BORN]
    PRELOADED = 20, -- View Couldn't START Before(<) this [READY]
    STARTED = 30, -- View Shouldn't STOP Before(<) this [WAKE]
    STOPPED = 90, -- Stop All Interaction Listeners [SLEEP]
    DESTROYED = 1000 -- Free to Switch to this @ Anytime [ENDED]
}

function View:initialize(parent)
--  self.isBlocked = true
  self.isBlocked = false
  self.layer = display.newGroup()
  -- _elements table contains embedded view objects in a numerical order
  -- elements table contains embedded view objects has `name` keys in a hash
  if type(self._elements) ~= 'table' then self._elements = {} end
  if type(self.elements) ~= 'table' then self.elements = {} end

  Runtime:addEventListener('receive', self)
  self:setState('INITIALIZED')
  
  if parent then
    if parent.isInstanceOf and type(parent.isInstanceOf) == 'function' and parent:isInstanceOf(View) and parent.state >= 10 then
      parent:addView(self)
    elseif parent.insert and type(parent.insert) == 'function' then
      parent:insert(self.layer)
    end
  end
end

function View:setState(status)
  if type(status) == 'number' then
    self.state = status
  elseif type(status) == 'string' then
    self.state = View.STATUS[status]
    assert(self.state, "unknown state " .. status)
  else
    assert(true, "no status name or status number passed.")
  end
end

function View:getState()
  local state_name = 'undefined state code ' .. self.state
  for name,value in pairs(View.STATUS) do
    if self.state == value then
      state_name = name
    end
  end
  return state_name
end

function View:cleanup()
  self:childSend('cleanup')
  if self.layer and self.layer.removeSelf and type(self.layer.removeSelf) == 'function' then
    self.layer:removeSelf()
    self.layer = nil
  end
  self._elements = {}
  self.elements = {}
  self:setState('INITIALIZED')
  Runtime:removeEventListener('receive', self)
end

function View:destroy()
  self:cleanup()
  self:setState('DESTROYED')
end

function View:send(name, ...)
  assert(type(name)=='string', "the function name must be a string.")
  if self[name] and type(self[name]) == 'function' then
    return self[name](self, ...)
  end
end

function View:childSend(name, ...)
  assert(type(name)=='string', "the function name must be a string.")
  for i, v in ipairs(self._elements) do
    if v[name] and type(v[name]) == 'function' then
--      return self[name](v, ...)
      return v[name](v, ...)
    end
  end
end

function View:signal(name, opts)
  opts = opts or {}
  assert(type(opts) == 'table', 'the option parameter must be a table')

  -- override the name and callback for the signal
  opts.name = 'receive'
  opts.callback = name

  Runtime:dispatchEvent(opts)
end

function View:receive(event)
  self:send(event.callback, event)
end

function View:_attach(obj, name, force)
  if obj == nil then
    d('View wouldnt attach anything unexists!')
    return false
  end
  if self.state < View.STATUS.INITIALIZED then
    d('View not initialized couldnt attach anything!')
    return false
  end
  if not name and obj.name and type(obj.name) == 'string' then name = obj.name end

  if name then
    assert(force or not self.elements[name], name .. " already attached as an element")
    self.elements[name] = obj
  end

  -- add object to the numeric ordered array
  table.insert(self._elements, obj)

  -- add parent field to self for callback
  obj.parent = self

  if obj.isInstanceOf and obj:isInstanceOf(View) then
    self.layer:insert(obj.layer)
  else
    self.layer:insert(obj)
  end
end

function View:addView(view)
  assert(view:isInstanceOf(View) and view.state >= 10, "only an initialized view object can be add to via `addView`")
  self:_attach(view)
end

return View