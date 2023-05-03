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

  -- This will read all of the output, as always
  local result2 = handle2:read('*all')
  local rc = {handle2:close()}
  if rc[1] then
    ngx.print(result2)
  else
    ngx.status = 404
    ngx.print("Error during execution of shell: "..rc[3])
  end
  --ngx.say("\n2: "..rc[2].."\n3: "..rc[3])

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
