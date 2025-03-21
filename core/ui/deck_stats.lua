-- Deck stats
G.FUNCS.deck_stats = function()
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu{
        definition = G.UIDEF.deck_stats()
    }
end

function G.UIDEF.deck_stats()
    G.ACTIVE_FLOWPOT_UI = true
    FlowerPot.GLOBAL.IN_DECK_STATS = true

    return create_UIBox_generic_options({back_func = 'high_scores', contents ={
        {n=G.UIT.C, config = {align = "cm"}, nodes = {
            {n=G.UIT.O, config={id = 'deck_stats', object = UIBox{definition = buildDeckStats_selector(1), config = {offset = {x=0,y=0}}}}}
        }}
    }})
end

-- Deck Stats selector
function buildDeckStats_selector(page)
    page = FlowerPot.GLOBAL.LAST_DECK_STAT_PAGE or page or 1
    ---@type UINode[]
    local back_cardareas = {
        {n=G.UIT.R, config = {align = "cm", colour = G.C.UI.TRANSPARENT_DARK, padding = 0.05, r = 0.1, minw = 11.5, minh = 3}, nodes = {}},
        {n=G.UIT.R, config = {align = "cm", colour = G.C.UI.TRANSPARENT_DARK, padding = 0.05, r = 0.1, minw = 11.5, minh = 3}, nodes = {}}
    }

    for i=1, 2 do
        for ii=1, 5 do
            local back_config = G.P_CENTER_POOLS["Back"][ii+(5*(i-1))+(10*(page-1))]

            if back_config then
                local deck = Back(back_config)

                local cardarea = CardArea(
                    G.ROOM.T.x + 0.2*G.ROOM.T.w/2, G.ROOM.T.h,
                    G.CARD_W, G.CARD_H,
                    {card_limit = 5, type = 'deck', highlight_limit = 0, deck_height = 0.75, thin_draw = 1}
                )

                for iii = 1, 10 do
                    local card = Card(G.ROOM.T.x + 0.2*G.ROOM.T.w/2, G.ROOM.T.h, G.CARD_W, G.CARD_H, pseudorandom_element(G.P_CARDS), G.P_CENTERS.c_base,
                        {playing_card = iii, flowpot_deck_stats = back_config, flowpot_deck_back = deck}
                    )
                    card.sprite_facing = 'back'
                    card.facing = 'back'
                    cardarea:emplace(card)
                    card.children.back:remove()
                    card.children.back = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS[back_config.unlocked and back_config.atlas or 'centers'], back_config.unlocked and back_config.pos or {x = 4, y = 0})
                    card.children.back.states.hover = card.states.hover
                    card.children.back.states.click = card.states.click
                    card.children.back.states.drag = card.states.drag
                    card.children.back.states.collide.can = false
                    card.children.back:set_role({major = card, role_type = 'Glued', draw_major = card})
                    if iii == 10 then card.sticker = get_deck_win_sticker(back_config) end
                end

                back_cardareas[i].nodes[ii] =
                {n=G.UIT.C, config = {align = "cm", colour = G.C.UI.TRANSPARENT_DARK, padding = 0.05, r = 0.1}, nodes = {
                    {n=G.UIT.O, config = {align = "cm", object = cardarea} },
                }}
            end
        end
    end

    local deck_stat_options = {}
    for i = 1, math.ceil(#G.P_CENTER_POOLS["Back"]/10) do
        table.insert(deck_stat_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#G.P_CENTER_POOLS["Back"]/10)))
    end

    ---@type UINode
    return {n=G.UIT.ROOT, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
        {n=G.UIT.R, config = {align = "cm"}, nodes = {
            {n=G.UIT.C, config = {align = "cm", padding = 0.05}, nodes = back_cardareas}
        }},
        #G.P_CENTER_POOLS["Back"] > 10 and {n=G.UIT.R, config={align = "cm"}, nodes={
            create_option_cycle({options = deck_stat_options, w = 4.5, cycle_shoulders = true, opt_callback = 'deck_stats_histogram_page', current_option = page, colour = G.C.RED, no_pips = true, focus_args = {snap_to = true, nav = 'wide'}})
        }} or nil
    }}
end

G.FUNCS.deck_stats_histogram_page = function(args)
    if not args or not args.cycle_config then return end
    local deck_stats_uibox = G.OVERLAY_MENU:get_UIE_by_ID('deck_stats')
    FlowerPot.GLOBAL.LAST_DECK_STAT_PAGE = args.cycle_config.current_option

    deck_stats_uibox.config.object:remove()
    deck_stats_uibox.config.object = UIBox{
        definition = buildDeckStats_selector(args.cycle_config.current_option),
        config = {offset = {x=0,y=0}, parent = deck_stats_uibox},
    }
    deck_stats_uibox.config.object:recalculate()
