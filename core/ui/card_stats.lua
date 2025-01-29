-- Card usage stats
function G.UIDEF.usage_tabs()
    FlowerPot.convert_save_data()
    local stat_tabs = {
        {
            label = localize('b_stat_jokers'),
            chosen = true,
            tab_definition_function = create_UIBox_card_stats,
            tab_definition_function_args = {'joker_usage', "round_wins"},
        },
        {
            label = localize('b_stat_consumables'),
            tab_definition_function = create_UIBox_card_stats,
            tab_definition_function_args = {'consumeable_usage', "times_used"},
        },
        {
            label = localize('b_stat_vouchers'),
            tab_definition_function = create_UIBox_card_stats,
            tab_definition_function_args = {'voucher_usage', "times_redeemed", 'Voucher'},
        },
    }

    for _, v in ipairs(FlowerPot.index_stat_tabs) do
        stat_tabs[#stat_tabs+1] = v.tab_definition()
    end

    return create_UIBox_generic_options({back_func = 'high_scores', contents ={create_tabs({
            tabs = stat_tabs,
            padding = 0,
            text_scale = 0.45,
            scale = 0.85,
            snap_to_nav = true
        })
    }})
end

FlowerPot.GLOBAL.CARD_STATS_FILTER = {}
function create_UIBox_card_stats(args)
    FlowerPot.GLOBAL.CARD_STATS_FILTER = {
        stat_group = args[1],
        stat_type = args[2],
        set = args[3],
        consumable = (args[1] == "consumeable_usage"),
    }
    return {n=G.UIT.ROOT, config={align = "cm", minh = 3, padding = 0.05, r = 0.1, colour = G.C.CLEAR}, nodes={
        {n=G.UIT.C, config = {align = 'cm', colour = G.C.CLEAR, padding = 0.1}, nodes = {
            {n=G.UIT.O, config={id = 'histogram', object = UIBox{definition = buildCardStats_histogram({}), config = {offset = {x=0,y=0}}}}},
            {n=G.UIT.O, config={id = 'histogram_settings', object = UIBox{definition = buildCardStats_histogram_settings({}), config = {offset = {x=0,y=0}}}}}
        }}
    }}
end

-- Histograms master
function buildCardStats_histogram(args)
    local stat_group, _set, stat_type, mod, page = FlowerPot.GLOBAL.CARD_STATS_FILTER.stat_group, 
        FlowerPot.GLOBAL.CARD_STATS_FILTER.set, FlowerPot.GLOBAL.CARD_STATS_FILTER.stat_type, FlowerPot.GLOBAL.CARD_STATS_FILTER.mod, args.page or 1
    local used_cards, max_amt = {}, 0
    local stat_group_info = FlowerPot.stat_groups[stat_group]:create_data_table()
    for i, v in ipairs(stat_group_info) do
        if G.P_CENTERS[v.key] and G.P_CENTERS[v.key].discovered and (not _set or G.P_CENTERS[v.key].set == _set) and (not mod or (G.P_CENTERS[v.key].mod and G.P_CENTERS[v.key].mod.id == mod)) then
            local data_table = FlowerPot.stat_types[stat_type]:create_stat_table(v)
            if data_table.count > 0 then 
                used_cards[#used_cards+1] = data_table
                if data_table.count > max_amt then max_amt = data_table.count end
            end
        end
    end

    table.sort(used_cards, function (a, b) return a.count > b.count end )
    local histograms = {{}, {}}
    local histogram_colour = G.C.RED

    for i = 1, 2 do
        for ii = 1, 4 do
            local v = used_cards[ii+(4*(i-1))+(8*(page-1))]
            if v then 
                histograms[i][#histograms[i]+1] = create_UIBox_histogram(G.P_CENTERS[v.key], v, max_amt)
                histogram_colour = G.C.SECONDARY_SET[G.P_CENTERS[v.key].set]
            end
        end
    end

    local histogram_options = {}
    for i = 1, math.ceil(#used_cards/8) do
            table.insert(histogram_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#used_cards/8)))
    end

    return {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
        {n=G.UIT.C, config={align = "cm", padding = 0.05, colour = G.C.UI.TRANSPARENT_DARK, r = 0.1, minh = 0.5*G.CARD_H*5, minw = 0.5*G.CARD_H*3*1.5}, nodes={
            {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
                {n=G.UIT.B, config={w = 0.2, h = 0.2, r = 0.1, colour = histogram_colour}},
                {n=G.UIT.T, config={text = localize(FlowerPot.stat_types[stat_type].display_txt.full), scale = 0.35, colour = G.C.WHITE}}
            }},
            {n=G.UIT.R, config={align = "cm", colour = G.C.BLACK, r = 0.1, minh = 0.5*G.CARD_H*5, minw = 0.5*G.CARD_H*3, padding = 0.1}, nodes={
                {n=G.UIT.C, config={align = "cm", padding = 0.1}, nodes=histograms[1]},
                {n=G.UIT.C, config={align = "cm", padding = 0.1}, nodes=histograms[2]},
            }},
            #used_cards > 8 and {n=G.UIT.R, config={align = "cm"}, nodes={
                create_option_cycle({options = histogram_options, w = 4.5, cycle_shoulders = true, opt_callback = 'card_stats_histogram_page', current_option = page, colour = G.C.RED, no_pips = true, focus_args = {snap_to = true, nav = 'wide'}})
            }} or nil
        }}
    }}
end

function create_UIBox_histogram(center, stats, max_amt)
    local card = Card(0,0, 0.5*G.CARD_W, 0.5*G.CARD_H, nil, center)
    if center.set == "Voucher" then card.sticker = get_voucher_win_sticker(center) end
    card.ambient_tilt = 0.8
    local cardarea = CardArea(
        G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
        G.CARD_W*0.5,
        G.CARD_H*0.5, 
        {card_limit = 2, type = 'title', highlight_limit = 0})
    cardarea:emplace(card)

    return {n=G.UIT.R, config={align = "cm",minw = 3}, nodes={
        {n=G.UIT.R, config={align = "cm", r = 0.1}, nodes={
            {n=G.UIT.C, config={align = "cm"}, nodes={
                {n=G.UIT.C, config={align = "cm", minw = 0.5*G.CARD_W} , nodes={
                    {n=G.UIT.O, config={object = cardarea}}
                }},
                {n=G.UIT.C, config={align = "cm", padding = 0.05}, nodes={
                    {n=G.UIT.T, config={text = stats.count, scale = 0.35, colour = mix_colours(G.C.FILTER, G.C.WHITE, 0.8), shadow = true}}
                }},
            }},
            {n=G.UIT.C, config={align = "cm", padding = 0.03}, nodes={
                {n=G.UIT.C, config={align = "cm"}, nodes={
                    {n=G.UIT.C, config={align = "cm", minw = 2*(stats.count/max_amt), minh = 0.7, colour = G.C.SECONDARY_SET[center.set] or G.C.RED, res = 0.1, r = 0.003}, nodes={}},
                    {n=G.UIT.C, config={align = "cm", minw = 2-(2*(stats.count/max_amt)), minh = 0.7, colour = G.C.UI.TRANSPARENT_DARK}, res = 0.1, r = 0.003, nodes={}},
                }},
            }},
        }},
    }}
end

G.FUNCS.card_stats_histogram_page = function(args)
    if not args or not args.cycle_config then return end
    local histogram_uibox = G.OVERLAY_MENU:get_UIE_by_ID('histogram')

    histogram_uibox.config.object:remove()
    histogram_uibox.config.object = UIBox{
        definition = buildCardStats_histogram({page = args.cycle_config.current_option}),
        config = {offset = {x=0,y=0}, parent = histogram_uibox},
    }
    histogram_uibox.config.object:recalculate()
end

-- Histogram Settings
function buildCardStats_histogram_settings(args)
    local histogram_setting_tabs = {}
    if FlowerPot.GLOBAL.CARD_STATS_FILTER.consumable then 
        histogram_setting_tabs[#histogram_setting_tabs+1] = {
            label = localize("b_flowpot_consumable_types"),
            chosen = (FlowerPot.GLOBAL.CARD_STATS_FILTER.consumable and true),
            tab_definition_function = function() 
                return {
                    n = G.UIT.ROOT,
                    config = {
                        emboss = 0.05,
                        minh = 6,
                        r = 0.1,
                        minw = 6,
                        align = "tm",
                        padding = 0.2,
                        colour = G.C.CLEAR
                    },
                    nodes = {
                        {n=G.UIT.O, config={id = 'stat_consumable_type_uibox', object = 
                            UIBox{
                                definition = create_UIBox_histogram_consumable_type_tab({}),
                                config = {offset = {x=0,y=0}}
                            }
                        }}
                    }
                }
            end,
        }
    end
    histogram_setting_tabs[#histogram_setting_tabs+1] = {
        label = localize("b_flowpot_stat_types"),
        chosen = (not FlowerPot.GLOBAL.CARD_STATS_FILTER.consumable and true),
        tab_definition_function = function() 
            return {
                n = G.UIT.ROOT,
                config = {
                    emboss = 0.05,
                    minh = 6,
                    r = 0.1,
                    minw = 6,
                    align = "tm",
                    padding = 0.2,
                    colour = G.C.CLEAR
                },
                nodes = {
                    {n=G.UIT.O, config={id = 'stat_types_uibox', object = 
                        UIBox{
                            definition = create_UIBox_histogram_stat_types({}), 
                            config = {offset = {x=0,y=0}}}
                    }}
                }
            }
        end,
    }
    if SMODS and SMODS.can_load then 
        histogram_setting_tabs[#histogram_setting_tabs+1] = {
            label = localize("b_flowpot_mods"),
            tab_definition_function = function() 
                return {
                    n = G.UIT.ROOT,
                    config = {
                        emboss = 0.05,
                        minh = 6,
                        r = 0.1,
                        minw = 6,
                        align = "tm",
                        padding = 0.2,
                        colour = G.C.CLEAR
                    },
                    nodes = {
                        {n=G.UIT.O, config={id = 'stat_mods_uibox', object = 
                            UIBox{
                                definition = create_UIBox_histogram_mods_tab({}), 
                                config = {offset = {x=0,y=0}}
                            }
                        }}
                    }
                }
            end,
        }
    end
    
    return {n=G.UIT.ROOT, config={align = "cm", colour = G.C.UI.TRANSPARENT_DARK, r = 0.1}, nodes={
            {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
                create_tabs({
                    tabs = histogram_setting_tabs,
                    tab_h = 4,
                    no_shoulders = true,
                    no_loop = true
                })
            }},
        }}
