---------------------
-- SEE LICENSE.TXT --
---------------------

--------------------
-- ENGLISH LOCALE --
--------------------
local L = LibStub("AceLocale-3.0"):NewLocale("Watcher", "enUS", true);

if (not L) then
    return;
end

------------
-- Dialog --
------------

L["Yes"] = true;
L["No"] = true;
L["update_defaults"] = "Watcher contains new defaults for your class.\nWould you like to update to them?\n\nThis will undo any changes that you have made.";
L["first_launch"] = "As this is your first time loading Watcher on this character, would you like to open the options panel to configure Watcher?\n\nIf not, you can always open the Watcher configuration panel with '/watcher'!";

-------------------
-- Options Panel --
-------------------

L["None"] = true;
L["OUTLINE"] = true;
L["THICKOUTLINE"] = true;
L["MONOCHROME"] = true;

L["At Least"] = true;
L["At Most"] = true;
L["Equals"] = true;

L["worldboss"] = "World Boss";
L["rareelite"] = "Rare Elite";
L["elite"] = "Elite";
L["rare"] = "Rare";
L["normal"] = "Normal";
L["trivial"] = "Trivial";
L["minus"] = "Minus (Minions or Summons)";

L["magic"] = "Magic";
L["poison"] = "Poison";
L["curse"] = "Curse";
L["disease"] = "Disease";
L["none"] = "Usable (not dispellable)";

L["Resource Type"] = true;
L["Combo Points"] = true;
L["Combo Points (Druid) (Rogue)"] = true;
L["Runes (Death Knight)"] = true;
L["Burning Embers (Warlock)"] = true;
L["Soul Shards (Warlock)"] = true;
L["Holy Power (Paladin)"] = true;
L["Insanity (Priest)"] = true;
L["Astral Power (Druid)"] = true;
L["Chi (Monk)"]	= true;
L["Arcane Charges (Mage)"] = true;
L["Maelstrom (Shaman)"] = true;
L["Fury (Demon Hunter)"] = true;
L["Pain (Demon Hunter)"] = true;
L["Anticipation"] = true;
L["Enable if you want to take combo points from Anticipation into account"] = "Enable if you want to take combo points from Anticipation into account if you have five combo points";
L["Eclipse Direction"] = true;
L["Direction that Eclipse is growing."] = true;
L["moon"] = "=>Lunar";
L["sun"] = "=>Solar";
L["Ignore"] = true;

L["General"] = true;
L["Enable"] = true;
L["Disable"] = true;
L["help_enable"] = "Enable or disable Watcher.";
L["Move Frames"] = true
L["help_move"] = "Unlocks/locks Watcher for repositioning. While unlocked, left click and drag.";
L["Reset"] = true;
L["help_reset"] = "Reset Watcher to its default settings.";
L["reset_ask_confirm"] = "Are you sure you want to Reset Watcher to its default settings?";
L["Author's Message"] = true;
L["Changelog (Major)"] = "Changelog";
L["issue_tracker"] = "Issue Tracker"
L["issue_tracker_desc"] = "Launch the Issue Tracker in the browser."
L["copy_url_instruction"] = "Copy below URL and paste it in your browser."

L["Display Settings"] = true;
L["Display Type"] = true;
L["help_display_type"] = "Sets Watcher's display type to change how it looks.";
L["Direction"] = true;
L["help_dir"] = "Set direction that Watcher grows.";
L["Max Number of Icons"] = true;
L["help_num_icons"] = "Display the maximum amount of icons that Watcher displays.";

L["Visibility"] = true;
L["Show only in combat"] = true;
L["Show only if target exists"] = true;
L["Show in party"] = true;
L["Show in raid"] = true;
L["Show in PVP"] = true;
L["Show while solo"] = true;

L["Sizing"] = true;
L["Scale"] = true;
L["help_scale"] = "Adjusts Watcher's scale.";
L["Icon Size"] = true;
L["help_size"] = "Adjusts the size of Watcher's icons. Also changes the timeline height.";
L["Time Segment Width"] = true;
L["segment_size_help"] = "Adjusts each time segment's width, effectively making the timeline bar longer.";

L["Alpha"] = true;
L["Icon Alpha"] = true;
L["help_alpha"] = "Sets the alpha for all of Watcher's icons.";
L["Background Alpha"] = true;
L["help_balpha"] = "Sets the alpha for the timeline background.";

