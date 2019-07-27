local composer = require( "composer" )
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
local colorHex = require('libs.convertcolor').hex
local util = require 'util'
local d = util.print_r

-- ---
-- CLASSES Declaration
--
local View = require "libs.view"
local Indicator = class('Indicator', View)
local Toast = require 'views.toast'
local APP = require("classes.application")

-- ---
-- Resize Image Display Object to Fit Screen WIDTH
--
function Indicator:initialize(opts, parent)
  assert(type(opts) == 'table' and next(opts) ~= nil, "a named option hash table need to create an indicator")
  self.name = opts.name or '_indicator' -- timestamp
  View.initialize(self, parent)
  assert(self.layer, 'Piece View Initialized Failed!')
  d('创建指示器对象: '..self.name)
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
  if self.total then
    local _progbar = widget.newProgressView {
      id = '_indicator_progressv',
      left = oX, top = oY + self.topPadding, width = vW,
      isAnimated = true
    }
    self:_attach(_progbar, 'progressBar')
    local goldenPaint = {colorHex('C7A680')}
    local whitePaint  = colorsRGB.RGBA('lightgray')
    _progbar._view._fillLeft.fill = goldenPaint
    _progbar._view._fillMiddle.fill = goldenPaint
    _progbar._view._fillRight.fill = goldenPaint
    _progbar._view._outerLeft.fill = whitePaint
    _progbar._view._outerMiddle.fill = whitePaint
    _progbar._view._outerRight.fill = whitePaint
  end

  local _spinner = widget.newSpinner {
    id = '_spinner',
    x = halfW, y = halfH,
    deltaAngle = 10,
    incrementEvery = 20
  }
  _spinner.alpha = 0
  self:_attach(_spinner, 'spinner')
  --self.layer:toFront()
  -- END VISUAL INITIALIING
  -- -------------------
  d(self.name..' began with '..self:getState())
end

function Indicator:onProgress(event)
  local i = event.index
  --d(self:getState())
  --d(self.layer)
  local progressBar = self.elements.progressBar
  if progressBar then
    self.elements.progressBar:setProgress(i/self.total)
    --self.layer:toFront()
  end
end

function Indicator:onPieceLoad(event)
  self.elements.spinner.alpha = 1
  self.elements.spinner:start()
end

function Indicator:onPieceLoaded(event)
  self.elements.spinner.alpha = 0
  self.elements.spinner:stop()
end

function Indicator:onHeaderMove(event)
  local progressBar = self.elements.progressBar
  local barMargin = progressBar.height
  d(event.targetYPos)
  local targetY = event.targetYPos
  self.animation = transition.to(progressBar, {time = 450, transition = easing.outExpo, y =  targetY + barMargin/2})
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

function Indicator:stop()
  d('Destroy Indicator View')
  self:cleanup()
end

return Indicator
