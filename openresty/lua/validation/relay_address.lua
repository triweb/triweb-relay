--
-- The relay_address.lua module provides the _M.is_valid(domain) function that may be used to verify
-- that a domain name points at the address of this relay server (prior to attempting to get the SSL certificate issued).
--
-- A comma-separated list of valid IP addresses for this relay should be present inside the RELAY_ADDRESS env. variable
-- A wildcard (*) entry in the RELAY_ADDRESS list may be used to effectively disable the validation (not recommended).
--

local _M = {}
local http = require "resty.http"
local cjson = require "cjson"

-- Queries the Cloudflare DNS resolver for the A record of the given domain name,
-- and returns a collection of addresses as a LUA table
local function resolve_address(domain)
  local httpc = http.new()
  local ips = {}
  local res, err = httpc:request_uri("https://cloudflare-dns.com/dns-query", {
    method = "GET",
    headers = {
      ["Accept"] = "application/dns-json"
    },
    query = {
      name = domain,
      type = "A"
    }
  })

  if not res or res.status ~= 200 then
    return ips
  end

  local response = cjson.decode(res.body)

  if not (response and response.Answer) then
    return ips
  end

  for _, answer in ipairs(response.Answer) do
    if answer.type == 1 then -- A record type
      table.insert(ips, answer.data)
    end
  end

  return ips
end

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- Validates if the given domain resolves to one of IP addresses passed in RELAY_ADDRESS env. variable
function _M.is_valid(domain)
  local address_whitelist = string.gmatch(os.getenv("RELAY_ADDRESS") or "", "([^,]+)")
  local resolved_addresses = resolve_address(domain)

  local matched = false

  for _,resolved_address in ipairs(resolved_addresses) do
    matched = false

    for whitelisted_address in address_whitelist do
      if (whitelisted_address == '*' or resolved_address == whitelisted_address) then
        ngx.log(ngx.ERR, 'true')
        matched = true
        break
      end
    end

    if not matched then
      return false
    end
  end

  ngx.log(ngx.ERR, matched)
  return matched
end

return _M
