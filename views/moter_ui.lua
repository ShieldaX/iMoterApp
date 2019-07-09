local composer = require( "composer" )
-- Constants List:
local oX = display.screenOriginX
local oY = display.screenOriginY
local vW = display.viewableContentWidth
local vH = display.viewableContentHeight
require("mobdebug").start()
local class = require 'libs.middleclass'
local Stateful = require 'libs.stateful'
local inspect = require 'libs.inspect'
local colorHex = require('libs.convertcolor').hex

local util = require 'util'
local d = util.print_r
--util.show_fps()

-- local forward references should go here --
local screenW, screenH, halfW, halfH = display.contentWidth, display.contentHeight, display.contentWidth*0.5, display.contentHeight*0.5
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight
local cX, cY = screenOffsetW + halfW, screenOffsetH + halfH

-- 将图片自适应屏幕宽度
local function fitScreenW(p, top, bottom)
	top = top or 0
	bottom = bottom or 0
	local h = viewableScreenH-(top+bottom)
	if p.width > viewableScreenW or p.height > h then
		if p.width/viewableScreenW > p.height/h then
				p.xScale = viewableScreenW/p.width
				p.yScale = viewableScreenW/p.width
		else
				p.xScale = h/p.height
				p.yScale = h/p.height
		end
	end
	p.x = screenW*.5
	p.y = h*.5
end
-- ---
-- Resize Image Display Object to Fit Screen WIDTH
--
function util.fitWidth(obj, W)
  local scaleFactor = W/obj.width
  obj.width = obj.width*scaleFactor
  obj.height = obj.height*scaleFactor
end

-- Classes
local View = require 'libs.view'
local Piece = require 'views.piece'
local Indicator = require 'views.indicator'
local Moter = class('MoterView', View)
local APP = require("classes.application")

local LayoutManager = require( "libs.layout" )
-- layout manager object
local Layout = LayoutManager:new()

-- Group to hold rects that display the regions
local Regions

-- Content grid size; change these to change the size of the generated grid
local ContentGridSize = 4
local GridPixelPadding = 8


local function makeTimeStamp(dateStringArg)
	
	local inYear, inMonth, inDay, inHour, inMinute, inSecond, inZone =      
  string.match(dateStringArg, '^(%d%d%d%d)-(%d%d)-(%d%d)T(%d%d):(%d%d):(%d%d)(.-)$')

	local zHours, zMinutes = string.match(inZone, '^(.-):(%d%d)$')
		
	local returnTime = os.time({year=inYear, month=inMonth, day=inDay, hour=inHour, min=inMinute, sec=inSecond, isdst=false})
	
	if zHours then
		returnTime = returnTime - ((tonumber(zHours)*3600) + (tonumber(zMinutes)*60))
	end
	
	return returnTime
	
end

local zodiacList = {'猪', '鼠', '牛', '虎', '兔', '龙', '蛇', '马', '羊', '猴', '鸡', '狗'}
local function DOB2AgeZodiacAstro(birthday)
  local xyear, xmonth, xday = birthday:match("(%d+)%-(%d+)%-(%d+)")
  local currentDate = os.date("!%Y-%m-%d")
  local yyear, ymonth, yday = currentDate:match("(%d+)%-(%d+)%-(%d+)")
  local yearElapsed, _month, _day = yyear - xyear, ymonth - xmonth, yday - xday
  -- -------------------Age----------------- --
  local age = yearElapsed
  if _month < 0 then -- current month: 7, birth month: 8
    age = age - 1
  elseif _month == 0 then
    if _day < 0 then age = age -1 end
  end
  d('Age: '..age)
  -- -----------------Zodiac---------------- --
  local _animalRange = math.fmod((xyear - 4), 12)
  local zodiac = zodiacList[_animalRange+1]
  d('Zodiac: '..zodiac)
  -- -----------Astrological Sign----------- --
  local astroSign
  local dmonth, dday = tonumber(xmonth), tonumber(xday)
  if (dmonth == 12) then
    astroSign = dday < 22 and '射手' or '摩羯'
  elseif dmonth == 1 then
    astroSign = dday < 20 and '摩羯' or '水瓶'
  elseif dmonth == 2 then
    astroSign = dday < 19 and '水瓶' or '双鱼'
  elseif dmonth == 3 then
    astroSign = dday < 21 and '双鱼' or '白羊'  
  elseif dmonth == 4 then
    astroSign = dday < 20 and '白羊' or '金牛'
  elseif dmonth == 5 then
    astroSign = dday < 21 and '金牛' or '双子'
  elseif dmonth == 6 then
    astroSign = dday < 21 and '双子' or '巨蟹'
  elseif dmonth == 7 then
    astroSign = dday < 23 and '巨蟹' or '狮子'
  elseif dmonth == 8 then
    astroSign = dday < 23 and '狮子' or '室女'
  elseif dmonth == 9 then
    astroSign = dday < 23 and '室女' or '天秤'
  elseif dmonth == 10 then
    astroSign = dday < 23 and '天秤' or '天蝎'
  elseif dmonth == 11 then
    astroSign = dday < 22 and '天蝎' or '射手'
  end
  d('Astrological Sign: '..astroSign)
  return age, zodiac, astroSign
  --return os.time({year = xyear, month = xmonth, day = xday, hour = 0, min = 0, sec = 0})