L["Time Segments"] = true;
L["Add Time Segment"] = true;
L["Add a time segment to the timeline bar (in seconds)."] = true;
L["Remove Time Segment"] = true;
L["Remove a time segment from the timeline bar (in seconds)."] = true;
L["Reset Time Segments"] = true;
L["Resets the timeline time segments to the default configuration."] = true;
L["Show Time Increments"] = true;
L["Display"] = true;
L["Timeline Settings"] = true;
L["Max Icon Stack"] = true;
L["Sets the maximum number of stacked icons."] = true;
L["Stack Height"] = true;
L["Sets the percentage of the icon that is visible when stacked."] = true;

L["Text Settings"] = true;
L["Text Display"] = true;
L["Font"] = true;
L["Font Effect"] = true;
L["Font Size"] = true;
L["Label Color"] = "Keybind Label Color";
L["Show CD Text"] = true;
L["Show Labels"] = "Show Keybind Labels";
L["Position"] = true;
L["Text Anchor"] = "Cooldown Text Anchor";
L["help_text_anchor"] = "Sets where the cooldown text anchors on the icon.";
L["Label Vertical Position"] = "Keybind Label Vertical";
L["Label Horizontal Position"] = "Keybind Label Horizontal";

L["Casts Affect Usability"] = true;
L["This will cause current casts of the player to 'push back' all other abilities on the timeline."] = true;

L["Stacking"] = true;

L["Orient to GCD"] = true;
L["Sets the origin to the GCD, so that times are relative to the GCD."] = true;

L["Icon Settings"] = true;
L["Desaturate Unusable Icons"] = true;
L["This will make icons appear grey-scale when they cannot be cast."] = true;
L["Hide Low Power Icons"] = true;
L["hideIconsWhenRecoveringResources tooltip"] = "This will hide icons when you do not have enough regenerating primary resource (mana/energy/focus) to cast instead of placing them on the timeline with the time until the resource has regenerated enough to cast the spell."

L["Spells"] = true;
L["Spell"] = true;
L["The spell to configure."] = true;
L["Add New Spell"] = true;
L["Input a spell name or spellId to add."] = true;
L["Are you sure that you want to delete this spell?"] = true;

L["Spell Options"] = true;
L["Keep Enough Resources"] = true;
L["Keep enough resources to keep this ability on cooldown."] = "Keep enough resources to keep this ability on cooldown. Amount kept will vary dynamically based on cooldown.\n\nNOTE: This will only work for regenerating primary resources (mana/energy/focus).\n\nWARNING: Will hide other abilities, use with extreme caution.";
L["Keybind Label"] = true;
L["The keybind label that will appear on the spell."] = true;
L["Spell Dropdown Label"] = true;
L["The label that will show in the dropdown menu"] = true;

L["Filter Set"] = "Filter Set (Conditions)";
L["The filter set to configure."] = true;
L["Add New Filter Set"] = true;
L["Rename Filter Set"] = true;
L["Rename"] = true;
L["Delete"] = true;
L["Accept"] = true;
L["Cancel"] = true;
L["Rename the currently selected filter set."] = true;
L["Input a new filter set name."] = true;
L["Filter Set Options"] = "Filter Set (Conditions) Options";
L["Select Filter Type To Add"] = true;
L["Add New Filter"] = true;
L["Filters"] = true;
L["Adds a new filter to this filter set."] = true;
L["Remove Filter"] = true;
L["Removes this filter from this filter set."] = true;
L["Delete Spell"] = true;
L["Delete the currently selected spell"] = true;
L["Delete Filter Set"] = true;
L["Delete the currently selected filter set."] = true;
L["Are you sure that you want to delete this filter set?"] = true;
L["Are you sure that you want to delete this filter?"] = true;

L["usability"] = "Usability and Cooldown";
L["Ignore Usability"] = true;
L["Enable if you want the filter to ignore usability (not enough mana, don't have skill, etc)."] = true;

L["Unit"] = true;
L["auras"] = "Auras (Buffs and Debuffs)";
L["Aura Type"] = true;
L["Buff"] = true;
L["Debuff"] = true;
L["Whether the aura is a buff or debuff."] = true;
L["Track Stacks"] = true;
L["Enable if you want the filter to check the number of stacks."] = true;
L["Aura Name"] = true;
L["The name of the buff or debuff."] = true;
L["Is Player Buff"] = true;
L["The aura is a buff on the player, if not selected, the aura is a debuff on the target."] = true;
L["Player Is Caster"] = true;
L["If enabled, the player must be the caster of the aura."] = true;
L["Stack Count"] = true;
L["The number of stacks to check for."] = true;

