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
                        data_table[#data_table+1] = card_table
                    end
                end
                table.sort(data_table, function (a, b) return a.count > b.count end )

                return data_table
            end
        end,
        compat = {
            CSV = {
                titles = {v.set, ("Times %s"):format(v.profile_key and "Used" or "Bought")},
                data_order = {"name", "count"},
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

-- Formats
FlowerPot.addFormat({
    key = "CSV",
    compat_req = {["titles"] = true, ["data_order"] = true},
    write_file = function(self, data_table, stat_group, file_type_path)
        local titles = stat_group.compat.CSV.titles
        local data_order = stat_group.compat.CSV.data_order
        if #titles == 0 then
            for k, v in pairs(data_table[1]) do
                titles[#titles+1] = k
            end
        end
        local csv_data = ""..FlowerPot.data_to_csv(titles, ",").."\r\n"
        for i = 1, #data_table do
            local data_to_convert = {}
            for _, v in ipairs(data_order) do
                data_to_convert[#data_to_convert+1] = data_table[i][v]
            end
            csv_data = csv_data..FlowerPot.data_to_csv(data_to_convert, ",").."\r\n"
        end
        assert(FP_NFS.write(file_type_path..stat_group.file_name..".csv", csv_data))
    end,
})
FlowerPot.addFormat({
    key = "JSON",
    write_file = function(self, data_table, stat_group, file_type_path)
        assert(FP_NFS.write(file_type_path..stat_group.file_name..".json", FP_JSON.encode(data_table)))
    end,
    decode_file = function(self, file_path)
        local asdf = FP_NFS.read(file_path)
        return assert(FP_JSON.decode(FP_NFS.read(file_path)))
    end,
    write_profile = function(self, path_to_format)
        local final_table = {}
        FP_NFS.remove(path_to_format.."profile_stats.json")

        local function recurse_create_final_table(path)
            for _, filename in ipairs(FP_NFS.getDirectoryItems(path)) do
                if filename:match(".json") then 
                    local file_data = self:decode_file(path..filename)
                    final_table[filename:sub(0, -6)] = file_data
                else
                    recurse_create_final_table(path..filename.."/")
                end
            end
        end

        recurse_create_final_table(path_to_format)
        assert(FP_NFS.write(path_to_format.."profile_stats.json", FP_JSON.encode(final_table)))
    end,
})

function FlowerPot.create_profile_folders(profile_name)
    local path_to_profile = FlowerPot.path_to_stats()..profile_name.."/"
    FP_NFS.createDirectory(path_to_profile)

    for k, v in pairs(FlowerPot.formats) do
        local path_to_format = path_to_profile..k.."/"
        FP_NFS.createDirectory(path_to_format)
    
        for kk, vv in pairs(FlowerPot.stat_groups) do
            FP_NFS.createDirectory(FlowerPot.get_stat_group_dir(vv, path_to_format))
        end
    end
end

function FlowerPot.get_stat_group_dir(stat_group, path_to_format)
    local function recurse_create_directory(folder_dir, path, depth)
        depth = depth or 1
        if folder_dir[depth] then 
            return recurse_create_directory(folder_dir, path..folder_dir[depth].."/", depth+1)
        end
        return path.."/"
    end

    return recurse_create_directory(stat_group.folder_dir or {}, path_to_format)
end

function FlowerPot.create_stat_files(stat_group, path, mod)
    for k, v in pairs(FlowerPot.formats) do
        if FlowerPot.check_format_compat(stat_group, v) then
            local data_table = stat_group:create_data_table(v, mod)
            if data_table and type(data_table) == "table" then
                local file_type_path = path..v.key.."/"
                v:write_file(data_table, stat_group, FlowerPot.get_stat_group_dir(stat_group, file_type_path))
            end
        end
    end
end

function FlowerPot.create_complete_profile(profile_folder)
    for k, v in pairs(FlowerPot.formats) do
        if v.write_profile and type(v.write_profile) == "function" then v:write_profile(profile_folder..v.key.."/") end
    end
end

function FlowerPot.check_format_compat(stat_group, format)
    if not format.compat_req then return true end --format has no compat req
    if not stat_group.compat then return false end --stat group does not have compat
    for k, v in pairs(stat_group.compat[format.key] or {}) do
        if not format.compat_req[k] then return false end
    end
    return true
end

function FlowerPot.data_to_csv(str_array, delim)
    assert(type(str_array) == "table", "Flower Pot: Passing non-table as \"str_array\" in \"data_to_csv\" function")
    local final_str = ""
    for _, v in ipairs(str_array) do
        if type(v) == "string" or type(v) == "number" then final_str = final_str..tostring(v)..delim end
    end
    return final_str
end

-- Voucher Win Tracking
function get_voucher_win_sticker(_center, index)
    local voucher_usage = G.PROFILES[G.SETTINGS.profile].voucher_usage[_center.key] or {}
    if voucher_usage.wins then 
        if SMODS and SMODS.can_load then
            local applied = {}
            local _count = 0
            local _stake = nil
            for k, v in pairs(voucher_usage.wins_by_key or {}) do
                SMODS.build_stake_chain(G.P_STAKES[k], applied)
            end
            for i, v in ipairs(G.P_CENTER_POOLS.Stake) do
                if applied[v.order] then
                    _count = _count+1
                    if (v.stake_level or 0) > (_stake and G.P_STAKES[_stake].stake_level or 0) then
                        _stake = v.key
                    end
                end
            end
            if index then return _count end
            if _count > 0 then return G.sticker_map[_stake] end
        else
            local _stake = 0
            for k, v in pairs(G.PROFILES[G.SETTINGS.profile].voucher_usage[_center.key].wins or {}) do
                _stake = math.max(k, _stake)
            end
            if index then return _stake end
            if _stake > 0 then return G.sticker_map[_stake] end
        end
    end
    if index then return 0 end
end

function set_voucher_win()
    for k, v in pairs(G.GAME.used_vouchers) do
        if G.P_CENTERS[k] then
            G.PROFILES[G.SETTINGS.profile].voucher_usage[k] = G.PROFILES[G.SETTINGS.profile].voucher_usage[k] or {count = 1, order = G.P_CENTERS[k].order, wins = {}, wins_by_key = {}}
            local voucher = G.PROFILES[G.SETTINGS.profile].voucher_usage[k]
            if voucher then
                voucher.wins = voucher.wins or {}
                voucher.wins[G.GAME.stake] = (voucher.wins[G.GAME.stake] or 0) + 1
                if SMODS and SMODS.can_load then
                    voucher.wins_by_key = voucher.wins_by_key or {}
                    voucher.wins_by_key[SMODS.stake_from_index(G.GAME.stake)] = (voucher.wins_by_key[SMODS.stake_from_index(G.GAME.stake)] or 0) + 1
                    local applied = SMODS.build_stake_chain(G.P_STAKES[SMODS.stake_from_index(G.GAME.stake)]) or {}
                    for i, v in ipairs(G.P_CENTER_POOLS.Stake) do
                        if applied[i] then
                            voucher.wins[i] = math.max(voucher.wins[i] or 0, 1)
                            voucher.wins_by_key[SMODS.stake_from_index(i)] = math.max(voucher.wins_by_key[SMODS.stake_from_index(i)] or 0, 1)
                        end
                    end
                end
            end
        end
    end
    G:save_settings()
end

-- Poker Hand Level Tracking
local level_up_hand_ref = level_up_hand
function level_up_hand(card, hand, instant, amount)
    level_up_hand_ref(card, hand, instant, amount)
    local poker_hand_key = hand
    local poker_hand_label = poker_hand_key:gsub("%s+", "")
    if G.PROFILES[G.SETTINGS.profile].hand_usage[poker_hand_label] == nil then
        G.PROFILES[G.SETTINGS.profile].hand_usage[poker_hand_label] = {count = 0, order = poker_hand_label, level = 1}
    end
    if not G.PROFILES[G.SETTINGS.profile].hand_usage[poker_hand_label].level then
        G.PROFILES[G.SETTINGS.profile].hand_usage[poker_hand_label].level = 1
    end
    local function is_inf(x) return x ~= x end
    if not (G.GAME.hands[hand].level == math.huge and is_inf(G.GAME.hands[hand].level or 1) == true) then --don't save numbers that are NaN or naneinf
        if G.PROFILES[G.SETTINGS.profile].hand_usage[poker_hand_label].level < G.GAME.hands[hand].level then 
            G.PROFILES[G.SETTINGS.profile].hand_usage[poker_hand_label].level = G.GAME.hands[hand].level
        end
    end
    G:save_settings()
end

local init_item_prototypes_ref = Game.init_item_prototypes
function Game:init_item_prototypes()
    init_item_prototypes_ref(self)
    FlowerPot.convert_save_data()
end

function FlowerPot.convert_save_data()
    if SMODS and SMODS.can_load then
        for k, v in pairs(G.PROFILES[G.SETTINGS.profile].voucher_usage) do
            local first_pass = not v.wins_by_key
            v.wins_by_key = v.wins_by_key or {}
            for index, number in pairs(v.wins or {}) do
                if index > 8 and not first_pass then break end
                v.wins_by_key[SMODS.stake_from_index(index)] = number
            end
        end
    end
    for k, v in pairs(G.PROFILES[G.SETTINGS.profile].hand_usage) do
        if not v.level then G.PROFILES[G.SETTINGS.profile].hand_usage[k].level = 1 end
    end
    G:save_settings()
end
