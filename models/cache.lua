local ModeloEspecial = require 'vendor.modeloespecial.modeloespecial'
local Model = ModeloEspecial.Model

local log = require 'vendor.log.log'

local caches = modeloespecial:new {
  name = "cachedb",
  location = "memory",
  --debug = true
}

local Cache = Model:extend {table = "caches"}

function Cache:find()
  -- body
end

function Cache.exists(URL)
end

return Cache