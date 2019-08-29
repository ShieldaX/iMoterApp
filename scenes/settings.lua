----------------------------------------------------------------------------------
--      Main App
--      Scene notes
---------------------------------------------------------------------------------
local composer = require( "composer" )

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

local fontDMFT = 'assets/fonts/DMFT1541427649707.ttf'
local fontSHSans = 'assets/fonts/SourceHanSansK-Regular.ttf'
local fontSHSansBold = 'assets/fonts/SourceHanSansK-Bold.ttf'
local fontMorganiteBook = 'assets/fonts/Morganite-Book-4.ttf'
local fontMorganiteSemiBold = 'assets/fonts/Morganite-SemiBold-9.ttf'
local fontZcoolHuangYou = 'assets/fonts/站酷庆科黄油体.ttf'

local colorHex = require('libs.convertcolor').hex
local widget = require( "widget" )
local util = require 'util'
local d = util.print_r

local inspect = require('libs.inspect')
local iMoterAPI = require( "classes.iMoter" )

local HeaderView = require("views.header")

-- mui
--local muiData = require( "materialui.mui-data" )

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
local mui = require( "materialui.mui" )
local iMoter = iMoterAPI:new()

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:create( event )
	local sceneGroup = self.view
  local params = event.params
  mui.init(nil, { parent=self.view })
  local _ColorGray = {colorHex('6C6C6C')}
  local _ColorDark = {colorHex('1A1A19')}
  local _ColorGolden = {colorHex('C7A680')}
  local labelFSize = 34
  local padding = labelFSize*.618
  local topMargin = topInset
  local gY
  -----------------------------------------------------------------------------
  -- Create a vector rectangle sized exactly to the "safe area"
  local background = display.newRect(sceneGroup, oX, oY, vW, vH)
  background:setFillColor(colorHex('1A1A19'))
  background:translate( background.contentWidth*0.5, background.contentHeight*0.5 )
  sceneGroup:insert( background )
  
  self.header = HeaderView:new({name = 'NavBar'}, sceneGroup)
  self.header.elements.navBar:setLabel('设置')
  
  -- Usage
  -- 横图自动旋转 =================================
  local function onSwitchPress( event )
    local switch = event.target
    print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )
  end
  -- Create the widget
  local autoRotateLabel = display.newText( "横图自动旋转", 0, 0, fontZcoolHuangYou, labelFSize*.69)
  autoRotateLabel.anchorX = 1; autoRotateLabel.anchorY = 0
  autoRotateLabel.x = cX + labelFSize*.5
  autoRotateLabel.y = topMargin + labelFSize + 40
  sceneGroup:insert(autoRotateLabel)
  gY = autoRotateLabel.y
  local autoRotateSwitch = widget.newSwitch(
    {
      left = cX + labelFSize,
      top = gY,
      style = "onOff",
      id = "onOffSwitch",
      initialSwitchState = false, --TODO: load state from local_storage
      onPress = onSwitchPress
    }
  )
  sceneGroup:insert(autoRotateSwitch)
  -- ================================================
  
  -- 手机网络可用 =================================
  local function onNetBanSwitchPress( event )
    local switch = event.target
    print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )
  end
  local mobileNetworkBanLabel = display.newText( "非Wi-Fi下可用", 0, 0, fontZcoolHuangYou, labelFSize*.69)
  mobileNetworkBanLabel.anchorX = 1; mobileNetworkBanLabel.anchorY = 0
  mobileNetworkBanLabel.x = cX + labelFSize*.5
  mobileNetworkBanLabel.y = gY + 60
  sceneGroup:insert(mobileNetworkBanLabel)
  gY = mobileNetworkBanLabel.y
  local networkBanSwitch = widget.newSwitch(
    {
      left = cX + labelFSize,
      top = gY,
      style = "onOff",
      id = "onOffSwitch",
      initialSwitchState = false, --TODO: load state from local_storage
      onPress = onNetBanSwitchPress
    }
  )
  sceneGroup:insert(networkBanSwitch)
  -- ================================================
  
  local function resetCache( event )
    if ( "ended" == event.phase ) then
      print( "TODO: clear app's cache data, images" )
    end
  end
  local resetCacheBtn = widget.newButton(
    {
      label = "清 除 缓 存",
      onEvent = resetCache,
      emboss = false,
      -- Properties for a rounded rectangle button
      shape = "roundedRect",
      width = 200,
      height = 40,
      cornerRadius = 10,
      font = fontZcoolHuangYou, fontSize = labelFSize*.6,
      labelAlign = 'center', 
      labelColor = { default=colorsRGB.RGBA('white'), over=colorsRGB.RGBA('white') },
      fillColor = { default=colorsRGB.RGBA('firebrick'), over=colorsRGB.RGBA('tomato') },
--      strokeColor = { default={1,0.4,0,1}, over={0.8,0.8,1,1} },
--      strokeWidth = 2
    }
  )
  resetCacheBtn.x = cX
  resetCacheBtn.y = gY + 80
  gY = resetCacheBtn.y
  sceneGroup:insert(resetCacheBtn)

  local function signout( event )
    if ( "ended" == event.phase ) then
      print( "TODO: sign user out" )
    end
  end
  local signoutBtn = widget.newButton(
    {
      label = "退 出 登 录",
      onEvent = signout,
      emboss = false,
      -- Properties for a rounded rectangle button
      shape = "roundedRect",
      width = 200,
      height = 40,
      cornerRadius = 10,
      font = fontZcoolHuangYou, fontSize = labelFSize*.6,
      labelAlign = 'center', 
      labelColor = { default=colorsRGB.RGBA('white'), over=colorsRGB.RGBA('white') },
      fillColor = { default=colorsRGB.RGBA('firebrick'), over=colorsRGB.RGBA('tomato') },
--      strokeColor = { default={1,0.4,0,1}, over={0.8,0.8,1,1} },
--      strokeWidth = 2
    }
  )
  signoutBtn.x = cX
  signoutBtn.y = gY + 69
  gY = signoutBtn.y
  sceneGroup:insert(signoutBtn)

  APP:sceneForwards(params, 'mine')
  -----------------------------------------------------------------------------
end

-- Called BEFORE scene has moved onscreen:
function scene:show( event )
	local sceneGroup = self.view
  local phase = event.phase
  local params = event.params
  if ( phase == "will" ) then
--    local _title = params.title
--    _title = _title:gsub("%d+%.%d+%.%d+", '', 1)
--    local title = util.GetMaxLenString(_title, 30)
    --self.header.elements.navBar:setLabel(title)
    APP.Footer:hide()
  elseif ( phase == "did" ) then
    if self.infoCard then
      self.infoCard:show()
    end
    d('settings showing...')
    local sceneToRemove = composer.getVariable('sceneToRemove')
    if sceneToRemove then
      composer.removeScene(sceneToRemove)
      composer.setVariable('sceneToRemove', false)
    end
    APP._scenes()
  end
end

function scene:hide( event )
	local sceneGroup = self.view
	-- nothing to do here
  if ( phase == "will" ) then

  elseif ( phase == "did" ) then
    local sceneName = APP.popScene().name
    d('POP:')
    d(sceneName)
    composer.removeScene(sceneName)
  end
end

function scene:destroy( event )
	local sceneGroup = self.view
  --network.cancel(self.requestId)
  self.header:cleanup()
  d('settings scene destoried success!')
  --APP.popScene()
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene