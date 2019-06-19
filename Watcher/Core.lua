---------------------
-- SEE LICENSE.TXT --
---------------------

---------------
-- LIBRARIES --
---------------
local AceAddon = LibStub("AceAddon-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("Watcher");
local media = LibStub:GetLibrary("LibSharedMedia-3.0");
local LibSpellbook = LibStub:GetLibrary("LibSpellbook-1.0");
local LibPvpTalents = LibStub:GetLibrary("LibPvpTalents-1.0");

----------
-- CORE --
----------
Watcher = AceAddon:NewAddon("Watcher", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceSerializer-3.0");
Watcher.apiVersion = 2;

-------------
-- GLOBALS --
-------------
Watcher.activePriorityList = nil;
Watcher.startTime = nil;
Watcher.classDefaults = {};
Watcher.replacedSpellsCache = {};
Watcher.showDebugTab = true;

-----------------------------
-- DEFAULT SAVED VARIABLES --
-----------------------------

Watcher.defaults = {
    char = {
        enable = true,

        -- position settings
        unlocked = false,
        point = "CENTER",
        relativeTo = "UIParent",
        relativePoint = "CENTER",
        xOffset = 0,
        yOffset = -200,

        -- visiblity settings
        showOnlyInCombat = false,
        showOnlyOnAttackableTarget = false,
        showInRaid = true,
        showInParty = true,
        showWhilePVP = true,
        showWhileSolo = true,

        -- icon settings
        desaturateIconsWhenUnusable = true,
        hideIconsWhenRecoveringResources = false,

        -- display settings
        iconAlpha = 1,
        backgroundAlpha = 0.6,
        iconFont = "Friz Quadrata TT",
        iconFontEffect = "OUTLINE",
        iconFontSize = 24,
        scale = .85,
        textAnchor =  "center",
        growDir = "right",
        showCooldownText = true,
        showLabel = true,
        iconSize = 50,
        labelColor = {r = 1, g = 1, b = 1, a = 1},
        labelVertPos = 0,
        labelHoriPos = 0,
        numIcons = 64,

        -- timeline settings
        orientToGCD = false,
        castsAffectUsability = false,
        maxStackedIcons = 3,
        stackHeight = .3,
        showIncrementText = true,
        timeIncrements = {},
        timeSegmentWidth = 50,
        barFontSize = 12,

        -- indexed by spellId
        spells = {
            ['*'] = {
                settings = {
                    label = "",
                    dropdownLabel = "",
                    keepEnoughResources = false,
                },
                filterSetIds = {},
            },
        },

        -- indexed by filterSetId which will just be number incremented up
        filterSets = {
            ['*'] = {
                name = "",
                spellId = 0,
                settings = {
                },
                filters = {
                    ['*'] = {
                        filterType = "", -- filters are documented in Filter.lua
                    },
                },
            },
        },

        -- indexed by priorityListId which is just a number incremented up
        priorityLists = {
            ['*'] = {
                name = "",
                spellConditions = {},
                cooldowns = {},
                settings = {
                },
                filters = {
                    ['*'] = {
                        filterType = "", -- filters are documented in Filter.lua
                    },
                },
            },
        },
    },
}

function Watcher:ScanReplacedSpells()
    Watcher.replacedSpellsCache = {};
    for i = 1, GetNumSpellTabs() do --retrieve list of all learned spells
        local _,_,tabOffset,numEntries,_,inactive = GetSpellTabInfo(i);
        if (inactive == 0) then
            for index = tabOffset + 1, tabOffset + numEntries do
                local spellName, _, spellNameId = GetSpellBookItemName(index, BOOKTYPE_SPELL);
                local skillType, special = GetSpellBookItemInfo(index, BOOKTYPE_SPELL);
                if (skillType == "SPELL") then
                    local name = GetSpellInfo(special);
                    if (name ~= spellName) then
                        Watcher.replacedSpellsCache[special] = spellNameId;
                    end
                end
            end
        end
    end
end

StaticPopupDialogs["CONFIRM_RESET"] = {
  text = L["reset_ask_confirm"],
  button1 = "Yes",
  button2 = "No",
  OnAccept = function()
      Watcher:Reset()
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

StaticPopupDialogs["WATCHER_TRACKER_URL"] = {
  text = L["copy_url_instruction"],
  button1 = "Close",
  hasEditBox = 1,
  OnShow = function(self)
	self.editBox:SetText("https://wow.curseforge.com/projects/shotwatch/issues");
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

----------------
-- SETUP/INIT --
----------------
function Watcher:OnInitialize()
    -- Setup database and register defaults
    self.db = LibStub("AceDB-3.0"):New("WatcherDB", Watcher.defaults, "char");

    -- Get versioning information
    self.version = GetAddOnMetadata("Watcher", "Version");

    local packageVersion = GetAddOnMetadata("Watcher", "X-Curse-Packaged-Version");
    if (packageVersion) then
        self.version = self.version.." ("..packageVersion..")";
    end

    -- register options
    self.generalOptions.name = self.generalOptions.name.." "..self.version.." Settings";
    Watcher:RegisterOptions(); -- TODO: move into load on demand module to reduce memory usage

    self:RegisterChatCommand("watcher", "HandleChatCommand");
    self:RegisterChatCommand("watch", "HandleChatCommand");
    self:RegisterChatCommand("Watcher", "HandleChatCommand");
	self:RegisterChatCommand("Watch", "HandleChatCommand");

    if (not self.db.char.enable) then
        self:Disable();
    end
end

function Watcher:OnEnable()
    self.db.char.enable = true;

    -- create default spec priority lists
    -- TODO: more elegant default system
    if ((not self.db.char.priorityLists) or (not next(self.db.char.priorityLists))) then
        self:SetDefaultPriorityListsSpellsAndFilterSets();
    end

    --The profiles date is older then the new defaults
    --Give the user the option to use the new defaults
    local classDefaults = self:GetDefaultConfig();
    if (self.db.char.newDefaultDate < classDefaults.newDefaultDate) then
        self:ResetToDefaultsDialog();
        self.db.char.newDefaultDate = classDefaults.newDefaultDate; -- no matter what, update to the default timestamp.
    end
    
    -- check the Watcher.apiVersion if it doesn't exist or is lesser than, call the migration function
    if ((not self.db.char.version) or (self.db.char.version < self.apiVersion)) then
        self:Migrate();
    end
	if ((not self.db.char.addonVersion) or self.db.char.addonVersion < self.version) then --Aura filter migration: set ifExists to true on all aura filters
		self:MigrateMinor();
	end

    -- Register events
    self:RegisterEvent("PLAYER_REGEN_ENABLED");
    self:RegisterEvent("PLAYER_REGEN_DISABLED");
    self:RegisterEvent("PLAYER_TALENT_UPDATE");
    self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");

    self:RegisterEvent("PLAYER_ENTERING_WORLD", "SetupPriorityFrame");
    self:RegisterEvent("PLAYER_TARGET_CHANGED", "SetupPriorityFrame");

    self:RegisterEvent("RAID_ROSTER_UPDATE", "ShowHidePriorityFrame");
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "ShowHidePriorityFrame");

    -- if the display doesn't have any timeIncrements; make some.
    if (not self.db.char.timeIncrements or table.getn(self.db.char.timeIncrements) == 0) then
        self:ResetTimeSegments();
    end

    self:EvaluatePriorityListFilters();
    self:SetupPriorityFrame();
end

function Watcher:ResetToDefaultsDialog()
    StaticPopupDialogs["Watcher Reset Defaults"] = {
        text = L["update_defaults"],
        button1 = L["Yes"],
        button2 = L["No"],
        OnAccept = function()
            self:SetDefaultPriorityListsSpellsAndFilterSets();
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = false,
        preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
    };

    StaticPopup_Show ("Watcher Reset Defaults");
end

function Watcher:GetDefaultConfig()
    local className = select(2, UnitClass('player'));
    return Watcher.classDefaults[className];
end

function Watcher:SetDefaultPriorityListsSpellsAndFilterSets()
    --Save to characters own
    local classDefaults = self:GetDefaultConfig();

    self.db.char.priorityLists = classDefaults.priorityLists;
    self.db.char.filterSets = classDefaults.filterSets;
    self.db.char.spells = classDefaults.spells;
    self.db.char.version = classDefaults.version;
	self.db.char.addonVersion = self.version;
    self.db.char.newDefaultDate = classDefaults.newDefaultDate; -- So we do not ask this every time the addon starts

    self:InjectPriorityOptions();
    self:SetupPriorityFrame();
end

function Watcher:OnDisable()
    self.db.char.enable = false;

    -- Register events
    self:UnregisterEvent("PLAYER_REGEN_ENABLED");
    self:UnregisterEvent("PLAYER_REGEN_DISABLED");

    self:UnregisterEvent("PLAYER_TALENT_UPDATE");
    self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
    self:UnregisterEvent("PLAYER_TARGET_CHANGED");

    self:UnregisterEvent("RAID_ROSTER_UPDATE");
    self:UnregisterEvent("PARTY_MEMBERS_CHANGED");

    self:UnregisterFilterEvents();

    self.activePriorityList = nil;

    self:SetupPriorityFrame();
end

function Watcher:HandleChatCommand(args)
    if (not args or (args:trim() == "")) then
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame["Spell_Options"]);
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame["Spell_Options"]);
	elseif (args:trim() == "reset") then
		StaticPopup_Show("CONFIRM_RESET")
		return
	elseif (args:trim() == "ver" or args:trim() == "version") then
		print("Watcher "..self.version);
		return
	elseif (args:trim() == "dis" or args:trim() == "display") then
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame["Display_Options"]);
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame["Display_Options"]);
    elseif (args:trim() == "prio" or args:trim() == "priority") then
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame["Priority_Options"]);
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame["Priority_Options"]);
	elseif (string.find(args, "pvpname") == 1) then
		local _, specId, name = self:GetArgs(args,3);
		print(LibPvpTalents:GetTalentFromName(specId, name));
		return
	elseif (string.find(args, "pvp") == 1) then
		local _, specId = self:GetArgs(args,2);
		specId = tonumber(specId);
		for i, v in pairs(LibPvpTalents:GetSpecTalents(specId)) do
			print(v);
		end
		return
	elseif (args:trim() == "changes" or args:trim() == "changelog") then
		self:DisplayChanges();
    else
        LibStub("AceConfigCmd-3.0").HandleCommand(Watcher, "watcher", "Watcher", args)
    end
