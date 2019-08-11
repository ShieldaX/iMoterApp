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
local Stateful = require 'libs.stateful'
local inspect = require 'libs.inspect'
local colorHex = require('libs.convertcolor').hex
local util = require 'util'
local d = util.print_r

-- Fonts
local fontDMFT = 'assets/fonts/DMFT1541427649707.ttf'
local fontSHSans = 'assets/fonts/SourceHanSansK-Regular.ttf'
local fontSHSansBold = 'assets/fonts/SourceHanSansK-Bold.ttf'
local fontMorganiteBook = 'assets/fonts/Morganite-Book-4.ttf'
local fontMorganiteSemiBold = 'assets/fonts/Morganite-SemiBold-9.ttf'

--------------------- 
local function StringToTable(s)
  local tb = {}
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

--------------------- 
-- ---
-- CLASSES Declaration
--
local View = require "libs.view"
local Tag = class('AlbumTagView', View)

function Tag:initialize(opts, parent)
--  d('创建标签对象: '..opts.name)
  self.name = opts._id
  self.id = opts.name
  View.initialize(self, parent)
  -- -------------------
  -- DATA BINDING
  self.cornerRadius = opts.radius or 12
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  local padding = 6
  local fontSize = 12
  local _text = display.newText { text = self.id, x = 0, y = 0, fontSize = fontSize, align = 'center', font = fontSHSansBold }
  --_text.anchorY = 1
  _text:setFillColor(colorHex('1A1A19'))
  _text.y = _text.y + padding*.4
  local _bg_width, _bg_height = _text.width + padding*3, _text.height + padding
  local _bg = display.newRoundedRect(0, 0, _bg_width, _bg_height, self.cornerRadius)
  _bg:setFillColor(colorHex('C7A680')) -- Golden
  self:_attach(_bg, '_bg')
  self:_attach(_text, '_text')
  self.layer.anchorChildren = true
  self.layer.anchorX = 0
  self.layer.anchorY = 1
  -- END VISUAL INITIALIING
  -- -------------------
end

-- ---
-- Begin to receive touch or tap events, then give reflection back properly
--
function Tag:start()
--{{{
--  d('Try to start Tag '..self.name..' @ '..self:getState())
  if (self.state >= View.STATUS.STARTED) then
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

function Tag:tap(tap)
  transition.cancel(self.animation)
  self.layer.alpha = 1
  self.animation = transition.to(self.layer, {time = 200, transition = easing.continuousLoop, alpha = .5})
  d('Open album List by Tag: '..self.id)
  self:signal('onTagTapped', {id = self.name, name = self.id})
end

function Tag:cleanup()
  View.cleanup(self)
end

return Tag