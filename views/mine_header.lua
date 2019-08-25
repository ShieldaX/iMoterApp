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
    APP:sceneBackwards()
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
  -- -------------------
  -- DATA BINDING
  --
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  -- Configure topbar
  navBarHeight = 42
  self.navBarHeight = navBarHeight

  local bg = display.newRect(cX, navBarHeight, vW, vH*.24)
  bg:setFillColor(unpack(theme.navBarBackgroundColor))
  bg.anchorY = 0
  self:_attach(bg, 'bg')

  local RightButton = {
    id = 'backBtn',
    label = '设置 ',
    font = fontZcoolHuangYou,
    fontSize = 16,
    onEvent = opts.onEvent or leftButtonEvent,
    labelColor = { default={colorHex('C7A680')}, over={colorHex('6C6C6C')} }
  }

  local navBar = widget.newNavigationBar({
      isTransluscent = true,
      backgroundColor = theme.navBarBackgroundColor,
      title = "个人中心",
      titleColor = {colorHex('C7A680')},
      font = fontDMFT, fontSize = 18,
      height = navBarHeight,
      includeStatusBar = false,
      rightButton = RightButton,
    })
  self.navBarYPos = navBar.y
  self:_attach(navBar, 'navBar')
  self:showAvatar()
  -- END VISUAL INITIALIING
  -- -------------------
end

function Header:showAvatar()
  -- Set the fill (paint) to use the bitmap image
  local paint = {
    type = "image",
    filename = "assets/images/user.png"
  }
  local avatar = display.newCircle(cX, cY, 36)
  avatar:setStrokeColor(.8)
  avatar.strokeWidth = 2
  avatar.fill = paint
  self:_attach(avatar, 'avatar')
  local bg = self.elements.bg
  avatar.x = vW*.2
  avatar.y = bg.y + bg.contentHeight*.6
  local uname = display.newText {
    text = '登录/注册',
    font = fontDMFT,
    fontSize = 20,
  }
  self:_attach(uname, 'auth')
  uname.anchorX = 0
  uname.x = avatar.x + avatar.width*.8
  uname.y = avatar.y
  local function userAuthentication()
    local options =
    {
      isModal = true,
      effect = "slideUp",
      time = 360,
      params = {
        sampleVar1 = "my sample variable",
        sampleVar2 = "another sample variable"
      }
    }
    composer.showOverlay('scenes.authenticate', options)
  end
  uname:addEventListener('tap', userAuthentication)
end

function Header:loadUser(event)
  local user = event.user
  self.elements.auth.text = user.name
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

function Header:toggle()
  if self.isHidden then
    self:show()
  else
    self:hide()
  end
end

return Header