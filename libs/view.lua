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
    CREATED = 1,
    INITIALIZED = 10,
    PRELOADED = 20,
    STARTED = 30,
    STOPPED = 90
}

function View:initialize(parentGroup)
  self:setState('CREATED')
  self.blocking = false
  self.layer = display.newGroup()
  -- _elements table contains embedded live objects in a numerical order
  -- elements table contains embedded live objects has `name` keys in a hash
  if type(self._elements) ~= 'table' then self._elements = {} end
  if type(self.elements) ~= 'table' then self.elements = {} end
  if parentGroup and parentGroup.insert and type(parentGroup.insert) == 'function' then
    parentGroup:insert(self.layer)
  end
  Runtime:addEventListener('receive', self)
  self:setState('INITIALIZED')
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
  self:setState('CREATED')
end

function View:send(name, ...)
  assert(type(name)=='string', "the function name must be a string.")
  if self[name] and type(self[name]) == 'function' then
    return self[name](self, ...)
  end
end

function View:childSend(name, ...)
  assert(type(name)=='string', "the function name must be a string.")
  for i,v in ipairs(self._elements) do
    if v[name] and type(v[name]) == 'function' then
      return self[name](v, ...)
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

function View:receive()
  self:send(event.callback, event)
end

function View:_attach(obj, name, force)
  if not name and obj.name and type(obj.name) == 'string' then name = obj.name end

  if name then
    assert(force or not self.elements[name], name .. " already attached as an element")
    self.elements[name] = obj
  end

  -- add object to the numeric ordered array
  table.insert(self._elements, obj)

  -- add parent field for self for callback
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
--local createdView = View:addState('CREATED')