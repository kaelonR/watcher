---------------------
-- SEE LICENSE.TXT --
---------------------

-------------------
-- SPELL FILTERS --
-------------------
if (not Watcher) then
    return;
end


---------------
-- LIBRARIES --
---------------
local LibDispellable = LibStub:GetLibrary("LibDispellable-1.0");
local LibSpellbook = LibStub:GetLibrary("LibSpellbook-1.0");
local LibPvpTalents = LibStub:GetLibrary("LibPvpTalents-1.0");

-------------
-- GLOBALS --
-------------
Watcher.events = {
    --["EVENT_NAME"] = {["usability"] = true,};
};


-------------------
-- LOOKUP TABLES --
-------------------
Watcher.spellFilterFunctions = {
    ["usability"] = function(spellId, filterSetId, filterId) return Watcher:CheckUsability(spellId, filterSetId, filterId) end,
    ["auras"] = function(spellId, filterSetId, filterId) return Watcher:CheckAura(spellId, filterSetId, filterId) end,
    ["power"] = function(spellId, filterSetId, filterId) return Watcher:CheckPower(spellId, filterSetId, filterId) end,
    ["secondaryResource"] = function(spellId, filterSetId, filterId) return Watcher:CheckSecondaryResource(spellId, filterSetId, filterId) end,
    ["health"] = function(spellId, filterSetId, filterId) return Watcher:CheckHealth(spellId, filterSetId, filterId) end,
    --["timeToLive"] = function(spellId, filterSetId, filterId) return Watcher:CheckTimeToLive(spellId, filterSetId, filterId) end,
    ["classification"] = function(spellId, filterSetId, filterId) return Watcher:CheckClassification(spellId, filterSetId, filterId) end,
    ["targetAura"] = function(spellId, filterSetId, filterId) return Watcher:CheckTargetAura(spellId, filterSetId, filterId) end,
    ["targetCastingInterruptable"] = function(spellId, filterSetId, filterId) return Watcher:CheckTargetCastingInterruptable(spellId, filterSetId, filterId) end,
    --["aoe"] = function(spellId, filterSetId, filterId) return Watcher:CheckAOE(spellId, filterSetId, filterId) end,
    ["totem"] = function(spellId, filterSetId, filterId) return Watcher:CheckTotem(spellId, filterSetId, filterId) end,
    ["talent"] = function(spellId, filterSetId, filterId) return Watcher:CheckSpellTalent(spellId, filterSetId, filterId) end,
    ["spellCharges"] = function(spellId, filterSetId, filterId) return Watcher:CheckSpellCharges(spellId, filterSetId, filterId) end,
};
Watcher.priorityListFilterFunctions = {
    ["spec"] = function(priorityListId, filterId) return Watcher:CheckSpec(priorityListId, filterId); end,
    ["talent"] = function(priorityListId, filterId) return Watcher:CheckTalent(priorityListId, filterId); end,
    ["dualWield"] = function(priorityListId, filterId) return Watcher:CheckIfDualWielding(priorityListId, filterId); end,
};
Watcher.spellFilterEvents = {
    ["usability"] = {
        ["SPELL_UPDATE_USABLE"] = {},
        ["SPELL_UPDATE_COOLDOWN"] = {},
        ["UNIT_POWER_UPDATE"] = {"player"},
        
        ["UNIT_SPELLCAST_CHANNEL_START"] = {"player"},
        ["UNIT_SPELLCAST_CHANNEL_STOP"] = {"player"},
        ["UNIT_SPELLCAST_CHANNEL_UPDATE"] = {"player"},
        ["UNIT_SPELLCAST_DELAYED"] = {"player"},
        ["UNIT_SPELLCAST_INTERRUPTED"] = {"player"},
        ["UNIT_SPELLCAST_START"] = {"player"},
        ["UNIT_SPELLCAST_STOP"] = {"player"},
    },
    ["auras"] = {
        ["UNIT_AURA"] = {"player", "target", "focus", "mouseover", "pet"},
    },
    ["power"] = {
        ["UNIT_MAXPOWER"] = {"player"},
        ["UNIT_POWER_FREQUENT"] = {"player"},
    },
    ["secondaryResource"] = {
        ["UNIT_MAXPOWER"] = {"player"},
        ["UNIT_POWER_FREQUENT"] = {"player"},
        ["RUNE_POWER_UPDATE"] = {},
        ["UNIT_POWER_UPDATE"] = {},
        ["UNIT_AURA"] = {"player"},
    },
    ["health"] = {
        ["UNIT_HEALTH"] = {"player", "target", "focus", "mouseover", "pet"},
    },
    ["targetAura"] = {
        ["UNIT_AURA"] = {"target"},
    },
    ["targetCastingInterruptable"] = {
        ["UNIT_SPELLCAST_INTERRUPTIBLE"] = {"target"},
        ["UNIT_SPELLCAST_NOT_INTERRUPTIBLE"] = {"target"},
        ["UNIT_SPELLCAST_CHANNEL_START"] = {"target"},
        ["UNIT_SPELLCAST_CHANNEL_STOP"] = {"target"},
        ["UNIT_SPELLCAST_CHANNEL_UPDATE"] = {"target"},
        ["UNIT_SPELLCAST_DELAYED"] = {"target"},
        ["UNIT_SPELLCAST_INTERRUPTED"] = {"target"},
        ["UNIT_SPELLCAST_START"] = {"target"},
        ["UNIT_SPELLCAST_STOP"] = {"target"},
    },
    ["totem"] = {
        ["PLAYER_TOTEM_UPDATE"] = {},
    },
    ["spec"] = {
        ["ACTIVE_TALENT_GROUP_CHANGED"] = {},
    },
    ["talent"] = {
        ["CHARACTER_POINTS_CHANGED"] = {},
    },
    ["spellCharges"] = {
        ["SPELL_UPDATE_USABLE"] = {},
        ["SPELL_UPDATE_CHARGES"] = {},
    },
};
Watcher.bucketTimers = {
    --[[
    ["filterType"] = aceTimerID,
    --]]
};
Watcher.buckets = {
    --[[
    ["filterType"] = 0
    --]]
};

