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
  d('- Prototype of AlbumList View -')
  d('- ======================== -')
  View.initialize(self, sceneGroup)
  -- -------------------
  -- DATA BINDING
  self.rawData = obj
  self._albums = obj.albums
  self.name = 'album list'
  self.covers = {}
  APP.CurrentAlbumList = self
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
      if _t.motion <= -30 and not isTabBarHidden then
        APP.Footer:hide()
      elseif _t.motion >= 30 and isTabBarHidden then
        APP.Footer:show()
      end
    elseif ( phase == "ended" ) then
      print( "Scroll view was released" )
    end
    -- In the event a scroll limit is reached...
    if ( event.limitReached ) then
      local slider = self.elements.slider
      if ( event.direction == "up" ) then
        print( "Load more content..." )
        local iMoter = self.bumper
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
        iMoter:listAlbums({skip = self.cursorIndex, limit = 10}, showAlbumsWithData)
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
end

function AlbumList:loadCover(index)
  local album = self._albums[index]
  d(album)
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

function AlbumList:onAlbumTapped(event)
  event.labelText = table.indexOf(self.imgNames, self.currentPieceId) .. '/' .. self.rawData.pieces
  local options = {
    effect = "fade",
    time = 500,
    isModal = true,
    params = event
  }
  composer.showOverlay( "scenes.album", options )
end

function AlbumList:onCoverTapped(event)
--  event.coverImageURI = 
  local options = {
    effect = "slideLeft",
    time = 420,
    params = event
  }
  composer.gotoScene( "scenes.album", options )
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