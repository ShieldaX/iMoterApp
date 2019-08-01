local widget = require( "widget" )
local widgetExtras = require("libs.widget-extras")
local mui = require( "materialui.mui" )
local muiData = require( "materialui.mui-data" )
-- Set a default theme
widget.setTheme("widget_theme_ios7")

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

local class = require 'libs.middleclass'
local utility = require 'libs.utility'
--local Stateful = require 'libs.stateful'
--local inspect = require 'libs.inspect'
local colorHex = require('libs.convertcolor').hex
local util = require 'util'
local d = util.print_r
local _ = require 'libs.underscore'

-- Fonts
local fontDMFT = 'assets/fonts/DMFT1541427649707.ttf'
local fontSHSans = 'assets/fonts/SourceHanSansK-Regular.ttf'
local fontSHSansBold = 'assets/fonts/SourceHanSansK-Bold.ttf'
local fontMorganiteBook = 'assets/fonts/Morganite-Book-4.ttf'
local fontMorganiteSemiBold = 'assets/fonts/Morganite-SemiBold-9.ttf'
local fontZcoolHuangYou = 'assets/fonts/站酷庆科黄油体.ttf'

-- Functions
local function createIcon(options)
  local fontPath = "icon-font/"
  local materialFont = fontPath .. "MaterialIcons-Regular.ttf"
  options.font = materialFont
  options.text = mui.getMaterialFontCodePointByName(options.text)
  local icon = display.newText(options)
  return icon
end

local function dateFromString(timestr)
  local _time = utility.getTimeStamp(timestr)
  return os.date("!%Y-%m-%d", _time)
end

local function fitImage( displayObject, fitWidth, fitHeight, enlarge )
  --
  -- first determine which edge is out of bounds
  --
  local scaleFactor = fitHeight / displayObject.contentHeight 
  local newWidth = displayObject.contentWidth * scaleFactor
  if newWidth > fitWidth then
    scaleFactor = fitWidth / displayObject.contentWidth 
  end
  if not enlarge and scaleFactor > 1 then
    return
  end
  displayObject:scale( scaleFactor, scaleFactor )
end

-- ---
-- CLASSES Declaration
--
local View = require 'libs.view'
local RemoteImage = require 'libs.remote_image'
local Tag = require 'views.album_tag'
local Card = class('AlbumCardView', View)

local DateCard = class('DateCard', View)

function DateCard:initialize(dateStr, radius, x, y)
  View.initialize(self)
  self.radius = radius or 16
  self.x = x or cX
  self.y = y or cY
  local round = display.newCircle(0, 0, self.radius)
  round:setFillColor(colorHex('C7A680'))
  local timestamp = utility.getTimeStamp(dateStr)
  local date = os.date("%b %d", timestamp)
  --local month, day = date:match("(%w+)%s(%d+)")
  local dateTable = tostring(date):split(' ')
  --local year, month, day = date:match("(%d+)%-(%d+)%-(%d+)")
  local labelDay = display.newText {
      text = dateTable[2],
      x = 0, y = 12,
      font = fontSHSansBold,
      fontSize = 18,
      align = 'center'
    }
  local labelMonth = display.newText {
      text = string.upper(dateTable[1]),
      x = 0, y = -8,
      font = fontSHSans,
      fontSize = 15,
      align = 'center'
    }
  labelDay:setFillColor(0)
  labelMonth:setFillColor(0)
  self:_attach(round, 'bg')
  self:_attach(labelMonth, 'labelMonth')
  self:_attach(labelDay, 'labelDay')
  self.layer.anchorChildren = true
  self.layer.anchorX = .5
  self.layer.anchorY = .5
  self.layer.x = self.x
  self.layer.y = self.y
end

