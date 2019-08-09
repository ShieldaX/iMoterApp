local composer = require( "composer" )
local scene = composer.newScene()

local bg

function scene:create( event )
    local sceneGroup = self.view
    bg = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    sceneGroup:insert(bg)
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    local params = event.params or {}

    if ( phase == "will" ) then
        local bgColor = params.bgColor or { 0, 0, 0, 1 }
        bg:setFillColor(unpack(bgColor))
    elseif ( phase == "did" ) then
        local options = {
            effect = params.effect or "crossFade",
            time = params.time or 250,
            params = params.nextParams or {},
        }

        local delayMs = (params.delay ~= nil) and params.delay or 500

        timer.performWithDelay( delayMs, function()
            composer.gotoScene(params.nextSceneName, options)
        end)
    end
end

function scene:hide( event )
    if ( phase == "will" ) then
    elseif ( phase == "did" ) then
    end
end

function scene:destroy( event )
    local sceneGroup = self.view
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene