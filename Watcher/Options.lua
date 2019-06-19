---------------------
-- SEE LICENSE.TXT --
---------------------

-------------
-- OPTIONS --
-------------
-- TODO: insert licence
if (not Watcher) then
    return;
end


---------------
-- LIBRARIES --
---------------
local L = LibStub("AceLocale-3.0"):GetLocale("Watcher");
local media = LibStub:GetLibrary("LibSharedMedia-3.0");
local LibSpellbook = LibStub:GetLibrary("LibSpellbook-1.0");
local _;


-------------
-- GLOBALS --
-------------
Watcher.configurationSelections = {};
local S = Watcher.configurationSelections;
Watcher.changelog = [[
Update 3.0.8. (BfA 8.1.5)
    - Addon is now up-to-date with BfA 8.1.5
    - Fixed a bug where Chaos Strike and Blade Dance were still on the timeline for Demon Hunters while in metamorphosis (thanks to elidion for this bugfix)
    - Fixed an issue where talents that make a temporary buff permanent cause linked spells to remain on the timeline indefinitely.

Update 3.0.7. (BfA 8.0.1)
    - Spells that have been replaced by other spells will no longer be shown on the timeline
    - fixed a bug that prevented the timeline from updating when switching talents or specs.
    - Fixed a bug causing the totem filter to sometimes fail to recognize placed totems.
    - Removed the totem type option from the totem filter
    - changed the totem name option to totem spell name option in the totem filter
    - Removed the mushroom filter.

Update 3.0.6 (BfA 8.0.1)
    - Added an option to the aura filter that allows tracking when specified aura doesn't exist.
    - fixed a bug that prevented DK runes from properly updating.
    - fixed a bug where Shamans couldn't track mana (both primary and secondary filters tracked maelstrom), Mana is now tracked by Power filter and Maelstrom by secondary resource filter.
    - '/watcher changes' now displays the last changelog once instead of twice.
]]; 
Watcher.message = [[Hello!

I've taken over Watcher from the original author, Micheal (mpstark). The addon has been updated to Battle For Azeroth and will continue to receive support and bugfixes for the foreseeable future.

If you've found a bug, please report it on the project's issue tracker.
https://wow.curseforge.com/projects/shotwatch/issues

Have fun with the addon in BfA!

--Jordy141 (Grimmj-Nagrand)]];


--------------------
-- LOOK UP TABLES --
--------------------
Watcher.relationships = {
    ["At Least"] = L["At Least"],
    ["At Most"] = L["At Most"],
    ["Equals"] = L["Equals"],
}
Watcher.unitClassifications = {
    ["worldboss"] = L["worldboss"],
    ["rareelite"] = L["rareelite"],
    ["elite"] = L["elite"],
    ["rare"] = L["rare"],
    ["normal"] = L["normal"],
    ["trivial"] = L["trivial"],
    ["minus"] = L["minus"],
};
Watcher.unitClassificationsValues = {
    ["worldboss"] = 7,
    ["rareelite"] = 6,
    ["elite"] = 5,
    ["rare"] = 4,
    ["normal"] = 3,
    ["minus"] = 2,
    ["trivial"] = 1,
};
Watcher.resourceTypes = {
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
}
Watcher.textAnchor = {
    ["top"] = "top";
    ["bottom"] = "bottom";
    ["center"] = "center";
};
Watcher.directions = {
	["up"] = "up",
	["down"] = "down",
	["left"] = "left",
    ["right"] = "right",
}
Watcher.fontEffects = {
    ["none"] = L["None"],
	["OUTLINE"] = L["OUTLINE"],
	["THICKOUTLINE"] = L["THICKOUTLINE"],
	--["MONOCHROME"] = L["MONOCHROME"],
};
Watcher.units = {
    ["player"] = "player",
    ["target"] = "target",
    ["pet"] = "pet",
    ["focus"] = "focus",
    ["mouseover"] = "mouseover",
}

