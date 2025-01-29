for _, path in ipairs {
    "core/ui/stats_menu.lua",
    "core/ui/card_stats.lua",
    "core/ui/poker_hands.lua",
} do
	assert(load(FP_NFS.read(FlowerPot.path_to_self()..path), ('=[FlowerPot-UI _ "%s"]'):format(path)))()
end