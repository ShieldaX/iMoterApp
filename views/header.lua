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
local colorHex = require('libs.convertcolor').hex
local util = require 'util'
local d = util.print_r

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
		local prevScene = composer.getSceneName( "previous" )
		if prevScene then
			composer.gotoScene( prevScene, {effect = 'slideRight', time = 420} )
		end
	end
	return true
end

local navBarHeight = nil

-- ---
-- TOP UI Components Navbar ProgressBar...
--
function Header:initialize(opts, parent)
  assert(type(opts) == 'table' and next(opts) ~= nil, "a named option hash table need to create the header")
  View.initialize(self, parent)
  self.name = opts.name or '_indicator' -- timestamp
  d('创建头部对象: '..self.name)
  d(self.name..' began with '..self:getState())
  -- -------------------
  -- DATA BINDING
  --
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  -- Configure topbar
	local leftButton = {
    id = 'backBtn',
    label = '< 返回',
    font = fontZcoolHuangYou,
		fontSize = 16,
		onEvent = opts.onEvent or leftButtonEvent,
    labelColor = { default={colorHex('C7A680')}, over={colorHex('6C6C6C')} }
	}
  navBarHeight = 42
  self.navBarHeight = navBarHeight
  local navBar = widget.newNavigationBar({
		isTransluscent = true,
		backgroundColor = theme.navBarBackgroundColor,
		title = "图集",
		titleColor = {colorHex('C7A680')},
		font = fontDMFT, fontSize = 18,
		height = navBarHeight,
		includeStatusBar = false,
		leftButton = leftButton,
	})
  self.navBarYPos = navBar.y
  self:_attach(navBar, 'navBar')
  -- END VISUAL INITIALIING
  -- -------------------
end

function Header:hide()
  local navBar = self.elements.navBar
  if not navBar or self.isHidden then return false end
  local targetY = navBar.y-navBarHeight
  self:signal('onHeaderMove', {hidden = true, targetYPos = targetY + self.navBarHeight + topInset})
  self.animation = transition.to(navBar, {time = 450, transition = easing.outExpo, y = targetY})
  self.isHidden = true
end

function Header:show()
  local navBar = self.elements.navBar
  if not navBar or not self.isHidden then return false end
  local targetY = self.navBarYPos
  self:signal('onHeaderMove', {hidden = false, targetYPos = targetY + self.navBarHeight + topInset})
  self.animation = transition.to(navBar, {time = 450, transition = easing.outExpo, y = targetY})
  self.isHidden = false
end 

return Header