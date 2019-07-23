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
		width = 35,
		height = 35,
		defaultFile = "assets/images/hamburger-" .. theme.name .. ".png",
		overFile = "assets/images/hamburger-" .. theme.name .. ".png",
		onEvent = leftButtonEvent,
	}
--  local tColor = colorsRGB.RGBA('dodgerblue', 0.618)
--  local tColor = colorsRGB.RGBA('whitesmoke', 0.24)
  local topBar = widget.newNavigationBar({
		isTransluscent = true,
		backgroundColor = theme.navBarBackgroundColor,
		title = "= MEOW =",
		titleColor = theme.navBarTextColor,
		font = fontDMFT, fontSize = 18,
		height = 42,
		includeStatusBar = false,
    --top = topInset
		--leftButton = leftButton
	})
  self:_attach(topBar, 'TopBar')
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

return Header

