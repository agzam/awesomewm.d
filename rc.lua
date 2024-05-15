home = os.getenv("HOME")
cfg_dir = home .. "/.config/awesome/"

package.cpath =
  package.cpath .. ";"
  .. home .. "/.luarocks/lib/lua/5.3/?.so;"
  .. home .. "/.luarocks/lib/lua/5.3/?/?.so"

package.path =
  package.path .. ";"
  .. home .. "/.luarocks/share/lua/5.3/?.lua;"
  .. home .. "/.luarocks/share/lua/5.3/?/?.lua;"
  .. cfg_dir .. "lib/?.lua;"
  .. cfg_dir .. "lib/?/init.lua;"


fennel = require("fennel")

-- fennel.path = package.path .. ";" .. cfg_dir .. "src/?.lua;" .. cfg_dir .. "lib/?.lua;"
fennel.path = fennel.path .. ";"
  .. package.path .. ";"
  .. cfg_dir .. "src/?.fnl;"
  .. cfg_dir .. "lib/?/?.fnl;"
  .. cfg_dir .. "lib/?.fnl;"

fennel["macro-path"] = cfg_dir .. "src/?.fnl;"
  .. cfg_dir .. "lib/?.fnl;"

-- searcher = fennel.makeSearcher({
--     correlate = true,
--     -- useMetadata = true,
--     -- disable strict checking.
--     -- TODO: assemble a full list of globals so we can enable this

--     compilerEnv = _G
--     -- allowedGlobals = false
-- })

table.insert(package.loaders or package.searchers, fennel.searcher)
debug.traceback = fennel.traceback

require("_init")
