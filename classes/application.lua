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

function M.currentScene(key, value)
  local scene = scenes[#scenes]
  if key then scene[key] = value end
  return scene
end

function M.previousScene()
  table.remove(scenes)
  return scenes[#scenes]
end

return M
