-- Constants List:
local oX = display.screenOriginX
local oY = display.screenOriginY
local vW = display.viewableContentWidth
local vH = display.viewableContentHeight
local visibleAspectRatio = vW/vH

local class = require 'libs.middleclass'
--local Stateful = require 'libs.stateful'
--local inspect = require 'libs.inspect'
local colorHex = require('libs.convertcolor').hex
local util = require 'util'
local d = util.print_r

-- local forward references should go here --
local screenW, screenH, halfW, halfH = display.contentWidth, display.contentHeight, display.contentWidth*0.5, display.contentHeight*0.5
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight
local cX, cY = screenOffsetW + halfW, screenOffsetH + halfH

-- Fonts
local fontDMFT = 'assets/fonts/DMFT1541427649707.ttf'
local fontSHSans = 'assets/fonts/SourceHanSansK-Regular.ttf'
local fontSHSansBold = 'assets/fonts/SourceHanSansK-Bold.ttf'
local fontMorganiteBook = 'assets/fonts/Morganite-Book-4.ttf'
local fontMorganiteSemiBold = 'assets/fonts/Morganite-SemiBold-9.ttf'

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

--------------------- 
local function StringToTable(s)
  local tb = {}
  --[[
    UTF8的编码规则：
    1. 字符的第一个字节范围： 0x00—0x7F(0-127),或者 0xC2—0xF4(194-244); UTF8 是兼容 ascii 的，所以 0~127 就和 ascii 完全一致
    2. 0xC0, 0xC1,0xF5—0xFF(192, 193 和 245-255)不会出现在UTF8编码中 
    3. 0x80—0xBF(128-191)只会出现在第二个及随后的编码中(针对多字节编码，如汉字) 
    ]]
  for utfChar in string.gmatch(s, "[%z\1-\127\194-\244][\128-\191]*") do
    table.insert(tb, utfChar)
  end

  return tb
end

local function GetUTFLen(s)
  local sTable = StringToTable(s)

  local len = 0
  local charLen = 0

  for i=1,#sTable do
    local utfCharLen = string.len(sTable[i])
    if utfCharLen > 1 then -- 长度大于1的就认为是中文
      charLen = 2
    else
      charLen = 1
    end

    len = len + charLen
  end

  return len
end

local function GetUTFLenWithCount(s, count)
  local sTable = StringToTable(s)

  local len = 0
  local charLen = 0
  local isLimited = (count >= 0)

  for i=1,#sTable do
    local utfCharLen = string.len(sTable[i])
    if utfCharLen > 1 then -- 长度大于1的就认为是中文
      charLen = 2
    else
      charLen = 1
    end

    len = len + utfCharLen

    if isLimited then
      count = count - charLen
      if count <= 0 then
        break
      end
    end
  end

  return len
end

function util.GetMaxLenString(s, maxLen)
  local len = GetUTFLen(s)

  local dstString = s
  -- 超长，裁剪，加...
  if len > maxLen then
    dstString = string.sub(s, 1, GetUTFLenWithCount(s, maxLen))
    dstString = dstString.."..."
  end

  return dstString
end

local function snapTitle(title, maxLen)
  maxLen = maxLen or 34
  --title = title:gsub("%d+%.", '', 1)
  return util.GetMaxLenString(title, maxLen)
end
--------------------- 

-- ---
-- CLASSES Declaration
--
local View = require "libs.view"
local Cover = class('AlbumCoverView', View)
Cover.STATUS.RELEASED = 100

-- ---
-- Default Image File Cache Directory
-- TODO: Try to load cover image from this dir firstly
Cover.static.DEFAULT_DIRECTORY = system.CachesDirectory

function Cover:initialize(opts, parent)
  d('创建封面对象: '..opts.name)
  self.uri = opts.uri .. '.jpg'
  self.fileName = opts.name .. '.jpg'
  self.name = opts.name
  self.title = opts.title
  self.index = opts.index or 1
  self.id = opts.id
  View.initialize(self, parent)
  --self.layer:toFront()
  self.layer.anchorChildren = true
  self.layer.anchorY = 1
  -- =============================
end