-- ---
--
function Card:initialize(opts, parent)
  d('-*-*-*-*-*-*-*-*-*-*-*-*-*-*')
  d('- Prototype of Card View -')
  d('- ======================== -')
  assert(type(opts) == 'table' and next(opts) ~= nil, "a named option hash table need to create a footer")
  self.name = opts.name or 'infoCard'-- timestamp
  View.initialize(self, parent)
  assert(self.layer, 'Card View Initialized Failed!')
  d('创建卡片对象: '..self.name)
  -- -------------------
  -- DATA BINDING
  self.barHeight = opts.barHeight or 64
  self.barWidth = opts.barWidth or vW
  self.excerpt = opts.excerpt
  self.publishDate = opts.created
  self.title = opts.title
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  local function panelTransDone( target )
    if ( target.completeState ) then
      --print( "PANEL STATE IS: "..target.completeState )
    end
  end
  -- Function to handle button events
  local function handleTabBarEvent( event )
    print( event.target.id )  -- Reference to button's 'id' parameter
  end
  local labelFont = fontSHSans
  local labelFontSize = 24
  local labelColor = { default={colorHex('6C6C6C')}, over={colorHex('C7A680')} }
  local onRelease = handleTabBarEvent

  local span = vW*.12
  local radius = span/math.sqrt(2)
  local leftPadding, topPadding = 20, 24
  
  local infoCard = display.newGroup()
  infoCard.anchorChildren = true
  infoCard.anchorX = 0
  infoCard.anchorY = 0.5
  local bg = display.newRect(infoCard, 0, 0, vW, vH*.36)
  bg:setFillColor(colorHex('1A1A19'))
  
  -- 标题
  local labelTitle = display.newText {
    parent = infoCard,
    text = self.title:gsub("%d+%.?", '', 3),
    x = bg.width*.05, y = topPadding + radius*.618,
    width = bg.width*.618, height = 0,
    font = fontZcoolHuangYou, fontSize = 26,
    align = 'left'
  }
  labelTitle.anchorX, labelTitle.anchorY = 0, 0
  local titleHeight = labelTitle.contentHeight
  self.titleYPos = labelTitle.y
  
  -- 介绍
  local excerptText = display.newText {
    parent = infoCard,
    text = self.excerpt,
    x = bg.width*.05, y = labelTitle.y + titleHeight + topPadding,
    width = bg.width*.9, height = 0,
    font = fontSHSans, fontSize = 16,
    align = 'left'
  }
  excerptText:setFillColor(colorHex('6C6C6C'))
  bg.anchorX, bg.anchorY = 0, 0
  excerptText.anchorX, excerptText.anchorY = 0, 0
  local textHeight = excerptText.height
  bg.height = textHeight + topPadding*4 + bottomInset + radius + titleHeight
  infoCard.x = -vW*.5
  
  -- 发布日期
  local dayBoard = DateCard:new(self.publishDate, radius, cX, 0)
  self:_attach(dayBoard)
  infoCard:insert(dayBoard.layer)
  
  -- 浏览量
  local labelViews = display.newText {
      text = opts.views,
      font = fontSHSans, fontSize = 16,
      x = vW*.94, y = topPadding,  
    }
  labelViews.anchorX = 1
  local iconViews = createIcon {
      x = vW - 60, y = topPadding - 4,
      text = 'visibility',
      fontSize = 18,
    }
  labelViews:setFillColor(colorHex('6C6C6C'))
  iconViews:setFillColor(colorHex('6C6C6C'))
  infoCard:insert(labelViews)
  infoCard:insert(iconViews)
  iconViews.x = labelViews.x - labelViews.contentWidth -12
  
  local panel = widget.newPanel{
    location = "bottom",
    onComplete = panelTransDone,
    width = self.barWidth,
    height = infoCard.contentHeight,
    speed = 300,
    inEasing = easing.outCubic,
    outEasing = easing.inCirc
  }
  panel:insert(infoCard)
  self:_attach(panel, 'panel')
  self:buildTags(opts.tags, 20, 12)
  --self:layoutTitle()
  self.hidden = true
  --self:show()
  -- END VISUAL INITIALIING
  -- -------------------
end

function Card:showMoters(moters)
--  local span = vW*.1
--  local radius = span/math.sqrt(2)
  local span = vW*.1
  local radius = span/math.sqrt(2)
  local leftPadding, topPadding = 20, 24
  local panel = self.elements.panel
  
  local function networkListener( event )
    if ( event.isError ) then
      print ( "Network error - download failed" )
      native.showAlert("网络错误!", "网络似乎开小差了，联网后重试!", { "好的" } )
      return false
    else
      local avatar = display.newGroup()
      avatar.anchorChildren = true
      avatar.anchorX = .5
      avatar.anchorY = .5
      local dataBoard = display.newRect(avatar, 0, 0, span + 4, span + 4)
      dataBoard:setFillColor(1, .9)
      local container = display.newContainer(avatar, span, span)
      dataBoard:rotate(45)
      container:rotate(45)
      container.anchorChildren = true
      container.anchorX = .5
      container.anchorY = .5
