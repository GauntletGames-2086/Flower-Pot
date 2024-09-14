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
    local m = UIBox_button({
        minw = 5,
        button = "FlowerPot_Menu",
        label = {localize{type = 'name_text', key = "j_flower_pot", set = "Joker"}},
        colour = G.C.SO_1.Clubs,
    })
    table.insert(contents.nodes[1].nodes[1].nodes[1].nodes, #contents.nodes[1].nodes[1].nodes[1].nodes + 1, m)
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
            UIBox_button({label = {localize("b_flowpot_create_profile_stats")}, button = "create_profile_stat_files", colour = G.C.ORANGE, minw = 5, minh = 0.7, scale = 0.6}),
        },
    }
end

G.FUNCS.create_profile_stat_files = function(e)
    print("Flower Pot | Creating Profile Stat Files")
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