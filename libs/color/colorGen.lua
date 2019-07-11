local colorGen = {}

-- Table of named HEX colors
local _colors = {
    ["darkest-grey"]    = "#404040", -- .25
    ["darker-grey"]     = "#727272", -- .37
    ["dark-grey"]       = "#868686", -- .45
    ["grey"]            = "#929292", -- .50
    ["medium-grey"]     = "#BFBFBF", -- .70
    ["light-grey"]      = "#EFEFEF", -- .92
    ["lighter-grey"]    = "#F7F7F7", -- .97

    ["near-white"]      = "#F9F9F9", -- .98

    ["dark-blue"]       = "#3192A7",
    ["blue"]            = "#53B3C7",
    ["light-blue"]      = "#7DCFDE",

    ["orange"]          = "#F39C12",

    ["green"]           = "#86d479",
    ["light-green"]     = "#66E666",

    ["red"]             = "#E66666"
}

-- source https://gist.github.com/jasonbradley/4357406
local function hex2rgb (hex)
    local hex = hex:gsub("#","")
    local r, g, b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
    return r/255, g/255, b/255 -- Corona needs percentages
end

function colorGen:new ()
    local obj = {}
    self.__index = self
    return setmetatable(obj, self)
end

function colorGen:get (name)
    if not _colors[name] then
        print("ERROR: "..name.." does not exist")
    end
    return hex2rgb( _colors[name] )
end

function colorGen:getOver (name)
    local r, g, b = hex2rgb( _colors[name] )
    return r, g, b, .75
end

return colorGen

--[[
Usage:

local btn = widget.newButton {
    x = 0,
    y = 0,
    label = "My Button",
    labelColor = { default = { colors:get("orange") }, over = { colors:getOver("orange") } },
    fillColor = { default = { colors:get("medium-grey") }, over = { colors:getOver("medium-grey") } },
    font = "Custom Font",
    shape = "circle",
    radius = 10,
    fontSize = 12,
    onRelease = onBtnRelease
}

--]]