--------------------
-- OPTIONS TABLES --
--------------------
Watcher.generalOptions = {
    name = "Watcher",
    handler = Watcher,
    type = 'group',
    args = {
        general = {
            type = 'group',
            name = L["General"],
            order = 1,
            inline = true,
            args = {
                enable = {
                    type = 'toggle',
                    name = L["Enable"],
                    desc = L["help_enable"],
                    get = "IsEnabled",
                    set = function(_, newValue) if (not newValue) then Watcher:Disable(); else Watcher:Enable(); end end,
                    order = 1,
                },
                disable = { --TODO: check up on
                    type = 'toggle',
                    name = L["Disable"],
                    desc = L["help_enable"],
                    get = "IsEnabled",
                    set = function(_, newValue) if newValue then Watcher:Disable(); else Watcher:Enable(); end end,
                    guiHidden = true,
                    order = 1,
                },
                move = {
                    type = 'toggle',
                    name = L["Move Frames"],
                    desc = L["help_move"],
                    get = function() return Watcher.db.char.unlocked; end,
                    set = function(_, newValue) Watcher.db.char.unlocked = newValue; Watcher:SetupPriorityFrame(); end,
                    order = 2,
                },
                reset = {
                    type = 'execute',
                    name = L["Reset"],
                    desc = L["help_reset"],
                    confirm = true,
					confirmText = L["reset_ask_confirm"],
                    func = "Reset",
                    order = 3,
                },
				issue_tracker = {
					type = 'execute',
					name = L["issue_tracker"],
					desc = L["issue_tracker_desc"],
					confirm = false,
					func = "LaunchTracker",
					order = 4,
				}
--~                 export = {
--~                     type = 'execute',
--~                     name = L["Export"],
--~                     desc = L["help_export"],
--~                     confirm = false,
--~                     func = "Export",
--~                     order = 5,
--~                 },
            },
        },
        messageGroup = {
            type = 'group',
            name = L["Author's Message"],
            order = 5,
            cmdHidden = true,
            inline = true,
            args = {
                message = {
                    type = 'description',
                    name = Watcher.message,
                    fontSize = "medium",
                    width = "full",
                    order = 1,
                },
            }
        },
        changeLogGroup = {
            type = 'group',
            name = L["Changelog (Major)"],
            order = 6,
            cmdHidden = true,
            inline = true,
            args = {
                changelog = {
                    type = 'description',
                    name = Watcher.changelog,
                    fontSize = "medium",
                    width = "full",
                    order = 1,
                },
            }
        },
    },
};
Watcher.displayOptions = {
    name = L["Display Settings"],
    type = 'group',
    handler = Watcher,
    childGroups = 'tab',
    order = 1,
    args = {
        general = {
            type = 'group',
            name = L["General"],
            order = 1,
            args = {
                displayType = {
                    type = 'select',
                    name = L["Display Type"],
                    desc = L["help_display_type"],
                    disabled = true,
                    get = function() return 1; end, -- TODO: implement
                    set = function(_, newValue) end,
                    values = {"Timeline"},
                    order = 1,
                },
                direction = {
                    type = 'select',
                    name = L["Direction"],
                    desc = L["help_dir"],
                    get = function() return Watcher.db.char.growDir; end,
                    set = function(_, newValue) Watcher.db.char.growDir = newValue; Watcher:SetupPriorityFrame(); end,
                    values = Watcher.directions,
                    order = 2,
                },
                visiblity = {
                    type = 'group',
                    name = L["Visibility"];
                    inline = true,
                    order = 4,
                    args = {
                        combat = {
                            type = 'toggle',
                            name = L["Show only in combat"],
                            get = function() return Watcher.db.char.showOnlyInCombat; end,
                            set = function(_, newValue) Watcher.db.char.showOnlyInCombat = newValue; Watcher:ShowHidePriorityFrame(); end,
                            order = 1,
                        },
                        target = {
                            type = 'toggle',
                            name = L["Show only if target exists"],
                            get = function() return Watcher.db.char.showOnlyOnAttackableTarget; end,
                            set = function(_, newValue) Watcher.db.char.showOnlyOnAttackableTarget = newValue; Watcher:ShowHidePriorityFrame(); end,
                            order = 2,
                        },
                        solo = {
                            type = 'toggle',
                            name = L["Show while solo"],
                            get = function() return Watcher.db.char.showWhileSolo; end,
                            set = function(_, newValue) Watcher.db.char.showWhileSolo = newValue; Watcher:ShowHidePriorityFrame(); end,
                            order = 3,
                        },
                        party = {
                            type = 'toggle',
                            name = L["Show in party"],
                            get = function() return Watcher.db.char.showInParty; end,
                            set = function(_, newValue) Watcher.db.char.showInParty = newValue; Watcher:ShowHidePriorityFrame(); end,
                            order = 4,
                        },
                        raid = {
                            type = 'toggle',
                            name = L["Show in raid"],
                            get = function() return Watcher.db.char.showInRaid; end,
                            set = function(_, newValue) Watcher.db.char.showInRaid = newValue; Watcher:ShowHidePriorityFrame(); end,
                            order = 5,
                        },
                        pvp = {
                            type = 'toggle',
                            name = L["Show in PVP"],
                            get = function() return Watcher.db.char.showWhilePVP; end,
                            set = function(_, newValue) Watcher.db.char.showWhilePVP = newValue; Watcher:ShowHidePriorityFrame(); end,
                            order = 6,
                        },
                    },
                },
                sizing = {
                    type = 'group',
                    name = L["Sizing"];
                    inline = true,
                    order = 5,
                    args = {
                        scale = {
                            type = 'range',
                            name = L["Scale"],
                            desc = L["help_scale"],
                            min = 0.25,
                            max = 3.00,
                            step = 0.05,
                            get = function() return Watcher.db.char.scale; end,
                            set = function(_, newValue) Watcher.db.char.scale = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 1,
                        },
                        iconSize = {
                            type = 'range',
                            name = L["Icon Size"],
                            desc = L["help_size"],
                            min = 10,
                            max = 75,
                            step = 5,
                            get = function() return Watcher.db.char.iconSize; end,
                            set = function(_, newValue) Watcher.db.char.iconSize = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 2,
                        },
                    },
                },
                alpha = {
                    type = 'group',
                    name = L["Alpha"];
                    inline = true,
                    order = 6,
                    args = {
                        iconAlpha = {
                            type = 'range',
                            name = L["Icon Alpha"],
                            desc = L["help_alpha"],
                            min = 0,
                            max = 1,
                            step = 0.05,
                            get = function() return Watcher.db.char.iconAlpha end;
                            set = function(_, newValue) Watcher.db.char.iconAlpha = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 1,
                        },
                        backgroundAlpha = {
                            type = 'range',
                            name = L["Background Alpha"],
                            desc = L["help_balpha"],
                            min = 0,
                            max = 1,
                            step = 0.05,
                            get = function() return Watcher.db.char.backgroundAlpha end;
                            set = function(_, newValue) Watcher.db.char.backgroundAlpha = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 2,
                        },
                    },
                },
            }
        },
        text = {
            name = L["Text Settings"],
            type = 'group',
            order = 2,
            args = {
                visibility = {
                    name = L["Visibility"],
                    type = 'group',
                    order = 1,
                    inline = true,
                    args = {
                        cooldownText = {
                            type = 'toggle',
                            name = L["Show CD Text"],
                            disabled = true,
                            get = function() return Watcher.db.char.showCooldownText; end,
                            set = function(_, newValue) Watcher.db.char.showCooldownText = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 1,
                        },
                        labelText = {
                            type = 'toggle',
                            name = L["Show Labels"],
                            get = function() return Watcher.db.char.showLabel; end,
                            set = function(_, newValue) Watcher.db.char.showLabel = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 2,
                        },
                    },
                },
                display = {
                    name = L["Text Display"],
                    type = 'group',
                    order = 2,
                    inline = true,
                    args = {
                        font = {
                            type = 'select',
                            name = L["Font"],
                            get = function() return Watcher.db.char.iconFont; end,
                            set = function(_, newValue) Watcher.db.char.iconFont = newValue; Watcher:SetupPriorityFrame(); end,
                            values = "GetFontList",
                            order = 1,
                        },
                        effect = {
                            type = 'select',
                            name = L["Font Effect"],
                            get = function() return Watcher.db.char.iconFontEffect; end,
                            set = function(_, newValue) Watcher.db.char.iconFontEffect = newValue; Watcher:SetupPriorityFrame(); end,
                            values = Watcher.fontEffects,
                            order = 2,
                        },
                        textsize = {
                            type = 'range',
                            name = L["Font Size"],
                            min = 6,
                            max = 36,
                            step = 1,
                            get = function() return Watcher.db.char.iconFontSize; end,
                            set = function(_, newValue) Watcher.db.char.iconFontSize = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 3,
                        },
                        labelColor = {
                            type = 'color',
                            name = L["Label Color"],
                            hasAlpha = true;
                            get = function() return Watcher.db.char.labelColor.r, Watcher.db.char.labelColor.g, Watcher.db.char.labelColor.b, Watcher.db.char.labelColor.a; end,
                            set = function(_, r, g, b, a) Watcher.db.char.labelColor.r = r; Watcher.db.char.labelColor.g = g; Watcher.db.char.labelColor.b = b; Watcher.db.char.labelColor.a = a; Watcher:SetupPriorityFrame(); end,
                            order = 4,
                        },
                    },
                },
                position = {
                    name = L["Position"],
                    type = 'group',
                    order = 4,
                    inline = true,
                    args = {
                        textAnchor = {
                            type = 'select',
                            name = L["Text Anchor"],
                            desc = L["help_text_anchor"],
                            get = function() return Watcher.db.char.textAnchor; end,
                            set = function(_, newValue) Watcher.db.char.textAnchor = newValue; Watcher:SetupPriorityFrame(); end,
                            values = Watcher.textAnchor,
                            order = 1,
                        },
                        labelVertPos = {
                            type = 'range',
                            name = L["Label Vertical Position"],
                            min = -60,
                            max = 60,
                            step = 2,
                            get = function() return Watcher.db.char.labelVertPos; end,
                            set = function(_, newValue) Watcher.db.char.labelVertPos = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 2,
                        },
                        labelHoriPos = {
                            type = 'range',
                            name = L["Label Horizontal Position"],
                            min = -60,
                            max = 60,
                            step = 2,
                            get = function() return Watcher.db.char.labelHoriPos; end,
                            set = function(_, newValue) Watcher.db.char.labelHoriPos = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 3,
                        },
                    },
                },
            },
        },
        timeLine = {
            name = L["Timeline Settings"],
            type = 'group',
            disabled = function() end,
            order = 3,
            args = {
                sizing = {
                    type = 'group',
                    name = L["Sizing"];
                    inline = true,
                    order = 2,
                    args = {
                        barSize = {
                            type = 'range',
                            name = L["Time Segment Width"],
                            desc = L["segment_size_help"],
                            min = 10,
                            max = 100,
                            step = 1,
                            get = function() return Watcher.db.char.timeSegmentWidth; end,
                            set = function(_, newValue) Watcher.db.char.timeSegmentWidth = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 1,
                        },
                    },
                },
                display = {
                    type = 'group',
                    name = L["Display"];
                    inline = true,
                    order = 1,
                    args = {
                        orientToGCD = {
                            type = 'toggle',
                            name = L["Orient to GCD"],
                            desc = L["Sets the origin to the GCD, so that times are relative to the GCD."],
                            get = function() return Watcher.db.char.orientToGCD; end,
                            set = function(_, newValue) Watcher.db.char.orientToGCD = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 1,
                        },
                        castsAffectUsability = {
                            type = 'toggle',
                            name = L["Casts Affect Usability"],
                            desc = L["This will cause current casts of the player to 'push back' all other abilities on the timeline."],
                            get = function() return Watcher.db.char.castsAffectUsability; end,
                            set = function(_, newValue) Watcher.db.char.castsAffectUsability = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 2,
                        },
                        showIncrementText = {
                            type = 'toggle',
                            name = L["Show Time Increments"],
                            get = function() return Watcher.db.char.showIncrementText; end,
                            set = function(_, newValue) Watcher.db.char.showIncrementText = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 3,
                        },
                    },
                },
                stacking = {
                    type = 'group',
                    name = L["Stacking"];
                    inline = true,
                    order = 1,
                    args = {
                        maxStackedIcons = {
                            type = 'range',
                            name = L["Max Icon Stack"],
                            desc = L["Sets the maximum number of stacked icons."],
                            min = 2,
                            max = 12,
                            step = 1,
                            get = function() return Watcher.db.char.maxStackedIcons; end,
                            set = function(_, newValue) Watcher.db.char.maxStackedIcons = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 1,
                        },
                        stackHeight = {
                            type = 'range',
                            name = L["Stack Height"],
                            desc = L["Sets the percentage of the icon that is visible when stacked."],
                            min = .1,
                            max = 1,
                            step = .05,
                            get = function() return Watcher.db.char.stackHeight; end,
                            set = function(_, newValue) Watcher.db.char.stackHeight = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 2,
                        },
                    },
                },
                icons = {
                    type = 'group',
                    name = L["Icon Settings"];
                    inline = true,
                    order = 3,
                    args = {
                        desaturateIconsWhenUnusable = {
                            type = 'toggle',
                            name = L["Desaturate Unusable Icons"],
                            desc = L["This will make icons appear grey-scale when they cannot be cast."],
                            get = function() return Watcher.db.char.desaturateIconsWhenUnusable; end,
                            set = function(_, newValue) Watcher.db.char.desaturateIconsWhenUnusable = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 1,
                        },
                        hideIconsWhenRecoveringResources = {
                            type = 'toggle',
                            name = L["Hide Low Power Icons"],
                            desc = L["hideIconsWhenRecoveringResources tooltip"],
                            get = function() return Watcher.db.char.hideIconsWhenRecoveringResources; end,
                            set = function(_, newValue) Watcher.db.char.hideIconsWhenRecoveringResources = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 1,
                        },
                    },
                },
                timeSegments = {
                    type = 'group',
                    name = L["Time Segments"];
                    inline = true,
                    order = 4,
                    args = {
                        addTime = {
                            type = 'input',
                            name = L["Add Time Segment"],
                            desc = L["Add a time segment to the timeline bar (in seconds)."],
                            get = function() return "" end,
                            set = function(_, newValue) if (tonumber(newValue) and (tonumber(newValue) >= 0)) then Watcher:AddTimeSegment(tonumber(newValue)); end end,
                            order = 1,
                        },
                        removeTime = {
                            type = 'input',
                            name = L["Remove Time Segment"],
                            desc = L["Remove a time segment from the timeline bar (in seconds)."],
                            get = function() return "" end,
                            set = function(_, newValue) if (tonumber(newValue) and (tonumber(newValue) >= 0)) then Watcher:RemoveTimeSegment(tonumber(newValue)); end end,
                            order = 2,
                        },
                        resetSegments = {
                            type = 'execute',
                            name = L["Reset Time Segments"],
                            desc = L["Resets the timeline time segments to the default configuration."],
                            func = "ResetTimeSegments";
                            order = 3,
                        },
                    },
                },
            },
        },
    },
};
Watcher.spellOptions = {
    name = L["Spells"],
    type = 'group',
    handler = Watcher,
    order = 1,
    args = {
        spell = {
            type = 'select',
            name = L["Spell"],
            desc = L["The spell to configure."],
            get = function() if (not S.spellId) then S.spellId = next(Watcher.db.char.spells); if (S.spellId) then S.filterSetId = next(Watcher.db.char.spells[S.spellId].filterSetIds); Watcher:InjectFilterOptions(); end end return S.spellId; end,
            set = function(_, newValue) S.spellId = newValue; S.filterSetId = next(Watcher.db.char.spells[S.spellId].filterSetIds); Watcher:InjectFilterOptions(); end,
            values = "GetSpellList",
            order = 1,
        },
        removeSpell = {
            type = 'execute',
            name = L["Delete Spell"],
            desc = L["Delete the currently selected spell"],
            confirm = true,
            confirmText = L["Are you sure that you want to delete this spell?"],
            hidden = function() return (not S.spellId); end;
            disabled = function() return (not S.spellId); end;
            func = function() Watcher:RemoveSpell(S.spellId); end,
            order = 2,
        },
        addSpell = {
            type = 'input',
            name = L["Add New Spell"],
            desc = L["Input a spell name or spellId to add."],
            get = function() return "" end,
            set = function(_, newValue) if (tonumber(newValue)) then Watcher:AddNewSpell(tonumber(newValue)); else Watcher:AddNewSpell(Watcher:GetSpellIdFromName(newValue)); end end,
            order = 3,
        },
        spellOptions = {
            type = 'group',
            name = L["Spell Options"];
            inline = true,
            hidden = function() return (not S.spellId); end;
            order = 4,
            args = {
                dropdownLabel = {
                    type = 'input',
                    name = L["Spell Dropdown Label"],
                    desc = L["The label that will show in the dropdown menu"],
                    get = function() if (not S.spellId) then return ""; end if (not Watcher.db.char.spells[S.spellId].settings.dropdownLabel) then return ""; end return Watcher.db.char.spells[S.spellId].settings.dropdownLabel; end,
                    set = function(_, newValue) Watcher.db.char.spells[S.spellId].settings.dropdownLabel = newValue; end,
                    order = 3,
                },
                keepEnoughResources = {
                    type = 'toggle',
                    name = L["Keep Enough Resources"],
                    desc = L["Keep enough resources to keep this ability on cooldown."],
                    disabled = true,
                    get = function() if (not S.spellId) then return false; end return Watcher.db.char.spells[S.spellId].settings.keepEnoughResources; end,
                    set = function(_, newValue) Watcher.db.char.spells[S.spellId].settings.keepEnoughResources = newValue; end,
                    order = 1,
                },
                keybindLabel = {
                    type = 'input',
                    name = L["Keybind Label"],
                    desc = L["The keybind label that will appear on the spell."],
                    get = function() if (not S.spellId) then return ""; end return Watcher.db.char.spells[S.spellId].settings.label; end,
                    set = function(_, newValue) Watcher.db.char.spells[S.spellId].settings.label = newValue; end,
                    order = 2,
                },
                divider = {
                    type = 'header',
                    name = "",
                    order = 4,
                },
                filterSet = {
                    type = 'select',
                    name = L["Filter Set"],
                    desc = L["The filter set to configure."],
                    get = function() if (not S.spellId) then return; end if (not S.filterSetId and (Watcher.db.char.spells[S.spellId])) then S.filterSetId = next(Watcher.db.char.spells[S.spellId].filterSetIds); Watcher:InjectFilterOptions(); end return S.filterSetId; end,
                    set = function(_, newValue) S.filterSetId = newValue; Watcher:InjectFilterOptions(); end,
                    values = function() return Watcher:GetFilterSets(S.spellId); end,
                    order = 5,
                },
                renameFilterSet = {
                    type = 'execute',
                    name = L["Rename"],
                    desc = L["Rename the currently selected filter set."],
                    width = "half",
                    disabled = function() return ((not S.filterSetId) or Watcher.db.char.filterSets[S.filterSetId].name == L["Usable"]); end,
                    hidden = function() return ((not S.filterSetId) or Watcher.db.char.filterSets[S.filterSetId].name == L["Usable"]); end,
                    func = function() Watcher:RenameFilterSet(S.filterSetId); end,
                    order = 6,
                },
                deleteFilterSet = {
                    type = 'execute',
                    name = L["Delete"],
                    desc = L["Delete the currently selected filter set."],
                    width = "half",
                    confirm = true,
                    confirmText = L["Are you sure that you want to delete this filter set?"],
                    disabled = function() return ((not S.filterSetId) or Watcher.db.char.filterSets[S.filterSetId].name == L["Usable"]); end,
                    hidden = function() return ((not S.filterSetId) or Watcher.db.char.filterSets[S.filterSetId].name == L["Usable"]); end,
                    func = function() Watcher:RemoveFilterSet(S.filterSetId); end,
                    order = 7,
                },
                addFilterSet = {
                    type = 'input',
                    name = L["Add New Filter Set"],
                    desc = L["Input a new filter set name."],
                    get = function() return "" end,
                    set = function(_, newValue) Watcher:AddNewFilterSet(newValue, S.spellId); end,
                    order = 8,
                },
                filterSetOptions = {
                    type = 'group',
                    name = L["Filter Set Options"];
                    inline = true,
                    --disabled = function() return ((not S.filterSetId) or Watcher.db.char.filterSets[S.filterSetId].name == L["Usable"]); end,
                    --hidden = function() return ((not S.filterSetId) or Watcher.db.char.filterSets[S.filterSetId].name == L["Usable"]); end,
                    order = 9,
                    args = {
                        bottomFilterDivider = {
                            type = 'header',
                            name = "",
                            order = -3,
                        },
                        selectFilterToAdd = {
                            type = 'select',
                            name = L["Select Filter Type To Add"],
                            disabled = function() return ((not S.filterSetId) or Watcher.db.char.filterSets[S.filterSetId].name == L["Usable"]); end,
                            hidden = function() return ((not S.filterSetId) or Watcher.db.char.filterSets[S.filterSetId].name == L["Usable"]); end,
                            get = function() if (not S.filterType) then S.filterType = next(Watcher:GetFilters()); end return S.filterType; end,
                            set = function(_, newValue) S.filterType = newValue; end,
                            values = "GetFilters",
                            width = "double",
                            order = -2,
                        },
                        addNewFilter = {
                            type = 'execute',
                            name = L["Add New Filter"],
                            disabled = function() return ((not S.filterSetId) or Watcher.db.char.filterSets[S.filterSetId].name == L["Usable"]); end,
                            hidden = function() return ((not S.filterSetId) or Watcher.db.char.filterSets[S.filterSetId].name == L["Usable"]); end,
                            desc = L["Adds a new filter to this filter set."],
                            func = function() if (not S.filterType or not S.filterSetId) then return; end Watcher:AddFilter(S.filterType, S.filterSetId); end,
                            order = -1,
                        },
                    },
                },
            },
        },
    },
};
Watcher.priorityOptions = {
    name = L["Priority Lists"],
    type = "group",
    handler = Watcher,
    childGroups = "select",
    order = 1,
    args = {

    },
};
Watcher.debugOptions = {
    name = L["Debug"],
    type = 'group',
    handler = Watcher,
	order = 1,
	args = {
		ExportList= {
            type = 'input',
            name = L["Debug"],
            desc = L["Export used to maintain the addon"],
            get = "ExportL",
			multiline=30,
			width  = "full",
            order = 1,
        },
    },
};


