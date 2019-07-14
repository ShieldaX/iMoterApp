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

local Adapter = class "Adapter"
--Adapter:include(Stateful)

-- status code
Adapter.static.STATUS = {
    INITIALIZED = 10, -- [BORN]
    PRELOADED = 20, -- Adapter Couldn't START Before(<) this [READY]
    STARTED = 30, -- Adapter Shouldn't STOP Before(<) this [WAKE]
    STOPPED = 90, -- Stop All Interaction Listeners [SLEEP]
    DESTROYED = 1000 -- Free to Switch to this @ Anytime [ENDED]
}

function Adapter:initialize(parent)
  -- _elements table contains embedded view objects in a numerical order
  -- elements table contains embedded view objects has `name` keys in a hash
  if type(self._data) ~= 'table' then self._rawData = {} end
  if type(self.data) ~= 'table' then self.data = {} end

  Runtime:addEventListener('receive', self)
  self:setState('INITIALIZED')
end

function Adapter:setState(status)
  if type(status) == 'number' then
    self.state = status
  elseif type(status) == 'string' then
    self.state = Adapter.STATUS[status]
    assert(self.state, "unknown state " .. status)
  else
    assert(true, "no status name or status number passed.")
  end
end

function Adapter:getState()
  local state_name = 'undefined state code ' .. self.state
  for name,value in pairs(Adapter.STATUS) do
    if self.state == value then
      state_name = name
    end
  end
  return state_name
end

function Adapter:cleanup()
  self._data = {}
  self.data = {}
  self:setState('INITIALIZED')
end

function Adapter:send(name, ...)
  assert(type(name)=='string', "the function name must be a string.")
  if self[name] and type(self[name]) == 'function' then
    return self[name](self, ...)
  end
end

function Adapter:signal(name, opts)
  opts = opts or {}
  assert(type(opts) == 'table', 'the option parameter must be a table')

  -- override the name and callback for the signal
  opts.name = 'receive'
  opts.callback = name

  Runtime:dispatchEvent(opts)
end

function Adapter:receive(event)
  self:send(event.callback, event)
end

return Adapter