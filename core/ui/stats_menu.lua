G.FUNCS.high_scores = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = create_UIBox_high_scores(),
  }
end

function create_UIBox_high_scores()
  fetch_achievements()
  set_profile_progress()
  set_discover_tallies()

  local scores = {
    create_UIBox_high_scores_row("hand"),
    create_UIBox_high_scores_row("furthest_round"),
    create_UIBox_high_scores_row("furthest_ante"),
    create_UIBox_high_scores_row("poker_hand"),
    create_UIBox_high_scores_row("most_money"),
    create_UIBox_high_scores_row("win_streak"),
  }
  G.focused_profile = G.SETTINGS.profile
  local cheevs = {}
  
  local t = create_UIBox_generic_options({ back_func = 'options', snap_back = true, contents = {
    {n=G.UIT.C, config={align = "cm"}, nodes = {
      {n=G.UIT.C, config={align = "cm", minw = 3, padding = 0.2, r = 0.1, colour = G.C.CLEAR}, nodes={
        {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes=
          scores
        },
      }},
      {n=G.UIT.C, config={align = "cm", padding = 0.1, r = 0.1, colour = G.C.CLEAR}, nodes={
        create_progress_box(),
        UIBox_button({button = 'usage', label = {localize('k_card_stats')}, minw = 7.5, minh = 1, focus_args = {nav = 'wide'}}),
        UIBox_button({button = 'poker_hand_stats', label = {localize('b_flowpot_poker_hand_stats')}, minw = 7.5, minh = 1, focus_args = {nav = 'wide'}}),
      }},
      not G.F_NO_ACHIEVEMENTS and {n=G.UIT.C, config={align = "cm", r = 0.1, colour = G.C.CLEAR}, nodes=cheevs} or nil
    }}
  }})

  return t
end