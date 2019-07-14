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
local StarRating = require 'views.star_rating'
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
  else
    name = _data.name
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
  if data.avatar then
    self.avatarImgURI = "https://t1.onvshen.com:85/gallery/".._id.."/"..data.avatar.."/0.jpg"
  else
    self.avatarImgURI = "https://img.onvshen.com:85/girl/".._id.."/".._id..".jpg"
  end
  self.avatarFileName = _id.."_".._id..".jpg"
  --APP.CurrentMoter = self
  -- END DATA BINDING
  -- -------------------
  -- VISUAL INITIALIING
  local _bg = display.newRect(oX, oY, vW, vH*0.46)
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
  self.layer.alpha = 0
  local fontDMFT = 'assets/fonts/DMFT1541427649707.ttf'
  local fontSHSans = 'assets/fonts/SourceHanSansK-Regular.ttf'
  local fontMorganiteBook = 'assets/fonts/Morganite-Book-4.ttf'
  local fontMorganiteSemiBold = 'assets/fonts/Morganite-SemiBold-9.ttf'
  --d(inspect(native.getFontNames()))
  local _data = self.rawData
  -- ==============================
  -- TITLE SECTION
  local name = resolveNames(_data.names, _data.name)
  APP.Header.elements.TopBar:setLabel(name)

  local ratingStars = _data.score and StarRating(_data.score.count, {name = 'stars', fillColor = colorsRGB.RGBA('gold'), iconSize = 20})
  util.center(ratingStars.layer)

  local labelG = display.newGroup()