end

function Watcher:DisplayChanges()
	local lastUpdate = Watcher.changelog:sub(1,Watcher.changelog:find("Update",50)-2);
		for v in lastUpdate:gmatch("[^\r\n]+") do
			ChatFrame1:AddMessage(v);
		end
	return
end

function Watcher:Reset()
    self.db:ResetDB();
    self:ResetTimeSegments();
    ReloadUI();
end

function Watcher:LaunchTracker()
	StaticPopup_Show("WATCHER_TRACKER_URL");
end

-----------------
-- MISC/HELPER --
-----------------
function Watcher:GetDurationString(duration)
    local durationString = (("%1.1f"):format(duration % 120));

    -- check and correct durationString for more than 2 minutes or 2 hours
    if (duration >= 60) then
        duration = floor(duration - (duration % 60)) / 60; -- minutes
        durationString = (duration % 60) .."m ";

        if (duration >= 120) then
            duration = (duration - (duration % 60)) / 60; -- hours
            durationString = (duration + 1).. "h ";
        end
    end

    return durationString;
end


-- Percent health/power
function Watcher:GetHealthPercent(unit)
    return (UnitHealth(unit)/UnitHealthMax(unit));
end

function Watcher:GetPowerPercent(unit)
    return (UnitPower(unit)/UnitPowerMax(unit));
