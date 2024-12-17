FlowerPot.CONFIG = SMODS.current_mod.config

-- Move config tab from main menu to SMODS mod menu
SMODS.current_mod.config_tab = function()
    return FlowerPot.config_tab()
end

SMODS.Atlas{key = "modicon", atlas_table = "ASSET_ATLAS", px = 34, py = 34, path = "modicon.png"}

local mod_compat_keys = {
    ["ortalab"] = "mod_compat/ortalab.lua",
    ["Reverie"] = "mod_compat/reverie.lua",
    ["TWEWY"] = "mod_compat/twewj.lua",
    ["sdm0sstuff"] = "mod_compat/sdm0s_stuff.lua",
    ["BalatroJokersPLUS"] = "mod_compat/balatro_jokers_plus.lua",
    ["BetmmaJokers"] = "mod_compat/betmma_jokers.lua",
    ["Bunco"] = "mod_compat/bunco.lua",
    ["LobotomyCorp"] = "mod_compat/lobcorp.lua",
}

for k, v in pairs(mod_compat_keys) do
    if SMODS.Mods[k] and SMODS.Mods[k].can_load then
        local loaded, err = load(FP_NFS.read(FlowerPot.path_to_self()..v), ('=[FlowerPot-COMPAT _ "%s"]'):format(path))()
        if err then
            sendErrorMessage(('=[FlowerPot-COMPAT _ "%s"] Failed to load: '):format(path)..err)
        end
    end
end