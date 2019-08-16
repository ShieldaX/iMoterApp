local composer = require( "composer" )
local widget = require( "widget" )
local widgetExtras = require("libs.widget-extras")
-- Set a default theme
widget.setTheme("widget_theme_ios7")

--
-- theme -- a data table of colors and font attributes to quickly change
--          how the app looks
--
local theme = require( "classes.theme" )

local class = require 'libs.middleclass'
--local Stateful = require 'libs.stateful'
--local inspect = require 'libs.inspect'

local util = require 'util'
local d = util.print_r
local colorHex = require('libs.convertcolor').hex

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

-- Fonts
local fontDMFT = 'assets/fonts/DMFT1541427649707.ttf'
local fontSHSans = 'assets/fonts/SourceHanSansK-Regular.ttf'
local fontSHSansBold = 'assets/fonts/SourceHanSansK-Bold.ttf'
local fontMorganiteBook = 'assets/fonts/Morganite-Book-4.ttf'
local fontMorganiteSemiBold = 'assets/fonts/Morganite-SemiBold-9.ttf'
local fontZcoolHuangYou = 'assets/fonts/站酷庆科黄油体.ttf'

-- Our modules
local APP = require( "classes.application" )

-- ---
-- CLASSES Declaration
--
local View = require "libs.view"
local Header = class('TagHeaderView', View)

local function leftButtonEvent( event )
  if event.phase == "ended" then
    APP:sceneBackwards()
  end
  return true
end

-- ---
-- TOP UI Components Navbar ProgressBar...
--
function Header:initialize(opts, parent)
  assert(type(opts) == 'table' and next(opts) ~= nil, "a named option hash table need to create the header")
  View.initialize(self, parent)
  assert(self.layer, 'Piece View Initialized Failed!')
  self.name = opts.name or 'tag_header' -- timestamp
  self.id = opts.id
  self.tag_name = opts.tag_name or 'meitui'
  self.tag_desc = opts.tag_desc or '美腿美女图片，图片中的美女都有着美丽、性感、修长的玉腿。美腿之美可以分为晶莹剔透的大腿美、白璧无瑕的小腿美、细微的美足、健康明朗的腿形美。美腿不仅具有先天性因素，同时通过后天的弥补也可以修得迷人腿型，方法多样。'
  -- -------------------
  -- DATA BINDING
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  --local topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()
  local titleFSize = 12
  local labelFSize = 18
  local padding = labelFSize*.618
  local gY = topInset + padding*2
  
  local labelTitle = display.newText {text = self.tag_name, x = vW*.24, y = gY, fontSize = 26, font = fontZcoolHuangYou}
  gY = gY + padding*4
  local labelDesc = display.newText {text = self.tag_desc, x = vW*.24, y = gY, fontSize = labelFSize, font = fontZcoolHuangYou}
  self:_attach(labelTitle, 'labelTitle')
  self:_attach(labelDesc, 'labelDesc')
  labelDesc.id = 'labelDesc'
  -- END VISUAL INITIALIING
  -- -------------------
end

function Header:tap(event)
  local id = event.target.id
  
  return true
end

return Header