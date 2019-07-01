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

local View = require "libs.view"
local Piece = class('PieceView', View)

function util.resize(obj)
  local ini
  local ratioT = obj.width/obj.height
  d(visibleAspectRatio..':'..ratioT)
  --resize properly
  if visibleAspectRatio >= ratioT then
      ini = vH/obj.height
  else
      ini = vW/obj.width
  end
  obj:scale(ini, ini)
end

Piece.static.directory = system.CachesDirectory

function Piece:initialize(uri, fname, parent, index)
  View.initialize(self)
  --local name = fname:gsub('.jpg', '')
  print('创建图片对象: '..fname)
  self.uri = uri .. '.jpg'
  self.fileName = fname .. '.jpg'
  self.name = fname
  --self.parent = parent
  --self.indexOfAlbum = index
  --if self.state < 10 then View.initialize(self) end
end

function Piece:preload(callback)
  if self.state > self.class.STATUS['INITIALIZED'] then
    return false
  elseif self.state < self.class.STATUS['INITIALIZED'] then
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
        --fitScreenW(_image, 0, 0)
        --_image.x, _image.y = display.screenOriginX, display.screenOriginY
        transition.to( _image, { alpha = 1.0 } )
        self:_attach(_image, 'image')
        self:block()
        --self.layer:toBack()
        self.targetScale = self.elements['image'].xScale
        --d('Target Scale Factor: ' .. self.targetScale)
	    end
	    print ( "event.response.fullPath: ", event.response.fullPath )
	    print ( "event.response.filename: ", event.response.filename )
	    print ( "event.response.baseDirectory: ", event.response.baseDirectory )
      self.fileName = event.response.filename
      self.baseDir = event.response.baseDirectory
      --self.imageView:toBack()
      --self.parent._bg:toBack()
      self:setState('PRELOADED')
      if callback and type(callback) == 'function' then callback() end
	end
  display.loadRemoteImage( self.uri, "GET", networkListener, self.fileName, system.CachesDirectory, oX, oY)
end

function Piece:onImageLoaded()
  d('self.name' .. 'image resource loaded')
end

-- ---
-- Main Touch Handler
--
function Piece:touch(event)
--{{{
    local t = event.target
    local phase = event.phase
    --began
    if ('began' == phase) then
      --self.parent:info(false)
      display.getCurrentStage():setFocus( t )
      t.isFocus = true
      t.yStart = t.y
      t.tStart = event.time
      --t.tLast = event.time
      t.motion = 0
      t.speed = 0
      t.direction = 0
    --focus
    elseif t.isFocus then
      --moved
      if ('moved' == phase) then
        t.tLast = event.time
        -- space passed by touch
        t.motion = event.y - event.yStart
        -- Sync movement
        t.y = t.yStart + t.motion
        -- Detect switching direction
        if t.motion > 0 and t.direction >= 0 then
          t.direction = -1
          self.parent:switchPiece(t.direction)
        elseif t.motion < 0 and t.direction <=0 then
          t.direction = 1
          self.parent:switchPiece(t.direction)
        end
        if math.abs(t.motion) > 0 and self.parent.paintedPieceId and self.parent.elements[self.parent.paintedPieceId] then
          local ratio = (math.abs(t.motion)/vH)*.1 + .8
          local paintedPiece = self.parent.elements[self.parent.paintedPieceId].layer
          --local paintedPieceImage = self.parent.elements[self.parent.paintedPieceId].elements.image
          if paintedPieceImage then
            paintedPieceImage.xScale, paintedPieceImage.yScale = ratio, ratio
            util.center(paintedPieceImage)
          end
          paintedPiece.xScale, paintedPiece.yScale = ratio, ratio
          util.center(paintedPiece)
          self.parent.elements[self.parent.paintedPieceId].layer.alpha = math.abs(t.motion)/(vH*1.2)
        end
      --ended or cancelled
      elseif ('ended' == phase or 'cancelled' == phase) then
        local transT = 600
        local ease = easing.outExpo
        -- detect flick
        if t.tLast and (event.time - t.tLast) < 100 then t.flick = true else t.flick = false end
        if (t.flick or (math.abs(t.motion) > vH*.4 and math.abs(t.direction) ~= 0)) and self.parent.paintedPieceId then
          self.parent:turnOver()
        else
          --ease = easing.inQuad
          transition.to( t, {time = transT, y = 0, transition = ease} )
          -- drop older painted pix if any
          if self.parent.paintedPieceId and self.parent.elements[self.parent.paintedPieceId] then
            local _target = self.parent.elements[self.parent.paintedPieceId]
            --transition.to(_target.elements['shade'], {time = transT, alpha = 1, transition = ease})
            transition.to(_target.layer, {
                time = transT,
                x = 64, y = 96,
                xScale = 0.8, yScale = 0.8,
                transition = ease,
                onComplete = function() self.parent:turnOut() end
              })
          end
        end
        display.getCurrentStage():setFocus( nil )
        t.isFocus = false
      end
    end
    --
    return true
--}}}
end

-- add tap listeners
function Piece:tap()
	d('board')
	--self.parent:board()
end

-- ---
-- blocking Piece on load
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
  layer.alpha = 0.1
  self.blocking = true
  --self.layer.xScale = self.targetScale * 0.618
  --self.layer.yScale = self.targetScale * 0.618
end

-- ---
-- unblock Pix after loading
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
  --local reImage = display.newImage( self.parent, self.fileName, self.baseDir )
  --fitScreenW(reImage)
end

-- ---
-- begin to receive touch or tap events, then give reflection back properly
--
function Piece:start()
--{{{
    d(self.name..' '..self:getState())
    if self.state > 30 then
      d(self.name .. ' already started!')
      return false 
    end
    if self.state < 20 then
      d(self.name .. ' is not ready to start!')
      return false 
    end
    if self.blocking == true then
      self:unblock()
    end
    -- add touch event handler
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