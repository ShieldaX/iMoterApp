local widget = require( "widget" ) 
-- Set a default theme
widget.setTheme( "widget_theme_ios7" )

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
local Header = class('HeaderView', View)

-- ---
-- Resize Image Display Object to Fit Screen WIDTH
--
function Header:initialize(opts, parent)
  assert(type(opts) == 'table' and next(opts) ~= nil, "a named option hash table need to create the header")
  View.initialize(self, parent)
  assert(self.layer, 'Piece View Initialized Failed!')
  self.name = opts.name or '_indicator' -- timestamp
  d('创建指示器对象: '..self.name)
  d(self.name..' began with '..self:getState())
  -- -------------------
  -- DATA BINDING
  --
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  -- Configure topbar
  
  -- END VISUAL INITIALIING
  -- -------------------
end

function Header:onProgress(event)
  local i = event.index
  self.elements.bar:setProgress(i/self.total)
end

function Header:onPieceLoad(event)
  self.elements.spinner.alpha = 1
  self.elements.spinner:start()
end

function Header:onPieceLoaded(event)
  self.elements.spinner.alpha = 0
  self.elements.spinner:stop()
end
  
return Header