end


-- Secondary Resources
function Watcher:GetSecondaryResource(resourceType, optionalBehavior)
    --[[
	[4] = L["Combo Points (Druid) (Rogue)"],
    [5] = L["Runes (Death Knight)"],
	[7] = L["Soul Shards (Warlock)"],
    [8] = L["Astral Power (Druid)"],
    [9] = L["Holy Power (Paladin)"],
	[11] = L["Maelstrom (Shaman)"],
    [12] = L["Chi (Monk)"],
	[13] = L["Insanity (Priest)"],
    [16] = L["Arcane Charges (Mage)"],
	[17] = L["Fury (Demon Hunter)"],
	[18] = L["Pain (Demon Hunter)"]
	]]

    if (resourceType == SPELL_POWER_SOUL_SHARDS) then
        -- return soul shards with a decimal
        return (UnitPower("player", resourceType, true))/100.0;
    elseif (resourceType > 0 and resourceType ~= 4 and resourceType ~= 5) then
        return UnitPower("player", resourceType);
    elseif (resourceType == 5) then
        local numActive = 0;
        for i = 1, 6 do
            numActive = numActive + GetRuneCount(i);
        end
        return numActive;
    elseif (resourceType == 4) then
        local comboPoints = GetComboPoints("player", "target");
        
        if (optionalBehavior and (optionalBehavior == "ANTICIPATION") and (comboPoints >= 5)) then
            local _, _, _, auraCount = UnitAura("player", GetSpellInfo(114015), nil, "PLAYER|HELPFUL");
            
            if (auraCount) then
                comboPoints = comboPoints + auraCount;
            end
        end
    
        return comboPoints;
    end
end

function Watcher:GetSecondaryResourceList()
    local secondaryResourceList = {};
    
    -- TODO: FIX THIS
    local class = UnitClass("player"); -- there are other returns, but all we care about is localized name

    for k, v in pairs(self.resourceTypes) do
        if (string.find(v, "("..class..")")) then
            secondaryResourceList[k] = v;
        end
    end

    return secondaryResourceList;
end

function Watcher:CheckClassSecondaryResource()
    local secondaryResourceList = self:GetSecondaryResourceList();

    for k, v in pairs(secondaryResourceList) do
        return false;
    end

    return true;
