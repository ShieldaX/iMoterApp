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
local AlbumListView = require 'views.album_list'
local Cover = require 'views.album_cover'
--local Indicator = require 'views.indicator'
local AlbumList = class('MoterAlbumListView', AlbumListView)
local Toast = require 'views.toast'
local APP = require("classes.application")

-- Constants List:
local oX = display.screenOriginX
local oY = display.screenOriginY
local vW = display.viewableContentWidth
local vH = display.viewableContentHeight
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

local function resolveCoverImage(album)
  local prefix = 'https://t1.onvshen.com:85/gallery/'
  local subfix = '0'
  local moterId, albumId = album.moters[#album.moters], album._id
  if not moterId then d(album.moters) end
  local coverURI = prefix .. moterId .. '/' .. albumId .. '/cover/' .. subfix
  local coverImgName = moterId .. '_' .. albumId .. '_cover_' .. subfix
  return coverURI, coverImgName
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

local function createIcon(options)
  local fontPath = "icon-font/"
  local materialFont = fontPath .. "MaterialIcons-Regular.ttf"
  options.font = materialFont
  options.text = mui.getMaterialFontCodePointByName(options.text)
  local icon = display.newText(options)
  return icon
end

-- 利用获取的图集信息实例化一个图集对象
function AlbumList:initialize(obj, topPadding, sceneGroup)
  d('-*-*-*-*-*-*-*-*-*-*-*-*-*-*')
  d('- Prototype of Moter AlbumList View -')
  d('- ======================== -')
  assert(obj.moter_id, 'No moter id specified!')
  View.initialize(self, sceneGroup)
  -- -------------------
  -- DATA BINDING
  self.rawData = obj
  self.moter_id = obj.moter_id
  self._albums = obj.albums
  self.name = 'album_list'
  self.covers = {}
  sceneGroup.currentAlbumList = self
  local scene = composer.getScene(composer.getSceneName('current'))
  local moterView = scene.moterView
  local hint = moterView.elements.hint
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  -- ScrollView listener
  local function onScrollComplete()
    print( "Scroll complete!" )
  end

  local function scrollListener( event )
    local _t = event.target
    local phase = event.phase
    if ( phase == "began" ) then
      _t.xStart, _t.yStart = _t:getContentPosition()
    elseif ( phase == "moved" ) then
      _t.xLast, _t.yLast = _t:getContentPosition()
      _t.motion = _t.yLast - _t.yStart
      local isTabBarHidden = APP.Footer.hidden
      if _t.motion >= 2 and _t.yLast > 20 then
        if not self.shouldFlip then
          Toast('继续下滑返回'):show(0, -vH*.5 + topInset + 64)
          self.shouldFlip = (_t.yLast >= 24)
        end
      else
        Toast:hide()
        self.shouldFlip = false
      end
    elseif ( phase == "ended" ) then
--      print( "Scroll view was released" )
      if self.shouldFlip then
        Toast:hide()
        self:unfold()
      end
    end
    -- In the event a scroll limit is reached...
    if ( event.limitReached ) then
      local slider = self.elements.slider
      if ( event.direction == "up" ) then
        print( "Load more content..., TODO: block continuesly load if there'r no more albums" )
        local iMoter = self.bumper or APP.iMoterAPI --or require('classes.iMoter'):new()
        local function showAlbumsWithData(res)
          if not res or not res.data then
            native.showAlert("Oops!", "Album list currently not avaialble!", { "Okay" } )
            return false
          end
          local newlist = res.data.albums
          local albumlist = self._albums
          for _, album in ipairs(newlist) do
            table.insert(albumlist, album)
          end
          d(#self._albums)
          self:open(self.cursorIndex + 1)
        end
        iMoter:listAlbumsOfMoter( self.moter_id, {skip = self.cursorIndex, limit = 10}, showAlbumsWithData)
      elseif ( event.direction == "down" ) then print( "Reached top limit" )

      elseif ( event.direction == "left" ) then
        print( "Reached right limit" )
      elseif ( event.direction == "right" ) then print( "Reached left limit" )
      end
    end
    return true
  end
  local padding = topPadding or 0
  local scrollContainer = widget.newScrollView{
    top = oY, left = oX,
    width = vW, height = vH - padding,
    scrollWidth = vW, scrollHeight = vH,
    hideBackground = true,
    hideScrollBar = true,
    friction = 0.946,
    listener = scrollListener,
    horizontalScrollDisabled = true
  }
  self:_attach(scrollContainer, 'slider')
  -- END VISUAL INITIALIING
  -- -------------------
end

function AlbumList:unfold()
  transition.to(
    self.layer,
    {
      time = 600, transition = easing.outExpo,
      y = vH+bottomInset,
      onComplete = function() self:stop() end
    }
  )
  local scene = composer.getScene(composer.getSceneName('current'))
  scene.moterView:popState('MoterAlbumList')
end

function AlbumList:open(index)
  index = index or 1
  --self.cursorAlbumId = index
  --local indicator = Indicator:new({total= #self.imgURIs, name= 'progbar', top= 0}, self)
  local albums = self._albums
  for i = index, #albums, 1 do
    self:loadCover(i)
  end
  self.cursorIndex = #albums
  self:setState('STARTED')
  composer.removeScene('scenes.album')
end

function AlbumList:loadCover(index)
  local album = self._albums[index]
--  d(album)
  if not album then return false end
  local coverURI, coverFileName = resolveCoverImage(album)
  local cover = Cover({
      uri = coverURI,
      name = coverFileName,
      title = album.title,
      id = album._id,
      index = index
      }, self)
  local row = math.round(index/2)
  local col = index - (row - 1)*2
  local covers = self.covers
  covers[row] = covers[row] or {}
  covers[row][col] = cover
  cover:preload(row, col)
end

function AlbumList:onCoverTapped(event)
  composer.removeScene('scens.album')
  local options = {
    time = 420,
    effect = "slideLeft",
    params = event
  }
  composer.gotoScene("scenes.album", options)
end

function AlbumList:start()
  if self.state == 30 then return false end
  --local e = self.elements
  self:setState('STARTED')
end

function AlbumList:stop()
  self:cleanup()
end

return AlbumList