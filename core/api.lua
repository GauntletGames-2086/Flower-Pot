FlowerPot.stat_types = {}
FlowerPot.index_stat_types = {}
-- "key": REQUIRED. Used when indexing FlowerPot.stat_types
-- "valid_stat_groups": REQUIRED. Table of keys to stat groups that will use this stat type
-- "create_stat_table": REQUIRED. Creates a stat table
-- "display_txt": OPTIONAL. Table with the keys to display text
function FlowerPot.addStatType(stat_type)
    for i, v in ipairs({"key", "valid_stat_groups", "create_stat_table"}) do
        if not stat_type[v] then error(("Flower Pot | Registered stat type does not have required param \"%s\""):format(v)) end
    end

    FlowerPot.stat_types[stat_type.key:lower()] = stat_type
    FlowerPot.index_stat_types[#FlowerPot.index_stat_types+1] = stat_type
end

FlowerPot.stat_groups = {}
FlowerPot.index_stat_groups = {}
-- "key": REQUIRED. Used when indexing FlowerPot.stat_groups
-- "folder_dir": REQUIRED. Table of names that this stat group will be saved to
-- "file_name": REQUIRED. Name of the stat_group file
-- "create_data_table" (self, format): REQUIRED. Function that creates the data used by the formats
-- "compat": OPTIONAL. Some formats require extra information, and will not save this stat group if not provided
function FlowerPot.addStatGroup(stat_group)
    for i, v in ipairs({"key", "folder_dir", "file_name", "create_data_table"}) do
        if not stat_group[v] then error(("Flower Pot | Registered stat group does not have required param \"%s\""):format(v)) end
    end

    FlowerPot.stat_groups[stat_group.key:lower()] = stat_group
    FlowerPot.index_stat_groups[#FlowerPot.index_stat_groups+1] = stat_group
end

FlowerPot.stat_tabs = {}
FlowerPot.index_stat_tabs = {}
-- "key": REQUIRED. Used when indexing FlowerPot.stat_tab
-- "tab_definition": REQUIRED. Function that returns the tab UI
function FlowerPot.addStatTab(stat_tab)
    for i, v in ipairs({"key", "tab_definition"}) do
        if not stat_group[v] then error(("Flower Pot | Registered stat tab does not have required param \"%s\""):format(v)) end
    end

    FlowerPot.stat_tabs[stat_tab.key:lower()] = stat_tab
    FlowerPot.index_stat_tabs[#FlowerPot.index_stat_tabs+1] = stat_tab
end

FlowerPot.formats = {}
FlowerPot.index_formats = {}
-- "key": REQUIRED. Used when indexing FlowerPot.formats
-- "write_file" (self, data_table, stat_group, file_type_path): REQUIRED. Function to write the stat group file
-- "decode_file" (self, file_path): OPTIONAL. Function to decode file (not always needed)
-- "write_profile" (self, path_to_format): OPTIONAL. function to write the full stats profile
-- "compat_req": OPTIONAL. Some formats require extra information to save, and this will restrict stat groups to only those meeting the requirements
function FlowerPot.addFormat(format)
    for i, v in ipairs({"key", "write_file"}) do
        if not format[v] then error(("Flower Pot | Registered file format does not have required param \"%s\""):format(v)) end
    end

    FlowerPot.formats[format.key:lower()] = format
    FlowerPot.index_formats[#FlowerPot.index_formats+1] = format
end

FlowerPot.records = {}
FlowerPot.rev_lookup_records = {}
-- "key": REQUIRED. Used when indexing FlowerPot.records
-- "add_tooltips" (self, info_queue, card_progress, card): REQUIRED. Function to add tooltips onto the card
    -- Note: "card" paramater does not exist unless Steamodded is loaded
-- "check_record" (self, card): REQUIRED. Function to return the value
-- "cards": OPTIONAL. Table with keys to cards with this record. Adds keys into FlowerPot.rev_lookup_records
    -- Adding a card to a record already declared is done through FlowerPot.rev_lookup_records[<card key>] = copy_table(<record config>)
-- "default": OPTIONAL. Default value

function FlowerPot.addRecord(record)
    for i, v in ipairs({"key", "add_tooltips", "check_record"}) do
        if not record[v] then error(("Flower Pot | Registered record does not have required param \"%s\""):format(v)) end
    end

    for i, v in ipairs(record.cards or {}) do
        FlowerPot.rev_lookup_records[v] = copy_table(record)
    end

    FlowerPot.records[record.key:lower()] = record
end