end

local function parseBirthday(birthday)
  local _time = makeTimeStamp(birthday)
  return os.date("!%Y-%m-%d", _time)
end

local function animate(displayObj, direction, delay)
  local _time = 800
  direction = direction or 'bottom'
  local _from
  if direction == 'left' or direction == 'right' then
    _from = direction == 'left' and -1 or 1
    local contentW = displayObj.contentWidth
    displayObj.animation = transition.from(displayObj, {delay = delay, time = _time, x = displayObj.x+(contentW*_from), alpha = 0, transition = easing.outBack})
  else
    _from = direction == 'top' and -1 or 1
    local contentH = displayObj.contentHeight
    displayObj.animation = transition.from(displayObj, {delay = delay, time = _time, y = displayObj.y+(contentH*_from), alpha = 0, transition = easing.outBack})
  end
end

-- 利用获取的图集信息实例化一个图集对象
function Moter:initialize(obj, sceneGroup)
  d('-*-*-*-*-*-*-*-*-*-*-*-*-*-*')
  d('- Prototype of Moter View -')
  d('- ======================== -')
  View.initialize(self, sceneGroup)
  -- -------------------
  -- DATA BINDING
  self.rawData = obj
  self.name = obj._id
  local _id = obj._id
  self.avatarImgURI = "https://img.onvshen.com:85/girl/".._id.."/".._id..".jpg"
  self.avatarFileName = _id.."_".._id..".jpg"
  --APP.CurrentMoter = self
  -- END DATA BINDING
  -- -------------------
  -- VISUAL INITIALIING
  local _bg = display.newRect(oX, oY, vW, vH*(1-0.618))
  _bg:setFillColor(colorHex('1A1A19'))
  _bg.anchorY = 1
  _bg.x = cX; _bg.y = vH
  self:_attach(_bg, 'bg')
  self.parentBG = sceneGroup[1]
  -- END VISUAL INITIALIING
  self:preload()
end

-- ---------------
-- 资源预加载，在scene:create时预先调用
function Moter:preload()
  if self.state > View.STATUS.INITIALIZED then
    d("Try to preload Moter already @ "..self.getState())
    return false
  end
  -- Load remote image
	local function networkListener( event )
    if ( event.isError ) then
      print ( "Network error - download failed" )
      return false
    else
      local _image = event.target
      util.fitWidth(_image, vW) --横占屏幕
      --_image.alpha = 0
      util.center(_image)
      _image.y = _image.contentHeight*.5 -- 置于顶部
      --self.animation = transition.to( _image, { time = 500, alpha = 1, y = _image.contentHeight*.5 + vH*.1, transition = easing.outExpo} )
      self:_attach(_image, 'avatar')
      _image:toBack()
    end
    self.baseDir = event.response.baseDirectory
    self:setState('PRELOADED')
    self:signal('onAavatrLoaded')
    if not self.isBlocked then
      d('Start Moter View '..self.name..' '..self:getState()..' and Not Blocked')
      self:start() --self:layout()
    else
      d(self.name .. ' ' .. self:getState())
    end
	end
  display.loadRemoteImage( self.avatarImgURI, "GET", networkListener, {progress = false}, self.avatarFileName, Piece.DEFAULT_DIRECTORY, oX, oY)
end

