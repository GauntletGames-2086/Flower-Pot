-- Copy of SMODS.handle_loc_file so loc files can still be loaded
function FlowerPot.load_localization()
    local dir = FlowerPot.path_to_self() .. 'localization/'
	local file_name
    for k, v in ipairs({ dir .. G.SETTINGS.language .. '.lua', dir .. 'default.lua', dir .. 'en-us.lua', dir .. G.SETTINGS.language .. '.json', dir .. 'default.json', dir .. 'en-us.json' }) do
        if FP_NFS.getInfo(v) then
            file_name = v
            break
        end
    end
    if not file_name then return end

    local loc_table = nil
    if file_name:lower():match("%.json$") then
        loc_table = assert(JSON.decode(FP_NFS.read(file_name)))
    else
        loc_table = assert(loadstring(FP_NFS.read(file_name)))()
    end
    local function recurse(target, ref_table)
        if type(target) ~= 'table' then return end --this shouldn't happen unless there's a bad return value
        for k, v in pairs(target) do
            if not ref_table[k] or (type(v) ~= 'table') or type(v[1]) == 'string' then
                ref_table[k] = v
            else
                recurse(v, ref_table[k])
            end
        end
    end
	recurse(loc_table, G.localization)
end

local createOptionsRef = create_UIBox_options
function create_UIBox_options()
    local contents = createOptionsRef()
    if G.STAGE == G.STAGES.MAIN_MENU and not (SMODS and SMODS.can_load) then
        local m = UIBox_button({
            minw = 5,
            button = "FlowerPot_Menu",
            label = {localize{type = 'name_text', key = "j_flower_pot", set = "Joker"}},
            colour = G.C.SO_1.Clubs,
        })
        table.insert(contents.nodes[1].nodes[1].nodes[1].nodes, #contents.nodes[1].nodes[1].nodes[1].nodes + 1, m)
    end
    return contents
end

G.FUNCS.FlowerPot_Menu = function(e)
    local tabs = create_tabs({
        snap_to_nav = true,
        tabs = {
            {
                label = localize{type = 'name_text', key = "j_flower_pot", set = "Joker"},
                chosen = true,
                tab_definition_function = function()
                    G.ACTIVE_FLOWPOT_UI = true
                    return FlowerPot.config_tab()
                end
            },
        }
    })
    G.FUNCS.overlay_menu{
        definition = create_UIBox_generic_options({
            back_func = "options",
            contents = {tabs}
        }),
        config = {offset = {x=0,y=10}}
    }
end

function FlowerPot.config_tab()
    return {
        n = G.UIT.ROOT,
        config = {
            emboss = 0.05,
            minh = 6,
            r = 0.1,
            minw = 10,
            align = "cm",
            padding = 0.2,
            colour = G.C.BLACK
        },
        nodes = {
            {n=G.UIT.C, config = {align = "cm", padding = 0.1}, nodes = {
				create_toggle({
					label = localize("b_flowpot_tooltip_settings"),
					ref_table = FlowerPot.CONFIG,
					ref_value = "stat_tooltips_enabled",
				}),
                create_option_cycle({
                    label = localize('b_flowpot_voucher_sticker_setting'),
                    scale = 0.8,
                    options = localize('b_flowpot_voucher_sticker_options'),
                    opt_callback = 'flowpot_voucher_sticker_settings',
                    current_option = FlowerPot.CONFIG.voucher_sticker_enabled,
                    w = 5
                }),
                UIBox_button({label = {localize("b_flowpot_create_profile_stats")}, button = "create_profile_stat_files", colour = G.C.ORANGE, minw = 5, minh = 0.7, scale = 0.6}),
			}},
        },
    }
end

G.FUNCS.flowpot_voucher_sticker_settings = function(args)
    FlowerPot.CONFIG.voucher_sticker_enabled = args.to_key
    if SMODS and SMODS.can_load then
        SMODS.save_mod_config(SMODS.Mods["FlowerPot"])
    end
end

local GFUNCS_options = G.FUNCS.options
G.FUNCS.options = function(e)
    if G.ACTIVE_FLOWPOT_UI then 
        local success, err = pcall(function() FlowerPot.save_flowpot_config() end)
        if not success then print("FlowerPot-CORE - Config failed to load: "..err) end
    end
    G.ACTIVE_FLOWPOT_UI = nil
    GFUNCS_options(e)
end

G.FUNCS.create_profile_stat_files = function(e)
    fetch_achievements()
    set_profile_progress()
    set_discover_tallies()

    local profile_folder = FlowerPot.path_to_stats()..G.PROFILES[G.SETTINGS.profile].name.."/"
    FlowerPot.create_profile_folders(G.PROFILES[G.SETTINGS.profile].name)

    for _, v in pairs(FlowerPot.stat_groups) do
        FlowerPot.create_stat_files(v, profile_folder)
    end

    FlowerPot.create_complete_profile(profile_folder)
end

local init_game_obj_ref = Game.init_game_object
function Game:init_game_object()
    local ref = init_game_obj_ref(self)
    ref.FLOWPOT = {}
    return ref
end

if not (SMODS and SMODS.can_load) then 
    -- Copy of Steamodded's serialize function for config loading consistency
    function serialize(t, indent)
        indent = indent or ''
        local str = '{\n'
        for k, v in ipairs(t) do
            str = str .. indent .. '\t'
            if type(v) == 'number' then
                str = str .. v
            elseif type(v) == 'boolean' then
                str = str .. (v and 'true' or 'false')
            elseif type(v) == 'string' then
                str = str .. serialize_string(v)
            elseif type(v) == 'table' then
                str = str .. serialize(v, indent .. '\t')
            else
                -- not serializable
                str = str .. 'nil'
            end
            str = str .. ',\n'
        end
        for k, v in pairs(t) do
            if type(k) == 'string' then
                str = str .. indent .. '\t' .. '[' .. serialize_string(k) .. '] = '
                
                if type(v) == 'number' then
                    str = str .. v
                elseif type(v) == 'boolean' then
                    str = str .. (v and 'true' or 'false')
                elseif type(v) == 'string' then
                    str = str .. serialize_string(v)
                elseif type(v) == 'table' then
                    str = str .. serialize(v, indent .. '\t')
                else
                    -- not serializable
                    str = str .. 'nil'
                end
                str = str .. ',\n'
            end
        end
        str = str .. indent .. '}'
        return str
    end

    -- Copy of Steamodded's serialize_string function for config loading consistency
    function serialize_string(s)
        return string.format("%q", s)
    end
end