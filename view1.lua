-----------------------------------------------------------------------------------------
--
-- view1.lua
--
-----------------------------------------------------------------------------------------
local imoter = require("classes.imoter")
local myData = require( "classes.mydata" )

local composer = require( "composer" )
local scene = composer.newScene()

local screenW, screenH = display.contentWidth, display.contentHeight
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

-- local imageURI = 'https://t1.onvshen.com:85/gallery/22162/30253/s/0.jpg'
local imageFileName = '0.jpg'

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
	        fitScreen(event.target)
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
	local function displayAlbum()
		-- Get a local reference to the recent weather data
		local response = myData.targetImgURI
		local imgURIs, imgNames = resolveImageFileName( myData.album )

		-- show an alert if the weather data isn't available
		if not response then
			native.showAlert("Oops!", "Forcast information currently not avaialble!", { "Okay" } )
			return false -- no need to try and run the rest of the function if we don't have our forecast.the
		end
		for i =1, #imgURIs do
			display.loadRemoteImage( imgURIs[i], "GET", networkListener, imgNames[i], system.TemporaryDirectory, 50, 50 )
		end
	end

	return displayAlbum
end

function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- create a white background to fill screen
	local background = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
	background:setFillColor( 1 )	-- white

	-- create some text
	local title = display.newText( "First View", display.contentCenterX, 125, native.systemFont, 32 )
	title:setFillColor( 0 )	-- black

	local newTextParams = { text = "Loaded by the first tab's\n\"onPress\" listener\nspecified in the 'tabButtons' table",
						x = display.contentCenterX + 10,
						y = title.y + 215,
						width = 310, height = 310,
						font = native.systemFont, fontSize = 14,
						align = "center" }
	local summary = display.newText( newTextParams )
	summary:setFillColor( 0 ) -- black

	imoter.fetchWeather(initAlbum(createImgLoader(sceneGroup)));

	-- all objects must be added to group (e.g. self.view)
	sceneGroup:insert( background )
	sceneGroup:insert( title )
	sceneGroup:insert( summary )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		--
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end
end

function scene:destroy( event )
	local sceneGroup = self.view

	-- Called prior to the removal of scene's "view" (sceneGroup)
	--
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene