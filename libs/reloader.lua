-- Reload images, audios, videos, etc.
local class = require 'libs.middleclass'
local Stateful = require 'libs.stateful'
--local inspect = require 'libs.inspect'
local reloader = class 'reloader'
local lfs = require 'lfs'

local util = require 'util'
d = util.print_r

local pathForImages 	= ""
local filenames = {}
local baseDir
local baseDirDevice
local environment = system.getInfo( "environment" )

function reloader:initialize(baseDirectory)
  if environment == "simulator" then  
    baseDir = system.pathForFile(nil, system.CachesDirectory)
    for file in lfs.dir(baseDir .. pathForImages) do
      if (file ~= '.' and file ~= '..' and file ~= ".DS_Store" ) then
        table.insert(filenames, file)
      end
    end
  else
    baseDir = system.pathForFile( nil, system.CachesDirectory ) 
    for file in lfs.dir(baseDir) do
      if (file ~= '.' and file ~= '..' and file ~= ".DS_Store" ) then
        table.insert(filenames, file)
      end
    end
    if (#filenames == 0) then return false end
  end
  
  if environment == "simulator" then  
    baseDir = system.pathForFile('main.lua'):gsub("main.lua", "")
      for file in lfs.dir(baseDir .. pathForImages) do
          if (file ~= '.' and file ~= '..' and file ~= ".DS_Store" ) then
              table.insert(filenames, file)
          end
      end
  else
    baseDir = system.pathForFile( nil, system.ResourceDirectory ) 
    for file in lfs.dir(baseDir .. "/" .. pathForImages) do
          if (file ~= '.' and file ~= '..' and file ~= ".DS_Store" ) then
              table.insert(filenames, file)
          end
      end
      if (#filenames == 0) then return false end
  end
  self.filenames = filenames
  --d(self.filenames)
end

function reloader:access(fname, baseDir)
  self.fullPath = system.pathForFile(fname, system.pathForFile('main.lua'):gsub("main.lua", ""))
  d(self.fullPath)
  return self.fullPath
end

return reloader