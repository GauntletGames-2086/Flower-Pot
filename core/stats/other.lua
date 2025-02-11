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
    local hand_to_level = G.PROFILES[G.SETTINGS.profile].hand_usage[poker_hand_label]
    if not hand_to_level.level then
        hand_to_level.level = 1
    end
    local function is_inf(x) return x ~= x end
    if to_big(G.GAME.hands[hand].level) ~= to_big(math.huge) and is_inf(to_big(G.GAME.hands[hand].level)) == false then --don't save numbers that are NaN or naneinf
        if to_big(hand_to_level.level) < to_big(G.GAME.hands[hand].level) then 
            hand_to_level.level = G.GAME.hands[hand].level
            if type(hand_to_level.level) == 'table' then
                if to_big(hand_to_level.level) > to_big(1e300) then
                    hand_to_level.level = to_big(1e300)
                elseif to_big(hand_to_level.level) < to_big(-1e300) then
                    hand_to_level.level = to_big(-1e300)
                end
                hand_to_level.level = hand_to_level.level:to_number(value)
            end
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
    for k, v in pairs(G.PROFILES[G.SETTINGS.profile].joker_usage) do
        if FlowerPot.rev_lookup_records[k] then
            v.records = v.records or {}
            v.records[FlowerPot.rev_lookup_records[k].key] = v.records[FlowerPot.rev_lookup_records[k].key] or (FlowerPot.rev_lookup_records[k].default or 0)
        end
    end
    G:save_settings()
end

to_number = to_number or function(x)
    return x
end

to_big = to_big or function(x)
    return x
end