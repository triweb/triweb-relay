--
-- The allowed_domains.lua module provides the _M.is_valid(domain) function that may be used to verify
-- that a domain name is included in a whitelist of domain names that may be served by this relay.
--
-- A comma-separated list of valid domain names should be present inside the RELAY_ADDRESS env. variable.
-- It is possible to use wildcard entries (e.g., *.domain.com, *) on this list.
--

local _M = {}

-- Verifies if the client domain name is on a whitelist
function _M.is_valid(domain)

  local whitelist = os.getenv("ALLOWED_DOMAINS") or ""
  for whitelisted_domain in string.gmatch(whitelist, "([^,]+)") do

    -- an '*' entry in whitelist matches all domains
    if whitelisted_domain == '*' then
      return true

    -- exact match
    elseif domain == whitelisted_domain then
      return true

    -- match wildcards like '*.domain.test'
    elseif string.find(whitelisted_domain, '*') and string.match(domain, "^" .. string.gsub(whitelisted_domain, "%*", "[^.]+") .. "$") then

      local regex_pattern = string.gsub(whitelisted_domain, "%.", "%.")
      regex_pattern = string.gsub(regex_pattern, "%-", "%-")
      regex_pattern = string.gsub(regex_pattern, "%*", "[^.]+")

      if string.match(domain, "^" .. regex_pattern .. "$") then
        return true
      end

    end
  end

  return false
end

return _M
