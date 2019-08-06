local composer = require( "composer" )

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

-- Classes
local View = require 'libs.view'
local Piece = require 'views.piece_horizon'
local Indicator = require 'views.indicator'
local Album = class('AlbumView', View)
local APP = require("classes.application")

local fontDMFT = 'assets/fonts/DMFT1541427649707.ttf'
local fontSHSans = 'assets/fonts/SourceHanSansK-Regular.ttf'
local fontSHSansBold = 'assets/fonts/SourceHanSansK-Bold.ttf'
local fontMorganiteBook = 'assets/fonts/Morganite-Book-4.ttf'
local fontMorganiteSemiBold = 'assets/fonts/Morganite-SemiBold-9.ttf'

local function tribleNum(num)
  local prefix = '00'
  if num >= 10 then
    prefix = '0'
  elseif num >= 100 then
    prefix = ''
  end
  return prefix .. tostring( num )
end

-- 根据远端资源命名规则解析图集所包含的图片
local function resolveImages(album, includeCover)
  local numPieces, uris, names = 1, {}, {}
  numPieces = album.pieces
  local prefix = 'https://t1.onvshen.com:85/gallery/'
  local subfix = '0'
  local moterId, albumId = album.moters[1]._id, album._id
  uris[1] = prefix .. moterId .. '/' .. albumId .. '/' .. subfix
  names[1] = moterId .. '_' .. albumId .. '_' .. subfix
  for i = 2, numPieces do
    local idx = i - 1
    uris[i] = prefix .. moterId .. '/' .. albumId .. '/' .. tribleNum(idx)
    names[i] = moterId .. '_' .. albumId .. '_' .. tribleNum(idx)
  end
  if includeCover then
    local coverURI = prefix .. moterId .. '/' .. albumId .. '/cover/' .. subfix
    local coverName = moterId .. '_' .. albumId .. '_cover_' .. subfix
    table.insert(uris, 1, coverURI)
    table.insert(names, 1, coverName)
  end
  return uris, names
end

local function resolvePublisher(album)
  local publisher = album.publisher
  if not publisher then
    local title = album.title
    if title then
      publisher = title:match('%[(.)%]') or publisher
    end
  end
  return publisher
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

-- 利用获取的图集信息实例化一个图集对象
function Album:initialize(obj, sceneGroup)
  d('-*-*-*-*-*-*-*-*-*-*-*-*-*-*')
  d('- Prototype of Album View -')
  d('- ======================== -')
  self.name = obj.name or obj._id
  View.initialize(self, sceneGroup)
  -- -------------------
  -- DATA BINDING
  self.rawData = obj
  self.imgURIs, self.imgNames = resolveImages(obj)
  self.currentPieceId = nil
  self.paintedPieceId = nil
  self.pieceAutoRotate = composer.getVariable('autoRotate')
  composer.setVariable( "autoRotate", self.pieceAutoRotate )
  -- END DATA BINDING
  -- -------------------
  -- -------------------
  -- VISUAL INITIALIING
  local _bg = display.newRect(oX, oY, vW, vH)
--  _bg:setFillColor(colorHex('1A1A19'))
  _bg:setFillColor(colorHex('6C6C6C'), .32)
--  _bg:setFillColor(unpack(colorsRGB.RGBA('whitesmoke')))
  _bg:translate( _bg.contentWidth*0.5, _bg.contentHeight*0.5 )
  self:_attach(_bg, '_bg')
