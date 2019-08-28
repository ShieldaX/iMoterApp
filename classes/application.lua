local util = require 'util'
local d = util.print_r
local composer = require( "composer" )

local M = {}

-- Gather insets (function returns these in the order of top, left, bottom, right)
M.topInset, M.leftInset, M.bottomInset, M.rightInset = display.getSafeAreaInsets()

local scenes = {
    home = {},
    search = {},
    mine = {}
  }

function M.pushScene(scene, tab)
  tab = tab or 'home'
  print(scene.name .. ' pushed to scene history')
  return table.insert(scenes[tab], scene)
end

function M.popScene(tab)
  tab = tab or 'home'
  return table.remove(scenes[tab])
end

function M._scenes()
  d(scenes)
end

function M.currentScene(tab, key, value)
  tab = tab or 'home'
  local scenes = scenes[tab]
  local scene = scenes[#scenes]
  if key then scene[key] = value end
  return scene
end

function M.previousScene(tab)
  tab = tab or 'home'
  local scenes = scenes[tab]  
  return scenes[#scenes-1]
end

function M:sceneForwards(params)
  local tab = self:currentTab() or 'home'
  d('当前所在TAB：'..tab)
  local currentSceneName = composer.getSceneName('current')
  local sceneToRemove = composer.getVariable('sceneToRemove')
  if not sceneToRemove then
    self.pushScene({name = currentSceneName, params = params}, tab)
  end
end

function M:currentTab()
  local AppFooter = self.Footer
  return AppFooter and AppFooter.tabSelected
end

function M:sceneBackwards(tab)
  tab = tab or self:currentTab() or 'home'
  d('当前所在TAB：'..tab)
  local prevScene = self.previousScene(tab)
  if prevScene then
    d('CBack to :')
    d(prevScene.name)
    local currentSceneName = self.currentScene(tab).name
    if not (currentSceneName == prevScene.name) then
      d('remove '..currentSceneName)
      composer.setVariable('sceneToRemove', currentSceneName)
    else
      d('not remove '..currentSceneName)
    end
    self.popScene(tab)
    composer.gotoScene( prevScene.name, {effect = 'slideRight', time = 420, params = prevScene.params} )
  end
end

function M:sceneRecycle(sceneName)
  composer.removeScene(sceneName)
end

return M
