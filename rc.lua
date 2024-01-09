fennel = require("fennel")
cfgDir = os.getenv("HOME") .. "/.config/awesome/"
fennel.path = fennel.path .. ";" .. cfgDir .. "?.fnl;" .. cfgDir .. "?/init.fnl"

searcher = fennel.makeSearcher({
    correlate = true,
    useMetadata = true,
    -- disable strict checking.
    -- TODO: assemble a full list of globals so we can enable this
    allowedGlobals = false
})

table.insert(package.loaders or package.searchers, searcher)
debug.traceback = fennel.traceback

require("config")
