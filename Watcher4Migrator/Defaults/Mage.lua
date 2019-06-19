------------
-- MAGE --
------------
if (not Watcher) then
    return;
end

if (select(2, UnitClass('player')) ~= "MAGE") then
    return;
end

Watcher.classDefaults["MAGE"] = {
    ["newDefaultDate"] = 1469217919;
    ["priorityLists"] = {
        [1] = {
            ["name"] = "Arcane";
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
            ["name"] = "Fire";
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
            ["name"] = "Frost";
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