L["Track Remaining Time"] = true;
L["Enable if you want the filter to check the time remaining on the aura. If checking if the aura doesn't exist as well as checking for some time below, it will pass the filter if the buff exists but is below the set point."] = true;
L["Remaining Time"] = true;
L["The remaining time to check for in seconds."] = true;

L["Percent"] = true;
L["Percent to trigger at."] = true;
L["power"] = "Power (mana/rage/runic power/etc.)";
L["Invert"] = true;
L["When Below"] = true;
L["When Above"] = true;
L["Aura Existence"] = true;

L["health"] = "Health (target/player)";

L["secondaryResource"] = "Secondary Resource (Runes/Eclipse/Combo Points/etc.)";
L["The value of the secondary resource."] = true;
L["The secondary resource type to use."] = true;
L["Not a number"] = true;
L["Too small"] = true;
L["Too large"] = true;

L["timeToLive"] = "Target Time To Live";
L["Time To Live (seconds)"] = true;
L["Set the time to live threshold (in seconds), i.e. only cast if target will last x seconds."] = true;
L["Invert"] = true;
L["Inverts the time to live threshold. Cast if target will not last x seconds."] = true;

L["classification"] = "Target Classification (elite/boss/etc.)"
L["Classification"] = true;
L["The classification of the target to filter on."] = true;
L["At least will allow anything higher; at most anything lower."] = true;

L["targetAura"] = "Target Aura (stealable/dispellable)";
L["Stealable"] = true;
L["Check if target has stealable buff."] = true;
L["Dispellable"] = true;
L["Check if target has dispellable buff/debuff."] = true;
L["Enter a enemy buff to add to the whitelist."] = true;
L["Uses the whitelist to select which buffs to steal/interrupt."] = true;
L["Select a enemy buff in the whitelist to remove."] = true;

L["targetCastingInterruptable"] = "Target Casting Interruptable Spell";
L["Enter a spell to add to the interruptable spell whitelist."] = true;
L["Use Whitelist"] = true;
L["Remove from Whitelist"] = true;
L["Add to Whitelist"] = true;
L["Select a spell in the whitelist to remove."] = true;
L["Uses the whitelist to select which spells to interrupt."] = true;

L["aoe"] = "AOE";
L["Number of Active Enemies"] = true;
L["Set the threshold of active enemies."] = true;
L["Grouped"] = true;
L["Attempts to only show filter if the active enemies are grouped together. EXPERIMENTAL!"] = true;

L["Refresh Threshold"] = true;
L["When the remaining time is less then the refresh threshold, the filter triggers."] = true;
L["totem"] = "Totem filter";
L["Totem Spell Name"] = true;
L["If Exists"] = true;
L["Does not exist"] = true;
L["If Aura Exists"] = true;
L["If Aura Does Not Exist"] = true;
L["Aura Exists"] = true;
L["Aura Does Not Exist"] = true;
L["Totem Exists"] = true;
L["Totem Does Not Exist"] = true;
L["Existance"] = true;

L["Check if the totem or mushroom exists. If unchecked, if it doesn't."] = true;
L["What type of totem or mushroom to check for."] = true;
L["Name"] = true;
L["Enter a name of the totem to look for. Blank if all of that type."] = true;
L["Type"] = true;
L["Fire"] = true;
L["Earth"] = true;
L["Water"] = true;
L["Air"] = true;
L["Mushroom #1"] = true;
L["Mushroom #2"] = true;
L["Mushroom #3"] = true;

L["spec"] = "Specialization";
L["Filter is active if you are in this spec."] = true;

L["If Not Selected"] = true;
L["talent"] = "Talent";
L["Filter is active if you have this talent."] = true;
L["Enable if you want the filter to trigger when you do not have the talent instead of if you do."] = true;
L["If Not Selected"] = true;

L["glyph"] = "Glyph";
L["Filter is active if you have this glyph equipped."] = true;
L["Glyph of (the).."] = true;
L["Enable if you want the filter to trigger when you do not have the glyph instead of if you do."] = true;

L["spellCharges"] = "Spell Charges";
L["Number of Charges"] = true;
L["The number of charges to check for on the spell that this filter is on"] = true;

L["Priorities"] = true;
L["Add Spell"] = true;
L["Add"] = true;
L["Up"] = true;
L["Down"] = true;
L["Remove"] = true;
L["Edit"] = true;

L["Usable"] = true;
L["Priority Lists"] = true;


L["Export"] = true;
L["help_export"] = "Export Watcher settings.";
L["Debug"] = true;
L["Export used to maintain the addon"] = true;