--  local labelScore = _data.score and display.newText{text = _data.score.count, x = vW-50, y = self.elements.bg.y-80, fontSize = 50}
--  if labelScore then labelScore:setFillColor(unpack(colorsRGB.RGBA('gold', .9))) end

  local labelBG = display.newRoundedRect(labelG, oX, oY, vW*.42, vH*.3, 2)
  labelBG:setFillColor(colorHex('222222', .99))
  labelBG.strokeWidth = 1; labelBG:setStrokeColor(colorHex('333333', 0.5))
  labelBG.anchorY = 0
  --labelBG.y = labelBG.y - labelBG.height*.5

  local padding = 28
  local age, zodiac, astroSign
  if _data.birthday then
    age, zodiac, astroSign = DOB2AgeZodiacAstro(_data.birthday)
  end
  local labelNameAge = display.newText {text = _data.name..(age and ', '..age or ''), x = 0, y = 0, fontSize = 22, font = fontDMFT}
  local bounds = labelBG.contentBounds
  labelNameAge.x = bounds.xMin + labelNameAge.width*.5 + padding*.5
  labelNameAge.y = bounds.yMin+padding
  labelG:insert(labelNameAge)

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
  labelG:insert(ratingStars.layer)
  d('======================')
  ratingStars.layer.x = sperateLine.x + ratingStars.layer.contentWidth*.5
  ratingStars.layer.y = sperateLine.y
  self.stars = ratingStars
  labelInfo.y = labelHW.y + labelInfo.baselineOffset*.5 + labelHW.contentHeight*.3

  -- ==============================
  -- BIO DESC SECTION
  local labelBioCap = display.newText {text = '详情资料', x = 0, y = 0, fontSize = 20, font = fontDMFT}
  local labelBio = display.newText {text = _data.bio,  width = vW*.9, x = leftPadding, y = labelHW.y + padding*.6, fontSize = 12, font = fontSHSans}
  labelBioCap:setFillColor(colorHex('C7A680'))
  labelBio:setFillColor(colorHex('6C6C6C'))
  labelBioCap.anchorX, labelBioCap.anchorY = 0, 0
  labelBio.anchorX, labelBio.anchorY = 0, 0
  local bg = self.elements.bg
  labelBioCap.x, labelBioCap.y = 15, bg.y - bg.height + padding*2.4
  labelBio.x, labelBio.y = 15, labelBioCap.y + padding*1.1
  self:_attach(labelG, 'capCard')
  self:_attach(labelBioCap)
  self:_attach(labelBio)
  -- ---------------------------------
  if _data.birthday then
    local goldenColor = {colorHex('6C6C6C')}
    local birthG = display.newGroup()
    local labelBirthday = display.newText{text = parseBirthday(_data.birthday), x = leftPadding, y = labelHW.y + padding*.5, fontSize = 25, font = fontMorganiteSemiBold}
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
    birthG.x = labelBio.contentBounds.xMax
    birthG.y = labelBioCap.y + birthG.contentHeight*.5
    self:_attach(birthG)
  end
  -- ---------------------------------
  -- Reheight and reposition capCard to fit full-screened phones
  local crossCut = labelBG.contentBounds.yMax - labelInfo.contentBounds.yMax
  if crossCut > 0 and crossCut < 5 then -- Keep at least 5px space
    labelBG.height = labelBG.height + 5
  elseif crossCut > padding then
    d('cross cutting: '..crossCut)
    labelBG.height = labelBG.height - crossCut + padding*.5
  end
  -- ------------------------------
  --labelG.anchorChildren = true
  labelG.x = oX+labelBG.width*.6 --actual 0.1 labelBG width offset oX
  labelG.y = self.elements.bg.contentBounds.yMin - labelG.contentHeight*.7

  local _lgray = {colorHex('6C6C6C')}
  local titleFSize = 12
  local labelFSize = 24
  local gY = screenH - bg.height*.3
  local titleScore = display.newEmbossedText {text = '评分', x = vW*.24, y = gY, fontSize = titleFSize, font = fontSHSans}
  titleScore:setFillColor(unpack(_lgray))
  local labelScoreCount = display.newText {text = _data.score.count, x = vW*.24, y = titleScore.contentBounds.yMax + 10, fontSize = labelFSize, font = fontDMFT}
  readableNumber(_data.score.votes)
  local titleAlbum = display.newEmbossedText {text = '图集', x = vW*.5, y = gY, fontSize = titleFSize, font = fontSHSans}
  titleAlbum:setFillColor(unpack(_lgray))
  local labelNumAlbum = display.newText {text = '162', x = vW*.5, y = titleAlbum.contentBounds.yMax + 10, fontSize = labelFSize, font = fontDMFT}

  local titleHot = display.newEmbossedText {text = '热度', x = vW*.76, y = gY, fontSize = titleFSize, font = fontSHSans}
  titleHot:setFillColor(unpack(_lgray))
  local labelNumHot = display.newText {text = readableNumber(_data.score.votes), x = vW*.76, y = titleHot.contentBounds.yMax + 10, fontSize = labelFSize, font = fontDMFT}

  local triangleShape = display.newPolygon(cX, cY, {-10, 5, 0, -8, 10, 5})
  triangleShape:setFillColor(unpack(_lgray))
  triangleShape.anchorY = 1
  triangleShape.y = labelScoreCount.y + 32
  --self:_attach(triangleShape, '_tabCursor')
  triangleShape.x = vW*.24

  local _nextBG = display.newRect(self.layer, cX, cY, vW, vH*.6)
  _nextBG:setFillColor(unpack(_lgray)) -- golden gray 
  --util.center(_nextBG)
  _nextBG.anchorY = 0
  _nextBG.y = triangleShape.y
  --self:_attach(_nextBG, 'nextBG')

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
  timer.performWithDelay(1000, function() self.stars:animate() end)
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
    self:signal('onLikeTapped', tap)
    pulse2(0, 0, gold, scale1, scale2, 250, 500, effectG)
    --favBtnG[4]:setFillColor(unpack(colorsRGB.RGBA('red')))
  end
  favIcon:addEventListener('tap', tapListener)

  self:setState('STARTED')
end

function Moter:onLikeTapped(tap)
  --d(tap.numTaps)
  local favIcon = self.elements.favBtnG[self.elements.favBtnG.numChildren]
  if self.moterLiked then
    self.moterLiked = false
    favIcon:setFillColor(unpack(colorsRGB.RGBA('white')))
  else
    self.moterLiked = true
    favIcon:setFillColor(unpack(colorsRGB.RGBA('crimson')))
  end
end

function Moter:stop()
  self:cleanup()
end

return Moter