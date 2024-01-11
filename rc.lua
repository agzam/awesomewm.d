home = os.getenv("HOME")
cfg_dir = home .. "/.config/awesome/"

package.path = package.path .. ";" .. home .. "/.luarocks/share/lua/5.4/?.lua;" .. home .. "/.luarocks/share/lua/5.4/?/init.lua"
package.cpath = package.cpath .. ";" .. home .. "/.luarocks/lib/lua/5.4/?.so"

fennel = require("fennel")

fennel.path = package.path .. ";" .. cfg_dir .. "src/?.lua;" .. cfg_dir .. "lib/?.lua;"
fennel.path = fennel.path .. ";" .. cfg_dir .. "src/?.fnl;" .. cfg_dir .. "lib/?.fnl;"

searcher = fennel.makeSearcher({
    correlate = true,
    useMetadata = true,
    -- disable strict checking.
    -- TODO: assemble a full list of globals so we can enable this
    allowedGlobals = false
})

table.insert(package.loaders or package.searchers, searcher)
debug.traceback = fennel.traceback

require("_init")