--  local indicator = Indicator:new({total= #self.imgURIs, name= 'indicator', top= 42}, self)
--  self:_attach(indicator, 'indicator')
  self.elements._bg:toBack()
  -- END VISUAL INITIALIING
  -- -------------------
end

function Album:open(index)
  index = index or 1
  self.currentPieceId = nil
--  local curScene = composer.getScene(composer.getSceneName('current')) 
  local indicator = Indicator:new({total= #self.imgURIs, name= 'indicator', top= 42})
  self:_attach(indicator)
  self:createPiece(index)
  -- First Initialize: Update Pieces (C/P) Reference Manually
  self.currentPieceId, self.paintedPieceId = self.paintedPieceId, nil
  --self:showInfo()
  self:setState('STARTED')
end

-- ---
-- 清除其他预加载的Piece View，（重）新创建一个Piece对象，
-- 如果预加载的Piece View 和目标一致则直接返回
-- 如果有预加载回调任务则置入Piece View的预加载中
function Album:createPiece(index)
  if self.paintedPieceId then
    d('FOUND EXISIST IN MEMORY: ' .. self.paintedPieceId)
    if self.elements[self.paintedPieceId] then
      d('ALREADY ATTACHED: @' .. self.elements[self.paintedPieceId].state)
      return false
    end
  end
  self:turnOut()
  local _piece = Piece:new(self.imgURIs[index], self.imgNames[index])
  self:_attach(_piece)
  _piece:preload()
  self.paintedPieceId = _piece.name
  self:signal('onProgress', {index = index})
end

-- ---
-- load another of piece
-- @param direction: 1(scroll down), -1(scroll up)
--
function Album:switchPiece(direction)
  d('当前显示的Piece ID：' .. self.currentPieceId)
  if direction == 0 or self.currentPieceId == nil then return false end
  direction = tonumber(direction) or 1
  assert(math.abs(direction) == 1, "invalid direction while call ':switchPiece'")
  -- Try to drop older painted piece
  self:turnOut()
  -- Get target piece id
  local currentIndex = table.indexOf(self.imgNames, self.currentPieceId)
  local targetIndex = currentIndex + direction
  local pieceId = self.imgNames[targetIndex]
--  self:signal('onPieceSwitch', {direction = direction})
  -- 切换显示头部和信息卡片

  local currentScene = composer.getScene(composer.getSceneName('current'))
  local titleBar = currentScene.header
  local infoCard = currentScene.infoCard
  if direction > 0 then
    titleBar:hide()
    infoCard:hide()
--  else
--    titleBar:show()
--    infoCard:show()
  end

  if pieceId == nil then
    if direction == -1 then
      d('This is already the first pix!') 
      local prevScene = composer.getSceneName( "previous" )
      if prevScene then
        composer.gotoScene( prevScene, {effect = 'slideRight', time = 420} )
      end
      display.getCurrentStage():setFocus(nil)
      return true
    elseif direction == 1 then
      d('This is already the foot pix!')
    end
    --self:signal('onAlbumLimitReached', {direction = direction})
    return false
  end
  self:createPiece(targetIndex)
end

-- ---
-- change current piece after switching properly
-- STOP any interactions
function Album:turnOver()
  if self.paintedPieceId == nil or self.currentPieceId == nil then return false end
  local transTime, easeType = 400, easing.outQuad --ms
  local currentPiece = self.elements[self.currentPieceId]
  local targetPiece = self.elements[self.paintedPieceId]
  -- ------------------
  -- Current Piece is Fading Out
  currentPiece:stop()
  local targetIndex = table.indexOf(self.imgNames, self.paintedPieceId)
--  local currentIndex = table.indexOf(self.imgNames, self.currentPieceId)
--  local direction = targetIndex > currentIndex and 1 or -1  
  self:signal('onProgress', {index = targetIndex})
--  transition.to( currentPiece.layer, {time = transTime - 50, y = - currentPiece.layer.direction*vH, transition = easeType} )
  transition.to( currentPiece.layer, {time = transTime - 50, x = - currentPiece.layer.direction*vW, transition = easeType} )
  -- ------------------
  -- Target Piece is Fading In (Comes Up)
  local isPreloaded = (targetPiece.state >= View.STATUS.PRELOADED)
  if not isPreloaded then -- 图片未加载的情况下：需要重新定位View的Layer
    d('REPOSITION Target Piece View Group')
    local _layer = targetPiece.layer
    _layer.x = (1 - _layer.xScale)*vW*.5
    _layer.y = (1 - _layer.yScale)*vH*.5
  end
  -- Blocking Piece to Avoid Unexpect Interaction while Transition (Moving)
  targetPiece.isBlocked = true
  transition.to( targetPiece.layer, {
      --onStart = function() targetPiece.isBlocked = true end,
      time = transTime,
      x = 0, y = 0,
      xScale = 1, yScale = 1,
      alpha = 1,
      transition = easeType,
      onComplete = function()
        targetPiece.isBlocked = false
        currentPiece:cleanup()
        self.elements[self.currentPieceId] = nil
        -- Exchange references C/P piece view
        self.currentPieceId, self.paintedPieceId = self.paintedPieceId, nil
        if self.currentPieceId and self.elements[self.currentPieceId].state >= View.STATUS.PRELOADED then
          self.elements[self.currentPieceId]:start()
        end
      end
    }
  )
end

-- ---
-- 清除预加载的（目标）Piece View对象并重置预加载索引
-- clean the new piece object on album view
-- @return 'boolean' False if nothing need clean.
function Album:turnOut()
  if self.paintedPieceId and self.elements[self.paintedPieceId] then
    self.elements[self.paintedPieceId]:cleanup() -- RELEASE Painted Piece
    self.elements[self.paintedPieceId] = nil
    self.paintedPieceId = nil
    return true
  else
    return false
  end
end

function Album:onPieceTapped(event)
  event.labelText = table.indexOf(self.imgNames, self.currentPieceId) .. '/' .. self.rawData.pieces
  local options = {
    effect = "fade",
    time = 500,
    isModal = true,
    params = event
  }
  d('打开图片专门页面...')
  composer.showOverlay( "scenes.piece", options )
end

function Album:onPieceTapped(event)
  local scene = composer.getScene(composer.getSceneName('current'))
  scene.header:toggle()
  scene.infoCard:toggle()
end

function Album:start()
  if self.state == 30 then return false end
  self:setState('STARTED')
end

function Album:stop()
  d('Try to destroy Album: '..self.name)
  local currentPiece = self.elements[self.currentPieceId]
  currentPiece:stop()
  currentPiece:cleanup()
  self:destroy()
end

return Album