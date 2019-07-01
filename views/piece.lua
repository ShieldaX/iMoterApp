-- Constants List:
local oX = display.screenOriginX
local oY = display.screenOriginY
local vW = display.viewableContentWidth
local vH = display.viewableContentHeight
local visibleAspectRatio = vW/vH

local class = require 'libs.middleclass'
--local Stateful = require 'libs.stateful'
--local inspect = require 'libs.inspect'

local util = require 'util'
local d = util.print_r
--util.show_fps()

-- local forward references should go here --
local screenW, screenH, halfW, halfH = display.contentWidth, display.contentHeight, display.contentWidth*0.5, display.contentHeight*0.5
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

-- ---
-- CLASSES Declaration
--
local View = require "libs.view"
local Piece = class('PieceView', View)

-- ---
-- Resize Image Display Object to Fit Screen WIDTH
--
function util.resize(obj)
  local ini
  local ratioT = obj.width/obj.height
  --d(visibleAspectRatio..':'..ratioT)
  --resize properly
  if visibleAspectRatio >= ratioT then
      ini = vH/obj.height
  else
      ini = vW/obj.width
  end
  obj:scale(ini, ini)
end

-- ---
-- Default Image File Cache Directory
-- TODO: Try to load piece image from this dir firstly
Piece.static.DEFAULT_DIRECTORY = system.CachesDirectory

function Piece:initialize(uri, name, parent, index)
  View.initialize(self)
  assert(self.layer, 'Piece View Initialized Failed!')
  d('创建图片对象: '..name)
  self.uri = uri .. '.jpg'
  self.fileName = name .. '.jpg'
  self.name = name
  d(self.name..' '..self:getState())
end

-- ---
-- Preload Image Display Object
-- Then Start Self View Automatically
--
function Piece:preload()
  if self.state > self.class.STATUS.INITIALIZED then
    return false
  elseif self.state < self.class.STATUS.INITIALIZED then
    self:initialize()
  end
  -- Load image
	local function networkListener( event )
    if ( event.isError ) then
      print ( "Network error - download failed" )
      return false
    else
      local _image = event.target
      util.resize(_image)
      _image.alpha = 0
      util.center(_image)
      transition.to( _image, { alpha = 1.0 } )
      self:_attach(_image, 'image')
      if self.blocking then
        self:unblock()
      end
    end
    --print ( "event.response.fullPath: ", event.response.fullPath )
    --print ( "event.response.filename: ", event.response.filename )
    --print ( "event.response.baseDirectory: ", event.response.baseDirectory )
    self.fileName = event.response.filename
    self.baseDir = event.response.baseDirectory
    self:setState('PRELOADED')
    -- AutoStart
    self:start()
	end
  display.loadRemoteImage( self.uri, "GET", networkListener, self.fileName, Piece.DEFAULT_DIRECTORY, oX, oY)
end

function Piece:onImageLoaded()
  d('self.name' .. 'image resource loaded')
end

-- ---
-- Main Touch Handler
--
function Piece:touch(event)
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
      _t.speed = 0
      _t.direction = 0
    --focus
    elseif _t.isFocus then
      local album = self.parent
      --moved
      if ('moved' == phase) then
        _t.tLast = event.time
        -- Distence passed by touch
        _t.motion = event.y - event.yStart
        -- Sync Movement
        _t.y = _t.yStart + _t.motion
        -- Detect switching direction
        if _t.motion > 0 and _t.direction >= 0 then
          _t.direction = -1
          album:switchPiece(_t.direction)
        elseif _t.motion < 0 and _t.direction <=0 then
          _t.direction = 1
          album:switchPiece(_t.direction)
        end
        if math.abs(_t.motion) > 0 and album.paintedPieceId and album.elements[album.paintedPieceId] then
          local ratio = (math.abs(_t.motion)/vH)*.1 + .8
          local paintedPiece = album.elements[album.paintedPieceId].layer
          --local paintedPieceImage = album.elements[album.paintedPieceId].elements.image
          if paintedPieceImage then
            paintedPieceImage.xScale, paintedPieceImage.yScale = ratio, ratio
            util.center(paintedPieceImage)
          end
          paintedPiece.xScale, paintedPiece.yScale = ratio, ratio
          util.center(paintedPiece)
          album.elements[album.paintedPieceId].layer.alpha = math.abs(_t.motion)/(vH*1.2)
        end
      --ended or cancelled
      elseif ('ended' == phase or 'cancelled' == phase) then
        local transT = 600
        local ease = easing.outExpo
        -- detect flick
        if _t.tLast and (event.time - _t.tLast) < 100 then _t.flick = true else _t.flick = false end
        -- 处理快速翻页动作
        local snap = vH*.1
        if (_t.flick and (math.abs(_t.motion) >= snap and math.abs(_t.direction) ~= 0)) and album.paintedPieceId then
          if album.elements[album.paintedPieceId].state >= View.STATUS.PRELOADED then
            d('Flicked and Image Preloaded')
          else -- 图片未加载完成
            d('Flicked but Image Unloaded')
          end
          album:turnOver()
        else
          --ease = easing.inQuad
          transition.to( _t, {time = transT, y = 0, transition = ease} )
          -- drop older painted pix if any
          if album.paintedPieceId and album.elements[album.paintedPieceId] then
            local _target = album.elements[album.paintedPieceId]
            --transition.to(_target.elements['shade'], {time = transT, alpha = 1, transition = ease})
            transition.to(_target.layer, {
                time = transT,
                x = 64, y = 96,
                xScale = 0.8, yScale = 0.8,
                transition = ease,
                onComplete = function() album:turnOut() end
              })
          end
        end
        display.getCurrentStage():setFocus( nil )
        _t.isFocus = false
      end
    end
    --
    return true