----------------------
-- EVALUATE FILTERS --
----------------------
function Watcher:EvaluatePriorityListFilters()
    for priorityListId, priorityList in pairs(self.db.char.priorityLists) do
        local evaluate = true;
        for filterId, filter in pairs(priorityList.filters) do
            evaluate = evaluate and self.priorityListFilterFunctions[filter.filterType](priorityListId, filterId);
        end

        if (evaluate) then
            self.activePriorityList = priorityListId;
            self:UnregisterFilterEvents();
            self:RegisterFilterEvents();
            return;
        end
    end
end

function Watcher:EvaluateSpellFilter(spellId, filterSetId, filterType)
    local evaluate = 0;
    local results = {};

    for filterId, filter in pairs(self.db.char.filterSets[filterSetId].filters) do
        if ((not filterType) or (filterType == filter.filterType)) then
            local filterResult = self.spellFilterFunctions[filter.filterType](spellId, filterSetId, filterId);
            if (not results[filter.filterType]) then
                results[filter.filterType] = {};
            end
            
            results[filter.filterType][filterId] = filterResult;

            if ((not filterResult) or (not evaluate)) then
                evaluate = nil;
            else
                evaluate = math.max(evaluate, filterResult);
            end
        end
    end

    return evaluate, results;
end

function Watcher:EvaluateEvent(eventName, firstArg)
    if (self.events[eventName]) then
        for filterType, exists in pairs(self.events[eventName]) do
            if (self.spellFilterEvents[filterType][eventName]) then
                if (table.getn(self.spellFilterEvents[filterType][eventName]) ~= 0) then
                    -- check args for first arg match
                    for i, arg in pairs(self.spellFilterEvents[filterType][eventName]) do
                        if (firstArg == arg) then
                            -- arg check successful, pass it on
                            self:AddToBucket(filterType);
                        end
                    end
                else
                    -- no arg check, pass it on
                    self:AddToBucket(filterType);
                end
            end
        end
    end
