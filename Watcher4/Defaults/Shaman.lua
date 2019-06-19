------------
-- SHAMAN --
------------
if (not Watcher) then
    return;
end

if (select(2, UnitClass('player')) ~= "SHAMAN") then
    return;
end

Watcher.classDefaults["SHAMAN"] = {
    ["newDefaultDate"] = 1469217919;
    ["priorityLists"] = {
        [1] = {
            ["name"] = "Elemental";
            ["cooldowns"] = {};
            ["settings"] = {};
            ["spellConditions"] = {};
            ["filters"] = {
                [1] = {
                    ["filterType"] = "spec";
                    ["specNum"] = 1;
                };
            };
        };
        [2] = {
            ["name"] = "Enhancement";
            ["cooldowns"] = {};
            ["settings"] = {};
            ["spellConditions"] = {};
            ["filters"] = {
                [1] = {
                    ["filterType"] = "spec";
                    ["specNum"] = 2;
                };
            };
        };
        [3] = {
            ["name"] = "Restoration";
            ["cooldowns"] = {};
            ["settings"] = {};
            ["spellConditions"] = {};
            ["filters"] = {
                [1] = {
                    ["filterType"] = "spec";
                    ["specNum"] = 3;
                };
            };
        };
    };
    ["version"] = 2;
    ["spells"] = {};
    ["filterSets"] = {};
};