end

G.FUNCS.deck_stats_overview = function(deck)
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu{
        definition = G.UIDEF.deck_stats_overview(deck)
    }
end

function G.UIDEF.deck_stats_overview(deck)
    FlowerPot.GLOBAL.IN_DECK_STATS = true

    return create_UIBox_generic_options({back_func = 'deck_stats', contents ={
        {n=G.UIT.C, config = {align = "cm"}, nodes = {
            {n=G.UIT.O, config={id = 'deck_stats_overview', object = UIBox{definition = buildDeckStats_overview(deck or G.P_CENTERS.b_red), config = {offset = {x=0,y=0}}}}}
        }}
    }})
end

-- Individual deck overview
function buildDeckStats_overview(deck)
    deck_stats = G.PROFILES[G.SETTINGS.profile].deck_usage[deck.key]
    if not deck_stats then
        G.PROFILES[G.SETTINGS.profile].deck_usage[deck.key] = {count = 0, order = deck.order, wins = {}, losses = {}, wins_by_key = {}, losses_by_key = {}, records = {}}
        deck_stats = G.PROFILES[G.SETTINGS.profile].deck_usage[deck.key]
    elseif not deck_stats.records then
        deck_stats.records = {}
    end
    local total_wins = 0
    local total_losses = 0
    local lowest_rounds = deck_stats.records.lowest_round_win
    local highest_score = deck_stats.records.highest_score

    for _, v in ipairs(deck_stats.wins or {}) do
        total_wins = total_wins + v
    end

    for _, v in ipairs(deck_stats.losses or {}) do
        total_losses = total_losses + v
    end

    local viewed_back = Back(get_deck_from_name(deck))
    G.GAME.viewed_back = viewed_back
    G.GAME.viewed_back:change_to(deck)

    local cardarea = CardArea(
        G.ROOM.T.x + 0.2*G.ROOM.T.w/2, G.ROOM.T.h,
        G.CARD_W, G.CARD_H,
        {card_limit = 5, type = 'deck', highlight_limit = 0, deck_height = 0.75, thin_draw = 1}
    )

    for i = 1, 10 do
        local card = Card(G.ROOM.T.x + 0.2*G.ROOM.T.w/2, G.ROOM.T.h, G.CARD_W, G.CARD_H, pseudorandom_element(G.P_CARDS), G.P_CENTERS.c_base,
            {playing_card = i, viewed_back = true, flowpot_deck_stats = deck, flowpot_deck_back = viewed_back}
        )
        card.sprite_facing = 'back'
        card.facing = 'back'
        cardarea:emplace(card)
        if i == 10 then G.sticker_card = card; card.sticker = get_deck_win_sticker(deck) end
    end

    ---@type UINode
    return {n=G.UIT.ROOT, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
        {n=G.UIT.R, config = {align = "cm", padding = 0.1}, nodes = {
            {n=G.UIT.C, config = {align = "bm", r = 0.1}, nodes = {
                {n=G.UIT.R, config = {align = "bm", colour = G.C.UI.TRANSPARENT_DARK, padding = 0.05, r = 0.1}, nodes = {
                    {n=G.UIT.O, config = {align = "bm", object = cardarea} },
                }},
            }},
            {n=G.UIT.C, config = {align = "cm"}, nodes = {
                {n=G.UIT.R, config = {align = "cm", padding = 0.1}, nodes = {
                    {n=G.UIT.T, config={text = localize("b_flowpot_deck_records"), scale = 0.5, colour = G.C.UI.TEXT_LIGHT}},
                }},
                {n=G.UIT.R, config = {align = "cm", colour = G.C.UI.TRANSPARENT_DARK, padding = 0.1, r = 0.1}, nodes = {
                    create_UIBox_deck_stat_row({data = (''..total_wins).."/"..(''..total_losses), loc_key = "b_flowpot_total_wins_losses"}),
                    create_UIBox_deck_stat_row({data = lowest_rounds, loc_key = "b_flowpot_fastest_run", loc_val = "b_flowpot_num_rounds"}),
                    create_UIBox_deck_stat_row({data = number_format(highest_score), loc_key = "b_flowpot_highest_score"}),
                }},
            }},
            {n=G.UIT.C, config = {align = "cm"}, nodes = {
                {n=G.UIT.R, config = {align = "cm", colour = G.C.UI.TRANSPARENT_DARK, padding = 0.1, r = 0.1}, nodes = {
                    create_UIBox_deck_stat_stickers(deck)
                }},
            }},
        }}
    }}
