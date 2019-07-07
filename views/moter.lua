local composer = require( "composer" )
-- Constants List:
local oX = display.screenOriginX
local oY = display.screenOriginY
local vW = display.viewableContentWidth
local vH = display.viewableContentHeight

local class = require 'libs.middleclass'
local Stateful = require 'libs.stateful'
local inspect = require 'libs.inspect'

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
  --obj:scale(scaleFactor, scaleFactor)
end

-- Classes
local View = require 'libs.view'
local Piece = require 'views.piece'
local Indicator = require 'views.indicator'
local Moter = class('MoterView', View)
local APP = require("classes.application")

local LayoutManager = require( "libs.layout" )
-- layout manager object
local Layout

-- Group to hold rects that display the regions
local Regions

-- Content grid size; change these to change the size of the generated grid
local ContentGridSize = 4
local GridPixelPadding = 8

-- 利用获取的图集信息实例化一个图集对象
function Moter:initialize(obj, sceneGroup)
  d('-*-*-*-*-*-*-*-*-*-*-*-*-*-*')
  d('- Prototype of Moter View -')
  d('- ======================== -')
  View.initialize(self, sceneGroup)
  -- -------------------
  -- DATA BINDING
  self.rawData = obj
  self.name = obj.name
  local _id = obj._id
  self.avatarImgURI = "https://img.onvshen.com:85/girl/".._id.."/".._id..".jpg"
  self.avatarFileName = _id.."_".._id..".jpg"
  --APP.CurrentMoter = self
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  local _bg = display.newRoundedRect(self.layer, oX, oY, vW, vH, 8)
--  local _bg = display.newRect(self.layer, oX, oY, vW, vH)
  _bg:setFillColor(1) -- Pure White
  util.center(_bg)
--  _bg.y = _bg.y+50
  self:_attach(_bg, '_bg')
  --self.elements._bg:toBack()
  -- END VISUAL INITIALIING
  -- -------------------
end

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
--[[
local _then = TimeStamp("2013-01-01T00:00:00Z")
local _now = os.time()
local timeDifference = _now - _then
daysDifference = math.floor(timeDifference / (24 * 60 * 60))
d(daysDifference)
--]]

local zodiacList = {'鼠', '牛', '虎', '兔', '龙', '蛇', '马', '羊', '猴', '鸡', '狗', '猪'}
local function DOB2AgeZodiacAstro(birthday)
  local xyear, xmonth, xday = birthday:match("(%d+)%-(%d+)%-(%d+)")
  local currentDate = os.date("!%Y-%m-%d")
  local yyear, ymonth, yday = currentDate:match("(%d+)%-(%d+)%-(%d+)")
  local yearElapsed, _month, _day = yyear - xyear, ymonth - xmonth, yday - xday
  -- -------------------Age----------------- --
  local age = yearElapsed
  d('Age : '..age)
  if _month < 0 then -- current month: 7, birth month: 8
    age = age - 1
  elseif _month == 0 then
    if _day < 0 then age = age -1 end
  end
  d('Age: '..age)
  -- -----------------Zodiac---------------- --
  local _animalRange = math.fmod((xyear - 4), 12)
  local zodiac = zodiacList[_animalRange]
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
  --d(birthday)
  local _time = makeTimeStamp(birthday)
  --d(_time)
  return os.date("!%Y-%m-%d", _time)
end

local function parseAge(birthday)
  local _then = makeTimeStamp(birthday)
  local _now = os.time()
  local timeElapsed = _now - _then
  yearsPast = math.floor(timeElapsed/(24*60*60*365))
end

