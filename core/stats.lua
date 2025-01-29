for _, path in ipairs {
    "core/stats/stat_groups.lua",
    "core/stats/formats.lua",
    "core/stats/records.lua",
    "core/stats/other.lua",
  } do
    assert(load(FP_NFS.read(FlowerPot.path_to_self()..path), ('=[FlowerPot-STATS _ "%s"]'):format(path)))()
end