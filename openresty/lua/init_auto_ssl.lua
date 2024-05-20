-- Use resty.auto-ssl to automatically generate SSL certificates
--
-- @see https://github.com/auto-ssl/lua-resty-auto-ssl
auto_ssl = (require "resty.auto-ssl").new()

-- Use Redis as a storage adapter for SSL certificates.
--
-- Redis should be configured in persistent mode to ensure that certificates are stored,
-- and not re-issued after each relay reboot.
-- @see https://redis.io/docs/manual/persistence/
auto_ssl:set("storage_adapter", "resty.auto-ssl.storage_adapters.redis")
auto_ssl:set("redis", {
  prefix = "resty.auto_ssl-"
})

-- Define a function to determine which SNI domains to automatically handle
-- and register new certificates for. Defaults to not allowing any domains,
-- so this must be configured.
auto_ssl:set("allow_domain", function(domain)
  local domains_whitelist = require "./validation/allowed_domains"
  local relay_address_whitelist = require "./validation/relay_address"

  return (domains_whitelist.is_valid(domain) and relay_address_whitelist.is_valid(domain))
end)

-- Make the openresty check for needed certificate renewals more often,
-- as otherwise old certificates will result in "failed to set ocsp stapling"
-- @see https://github.com/auto-ssl/lua-resty-auto-ssl/issues/241
-- @see https://github.com/auto-ssl/lua-resty-auto-ssl/issues/239
auto_ssl:set("renew_check_interval", 1800)

auto_ssl:init()
