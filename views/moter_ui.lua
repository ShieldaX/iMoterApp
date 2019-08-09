local composer = require( "composer" )
-- Constants List:
local oX = display.screenOriginX
local oY = display.screenOriginY
local vW = display.viewableContentWidth
local vH = display.viewableContentHeight
--require("mobdebug").start()
local class = require 'libs.middleclass'
local mui = require( "materialui.mui" )
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
local topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()

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

local function createLabel(opts)
  local text = opts.text
  if not text then return end
  local label = display.newGroup()
  local padding = opts.padding or 6
  local fontSize = opts.fontSize or 12
  local cornerRadius = opts.cornerRadius or 12
  local x, y = opts.x or cX, opts.y or cY 
  local _text = display.newText { text = text, x = 0, y = 0, fontSize = fontSize, align = 'center', font = fontSHSansBold }
  _text:setFillColor(colorHex('1A1A19'))
  _text.y = _text.y + padding*.4
  local _bg_width, _bg_height = _text.width + padding*3, _text.height + padding
  local _bg = display.newRoundedRect(0, 0, _bg_width, _bg_height, cornerRadius)
  _bg:setFillColor(colorHex('C7A680')) -- Golden
  label:insert(_bg)
  label:insert(_text)
  label.anchorChildren = true
  label.anchorX = .5
  label.anchorY = 1
  return label
end

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
local StarRating = require 'views.star_rating'
local Moter = class('MoterView', View)
Moter:include(Stateful)
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

local function getPreciseDecimal(nNum, n)
  if type(nNum) ~= "number" then
    return nNum
  end
  n = n or 0;
  n = math.floor(n)
  if n < 0 then
    n = 0
  end
  local nDecimal = 10 ^ n
  local nTemp = math.floor(nNum * nDecimal);
  local nRet = nTemp / nDecimal;
  return nRet
end

local function readableNumber(num)
  if type(num) == 'string' then num = tonumber(num) end
  local digit
  if num >= math.pow(10, 4) then
    digit = getPreciseDecimal(num*math.pow(0.1, 4), 1)
    d(digit .. '万')
    return digit .. '万'
  elseif num >= math.pow(10, 3) then
    digit = getPreciseDecimal(num*math.pow(0.1, 3), 1)
    d(digit)
    return digit .. '千'
  else
    d(digit)
    digit = num
    return digit
  end
end

local zodiacList = {'鼠', '牛', '虎', '兔', '龙', '蛇', '马', '羊', '猴', '鸡', '狗', '猪'}
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

local function getAstroCode(astroName)
  local astroTalbe = {'白羊', '金牛', '双子', '巨蟹', '狮子', '室女', '天秤', '天蝎', '射手', '摩羯', '水瓶', '双鱼'}
  local alphabet = 'EFGHIJKLMNOP'
  local index = table.indexOf(astroTalbe, astroName)
  if not index then return false end
  return alphabet:sub(index, index)
end

local function getZodiacCode(zodiacName)
  local alphabet = 'abcdefghijkl'
  local index = table.indexOf(zodiacList, zodiacName)
  if not index then return false end
  return alphabet:sub(index, index)
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

local function ratingStars(score)
  local score2Local = score*.5
  d('Local score: '..score2Local)
  --local halfAt = score2Local - math.floor(score2Local) > 0 and math.floor(score2Local)
  for i=1, 5, 1 do
    print(i)
    if score2Local > i then
      d('create star')
    elseif score2Local < i and math.ceil(score2Local) == i then
      d('create star_half')
    else
      d('create star_border')
    end
    --util.createIcon('star')
  end
end

local function resolveNames(names, name)
  names = names or {}
  if names.cn and names.en then
    name = names.cn..', '..names.en
  elseif names.cn then
    name = names.cn
  elseif names.en then
    name = names.en
  end
  return name
end