function Moter:layout()
  --local indicator = Indicator:new({total= #self.imgURIs, name= 'progbar', top= 0}, self)
  --self:addView(indicator)
  local _data = self.rawData
  local labelBirthday = display.newText {text = '生日：' .. parseBirthday(_data.birthday), x = cX, y = cY, fontSize = 12}
  labelBirthday:setFillColor(0)
  local age, zodiac, astroSign = DOB2AgeZodiacAstro(_data.birthday)
  local labelAge = display.newText {text = '年龄：' .. age, x = cX, y = cY + 20, fontSize = 12}
  local labelAstroSign = display.newText {text = '星座：' .. astroSign .. '座', x = cX, y = cY + 40, fontSize = 12}
  labelAge:setFillColor(0)
  labelAstroSign:setFillColor(0)
  -- ------------------------------ http://www.wellho.net/resources/ex.php4?item=u105/spjo
  local names = _data.names
  if names.cn and names.en then
    names = names.cn..','..names.en
  elseif names.cn then
    names = names.cn
  elseif names.en then
    names = names.en
  end
  local labelHeight = _data.height and display.newText {text = '身高：' .. _data.height .. 'CM', x = cX, y = cY + 60, fontSize = 12}
  if labelHeight then labelHeight:setFillColor(0) end
  local labelWeight = _data.weight and display.newText {text = '体重：' .. _data.weight .. 'KG', x = cX, y = cY + 80, fontSize = 12}
  if labelWeight then labelWeight:setFillColor(0) end
  local measure = _data.measure and 'B'.._data.measure.bust..' '..'W'.._data.measure.waist..' '..'H'.._data.measure.hips
  local labelMeasure = display.newText {text = '三围：' .. measure, x = cX, y = cY + 100, fontSize = 12}
  if labelMeasure then labelMeasure:setFillColor(0) end
  local labelBirthPlace = display.newText {text = '出生：'.._data.country..' '.._data.birthplace, x = cX, y = cY + 120, fontSize = 12}
  if labelBirthPlace then labelBirthPlace:setFillColor(0) end
  local labelCareer = _data.career and display.newText {text = '职业：'..table.concat(_data.career, ' '), x = cX, y = cY + 140, fontSize = 12}
  if labelCareer then labelCareer:setFillColor(0) end
  local labelHobbies = _data.hobbies and display.newText {text = '兴趣：'..table.concat(_data.hobbies, ' '), x = cX, y = cY + 160, fontSize = 12}
  if labelHobbies then labelHobbies:setFillColor(0) end
  -- -----------------------
  
  local labelBio = _data.bio and display.newText {text = _data.bio, x = cX, y = cY - 60, fontSize = 12, width = vW*0.75}
  labelBio:setFillColor(0)
  
  if self.state > View.STATUS.INITIALIZED then
    d("Try to preload Moter already @ "..self.getState())
    return false
  end
  -- Load image
	local function networkListener( event )
    if event.phase == 'began' or event.phase == 'progress' then
      self._requestId = event.requestId
      print('Image is Loading')
      return
    elseif event.phase == 'ended' then
      print('Image Loading Ended')
      self._requestId = nil
    end
    if ( event.isError ) then
      print ( "Network error - download failed" )
      return false
    else
      --self:signal('onAavatrLoaded')
      local _image = event.target
      util.fitWidth(_image, vW/3)
      _image.alpha = 0
      util.center(_image)
      --_image.x = cX - _image.width*.5
      self.imageTransiton = transition.to( _image, { time = 500, alpha = 1, y = _image.contentHeight*.5 + vH*.1, transition = easing.outExpo} )
      self:_attach(_image, 'avatar')
      
    end
    self.avatarFileName = event.response.filename
    self.baseDir = event.response.baseDirectory
    -- When self is RELEASED by Parent View
    if self.state >= View.STATUS.PRELOADED then
      --self:cleanup()
    else
      self:setState('PRELOADED')
      if not self.isBlocked then
        d('Start Piece '..self.name..' '..self:getState()..' and Not Blocked')
        self:start()
      else
        d(self.name .. ' ' .. self:getState())
      end
    end
	end
  display.loadRemoteImage( self.avatarImgURI, "GET", networkListener, {progress = true}, self.avatarFileName, Piece.DEFAULT_DIRECTORY, oX, oY)
end

function Moter:onPieceTapped(event)
  event.labelText = table.indexOf(self.imgNames, self.currentPieceId) .. '/' .. self.rawData.pieces
  local options = {
      effect = "fade",
      time = 500,
      isModal = true,
      params = event
  }
  composer.showOverlay( "scenes.piece", options )
end

--local ActiveAlbum = AlbumView:addState('Actived')
--function ActiveAlbum:start() end

function Moter:start()
  if self.state == 30 then return false end
  --local e = self.elements
  self:setState('STARTED')
end

function Moter:stop()
  self:cleanup()
end

return Moter