end


----------------------
-- EVENT THROTTLING --
----------------------
function Watcher:AddToBucket(filterType)
    if (not self.buckets[filterType]) then
        self.buckets[filterType] = 1;
        self:BucketTriggered(filterType);
    else
        self.buckets[filterType] = self.buckets[filterType] + 1;
    end
end

function Watcher:BucketTriggered(filterType)
    if (self.buckets[filterType] and (self.buckets[filterType] == 0)) then
        --empty bucket, clean up
        self.bucketTimers[filterType] = nil;
        self.buckets[filterType] = nil;
        return;
    end

    -- something in bucket, update
    self:UpdateByFilterType(filterType);

    -- empty bucket and reschedule timer
    self.buckets[filterType] = 0;
    self.bucketTimers[filterType] = self:ScheduleTimer("BucketTriggered", .1, filterType);
end


------------
-- EVENTS --
------------
function Watcher:RegisterFilterEvents()
    if (self.activePriorityList) then
        local priorityList = self.db.char.priorityLists[self.activePriorityList];
        for priorityNum, spellCondition in ipairs(priorityList.spellConditions) do
            for filterId, filter in pairs(self.db.char.filterSets[spellCondition.filterSetId].filters) do
                if (self.spellFilterEvents[filter.filterType]) then
                    for eventName, argsTable in pairs(self.spellFilterEvents[filter.filterType]) do
                        if (not self.events[eventName]) then
                            -- event not registered yet
                            self.events[eventName] = {};
                            self:RegisterEvent(eventName, "EvaluateEvent");
                        end
                        self.events[eventName][filter.filterType] = true;
                    end
                end
            end
        end
    end
end

function Watcher:UnregisterFilterEvents()
    self:CancelAllTimers();
    if (next(self.events)) then
        for eventName, filterTypeTable in pairs(self.events) do
            self:UnregisterEvent(eventName);
        end
        self.events = {};
        self.bucketTimers = {};
        self.buckets = {};
    end
end


------------
-- HELPER --
------------
function Watcher:CheckForFilterType(filterSetId, filterType)
    for filterId, filter in pairs(self.db.char.filterSets[filterSetId].filters) do
        if (filterType == filter.filterType) then
            return true;
        end
    end

    return false;
end


-------------------
-- SPELL FILTERS --
-------------------
-- these functions return nil if the filter is not met; a number meaning expireTime/metTime; and 0 for met now
function Watcher:CheckUsability(spellId, filterSetId, filterId)
    local filter = self.db.char.filterSets[filterSetId].filters[filterId];
    local timeUntil = 0;

    -- check to see if the spell is known
    if (not LibSpellbook:IsKnown(spellId)) then
        return;
    end

    -- check cooldown
    local startTime, duration, enabled = GetSpellCooldown(spellId);
    local _, gcdDuration, _ = GetSpellCooldown(61304); -- GCD cooldown

    -- if it's 'active', then it cannot be used
    if(enabled == 0) then
        return;
    end

    -- check cast
    local castName, _, _, _, castStartTime, castEndTime = UnitCastingInfo("player");
    
    -- check to see if currently casting spell with cooldown, remove if we are, since the spell will become unusable soon
    if((GetSpellBaseCooldown(spellId) ~= 0) and (castName) and (castName == GetSpellInfo(spellId))) then
        return;
    end

    -- check cast time if option is enabled
    if (castEndTime and self.db.char.castsAffectUsability) then
        timeUntil = math.max((castEndTime/1000), timeUntil);
    end
    
    -- check channel
    local channelName, _, _, _, channelStartTime, channelEndTime = UnitChannelInfo("player");

    -- check cast time if option is enabled
    if (channelEndTime and self.db.char.castsAffectUsability) then
        timeUntil = math.max((channelEndTime/1000), timeUntil);
    end
    
    -- check cooldown
    if (startTime ~= 0) then
        timeUntil = math.max((startTime + duration), timeUntil);
    end

    -- ignore usability, pass the before checking usability
    if (filter.ignore) then
        return timeUntil;
    end

    -- check usability
    local isUsable, notEnoughResources = IsUsableSpell (spellId);
    if (not isUsable) then
        local cost = self:GetPowerCost(spellId);
        local power = UnitPower("player");

        -- check if not enough power and calculate time until power regens
        if (notEnoughResources and cost and (cost > power) and (not self.db.char.hideIconsWhenRecoveringResources)) then
            local inactiveRegen, activeRegen = GetPowerRegen();
            local timeUntilRegen = 0;

            -- regen is determined by in or out of combat
            if (InCombatLockdown()) then
                -- in combat
                timeUntilRegen = (cost - power) / activeRegen;
            else
                timeUntilRegen = (cost - power) / inactiveRegen;
            end

            timeUntil = math.max((GetTime() + timeUntilRegen), timeUntil);
        else
            if (notEnoughResources) then
                if ((startTime + duration) <= (gcdDuration + GetTime())) then
                    return;
                end
            else
                return;
            end
        end
    end

    return timeUntil;
end

function Watcher:CheckAura(spellId, filterSetId, filterId)
    local filter = self.db.char.filterSets[filterSetId].filters[filterId];
    -- build auraFilter (i.e. PLAYER|HARMFUL), etc.
    local auraFilter = "";

    if (filter.playerIsCaster) then
        auraFilter = "PLAYER|";
    end

    auraFilter = auraFilter..filter.auraType;

    -- get information about the aura on the unit
    local auraName, _, auraCount, _, auraDuration, auraExpirationTime, _, _, _, _ = AuraUtil.FindAuraByName(filter.auraName, filter.unit, auraFilter);

    if (auraName) then
		if (not filter.ifExists) then
			return;
		end
        -- aura exists
        local timeRemaining = auraExpirationTime - GetTime();

        if (filter.ifExists) then
            -- looking for existence of aura and found it; check if stacks and remainingTime match;

            -- check if failed stack count check
            if (filter.trackStacks) then
                if (((filter.stackRelationship == "At Least") and (auraCount < filter.stackCount))
                    or (filter.stackRelationship == "Equals" and (auraCount ~= filter.stackCount))
                    or (filter.stackRelationship == "At Most" and (auraCount > filter.stackCount))) then
                    return;
                end
            end

            -- check if the remaining time is right
            if (filter.trackRemainingTime) then
                if (filter.remainingTimeRelationship == "BELOW") then
                    -- looking for if the remaining time is below
                    if (timeRemaining <= filter.remainingTime) then
                        return 0;
                    else
                        -- return the time when it will reach the desired point.
                        return (GetTime() + (timeRemaining - filter.remainingTime));
                    end
                else
                    -- looking for if the remaining time is above
                    if (timeRemaining >= filter.remainingTime) then
                        return 0;
                    end
                end
            else
                return 0;
            end
        else
            -- looking for non-existence of an aura and found that it existed, check if the remaining time matches
            -- only "BELOW" has any meaning here
            if (filter.trackRemainingTime and filter.remainingTimeRelationship == "BELOW") then
                if (timeRemaining <= filter.remainingTime) then
                    return 0;
                else
                    return (GetTime() + (timeRemaining - filter.remainingTime));
                end
            end
            
            -- return the time in which the aura will not exist.
            return auraExpirationTime;
        end
    else
        -- aura doesn't exist
        if (not filter.ifExists) then
            -- looking for non-existence of an aura and found it.
            return 0;
        end

        -- else, return nothing for filter.ifExists
    end
end