-- 利用获取的图集信息实例化一个图集对象
function Moter:initialize(data, sceneGroup)
  d('-*-*-*-*-*-*-*-*-*-*-*-*-*-*')
  d('- Prototype of Moter View -')
  d('- ======================== -')
  View.initialize(self, sceneGroup)
  -- -------------------
  -- DATA BINDING
  self.rawData = data.moter
  local obj = self.rawData
  self.name = obj._id
  local _id = obj._id
  data.avatar = nil
  if data.avatar then
    self.avatarImgURI = "https://t1.onvshen.com:85/gallery/".._id.."/"..data.avatar.."/0.jpg"
    self.avatarFileName = _id.."_"..data.avatar.."_0.jpg"
  else
    self.avatarImgURI = "https://img.onvshen.com:85/girl/".._id.."/".._id..".jpg"
    self.avatarFileName = _id.."_".._id..".jpg"
  end
  --APP.CurrentMoter = self
  -- END DATA BINDING
  -- -------------------
  -- VISUAL INITIALIING
  local _bg = display.newRect(oX, oY, vW, vH*.36)
  _bg:setFillColor(colorHex('1A1A19'))
  _bg.anchorY = 1
  _bg.x = cX
  _bg.y = vH
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
      _image.y = _image.contentHeight*.5 + topInset + 20 -- 置于顶部
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
  display.loadRemoteImage( self.avatarImgURI, "GET", networkListener, {progress = false}, self.avatarFileName, Piece.DEFAULT_DIRECTORY, oX, oY + topInset)
end

-- -----------------
-- 使用数据以及资源填充页面 with 排版布局
function Moter:layout()
  self.layer.alpha = 0
  --d(inspect(native.getFontNames()))
  local _data = self.rawData
  d(_data)
  -- ==============================
  -- TITLE SECTION
  local name = resolveNames(_data.names, _data.name)
  
  --local ratingStars = _data.score and StarRating(_data.score.count, {name = 'stars', fillColor = colorsRGB.RGBA('gold'), iconSize = 20})
  --util.center(ratingStars.layer)

  local labelG = display.newGroup()
