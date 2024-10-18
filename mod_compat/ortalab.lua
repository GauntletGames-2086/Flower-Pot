-- Beyond the Mask (highest dollars) [x]
-- Blue Card (highest chips) [x]
-- Evil Eye (highest dollars) [x]
-- Skydiving (highest xmult) [x]
-- Triangle Joker (highest mult) [x]
-- Pickaxe (highest xmult) [x]
-- Revolver (highest chips) [x]
-- Rusty Joker (highest xmult) [x]
-- Sandstone Joker (highest xmult) [x]
-- Shrine (highest xmult) [x]
-- Televangelist (highest xmult) [x]
-- Fine Wine (highest discards, custom) [x]

FlowerPot.addRecord({
    key = "highest_discards",
    cards = {
        "j_ortalab_fine_wine",
    },
    default = 2,
    add_tooltips = function(self, info_queue, card_progress, card)
        info_queue[#info_queue+1] = {key = 'record_highest_discards', set = 'Other', vars = {(card_progress.records and card_progress.records.highest_discards) or self.default}}
    end,
    check_record = function(self, card)
        return card.ability.extra.discards
    end
})

FlowerPot.rev_lookup_records["j_ortalab_blue_card"] = copy_table(FlowerPot.records["highest_chips"])
FlowerPot.rev_lookup_records["j_ortalab_revolver"] = copy_table(FlowerPot.records["highest_chips"])

FlowerPot.rev_lookup_records["j_ortalab_revolver"] = copy_table(FlowerPot.records["highest_mult"])
FlowerPot.rev_lookup_records["j_ortalab_revolver"].check_record = function(self, card)
    return card.ability.extra.mult_total
end

FlowerPot.rev_lookup_records["j_ortalab_skydiving"] = copy_table(FlowerPot.records["highest_xmult"])
FlowerPot.rev_lookup_records["j_ortalab_skydiving"].check_record = function(self, card)
    return card.ability.extra.curr_xmult
end
FlowerPot.rev_lookup_records["j_ortalab_pickaxe"] = copy_table(FlowerPot.records["highest_xmult"])
FlowerPot.rev_lookup_records["j_ortalab_pickaxe"].check_record = function(self, card)
    return card.ability.extra.xmult
end
FlowerPot.rev_lookup_records["j_ortalab_rusty"] = copy_table(FlowerPot.records["highest_xmult"])
FlowerPot.rev_lookup_records["j_ortalab_rusty"].check_record = function(self, card)
    local count = G.playing_cards and calculate_rusty_amount() or 0
    return card.ability.extra.xmult + (card.ability.extra.gain * count)
end
FlowerPot.rev_lookup_records["j_ortalab_sandstone"] = copy_table(FlowerPot.records["highest_xmult"])
FlowerPot.rev_lookup_records["j_ortalab_sandstone"].check_record = function(self, card)
    return card.ability.extra.xmult
end
FlowerPot.rev_lookup_records["j_ortalab_shrine"] = copy_table(FlowerPot.records["highest_xmult"])
FlowerPot.rev_lookup_records["j_ortalab_shrine"].check_record = function(self, card)
    return card.ability.extra.xmult
end
FlowerPot.rev_lookup_records["j_ortalab_televangelist"] = copy_table(FlowerPot.records["highest_xmult"])
FlowerPot.rev_lookup_records["j_ortalab_televangelist"].check_record = function(self, card)
    return card.ability.extra.xmult
end

FlowerPot.rev_lookup_records["j_ortalab_beyond_the_mask"] = copy_table(FlowerPot.records["highest_dollar"])
FlowerPot.rev_lookup_records["j_ortalab_evil_eye"] = copy_table(FlowerPot.records["highest_dollar"])
FlowerPot.rev_lookup_records["j_ortalab_evil_eye"].check_record = function(self, card)
    local count = 0
    for _,_ in pairs(card.ability.extra.spectral_type_sold) do
        count = count + 1
    end
    return card.ability.extra.money*count
end