end

function create_UIBox_histogram_stat_types(args)
    local stat_group, _set, stat_type, mod, page = FlowerPot.GLOBAL.CARD_STATS_FILTER.stat_group, 
        FlowerPot.GLOBAL.CARD_STATS_FILTER.set, FlowerPot.GLOBAL.CARD_STATS_FILTER.stat_type, FlowerPot.GLOBAL.CARD_STATS_FILTER.mod, args.page or 1
    local available_stat_types = {}
    for i, v in ipairs(FlowerPot.index_stat_types) do
        if v.valid_stat_groups[stat_group] then available_stat_types[#available_stat_types+1] = v end
    end

    local buttons = {}
    for i = 1, 6 do
        local selected_stat_type = available_stat_types[i+(6*(page-1))]
        if not selected_stat_type then break end
        buttons[#buttons+1] = {n=G.UIT.R, config = {align = 'cm', padding = 0.1}, nodes = {
            UIBox_button({ label = {localize(selected_stat_type.display_txt.button)}, button = "histogram_reset_stat_type", ref_table = {stat_type = selected_stat_type.key}, colour = G.C.RED, minw = 5, minh = 0.65, scale = 0.6})
        }}
    end

    local stat_types_options = {}
    for i = 1, math.ceil(#available_stat_types/6) do
            table.insert(stat_types_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#available_stat_types/6)))
    end

    return {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
        {n=G.UIT.C, config={align = "cm", padding = 0.05, minh = 2}, nodes={
            {n=G.UIT.R, config={align = "cm", padding = 0.1, colour = G.C.BLACK, minh = 5.5, r = 0.1}, nodes=buttons},
            #available_stat_types > 6 and {n=G.UIT.R, config={align = "cm"}, nodes={
                create_option_cycle({options = stat_types_options, w = 4.5, cycle_shoulders = true, opt_callback = 'card_stat_types_page', current_option = page, colour = G.C.RED, no_pips = true, focus_args = {snap_to = true, nav = 'wide'}})
            }} or nil
        }}
    }}