--  local labelScore = _data.score and display.newText{text = _data.score.count, x = vW-50, y = self.elements.bg.y-80, fontSize = 50}
--  if labelScore then labelScore:setFillColor(unpack(colorsRGB.RGBA('gold', .9))) end

  local labelBG = display.newRoundedRect(labelG, oX, oY, vW*.42, vH*.3, 2)
  labelBG:setFillColor(colorHex('222222', .99))
  labelBG.strokeWidth = 1; labelBG:setStrokeColor(colorHex('333333', 0.5))
  labelBG.anchorY = 0
  --labelBG.y = labelBG.y - labelBG.height*.5

  local padding = 28
  local rowY = padding
  
  local age, zodiac, astroSign
  if _data.birthday then
    age, zodiac, astroSign = DOB2AgeZodiacAstro(_data.birthday)
  end
  local labelNameAge = display.newText {
--      text = _data.name..(age and ', '..age or ''),
      text = age and age..'('..astroSign..')' or _data.name,
      x = 0, y = 0,
      --width = labelBG.width*.9,
      fontSize = 20, font = fontDMFT
    }
  local bounds = labelBG.contentBounds
  labelNameAge.x = bounds.xMin + labelNameAge.width*.5 + padding*.5
  labelNameAge.y = bounds.yMin+rowY
  rowY = labelNameAge.y
  labelG:insert(labelNameAge)

  -- ==============================
  local sperateLine = display.newLine(labelG, bounds.xMin+padding*.5, labelNameAge.y+padding, bounds.xMax-padding*.5, rowY+padding)
  rowY = sperateLine.y
  sperateLine:setStrokeColor(colorHex('333333')); sperateLine.strokeWidth = 2
  -- ==============================
  -- DATA INFO SECTION
  local leftPadding = bounds.xMin+padding*.5
  local HW = (_data.height and _data.height .. 'CM  ' or '') .. (_data.weight and _data.weight .. 'KG' or '')
  local infoText = HW:len() > 0 and HW..'\n' or ''
  local measure = _data.measure and next(_data.measure) and 'B'.._data.measure.bust..' '..'W'.._data.measure.waist..' '..'H'.._data.measure.hips or ''
  measure = measure:len() > 0 and measure..'\n' or ''
  infoText = infoText..measure
  
  infoText = infoText..(_data.country and _data.country..' ' or '') .. (_data.birthplace and _data.birthplace or '')

  infoText = infoText..(_data.career and '\n'..table.concat(_data.career, ' ') or '')

  infoText = infoText..(_data.hobbies and '\n'..table.concat(_data.hobbies, ' ') or '')

  local labelInfo = display.newText {
      text = infoText,
      x = leftPadding, y = rowY + padding*.5,
      width = labelBG.width*.8,
      fontSize = 14, font = fontSHSans
    }
  labelInfo:setFillColor(colorHex('C7A680'))
  labelInfo.anchorX, labelInfo.anchorY = 0, 0
  labelG:insert(labelInfo)
  --labelG:insert(ratingStars.layer)
  d('======================')
  --ratingStars.layer.x = sperateLine.x + ratingStars.layer.contentWidth*.5
  --ratingStars.layer.y = sperateLine.y
  --self.stars = ratingStars
  rowY = labelInfo.y
  -- ==============================
  -- BIO DESC SECTION
  local labelBioCap = display.newText {text = '详情资料', x = 0, y = 0, fontSize = 20, font = fontDMFT}
  local labelBio = display.newText {text = _data.bio,  width = vW*.92, x = leftPadding, y = rowY + padding*.6, fontSize = 14, font = fontSHSans}
  labelBioCap:setFillColor(colorHex('C7A680'))
  labelBio:setFillColor(colorHex('6C6C6C'))
  labelBioCap.anchorX, labelBioCap.anchorY = 0, 0
  labelBio.anchorX, labelBio.anchorY = 0, 0
  local bg = self.elements.bg
  labelBioCap.x, labelBioCap.y = 15, bg.y - bg.height + padding*3
  labelBio.x, labelBio.y = 15, labelBioCap.y + padding*1.1
  self:_attach(labelG, 'capCard')
  self:_attach(labelBioCap)
  self:_attach(labelBio, 'labelBio')
  -- ---------------------------------
  if _data.birthday then
    local goldenColor = {colorHex('6C6C6C')}
    local birthG = display.newGroup()
    local labelBirthday = display.newText{text = parseBirthday(_data.birthday), x = cX, y = cY, fontSize = 25, font = fontMorganiteSemiBold}
    labelBirthday:setFillColor(unpack(goldenColor))
    --labelBirthday.anchorY = 1
    labelBirthday.x, labelBirthday.y = vW-50, self.elements.bg.y-48
    birthG:insert(labelBirthday)
    local zodiacIcon
    if zodiac then
      zodiacIcon = display.newText{text = getZodiacCode(zodiac), x = vW-50, y = self.elements.bg.y-50, fontSize = 24, align = "center", font = "assets/fonts/Chinese Zodiac.ttf"}
      zodiacIcon:setFillColor(unpack(goldenColor))
      --zodiacIcon.anchorY = 1
      zodiacIcon.x = labelBirthday.contentBounds.xMax + zodiacIcon.contentWidth*.8
      birthG:insert(zodiacIcon)
    end
    local astroIcon
    if astroSign then
      astroIcon = display.newText{text = getAstroCode(astroSign), x = vW-50, y = self.elements.bg.y-50, fontSize = 25, align = "center", font = "assets/fonts/華康星座篇.ttf"}
