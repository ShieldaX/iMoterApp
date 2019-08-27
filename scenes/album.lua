----------------------------------------------------------------------------------
--      Main App
--      Scene notes
---------------------------------------------------------------------------------
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

local fontDMFT = 'assets/fonts/DMFT1541427649707.ttf'
local fontSHSans = 'assets/fonts/SourceHanSansK-Regular.ttf'
local fontSHSansBold = 'assets/fonts/SourceHanSansK-Bold.ttf'
local fontMorganiteBook = 'assets/fonts/Morganite-Book-4.ttf'
local fontMorganiteSemiBold = 'assets/fonts/Morganite-SemiBold-9.ttf'
local fontZcoolHuangYou = 'assets/fonts/站酷庆科黄油体.ttf'

local colorHex = require('libs.convertcolor').hex
local widget = require( "widget" )
local util = require 'util'
local d = util.print_r

local inspect = require('libs.inspect')
local iMoterAPI = require( "classes.iMoter" )

--local mui = require( "materialui.mui" )
local AlbumView = require("views.album")
--local Tag = require("views.album_tag")
local HeaderView = require("views.header")
local Card = require 'views.album_card'

-- mui
--local muiData = require( "materialui.mui-data" )

----------------------------------------------------------------------------------
--
--      NOTE:
--
--      Code outside of listener functions (below) will only be executed once,
--      unless storyboard.removeScene() is called.
--
---------------------------------------------------------------------------------
local scene = composer.newScene()
-- Our modules
local APP = require( "classes.application" )
--local utility = require( "libs.utility" )
local mui = require( "materialui.mui" )
local iMoter = iMoterAPI:new()

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

function scene:showInfo(album)
  local cardOpts = album
  cardOpts.name = 'infoCard'
  self.infoCard = Card:new(cardOpts, self.view)
  self.infoCard:showMoters(album.moters)
end

-- Called when the scene's view does not exist:
function scene:create( event )
	local sceneGroup = self.view
  local params = event.params
  composer.setVariable( "autoRotate", false )
  mui.init(nil, { parent=self.view })
  -----------------------------------------------------------------------------
  --      CREATE display objects and add them to 'group' here.
  local background = display.newRect(sceneGroup, oX, oY, vW, vH)
  background:setFillColor( 0 )
  background:translate( background.contentWidth*0.5, background.contentHeight*0.5 )
  
  self.header = HeaderView:new({name = 'NavBar'}, sceneGroup)
  
  local album_id = params.album_id
  local _title = params.title
  local index = params.index or 1
  _title = _title:gsub("%d+%.%d+%.%d+", '', 1)
  local title = util.GetMaxLenString(_title, 30)
  local function openAlbumWithData(res)
    if not res or not res.data then
      native.showAlert("Oops!", "This album currently not avaialble!", { "Okay" } )
      return false -- no need to try and run the rest of the function if we don't have our forecast.the
    end
    local _album = res.data.album
--    d(_album)
    if _album.publisher then
      local publisher = '优の艺' or _album.publisher.name
      self.header.elements.navBar:setLabel(publisher)
    end
    APP.albumView = AlbumView:new(_album, sceneGroup)
    APP.albumView:open(index)
    self:showInfo(_album)
    self.header.layer:toFront()
  end
  iMoter:getAlbumById(album_id, openAlbumWithData)
  APP:sceneForwards(params)
--  local prevScene = APP.previousScene()
--  local _currentScene = APP.currentScene()
--  local currentSceneName = composer.getSceneName('current')
--  local sceneToRemove = composer.getVariable('sceneToRemove')
--  if not sceneToRemove then
--    APP.pushScene({name = currentSceneName, params = params})
--  end
  -----------------------------------------------------------------------------
end

-- Called BEFORE scene has moved onscreen:
function scene:show( event )
	local sceneGroup = self.view
  local phase = event.phase
  local params = event.params
  if ( phase == "will" ) then
--    local _title = params.title
--    _title = _title:gsub("%d+%.%d+%.%d+", '', 1)
--    local title = util.GetMaxLenString(_title, 30)
    --self.header.elements.navBar:setLabel(title)
    APP.Footer:hide()
  elseif ( phase == "did" ) then
    if self.infoCard then
      self.infoCard:show()
    end
    d('album showing...')
    local sceneToRemove = composer.getVariable('sceneToRemove')
    if sceneToRemove then
      composer.removeScene(sceneToRemove)
      composer.setVariable('sceneToRemove', false)
    end
    APP._scenes()
  end
end

function scene:hide( event )
	local sceneGroup = self.view
	-- nothing to do here
  if ( phase == "will" ) then

  elseif ( phase == "did" ) then
    local sceneName = APP.popScene().name
    d('POP:')
    d(sceneName)
    composer.removeScene(sceneName)
  end
end

function scene:destroy( event )
	local sceneGroup = self.view
  --network.cancel(self.requestId)
  self.header:cleanup()
  self.infoCard:stop()
  APP.albumView:stop()
  d('Album scene destoried success!')
  --APP.popScene()
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene
