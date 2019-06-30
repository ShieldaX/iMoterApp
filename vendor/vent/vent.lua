local vent = {}
local log = require 'vendor.log.log'

function vent:on(event, listener)
	assert(type(self) == 'table', 'Method was called as .on instead of :on')
	assert(type(event) == 'string', 'Expected event to be a string')
	self._events = self._events or {}

	if not listener then
		return
	end

	if type(listener) == 'function' then
		listener = {callback = listener}
	end
	assert(listener.callback and type(listener.callback) == 'function', 'Expected a function as event listener')

	if self.class then
		event = self.class.name .. '.' .. event
	end

	self._events[event] = self._events[event] or {}
	table.insert(self._events[event], listener)
end

function vent:off(event, listener)
	assert(type(self) == 'table', 'Method was called as .off instead of :off')
	assert(type(event) == 'string', 'Expected event to be a string')

	if self.class then
		event = self.class.name .. '.' .. event
	end

	if listener then
		for i, currentListener in ipairs(self._events[event] or {}) do
			if currentListener.callback == listener then
				table.remove(self._events[event], i)
			end
		end
	else
		self._events[event] = nil
	end
end

function vent:allOff(event)
	self:off(event)
end

function vent:trigger(event, data)
	assert(event, 'The event needs a name to trigger')
	data = data or {}

	if type(data) ~= 'table' then
		data = {value = data}
	end
	data.name = event

	local removals = {}

	for i, eventTable in ipairs(self:getListeners(event)) do
		if eventTable.once then
			removals[#removals + 1] = i
		end
		timer.performWithDelay(2 ^ -40, function()
			if type(eventTable.callback) ~= 'function' then
				log(eventTable)
			end
			-- Special casing for when vent is included as mixin
			if not self.class then
				eventTable.callback(data)
			else
				eventTable.callback(self, data)
			end
		end)
	end

	if self.class then
		event = self.class.name .. '.' .. event
	end

	for i = 1, #removals do
		table.remove(self._events[event], removals[i])
	end
end

function vent:allEventNames()
	local keys = {}
	for key, _ in pairs(self._events) do
		keys[#keys + 1] = key
	end
	return keys
end

function vent:once(name, listener)
	self:on(name, {
		callback = listener,
		once = true
	})
end

function vent:getListeners(event)
	if self.class then
		event = self.class.name .. '.' .. event
	end
	return (self._events and self._events[event]) or {}
end

return vent
