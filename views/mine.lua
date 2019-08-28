-- Mine UI
local composer = require( "composer" )
local widget = require( "widget" )
local mui = require( "materialui.mui" )

local _ = require 'libs.underscore'
local class = require 'libs.middleclass'
local Stateful = require 'libs.stateful'
local inspect = require 'libs.inspect'
local colorHex = require('libs.convertcolor').hex

local util = require 'util'
local d = util.print_r

-- Classes
local View = require 'libs.view'
local Piece = require 'views.piece'
local Album = require 'views.album'
local Cover = require 'views.album_cover'
local MineList = class('MineList', View)
local APP = require("classes.application")

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

local function createIcon(options)
  local fontPath = "icon-font/"
  local materialFont = fontPath .. "MaterialIcons-Regular.ttf"
  options.font = materialFont
  options.text = mui.getMaterialFontCodePointByName(options.text)
  local icon = display.newText(options)
  return icon
end

-- 利用获取的图集信息实例化一个图集对象
function MineList:initialize(topPadding, sceneGroup)
  View.initialize(self, sceneGroup)
  -- -------------------
  -- DATA BINDING
--  self.rawData = obj
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  local bgColor
  local rowLineColor
  local labelColor = {colorHex('C7A680')}
  local function onRowRender( event )

    --Set up the localized variables to be passed via the event table

    local row = event.row
    local id = row.index
    local params = event.row.params

    row.bg = display.newRect( 0, 0, display.contentWidth, 60 )
    row.bg.anchorX = 0
    row.bg.anchorY = 0
    row.bg:setFillColor(colorHex('1A1A19'))
    row:insert( row.bg )
    row._separator:toFront()

    if ( event.row.params ) then    
      row.nameText = display.newText( params.name, 12, 0, fontZcoolHuangYou, 22 )
      row.nameText.anchorX = 0
      row.nameText.anchorY = 0.5
      row.nameText:setFillColor( unpack(labelColor) )
      row.nameText.y = 30
      row.nameText.x = 42
      
      row.rightArrow = display.newText( '>', 12 , 0,  fontZcoolHuangYou, 18)
      row.rightArrow.anchorX = 0
      row.rightArrow.anchorY = 0.5
      row.rightArrow:setFillColor( .5 )
      row.rightArrow.x = display.contentWidth - 40
      row.rightArrow.y = row.height / 2

      row:insert( row.nameText )
      row:insert( row.rightArrow )
    end
    return true
  end

  local navBarHeight = topPadding or 100
  local tabBarHeight = 50
  local menuList = widget.newTableView {
    top = navBarHeight, 
    width = display.contentWidth,
    height = display.contentHeight - navBarHeight - tabBarHeight,
    onRowRender = onRowRender,
    onRowTouch = onRowTouch,
    hideBackground = true,
    topPadding = topInset*.36,
  }

  local menuData = {}
  menuData[1] = { name="收藏的图集" }
  menuData[2] = { name="喜欢的女神" }
  menuData[3] = { name="开通会员"   }
  menuData[4] = { name="问题反馈"   }
  menuData[5] = { name="关于优艺"   }
  menuData[6] = { name="帮助中心"   }

  for i = 1, #menuData do
    menuList:insertRow{
      rowHeight = 60,
      isCategory = false,
      rowColor = { default=labelColor, over={1,0.5,0,0.2} },
      lineColor = {.5, .5, .5, .5},
      params = {
        name = menuData[i].name,
        phone = menuData[i].phone
      }
    }
  end
  self:_attach(menuList, 'table')
  -- END VISUAL INITIALIING
  -- -------------------
end

function MineList:onAlbumTapped(event)
  local options = {
    effect = "fade",
    time = 500,
    isModal = true,
    params = event
  }
  composer.showOverlay( "scenes.album", options )
end

function MineList:onCoverTapped(event)
  local options = {
    effect = "slideLeft",
    time = 420,
    params = event
  }
  composer.gotoScene( "scenes.album", options )
end

function MineList:start()
  if self.state == 30 then return false end
  --local e = self.elements
  self:setState('STARTED')
end

function MineList:stop()
  self:cleanup()
end

return MineList