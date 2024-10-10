--- STEAMODDED HEADER
--- MOD_NAME: Flower Pot
--- MOD_ID: FlowerPot
--- MOD_AUTHOR: [ItsFlowwey]
--- MOD_DESCRIPTION: Utility + QoL mod, aimed at improved stat display and collection
--- PREFIX: flowpot
--- VERSION: 0.7

SMODS.current_mod.config_tab = function()
    return FlowerPot.config_tab()
end

SMODS.Atlas{key = "modicon", atlas_table = "ASSET_ATLAS", px = 34, py = 34, path = "modicon.png"}