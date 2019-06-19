---------------------
-- SEE LICENSE.TXT --
---------------------

if (not Watcher) then
    return;
end

---------------
-- LIBRARIES --
---------------
local L = LibStub("AceLocale-3.0"):GetLocale("Watcher");
local media = LibStub:GetLibrary("LibSharedMedia-3.0");
local MSQ = LibStub:GetLibrary("Masque", true);


----------------
-- MIGRATIONS --
----------------

function Watcher:Migrate()
    -- check for first launch
    if (not self.db.char.version) then
        self:FirstLaunch();
        return;
    end

    print ("Watcher is migrating from API version "..self.db.char.version.." to API version "..self.apiVersion..". This should convert older settings into the newer version and no action is required.");
    
    -- migrate from 0 to 1
    if (self.db.char.version == 0) then
        -- convert filters to newer version
        for filterSetId, filterSet in pairs(self.db.char.filterSets) do
            for filterId, filter in pairs(self.db.char.filterSets[filterSetId].filters) do
                if (filter.filterType == "auras") then
                    self:ConvertToNewAuraFilter(filter);
                elseif (filter.filterType == "health") then
                    self:ConvertToNewHealthFilter(filter);
                elseif (filter.filterType == "power") then
                    self:ConvertToNewPowerFilter(filter);
                elseif (filter.filterType == "talent") then
                    self:ConvertToNewTalentFilter(filter);
                elseif (filter.filterType == "spec") then
                    self:RemoveFilterSet(filterId);
                end
            end
        end
        
        self.db.char.version = 1;
		self.db.char.addonVersion = self.version;
    end
    
    -- migrate from 1 to 2
    if (self.db.char.version == 1) then
        -- convert all of the secondaryResource filters to use the new optionalBehavior
        for filterSetId, filterSet in pairs(self.db.char.filterSets) do
            for filterId, filter in pairs(self.db.char.filterSets[filterSetId].filters) do
                if (filter.filterType == "secondaryResource") then
                    self:ConvertToNewSecondaryResourceFilter(filter);
                end
            end
        end
    
        for priorityListId, priorityList in pairs(self.db.char.priorityLists) do
            -- add the cooldowns table
            self.db.char.priorityLists[priorityListId].cooldowns = {};
            
            -- remove spellCondition.name, since it doesn't need to exist.
            for spellConditionId, spellCondition in pairs(self.db.char.priorityLists[priorityListId].spellConditions) do
                if (self.db.char.priorityLists[priorityListId].spellConditions[spellConditionId].name) then
                    self.db.char.priorityLists[priorityListId].spellConditions[spellConditionId].name = nil;
                end
            end
        end
    
        self.db.char.version = 2;
    end
    
    self.db.char.version = self.apiVersion;
end

function Watcher:MigrateMinor()
	local latestMigrationVersion = "3.0.7"; --latest version that migrated settings.
	if (not self.db.char.addonVersion) then --Watcher is pre-3.0.6: set version to 3.0.5 since that is the initial release prior to minor migrations.
		self.db.char.addonVersion = "3.0.5";
	end
	if (self.db.char.addonVersion < latestMigrationVersion) then
		print("Watcher has migrated settings to the latest version, "..self.version..". All important changes will be listed below.")
	end
	if (self.db.char.addonVersion < "3.0.6") then
		for filterSetId, filterSet in pairs(self.db.char.filterSets) do
            for filterId, filter in pairs(self.db.char.filterSets[filterSetId].filters) do
                if (filter.filterType == "auras") then
					filter.ifExists = "TRUE"; --set all aura filters to track if aura exists. Needed since the "if exists" toggle wasn't working properly prior to 3.0.6.
				elseif (filter.filterType == "talent") then --return combo points and runes filters to the proper game values.
					if (filter.resourceType == -1) then
						filter.resourceType = 4;
					elseif (filter.resourceType == -2) then
						filter.resourceType = 5
					end
				end
			end
		end
		print("   - Any aura filters you have configured are now set to trigger when the specified aura exists. If you have any filters that depend on the aura NOT existing, you should edit them now and set them to trigger when the aura does not exist.");
    end
    if (self.db.char.addonVersion < "3.0.7") then
        local foundTotemMasteryTotemFilter = false;
        local migratedTotemFilter = false;
        for filterSetId, filterSet in pairs(self.db.char.filterSets) do
            for filterId, filter in pairs(self.db.char.filterSets[filterSetId].filters) do
                if (filter.filterType == "totem" and self.db.char.filterSets[filterSetId].spellId == 210643) then --Totem filter for Totem Mastery
                    Watcher:EvaluatePriorityListFilters() --initialize priority lists, needed for this operation
                    newFilter = {
                        ["filterType"] = "auras",
                        ["unit"] = "player",
                        ["auraType"] = "HELPFUL",
                        ["playerIsCaster"] = true,
                        ["ifExists"] = filter.exists,
                        ["auraName"] = filter.name,
                        ["trackRemainingTime"] = false,
                        ["remainingTimeRelationship"] = "BELOW",
                        ["remainingTime"] = 0,
                        ["trackStacks"] = false,
                        ["stackCount"] = 0,
                        ["stackRelationship"] = "At Least",
                    }
                    local filterSetId = table.getn(self.db.char.filterSets) + 1; --insert filter set
                    self.db.char.spells[210643].filterSetIds[filterSetId] = true;
                    self.db.char.filterSets[filterSetId] = {["name"] = "Totem Mastery Buffs", ["spellId"] = 210643, ["settings"] = {}, filters = {}};
                    Watcher:AddFilter("usability", filterSetId);
                    self.configurationSelections.filterSetId = filterSetId;
                    Watcher:InjectFilterOptions();

                    local filterId = table.getn(self.db.char.filterSets[filterSetId].filters) + 1; --inject filter
                    self.db.char.filterSets[filterSetId].filters[filterId] = newFilter;
                    Watcher:InjectFilterOptions();
                    Watcher:AddSpellToPriorityList(210643, filterSetId, self.activePriorityList); --add to priority list

                    filter.name = "Totem Mastery"; --modify totem filter
                    foundTotemMasteryTotemFilter = true;  
                end
                if (filter.filterType == "totem") then --remove slot option from totem filters
                    filter.slot = nil;
                    migratedTotemFilter = true;
                end
            end
        end
        if (foundTotemMasteryTotemFilter) then
            print("Watcher found a totem filter for the Totem Mastery spell. This has now been converted to separate filter sets with an aura(type: buff, unit: player) filter and a totem filter.");
        end
        if (migratedTotemFilter) then
            print("Totem types have been removed from the totem filter.")
        end
        if (not foundTotemMasteryTotemFilter and not migratedTotemFilter) then
            print("No important changes were recorded.");
        end
    end
	self.db.char.addonVersion = self.version;