--}}}
end

-- Add tap listeners
function Piece:tap()
  -- TODO: pop overlay: Enter image resource view.
	d('board')
	--album:board()
end

-- ---
-- Blocking Piece while Loading
--
function Piece:block()
  if self.blocking == true then return false end
  local layer = self.layer
  --local shade = display.newRect(layer.x, layer.y, layer.width, layer.height)
  --shade:setFillColor(1, 1, 1, 255)
  -- replace manually
  --shade.x = self.elements['image'].x
  --shade.y = self.elements['image'].y
  --self:_attach(shade, 'shade')
  --shade:toFront()
  layer.alpha = 0.2
  self.blocking = true
  --self.layer.xScale = self.targetScale * 0.618
  --self.layer.yScale = self.targetScale * 0.618
end

-- ---
-- Unblock Piece After Preloaded
--
function Piece:unblock()
  if self.blocking == false then return false end
  --self.imageView.xScale = self.targetScale
  --self.imageView.yScale = self.targetScale
  self.layer.alpha = 1
  self.blocking = false
end

function Piece:reload(image)
  d(self.fileName)
  if not self.baseDir then
    self.baseDir = Piece.directory
  end
  --local reImage = display.newImage( album, self.fileName, self.baseDir )
  --fitScreenW(reImage)
end

-- ---
-- Begin to receive touch or tap events, then give reflection back properly
--
function Piece:start()
--{{{
    d(self.name..' '..self:getState())
    if self.state > View.STATUS.STARTED then
      d(self.name .. ' already Started!')
      return false 
    end
    if self.state < View.STATUS.PRELOADED then
      d(self.name .. ' is Not Ready to Start!')
      return false 
    end
    if self.blocking == true then
      self:unblock()
    end
    -- Add touch event handler
    self.layer:addEventListener('touch', self)
    self.layer:addEventListener('tap', self)
    self:setState('STARTED')
    d(self.name..' '..self:getState())
--}}}
end

-- ---
-- main program entered another progress/app, freeze from reflecting, sleep
-- remove listeners
--
function Piece:pause()
--{{{
    if self:getState() ~= 'started' then return end
    self.blocking = true
    -- TODO: stop listening
    self.layer:removeEventListener('touch', self)
    self.layer:removeEventListener('tap', self)
    -- ...
    self:setState('STOPPED')
--}}}
end

-- ---
-- main program returned to this progress/app, wake up
--
function Piece:resume()
--{{{
    if self:getState() ~= 'STOPPED' then return false end
    self.blocking = false
    -- TODO: restore listeners
    self.layer:removeEventListener('touch', self)
    self.layer:removeEventListener('tap', self)
    -- ...
    self:setState('STARTED')
--}}}
end

-- ---
-- terminate pictorial view app, execute on exist
--
function Piece:stop()
--{{{
    -- TODO: stop listening
    self.layer:removeEventListener('touch', self)
    self.layer:removeEventListener('tap', self)
    -- ...
    --self:cleanup()
    self:setState('STOPPED')
    d(self.name..' '..self:getState())
    --self:cleanup()
--}}}
end

return Piece