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
  self.rawData = obj
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  local springStart = 0
  local needToReload = false

  local function scrollListener( event )
     if ( event.phase == "began" ) then
        springStart = event.target.parent.parent:getContentPosition()
        needToReload = false
     elseif ( event.phase == "moved" ) then
        if ( event.target.parent.parent:getContentPosition() > springStart + 60 ) then
           needToReload = true
        end
     elseif ( event.limitReached == true and event.phase == nil and event.direction == "down" and needToReload == true ) then
        --print( "Reloading Table!" )
        needToReload = false
     end
     return true
  end
    
  local function onRowRender( event )

     --Set up the localized variables to be passed via the event table

     local row = event.row
     local id = row.index
     local params = event.row.params

     row.bg = display.newRect( 0, 0, display.contentWidth, 60 )
     row.bg.anchorX = 0
     row.bg.anchorY = 0
     row.bg:setFillColor( 1, 1, 1 )
     row:insert( row.bg )

     if ( event.row.params ) then    
        row.nameText = display.newText( params.name, 12, 0, native.systemFontBold, 18 )
        row.nameText.anchorX = 0
        row.nameText.anchorY = 0.5
        row.nameText:setFillColor( 0 )
        row.nameText.y = 20
        row.nameText.x = 42

        row.phoneText = display.newText( params.phone, 12, 0, native.systemFont, 18 )
        row.phoneText.anchorX = 0
        row.phoneText.anchorY = 0.5
        row.phoneText:setFillColor( 0.5 )
        row.phoneText.y = 40
        row.phoneText.x = 42

        row.rightArrow = display.newText( '>', 15 , 40 )
        row.rightArrow.x = display.contentWidth - 20
        row.rightArrow.y = row.height / 2

        row:insert( row.nameText )
        row:insert( row.phoneText )
        row:insert( row.rightArrow )
     end
     return true
  end

  local navBarHeight = topPadding or 100
  local tabBarHeight = 50
  local myList = widget.newTableView {
     top = navBarHeight, 
     width = display.contentWidth, 
     height = display.contentHeight - navBarHeight - tabBarHeight,
     onRowRender = onRowRender,
     onRowTouch = onRowTouch,
     listener = scrollListener
  }
  
  local myData = {}
  myData[1] = { name="收藏的图集",    phone="555-555-1234" }
  myData[2] = { name="喜欢的女神",  phone="555-555-1235" }
  myData[3] = { name="Wilma",   phone="555-555-1236" }
  myData[4] = { name="Betty",   phone="555-555-1237" }
  myData[5] = { name="Pebbles", phone="555-555-1238" }
  myData[6] = { name="BamBam",  phone="555-555-1239" }
  myData[7] = { name="Dino",    phone="555-555-1240" }

  for i = 1, #myData do
     myList:insertRow{
        rowHeight = 60,
        isCategory = false,
        rowColor = { 1, 1, 1 },
        lineColor = { 0.2, 0.2, 0.2 },
        params = {
           name = myData[i].name,
           phone = myData[i].phone
        }
     }
  end
  self:_attach(myList, 'table')
  -- END VISUAL INITIALIING
  -- -------------------
end

function MineList:open(index)
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

function MineList:loadCover(index)
  local album = self._albums[index]
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