end

function create_UIBox_deck_stat_stickers(deck)
    local _profile_progress = G.PROFILES[G.SETTINGS.profile].progress
    local text_scale = 1
    local bar_colour = G.PROFILES[G.focused_profile].all_unlocked and G.C.RED or G.C.BLUE
    ---@type UINode[]
    local rows = {}

    _profile_progress.FLOWPOT_deck_overall_tally, _profile_progress.FLOWPOT_deck_overall_of = 
        _profile_progress.FLOWPOT_per_deck_joker_stickers[deck.key].tally/_profile_progress.FLOWPOT_per_deck_joker_stickers[deck.key].of + 
        _profile_progress.FLOWPOT_per_deck_voucher_stickers[deck.key].tally/_profile_progress.FLOWPOT_per_deck_voucher_stickers[deck.key].of,
        4

    for i = 1, 2 do
        local profile_stat = (i == 1 and _profile_progress.FLOWPOT_per_deck_joker_stickers or _profile_progress.FLOWPOT_per_deck_voucher_stickers)
        local tab, val, max = profile_stat[deck.key], 'tally', profile_stat[deck.key].of

        rows[#rows+1] = 
        {n=G.UIT.R, config={align = "cm", padding = 0.05, r = 0.1, colour = darken(G.C.JOKER_GREY, 0.1), emboss = 0.05}, nodes={
            {n=G.UIT.C, config={align = "cm", padding = 0.05, minw = 3.5*text_scale, maxw = 3.5*text_scale}, nodes={
                {n=G.UIT.T, config={text = localize((i == 1 and "b_flowpot_per_deck_joker" or "b_flowpot_per_deck_voucher")), scale = 0.5*text_scale, colour = G.C.UI.TEXT_LIGHT, shadow = true}},
            }},
            {n=G.UIT.C, config={align = "cl", minh = 0.8, r = 0.1, minw = 3.5*text_scale, colour = G.C.BLACK, emboss = 0.05,
            progress_bar = {
                max = max, ref_table = tab, ref_value = val, empty_col = G.C.BLACK, filled_col = adjust_alpha(bar_colour, 0.5)
            }}, nodes={
                {n=G.UIT.C, config={align = "cm", padding = 0.05, r = 0.1, minw = 3.5*text_scale}, nodes={
                    {n=G.UIT.O, config={object = DynaText({string = {math.floor(0.01+100*profile_stat[deck.key].tally/profile_stat[deck.key].of)..'%'}, colours = {G.C.WHITE},shadow = true, float = true, scale = 0.55*text_scale})}},
                    {n=G.UIT.T, config={text = " ("..profile_stat[deck.key].tally..'/'..profile_stat[deck.key].of..")", scale = 0.35, colour = G.C.JOKER_GREY}}
                }},
            }},
        }}
    end

    ---@type UINode
    return {n=G.UIT.R, config={align = "bm", padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05, minh = 3.6}, nodes={
        {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
            {n=G.UIT.C, config={align = "cm", padding = 0.1, minw = 3.5*text_scale, maxw = 3.5*text_scale}, nodes={
                {n=G.UIT.T, config={text = localize('k_progress'), scale = 0.5, colour = G.C.UI.TEXT_LIGHT, shadow = true}},
            }},
            {n=G.UIT.C, config={align = "cl", minh = 0.6, r = 0.1, minw = 3.5*text_scale, colour = G.C.BLACK, emboss = 0.05,
            progress_bar = {
                max = _profile_progress.FLOWPOT_deck_overall_of, ref_table = _profile_progress, ref_value = 'FLOWPOT_deck_overall_tally', empty_col = G.C.BLACK, filled_col = adjust_alpha(bar_colour, 0.5)
            }}, nodes={
                {n=G.UIT.C, config={align = "cm", padding = 0.05, r = 0.1, minw = 3.5*text_scale}, nodes={
                  {n=G.UIT.O, config={object = DynaText({string = {math.floor(0.01+100*_profile_progress.FLOWPOT_deck_overall_tally/_profile_progress.FLOWPOT_deck_overall_of)..'%'}, colours = {G.C.WHITE},shadow = true, float = true, scale = 0.55})}},
                }},
            }}
        }},
        {n=G.UIT.R, config={align = "cm", padding = 0.05}, nodes=rows},
    }}
end

