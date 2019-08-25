-----------------------------------------------------------------------------------------
-- iMoter Class
-----------------------------------------------------------------------------------------
local class = require 'libs.middleclass'
local RESTful = require("classes.RESTful")
local iMoter = class 'iMoter'

----------------------------  -------------------------------------------------------------
function iMoter:initialize()   

  -- Create header for app-level access
  self.headers = {}

  -- Initialize class
  self.restful = RESTful:new(self, "iMoter")

end

-----------------------------------------------------------------------------------------
function iMoter:reloadSession()
  -- Try to reload session on start up
  -- if no session found, then try to refresh session
  -- if session coudn't be refreshed, then require user to relogin
end

function iMoter:onNetworkError(error)
  print(error)
end

-----------------------------------------------------------------------------------------
function iMoter:callMethod(name, t, ...)
   --local arg = {n=select('#', ...), ...}
  local preCallback = nil
  
  if name == "login" then
    preCallback = function(res)
      if res.error then
        print("ERROR on Login")
        print("URL: "..res.url)
      elseif tonumber(res.status) == 200 then
        local token = res.data.token
        print("login success, new access token: " .. token)
        self.headers.Authorization = 'JWT ' .. token
        print(self.headers.Authorization)
      else
        print("login failed, status code: " .. res.status)
      end
    end
  end
  
  -- Make the rest call
  self.restful:call(name, t, self.headers, self.extraArgList, preCallback, ...)
end

return iMoter