-- ---
-- Preload Cover Image Display Object
--
function Cover:preload(row, col)
  if self.state > View.STATUS.INITIALIZED then
    d("Try to preload Cover already @ "..self.getState())
    return false
  end
  -- ------------------
  -- Block view while preloading image
  self.isBlocked = true
  self:signal('onImageLoad')
  -- Load image
  local scaleFactor = 0.42
  local _row = row
  local _col = col
  self.row = row
  self.col = col
  self.layer.x = oX + (vW*scaleFactor)*.618 + (_col-1)*(vW*scaleFactor*1.14)
  local function networkListener( event )
    if ( event.isError ) then
      print ( "Network error - download failed" )
      native.showAlert("网络错误!", "网络似乎开小差了，联网后重试!", { "好的" } )
      return false
    else
      local _image = event.target
      fitImage(_image, vW*scaleFactor, vH*scaleFactor)
      _image.alpha = 0
      self.imageTransiton = transition.to( _image, { alpha = 1, time = 1000 } )
      self:_attach(_image, 'image')
      self:send('onImageLoaded')
    end
    self.fileName = event.response.filename
    self.baseDir = event.response.baseDirectory
    -- When self is RELEASED by Parent View
    if self.state >= View.STATUS.PRELOADED then
      self:cleanup()
    else
      self:setState('PRELOADED')
      d('Start Cover '..self.name..' '..self:getState())
      self.isBlocked = false
      self:start()
    end
  end
  display.loadRemoteImage( self.uri, "GET", networkListener, self.fileName, Cover.DEFAULT_DIRECTORY, oX, oY)
end

function Cover:onImageLoaded()
  local cImage = self.elements.image
  if not cImage then return false end
  local bounds = cImage.contentBounds
  local boundRect = display.newRect(bounds.xMin, bounds.yMin, cImage.contentWidth, cImage.contentHeight)
  boundRect.strokeWidth = 5
  boundRect:setStrokeColor(colorHex('C7A680')) --golden
  self:_attach(boundRect)
  boundRect.x = cImage.x
  boundRect.y = cImage.y
  boundRect:toBack()
  -- ---------------------------
  local labelFSize = 12
  local label = display.newText {
    text = util.GetMaxLenString(self.title, 34),
    x = cX, y = cY, 
    fontSize = labelFSize, font = fontSHSansBold,
    width = cImage.contentWidth+4,
    align = 'Left'
  }
--  TODO: use label.height to limit text height
  local labelHeight = label.contentHeight
  if labelHeight >= labelFSize*3 then
    label.text = label.text:gsub("%d+%.", '', 1)
    if label.height >= labelFSize*3 then
      label.text = util.GetMaxLenString(self.title, 24)
    end
  elseif labelHeight < labelFSize*2.5 and labelHeight > labelFSize*1.5 then
    label.text = self.title
  elseif labelHeight < labelFSize*1.5 then
    label.text = self.title..' '..self.title
  end
  label:setFillColor(unpack(colorsRGB.RGBA('white', 0.9)))
  self:_attach(label, 'label')
  label.x = cImage.x
  label.y = cImage.y + cImage.contentHeight*.5 + label.contentHeight*.5 + 10
  self.layer.y = self.row*(self.layer.contentHeight + 10)
  self.parent.elements.slider:insert(self.layer)
  --self.layer.anchorChildren = true
end

-- ---
-- Begin to receive touch or tap events, then give reflection back properly
--
function Cover:start()
--{{{
  d('Try to start Cover '..self.name..' @ '..self:getState())
  if (self.state < View.STATUS.PRELOADED) or self.isBlocked then
    d(self.name .. ' is Not Ready to Start!')
    return false
  elseif (self.state >= View.STATUS.STARTED) then
    d(self.name .. ' already Started!')
    return false
  end
  if (self.state <= View.STATUS.STOPPED) then
    --self:unblock()
  end
  -- Add touch event handler
  self.layer:addEventListener('touch', self)
  self.layer:addEventListener('tap', self)
  self:setState('STARTED')
--}}}
end

function Cover:tap(tap)
  d('Open album: '..self.title)
  self:signal('onCoverTapped', {album_id = self.id, title = self.title})
end

return Cover
