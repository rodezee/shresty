-- module
local _M = {}
-- json
local cjson = require "cjson"
-- jwt cookie
local jwt_obj = { header={typ="JWT", alg="HS256"}, payload={} }
local jwt = require "resty.jwt"
local ck = require "resty.cookie"
local cookie, err = ck:new()
if not cookie then
    ngx.log(ngx.ERR, err)
    return
end

local function isempty(s)
  return s == nil or s == ''
end

local function jwt_init(jwt_secret)
  -- get jwt cookie
  local field, al = cookie:get("jwt")
  if field then
    -- verify existing jwt object
    local jwt_verified = jwt:verify(jwt_secret, field)
    -- save payload of the exitsting jwt
    jwt_obj['payload'] = jwt_verified['payload']
    --ngx.log(ngx.ALERT, "verified existing jwt_obj" .. "=" .. cjson.encode(jwt_obj))
  else
    -- no jwt found yet, accept the one defined at the top of this document
    --ngx.log(ngx.ALERT, "using defined jwt_obj" .. "=" .. cjson.encode(jwt_obj))
    --ngx.log(ngx.ALERT, al)
  end
end

local function jwt_set(name, value, jwt_secret)
  -- add the given name/value to the jwt content
  jwt_obj['payload'][name] = value

  -- sign jwt object
  local jwt_token = jwt:sign(jwt_secret, jwt_obj)
  --ngx.log(ngx.ALERT, "jwt_token" .. "=" .. cjson.encode(jwt_token))

  -- save jwt cookie
  local ok, err = cookie:set({
    key = "jwt",
    value = jwt_token,
    path = "/",
    httponly = true,
    domain = ngx.var.host,
    max_age = 86400,
    samesite = "Strict"
  })
  if not ok then
      ngx.log(ngx.ERR, err)
      return
  end
end

local function jwt_fini()

end

function _M.query(command, username, userpassword, basicauth, jwt_secret, loggerON)
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

  local exec = require 'resty.exec'
  local prog = exec.new('/tmp/exec.sock')

  -- CONNECT SHELL
  local success, err = pg:connect()
  if err then
    if err == "connection refused" then
      ngx.status = 500
      ngx.print( "database connection refused, wrong port, host or db specified" )
    elseif err == "authentication exchange unsuccessful" then
      ngx.status = 401
      ngx.header['WWW-Authenticate'] = 'Basic realm="Postgresty Authorization", charset="UTF-8"'
      ngx.print( cjson.encode(err) )
    else -- unknown connection error
      ngx.status = 400
      ngx.print( cjson.encode(err) )      
    end
  else
    jwt_init(jwt_secret)
    jwt_set("user", username, jwt_secret)
    jwt_fini(jwt_secret)
    -- RUN COMMAND
    local result, erronoq = pg:query(SQL);
    if erronoq and type(erronoq) ~= 'number' then
      if erronoq:match("ERROR: permission denied for(.*)") then
        ngx.status = 401
      else
        ngx.status = 404
      end
      ngx.print( cjson.encode(erronoq) )
    else
      ngx.status = 200
      ngx.print( cjson.encode(result) )
    end
  end

end

return _M
