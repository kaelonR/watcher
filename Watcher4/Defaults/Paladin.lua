------------
-- PALADIN --
------------
if (not Watcher) then
    return;
end

if (select(2, UnitClass('player')) ~= "PALADIN") then
    return;
end

Watcher.classDefaults["PALADIN"] = {
    ["newDefaultDate"] = 1469217919;
    ["priorityLists"] = {
        [1] = {
            ["name"] = "Holy";
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
            ["name"] = "Protection";
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
            ["name"] = "Retribution";
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
