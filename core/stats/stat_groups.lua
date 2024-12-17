-- Needed for earlier portions of the code
FlowerPot.addStatType({
    key = "times_used",
    display_txt = {
        button = "b_flowpot_times_used_short",
        full = "b_flowpot_times_used_expand",
    },
    valid_stat_groups = {["consumable_usage"] = true},
    create_stat_table = function(self, stat_group_info)
        return {key = stat_group_info.key, count = stat_group_info.count}
    end,
})

-- Stat Groups
for i, v in ipairs({
    {set = "Joker", key = "joker_usage"}, 
    {set = "Voucher", key = "voucher_usage"}, 
    {set = "Tarot", key = "tarot_usage", profile_key = "consumeable_usage"}, 
    {set = "Planet", key = "planet_usage", profile_key = "consumeable_usage"}, 
    {set = "Spectral", key = "spectral_usage", profile_key = "consumeable_usage"}}) do
    if v.profile_key and v.profile_key == "consumeable_usage" then FlowerPot.stat_types["times_used"].valid_stat_groups[v.key] = true end
    FlowerPot.addStatGroup({
        key = v.key,
        folder_dir = {"Cards"},
        file_name = v.key, 
        stat_set = v.set,
        create_data_table = function(self, format)
            local card_type_stats = copy_table(G.PROFILES[G.SETTINGS.profile][v.profile_key or v.key])

            if next(card_type_stats) then
                local data_table = {}

                for k, vv in pairs(card_type_stats) do
                    if G.P_CENTERS[k] and (not self.stat_set or G.P_CENTERS[k].set == self.stat_set) then
                        local card_table = vv
                        card_table["key"] = k
                        card_table["name"] = localize{type = 'name_text', key = k, set = self.stat_set}
                        -- Reconstruct wins as total_wins to not crash from saving as JSON
                        card_table.total_wins = 0
                        if SMODS and SMODS.can_load then
                            for _, vvv in pairs(card_table.wins_by_key or {}) do
                                card_table.total_wins = card_table.total_wins + vvv
                            end
                        else
                            for _, vvv in ipairs(card_table.wins or {}) do
                                card_table.total_wins = card_table.total_wins + vvv
                            end
                        end
                        card_table.wins = nil
                        card_table.wins_by_key = nil
                        card_table.losses = nil
                        card_table.losses_by_key = nil
                        if self.stat_set == "Joker" then 
                            print(card_table.total_wins or 0)
                            card_table.total_wins = card_table.total_wins or 0
                        end
                        data_table[#data_table+1] = card_table
                    end
                end
                table.sort(data_table, function (a, b) return a.count > b.count end )

                return data_table
            end
        end,
        compat = {
            CSV = {
                titles = {
                    v.set, 
                    (v.profile_key) and "Times Used" or (v.set == "Voucher" and "Time Bought") or "Total Rounds", 
                    (v.set == "Joker" or v.set == "Voucher") and "Total Wins"
                },
                data_order = {
                    "name", 
                    "count", 
                    (v.set == "Joker" or v.set == "Voucher") and "total_wins",
                },
            }
        }
    })
end

FlowerPot.stat_types["times_used"].valid_stat_groups["consumeable_usage"] = true
FlowerPot.addStatGroup({
    key = "consumeable_usage",
    folder_dir = {"Cards"},
    file_name = "consumeable_usage",
    create_data_table = function(self, format)
        local card_type_stats = G.PROFILES[G.SETTINGS.profile][self.key]

        if next(card_type_stats) then
            local data_table = {}

            for k, v in pairs(card_type_stats) do
                if G.P_CENTERS[k] then
                    data_table[#data_table+1] = {key = k, name = localize{type = 'name_text', key = k, set = self.stat_set or G.P_CENTERS[k].set}, count = v.count}
                end
            end
            table.sort(data_table, function (a, b) return a.count > b.count end )

            return data_table
        end
    end,
    compat = {
        CSV = {
            titles = {"Consumable", "Times Used"},
            data_order = {"name", "count"},
        }
    }
})
FlowerPot.addStatGroup({
    key = "poker_hands",
    folder_dir = {"Poker Hands"},
    file_name = "poker_hands",
    create_data_table = function(self, format)
        local poker_hand_stats = G.PROFILES[G.SETTINGS.profile].hand_usage

        if next(poker_hand_stats) then
            local data_table = {}

            for k, v in pairs(poker_hand_stats) do
                data_table[#data_table+1] = {key = v.order, name = localize(v.order,'poker_hands'), count = v.count or 0, level = v.level or 1}
            end
            table.sort(data_table, function (a, b) return a.count > b.count end )
        
            return data_table
        end
    end,
    compat = {
        CSV = {
            titles = {"Poker Hand", "Total Played", "Highest lvl"},
            data_order = {"name", "count", "level"},
        }
    }
})

-- Stat Types
FlowerPot.addStatType({
    key = "round_wins",
    display_txt = {
        button = "b_flowpot_rounds_won_short",
        full = "b_flowpot_rounds_won_expand",
    },
    valid_stat_groups = {["joker_usage"] = true},
    create_stat_table = function(self, stat_group_info)
        return {key = stat_group_info.key, count = stat_group_info.count}
    end,
})
FlowerPot.addStatType({
    key = "times_redeemed",
    display_txt = {
        button = "b_flowpot_times_redeemed_short",
        full = "b_flowpot_times_redeemed_expand",
    },
    valid_stat_groups = {["voucher_usage"] = true},
    create_stat_table = function(self, stat_group_info)
        return {key = stat_group_info.key, count = stat_group_info.count}
    end,
})
FlowerPot.addStatType({
    key = "stake_wins",
    display_txt = {
        button = "b_flowpot_times_stake_win_short",
        full = "b_flowpot_times_stake_win_expand",
    },
    valid_stat_groups = {["joker_usage"] = true, ["voucher_usage"] = true},
    create_stat_table = function(self, stat_group_info)
        local total_wins = 0
        for _, v in ipairs(stat_group_info.wins or {}) do
            total_wins = total_wins + v
        end
        return {key = stat_group_info.key, count = stat_group_info.total_wins or total_wins}
    end,
})