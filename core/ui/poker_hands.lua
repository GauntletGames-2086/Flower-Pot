-- Poker hand stats
G.FUNCS.poker_hand_stats = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = G.UIDEF.poker_hand_stats()
  }
end

function G.UIDEF.poker_hand_stats()
  return create_UIBox_generic_options({back_func = 'high_scores', contents ={
    {n=G.UIT.C, config = {align = "cm"}, nodes = {
      {n=G.UIT.O, config={id = 'poker_hand_stats', object = UIBox{definition = buildPoker_hand_stats_master(1), config = {offset = {x=0,y=0}}}}}
    }}
  }})
end

function buildPoker_hand_stats_master(page)
  page = page or 1
  local poker_hand_uiboxes = {}
  for i = 1, 8 do
    local poker_hand_key = G.handlist[i+(8*(page-1))]
    if poker_hand_key ~= nil then
      local poker_hand_info = G.PROFILES[G.SETTINGS.profile].hand_usage[poker_hand_key:gsub("%s+", "")] or {order = poker_hand_key, count = 0, level = 1}
      poker_hand_uiboxes[#poker_hand_uiboxes+1] = create_UIBox_poker_hand_stats_row(poker_hand_info)
    end
  end

  local poker_hand_options = {}
  for i = 1, math.ceil(#G.handlist/8) do
      table.insert(poker_hand_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#G.handlist/8)))
  end

  return {n=G.UIT.ROOT, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
    {n=G.UIT.C, config = {align = "cm"}, nodes = {
      {n=G.UIT.R, config = {align = "cm", padding = 0.1, r = 0.1, colour = G.C.UI.TRANSPARENT_DARK, minh = 8.7}, nodes = {
        {n=G.UIT.C, config = {align = "cm", padding = 0.05}, nodes = poker_hand_uiboxes}
      }},
      #G.handlist > 8 and {n=G.UIT.R, config={align = "cm"}, nodes={
        create_option_cycle({options = poker_hand_options, w = 4.5, cycle_shoulders = true, opt_callback = 'poker_hand_stats_page', current_option = page, colour = G.C.RED, no_pips = true, focus_args = {snap_to = true, nav = 'wide'}})
      }} or nil
    }}
  }}
end

function create_UIBox_poker_hand_stats_row(hand_data)
  return {n=G.UIT.R, config={align = "cm", padding = 0.05, r = 0.1, colour = G.C.UI.TRANSPARENT_DARK}, nodes={
    {n=G.UIT.C, config={align = "cm", minw = 3.5, maxw = 3.5}, nodes={
      {n=G.UIT.T, config={text = ' '..localize(hand_data.order,'poker_hands'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT, shadow = true}}
    }},
    {n=G.UIT.C, config={align = "cm", padding = 0.15, r = 0.1, colour = darken(G.C.JOKER_GREY, 0.1)}, nodes={
      {n=G.UIT.C, config={align = "cm", padding = 0.05}, nodes={
        {n=G.UIT.T, config={text = localize('b_flowpot_highest_lvl'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT, shadow = true}}
      }},
      {n=G.UIT.C, config={align = "cl", padding = 0.05}, nodes={
        {n=G.UIT.C, config={align = "cm", padding = 0.01, r = 0.1, colour = G.C.HAND_LEVELS[math.min(7, (hand_data.level or 1))], minw = 1.5, outline = 0.8, outline_colour = G.C.WHITE}, nodes={
          {n=G.UIT.T, config={text = localize('k_level_prefix')..(hand_data.level or 1), scale = 0.5, colour = G.C.UI.TEXT_DARK}}
        }},
      }},
      {n=G.UIT.C, config={align = "cm"}, nodes={
        {n=G.UIT.T, config={text = localize('b_flowpot_total_played'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT, shadow = true}}
      }},
      {n=G.UIT.C, config={align = "cm", padding = 0.1, colour = G.C.L_BLACK,r = 0.1, minw = 0.9}, nodes={
        {n=G.UIT.T, config={text = hand_data.count, scale = 0.45, colour = G.C.FILTER, shadow = true}},
      }}
    }}
  }}
end

G.FUNCS.poker_hand_stats_page = function(args)
  if not args or not args.cycle_config then return end
  local poker_hand_stats_uibox = G.OVERLAY_MENU:get_UIE_by_ID('poker_hand_stats')

	poker_hand_stats_uibox.config.object:remove()
	poker_hand_stats_uibox.config.object = UIBox{
		definition = buildPoker_hand_stats_master(args.cycle_config.current_option),
		config = {offset = {x=0,y=0}, parent = poker_hand_stats_uibox},
	}
  poker_hand_stats_uibox.config.object:recalculate()
end