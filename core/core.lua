local FP_lovely = require("lovely")
FP_NFS = require("FP_nativefs")
FP_JSON = require("FP_json")

FlowerPot = {
    VERSION = "0.7.25",
    GLOBAL = {},
    CONFIG = {
        ["stat_tooltips_enabled"] = true,
        ["voucher_sticker_enabled"] = 1,
    },
    path_to_self = function()
        for k, v in pairs(FP_NFS.getDirectoryItems(FP_lovely.mod_dir)) do
            if v == "Flower-Pot" or string.find(v, "Flower%-Pot") then return FP_lovely.mod_dir.."/"..v.."/" end
        end
    end,
    path_to_stats = function() return love.filesystem.getSaveDirectory().."/Flower Pot - Stat Files/" end,
    save_flowpot_config = function() -- duplicate of SMODS.save_mod_config
        local success = assert(pcall(function()
            FP_NFS.createDirectory(love.filesystem.getSaveDirectory()..'/config')
            local serialized = 'return '..serialize(FlowerPot.CONFIG)
            FP_NFS.write(love.filesystem.getSaveDirectory()..'/config/FlowerPot.jkr', serialized)
        end))
        return success
    end,
    load_flowpot_config = function() -- duplicate of SMODS.load_mod_config
        local s1, config = pcall(function()
            return load(FP_NFS.read(love.filesystem.getSaveDirectory()..'/config/FlowerPot.jkr'), '=[FlowerPot-CONFIG]')()
        end)
        local s2, default_config = pcall(function()
            return load(FP_NFS.read(FlowerPot.path_to_self().."config.lua"), '=[FlowerPot-CONFIG "default"]')()
        end)
        if not s1 or type(config) ~= 'table' then config = {} end
        if not s2 or type(default_config) ~= 'table' then default_config = {} end
        FlowerPot.CONFIG = default_config
        
        local function insert_saved_config(savedCfg, defaultCfg)
            for savedKey, savedVal in pairs(savedCfg) do
                local savedValType = type(savedVal)
                local defaultValType = type(defaultCfg[savedKey])
                if not defaultCfg[savedKey] then
                    defaultCfg[savedKey] = savedVal
                elseif savedValType ~= defaultValType then
                elseif savedValType == "table" and defaultValType == "table" then
                    insert_saved_config(savedVal, defaultCfg[savedKey])
                elseif savedVal ~= defaultCfg[savedKey] then
                    defaultCfg[savedKey] = savedVal
                end
                
            end
        end

        insert_saved_config(config, FlowerPot.CONFIG)
    end
}

if not (SMODS and SMODS.can_load) then FlowerPot.load_flowpot_config() end

for _, path in ipairs {
    "core/api.lua",
    "core/stats.lua",
    "core/ui.lua",
    "core/other.lua",
} do
    assert(load(FP_NFS.read(FlowerPot.path_to_self()..path), ('=[FlowerPot-CORE _ "%s"]'):format(path)), "Flower Pot could not be found. \nPlease ensure that the Flower Pot mod folder is renamed to match the text \"Flower-Pot\".")()
end
