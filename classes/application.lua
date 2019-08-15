local util = require 'util'
local d = util.print_r
local composer = require( "composer" )

local M = {}

-- Gather insets (function returns these in the order of top, left, bottom, right)
M.topInset, M.leftInset, M.bottomInset, M.rightInset = display.getSafeAreaInsets()

local scenes = {}

function M.pushScene(scene)
  print(scene.name .. ' pushed to scene history')
  return table.insert(scenes, scene)
end

function M.popScene()
  return table.remove(scenes)
end

function M._scenes()
  d(scenes)
end

function M.currentScene(key, value)
  local scene = scenes[#scenes]
  if key then scene[key] = value end
  return scene
end

function M.previousScene()
  --local scene = table.remove(scenes)
  --print(scene.name .. ' poped from scene history')
  return scenes[#scenes-1]
end

function M:rollBackScene()
  local prevScene = self.previousScene()
  if prevScene then
    d('CBack to :')
    d(prevScene.name)
    local currentSceneName = self.currentScene().name
    if not (currentSceneName == prevScene.name) then
      d('remove '..currentSceneName)
      composer.setVariable('sceneToRemove', currentSceneName)
    else
      d('not remove '..currentSceneName)
    end
    self.popScene()
    composer.gotoScene( prevScene.name, {effect = 'slideRight', time = 420, params = prevScene.params} )
  end
end

return M