end

G.FUNCS.histogram_reset_stat_type = function(e)
    local args = e.config.ref_table
    FlowerPot.GLOBAL.CARD_STATS_FILTER.stat_type = args.stat_type

    G.FUNCS.card_stats_histogram_page({cycle_config = args})
end

G.FUNCS.card_stat_types_page = function(args)
    if not args or not args.cycle_config then return end
    local stat_types_uibox = G.OVERLAY_MENU:get_UIE_by_ID('stat_types_uibox')

    stat_types_uibox.config.object:remove()
    stat_types_uibox.config.object = UIBox{
        definition = create_UIBox_histogram_stat_types({page = args.cycle_config.current_option}),
        config = {offset = {x=0,y=0}, parent = stat_types_uibox},
    }
    stat_types_uibox.config.object:recalculate()
end

function create_UIBox_histogram_consumable_type_tab(args)
    local stat_group, _set, stat_type, mod, page = FlowerPot.GLOBAL.CARD_STATS_FILTER.stat_group, 
        FlowerPot.GLOBAL.CARD_STATS_FILTER.set, FlowerPot.GLOBAL.CARD_STATS_FILTER.stat_type, FlowerPot.GLOBAL.CARD_STATS_FILTER.mod, args.page or 1
    local consumable_type_index = {}
    local default_consumable_types = {["Tarot"] = 3, ["Planet"] = 2, ["Spectral"] = 1}
    for k, v in pairs(FlowerPot.stat_groups) do
        if v.stat_set and ((SMODS and SMODS.can_load and SMODS.ConsumableTypes[v.stat_set]) or default_consumable_types[v.stat_set]) then
            consumable_type_index[#consumable_type_index+1] = v
        end
    end

    table.sort(consumable_type_index, 
        function(a, b)
            if (default_consumable_types[a.stat_set] or default_consumable_types[b.stat_set]) then
                return (default_consumable_types[a.stat_set] or 0) > (default_consumable_types[b.stat_set] or 0)
            else
                return a.stat_set < b.stat_set
            end
        end
    )

    local buttons = {}
    if page == 1 then 
        buttons[1] = {n=G.UIT.R, config = {align = 'cm', padding = 0.1}, nodes = {
            UIBox_button({ label = {localize("b_flowpot_all_types")}, button = "histogram_reset_consumable_type", ref_table = {stat_group = "consumeable_usage"}, colour = G.C.RED, minw = 5, minh = 0.65, scale = 0.6})
        }}
    end
    for i = 1, page == 1 and 5 or 6 do
        local selected_consumable_type = consumable_type_index[i+(6*(page-1))]
        if selected_consumable_type then 
            local stat_group_info = FlowerPot.stat_groups[stat_group]:create_data_table()
            if #stat_group_info > 0 then
                buttons[#buttons+1] = {n=G.UIT.R, config = {align = 'cm', padding = 0.1}, nodes = {
                    UIBox_button({ label = {localize('k_'..string.lower(selected_consumable_type.stat_set))}, button = "histogram_reset_consumable_type", ref_table = {stat_group = selected_consumable_type.key, set = selected_consumable_type.stat_set}, colour = G.C.SECONDARY_SET[selected_consumable_type.stat_set] or G.C.RED, minw = 5, minh = 0.65, scale = 0.6})
                }}
            end
        end
    end

    local stat_consumable_type_options = {}
    for i = 1, math.ceil(#consumable_type_index/6) do
            table.insert(stat_consumable_type_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#consumable_type_index/6)))
    end

    return {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
        {n=G.UIT.C, config={align = "cm", padding = 0.05, minh = 2}, nodes={
            {n=G.UIT.R, config={align = "cm", padding = 0.05, colour = G.C.BLACK, minh = 5.5, r = 0.1}, nodes=buttons},
            #consumable_type_index > 6 and {n=G.UIT.R, config={align = "cm"}, nodes={
                create_option_cycle({options = stat_consumable_type_options, w = 4.5, cycle_shoulders = true, opt_callback = 'card_stat_consumable_type_page', current_option = page, colour = G.C.RED, no_pips = true, focus_args = {snap_to = true, nav = 'wide'}})
            }} or nil
        }}
    }}
