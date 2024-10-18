-- Phantom (highest xmult) [x]
-- Plumber (highest chips) [x]
-- Dagonet (highest xmult)
-- The Pickaxe (highest dollars)

FlowerPot.rev_lookup_records["j_PlusJokers_plumber"] = copy_table(FlowerPot.records["highest_chips"])

FlowerPot.rev_lookup_records["j_PlusJokers_phantom"] = copy_table(FlowerPot.records["highest_xmult"])
FlowerPot.rev_lookup_records["j_PlusJokers_phantom"].check_record = function(self, card)
    return card.ability.extra.Xmult
end
FlowerPot.rev_lookup_records["j_PlusJokers_dagonet"] = copy_table(FlowerPot.records["highest_xmult"])
FlowerPot.rev_lookup_records["j_PlusJokers_dagonet"].check_record = function(self, card)
    return card.ability.extra.Xmult
end

FlowerPot.rev_lookup_records["j_PlusJokers_thepickaxe"] = copy_table(FlowerPot.records["highest_dollars"])
FlowerPot.rev_lookup_records["j_PlusJokers_dagonet"].check_record = function(self, card)
    return card.ability.extra.money
end