-- Theresia (highest chips) [x]
-- Old Lady (highest mult)
-- All-Around Helper (highest xmult)
-- Child of the Galaxy (idk what to classify this so omitting)

FlowerPot.rev_lookup_records["j_lobc_theresia"] = copy_table(FlowerPot.records["highest_chips"])
FlowerPot.rev_lookup_records["j_lobc_theresia"].add_tooltips = function(self, info_queue, card_progress, card)
    if card:check_rounds(4) >= 4 then
        info_queue[#info_queue+1] = {key = 'record_highest_chips', set = 'Other', vars = {(card_progress.records and card_progress.records.highest_chips) or self.default}}
    end
end

FlowerPot.rev_lookup_records["j_lobc_old_lady"] = copy_table(FlowerPot.records["highest_mult"])
FlowerPot.rev_lookup_records["j_lobc_old_lady"].check_record = function(self, card)
    return card.ability.extra.mult
end
FlowerPot.rev_lookup_records["j_lobc_old_lady"].add_tooltips = function(self, info_queue, card_progress, card)
    if card:check_rounds(5) >= 5 then
        info_queue[#info_queue+1] = {key = 'record_highest_mult', set = 'Other', vars = {(card_progress.records and card_progress.records.highest_mult) or self.default}}
    end
end

FlowerPot.rev_lookup_records["j_lobc_all_around_helper"] = copy_table(FlowerPot.records["highest_xmult"])
FlowerPot.rev_lookup_records["j_lobc_all_around_helper"].check_record = function(self, card)
    return card.ability.extra.x_mult
end
FlowerPot.rev_lookup_records["j_lobc_all_around_helper"].add_tooltips = function(self, info_queue, card_progress, card)
    if card:check_rounds(6) >= 6 then
        info_queue[#info_queue+1] = {key = 'record_highest_xmult', set = 'Other', vars = {(card_progress.records and card_progress.records.highest_xmult) or self.default}}
    end
end