end

G.FUNCS.histogram_reset_consumable_type = function(e)
    local args = e.config.ref_table
    FlowerPot.GLOBAL.CARD_STATS_FILTER.stat_group = args.stat_group
    FlowerPot.GLOBAL.CARD_STATS_FILTER.set = args.set

    G.FUNCS.card_stats_histogram_page({cycle_config = args})
end

G.FUNCS.card_stat_consumable_type_page = function(args)
    if not args or not args.cycle_config then return end
    local stat_consumable_type_uibox = G.OVERLAY_MENU:get_UIE_by_ID('stat_consumable_type_uibox')

    stat_consumable_type_uibox.config.object:remove()
    stat_consumable_type_uibox.config.object = UIBox{
        definition = create_UIBox_histogram_consumable_type_tab({page = args.cycle_config.current_option}),
        config = {offset = {x=0,y=0}, parent = stat_consumable_type_uibox},
    }
    stat_consumable_type_uibox.config.object:recalculate()
end

function create_UIBox_histogram_mods_tab(args)
    local stat_group, _set, stat_type, mod, page = FlowerPot.GLOBAL.CARD_STATS_FILTER.stat_group, 
        FlowerPot.GLOBAL.CARD_STATS_FILTER.set, FlowerPot.GLOBAL.CARD_STATS_FILTER.stat_type, FlowerPot.GLOBAL.CARD_STATS_FILTER.mod, args.page or 1
    local mods_by_index, checked_mods = {}, {}
    local stat_group_info = FlowerPot.stat_groups[stat_group]:create_data_table()
    for i, v in ipairs(stat_group_info) do
        if G.P_CENTERS[v.key] and G.P_CENTERS[v.key].mod and G.P_CENTERS[v.key].discovered and (not _set or G.P_CENTERS[v.key].set == _set) and not checked_mods[G.P_CENTERS[v.key].mod.id] then
            checked_mods[G.P_CENTERS[v.key].mod.id] = true
            mods_by_index[#mods_by_index+1] = G.P_CENTERS[v.key].mod
        end
    end

    local buttons = {}
    if page == 1 then buttons[1] = {n=G.UIT.R, config = {align = 'cm', padding = 0.1}, nodes = {
        UIBox_button({ label = {localize("b_flowpot_all_cards")}, button = "histogram_reset_mods", ref_table = {}, colour = G.C.RED, minw = 5, minh = 0.65, scale = 0.6})
    }} end
    for i = 1, page == 1 and 5 or 6 do
        local selected_mod = mods_by_index[i+(6*(page-1))]
        if not selected_mod then break end
        buttons[#buttons+1] = {n=G.UIT.R, config = {align = 'cm', padding = 0.1}, nodes = {
            UIBox_button({ label = {selected_mod.name}, button = "histogram_reset_mods", ref_table = {mod = selected_mod.id}, colour = G.C.RED, minw = 5, minh = 0.65, scale = 0.6})
        }}
    end

    local stat_mods_options = {}
    for i = 1, math.ceil(#mods_by_index/6) do
            table.insert(stat_mods_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#mods_by_index/6)))
    end

    return {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
        {n=G.UIT.C, config={align = "cm", padding = 0.05, minh = 2}, nodes={
            {n=G.UIT.R, config={align = "cm", padding = 0.05, colour = G.C.BLACK, minh = 5.5, r = 0.1}, nodes=buttons},
            #mods_by_index > 6 and {n=G.UIT.R, config={align = "cm"}, nodes={
                create_option_cycle({options = stat_mods_options, w = 4.5, cycle_shoulders = true, opt_callback = 'card_stat_mods_page', current_option = page, colour = G.C.RED, no_pips = true, focus_args = {snap_to = true, nav = 'wide'}})
            }} or nil
        }}
    }}
end

G.FUNCS.histogram_reset_mods = function(e)
    local args = e.config.ref_table
    FlowerPot.GLOBAL.CARD_STATS_FILTER.mod = args.mod

    G.FUNCS.card_stats_histogram_page({cycle_config = args})
end

G.FUNCS.card_stat_mods_page = function(args)
    if not args or not args.cycle_config then return end
    local stat_mods_uibox = G.OVERLAY_MENU:get_UIE_by_ID('stat_mods_uibox')

    stat_mods_uibox.config.object:remove()
    stat_mods_uibox.config.object = UIBox{
        definition = create_UIBox_histogram_mods_tab({page = args.cycle_config.current_option}),
        config = {offset = {x=0,y=0}, parent = stat_mods_uibox},
    }
    stat_mods_uibox.config.object:recalculate()
end