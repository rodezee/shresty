-- module Shresty
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

function _M.exec(command, cid, exptime, loggerON)
  if isempty(command) then command = "echo 'Shresty'" end--; ngx.log(ngx.ALERT, "command: " .. command)
  if isempty(cid) then cid = 0 end
  if isempty(exptime) then exptime = 0 end
  if isempty(loggerON) then loggerON = false end

  _M.run(command, "/app/www/environments/", cid, exptime)
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
  if isempty(command) then command = "echo \"Shresty\"" end
  if isempty(envdir) then envdir = "/app/www/environments/" end
  if isempty(cid) then cid = 0 end
  if isempty(exptime) then exptime = 0 end
  if isempty(loggerON) then loggerON = false end

  -- DISABLE io stdout buffer
  io.stdout:setvbuf 'no'

  -- CREATE CHROOT ENVIRONMENT
  local cdir = envdir .. cid .. "/"
  if loggerON then ngx.log(ngx.NOTICE, "<br>cdir: " .. cdir) end

  local expfile = envdir .. ".exptime" .. cid
  if loggerON then ngx.log(ngx.NOTICE, "<br>expfile: " .. expfile) end
  local handle1 = io.popen('/bin/mkdir -p "'..cdir..'" && /bin/cp -ra /app/www/chrootfs/* "'..cdir..'"; echo -e "'..exptime..'" > "'..expfile..'"', "r")
  handle1:flush()
  local result1 = handle1:read("*all")
  local rc1 = {handle1:close()}
  if loggerON then ngx.log(ngx.NOTICE, "env_creation: "..result1.." code:"..rc1[3]) end

  -- RUN EXPIRE COMMAND
  local cres = _M.cycle_cleanup(envdir, loggerON)
  if loggerON then ngx.log(ngx.NOTICE, "cycle_cleanup: " .. cres) end

  -- RUN COMMAND
  -- neatify command
  local cmd = command:gsub('"', '\"'):gsub('$', '\$')
  if loggerON then ngx.log(ngx.NOTICE, "command: " .. cmd) end
  local handle2 = io.popen("/usr/sbin/chroot " .. cdir .. " /bin/sh +m -c \"" .. cmd .. "\"", "r")
  local result2 = handle2:read('*all')
  local rc2 = {handle2:close()}
  if rc2[1] then
    ngx.print(result2)
  else
    ngx.status = 404
    ngx.print("Error during execution of shell: "..cmd.."\ncode: "..rc2[3])
  end
  --ngx.say("\n2: "..rc2[2].."\n3: "..rc2[3])

  -- if handle2 == "" or handle2 == nil then
  --     ngx.status = 404
  --     return
  -- end
  -- handle2:flush()
  -- local result2 = handle2:read("*all")
  -- handle2:close()
  -- ngx.print(result2)
end

return _M
