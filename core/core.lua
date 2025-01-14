local FP_lovely = require("lovely")
FP_NFS = require("FP_nativefs")
FP_JSON = require("FP_json")

FlowerPot = {
    VERSION = "0.7.2",
    GLOBAL = {},
    CONFIG = {
        ["stat_tooltips_enabled"] = true,
    },
    path_to_self = function()
        for k, v in pairs(FP_NFS.getDirectoryItems(FP_lovely.mod_dir)) do
            if v == "Flower-Pot" or string.find(v, "Flower%-Pot") then return FP_lovely.mod_dir.."/"..v.."/" end
        end
    end,
    path_to_stats = function() return love.filesystem.getSaveDirectory().."/Flower Pot - Stat Files/" end,
    save_flowpot_config = function() -- duplicate of SMODS.save_mod_config
        local success = pcall(function()
            NFS.createDirectory('config')
            local serialized = 'return '..serialize(FlowerPot.CONFIG)
            NFS.write(('config/%s.jkr'):format("flowpot"), serialized)
        end)
        return success
    end,
}

for _, path in ipairs {
    "core/api.lua",
    "core/stats.lua",
    "core/ui.lua",
    "core/other.lua",
} do
    assert(load(FP_NFS.read(FlowerPot.path_to_self()..path), ('=[FlowerPot-CORE _ "%s"]'):format(path)))()
end
