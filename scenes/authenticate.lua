----------------------------------------------------------------------------------
--      Main App
--      Scene notes
---------------------------------------------------------------------------------
local mui = require( "materialui.mui" )
local muiData = require( "materialui.mui-data" )

local composer = require( "composer" )

local util = require 'util'
local d = util.print_r
local colorHex = require('libs.convertcolor').hex

-- Constants List:
local oX = display.screenOriginX
local oY = display.screenOriginY
local vW = display.viewableContentWidth
local vH = display.viewableContentHeight
local screenW, screenH, halfW, halfH = display.contentWidth, display.contentHeight, display.contentWidth*0.5, display.contentHeight*0.5
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight
local cX, cY = screenOffsetW + halfW, screenOffsetH + halfH
-- Gather insets (function returns these in the order of top, left, bottom, right)
local topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()

-- Fonts
local fontDMFT = 'assets/fonts/DMFT1541427649707.ttf'
local fontSHSans = 'assets/fonts/SourceHanSansK-Regular.ttf'
local fontSHSansBold = 'assets/fonts/SourceHanSansK-Bold.ttf'
local fontMorganiteBook = 'assets/fonts/Morganite-Book-4.ttf'
local fontMorganiteSemiBold = 'assets/fonts/Morganite-SemiBold-9.ttf'
local fontZcoolHuangYou = 'assets/fonts/站酷庆科黄油体.ttf'

local background = nil
local widget = require( "widget" )

local inspect = require('libs.inspect')
local iMoterAPI = require( "classes.iMoter" )

--local mui = require( "materialui.mui" )
--local AlbumView = require("views.album")
local AlbumList = require("views.album_list")
--local MoterView = require("views.moter")
local HeaderView = require("views.home_header")
local FooterView = require("views.footer")
--local Indicator = require 'views.indicator'

-- mui
--local muiData = require( "materialui.mui-data" )
-- @usage: https://material.io/tools/icons
function util.createIcon(options)
  local fontPath = "icon-font/"
  local materialFont = fontPath .. "MaterialIcons-Regular.ttf"
  options.font = materialFont
  local x,y = 160, 240
  if options.x ~= nil then
    x = options.x
  end
  if options.y ~= nil then
    y = options.y
  end  
  local fontSize = options.height
  if options.fontSize ~= nil then
    fontSize = options.fontSize
  end
  fontSize = math.floor(tonumber(fontSize))

  local font = native.systemFont
  if options.font ~= nil then
    font = options.font
  end
  local textColor = { 0, 0.82, 1 }
  if options.textColor ~= nil then
    textColor = options.textColor
  end
  local fillColor = { 0, 0, 0 }
  if options.fillColor ~= nil then
    fillColor = options.fillColor
  end
  options.isFontIcon = true
  -- scale font
  -- Calculate a font size that will best fit the given text field's height
  local checkbox = {contentHeight=options.height, contentWidth=options.width}
  local textToMeasure = display.newText( options.text, 0, 0, font, fontSize )
  fontSize = math.floor(fontSize * ( ( checkbox.contentHeight ) / textToMeasure.contentHeight ))
  local tw = textToMeasure.contentWidth
  local th = textToMeasure.contentHeight
  tw = fontSize
  options.text = mui.getMaterialFontCodePointByName(options.text)
  textToMeasure:removeSelf()
  textToMeasure = nil
  local options2 =
  {
    --parent = textGroup,
    text = options.text,
    x = x,
    y = y,
    font = font,
    width = tw * 1.5,
    fontSize = fontSize,
    align = "center"
  }
  local _icon = display.newText( options2 )
  _icon:setFillColor(unpack(textColor))
  return _icon
end
----------------------------------------------------------------------------------
--
--      NOTE:
--
--      Code outside of listener functions (below) will only be executed once,
--      unless storyboard.removeScene() is called.
--
---------------------------------------------------------------------------------
local scene = composer.newScene()
-- Our modules
local APP = require( "classes.application" )
--local utility = require( "libs.utility" )

local iMoter = iMoterAPI:new()

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:create( event )
  local sceneGroup = self.view
  mui.init(nil, { parent=self.view })
  -- Create a vector rectangle sized exactly to the "safe area"
  background = display.newRect(sceneGroup, oX, oY, vW, vH)
  background:setFillColor(colorHex('1A1A19'))
  background:translate( background.contentWidth*0.5, background.contentHeight*0.5 )
  sceneGroup:insert( background )
  local _ColorGray = {colorHex('6C6C6C')}
  local _ColorDark = {colorHex('1A1A19')}
  local _ColorGolden = {colorHex('C7A680')}
  local labelFSize = 34
  local padding = labelFSize*.618
  local topMargin = oX + topInset
  d(topMargin)
  local layoutY = topMargin
  local labelHeadline = display.newText( "欢迎回来", 0, 0, fontZcoolHuangYou, labelFSize)
