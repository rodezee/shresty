-- module
local _M = {}

local function isempty(s)
  return s == nil or s == ''
end

local function str_split(s, sep)
  if sep == nil then
      sep = '%s'
  end 
  local res = {}
  local func = function(w)
      table.insert(res, w)
  end 
  string.gsub(s, '[^'..sep..']+', func)
  return res 
end

function _M.get_client_ip() 

  -- Default to REMOTE_ADDR
  local ip = ngx.var.remote_addr

  local proxy_headers = {
      ngx.var.http_cf_connecting_ip,  -- CloudFlare
      ngx.var.http_incap_client_ip,   -- Incapsula
      ngx.var.http_x_sucuri_clientip, -- Sucuri
      ngx.var.http_x_forwarded_for    -- Any Proxy
  }

  -- Check for alternate headers indicating a forwarded IP address
  for _,proxy_header in ipairs ( proxy_headers ) do
      if proxy_header then
          local forwarded_ips = str_split( proxy_header , ',' )
          local forwarded_ip = forwarded_ips[1]
          if forwarded_ip then
              ip = forwarded_ip
              break
          end
      end
  end

  return ip;
end

function _M.exec(command, username, password, basicauth, cid, loggerON)
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

  -- EXECUTE COMMAND
  local result, err = _M.run(command, cid)

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

function _M.cycle_cleanup(envdir, loggerON)
  if isempty(envdir) then envdir = "/app/www/environments/" end
  if isempty(loggerON) then loggerON = false end
  local handle = io.popen([[
    mkdir -p ]]..envdir..[[;
    cd "]]..envdir..[[" && \
    for d in */ ; do
      EXPFILE=".exptime$(echo -e  "$d" | sed 's/.$//')"
      [ -f $EXPFILE ] && [ $(date +%s) -ge $(cat $EXPFILE) ] && rm -Rf $d $EXPFILE && echo "removed expired env: $d"
    done
  ]])
  handle:flush()
  local result = handle:read("*all")
  handle:close()
  if loggerON then ngx.log(ngx.NOTICE, result) end
  return result
end

function _M.run(command, envdir, cid, exptime, loggerON)
  if isempty(command) then command = "echo \"shresty\"" end
  if isempty(envdir) then envdir = "/app/www/environments/" end
  if isempty(cid) then cid = 0 end
  if isempty(exptime) then exptime = 0 end
  if isempty(loggerON) then loggerON = false end

  -- DISABLE io stdout buffer
  io.stdout:setvbuf 'no'

  -- CREATE CHROOT ENVIRONMENT
  local cdir = envdir .. cid .. "/"
  if loggerON then ngx.say("<br>cdir: " .. cdir) end

  local expfile = envdir .. ".exptime" .. cid
  if loggerON then ngx.say("<br>expfile: " .. expfile) end
  local handle1 = io.popen('/bin/mkdir -p "' .. cdir .. '" && /bin/cp -ra /app/www/chrootfs/* "' .. cdir .. '"; echo -e "' .. exptime .. '" > "' .. expfile .. '"', "r")
  if handle1 == "" or handle1 == nil then
    ngx.status = 404
    return
  end
  handle1:flush()
  local result1 = handle1:read("*all")
  handle1:close()
  ngx.print(result1)

  -- RUN EXPIRE COMMAND
  local cres = _M.cycle_cleanup(envdir, loggerON)
  if loggerON then ngx.say("<br>cycle_cleanup result: " .. cres) end

  -- RUN COMMAND
  if loggerON then ngx.say("<br>run: " .. command) end
  local handle2 = io.popen("/usr/sbin/chroot " .. cdir .. " /bin/sh +m -c \"" .. command .. "\"", "r")
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