function Watcher:CheckPower(spellId, filterSetId, filterId)
    local filter = self.db.char.filterSets[filterSetId].filters[filterId];
	local _, _, classID = UnitClass("player");
	local curPower = UnitPower("player");
	local powerMax = UnitPowerMax("player");
	if (classID == 7) then --shaman mana/maelstrom fix
		curPower = UnitPower("player",0);
		powerMax = UnitPowerMax("player",0);
	end
    -- TODO: implement keep enough resources
    
    -- remove the mana from the current cast
    local castSpellId = LibSpellbook:Resolve(UnitCastingInfo("player"));
    local castCost = Watcher:GetPowerCost(castSpellId);
    
    if (castCost) then
        curPower = curPower - castCost;
    end

    if (filter.relationship == "BELOW") then
        if ((curPower/powerMax) <= filter.threshold/100) then
            return 0;
        end
    else
        if ((curPower/powerMax) >= filter.threshold/100) then
            return 0;
        else
            if (not self.db.char.hideIconsWhenRecoveringResources) then
                -- calculate when player will have this amount of power
                local powerRequired = (UnitPowerMax("player") * filter.threshold/100);

                if (powerRequired and (powerRequired > curPower)) then
                    local inactiveRegen, activeRegen = GetPowerRegen();
                    local timeUntilRegen = 0;

                    -- regen is determined by in or out of combat
                    if (InCombatLockdown()) then
                        -- in combat
                        timeUntilRegen = (powerRequired - curPower) / activeRegen;
                    else
                        timeUntilRegen = (powerRequired - curPower) / inactiveRegen;
                    end

                    return (GetTime() + timeUntilRegen);
                end
            end
        end
    end
end

function Watcher:CheckSecondaryResource(spellId, filterSetId, filterId)
    local filter = self.db.char.filterSets[filterSetId].filters[filterId];
    local value = self:GetSecondaryResource(filter.resourceType, filter.optionalBehavior);

    if (filter.resourceType and filter.relationship and filter.value) then
        if (filter.relationship == "At Least") then
            if (filter.value <= value) then
                return 0;
            end
        elseif (filter.relationship == "At Most") then
            if (filter.value >= value) then
                return 0;
            end
        elseif (filter.relationship == "Equals") then
            if (filter.value == value) then
                return 0;
            end
        end
    end
end

function Watcher:CheckHealth(spellId, filterSetId, filterId)
    local filter = self.db.char.filterSets[filterSetId].filters[filterId];

    if (filter.relationship == "ABOVE") then
        if (self:GetHealthPercent(filter.unit) >= filter.threshold/100) then
            return 0;
        end
    else
        if (self:GetHealthPercent(filter.unit) <= filter.threshold/100) then
            return 0;
        end
    end
end

function Watcher:CheckTimeToLive(spellId, filterSetId, filterId) -- TODO
end

function Watcher:CheckClassification(spellId, filterSetId, filterId)
    local filter = self.db.char.filterSets[filterSetId].filters[filterId];
    local unitClassification = UnitClassification("target");

    if (filter.relationship == "At Least") then
        if (self.unitClassificationsValues[filter.value] <= self.unitClassificationsValues[unitClassification]) then
            return 0;
        end
    elseif (filter.relationship == "At Most") then
        if (self.unitClassificationsValues[filter.value] >= self.unitClassificationsValues[unitClassification]) then
            return 0;
        end
    elseif (filter.relationship == "Equals") then
        if (self.unitClassificationsValues[filter.value] == self.unitClassificationsValues[unitClassification]) then
            return 0;
        end
    end
end

function Watcher:CheckTargetAura(spellId, filterSetId, filterId)
    local filter = self.db.char.filterSets[filterSetId].filters[filterId];
    local i = 1;

    local name, dispelType, isStealable, _;

    repeat
        name, _, _, dispelType, _, _, _, isStealable, _, auraSpellId = UnitAura("target", i);

        if (name and ((not filter.useWhitelist) or filter.whitelist[name])) then
            if (UnitIsEnemy("player", "target") and filter.stealable and isStealable) then
                return 1;
            end

            if (LibDispellable:CanDispelWith("target", spellId)) then
                return 1;
            end
        end

        i = i + 1;
    until (not name)

end

