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
local Stateful = require 'libs.stateful'
--local inspect = require 'libs.inspect'

local util = require 'util'
local d = util.print_r

-- local forward references should go here --
local screenW, screenH, halfW, halfH = display.contentWidth, display.contentHeight, display.contentWidth*0.5, display.contentHeight*0.5
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

-- ---
-- CLASSES Declaration
--
local View = require "libs.view"
local Button = class('Button', View)
--local Toast = require 'views.toast'
local APP = require("classes.application")
Button:include(Stateful)

-- Enum of Indicator Types
Button.static.TYPE = {
    DEFAULT = 10,
    PLAIN = 10, -- DEFAULT
    BAR = 20,
    CUSTOMED = 100
  }
-- ---
-- Resize Image Display Object to Fit Screen WIDTH
--
function Button:initialize(opts, parent)
  assert(type(opts) == 'table' and next(opts) ~= nil, "a named option hash table need to create an indicator")
  self.name = opts.name or '_Button'..os.time() -- timestamped
  View.initialize(self, parent)
  assert(self.layer, 'Button View Initialized Failed!')
  d('创建按钮对象: '..self.name) -- Key =>（按）键; Button => 按钮 
  -- -------------------
  -- DATA BINDING
  self.padding = opts.padding or 40
  self.labelText = opts.text or 'Button'
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  -- Configure topbar
  local _progbar = widget.newProgressView {
      id = '_indicator_progressv',
      left = oX, top = oY + self.topPadding, width = vW,
      isAnimated = true
    }
  self:_attach(_progbar, 'bar')
  
  local _spinner = widget.newSpinner {
      id = '_spinner',
      x = halfW, y = halfH,
      deltaAngle = 10,
      incrementEvery = 20
    }
  
  self:_attach(_spinner, 'spinner')
  -- END VISUAL INITIALIING
  -- -------------------
end

-- overridable visual constructor
function Button:render(btnType)
  local btnTypeList = Button.TYPE
  btnType = table.indexOf(btnTypeList, btnType) or btnTypeList.DEFUALT
  if btnType == btnTypeList.DEFUALT or btnType == btnTypeList.PLAIN then
    -- 普通文字按钮
    local touchArea = display.newRect(0, 0, 200, 100)
    touchArea:setFillColor(colorsRGB.RGBA('gray', 0.6))
    touchArea.anchorX, touchArea.anchorY = .5, .5
    if not Button.DEBUG then
      touchArea.isVisible = true
    else
      touchArea.isVisible = false
    end
    touchArea.isHitTestable = true
    local label = display.newText { -- TODO: Use embossed text constructor
        text = self.labelText,
        x = 0, y = 0,
        font = native.systemFontBold,
        fontSize = self.fontSize or 16
      }
    touchArea.width = self.padding*2+label.width
    touchArea.height = self.padding*2+label.height
    --
    self.touchDelegate = touchArea
  end
  self:send('start')
  --self:gotoState('TOUCHABLE')
end

function Button:start()
  self.touchDelegate:addEventListener('touch', self)
end

function Button:touch(touch)
  d(touch.phase)
end

function Button:onProgress(event)
  local i = event.index
  self.elements.bar:setProgress(i/self.total)
end

function Button:onPieceLoad(event)
  self.elements.spinner.alpha = 1
  self.elements.spinner:start()
end

function Button:onPieceLoaded(event)
  self.elements.spinner.alpha = 0
  self.elements.spinner:stop()
end

function Button:onAlbumLimitReached(event)
  local direction = event.direction or 0
  local _toast
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

return Button