----------------------
-- OPTION FUNCTIONS --
----------------------
function Watcher:ExportL()
    local className = select(2, UnitClass('player'));

    local header = string.format(
[[------------
-- %s --
------------
if (not Watcher) then
    return;
end

if (select(2, UnitClass('player')) ~= "%s") then
    return;
end


]], className, className);
    
	local profile = {};
	for k,v in pairs(WatcherDB.char) do
		profile = v;
	end

	local defaultValues = {};
	defaultValues.priorityLists = profile.priorityLists;
	defaultValues.filterSets = profile.filterSets;
	defaultValues.spells = profile.spells;
	defaultValues.newDefaultDate = time();
	defaultValues.version = Watcher.apiVersion;
	return table.show(defaultValues,header.."Watcher.classDefaults[\""..className.."\"]");
end

function Watcher:RegisterOptions()
		local AceConfigDialog = LibStub("AceConfigDialog-3.0")

		LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Watcher", self.generalOptions);
        self.optionsFrame = AceConfigDialog:AddToBlizOptions("Watcher", "Watcher");

        LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Watcher Display Settings", self.displayOptions);
		self.optionsFrame["Display_Options"] = AceConfigDialog:AddToBlizOptions("Watcher Display Settings", L["Display Settings"], "Watcher");

        LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Watcher Spell Options", self.spellOptions);
		self.optionsFrame["Spell_Options"] = AceConfigDialog:AddToBlizOptions("Watcher Spell Options", L["Spells"], "Watcher");

        self:InjectPriorityOptions();
        LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Watcher Priority Options", self.priorityOptions);
		self.optionsFrame["Priority_Options"] = AceConfigDialog:AddToBlizOptions("Watcher Priority Options", L["Priority Lists"], "Watcher");

		if (Watcher.showDebugTab) then
			LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Watcher Debug Export", self.debugOptions);
			self.optionsFrame["Debug"] = AceConfigDialog:AddToBlizOptions("Watcher Debug Export", L["Debug"], "Watcher");
		end

