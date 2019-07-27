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
local Header = class('HeaderView', View)

local function leftButtonEvent( event )
  if event.phase == "ended" then
    local currScene = composer.getSceneName( "overlay" )
    if currScene then
      --composer.hideOverlay( "fromRight", 250 )
    else
      --composer.showOverlay( "scenes.menu", { isModal=true, time=250, effect="fromLeft" } )
    end
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
  self.name = opts.name or 'home_header' -- timestamp
  d('创建首页头部对象: '..self.name)
  d(self.name..' began with '..self:getState())
  -- -------------------
  -- DATA BINDING
  --
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  --local topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()
  local titleFSize = 12
  local labelFSize = 20
  local padding = labelFSize*.618
  local gY = topInset + padding*2

  local labelUpdate = display.newText {text = '最新', x = vW*.24, y = gY, fontSize = labelFSize, font = fontZcoolHuangYou}
  local labelHot = display.newText {text = '热门', x = vW*.5, y = gY, fontSize = labelFSize, font = fontZcoolHuangYou}
  local labelTag = display.newText {text = '标签', x = vW*.76, y = gY, fontSize = labelFSize, font = fontZcoolHuangYou}
  self:_attach(labelUpdate, 'labelUpdate')
  self:_attach(labelHot, 'labelHot')
  self:_attach(labelTag, 'labelTag')
  labelUpdate.id = 'labelUpdate'
  labelHot.id = 'labelHot'
  labelTag.id = 'labelTag'
  local cursorRect = display.newRect(cX, cY, vW*.2, 4)
  cursorRect:setFillColor(colorHex('C7A680'))
  cursorRect.anchorY = 1
  cursorRect.y = labelUpdate.y + padding*2
  self:_attach(cursorRect, 'cursor')
  cursorRect.x = labelUpdate.x
  self.tabSelected = 'labelUpdate'
  self:start()
  -- END VISUAL INITIALIING
  -- -------------------
end

function Header:hide()
  local topBar = self.elements.TopBar
  if not topBar or self.isHidden then return false end
  self.animation = transition.to(topBar, {time = 450, transition = easing.outExpo, y = -topBar.contentHeight})
  self:signal('onHeaderMove', {hidden = true})
  self.isHidden = true
end

function Header:show()
  local topBar = self.elements.TopBar
  if not topBar or not self.isHidden then return false end
  self.animation = transition.to(topBar, {time = 450, transition = easing.outExpo, y = 0})
  self:signal('onHeaderMove', {hidden = false})
  self.isHidden = false
end

function Header:start()
  for i, e in pairs(self.elements) do
    e:addEventListener('tap', self)
  end
end

function Header:tap(event)
  local id = event.target.id
  if self.tabSelected == id then
    d('Tab already seleted')
  else
    self:selectTab(event.target.id)
  end
  return true
end

function Header:selectTab(tab_id)
  local cursor = self.elements.cursor
  local targetTab = self.elements[tab_id]
  transition.to(cursor, {transition = easing.outExpo, time = 400, x = targetTab.x})
  self.tabSelected = tab_id
  self:signal('onHomeTabChanged', {tab = tab_id})
end

function Header:onHomeTabChanged(event)
  d(event)
  local targetTabID = event.tab
  local updateView = APP.albumListView
  if targetTabID == 'labelUpdate' then
    transition.to(updateView.layer, {transition = easing.outExpo, time = 600, x = 0})
  else
    transition.to(updateView.layer, {transition = easing.outExpo, time = 600, x = -vW})
  end
end

return Header