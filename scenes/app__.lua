----------------------------------------------------------------------------------
--      Main App
--      Scene notes
---------------------------------------------------------------------------------
local inspect = require('libs.inspect')
local myData = require( "classes.mydata" )
local iMoter = require( "classes.iMoter" )
local composer = require( "composer" )
local mui = require( "materialui.mui" )
local AlbumView = require("views.album")

local scene = composer.newScene()

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

local background = nil
local widget = require( "widget" )

-- mui
local muiData = require( "materialui.mui-data" )

----------------------------------------------------------------------------------
--
--      NOTE:
--
--      Code outside of listener functions (below) will only be executed once,
--      unless storyboard.removeScene() is called.
--
---------------------------------------------------------------------------------

-- Our modules
-- local myData = require( "classes.mydata" )
local utility = require( "libs.utility" )

iMoter = iMoter:new()

-- local forward references should go here --
local function triNum(num)
	local prefix = '00'
	if num >= 10 then
		prefix = '0'
	elseif num >= 100 then
		prefix = ''
	end
	return prefix .. tostring( num )
end

local function resolveImageFileName(album)
	local numPieces, uris, names = 1, {}, {}
	numPieces = album.pieces
	local prefix = 'https://t1.onvshen.com:85/gallery/'
  local subfix = '0.jpg'
  local moterId, albumId = album.moters[1]._id, album._id
  uris[1] = prefix .. moterId .. '/' .. albumId .. '/' .. subfix
  names[1] = moterId .. '_' .. albumId .. '_' .. subfix
	for i = 2, numPieces do
		local idx = i - 1
		uris[i] = prefix .. moterId .. '/' .. albumId .. '/' .. triNum(idx) .. '.jpg'
		names[i] = moterId .. '_' .. albumId .. '_' .. triNum(idx) .. '.jpg'
	end
	return uris, names
end

function fitScreen(p, top, bottom)
	local top = top or 0
	local bottom = bottom or 0
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

local function createImgLoader(sceneGroup)
	local function networkListener( event )
	    if ( event.isError ) then
	        print ( "Network error - download failed" )
	    else
	        event.target.alpha = 0
	        fitScreen(event.target, 0, 40)
	        sceneGroup:insert(event.target)
	        transition.to( event.target, { alpha = 1.0 } )
	    end
	    print ( "event.response.fullPath: ", event.response.fullPath )
	    print ( "event.response.filename: ", event.response.filename )
	    print ( "event.response.baseDirectory: ", event.response.baseDirectory )
	end
	return networkListener
end

local function initAlbum(networkListener)
	local function displayAlbum(i)
		i = i or 1
		-- Get a local reference to the recent weather data
		local response = myData.targetImgURI
		local imgURIs, imgNames = resolveImageFileName( myData.album )

		-- show an alert if the weather data isn't available
		if not response then
			native.showAlert("Oops!", "Album information currently not avaialble!", { "Okay" } )
			return false -- no need to try and run the rest of the function if we don't have our forecast.the
		end
		-- for i =1, #imgURIs do
		-- 	display.loadRemoteImage( imgURIs[i], "GET", networkListener, imgNames[i], system.TemporaryDirectory, 50, 50 )
		-- end
		display.loadRemoteImage( imgURIs[i], "GET", networkListener, imgNames[i], system.TemporaryDirectory, 50, 50 )
	end

	return displayAlbum
end



---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:create( event )
	local sceneGroup = self.view

  --Hide status bar from the beginning
  display.setStatusBar( display.HiddenStatusBar )

  display.setDefault("background", 1, 1, 1)

  mui.init(nil, { parent=self.view })

        -----------------------------------------------------------------------------

        --      CREATE display objects and add them to 'group' here.
        --      Example use-case: Restore 'group' from previously saved state.

  -- Gather insets (function returns these in the order of top, left, bottom, right)
  local topInset, leftInset, bottomInset, rightInset = mui.getSafeAreaInsets()
  -- Create a vector rectangle sized exactly to the "safe area"
  background = display.newRect(
      display.screenOriginX + leftInset,
      display.screenOriginY + topInset,
      display.viewableContentWidth - ( leftInset + rightInset ),
      display.viewableContentHeight - ( topInset + bottomInset )
  )
  background:setFillColor( 0 )
  background:translate( background.contentWidth*0.5, background.contentHeight*0.5 )
  sceneGroup:insert( background )

	--imoter.fetchAlbum(initAlbum(createImgLoader(sceneGroup)))
  iMoter:getAlbumById(
    '29919',
    function(res)
      if not res then
        native.showAlert("Oops!", "This album currently not avaialble!", { "Okay" } )
        return false -- no need to try and run the rest of the function if we don't have our forecast.the
      end
      local _album = res.data.album
      print(inspect(_album))
      local albumView = AlbumView:new(_album, sceneGroup)
      albumView:open()
      timer.performWithDelay(3000, function() albumView:loadPiece(2) end)
      timer.performWithDelay(4000, function() albumView:turnOver() end)
    end
  )
        -----------------------------------------------------------------------------

end



-- Called BEFORE scene has moved onscreen:
function scene:show( event )
	local sceneGroup = self.view

        -----------------------------------------------------------------------------

        --      This event requires build 2012.782 or later.

        -----------------------------------------------------------------------------

end

function scene:hide( event )
	local sceneGroup = self.view
	-- nothing to do here
	if event.phase == "will" then

	end

end

function scene:destroy( event )
	local sceneGroup = self.view
	-- nothing to do here
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene
