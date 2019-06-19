------------
-- DRUID --
------------
if (not Watcher) then
    return;
end

if (select(2, UnitClass('player')) ~= "DRUID") then
    return;
end

Watcher.classDefaults["DRUID"] = {
    ["newDefaultDate"] = 1469217919;
    ["priorityLists"] = {
        [1] = {
            ["name"] = "Feral";
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
        [2] = {
            ["name"] = "Balance";
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
        [3] = {
            ["name"] = "Guardian";
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
        [4] = {
            ["name"] = "Restoration";
            ["cooldowns"] = {};
            ["settings"] = {};
            ["spellConditions"] = {};
            ["filters"] = {
                [1] = {
                    ["filterType"] = "spec";
                    ["specNum"] = 4;
                };
            };
        };
    };
    ["version"] = 2;
    ["spells"] = {};
    ["filterSets"] = {};
};