end


function Watcher:FirstLaunch()
    self.db.char.version = self.apiVersion;
	self.db.char.addonVersion = self.version;
    StaticPopupDialogs["Watcher First Launch"] = {
        text = L["first_launch"],
        button1 = L["Yes"],
        button2 = L["No"],
        OnAccept = function()
            InterfaceOptionsFrame_OpenToCategory("Watcher");
            InterfaceOptionsFrame_OpenToCategory("Watcher");
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = false,
        preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
    };

    StaticPopup_Show ("Watcher First Launch");
end

function Watcher:ConvertToNewAuraFilter(filter)
    if (not filter.unit) then
        -- convert isBuff to auraType and unit
        if (filter.isBuff) then
            filter.auraType = "HELPFUL";
            filter.unit = "player";
        else
            filter.auraType = "HARMFUL";
            filter.unit = "target";
        end
        
        filter.isBuff = nil;
        
        -- convert stackCount to the various stacks options
        if (filter.stackCount == 0) then
            filter.trackStacks = false;
            filter.stackRelationship = "At Least";
        else
            filter.trackStacks = true;
            
            if (filter.invert) then
                filter.stackRelationship = "At Least";
            else
                filter.stackRelationship = "At Most";
            end
        end
        
        -- convert invert to ifExists
        if (filter.invert) then
            filter.ifExists = true;
        else
            filter.ifExists = false;
        end
        
        filter.invert = nil;
        
        -- convert refreshThreshold into trackRemainingTime
        if (filter.refreshThreshold == 0) then
            filter.trackRemainingTime = false;
            filter.remainingTimeRelationship = "BELOW";
            filter.remainingTime = 0;
        else
            filter.trackRemainingTime = true;
            filter.remainingTimeRelationship = "BELOW";
            filter.remainingTime = filter.refreshThreshold;
        end
        
        filter.refreshThreshold = nil;
    end
end

function Watcher:ConvertToNewHealthFilter(filter)
    if (not filter.relationship) then
        if (filter.player) then
            filter.unit = "player";
        else
            filter.unit = "target";
        end
        
        filter.player = nil;
        
        if (filter.invert) then
            filter.relationship = "ABOVE";
        else
            filter.relationship = "BELOW";
        end
        
        filter.invert = nil;
    end
end

function Watcher:ConvertToNewPowerFilter(filter)
    if (not filter.relationship) then
        if (filter.invert) then
            filter.relationship = "BELOW";
        else
            filter.relationship = "ABOVE";
        end
        
        filter.invert = nil;
    end
end

function Watcher:ConvertToNewTalentFilter(filter)
    if (filter.invert == nil) then
        filter.invert = false;
    end
end

function Watcher:ConvertToNewSecondaryResourceFilter(filter)
    if (not filter.optionalBehavior) then
        filter.optionalBehavior = "";
    end
end