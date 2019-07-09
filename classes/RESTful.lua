-- Rest.lua
-- @version 0.1.2
-- ================

-- Require External Library
local class = require 'libs.middleclass'
local inspect = require 'libs.inspect'
local multipart = require "classes.MultipartFormData"
local mimetypes = require "classes.mimetypes"
local json = require "json"
local socket_url = require "socket.url"
local util = require "util"
local d = util.print_r

-- Class
local RESTful = class 'RESTful'

local DEBUG = false
RESTful.PREVIEW_MOD = DEBUG

-- supported http methods
RESTful.methods = {
  GET = "GET",
  HEAD = "HEAD",
  PUT = "PUT",
  POST = "POST",
  DELETE = "DELETE",
}

-- Function

local url_escape = socket_url.escape

-- @param r Response table
function RESTful.defaultRestHandler(r)
  print("--------------- "..r.name)
  if r.error then
    print("ERROR")
    print("URL: "..r.url)
  else
    d(r.data)
  end
end

-- Create customized handler
-- @param t [table] List of function beings to handle various situation.
-- @return [function] Handler to handle RESTful response
function RESTful.createRestHandler(t)
  return function(r)
    if r.error then
      if t and t.error then
        t.error(r)
      else
        print("--------------- "..r.name)
        print("ERROR")
      end
    else
      if r.phase == "ended" then
        if t and type(t.success) == 'function' then
          t.success(r)
        else
          print("--------------- "..r.name)
          d(r.data)
        end
      else
        if t and type(t.progress) == 'function' then
          t.progress(r)
        end
      end
    end
  end
end

-- Constructor
-- @param obj Target API Object.
-- @param name [string] Name of the API, reference to api description
function RESTful:initialize(obj, name)

  -- Save the api description
  if name:find(".json") then
    local inp = assert(io.open(name, "rb"))
    local data = inp:read("*all")
    self.api = json.decode(data)
    print("Loaded api description from JSON file.\n")
  else
    name = string.lower(name)
    self.api = require('classes.api_'..name)
    print("Loaded api description from Lua Table directly.\n")
  end
  
  if not (self.api) then self.api = require('classes.api_'..name) end

  -- For each method
  if self.api.methods then
    for name, t in pairs(self.api.methods) do

      -- Create a function for the object, obj:method(...)
      obj[name] = function(self, ...)
        self:callMethod(name, t, ...) -- function must be implemented correctly
      end
    end
  end

end

