local FP_NFS = require("FP_nativefs")

for _, path in ipairs {
  "core/ui/card_stats.lua",
} do
	assert(load(FP_NFS.read(FlowerPot.path_to_self..path), ('=[FlowerPot-UI _ "%s"]'):format(path)))()
end