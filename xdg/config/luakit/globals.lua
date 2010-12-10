globals = {
    homepage         = nil,
    scroll_step      = 20,
    zoom_step        = 0.1,
    max_cmd_history  = 100,
    max_srch_history = 100,
--  http_proxy       = "http://example.com:3128",
    download_dir     = luakit.get_special_dir("DOWNLOAD") or (os.getenv("HOME") .. "/downloads"),
}

globals.useragent = ''

local ca_files = { luakit.data_dir .. "/ca-certificates.crt", "/etc/certs/ca-certificates.crt", "/etc/ssl/certs/ca-certificates.crt" }
for _, ca_file in ipairs(ca_files) do
    if os.exists(ca_file) then
        globals.ca_file = ca_file
        break
    end
end

globals.ssl_strict = false

search_engines = { google = "https://encrypted.google.com/search?num=100&q={0}" }
search_engines.default = search_engines.google

-- Fake the cookie policy enum here
cookie_policy = { always = 0, never = 1, no_third_party = 2 }

-- Per-domain webview properties
domain_props = { --[[
    ["all"] = {
        ["enable-scripts"]          = false,
        ["enable-plugins"]          = false,
        ["enable-private-browsing"] = false,
        ["user-stylesheet-uri"]     = "",
        ["accept-policy"]           = cookie_policy.never,
    },
    ["youtube.com"] = {
        ["enable-scripts"] = true,
        ["enable-plugins"] = true,
    },
    ["lwn.net"] = {
       ["accept-policy"] = cookie_policy.no_third_party,
    },
    ["forums.archlinux.org"] = {
        ["user-stylesheet-uri"]     = luakit.data_dir .. "/styles/dark.css",
        ["enable-private-browsing"] = true,
    }, ]]
}

-- vim: et:sw=4:ts=8:sts=4:tw=80