function create_UIBox_deck_stat_row(deck_data)
    deck_data.data = deck_data.data or "N/A"
    ---@type UINode
    return {n=G.UIT.R, config={align = "cm", padding = 0.1, r = 0.1, colour = darken(G.C.UI.TRANSPARENT_DARK, 0.2)}, nodes={
        {n=G.UIT.C, config={align = "cm", padding = 0.15, r = 0.1, minw = 4}, nodes={
            {n=G.UIT.C, config={align = "cm", padding = 0.05}, nodes={
                {n=G.UIT.T, config={text = localize(deck_data.loc_key), scale = 0.45, colour = G.C.UI.TEXT_LIGHT, shadow = true}}
            }},
            {n=G.UIT.C, config={align = "cl", padding = 0.05}, nodes={
                {n=G.UIT.T, config={
                    text =
                        (deck_data.loc_val and localize{type = 'variable', key = deck_data.loc_val, vars = {deck_data.data}})
                        or (''..deck_data.data),
                    scale = 0.5, colour = G.C.UI.TEXT_LIGHT, shadow = true}
                }
            }}
        }}
    }}
end

--- `info_queue` and `badges` code based on Galdur's implementation
local card_hover_ref = Card.hover
function Card:hover()
    card_hover_ref(self)
    if self.facing == 'back' and self.params.flowpot_deck_stats and (not self.states.drag.is or G.CONTROLLER.HID.touch) and not self.no_ui and not G.debug_tooltip_toggle then
        local fake_AUT = {
            main = {},
            name = {}
        }

        local info_queue = {}
        local loc_target = G.localization.descriptions[self.params.flowpot_deck_stats.set][self.params.flowpot_deck_stats.key]
        for _, lines in ipairs(loc_target.text_parsed) do
            for _, part in ipairs(lines) do
                if part.control.T then info_queue[#info_queue+1] = G.P_CENTERS[part.control.T] or G.P_TAGS[part.control.T] end
            end
        end
        local tooltips = {}
        if self.params.flowpot_deck_stats.unlocked then
            for _, center in pairs(info_queue) do
                local desc = generate_card_ui(center, {main = {},info = {},type = {},name = 'done',badges = {}}, nil, center.set, nil)
                tooltips[#tooltips + 1] =
                {n=G.UIT.R, config={align = "cm"}, nodes={
                    {n=G.UIT.R, config={align = "cm", colour = lighten(G.C.JOKER_GREY, 0.5), r = 0.1, padding = 0.05, emboss = 0.05}, nodes={
                        info_tip_from_rows(desc.info[1], desc.info[1].name),
                    }}
                }}
            end
        end
        local info_boxes = {{n=G.UIT.R, config = {align="cm", padding = 0.05, card_pos = self.T.x }, nodes = tooltips}}

        local badges = {n=G.UIT.ROOT, config = {colour = G.C.CLEAR, align = 'cm'}, nodes = {}}
        if SMODS and SMODS.can_load then
            SMODS.create_mod_badges(self.params.flowpot_deck_stats, badges.nodes)
        end
        if badges.nodes.mod_set then badges.nodes.mod_set = nil end

        fake_AUT.name = localize{type = 'name', key = self.params.flowpot_deck_stats.key, set = self.params.flowpot_deck_stats.set, nodes = fake_AUT.name}
        self.config.h_popup =
        {n=G.UIT.ROOT, config = {align = 'cm', colour = G.C.CLEAR}, nodes={
            {n=G.UIT.C, config={align = "cm", func = 'show_infotip',object = Moveable(),ref_table = next(info_boxes) and info_boxes or nil}, nodes={
                {n=G.UIT.R, config={padding = 0.05, r = 0.12, colour = lighten(G.C.JOKER_GREY, 0.5), emboss = 0.07}, nodes={
                    {n=G.UIT.R, config={align = "cm", padding = 0.07, r = 0.1, colour = adjust_alpha(darken(G.C.BLACK, 0.1), 0.8)}, nodes={
                        {n=G.UIT.R, config={align = "cm", padding = 0.05, r = 0.1}, nodes=fake_AUT.name},
                        self.params.flowpot_deck_back:generate_UI().nodes[1],
                        badges.nodes[1] and {n=G.UIT.R, config={align = "cm", r = 0.1, minw = 3, maxw = 4, minh = 0.4}, nodes={
                            {n=G.UIT.O, config={object = UIBox{definition = badges, config = {offset = {x=0,y=0}}}}}
                        }},
                    }}
                }}
            }},
        }}
        self.config.h_popup_config = self:align_h_popup()

        Node.hover(self)
    end
end

--- Deck click code based on Galdur's implementation
local card_click_ref = Card.click
function Card:click()
    if self.params.flowpot_deck_stats and self.params.flowpot_deck_stats.unlocked then
        G.FUNCS.deck_stats_overview(self.params.flowpot_deck_stats)
    else
        card_click_ref(self)
    end
end