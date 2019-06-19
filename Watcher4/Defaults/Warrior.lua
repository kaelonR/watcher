------------
-- WARRIOR --
------------
if (not Watcher) then
    return;
end

if (select(2, UnitClass('player')) ~= "WARRIOR") then
    return;
end

Watcher.classDefaults["WARRIOR"] = {
    ["newDefaultDate"] = 1469217919;
    ["priorityLists"] = {
        [1] = {
            ["name"] = "Arms";
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
            ["name"] = "Fury";
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
            ["name"] = "Protection";
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
