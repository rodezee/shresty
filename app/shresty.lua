-- module
local _M = {}

local function isempty(s)
  return s == nil or s == ''
end

function _M.exec(command, username, password, basicauth, jwt_secret, loggerON)
  if isempty(command) then command = "echo 'Shresty'" end--; ngx.log(ngx.ALERT, "command: " .. command)
  if isempty(username) then username = os.getenv("SHRESTY_USER") end
  if isempty(password) then password = os.getenv("SHRESTY_PASSWORD") end--; ngx.log(ngx.ALERT, "username: " .. username .. "  userpassword: " .. userpassword)
  if not isempty(basicauth) then
    local str = string.sub(basicauth, 7)
    local dec = ngx.decode_base64(str)
    username = dec:match("(.*):")
    password = dec:match(":(.*)")
  end
  if isempty(loggerON) then loggerON = false end

  local shell = require "shell-games"

  -- EXECUTE COMMAND
  local result, err = shell.run({ "echo", "'hello world'" })

  -- RETURN ERROR
  if err then
    if err == "connection refused" then
      ngx.status = 500
      ngx.print( "database connection refused, wrong port, host or db specified" )
    elseif err == "authentication exchange unsuccessful" then
      ngx.status = 401
      ngx.header['WWW-Authenticate'] = 'Basic realm="Postgresty Authorization", charset="UTF-8"'
      ngx.print( err )
    else -- unknown connection error
      ngx.status = 400
      ngx.print( err )      
    end
  else
    -- RETURN RESULT
    ngx.status = 200
    --ngx.say( result["status"] )
    ngx.say( result["output"] )
  end
end

return _M