-- Parse api description and execute request.
-- @param name [string] API name
-- @oaram t [table] Detail of this api (description)
-- @param headers [table] Request headers
-- @param extraArgList [table] Hash of extra arguments
-- @param preCallbackHook [function] API level callback function
function RESTful:call(name, t, headers, extraArgList, preCallbackHook, ...)
  local arg = {n=select('#', ...), ...}
  
  local newpath = t.path
  local args = ""

  local index = 1
  local argList = {}
  --local bodyList = {}
  local fileList = {} -- table to collect file argument
  local progress = nil -- listen to the progress event, nil or "upload" or "download"
  local callback = nil
  local body = nil
  
  -- copy headers
  local newheaders = {}
  for k,v in pairs(headers) do
    newheaders[k] = headers[k]
  end
  headers = newheaders

  -- Copy in any extra args
  if extraArgList then --if type(extraArgList) == 'table' then
    for k,v in pairs(extraArgList) do
      argList[k] = v
    end
  end

  -- For each required argument
  if t.required_params then
    for _,a in ipairs(t.required_params) do
      local value = arg[index]
      if type(value) == "table" then
        fileList[a] = value
      else
        -- convert array to hash, combine array of name and array of value, {'a','b','c'} + {1,2,3} = {a=1, b=2, c=3}.
        argList[a] = value
      end
      index = index + 1
    end
  end

  -- Handle optional parameters
  if t.optional_params then
    local optList = arg[index] -- the hash of optional params should be placed after required params
    index = index + 1
    if optList then
      for _,a in ipairs(t.optional_params) do
        local value = optList[a]
        if type(value) == "table" then
          fileList[a] = optList[a]
        else
          if type(value) == "boolean" then
            optList[a] = tostring(value)
            print('[RESTful] Auto convert boolean value to string: '..tostring(_)..'=>'..optList[a])
          end
          argList[a] = optList[a]
        end
      end
    end
  end

  if t.required_payload then
    body = arg[index]
    index = index + 1
  end
  
  -- Handle callback if necessary
  if arg[index] and type(arg[index]) == "function" then
    callback = arg[index]
  elseif arg[index] and type(arg[index]) == "table" then
    callback = RESTful.createRestHandler(arg[index])
    
    if type(arg[index]["progress"]) == "function" then
      if t.method == self.methods.GET then
        progress = "download"
      else
        progress = "upload"
      end
    end

  else
    callback = RESTful.defaultRestHandler
  end

  -- Handle args and path/arg substitution, /api/path/:arg?param=escaped_value
  --local args = ""
  --local newpath = t.path
  for a,v in pairs(argList) do
    -- Try to substitue into path
    newpath, count = newpath:gsub(":"..a, v)
    if count == 0 then
      if args == "" then
        args = a.."="..url_escape(v)
      else
        args = args .."&".. a .."="..url_escape(v)
      end
    end
  end
  --print("Path:", newpath)
  --print("ArgStr:", args, "\n")

  if t.required_payload then
    for a,v in pairs(fileList) do
      local filename = v.filename
      local baseDirectory = v.baseDirectory or system.DocumentsDirectory
      local path = system.pathForFile( filename, baseDirectory)
      local mime_type = v.content_type or mimetypes.guess(filename)
      -- multipart form data in body
      local fdata = multipart.new()
      fdata:addFile(a, path, mime_type, v.remoteFileName or filename)
      body = fdata:getBody()
      if DEBUG then print("Use multipart/form-data headers", "\n") end
      local newHeaders = fdata:getHeaders()
      headers["Content-Type"] = newHeaders["Content-Type"]
      headers["Content-Length"] = newHeaders["Content-Length"]
      break -- upload only one file a time
    end
  end

  if body then    
    local bodyType = type(body)

    if bodyType == "table" then
      if body.filename then
        if DEBUG then print("Try to upload file:", body.filename) end
        headers["Content-Type"] = body.content_type or mimetypes.guess(body.filename)
        body.content_type = nil
      end
    end
  end

  if t.required_payload then
    if not body then
      body = args -- intent pass paramters in body, convert args to body
      args = ""
    end
  end
  
  --Assemble and execute the request
  local base_url = t.base_url or self.api.base_url
  
  if args ~= "" then args = "?" .. args end

  local url = base_url .. "/" .. newpath .. args
  local params = {
    headers = headers,
    body = body,
    progress = progress,
  }

  -- Add event handlers
  local function handleResponse(error, response)
    response.name = name
    response.url = url
    response.method = t.method
    response.error = error -- this means networking error but not http error(404)
    -- preproccess response data
    if response.data then
      local ok, msg = pcall(function() return json.decode(response.data) end)
      if ok then
        response.data = msg
      end
    else
      response.data = {}
    end

    if type(preCallbackHook) == 'function' then preCallbackHook(response) end
    if type(callback) == 'function' then callback(response) end
  end

  -- middle event handler
  local function listener(event)
    -- preprocess rest response
    local response = {
      phase = event.phase,
      data = event.response,
      status = event.status, -- 200
      requestId = event.requestId,
      responseHeaders = event.responseHeaders, --TODO: detect content type
      bytesEstimated = event.bytesEstimated,
      bytesTransferred = event.bytesTransferred,
    }

    if DEBUG then print("responsed") end

    handleResponse(event.isError, response)
  end

  if DEBUG then
    print("-----------URL:", url)
    print("----------Body:")
    d(inspect(body))
    print("-------Headers:")
    d(inspect(headers))
    print("------Progress:")
    d(progress)
    print("---------------")
  else
    network.request(url, self.methods[t.method], listener, params)
  end
end

return RESTful
