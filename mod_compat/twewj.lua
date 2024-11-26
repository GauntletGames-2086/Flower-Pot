-- Storm Warning (highest chips) [x]
-- Impact Warning (highest chips) [x]
-- Shout! (longest streak, custom) [x]
-- Diss (highest mult) [x]
-- Fly Line (highest mult) [x]
-- Cosmic Pull (highest mult) [x]
-- Skull Rabbit (highest xmult)
-- Lolita Chopper (highest xmult) [x]
-- Eyes Full of Hope (highest consumable slots, custom) [x]
-- Demon's Hatred (highest mult) [x]

FlowerPot.addRecord({
    key = "highest_streak",
    cards = {
        "j_twewj_shout",
    },
    default = 0,
    add_tooltips = function(self, info_queue, card_progress, card)
        info_queue[#info_queue+1] = {key = 'record_highest_streak', set = 'Other', vars = {to_number((card_progress.records and card_progress.records.highest_streak) or self.default)}}
    end,
    check_record = function(self, card)
        return card.ability.extra.currentStreak
    end
})

FlowerPot.addRecord({
    key = "highest_consumable_slots",
    cards = {
        "j_twewj_eyesFullOfHope",
    },
    default = 0,
    add_tooltips = function(self, info_queue, card_progress, card)
        info_queue[#info_queue+1] = {key = 'record_highest_consumable_slots', set = 'Other', vars = {to_number((card_progress.records and card_progress.records.highest_consumable_slots) or self.default)}}
    end,
    check_record = function(self, card)
        return card.ability.extra.bonusConsumable
    end
})

FlowerPot.rev_lookup_records["j_twewj_stormWarning"] = copy_table(FlowerPot.records["highest_chips"])
FlowerPot.rev_lookup_records["j_twewj_impactWarning"] = copy_table(FlowerPot.records["highest_chips"])

FlowerPot.rev_lookup_records["j_twewj_diss"] = copy_table(FlowerPot.records["highest_mult"])
FlowerPot.rev_lookup_records["j_twewj_diss"].check_record = function(self, card)
    return card.ability.extra.mult
end
FlowerPot.rev_lookup_records["j_twewj_flyLine"] = copy_table(FlowerPot.records["highest_mult"])
FlowerPot.rev_lookup_records["j_twewj_flyLine"].check_record = function(self, card)
    return card.ability.extra.mult
end
FlowerPot.rev_lookup_records["j_twewj_cosmicPull"] = copy_table(FlowerPot.records["highest_mult"])
FlowerPot.rev_lookup_records["j_twewj_cosmicPull"].check_record = function(self, card)
    return card.ability.extra.mult
end
FlowerPot.rev_lookup_records["j_twewj_demonsHatred"] = copy_table(FlowerPot.records["highest_mult"])
FlowerPot.rev_lookup_records["j_twewj_demonsHatred"].check_record = function(self, card)
    return card.ability.extra.mult
end

FlowerPot.rev_lookup_records["j_twewj_skullRabbit"] = copy_table(FlowerPot.records["highest_xmult"])
FlowerPot.rev_lookup_records["j_twewj_skullRabbit"].check_record = function(self, card)
    return card.ability.extra.xMult
end
FlowerPot.rev_lookup_records["j_twewj_lolitaChopper"] = copy_table(FlowerPot.records["highest_xmult"])
FlowerPot.rev_lookup_records["j_twewj_lolitaChopper"].check_record = function(self, card)
    return card.ability.extra.xMult
end