function Watcher:CheckTargetCastingInterruptable(spellId, filterSetId, filterId)
    local filter = self.db.char.filterSets[filterSetId].filters[filterId];
    local name, _, _, _, _, _, _, notInterruptible = UnitCastingInfo("target");

    if (filter.useWhitelist) then
        if (not filter.whitelist[name]) then
            return;
        end
    end

    if (name and not notInterruptible) then
        return 1;
    end
end

function Watcher:CheckAOE(spellId, filterSetId, filterId) -- TODO
end

function Watcher:CheckTotem(spellId, filterSetId, filterId)
    local filter = self.db.char.filterSets[filterSetId].filters[filterId];
    for i = 1, 5 do --MAX_TOTEMS is 4, but GetTotemInfo returns data up to 5.
        local haveTotem, name, startTime, duration, icon = GetTotemInfo(i);
        if (name == filter.name) then
            return;
        end
    end
    local expireTime = 0;

    if (filter.exists and not haveTotem) then
        return;
    elseif (not filter.exists and not haveTotem) then
        return expireTime;
    end

    if ((filter.name ~= "") and name ~= filter.name) then
        print("Totem was incorrect!");
        return;
    end

    expireTime = startTime + duration

    if (filter.refreshThreshold > 0) then
        expireTime = (expireTime - filter.refreshThreshold);
        if (expireTime < 0) then
            expireTime = 0;
        end
    end

    return expireTime;
end

function Watcher:CheckSpellCharges(spellId, filterSetId, filterId)
    local filter = self.db.char.filterSets[filterSetId].filters[filterId];
    local currentCharges, maxCharges, cooldownStart, cooldownDuration, _ = GetSpellCharges(spellId);

    -- spell doesn't have charges!
    if (not currentCharges or not maxCharges) then
        return;
    end

    if (filter.relationship and filter.numCharges) then
        if (filter.relationship == "At Least") then
            if (currentCharges >= filter.numCharges) then
                return 0;
            elseif ((filter.numCharges <= maxCharges) and (currentCharges < maxCharges)) then
                return (cooldownStart + ((filter.numCharges - currentCharges) * cooldownDuration))
            end
        elseif (filter.relationship == "At Most") then
            if (currentCharges <= filter.numCharges) then
                return 0;
            end
        elseif (filter.relationship == "Equals") then
            if (filter.numCharges == currentCharges) then
                return 0;
            elseif ((filter.numCharges <= maxCharges) and (currentCharges < maxCharges) and (currentCharges <= filter.numCharges)) then
                return (cooldownStart + ((filter.numCharges - currentCharges) * cooldownDuration));
            end
        end
    end
end

function Watcher:CheckSpellTalent(spellId, filterSetId, filterId)
    local filter = self.db.char.filterSets[filterSetId].filters[filterId];
    local _, _, _, selected, _ = GetTalentInfoByID(filter.talentNum, GetActiveSpecGroup());
	if (not selected) then --if not found, check PVP talents instead.
		selected = LibPvpTalents:TalentIsSelected(filter.talentNum);
	end
    if (selected and not filter.invert) then
        return 0;
    elseif (not selected and filter.invert) then
        return 0;
    end
end


---------------------------
-- PRIORITY LIST FILTERS --
---------------------------
-- these functions return false if not met or true if met
function Watcher:CheckSpec(priorityListId, filterId)
    local filter = self.db.char.priorityLists[priorityListId].filters[filterId];

    return (filter.specNum == GetSpecialization());
end

function Watcher:CheckTalent(priorityListId, filterId)
    local filter = self.db.char.priorityLists[priorityListId].filters[filterId];

    local _, _, _, selected, _ = GetTalentInfo(filter.talentNum);
    return selected;
end

function Watcher:CheckIfDualWielding(priorityListId, filterId)
    local filter = self.db.char.priorityLists[priorityListId].filters[filterId];
    local isDualWielding = GetInventoryItemID("player", INVSLOT_OFFHAND) ~= nil;
    
    return (isDualWielding == filter.isDualWielding);
end
