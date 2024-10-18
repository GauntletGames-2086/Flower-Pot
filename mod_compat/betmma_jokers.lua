-- Jimbow (highest chips)
-- Flying Cards (highest xmult)

FlowerPot.rev_lookup_records["j_betm_jokers_jimbow"] = copy_table(FlowerPot.records["highest_chips"])

FlowerPot.rev_lookup_records["j_betm_jokers_flying_cards"] = copy_table(FlowerPot.records["highest_xmult"])
FlowerPot.rev_lookup_records["j_betm_jokers_flying_cards"].check_record = function(self, card)
    return card.ability.extra.x_mult
end