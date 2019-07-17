local M = {}

-- Gather insets (function returns these in the order of top, left, bottom, right)
M.topInset, M.leftInset, M.bottomInset, M.rightInset = display.getSafeAreaInsets()

return M