--      container.x = cX
--      container.y = cY
--      dataBoard.x = cX
--      dataBoard.y = cY
      local _image = event.target
      fitImage(_image, radius*2, span*2)
      _image.alpha = 0
      transition.to( _image, { alpha = 1, time = 300 } )
      _image._parent.baseDir = event.response.baseDirectory
      local layer = _image._parent.layer
      layer.rotation = -45
      container:insert(layer)
      panel:insert(avatar)
      avatar.x = vW*.36
      avatar.y = - panel.contentHeight*.5 + radius*2.5 + self.titleYPos
    end
    --self.fileName = event.response.filename
  end

  for i, moter in ipairs(moters) do
    local _id = moter._id
    local name = moter.name
    local avatarImgURI = "https://img.onvshen.com:85/girl/".._id.."/".._id..".jpg"
    local avatarFileName = _id.."_".._id..".jpg"
    local avatar = RemoteImage:new(avatarImgURI, RemoteImage.DEFAULT.METHOD, networkListener, avatarFileName, RemoteImage.DEFAULT.DIRECTORY, 0, 0)
    self:_attach(avatar)
  end
  
end

function Card:layoutTitle()
  local leftPadding, topPadding = 16, 8
  local infoCard = display.newGroup()
  infoCard.anchorChildren = true
  infoCard.anchorX = .5
  infoCard.anchorY = .5

  local labelTitle = display.newText {
    parent = infoCard,
    text = self.title,
    x = leftPadding, y = topPadding,
    width = vW*.618, height = 0,
    font = fontZcoolHuangYou, fontSize = 26,
    align = 'right'
  }
  labelTitle.anchorX, labelTitle.anchorY = 0, 0
  --labelTitle:setFillColor(colorHex('1A1A19'))

  local bg = display.newRect(infoCard, 0, 0, labelTitle.contentWidth + leftPadding*2, labelTitle.contentHeight + topPadding*2)
  bg.anchorX, bg.anchorY = 0, 0
  bg:setFillColor(colorHex('1A1A19'), 0)
  bg:toBack()

  --[[  
  local pubDateText = display.newText {
      parent = infoCard,
      text = self.publishDate,
      x = bg.width*.05, y = 5,
      width = bg.width*.9, height = 0,
      font = fontMorganiteSemiBold, fontSize = 20,
      align = 'left'
    }
  pubDateText.anchorX, pubDateText.anchorY = 0, 0
  ]]

  local panel = widget.newPanel{
    location = "right",
    --onComplete = panelTransDone,
    width = labelTitle.contentWidth + leftPadding*2,
    height = labelTitle.contentHeight + topPadding*2,
    speed = 300,
    inEasing = easing.outCubic,
    outEasing = easing.inCirc
  }
  panel:insert(infoCard)
  self:_attach(panel, 'titleBoard')
  panel.y = panel.y - 0.16*vH
end

function Card:buildTags(tags, left, top)
  local tagslider = display.newGroup()
  top = top or 0
  left = left or 20
  local panel = self.elements.panel
  for k, _tag in pairs(tags) do
    local tag = Tag:new(_tag, tagslider)
    tag.layer.x = left
    tag.layer.y = top
    left = left + tag.layer.contentWidth + 10
    tag:start()
    table.insert(self._elements, tag)
  end
  panel:insert(tagslider)
  tagslider.anchorChildren = true
  tagslider.anchorX = 0
  tagslider.anchorY = 1
  tagslider.x = -vW*.5 + vW*.05
  tagslider.y = panel.height*.5 - bottomInset - top
end

function Card:touch(event)
--  local id = event.target.id or event.target.parent.id
  local _t = event.target
  local id = _t.id
  if ( event.phase == "began" ) then
    display.getCurrentStage():setFocus( _t )
    _t.isFocus = true
    print( "Touch event began on: " .. event.target.id )
  elseif _t.isFocus then
    if ( event.phase == "ended" ) then
      print( "Touch event ended on: " .. event.target.id )
      if self.tabSelected == id then
        d('Tab already seleted')
      else
        self:selectTab(event.target.id)
      end
      display.getCurrentStage():setFocus( nil )
      _t.isFocus = false
    end
  end
  return true
end

function Card:tap(event)
--  stop any tap/touch propgation
  return true
end

function Card:show()
  if not self.hidden then return end
  self.hidden = false
  self.elements.panel:show()
  --self.elements.titleBoard:show()
end

function Card:hide()
  if self.hidden then return end
  self.hidden = true
  self.elements.panel:hide()
  --self.elements.titleBoard:hide()
end

function Card:toggle()
  if self.hidden then
    self:show()
  else
    self:hide()
  end
end

function Card:stop()
  d('Try to destroy Album Card')
  self:destroy()
end

return Card