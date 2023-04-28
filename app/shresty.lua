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
  local result, err = shell.run_raw(command, { capture = true })

  -- RETURN ERROR
  if err then
    if err == "connection refused" then
      ngx.status = 500
      ngx.print( "database connection refused, wrong port, host or db specified" )
    elseif err == "authentication exchange unsuccessful" then
      ngx.status = 401
      ngx.header['WWW-Authenticate'] = 'Basic realm="Shresty Authorization", charset="UTF-8"'
      ngx.print( err )
    else -- unknown connection error
      ngx.status = 400
      ngx.print( err )      
    end
  else
    -- RETURN RESULT
    ngx.status = 200
    ngx.say( result["output"] )
  end
end

function _M.run(command, cid, expires, loggerON)
  if isempty(command) then command = "echo \"shresty\"" end
  if isempty(cid) then cid = 0 end
  if isempty(expires) then expires = 0 end
  if isempty(loggerON) then loggerON = false end

  -- DISABLE io stdout buffer
  io.stdout:setvbuf 'no'

  -- CREATE CHROOT ENVIRONMENT
  if loggerON then ngx.say("<br>cid: " .. cid) end
  local cidenv = "/app/www/environments/" .. cid .. "/"
  if loggerON then ngx.say("<br>cidenv: " .. cidenv) end
  local handle0 = io.popen("/bin/mkdir -p " .. cidenv .. " && /bin/cp -ra /app/www/chrootfs/* " .. cidenv, "r")
  if handle0 == "" or handle0 == nil then
    ngx.status = 404
    return
  end
  handle0:flush()
  local result0 = handle0:read("*all")
  handle0:close()
  ngx.print(result0)

  -- RUN EXPIRE COMMAND
  if loggerON then ngx.say("<br>expires: " .. expires) end
  local handle1 = io.popen("/usr/sbin/chroot " .. cidenv .. " /bin/sh +m -c \"sleep " .. expires .. "; rm -Rf " .. cidenv .. "\" &", "r")
  if handle1 == "" or handle1 == nil then
      ngx.status = 404
      return
  end
  --handle1:flush()
  --local result1 = handle1:read("*all")
  --handle1:close()
  --ngx.print(result1)

  -- RUN COMMAND
  if loggerON then ngx.say("<br>run: " .. command) end
  local handle2 = io.popen("/usr/sbin/chroot " .. cidenv .. " /bin/sh +m -c \"" .. command .. "\"", "r")
  if handle2 == "" or handle2 == nil then
      ngx.status = 404
      return
  end
  handle2:flush()
  local result2 = handle2:read("*all")
  handle2:close()
  ngx.print(result2)
end

return _M