end

function Watcher:GetSecondaryResourceMin(resourceType)
    if (resourceType) then
        if (resourceType == SPELL_POWER_ECLIPSE) then
            return -100;
        else
            return 0;
        end
    else
        return -100;
    end
end

function Watcher:GetSecondaryResourceMax(resourceType)
    if (resourceType) then
        if (resourceType == -1) then
            return 10;
        elseif (resourceType == -2) then
            return 6;
        elseif ((resourceType <= -3) and (resourceType >= -5)) then
            return 2;
        else
            return UnitPowerMax("player", resourceType);
        end
    else
        return 100;
    end
end

function Watcher:GetSecondaryResourceStep(resourceType)
    if (resourceType) then
        if (resourceType == SPELL_POWER_SOUL_SHARDS) then
            return .01;
        else
            return 1;
        end
    else
        return 1;
    end
end

--[[function Watcher:GetTimeUntilSecondaryResource(resourceType, have, want)
    -- if it's a rune
    if ((resourceType == 5) and (have < want)) then
        local runicCooldowns = {};
        
        for slot = 1, 6 do
            local start, duration, runeReady = GetRuneCooldown(slot);
            
            if (not runeReady) then
                -- check to see if start is in the past, which means that it has happened already
                if (GetTime() >= start) then
                    table.insert(runicCooldowns, (start + duration) - GetTime());
                else
                    -- start is sometime in the future, just add the duration
                    table.insert(runicCooldowns, duration);
                end
            end
        end
        
        local function AnIndexOf(t, val)
            for k,v in ipairs(t) do 
                if v == val then return k end
            end
        end
        
        local timeUntil = 0;
        
        for runes = have, want-1 do
            if (#runicCooldowns and #runicCooldowns ~= 0) then
                local minimum = math.min(unpack(runicCooldowns));
                timeUntil = timeUntil + minimum;
                table.remove(runicCooldowns, AnIndexOf(runicCooldowns, minimum));
            else
                return;
            end
        end
        
        if (timeUntil ~= 0) then
            return timeUntil + GetTime();
        end
    end
end--]]


-- Talents/Specs
function Watcher:GetSpecList()
    local specList = {};

    for i = 1, GetNumSpecializations() do
        local _, name = GetSpecializationInfo(i); -- there are other returns, only care about name
        specList[i] = name;
    end

    return specList;
end

function Watcher:GetTalentList()
    local talentList = {};
    local numTiers = GetMaxTalentTier();
    local numRows = 3;
    local activeSpec = GetActiveSpecGroup();
	local specId = GetSpecializationInfo(GetSpecialization())

    for tier = 1, numTiers do
        for column = 1, numRows do
            local talentID, name = GetTalentInfo(tier, column, activeSpec);
            talentList[talentID] = name;
        end
    end
	
	for k,v in pairs(LibPvpTalents:GetSpecTalents(specId)) do
		talentList[k] = v
	end
    return talentList;
end

function Watcher:GetTalentIdByName(talentName)
    talentName = strlower(talentName)
    local spec = GetActiveSpecGroup();
    for tier = 1, 7 do
        for col = 1, 3 do
            local talentID, spellName = GetTalentInfo(tier, col, spec)
            if strlower(spellName) == talentName then
                return talentID
            end
        end
    end
end

function Watcher:GetTalentNameById(id)
    local spec = GetActiveSpecGroup();
    for tier = 1, 7 do
        for col = 1, 3 do
            local talentID, spellName = GetTalentInfo(tier, col, spec)
            if id == talentID then
                return spellName
            end
        end
    end
end

function Watcher:GetTalentByName(talentName)
    return self:GetTalentIdByName(talentName);
end


-- Fonts
function Watcher:GetFontList()
    local fonts = {};

    -- get fonts
    for k, v in pairs(media:List("font")) do
        fonts[v] = v;
    end

    return fonts;
end

-- Thanks for Bodypull on the blizzard forums for this snippet of code
local CostTip = CreateFrame('GameTooltip');
local CostText = CostTip:CreateFontString();
CostTip:AddFontStrings(CostTip:CreateFontString(), CostTip:CreateFontString());
CostTip:AddFontStrings(CostText, CostTip:CreateFontString());

function Watcher:GetPowerCost(spellId)
    if (not spellId) then
        return;
    end

    local PowerPatterns = {
		SPELL_POWER_HEALTH = '^' .. gsub(HEALTH_COST, '%%d', '([.,%%d]+)', 1) .. '$',
        SPELL_POWER_MANA = '^' .. gsub(MANA_COST, '%%d', '([.,%%d]+)', 1) .. '$',
		SPELL_POWER_RAGE = '^' .. gsub(RAGE_COST, '%%d', '([.,%%d]+)', 1) .. '$',
        SPELL_POWER_FOCUS = '^' .. gsub(FOCUS_COST, '%%d', '([.,%%d]+)', 1) .. '$',
        SPELL_POWER_ENERGY = '^' .. gsub(ENERGY_COST, '%%d', '([.,%%d]+)', 1) .. '$',
		SPELL_POWER_CHI = '^' .. gsub(CHI_COST, '%%d', '([.,%%d]+)', 1) .. '$',
		SPELL_POWER_HOLY_POWER = '^' .. gsub(HOLY_POWER_COST, '%%d', '([.,%%d]+)', 1) .. '$',
		SPELL_POWER_LIGHT_FORCE = '^' .. gsub(LIGHT_FORCE_COST, '%%d', '([.,%%d]+)', 1) .. '$',
		SPELL_POWER_DEMONIC_FURY = '^' .. gsub(DEMONIC_FURY_COST, '%%d', '([.,%%d]+)', 1) .. '$',
		SPELL_POWER_RUNE = gsub(RUNE_COST, '%%d', '([.,%%d]+)', 1) .. '$',
		SPELL_POWER_BLOOD = '^' .. gsub(RUNE_COST_BLOOD, '%%d', '([.,%%d]+)', 1) .. '$',
		SPELL_POWER_DEATH = '^' .. gsub(RUNE_COST_CHROMATIC, '%%d', '([.,%%d]+)', 1) .. '$',
		SPELL_POWER_FROST = '^' .. gsub(RUNE_COST_FROST, '%%d', '([.,%%d]+)', 1) .. '$',
		SPELL_POWER_UNHOLY = '^' .. gsub(RUNE_COST_UNHOLY, '%%d', '([.,%%d]+)', 1) .. '$',
		SPELL_POWER_RUNIC_POWER = '^' .. gsub(RUNIC_POWER_COST, '%%d', '([.,%%d]+)', 1) .. '$',
		SPELL_POWER_SHADOW_ORBS = '^' .. gsub(SHADOW_ORBS_COST, '%%d', '([.,%%d]+)', 1) .. '$',
		SPELL_POWER_SOUL_SHARDS = '^' .. gsub(SOUL_SHARDS_COST, '%%d', '([.,%%d]+)', 1) .. '$',
		SPELL_POWER_ARCANE_CHARGES = '^' .. gsub(ARCANE_CHARGES_COST, '%%d', '([.,%%d]+)', 1) .. '$',
		SPELL_POWER_BALANCE_NEGATIVE_ENERGY = '^' .. gsub(BALANCE_NEGATIVE_ENERGY_COST, '%%d', '([.,%%d]+)', 1) .. '$',
		SPELL_POWER_BURNING_EMBERS = '^' .. gsub(BURNING_EMBERS_COST, '%%d', '([.,%%d]+)', 1) .. '$',
		SPELL_POWER_DARK_FORCE = '^' .. gsub(DARK_FORCE_COST, '%%d', '([.,%%d]+)', 1) .. '$',
		SPELL_POWER_COMBO_POINTS = '^' .. gsub(COMBO_POINTS_COST, '%%d', '([.,%%d]+)', 1) .. '$',
		SPELL_POWER_INSANITY = '^' .. gsub(INSANITY_COST, '%%d', '([.,%%d]+)', 1) .. '$',
		SPELL_POWER_LUNAR_POWER = '^' .. gsub(LUNAR_POWER_COST, '%%d', '([.,%%d]+)', 1) .. '$',
		SPELL_POWER_MAELSTROM = '^' .. gsub(MAELSTROM_COST, '%%d', '([.,%%d]+)', 1) .. '$',
		SPELL_POWER_PAIN = '^' .. gsub(PAIN_COST, '%%d', '([.,%%d]+)', 1) .. '$',
		
    }

    CostTip:SetOwner(WorldFrame, 'ANCHOR_NONE');
    CostTip:SetSpellByID(spellId);

    -- get the line out of the tooltip
    local costText = CostText:GetText();

    -- get the pattern for the player's current power type
    local powerPattern = PowerPatterns[UnitPowerType('player')];

    if (not powerPattern or not costText) then
        return;
    end

    -- check the pattern against the line to see if it matches
    local cost = powerPattern and costText and strmatch(costText, powerPattern);

    -- strip delimiter and convert to number
    if (cost) then
        cost = gsub(cost, '%D', '') + 0;
    end

    return cost;
end


--------------------
-- EVENT HANDLING --
--------------------
function Watcher:PLAYER_REGEN_DISABLED()
    self:ShowHidePriorityFrame(true);
end

function Watcher:PLAYER_REGEN_ENABLED()
    self:ShowHidePriorityFrame(false);
end

function Watcher:PLAYER_TALENT_UPDATE()
    self:ScanReplacedSpells();
    LibSpellbook:ScanSpellbooks();
    self:SetupPriorityFrame();
    self:EvaluatePriorityListFilters();
end

function Watcher:PLAYER_EQUIPMENT_CHANGED()
    self:EvaluatePriorityListFilters();
    self:SetupPriorityFrame();
end


------------
-- SPELLS --
------------
function Watcher:AddNewSpell(spellId)
    if (spellId and tonumber(spellId) and (spellId > 0) and (not IsPassiveSpell(spellId))) then
        if (not (self.db.char.spells[spellId] and (table.getn(self.db.char.spells[spellId].filterSetIds) > 0))) then
            self.db.char.spells[spellId] = {
                settings = {
                    label = "",
                    dropdownLabel = "",
                    keepEnoughResources = false,
                },
                filterSetIds = {},
            };

            -- add default condition
            self:AddNewFilterSet(L["Usable"], spellId);

            self.configurationSelections.spellId = spellId;
        end
    end
end

function Watcher:GetSpellDropdownLabel(spellId)
    local dropdownLabel = self.db.char.spells[spellId].settings.dropdownLabel;
    local spellName = GetSpellInfo(spellId); -- first return is name

    -- if don't have the spellName, it's probably a talent
    if (not spellName) then
        spellName = self:GetTalentNameById(spellId);

        -- not a talent? just give them the spellID
        if (not spellName) then
            spellName = ""..spellId;
        end
    end

    local name = "";

    if (dropdownLabel and dropdownLabel ~= "") then
        name = spellName.." ("..dropdownLabel..")";
    else
        name = spellName;
    end

    return name;
end

function Watcher:GetSpellList()
    local spellList = {};

    -- get all of the spells names
    for k, v in pairs(self.db.char.spells) do
        if (tonumber(k)) then
            local spellName = self:GetSpellDropdownLabel(k)
			if(spellName) then
				spellList[k] = spellName
			end
		end
    end

    return spellList;
end

function Watcher:GetSpellIdFromName(name)
    local spellIds = LibSpellbook:GetAllIds(name);
    local spellId;
    
    -- go through the list of spellIds and choose the one that we know
    if (spellIds and (not spellIds == {})) then
        for potentialSpellId, _ in pairs(spellIds) do
            if (LibSpellbook:IsKnown(potentialSpellId) and not Watcher.replacedSpellsCache[potentialSpellId]) then
                spellId = potentialSpellId;
                break;
            end
        end
    end
	-- if that failed, check pvp talents
	if (not spellId) then
    local specId = GetSpecializationInfo(GetSpecialization());
	spellId = LibPvpTalents:GetTalentFromName(specId, name)
	end
    -- if that failed, fall back to grabbing a spell link
    if (not spellId) then
        local spellLink = GetSpellLink(name);
        if (#spellLink ~= 0) then
            local i, j = string.find(spellLink, "spell:(%d+)");
            spellId = tonumber(string.sub(spellLink, i+6, j));
        end
    end
    
    return spellId
end

function Watcher:RemoveSpell(spellId)
    if (spellId and self.db.char.spells[spellId]) then
        -- remove all of the filters sets associated
        for k, v in pairs(self.db.char.spells[spellId].filterSetIds) do
            self:RemoveFilterSet(k);
        end

        self.db.char.spells[spellId].settings = nil;
        self.db.char.spells[spellId].filterSetIds = nil;
        self.db.char.spells[spellId] = nil;

        if (spellId == self.configurationSelections.spellId) then
            self.configurationSelections.spellId = next(self.db.char.spells);
        end

        for priorityListID, priorityList in pairs(self.db.char.priorityLists) do
            for i, spellCondition in ipairs(self.db.char.priorityLists[priorityListID].spellConditions) do
                if (spellCondition.spellId == spellId) then
                    table.remove(self.db.char.priorityLists[priorityListID].spellConditions, i);
                    self:InjectPriorityOptions();
                end
            end
        end

        LibStub("AceConfigRegistry-3.0"):NotifyChange("Watcher");
    end
end


-------------------
-- SPELL FILTERS --
-------------------
function Watcher:AddNewFilterSet(name, spellId)
    if (name and (name ~= "") and spellId and (spellId > 0) and (self.db.char.spells[spellId])) then
        -- valid input

        -- make new id and set it to the spell
        local newId = table.getn(self.db.char.filterSets) + 1;
        self.db.char.spells[spellId].filterSetIds[newId] = true;

        self.db.char.filterSets[newId]= {};
        self.db.char.filterSets[newId].name = name;
        self.db.char.filterSets[newId].spellId = spellId;
        self.db.char.filterSets[newId].settings = {};
        self.db.char.filterSets[newId].filters = {};

        Watcher:AddFilter("usability", newId);

        self.configurationSelections.filterSetId = newId;
        self:InjectFilterOptions();
    end
end

function Watcher:GetFilterSets(spellId)
    local conditionList = {};

    if (self.db.char.spells[spellId]) then
        -- get all of the filterSets attached to spellId and their names
        for k, v in pairs(self.db.char.spells[spellId].filterSetIds) do
            conditionList[k] = self.db.char.filterSets[k].name;
        end
    end

    return conditionList;
end

function Watcher:RemoveFilterSet(filterSetId)
    if (filterSetId and (self.db.char.filterSets[filterSetId])) then
        local spellId = self.db.char.filterSets[filterSetId].spellId;
        self.db.char.spells[spellId].filterSetIds[filterSetId] = nil;
        self.db.char.filterSets[filterSetId] = nil;

        if (self.configurationSelections.filterSetId == filterSetId) then
            self.configurationSelections.filterSetId = next(self.db.char.spells[spellId].filterSetIds);
        end

        for priorityListID, priorityList in pairs(self.db.char.priorityLists) do
            for i, spellCondition in ipairs(self.db.char.priorityLists[priorityListID].spellConditions) do
                if (spellCondition.filterSetId == filterSetId) then
                    table.remove(self.db.char.priorityLists[priorityListID].spellConditions, i);
                    self:InjectPriorityOptions();
                end
            end
        end

        self:InjectFilterOptions();
    end
end

function Watcher:AddFilter(filterType, filterSetId)
    local conditionFilterDefaults = {
        ["usability"] = {
            ignore = false,
        },
        ["auras"] = {
            auraType = "HARMFUL";
            unit = "target";
            auraName = "",

            trackStacks = false,
            stackRelationship = "At Least",
            stackCount = 0,
            
            trackRemainingTime = false,
            remainingTimeRelationship = "BELOW",
            remainingTime = 0,
            
            playerIsCaster = true,
            ifExists = true,
        },
        ["power"] = {
            threshold = 0,
            relationship = "ABOVE",
        },
        ["secondaryResource"] = {
            resourceType = 0, -- look at http://www.wowwiki.com/PowerType, as well as specific runes and combo points
            relationship = "At Least", -- accepted values 'At Least', 'At Most', 'Equals'
            value = 0,
            optionalBehavior = "",
        },
        ["health"] = {
            threshold = 0,
            relationship = "ABOVE",
            unit = "target",
        },
        ["timeToLive"] = {
            value = 0,
            invert = false,
        },
        ["classification"] = {
            value = "normal", -- look at http://www.wowwiki.com/API_UnitClassification for acceptible values
            relationship = "At Least", -- accepted values 'At Least', 'At Most', 'Equals'
        },
        ["targetAura"] = {
            stealable = false,
            dispellable = false,
            useWhitelist = false,
            whitelist = {},
        },
        ["targetCastingInterruptable"] = {
            useWhitelist = false, -- see http://www.wowwiki.com/API_UnitCastingInfo
            whitelist = {},
        },
        ["aoe"] = {
            activeEnemies = 1,
            relationship = "At Least", -- accepted values 'At Least', 'At Most', 'Equals'
            grouped = false,
        },
        ["totem"] = {
            name = "",
            refreshThreshold = 0,
            exists = true,
        },
        ["talent"] = {
            talentNum = 1, -- see http://www.wowpedia.org/API_GetTalentInfo
            invert = false;
        },
        ["spellCharges"] = {
            relationship = "At Least", -- accepted values 'At Least', 'At Most', 'Equals'
            numCharges = 0,
        },
    };

    if (filterType and conditionFilterDefaults[filterType]) then
        -- make new index
        local i = table.getn(self.db.char.filterSets[filterSetId].filters) + 1;

        self.db.char.filterSets[filterSetId].filters[i] = conditionFilterDefaults[filterType];
        self.db.char.filterSets[filterSetId].filters[i].filterType = filterType;

        Watcher:InjectFilterOptions();
    end
end

function Watcher:GetFilters()
    local filterList = {};

    -- get all of the spells names
    for k, v in pairs(self.spellFilterFunctions) do
        if (k ~= "usability") then
            filterList[k] = L[k];
        end
    end

    return filterList;
end


--------------------
-- PRIORITY LISTS --
--------------------
function Watcher:AddNewPriorityList(name)
    if (name and name ~= "") then
        local priorityListId = (table.getn(self.db.char.priorityLists) or 0) + 1;
        self.db.char.priorityLists[priorityListId] = {};
        self.db.char.priorityLists[priorityListId].name = name;
        self.db.char.priorityLists[priorityListId].filters = {};
        self.db.char.priorityLists[priorityListId].settings = {};
        self.db.char.priorityLists[priorityListId].spellConditions = {};

        local specs = self:GetSpecList();
        for k, v in pairs(specs) do
            if (v == name) then
                -- add spec filter for the spec
                (self:AddNewPriorityListFilter("spec", priorityListId)).specNum = k;
            end
        end

        self:InjectPriorityOptions();
    end
end

function Watcher:AddNewPriorityListFilter(filterType, priorityListId)
    local priorityListFilterDefaults = {
        ["spec"] = {
            specNum = 1, -- see http://www.wowwiki.com/API_GetSpecialization
        },
        ["talent"] = {
            talentNum = 1, -- see http://www.wowpedia.org/API_GetTalentInfo
        },
    };

    if (filterType and priorityListFilterDefaults[filterType]) then
        local filterId = table.getn(self.db.char.priorityLists[priorityListId].filters) + 1;
        self.db.char.priorityLists[priorityListId].filters[filterId] = priorityListFilterDefaults[filterType];
        self.db.char.priorityLists[priorityListId].filters[filterId].filterType = filterType;

        return self.db.char.priorityLists[priorityListId].filters[filterId];
    end
end

function Watcher:AddSpellToPriorityList(spellId, filterSetId, priorityListId)
    if (spellId and filterSetId and priorityListId) then
        local newSpell = {};
        newSpell.spellId = spellId;
        newSpell.filterSetId = filterSetId;

        table.insert(self.db.char.priorityLists[priorityListId].spellConditions, newSpell);

        self:InjectPriorityOptions();
    end
end

function Watcher:SetActivePriorityList(priorityListId)
    self.activePriorityList = priorityListId;
end


--------------------
-- PRETTY PRINT --
--------------------


--[[
   Author: Julio Manuel Fernandez-Diaz
   Date:   January 12, 2007
   (For Lua 5.1)

   Modified slightly by RiciLake to avoid the unnecessary table traversal in tablecount()

   Formats tables with cycles recursively to any depth.
   The output is returned as a string.
   References to other tables are shown as values.
   Self references are indicated.

   The string returned is "Lua code", which can be procesed
   (in the case in which indent is composed by spaces or "--").
   Userdata and function keys and values are shown as strings,
   which logically are exactly not equivalent to the original code.

   This routine can serve for pretty formating tables with
   proper indentations, apart from printing them:

      print(table.show(t, "t"))   -- a typical use

   Heavily based on "Saving tables with cycles", PIL2, p. 113.

   Arguments:
      t is the table.
      name is the name of the table (optional)
      indent is a first indentation (optional).
--]]
function table.show(t, name, indent)
   local cart     -- a container
   local autoref  -- for self references

   --[[ counts the number of elements in a table
   local function tablecount(t)
      local n = 0
      for _, _ in pairs(t) do n = n+1 end
      return n
   end
   ]]
   -- (RiciLake) returns true if the table is empty
   local function isemptytable(t) return next(t) == nil end

   local function basicSerialize (o)
      local so = tostring(o)
      if type(o) == "function" then
         local info = debug.getinfo(o, "S")
         -- info.name is nil because o is not a calling level
         if info.what == "C" then
            return string.format("%q", so .. ", C function")
         else
            -- the information is defined through lines
            return string.format("%q", so .. ", defined in (" ..
                info.linedefined .. "-" .. info.lastlinedefined ..
                ")" .. info.source)
         end
      elseif type(o) == "number" or type(o) == "boolean" then
         return so
      else
         return string.format("%q", so)
      end
   end

   local function addtocart (value, name, indent, saved, field)
      indent = indent or ""
      saved = saved or {}
      field = field or name

      cart = cart .. indent .. field

      if type(value) ~= "table" then
         cart = cart .. " = " .. basicSerialize(value) .. ";\n"
      else
         if saved[value] then
            cart = cart .. " = {}; -- " .. saved[value]
                        .. " (self reference)\n"
            autoref = autoref ..  name .. " = " .. saved[value] .. ";\n"
         else
            saved[value] = name
            --if tablecount(value) == 0 then
            if isemptytable(value) then
               cart = cart .. " = {};\n"
            else
               cart = cart .. " = {\n"
               for k, v in pairs(value) do
                  k = basicSerialize(k)
                  local fname = string.format("%s[%s]", name, k)
                  field = string.format("[%s]", k)
                  -- three spaces between levels
                  addtocart(v, fname, indent .. "    ", saved, field)
               end
               cart = cart .. indent .. "};\n"
            end
         end
      end
   end

   name = name or "__unnamed__"
   if type(t) ~= "table" then
      return name .. " = " .. basicSerialize(t)
   end
   cart, autoref = "", ""
   addtocart(t, name, indent)
   return cart .. autoref
end
