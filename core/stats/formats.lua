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