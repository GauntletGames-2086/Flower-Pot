-- X-Ray (highest xmult) [x]
-- Shepherd Joker (highest chips) [x]
-- Joker Knight (highest mult) [x]
-- Neon (highest xmult) [x]
-- Magic Wand (highest xmult) [x]

FlowerPot.rev_lookup_records["j_bunc_shepherd"] = copy_table(FlowerPot.records["highest_chips"])

FlowerPot.rev_lookup_records["j_bunc_knight"] = copy_table(FlowerPot.records["highest_mult"])
FlowerPot.rev_lookup_records["j_bunc_knight"].check_record = function(self, card)
    return card.ability.extra.mult
end

FlowerPot.rev_lookup_records["j_bunc_xray"] = copy_table(FlowerPot.records["highest_xmult"])
FlowerPot.rev_lookup_records["j_bunc_xray"].check_record = function(self, card)
    return card.ability.extra.xmult
end
FlowerPot.rev_lookup_records["j_bunc_neon"] = copy_table(FlowerPot.records["highest_xmult"])
FlowerPot.rev_lookup_records["j_bunc_neon"].check_record = function(self, card)
    return card.ability.extra.xmult
end
FlowerPot.rev_lookup_records["j_bunc_magic_wand"] = copy_table(FlowerPot.records["highest_xmult"])
FlowerPot.rev_lookup_records["j_bunc_magic_wand"].check_record = function(self, card)
    return card.ability.extra.xmult
end