--      astroIcon:setFillColor(unpack(goldenColor))
      astroIcon:setFillColor(unpack(goldenColor))
      --astroIcon.anchorY = 1
      astroIcon.x = zodiacIcon.contentBounds.xMax + astroIcon.contentWidth*.6
      birthG:insert(astroIcon)
    end
    --if zodiacIcon and astroIcon then astroIcon.x = zodiacIcon.x + astroIcon.width end
    birthG.anchorChildren = true
    birthG.anchorX = 1

    birthG.y = labelBioCap.y + birthG.contentHeight*.5
    birthG.x = vW - padding*.36
    self:_attach(birthG)
  end
  -- ---------------------------------
  -- Reheight and reposition capCard to fit full-screened phones
  local crossCut = labelBG.contentBounds.yMax - (labelInfo.contentBounds.yMax+2)
  labelBG.height = labelBG.height - crossCut + padding*.5
  -- ------------------------------
  --labelG.anchorChildren = true
  labelG.x = oX+labelBG.width*.6 --actual 0.1 labelBG width offset oX
  labelG.y = self.elements.bg.contentBounds.yMin - labelG.contentHeight*.618
  
  local favBtnG = display.newGroup()
  local favoriteIcon = util.createIcon {
    text = "favorite",
    width = 25,
    height = 25,
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
  btnCircle:setStrokeColor(colorHex('ad7d7e'))
  btnCircle.alpha = 0.96
  btnCircle.strokeWidth = 2
  local btnCircleDeco = display.newCircle(favoriteIcon.x, favoriteIcon.y, 36)
  btnCircleDeco:setFillColor(colorHex('1B1B19'))
  btnCircleDeco:setStrokeColor(colorHex('ad7d7e'))
  btnCircleDeco.alpha = 0.4
  btnCircleDeco.strokeWidth = 1
  favBtnG:insert(btnCircleDeco)
  favBtnG:insert(btnCircle)
  favBtnG:insert(favoriteIcon)

  self:_attach(favBtnG, 'favBtnG')
  
  self:hintMore()
end

function Moter:start()
  if self.state == 30 then return false end
  self.layer.alpha = 1
  local e = self._elements

  for i, element in ipairs(e) do
    if i > 1 then
      animate(element, 'bottom', i*100)
    else
      transition.from(element, {time = 1000, transition = easing.outBack, height = element.height*.6})
    end
  end
  --timer.performWithDelay(1000, function() self.stars:animate() end)
  self:signal('onMoterLoaded')

  local green = {colorHex('33ffbb')}
  local blue = {colorHex('3399ff')}
  local gold = {colorHex('ad7d7e')}
  local _T_ = colorsRGB.RGBA('white', 0) -- Total Transparent

  local function pulse2(x, y, color, scale1, scale2, delay, time, parentG)
    local circle = display.newCircle(parentG, x, y, 20)
    circle:setFillColor(unpack(color))
    local effect1 = display.newCircle(parentG, x, y, 20)
    effect1:setFillColor(unpack(color))
    effect1.alpha = 0.4
    transition.to(effect1, {xScale = scale1, yScale = scale1, time = time + delay})
    transition.to(effect1, {alpha = 0, delay = delay, time = time, onComplete = display.remove})
    local effect2 = display.newCircle(parentG, x, y, 20)
    effect2:setFillColor(unpack(_T_))
    effect2:setStrokeColor(unpack(color))
    effect2.strokeWidth = 3
    transition.to(effect2, {xScale = scale2, yScale = scale2, time = time + delay})
    transition.to(effect2, {alpha = 0, strokeWidth = 0, delay = delay, time = time, onComplete = display.remove})
  end
  self.pulse = pulse2

  local scale1 = 2
  local scale2 = 4
  local favBtnG = self.elements.favBtnG
  local favIcon = favBtnG[1]
  local effectG = display.newGroup()

  favBtnG.effectG = effectG
  favBtnG:insert(effectG)
  effectG:toBack()
  effectG.x, effectG.y = favIcon.x, favIcon.y

  local function tapListener(tap)
    self:send('onLikeTapped', tap)
  end
  favIcon:addEventListener('tap', tapListener)

  self.layer:addEventListener('touch', self)
  self:setState('STARTED')
end

function Moter:touch(event)
--{{{
  local _t = event.target
  local phase = event.phase
  --began
  if ('began' == phase) then
    display.getCurrentStage():setFocus( _t )
    _t.isFocus = true
    _t.yStart = _t.y
    _t.tStart = event.time
    --t.tLast = event.time
    _t.motion = 0
    --_t.speed = 0
    _t.direction = 0
    _t.flick = false
    --focus
    --self:blurGaussian()
  elseif _t.isFocus then
    --moved
    if ('moved' == phase) then
      _t.tLast = event.time
      -- Distence passed by touch
      _t.motion = event.y - event.yStart

      -- Detect switching direction then load Right Next Piece in Memory, Painting...
      local limitMin, limitMax = 5, 100
      if _t.motion > limitMin and _t.direction >= 0 then
        _t.direction = -1
      elseif _t.motion < -limitMin and _t.direction <=0 then
        _t.direction = 1
      end
      --self:distort(_t.direction)
      -- Sync View's Layer
      local limitFactor = .2
      local avatar = self.elements.avatar
      local hint = self.elements.hint
      if math.abs(_t.motion) >= vH*.0006 then
        local _multi = math.abs(_t.motion)/vH
        _multi = _multi >= limitFactor and limitFactor or _multi
--        self:gotoState('reachBottomLimit')
        if _t.direction > 0 then self:blurGaussian(_multi*6) end
        local _scale = 1+_multi*.6
        avatar.xScale, avatar.yScale = _scale, _scale
        if _t.motion < 0 then hint.alpha = _multi*6 end
        if hint.alpha == 1 then
          hint.animation = transition.to(hint[3], {time = 200, transition = easing.outExpo, rotation = 0})
          hint[1].text = ' 释 放 '
          self.shouldFlip = true
          d('释放!以查看女神图集列表...')
        else
          transition.cancel(hint.animation)
          hint[3].rotation = 180
          hint[1].text = ' 上 拉 '
          self.shouldFlip = false
        end
      else
        self:blurGaussian(0)
        avatar:scale(1, 1)
        hint.alpha = 0
        hint[3].rotation = 0
      end
      -- Sync Movement
      if _t.motion < 30 and _t.motion > -vH*limitFactor then
        _t.y = _t.yStart + _t.motion
      end
      --ended or cancelled
    elseif ('ended' == phase or 'cancelled' == phase) then
      local transT = 200
      local ease = easing.outExpo
      -- Handle Flicking
      _t.flick = _t.tLast and (event.time - _t.tLast) < 100 and true or false
      -- Cancelled 动作取消 Try to roll back
      d('Touch/Move Action Cancelled, Rolling Back...')
      self:blurGaussian(0)
      --ease = easing.inQuad
      transition.to( _t, {time = transT, y = 0, transition = ease} )
      transition.to( self.elements.avatar, {time = transT, yScale = 1, xScale = 1, transition = ease} )
      transition.to( self.elements.hint, {time = transT*2, alpha = 0, transition = ease} )
      -- --------------------
      display.getCurrentStage():setFocus( nil )
      _t.isFocus = false
      if self.shouldFlip then
        self:gotoState('MoterAlbumList')
--        self:send('flipToAlbumList') 
      end
    end
  end
  return true
--}}}
end

function Moter:blurGaussian(multi)
  local object = self.elements.avatar
  if not object then return end
  multi = multi or 2
  if multi > 5 then
    return
  elseif multi == 0 then
    object.fill.effect = nil
    return
  end
  object.fill.effect = "filter.blurGaussian"
  object.fill.effect.horizontal.blurSize = 10*multi
  object.fill.effect.horizontal.sigma = 100*multi
  object.fill.effect.vertical.blurSize = 10*multi
  object.fill.effect.vertical.sigma = 100*multi
end

function Moter:hintMore()
  local labelBio = self.elements.labelBio
  local hint = display.newGroup()
  local labelMore = display.newText {
    text = '{ DRAG }',
    x = cX, y = cY,
    fontSize = 18, font = fontSHSans
  }
  
  local iconMore = createIcon {
    x = cX, y = cY,
    text = 'expand_more',
    fontSize = 40
  }
  
  local labelMoterAlbum = createLabel {
      text = '女神图集',
      icon = 'expand_less',
      fontSize = 16,
      padding = 10,
      cornerRadius = 20,
    }
  labelMoterAlbum.x = cX
  labelMoterAlbum.y = cY
  
  iconMore.anchorX = .5
  iconMore:setFillColor(unpack(colorsRGB.RGBA('white', 1)))
  labelMore.y = labelBio.y + labelBio.contentHeight + 40
  labelMoterAlbum.y = labelMore.y + labelMoterAlbum.contentHeight*1.5
  iconMore.y = labelMoterAlbum.y + iconMore.contentHeight*.5
  labelMore.alpha = 1
  hint:insert(labelMore)
  hint:insert(labelMoterAlbum)
  hint:insert(iconMore)
  hint.alpha = 0
  self:_attach(hint, 'hint')
end

function Moter:onLikeTapped(tap)
  --d(tap.numTaps)
  local scale1 = 2
  local scale2 = 4
  local favColor = {colorHex('ad7d7e')}
  local unFavColor = colorsRGB.RGBA('white', .5)
  local favIcon = self.elements.favBtnG[self.elements.favBtnG.numChildren]
  if self.moterLiked then
    self.moterLiked = false
    transition.cancel(favIcon.animation)
    favIcon.animation = transition.to(favIcon, {time = 300, xScale = 0.1, yScale = 0.1, transition = easing.inBack })
    timer.performWithDelay(300, function()
        self.pulse(0, 0, unFavColor, scale1, scale2, 250, 500, self.elements.favBtnG.effectG)
        favIcon:setFillColor(unpack(colorsRGB.RGBA('white')))
        favIcon.animation = transition.to(favIcon, {time = 300, xScale = 1, yScale = 1, transition = easing.outBack })
      end)
  else
    self.moterLiked = true
    transition.cancel(favIcon.animation)
    favIcon.animation = transition.to(favIcon, {time = 300, xScale = 0.1, yScale = 0.1, transition = easing.inBack })
    timer.performWithDelay(300, function()
        self.pulse(0, 0, favColor, scale1, scale2, 250, 500, self.elements.favBtnG.effectG)
        favIcon:setFillColor(unpack(colorsRGB.RGBA('crimson')))
        favIcon.animation = transition.to(favIcon, {time = 300, xScale = 1, yScale = 1, transition = easing.outBack })
      end)
  end
end

function Moter:stop()
  self:cleanup()
end

local MoterAlubmList = Moter:addState('MoterAlbumList')

function MoterAlubmList:enteredState()
  local hint = self.elements.hint
  local pinH = hint.contentHeight
  --transition.to(hint, {delay = 500, time = 200, transition = easing.inExpo, alpha = 0})
  transition.to(
    self.layer,
    {
      time = 600,
      y = -vH-topInset-pinH, transition = easing.outExpo,
      onComplete = function()
        local scene = composer.getScene(composer.getSceneName('overlay'))
        scene:loadMoterAlbumList()
      end
    }
  )
end

function MoterAlubmList:exitedState()
  transition.to(
    self.layer,
    {
      time = 600,
      y = 0, transition = easing.outExpo,
      onComplete = function()
        local scene = composer.getScene(composer.getSceneName('overlay'))
        scene:unloadMoterAlbumList()
      end
    }
  )
end

return Moter