-- -----------------
-- 使用数据以及资源填充页面 with 排版布局
function Moter:layout()
  local fontDMFT = 'assets/fonts/DMFT1541427649707.ttf'
  local fontSHSans = 'assets/fonts/SourceHanSansK-Regular.ttf'
  --d(inspect(native.getFontNames()))
  local _data = self.rawData
  -- ==============================
  -- TITLE SECTION
  local labelG = display.newGroup()
  --labelG.anchorChildren = true
  local labelBG = display.newRoundedRect(labelG, oX, oY, vW*.42, vH*.3, 2)
  labelBG:setFillColor(colorHex('222222', .99))
  labelBG.strokeWidth = 1; labelBG:setStrokeColor(colorHex('333333', 0.5))
  local padding = 28
  local names, name = _data.names
  names = names or {}
  if names.cn and names.en then
    name = names.cn..','..names.en
  elseif names.cn then
    name = names.cn
  elseif names.en then
    name = names.en
  else
    name = _data.name
  end
  APP.Header.elements.TopBar:setLabel(name)
  local age, zodiac, astroSign
  if _data.birthday then
    age, zodiac, astroSign = DOB2AgeZodiacAstro(_data.birthday)
  end
  local labelNameAge = display.newText {text = _data.name..(age and ','..age or ''), x = 0, y = 0, fontSize = 22, font = fontDMFT}
  local bounds = labelBG.contentBounds
  labelNameAge.x = bounds.xMin + labelNameAge.width*.5 + padding*.5; labelNameAge.y = bounds.yMin+padding
  labelG:insert(labelNameAge)
  labelG.x, labelG.y = oX+labelBG.width*.6, self.elements.bg.contentBounds.yMin-labelBG.height*.2
  -- ==============================
  local sperateLine = display.newLine(labelG, bounds.xMin+padding*.5, labelNameAge.y+padding, bounds.xMax-padding*.5, labelNameAge.y+padding)
  sperateLine:setStrokeColor(colorHex('333333')); sperateLine.strokeWidth = 2
  -- ==============================
  -- DATA INFO SECTION
  local labelHW, labelBirthPlace
  local leftPadding = bounds.xMin+padding*.5
  if _data.height or _data.weight then
    local HW = (_data.height and _data.height .. 'CM  ' or '') .. (_data.weight and _data.weight .. 'KG' or '')
    labelHW = display.newText {text = HW, x = leftPadding, y = sperateLine.y + padding*.5, fontSize = 14, font = fontSHSans}
    labelHW:setFillColor(colorHex('C7A680'))
    labelHW.anchorX, labelHW.anchorY = 0, 0
    labelG:insert(labelHW)
  end
  
  local measure = _data.measure and next(_data.measure) and 'B'.._data.measure.bust..' '..'W'.._data.measure.waist..' '..'H'.._data.measure.hips or ''
  local infoText = measure
  infoText = infoText..(_data.country and '\n'.._data.country..' ' or '') .. (_data.birthplace and _data.birthplace or '')

  infoText = infoText..(_data.career and '\n'..table.concat(_data.career, ' ') or '')
  
  infoText = infoText..(_data.hobbies and '\n'..table.concat(_data.hobbies, ' ') or '')
  
  local labelInfo = display.newText {text = infoText,  x = leftPadding, y = labelHW.y + padding*.6, fontSize = 14, font = fontSHSans}
  labelInfo:setFillColor(colorHex('C7A680'))
  labelInfo.anchorX, labelInfo.anchorY = 0, 0
  labelG:insert(labelInfo)
  
  local labelBioCap = display.newText {text = '详情资料', x = 0, y = 0, fontSize = 20, font = fontDMFT}
  local labelBio = display.newText {text = _data.bio,  width = vW*.9, x = leftPadding, y = labelHW.y + padding*.6, fontSize = 14, font = fontSHSans}
  labelBioCap:setFillColor(colorHex('C7A680'))
  labelBio:setFillColor(colorHex('6C6C6C'))
  labelBioCap.anchorX, labelBioCap.anchorY = 0, 0
  labelBio.anchorX, labelBio.anchorY = 0, 0
  local bg = self.elements.bg
  labelBioCap.x, labelBioCap.y = 15, bg.y - bg.height + padding*2.6
  labelBio.x, labelBio.y = 15, labelBioCap.y + padding*1.3
  self:_attach(labelBioCap)
  self:_attach(labelBio)
  
  local favBtnG = display.newGroup()
  local favoriteIcon = util.createIcon {
      name = "plus",
      text = "favorite",
      width = 28,
      height = 28,
      x = cX, y = vH*.9,
      isFontIcon = true,
      textColor = { 0.25, 0.75, 1, 1 }
    }
  favoriteIcon:setFillColor(unpack(colorsRGB.RGBA('white', 1)))
  util.center(favoriteIcon)
  favoriteIcon.x = vW*.8
  favoriteIcon.y = bg.y - bg.height
  local btnCircle = display.newCircle(favoriteIcon.x, favoriteIcon.y, 28)
  btnCircle:setFillColor(colorHex('1B1B19'))
  btnCircle:setStrokeColor(colorHex('BB9F7D'))
  btnCircle.alpha = 0.96
  btnCircle.strokeWidth = 2
  local btnCircleDeco = display.newCircle(favoriteIcon.x, favoriteIcon.y, 36)
  btnCircleDeco:setFillColor(colorHex('1B1B19'))
  btnCircleDeco:setStrokeColor(colorHex('BB9F7D'))
  btnCircleDeco.alpha = 0.4
  btnCircleDeco.strokeWidth = 1
  favBtnG:insert(btnCircleDeco)
  favBtnG:insert(btnCircle)
  favBtnG:insert(favoriteIcon)
end

function Moter:start()
  if self.state == 30 then return false end
  local e = self._elements
  --[[
  for i, element in ipairs(e) do
    if i > 1 then
      animate(element, 'top', i*100)
    else
      transition.from(element, {time = 1000, transition = easing.outBack, height = element.height*.9})
    end
  end
  ]]
  self:setState('STARTED')
end

function Moter:stop()
  self:cleanup()
end

return Moter