--  labelHeadline.anchorX = 0; labelHeadline.anchorY = .5
  labelHeadline.x = cX
  labelHeadline.y = topMargin + labelFSize
  sceneGroup:insert(labelHeadline)
  layoutY = labelHeadline.y

  mui.newTextField({
      parent = mui.getParent(),
      name = "email",
      labelText = "邮箱",
      text = "example@email.com",
      font = fontZcoolHuangYou,
      width = vW*.618,
      height = 36,
      x = cX,
      y = topMargin + labelFSize*2 + 18,
      trimAtLength = 30,
      activeColor = _ColorGolden,
      inactiveColor = _ColorGolden,
      callBack = mui.textfieldCallBack
    })

  mui.newTextField({
      parent = mui.getParent(),
      name = "password",
      labelText = "密码",
      text = "password",
      font = fontZcoolHuangYou,
      width = vW*.618,
      height = 36,
      x = cX,
      y = topMargin + labelFSize*2 + 120,
      activeColor = _ColorGolden,
      inactiveColor = _ColorGolden,
      callBack = mui.textfieldCallBack,
      isSecure = true
    })

--  self.fieldUserName = mui.newTextField({
--      parent = mui.getParent(),
--      name = "username",
--      labelText = "用户名",
--      text = "nickname",
--      font = fontZcoolHuangYou,
--      width = vW*.618,
--      height = 36,
--      x = cX,
--      y = oX + topInset + 260,
--      activeColor = _ColorGolden,
--      inactiveColor = _ColorGolden,
--      callBack = mui.textfieldCallBack,
--    })
  local labelReturnStatus = display.newText(sceneGroup, "没有账户？点击创建", 0, 0, fontSHSansBold, 14)
  labelReturnStatus:setFillColor(unpack(_ColorGray))
  labelReturnStatus.anchorY = 0
  labelReturnStatus.x = cX
  labelReturnStatus.y = topMargin + labelFSize*2 + 120 + 40
-- ----------------------------------------------------------------------------
-- HANDLE BUTTON PRESS
-- ----------------------------------------------------------------------------
  local function btnOnPressHandler(event)    
    local email = mui.getWidgetProperty('email', 'value')
    local password = mui.getWidgetProperty('password', 'value')

    print(email)
    print(password)

    -- stop if fields are blank
    if(email == '' or password == '') then
--      labelReturnStatus.text = '请输入账户和密码！'
      native.showAlert("登录失败", "请输入账户和密码！", { "好" } )
      return
    end
    local function refreshToken(res)
      if not res or not res.data then
        native.showAlert("登录失败", "请输入正确的账户和密码！", { "好" } )
--        labelReturnStatus.text = '登录失败，请检查您的设置！'
        return false
      end
      if tonumber(res.status) == 200 then
        APP.access_token = iMoter.headers.Authorization
        local user = res.data.user
        composer.setVariable('verifiedUser', user)
        composer.hideOverlay('slideDown')
      else
        native.showAlert("登录失败", "请输入正确的账户和密码！", { "好" } )
--        labelReturnStatus.text = '登录失败，请输入正确的账户和密码！'
      end
    end
    iMoter:login(email, password,  refreshToken)
  end
  mui.newRoundedRectButton({
      parent = mui.getParent(),
      name = "register",
      text = "登录",
      width = 150,
      height = 40,
      x = cX,
      y = topMargin + labelFSize*2 + 220,
      radius = 10,
      font = fontZcoolHuangYou,
      iconAlign = "left",
      textColor = _ColorDark,
      fillColor = _ColorGolden,
      state = {
        value = "off", -- defaults to "off", values: off, on and disabled
        off = {
          textColor = {1, 1, 1},
          fillColor = {0, 0.81, 1}
        },
        on = {
          textColor = {1, 1, 1},
          fillColor = {0, 0.61, 1}
        },
        disabled = {
          textColor = {1, 1, 1},
          fillColor = {.3, .3, .3}
        }
      },
      callBack = btnOnPressHandler,
      callBackData = {message = "newDialog callBack called"}, -- demo passing data to an event
    })
  -----------------------------------------------------------------------------
end

-- Called BEFORE scene has moved onscreen:
function scene:show( event )
  local sceneGroup = self.view
  if event.phase == "did" then
    APP.Footer:hide()
    function background:tap(event)
      native.setKeyboardFocus(nil)
    end
    background:addEventListener("tap",background)
  end
end

function scene:hide( event )
  local sceneGroup = self.view
  local parent = event.parent
  -- nothing to do here
  if event.phase == "will" then
    parent:authenticated()
    APP.Footer:show()
  end

end

function scene:destroy( event )
  local sceneGroup = self.view
  -- nothing to do here
  mui.destroy()
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene