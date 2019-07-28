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
Piece.STATUS.RELEASED = 100

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

function util.autoRotate(obj, clockwise)
  if obj.width/obj.height > 1 then
    d(clockwise)
    clockwise = type(clockwise) == 'number' and clockwise or 1
    obj.rotation = 90*clockwise
    local targetRatio = vW/(obj.height*obj.yScale)
    obj:scale(targetRatio, targetRatio)
  end
end

-- ---
-- Default Image File Cache Directory
-- TODO: Try to load piece image from this dir firstly
Piece.static.DEFAULT_DIRECTORY = system.CachesDirectory

function Piece:initialize(uri, name, parent)
  View.initialize(self)
  assert(self.layer, 'Piece H View Initialized Failed!')
  d('创建图片对象: '..name)
  self.uri = uri .. '.jpg'
  self.fileName = name .. '.jpg'
  self.name = name
  d(self.name..' '..self:getState())
end

-- ---
-- Preload Image Display Object
-- Then Try to Start Self if not blocked
--
function Piece:preload()
  if self.state > View.STATUS.INITIALIZED then
    d("Try to preload Piece already @ "..self.getState())
    return false
  end
  -- ------------------
  -- Block view while preloading image
  if self.parent.currentPieceId then
    self.isBlocked = true
  end
  self:signal('onPieceLoad')
  -- Load image
	local function networkListener( event )
    if event.phase == 'began' or event.phase == 'progress' then
      self._requestId = event.requestId
      print('Image is Loading')
      return
    elseif event.phase == 'ended' then
      print('Image Loading Ended')
      self._requestId = nil
    else
      d(event)
    end
    if ( event.isError ) then
      print ( "Network error - piece image download failed" )
      native.showAlert("网络错误!", "网络似乎开小差了，联网后重试!", { "好的" } )
      return false
    else
      self:signal('onPieceLoaded')
      local _image = event.target
      util.resize(_image)
      if self.parent.pieceAutoRotate then util.autoRotate(_image, self.parent.pieceAutoRotate) end
      _image.alpha = 0
      util.center(_image)
      self.imageTransiton = transition.to( _image, { alpha = 1.0 } )
      self:_attach(_image, 'image')
    end
    self.fileName = event.response.filename
    self.baseDir = event.response.baseDirectory
    -- When self is RELEASED by Parent View
    if self.state >= View.STATUS.PRELOADED then
      self:cleanup()
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
  display.loadRemoteImage( self.uri, "GET", networkListener, {progress = false}, self.fileName, Piece.DEFAULT_DIRECTORY, oX, oY)
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
      _t.xStart = _t.x
      _t.tStart = event.time
      --t.tLast = event.time
      _t.motion = 0
      --_t.speed = 0
      _t.direction = 0
      _t.flick = false
    --focus
      --self:blurGaussian()
    elseif _t.isFocus then
      local album = self.parent
      --moved
      if ('moved' == phase) then
        _t.tLast = event.time
        -- Distence passed by touch
        _t.motion = event.x - event.xStart
        -- Sync Movement
        _t.x = _t.xStart + _t.motion
        -- Detect switching direction then load Right Next Piece in Memory, Painting...
        if _t.motion > 20 and _t.direction >= 0 then
          _t.direction = -1
          album:switchPiece(_t.direction)
        elseif _t.motion < -20 and _t.direction <=0 then
          _t.direction = 1
          album:switchPiece(_t.direction)
        end
        --self:distort(_t.direction)
        -- Sync Scale and Alpha to View's Layer
        if math.abs(_t.motion) > 0 and album.paintedPieceId and album.elements[album.paintedPieceId] then
          local ratio = (math.abs(_t.motion)/vH)*.1 + .8 -- Fading Ratio: 0.8 is Base Scale Factor Number
          local paintedPiece = album.elements[album.paintedPieceId].layer
          paintedPiece.xScale, paintedPiece.yScale = ratio, ratio
          util.center(paintedPiece)
          paintedPiece.alpha = math.abs(_t.motion)/(vH*1.2)
        end
        if math.abs(_t.motion) >= vH*.0618 then
          local _multi = math.abs(_t.motion)/vH
          self:blurGaussian(_multi*15)
        else
          self:blurGaussian(0)
        end
      --ended or cancelled
      elseif ('ended' == phase or 'cancelled' == phase) then
        local transT = 200
        local ease = easing.outExpo
        -- Handle Flicking
        -- if _t.tLast and (event.time - _t.tLast) < 100 then _t.flick = true else _t.flick = false end
        _t.flick = _t.tLast and (event.time - _t.tLast) < 100 and true or false
        local snap = vH*.0618 --TODO: 优化体验以不同屏幕尺寸，避免当屏幕很大时不容易触发Flick翻页
        if (_t.flick and (math.abs(_t.motion) >= snap and math.abs(_t.direction) ~= 0)) and album.paintedPieceId then
          -- -----------------------------------
          -- DEBUG: ---------------------------- 
          if album.elements[album.paintedPieceId].state >= View.STATUS.PRELOADED then
            d('Flicked and Image Preloaded, now Switching')
          else
            d('Flicked but Image Unloaded, switch but should Block')
          end
          -- -----------------------------------
          album:turnOver()
        else -- Cancelled 动作取消 Try to roll back
          d('Touch/Move Action Cancelled, Rolling Back...')
          self:blurGaussian(0)
          --ease = easing.inQuad
          transition.to( _t, {time = transT, x = 0, transition = ease} )
          -- Try to drop Memory Prepainted Piece after???? transition
          if album.paintedPieceId and album.elements[album.paintedPieceId] then
            local _paintedPiece = album.elements[album.paintedPieceId].layer
            transition.to(_paintedPiece, {
                time = transT, alpha = 0,
                x = (.2*vW)*.5, y = (.2*vH)*.5,
                xScale = 0.8, yScale = 0.8,
                transition = ease,
                onComplete = function() d('Time to turn out') album:turnOut() end
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
function Piece:tap(event)
  if not self.baseDir then return end
	self:signal('onPieceTapped', {pieceId = self.fileName, baseDir = self.baseDir})
  return true
end

function Piece:distort(direction, deltaN, time)
  local image = self.elements.image
  if not direction or not image then return end
  local path = image.path
  deltaN  = deltaN or 100
  local _time = time or 100
  if direction == -1 then
    self.distortion = transition.to(path, {time = _time, x1 = deltaN, y1 = deltaN, x4 = -deltaN, y4 = deltaN})
  elseif direction == 1 then
    self.distortion = transition.to(path, {time = _time, x2 = deltaN, y2 = - deltaN, x3 = - deltaN, y3 = - deltaN})
  end
end

function Piece:blurGaussian(multi)
  local object = self.elements.image
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

-- ---
-- Blocking Piece while Loading
--
function Piece:block()
  if self.isBlocked == true then return false end
  local layer = self.layer
  layer.alpha = 0.2
  self.isBlocked = true
end

-- ---
-- Unblock Piece After Preloaded
--
function Piece:unblock()
  if self.isBlocked == false then return false end
  self.layer.alpha = 1
  self.isBlocked = false
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
  d('Try to start Piece '..self.name..' @ '..self:getState())
  if (self.state < View.STATUS.PRELOADED) or self.isBlocked then
    d(self.name .. ' is Not Ready to Start!')
    return false
  elseif (self.state >= View.STATUS.STARTED) then
    d(self.name .. ' already Started!')
    return false
  end
  
  if (self.state <= View.STATUS.STOPPED) then
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
    self.isBlocked = true
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
    self.isBlocked = false
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
    if self.state < View.STATUS.PRELOADED then d('Try to STOP a piece view NOT Preloaded!!!') end
    self.isBlocked = true
    self.layer:removeEventListener('touch', self)
    self.layer:removeEventListener('tap', self)
    self:setState('STOPPED')
    d(self.name..' '..self:getState())
--}}}
end

-- ---
-- @Overried 由于远程资源加载延迟，Piece View的视图清空需要
--           在PRELOADED状态后实际执行视图清空
function Piece:cleanup()
  if self.state < View.STATUS.PRELOADED then
    d('Try to cleanup ' .. self.name .. ' @ ' .. self:getState())
    self:setState('RELEASED')
    return false
  end
  d('CLEANUP ' .. self.name..' @ '..self:getState())
  View.cleanup(self)
  self:setState('DESTROYED')
  d(self.name..' @ '..self:getState())
end

return Piece