
FlowerPot.addRecord({
    key = "highest_chips",
    cards = {
        "j_runner",
        "j_square",
        "j_castle",
        "j_wee",
        "j_bull",
        "j_stone",
    },
    default = 0,
    add_tooltips = function(self, info_queue, card_progress, card)
        info_queue[#info_queue+1] = {key = 'record_highest_chips', set = 'Other', vars = {(card_progress.records and card_progress.records.highest_chips) or self.default}}
    end,
    check_record = function(self, card)
        return card.ability.extra.chips
    end
})
FlowerPot.addRecord({
    key = "highest_mult",
    cards = {
        "j_ceremonial",
        "j_ride_the_bus",
        "j_green_joker",
        "j_red_card",
        "j_fortune_teller",
        "j_flash",
        "j_trousers",
        "j_bootstraps",
    },
    default = 0,
    add_tooltips = function(self, info_queue, card_progress, card)
        info_queue[#info_queue+1] = {key = 'record_highest_mult', set = 'Other', vars = {(card_progress.records and card_progress.records.highest_mult) or self.default}}
    end,
    check_record = function(self, card)
        return card.ability.mult
    end
})
FlowerPot.addRecord({
    key = "highest_xmult",
    cards = {
        "j_steel_joker",
        "j_constellation",
        "j_madness",
        "j_vampire",
        "j_hologram",
        "j_obelisk",
        "j_lucky_cat",
        "j_campfire",
        "j_throwback",
        "j_glass",
        "j_caino",
        "j_yorick",
    },
    default = 1,
    add_tooltips = function(self, info_queue, card_progress, card)
        info_queue[#info_queue+1] = {key = 'record_highest_xmult', set = 'Other', vars = {(card_progress.records and card_progress.records.highest_xmult) or self.default}}
    end,
    check_record = function(self, card)
        return card.ability.x_mult
    end
})
FlowerPot.addRecord({
    key = "highest_sell_value",
    cards = {
        "j_egg",
    },
    default = 0,
    add_tooltips = function(self, info_queue, card_progress, card)
        info_queue[#info_queue+1] = {key = 'record_highest_sell_value', set = 'Other', vars = {(card_progress.records and card_progress.records.highest_sell_value) or self.default}}
    end,
    check_record = function(self, card)
        return card.sell_cost
    end
})
FlowerPot.addRecord({
    key = "highest_dollar",
    cards = {
        "j_rocket",
        "j_cloud_9",
    },
    default = 0,
    add_tooltips = function(self, info_queue, card_progress, card)
        info_queue[#info_queue+1] = {key = 'record_highest_dollar', set = 'Other', vars = {(card_progress.records and card_progress.records.highest_dollar) or self.default}}
    end,
    check_record = function(self, card)
        return card.ability.extra.dollars
    end
})

-- Edits to above records for specific jokers
FlowerPot.rev_lookup_records["j_bull"].check_record = function(self, card)
    return card.ability.extra*math.max(0,(G.GAME.dollars + (G.GAME.dollar_buffer or 0)))
end
FlowerPot.rev_lookup_records["j_stone"].check_record = function(self, card)
    return card.ability.extra*card.ability.stone_tally
end

FlowerPot.rev_lookup_records["j_fortune_teller"].check_record = function(self, card)
    return G.GAME.consumeable_usage_total.tarot
end
FlowerPot.rev_lookup_records["j_bootstraps"].check_record = function(self, card)
    return card.ability.extra.mult*math.floor((G.GAME.dollars + (G.GAME.dollar_buffer or 0))/card.ability.extra.dollars)
end

FlowerPot.rev_lookup_records["j_steel_joker"].check_record = function(self, card)
    return 1 + card.ability.extra*card.ability.steel_tally
end
FlowerPot.rev_lookup_records["j_caino"].check_record = function(self, card)
    return card.ability.caino_xmult
end

FlowerPot.rev_lookup_records["j_egg"].default = 2

FlowerPot.rev_lookup_records["j_rocket"].default = 1
FlowerPot.rev_lookup_records["j_rocket"].check_record = function(self, card)
    return card.ability.extra.dollars
end
FlowerPot.rev_lookup_records["j_cloud_9"].default = 4
FlowerPot.rev_lookup_records["j_cloud_9"].check_record = function(self, card)
    return card.ability.extra*(card.ability.nine_tally)
end

function FlowerPot.update_record(card_key, record_key, value)
    local card_progress = G.PROFILES[G.SETTINGS.profile].joker_usage[card_key]
    if card_progress then
        card_progress.records = card_progress.records or {}
        if not card_progress.records[record_key] or card_progress.records[record_key] < value then
            card_progress.records[record_key] = to_number(value)
        end
    else
        G.PROFILES[G.SETTINGS.profile].joker_usage[card_key] = {count = 0, order = G.P_CENTERS[card_key].order, wins = {}, losses = {}, wins_by_key = {}, losses_by_key = {}, records = {}}
        G.PROFILES[G.SETTINGS.profile].joker_usage[card_key].records[record_key] = to_number(value)
    end
end

local card_joker_calc = Card.calculate_joker
function Card:calculate_joker(context)
    local ret, callback = card_joker_calc(self, context)
    if FlowerPot.rev_lookup_records[self.config.center.key] then
        print(self.config.center.key)
        local value = FlowerPot.rev_lookup_records[self.config.center.key]:check_record(self)
        local function is_inf(x) return x ~= x end
        if value and to_number(value) ~= math.huge and is_inf(to_number(value)) == false then
            FlowerPot.update_record(self.config.center.key, FlowerPot.rev_lookup_records[self.config.center.key].key, value)
        end
    end
    return ret, callback
end