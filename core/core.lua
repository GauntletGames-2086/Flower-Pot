local FP_lovely = require("lovely")
local FP_NFS = require("FP_nativefs")
local FP_JSON = require("FP_json")

FlowerPot = {
    version = 0.5,
    path_to_self = FP_lovely.mod_dir.."/Flower-Pot/",
    path_to_stats = love.filesystem.getSaveDirectory().."/Flower Pot - Stat Files/",
    GLOBAL = {},
}

for _, path in ipairs {
    "core/api.lua",
	"core/stats.lua",
	"core/ui.lua",
    "core/other.lua",
} do
	assert(load(FP_NFS.read(FlowerPot.path_to_self..path), ('=[FlowerPot-CORE _ "%s"]'):format(path)))()
end