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
  local tColor = colorsRGB.RGBA('black', 0.24)
  local navBarBackgroundColor = tColor or theme.navBarBackgroundColor
  local topBar = widget.newNavigationBar({
		isTransluscent = true,
		backgroundColor = navBarBackgroundColor,
		title = "= MEOW =",
		titleColor = theme.navBarTextColor,
		font = theme.fontBold, fontSize = 14,
		height = 45,
		includeStatusBar = false,
		--leftButton = leftButton
	})
  self:_attach(topBar, 'TopBar')
  -- END VISUAL INITIALIING
  -- -------------------
end
  
return Header

