-- Trance The Devil (highest xmult)
-- Bounciest Ball (highest chips) [x]
-- Iconic Icon (highest mult) [x]
-- Clown Bank (highest xmult) [x]
-- Property Damage (highest xmult) [x]
-- Water Slide (highest chips) [x]
-- Joker Voucher (highest xmult)
-- SDM_0 (highest joker slots, custom) [x]

FlowerPot.addRecord({
    key = "highest_joker_slots",
    cards = {
        "j_sdm_0",
    },
    default = 0,
    add_tooltips = function(self, info_queue, card_progress, card)
        info_queue[#info_queue+1] = {key = 'record_highest_joker_slots', set = 'Other', vars = {to_number((card_progress.records and card_progress.records.highest_joker_slots) or self.default)}}
    end,
    check_record = function(self, card)
        return card.ability.extra.jkr_slots
    end
})

FlowerPot.rev_lookup_records["j_sdm_bounciest_ball"] = copy_table(FlowerPot.records["highest_chips"])
FlowerPot.rev_lookup_records["j_sdm_water_slide"] = copy_table(FlowerPot.records["highest_chips"])

FlowerPot.rev_lookup_records["j_sdm_iconic_icon"] = copy_table(FlowerPot.records["highest_mult"])
FlowerPot.rev_lookup_records["j_sdm_iconic_icon"].check_record = function(self, card)
    return card.ability.extra.mult
end

FlowerPot.rev_lookup_records["j_sdm_iconic_icon"] = copy_table(FlowerPot.records["highest_mult"])

FlowerPot.rev_lookup_records["j_sdm_clown_bank"] = copy_table(FlowerPot.records["highest_xmult"])
FlowerPot.rev_lookup_records["j_sdm_clown_bank"].check_record = function(self, card)
    return card.ability.extra.Xmult
end
FlowerPot.rev_lookup_records["j_sdm_property_damage"] = copy_table(FlowerPot.records["highest_xmult"])
FlowerPot.rev_lookup_records["j_sdm_property_damage"].check_record = function(self, card)
    return card.ability.extra.Xmult
end
FlowerPot.rev_lookup_records["j_sdm_joker_voucher"] = copy_table(FlowerPot.records["highest_xmult"])
FlowerPot.rev_lookup_records["j_sdm_joker_voucher"].check_record = function(self, card)
    return 1 + (G.vouchers and #G.vouchers.cards or 0) * card.ability.extra.Xmult_mod
end