local widget = require( "widget" ) 
-- Set a default theme
widget.setTheme( "widget_theme_ios7" )

--Display Constants List:
local oX = display.safeScreenOriginX
local oY = display.safeScreenOriginY
local vW = display.viewableContentWidth
local vH = display.viewableContentHeight
local visibleAspectRatio = vW/vH
local screenW, screenH, halfW, halfH = display.contentWidth, display.contentHeight, display.contentWidth*0.5, display.contentHeight*0.5
local cX, cY = display.contentCenterX, display.contentCenterY
local sW, sH = display.safeActualContentWidth, display.safeActualContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight
local topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()

local class = require 'libs.middleclass'
--local Stateful = require 'libs.stateful'
--local inspect = require 'libs.inspect'

local util = require 'util'
local d = util.print_r
--util.show_fps()

-- ---
-- CLASSES Declaration
--
local View = require "libs.view"
local Indicator = class('Indicator', View)
local Toast = require 'views.toast'
local APP = require("classes.application")

-- Enum of Indicator Types
Indicator.static.TYPE = {
    DEFAULT = 10,
    NUMERIC = 10, -- DEFAULT
    BAR = 20,
    ROUNDED = 30
  }
-- ---
-- Resize Image Display Object to Fit Screen WIDTH
--
function Indicator:initialize(opts, parent)
  assert(type(opts) == 'table' and next(opts) ~= nil, "a named option hash table need to create an indicator")
  View.initialize(self, parent)
  assert(self.layer, 'Piece View Initialized Failed!')
  self.name = opts.name or '_indicator' -- timestamp
  d('创建指示器对象: '..self.name)
  d(self.name..' began with '..self:getState())
  -- -------------------
  -- DATA BINDING
  self.topPadding = opts.top or 60
  self.total = opts.total
  self.init = opts.init or 0
  self.currentPos = nil
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  -- Configure topbar
  local _progbar
  if self.total then
    _progbar = widget.newProgressView {
        id = '_indicator_progressv',
        left = oX, top = oY + self.topPadding, width = vW,
        isAnimated = true
      }
    self:_attach(_progbar, 'bar')
  end
  
--  TODO: use native indicator instead: native.setActivityIndicator( state ) --boolean
  local _spinner = widget.newSpinner {
      id = '_spinner',
      x = halfW, y = halfH,
      deltaAngle = 10,
      incrementEvery = 20
    }
  _spinner.alpha = 0
  self:_attach(_spinner, 'spinner')
  self.layer:toFront()
  -- END VISUAL INITIALIING
  -- -------------------
end

function Indicator:onProgress(event)
  local i = event.index
  self.elements.bar:setProgress(i/self.total)
end

function Indicator:onPieceLoad(event)
  self.elements.spinner.alpha = 1
  self.elements.spinner:start()
end

function Indicator:onPieceLoaded(event)
  self.elements.spinner.alpha = 0
  self.elements.spinner:stop()
end

function Indicator:onAlbumLimitReached(event)
  local direction = event.direction or 0
  if direction == -1 then
    d('This is already the first piece!')
    --APP.repeated = APP.repeated + 1
    Toast('上滑翻页发现更多精彩'):show()
  elseif direction == 1 then
    d('This is already the foot piece!')
    Toast('你已经看到我的底线了'):show()
  elseif direction == 0 then
    d('You have reached the limitation')
  end
end

return Indicator
