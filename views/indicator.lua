-- Constants List:
local oX = display.screenOriginX
local oY = display.screenOriginY
local vW = display.viewableContentWidth
local vH = display.viewableContentHeight
local visibleAspectRatio = vW/vH

local class = require 'libs.middleclass'
--local Stateful = require 'libs.stateful'
--local inspect = require 'libs.inspect'

local util = require 'util'
local d = util.print_r
--util.show_fps()

-- local forward references should go here --
local screenW, screenH, halfW, halfH = display.contentWidth, display.contentHeight, display.contentWidth*0.5, display.contentHeight*0.5
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

-- ---
-- CLASSES Declaration
--
local View = require "libs.view"
local Indicator = class('Indicator', View)
--Indicator.STATUS.RELEASED = 100

function Indicator:initialize(opts, parentGroup)
  assert(type(opts) ~= table or next(opts) == nil, "a named option hash table need to create an indicator")
  View.initialize(self, parentGroup)
  assert(self.layer, 'Piece View Initialized Failed!')
  self.name = opts.name or '_indicator'
  d('创建指示器对象: '..self.name)
  d(self.name..' began with '..self:getState())
  -- -------------------
  -- DATA BINDING
  self.total = opts.total
  self.init = opts.init or 0
  self.currentPos = nil
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  local _bg = display.newRect(self.layer, display.screenOriginX, display.screenOriginY,
    display.viewableContentWidth, 16,
  )
  _bg:setFillColor(1) -- Pure White
  util.center(_bg)
  self:_attach(_bg, '_bg')
  -- TODO: Configure topbar
  -- -- local _topbar = widget.newProgressBar()
  -- END VISUAL INITIALIING
  -- -------------------
end
  
return Indicator