end

function Watcher:InjectFilterOptions()
    -- clear the old stuff out of the menu
    for k, v in pairs(self.spellOptions.args.spellOptions.args.filterSetOptions.args) do
        if (string.find(k, "^filter")) then
            self.spellOptions.args.spellOptions.args.filterSetOptions.args[k] = nil;
        end
    end

    if (S.filterSetId) then
        for filterId, value in pairs(self.db.char.filterSets[S.filterSetId].filters) do
            self.spellOptions.args.spellOptions.args.filterSetOptions.args["filterBegin"..filterId] = {
                type = 'header',
                name = L[self.db.char.filterSets[S.filterSetId].filters[filterId].filterType],
                order = (2*(filterId - 1)) + 3,
            };
            self.spellOptions.args.spellOptions.args.filterSetOptions.args["filter"..filterId] = self:GetFilterOptions(S.filterSetId, filterId);
        end
    end

    LibStub("AceConfigRegistry-3.0"):NotifyChange("Watcher Spell Options");
end

function Watcher:GetFilterOptions(filterSetId, filterId)
    local conditionFilterOptions = {
        ["usability"] = {
            ignoreUsability = {
                name = L["Ignore Usability"],
                desc = L["Enable if you want the filter to ignore usability (not enough mana, don't have skill, etc)."],
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].ignore; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].ignore = newValue; end,
                order = 1,
            }
        },
        ["auras"] = {
            auraType = {
                type = 'select',
                name = L["Aura Type"],
                desc = L["Whether the aura is a buff or debuff."],
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].auraType; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].auraType = newValue; end,
                values = {["HELPFUL"] = L["Buff"], ["HARMFUL"] = L["Debuff"]},
                order = 1,
            },
            unit = {
                type = 'select',
                name = L["Unit"],
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].unit; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].unit = newValue; end,
                values = self.units,
                order = 2,
            },
            auraName = {
                type = 'input',
                name = L["Aura Name"],
                desc = L["The name of the buff or debuff."],
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].auraName; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].auraName = newValue; end,
                order = 3,
            },
            trackStacks = {
                name = L["Track Stacks"],
                desc = L["Enable if you want the filter to check the number of stacks."],
                disabled = function() return (not self.db.char.filterSets[filterSetId].filters[filterId].ifExists); end,
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].trackStacks; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].trackStacks = newValue; end,
                order = 4,
            },
            stackRelationship = {
                type = 'select',
                name = "",
                desc = L["At least will allow anything higher; at most anything lower."],
                disabled = function() return (not self.db.char.filterSets[filterSetId].filters[filterId].ifExists or not self.db.char.filterSets[filterSetId].filters[filterId].trackStacks); end,
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].stackRelationship; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].stackRelationship = newValue; end,
                values = self.relationships,
                order = 5,
            },
            stackCount = {
                type = 'range',
                name = L["Stack Count"],
                desc = L["The number of stacks to check for."],
                disabled = function() return (not self.db.char.filterSets[filterSetId].filters[filterId].ifExists or not self.db.char.filterSets[filterSetId].filters[filterId].trackStacks); end,
                min = 0,
                max = 20,
                step = 1,
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].stackCount; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].stackCount = newValue; end,
                order = 6,
            },
            trackRemainingTime = {
                name = L["Track Remaining Time"],
                desc = L["Enable if you want the filter to check the time remaining on the aura. If checking if the aura doesn't exist as well as checking for some time below, it will pass the filter if the buff exists but is below the set point."],
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].trackRemainingTime; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].trackRemainingTime = newValue; end,
                order = 7,
            },
            remainingTimeRelationship = {
                type = 'select',
                name = "",
                disabled = function() return (not self.db.char.filterSets[filterSetId].filters[filterId].trackRemainingTime); end,
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].remainingTimeRelationship; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].remainingTimeRelationship = newValue; end,
                values = {["ABOVE"] = L["When Above"], ["BELOW"] = L["When Below"],},
                order = 8,
            },
            remainingTime = {
                type = 'range',
                name = L["Remaining Time"],
                desc = L["The remaining time to check for in seconds."],
                disabled = function() return (not self.db.char.filterSets[filterSetId].filters[filterId].trackRemainingTime); end,
                min = 0,
                max = 60,
                step = 1,
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].remainingTime; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].remainingTime = newValue; end,
                order = 9,
            },
            ifExists = {
                name = L["Aura Existence"],
                desc = "",
                type = 'select',
                get = function()
					if (self.db.char.filterSets[filterSetId].filters[filterId].ifExists) then
						return "TRUE"; 
					else
						return "FALSE";
					end
				end,
                set = function(_, newValue) 
					if(newValue == "TRUE") then
						self.db.char.filterSets[filterSetId].filters[filterId].ifExists = true; 
					else
						self.db.char.filterSets[filterSetId].filters[filterId].ifExists = false;
					end
				end,
				values = {["TRUE"] = L["Aura Exists"], ["FALSE"] = L["Aura Does Not Exist"]},
                order = 10,
            },
            playerIsCaster = {
                name = L["Player Is Caster"],
                desc = L["If enabled, the player must be the caster of the aura."],
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].playerIsCaster; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].playerIsCaster = newValue; end,
                order = 11,
            },
        },
        ["power"] = {
            relationship = {
                type = 'select',
                name = "",
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].relationship; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].relationship = newValue; end,
                values = {["ABOVE"] = L["When Above"], ["BELOW"] = L["When Below"],},
                order = 1,
            },
            threshold = {
                type = 'range',
                name = L["Percent"],
                desc = L["Percent to trigger at."],
                min = 0,
                max = 100,
                step = 1,
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].threshold; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].threshold = newValue; end,
                order = 2,
            },
        },
        ["secondaryResource"] = {
			resourceType = {
                type = 'select',
                name = L["Resource Type"],
                desc = L["The secondary resource type to use."],
                disabled = "CheckClassSecondaryResource",
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].resourceType; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].resourceType = newValue; self:InjectFilterOptions(); end,
                values = "GetSecondaryResourceList",
                order = 1,
            },
            relationship = {
                type = 'select',
                name = "",
                desc = L["At least will allow anything higher; at most anything lower."],
                disabled = "CheckClassSecondaryResource",
                width = "half",
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].relationship; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].relationship = newValue; end,
                values = self.relationships,
                order = 2,
            },
            value = {
                type = 'range',
                name = "",
                min = -100;
                max = 1000;
                softMin = self:GetSecondaryResourceMin(self.db.char.filterSets[filterSetId].filters[filterId].resourceType),
                softMax = self:GetSecondaryResourceMax(self.db.char.filterSets[filterSetId].filters[filterId].resourceType),
                step = self:GetSecondaryResourceStep(self.db.char.filterSets[filterSetId].filters[filterId].resourceType),
                desc = L["The value of the secondary resource."],
                disabled = "CheckClassSecondaryResource",
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].value; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].value = newValue; end,
                order = 3,
            },
            optionalAnticipationWidget = {
                name = L["Anticipation"],
                desc = L["Enable if you want to take combo points from Anticipation into account"],
                hidden = function() return ((self.db.char.filterSets[filterSetId].filters[filterId].resourceType ~= -1) and (select(2, UnitClass('player')) ~= "ROGUE")); end,
                width = "half",
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].optionalBehavior == "ANTICIPATION"; end,
                set = function(_, newValue) if (newValue) then self.db.char.filterSets[filterSetId].filters[filterId].optionalBehavior = "ANTICIPATION"; else self.db.char.filterSets[filterSetId].filters[filterId].optionalBehavior = "" end end,
                order = 4,
            },
            optionalEclipseDirectionWidget = {
                name = L["Eclipse Direction"],
                desc = L["Direction that Eclipse is growing."],
                hidden = function() return self.db.char.filterSets[filterSetId].filters[filterId].resourceType ~= SPELL_POWER_ECLIPSE; end,
                width = "half",
                type = 'select',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].optionalBehavior; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].optionalBehavior = newValue; end,
                values = {["moon"] = L["moon"], ["sun"] = L["sun"], [""] = L["Ignore"],},
                order = 4,
            },
        },
        ["health"] = {
            unit = {
                type = 'select',
                name = L["Unit"],
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].unit; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].unit = newValue; end,
                values = self.units,
                order = 1,
            },
            relationship = {
                type = 'select',
                name = "",
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].relationship; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].relationship = newValue; end,
                values = {["ABOVE"] = L["When Above"], ["BELOW"] = L["When Below"],},
                order = 2,
            },
            threshold = {
                type = 'range',
                name = L["Percent"],
                desc = L["Percent to trigger at."],
                min = 0,
                max = 100,
                step = 1,
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].threshold; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].threshold = newValue; end,
                order = 3,
            },
        },
        ["timeToLive"] = {
            value = {
                type = 'range',
                name = L["Time To Live (seconds)"],
                desc = L["Set the time to live threshold (in seconds), i.e. only cast if target will last x seconds."],
                min = 0,
                max = 120,
                step = 1,
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].value; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].value = newValue; end,
                order = 1,
            },
            invert = {
                name = L["Invert"],
                desc = L["Inverts the time to live threshold. Cast if target will not last x seconds."],
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].invert; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].invert = newValue; end,
                order = 2,
            },
        },
        ["classification"] = {
            relationship = {
                type = 'select',
                name = "",
                desc = L["At least will allow anything higher; at most anything lower."],
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].relationship; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].relationship = newValue; end,
                values = self.relationships,
                order = 1,
            },
            value = {
                type = 'select',
                name = L["Classification"],
                desc = L["The classification of the target to filter on."],
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].value; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].value = newValue; end,
                values = self.unitClassifications,
                order = 2,
            },
        },
        ["targetAura"] = {
            stealable = {
                name = L["Stealable"],
                desc = L["Check if target has stealable buff."],
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].stealable; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].stealable = newValue; end,
                order = 1,
            },
            dispellable = {
                name = L["Dispellable"],
                desc = L["Check if target has dispellable buff/debuff."],
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].dispellable; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].dispellable = newValue; end,
                order = 2,
            },
            useWhitelist = {
                name = L["Use Whitelist"],
                desc = L["Uses the whitelist to select which buffs to steal/interrupt."],
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].useWhitelist; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].useWhitelist = newValue; end,
                order = 4,
            },
            whitelistAdd = {
                type = 'input',
                name = L["Add to Whitelist"],
                desc = L["Enter a enemy buff to add to the whitelist."],
                disabled = function() return (not self.db.char.filterSets[filterSetId].filters[filterId].useWhitelist); end,
                get = function() return ""; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].whitelist[newValue] = newValue; end,
                order = 5,
            },
            whitelistRemove = {
                type = 'select',
                name = L["Remove from Whitelist"],
                desc = L["Select a enemy buff in the whitelist to remove."],
                disabled = function() return (not self.db.char.filterSets[filterSetId].filters[filterId].useWhitelist); end,
                get = function() return ""; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].whitelist[newValue] = nil; end,
                values = function() return self.db.char.filterSets[filterSetId].filters[filterId].whitelist; end,
                order = 6,
            },
        },
        ["targetCastingInterruptable"] = {
            useWhitelist = {
                name = L["Use Whitelist"],
                desc = L["Uses the whitelist to select which spells to interrupt."],
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].useWhitelist; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].useWhitelist = newValue; end,
                order = 1,
            },
            whitelistAdd = {
                type = 'input',
                name = L["Add to Whitelist"],
                desc = L["Enter a spell to add to the interruptable spell whitelist."],
                disabled = function() return (not self.db.char.filterSets[filterSetId].filters[filterId].useWhitelist); end,
                get = function() return ""; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].whitelist[newValue] = newValue; end,
                order = 2,
            },
            whitelistRemove = {
                type = 'select',
                name = L["Remove from Whitelist"],
                desc = L["Select a spell in the whitelist to remove."],
                disabled = function() return (not self.db.char.filterSets[filterSetId].filters[filterId].useWhitelist); end,
                get = function() return ""; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].whitelist[newValue] = nil; end,
                values = function() return self.db.char.filterSets[filterSetId].filters[filterId].whitelist; end,
                order = 3,
            },
        },
        ["aoe"] = {
            relationship = {
                type = 'select',
                name = "",
                desc = L["At least will allow anything higher; at most anything lower."],
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].relationship; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].relationship = newValue; end,
                values = self.relationships,
                order = 1,
            },
            activeEnemies = {
                type = 'range',
                name = L["Number of Active Enemies"],
                desc = L["Set the threshold of active enemies."],
                min = 1,
                max = 20,
                step = 1,
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].activeEnemies; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].activeEnemies = newValue; end,
                order = 2,
            },
            grouped = {
                name = L["Grouped"],
                desc = L["Attempts to only show filter if the active enemies are grouped together. EXPERIMENTAL!"],
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].grouped; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].grouped = newValue; end,
                order = 3,
            },
        },
        ["totem"] = {
            name = {
                type = 'input',
                name = L["Totem Spell Name"],
                desc = L["Enter a name of the totem to look for. Blank if all of that type."],
                disabled = function() local _, class = UnitClass("player"); if not (class == "SHAMAN" or class == "DRUID") then return true; else return false; end end,
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].name; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].name = newValue; end,
                order = 1,
            },
            exists = {
                name = L["Existance"],
                desc = L["Check if the totem or mushroom exists. If unchecked, if it doesn't."],
                type = 'select',
                disabled = function() local _, class = UnitClass("player"); if not (class == "SHAMAN" or class == "DRUID") then return true; else return false; end end,
                values = {['true'] = L["Totem Exists"],['false'] = L["Totem Does Not Exist"]},
                get = function() return tostring(self.db.char.filterSets[filterSetId].filters[filterId].exists); end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].exists = newValue == 'true' and true or false; end,
                order = 2,
            },
            refreshThreshold = {
                type = 'range',
                name = L["Refresh Threshold"],
                desc = L["When the remaining time is less then the refresh threshold, the filter triggers."],
                disabled = function() local _, class = UnitClass("player"); if not (class == "SHAMAN" or class == "DRUID") then return true; else return false; end end,
                min = 0,
                max = 12,
                step = 1,
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].refreshThreshold; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].refreshThreshold = newValue; end,
                order = 3,
            },
        },
        ["talent"] = {
            talentNum = {
                type = 'select',
                name = L["talent"],
                desc = L["Filter is active if you have this talent."],
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].talentNum; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].talentNum = newValue; end,
                values = "GetTalentList",
                order = 1,
            },
            invert = {
                name = L["If Not Selected"],
                desc = L["Enable if you want the filter to trigger when you do not have the talent instead of if you do."],
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].invert; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].invert = newValue; end,
                order = 2,
            }
        },
        ["spellCharges"] = {
            relationship = {
                type = 'select',
                name = "",
                desc = L["At least will allow anything higher; at most anything lower."],
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].relationship; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].relationship = newValue; end,
                values = self.relationships,
                order = 1,
            },
            numCharges = {
                type = 'range',
                name = L["Number of Charges"],
                desc = L["The number of charges to check for on the spell that this filter is on"],
                min = 0,
                max = 10,
                step = 1,
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].numCharges; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].numCharges = newValue; end,
                order = 2,
            },
        },
    };

    local filterOptions = {
        name = "",
        type = 'group',
        handler = Watcher,
        order = (2*(filterId - 1)) + 4,
        args = conditionFilterOptions[self.db.char.filterSets[filterSetId].filters[filterId].filterType],
    };

    filterOptions.args.remove = {
        type = 'execute',
        name = L["Remove Filter"],
        desc = L["Removes this filter from this filter set."],
        confirm = true,
        confirmText = L["Are you sure that you want to delete this filter?"], 
        func = function() self.db.char.filterSets[filterSetId].filters[filterId] = nil; self.spellOptions.args.spellOptions.args.filterSetOptions.args["filter"..filterId] = nil; self:InjectFilterOptions(); end,
        hidden = function() return self.db.char.filterSets[filterSetId].filters[filterId].filterType == "usability"; end;
        width = "full",
        order = 0,
    };

    return filterOptions;
end

function Watcher:InjectPriorityOptions()
    -- clear old
    self.priorityOptions.args = {};

    for i, v in pairs(self.db.char.priorityLists) do
        self.priorityOptions.args["PriorityList"..i] = self:GetPriorityListOptions(i, "PriorityList"..i);
    end

    self:SetupPriorityFrame();
    LibStub("AceConfigRegistry-3.0"):NotifyChange("Watcher Priority Options");
end

function Watcher:GetPriorityListOptions(priorityListId, listName)
    local priorityList = {
        name = self.db.char.priorityLists[priorityListId].name,
        type = "group",
        handler = Watcher,
        childGroups = "tree",
        order = function() if (self.db.char.priorityLists[priorityListId].filters[1] and self.db.char.priorityLists[priorityListId].filters[1].filterType == "spec" and GetSpecialization() and GetSpecialization() == self.db.char.priorityLists[priorityListId].filters[1].specNum) then return 1; end  return 2; end, --TODO: THIS IS A HACK
        args = {
            addSpell = {
                name = L["Add Spell"],
                type = "group",
                handler = Watcher,
                inline = true,
                order = 1,
                args = {
                    spell = {
                        type = 'select',
                        name = L["Spell"],
                        get = function() if (not S.spellId) then S.spellId = next(Watcher.db.char.spells); if (S.spellId) then S.filterSetId = next(Watcher.db.char.spells[S.spellId].filterSetIds); Watcher:InjectFilterOptions(); end end return S.spellId; end,
                        set = function(_, newValue) S.spellId = newValue; S.filterSetId = next(Watcher.db.char.spells[S.spellId].filterSetIds); Watcher:InjectFilterOptions(); end,
                        values = "GetSpellList",
                        order = 1,
                    },
                    filterSet = {
                        type = 'select',
                        name = L["Filter Set"],
                        get = function() if (not S.spellId) then return; end if (not S.filterSetId and (Watcher.db.char.spells[S.spellId])) then S.filterSetId = next(Watcher.db.char.spells[S.spellId].filterSetIds); Watcher:InjectFilterOptions(); end return S.filterSetId; end,
                        set = function(_, newValue) S.filterSetId = newValue; Watcher:InjectFilterOptions(); end,
                        values = function() return Watcher:GetFilterSets(S.spellId); end,
                        order = 2,
                    },
                    add = {
                        type = 'execute',
                        name = L["Add"],
                        func = function() Watcher:AddSpellToPriorityList(S.spellId, S.filterSetId, priorityListId) end,
                        disabled = function() return not (S.spellId and S.filterSetId); end,
                        order = 3,
                    },
                },
            },
        },
    };

    for i, v in ipairs(self.db.char.priorityLists[priorityListId].spellConditions) do
        priorityList.args["spellCondition"..i] = self:GetPriorityListEntryOptions(i, priorityListId, listName);
    end

    return priorityList;
end

function Watcher:GetPriorityListEntryOptions(spellConditionIndex, priorityListId, parentList)
    if (spellConditionIndex) then
        local priorityListEntry = {
            name = function() local name = spellConditionIndex.." - "..self:GetSpellDropdownLabel(self.db.char.priorityLists[priorityListId].spellConditions[spellConditionIndex].spellId); if (self.db.char.filterSets[self.db.char.priorityLists[priorityListId].spellConditions[spellConditionIndex].filterSetId].name ~= L["Usable"]) then name = name.." - "..self.db.char.filterSets[self.db.char.priorityLists[priorityListId].spellConditions[spellConditionIndex].filterSetId].name; end return name; end,
            type = "group",
            handler = Watcher,
            order = 1+spellConditionIndex,
            args = {
                moveUp = {
                    type = 'execute',
                    name = L["Up"],
                    func = function() if (spellConditionIndex ~= 1) then local temp = table.remove(self.db.char.priorityLists[priorityListId].spellConditions, spellConditionIndex); table.insert(self.db.char.priorityLists[priorityListId].spellConditions, spellConditionIndex-1, temp); self:InjectPriorityOptions(); LibStub("AceConfigDialog-3.0"):SelectGroup("Watcher Priority Options", parentList, "spellCondition"..(spellConditionIndex-1)); end end,
                    --width = "half",
                    order = 1,
                },
                moveDown = {
                    type = 'execute',
                    name = L["Down"],
                    func = function() if (spellConditionIndex ~= #self.db.char.priorityLists[priorityListId].spellConditions) then local temp = table.remove(self.db.char.priorityLists[priorityListId].spellConditions, spellConditionIndex); table.insert(self.db.char.priorityLists[priorityListId].spellConditions, spellConditionIndex+1, temp); self:InjectPriorityOptions(); LibStub("AceConfigDialog-3.0"):SelectGroup("Watcher Priority Options", parentList, "spellCondition"..(spellConditionIndex+1)); end end,
                    --width = "half",
                    order = 2,
                },
                removeItem = {
                    type = 'execute',
                    name = L["Remove"],
                    func = function() table.remove(self.db.char.priorityLists[priorityListId].spellConditions, spellConditionIndex); self:InjectPriorityOptions(); end,
                    --width = "half",
                    order = 3,
                },
                edit = {
                    type = 'execute',
                    name = L["Edit"],
                    func = function() S.spellId = self.db.char.priorityLists[priorityListId].spellConditions[spellConditionIndex].spellId; S.filterSetId = self.db.char.priorityLists[priorityListId].spellConditions[spellConditionIndex].filterSetId; self:InjectFilterOptions(); LibStub("AceConfigDialog-3.0"):Open("Watcher Spell Options"); end,
                    --width = "half",
                    order = 4,
                },
                -- messageGroup = {
                    -- type = 'group',
                    -- name = "",
                    -- order = 5,
                    -- inline = true,
                    -- args = {
                        -- message = {
                            -- type = 'description',
                            -- name = spellConditionIndex.."\n\n\n\n\nThere will be a display of the current spell and filter set options here.\n\n\n\n\nJust not yet.\n\n\n\n\n",
                            -- fontSize = "large",
                            -- width = "full",
                            -- order = 1,
                        -- },
                    -- }
                -- },
            },
        };

        return priorityListEntry;
    end
end


-----------
-- POPUP --
-----------

function Watcher:RenameFilterSet(filterSetId)
    StaticPopupDialogs["Watcher Rename Filter Set"] = {
        text = L["Input a new filter set name."],
        button1 = L["Accept"],
        button2 = L["Cancel"],
        
        OnAccept = function (self)
            local text = self.editBox:GetText();
            
            if (text and text ~= "Usable" and text ~= "") then
                Watcher.db.char.filterSets[S.filterSetId].name = text;
                Watcher:InjectFilterOptions();
            end
        end,
        
        OnShow = function (self)
            self.editBox:SetText(Watcher.db.char.filterSets[S.filterSetId].name)
        end,
        
        EditBoxOnTextChanged = function (self, data)
            local text = self:GetText();
            if (text and text ~= "Usable" and text ~= "") then
                self:GetParent().button1:Enable();
            else
                self:GetParent().button1:Disable();
            end
        end,
        
        EditBoxOnEnterPressed = function(self)
            self:GetParent().button1:Click();
        end,
        
        EditBoxOnEscapePressed = function(self)
            self:GetParent().button2:Click();
        end,
        
        timeout = 0,
        hasEditBox = 1,
        whileDead = true,
        preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
    };

    StaticPopup_Show ("Watcher Rename Filter Set");
end