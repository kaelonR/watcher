--[[
LibPvpTalents-1.0 - Track the and retrieve info about PVP talents for all specializations.
Copyright (C) 2018-2019 Jordy141 (Grimmj-Nagrand)

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and/or other materials provided with the distribution.
    * Redistribution of a stand alone version is strictly prohibited without
      prior written authorization from the LibSpellbook project manager.
    * Neither the name of the LibSpellbook authors nor the names of its contributors
      may be used to endorse or promote products derived from this software without
      specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

local MAJOR, MINOR = "LibPvpTalents-1.0", 1
assert(LibStub, MAJOR.." requires LibStub")
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

--PVP talents, grouped by specializationId (60+). format: [id] = name
if (not lib.talents) then
	lib.talents = {
		[0] = { --General
			[214027] = "Adaptation";
			[196029] = "Relentless";
			[208683] = "Gladiator's Medallion";
		},
		[62] = { -- Arcane Mage
			[276741] = "Arcane Empowerment";
			[198151] = "Torment the Weak";
			[210476] = "Master of Escape";
			[213220] = "Rewind Time";
			[198158] = "Mass Invisibility";
			[198062] = "Netherwind Armor";
			[198111] = "Temporal Shield";
			[236788] = "Dampened Magic";
			[198100] = "Kleptomania";
			[198064] = "Prismatic Cloak";
		},
		[63] = { -- Fire Mage
			[198062] = "Netherwind Armor";
			[198111] = "Temporal Shield";
			[203275] = "Tinder";
			[203280] = "World in Flames";
			[280450] = "Controlled Burn";
			[203283] = "Firestarter";
			[203284] = "Flamecannon";
			[203286] = "Greater Pyroblast";
			[198064] = "Prismatic Cloak";
			[236788] = "Dampened Magic";
			[198100] = "Kleptomania";
		},
		[64] = { -- Frost Mage
			[236788] = "Dampened Magic";
			[198100] = "Kleptomania";
			[198126] = "Chilled to the Bone";
			[198120] = "Frostbite";
			[198123] = "Deep Shatter";
			[198148] = "Concentrated Coolness";
			[206431] = "Burst of Cold";
			[198144] = "Ice Form";
			[198062] = "Netherwind Armor";
			[198111] = "Temporal Shield";
			[198064] = "Prismatic Cloak";
		},
		[65] = { -- Holy Paladin
			[199424] = "Pure of Heart";
			[199441] = "Avenging Light";
			[199452] = "Ultimate Sacrifice";
			[210378] = "Darkest before the Dawn";
			[199456] = "Spreading the Word";
			[199454] = "Blessed Hands";
			[199324] = "Divine Vision";
			[199330] = "Cleanse the Weak";
			[210294] = "Divine Favor";
			[216327] = "Light's Grace";
			[216868] = "Hallowed Ground";
		},
		[66] = { --Protection Paladin
			[216868] = "Hallowed Ground";
			[199542] = "Steed of Glory";
			[216853] = "Sacred Duty";
			[216860] = "Judgments of the Pure";
			[228049] = "Guardian of the Forgotton Queen";
			[216855] = "Guarded by the Light";
			[207028] = "Inquisition";
			[210341] = "Warrior of Light";
			[215652] = "Shield of Virtue";
			[236186] = "Cleansing Light";
			[199422] = "Holy Ritual";
			[199428] = "Luminescence";
			[199325] = "Unbound Freedom";
		},
		[70] = { --Retribution Paladin
			[199428] = "Luminescence";
			[199325] = "Unbound Freedom";
			[199422] = "Holy Ritual";
			[210323] = "Vengeance Aura";
			[210256] = "Blessing of Sanctuary";
			[204927] = "Seraphim's Blessing";
			[246806] = "Lawbringer";
			[204914] = "Divine Punisher";
			[247675] = "Hammer of Reckoning";
			[204979] = "Jurisdiction";
			[204934] = "Law and Order";
			[236186] = "Cleansing Light";
		},
		[71] = { -- Arms Warrior
			[235941] = "Master and Commander";
			[198807] = "Shadow of the Colossus";
			[236308] = "Storm of Destruction";
			[236320] = "War Banner";
			[198817] = "Sharpen Blade";
			[236273] = "Duel";
			[216890] = "Spell Reflection";
			[198500] = "Death Sentence";
			[236077] = "Disarm";
		},
		[72] = { -- Fury Warrior
			[198500] = "Death Sentence";
			[280745] = "Barbarian";
			[213857] = "Battle Trance";
			[199202] = "Thirst for Battle";
			[198877] = "Enduring Rage";
			[199261] = "Death Wish";
			[216890] = "Spell Reflection";
			[235941] = "Master and Commander";
			[236077] = "Disarm";
			[280747] = "Slaughterhouse";
		},
		[73] = { -- Protection Warrior
			[236077] = "Disarm";
			[199127] = "Sword and Board";
			[213871] = "Bodyguard";
			[199037] = "Leave No Man Behind";
			[199023] = "Morale Killer";
			[198912] = "Shield Bash";
			[199045] = "Thunderstruck";
			[199086] = "Warpath";
			[206572] = "Dragon Charge";
			[213915] = "Mass Spell Reflection";
			[205800] = "Oppressor";
			[253900] = "Ready for Battle";
		},
		[102] = { -- Balance Druid
			[233754] = "Celestial Guardian";
			[200567] = "Crescent Burn";
			[200726] = "Celestial Downpour";
			[233750] = "Moon and Stars";
			[209740] = "Moonkin Aura";
			[232546] = "Dying Stars";
			[233755] = "Deep Roots";
			[209749] = "Faerie Swarm";
			[209753] = "Cyclone";
			[233752] = "Ironfeather Armor";
			[200549] = "Prickling Thorns";
			[209730] = "Protector of the Grove";
			[236696] = "Thorns";
		},
		[103] = { -- Feral Druid
			[236696] = "Thorns";
			[236023] = "Earthen Grasp";
			[213200] = "Freedom of the Herd";
			[236012] = "Malorne's Swiftness";
			[203052] = "King of the Jungle";
			[236026] = "Enraged Maim";
			[236020] = "Ferocious Wound";
			[203224] = "Fresh Wound";
			[203242] = "Rip and Tear";
			[205673] = "Savage Momentum";
			[209730] = "Protector of the Grove";
			[236019] = "Tooth and Claw";
		},
		[104] = { -- Guardian Druid
			[236144] = "Master Shapeshifter";
			[201259] = "Toughness";
			[236180] = "Den Mother";
			[201664] = "Demoralizing Roar";
			[213951] = "Clan Defender";
			[236153] = "Raging Frenzy";
			[202110] = "Sharpened Claws";
			[228431] = "Charging Bash";
			[202226] = "Entangling Claws";
			[202246] = "Overrun";
			[202043] = "Protector of the Pack";
			[207017] = "Alpha Challenge";
			[236147] = "Malorne's Swiftness";
			[236148] = "Roaring Speed";
			[207017] = "Alpha Challenge";
		},
		[105] = { -- Resotration Druid
			[233673] = "Disentanglement";
			[203374] = "Nourish";
			[203399] = "Revitalize";
			[247543] = "Entangling Bark";
			[236696] = "Thorns";
			[233755] = "Deep Roots";
			[203553] = "Focused Growth";
			[200931] = "Encroaching Vines";
			[203651] = "Overgrowth";
			[203624] = "Early Spring";
			[33786] = "Cyclone";
			[209690] = "Druid of the Claw";
		},
		[250] = { -- Blood DK
			[202727] = "Unholy Command";
			[202731] = "Walking Dead";
			[47476] = "Strangulate";
			[233411] = "Blood for Blood";
			[233412] = "Last Dance";
			[203173] = "Death Chain";
			[207018] = "Murderous Intent";
			[51052] = "Anti-Magic Zone";
			[199642] = "Necrotic Aura";
			[199719] = "Heartstop Aura";
			[199720] = "Decomposing Aura";
			[77606] = "Dark Simulacrum";
		},
		[251] = { -- Frost DK
			[199642] = "Necrotic Aura";
			[199720] = "Decomposing Aura";
			[204080] = "Deathchill";
			[233396] = "Delirium";
			[279941] = "Tundra Stalker";
			[204135] = "Frozen Center";
			[233394] = "Overpowered Rune Weapon";
			[204160] = "Chill Streak";
			[51052] = "Anti-Magic Zone";
			[199719] = "Heartstop Aura";
			[77606] = "Dark Simulacrum";
			[201995] = "Cadaverous Pallor";
		},
		[252] = { -- Unholy DK
			[199725] = "Wandering Plague";
			[199724] = "Pandemic";
			[199722] = "Crypt Fever";
			[77606] = "Dark Simulacrum";
			[51052] = "Anti-Magic Zone";
			[199719] = "Heartstop Aura";
			[223829] = "Necrotic Strike";
			[201934] = "Unholy Mutation";
			[210128] = "Reanimation";
			[201995] = "Cadaverous Pallor";
			[199642] = "Necrotic Aura";
			[199720] = "Decomposing Aura";
		},
		[253] = { -- Beast Mastery Hunter
			[212668] = "The Beast Within";
			[204190] = "Wild Protector";
			[208652] = "Dire Beast: Hawk";
			[205691] = "Dire Beast: Basilisk";
			[248518] = "Interlope";
			[202746] = "Survival Tactics";
			[202589] = "Dragonscale Armor";
			[202797] = "Viper Sting";
			[202914] = "Spider Sting";
			[202900] = "Scorpid Sting";
			[236776] = "Hi-Explosive Trap";
			[53480] = "Roar of Sacrifice";
			[203235] = "Hunting Pack";
		},
		[254] = { -- Marksmanship Hunter
			[202589] = "Dragonscale Armor";
			[202746] = "Survival Tactics";
			[202797] = "Viper Sting";
			[202900] = "Scorpid Sting";
			[202914] = "Spider Sting";
			[213691] = "Scatter Shot";
			[236776] = "Hi-Explosive Trap";
			[203129] = "Trueshot Mastery";
			[248443] = "Ranger's Finesse";
			[203155] = "Sniper Shot";
			[53480] = "Roar of Sacrifice";
			[203235] = "Hunting Pack";
		},
		[255] = { -- Survival Hunter
			[203235] = "Hunting Pack";
			[212640] = "Mending Bandage";
			[53480] = "Roar of Sacrifice";
			[203264] = "Sticky Tar";
			[212638] = "Tracker's Net";
			[203340] = "Diamond Ice";
			[236776] = "Hi-Explosive Trap";
			[202746] = "Survival Tactics";
			[202914] = "Spider Sting";
			[202900] = "Scorpid Sting";
			[202589] = "Dragonscale Armor";
			[202797] = "Viper Sting";
		},
		[256] = { --Discipline Priest
			[196162] = "Purification";
			[196439] = "Purified Resolve";
			[214205] = "Trinity";
			[197535] = "Strength of Soul";
			[236499] = "Ultimate Radiance";
			[197590] = "Dome of Light";
			[197862] = "Archangel";
			[197871] = "Dark Archangel";
			[209780] = "Premonition";
			[215768] = "Searing Light";
		},
		[257] = { --Holy Priest
			[213610] = "Holy Ward";
			[221661] = "Holy Concentration";
			[215960] = "Greater Heal";
			[196559] = "Rapid Mending";
			[235587] = "Miracle Worker";
			[196602] = "Divine Attendant";
			[215982] = "Spirit of the Redeemer";
			[197268] = "Ray of Hope";
			[213602] = "Greater Fade";
			[196762] = "Inner Focus";
			[196611] = "Delivered from Evil";
		},
		[258] = { --Shadow Priest
			[280749] = "Void Shield";
			[199131] = "Pure Shadow";
			[199259] = "Driven to Madness";
			[199408] = "Edge of Insanity";
			[199445] = "Mind Trauma";
			[199484] = "Psychic Link";
			[108968] = "Void Shift";
			[228630] = "Void Origins";
			[211522] = "Psyfiend";
			[280750] = "Shadow Mania";
			[280752] = "Hallucinations";
		},
		[259] = { --Assassination Rogue
			[197007] = "Intent to Kill";
			[248744] = "Shiv";
			[198032] = "Honor Among Thieves";
			[197044] = "Deadly Brew";
			[197050] = "Mind-Numbing Poison";
			[198092] = "Creeping Venom";
			[198128] = "Flying Daggers";
			[198145] = "System Shock";
			[206328] = "Neurotoxin";
			[197000] = "Maneuverability";
			[269513] = "Death from Above";
			[212182] = "Smoke Bomb";
		},
		[260] = { --Outlaw Rogue
			[197000] = "Maneuverability";
			[198265] = "Take Your Cut";
			[212217] = "Control is King";
			[212210] = "Drink Up Me Hearties";
			[212035] = "Cheap Tricks";
			[207777] = "Dismantle";
			[198529] = "Plunder Armor";
			[209752] = "Boarding Party";
			[221622] = "Thick as Thieves";
			[198020] = "Turn the Tables";
			[248744] = "Shiv";
			[198032] = "Honor Among Thieves";
			[212182] = "Smoke Bomb";
			[269513] = "Death from Above";
		},
		[261] = { --Subtlety Rogue
			[198952] = "Veil of Midnight";
			[213981] = "Cold Blood";
			[216883] = "Phantom Assassin";
			[212081] = "Thief's Bargain";
			[207736] = "Shadowy Duel";
			[198675] = "Dagger in the Dark";
			[197899] = "Silhouette";
			[212182] = "Smoke Bomb";
			[197000] = "Maneuverability";
			[248744] = "Shiv";
			[198032] = "Honor Among Thieves";
			[269513] = "Death from Above";
		},
		[262] = { --Elemental Shaman
			[204385] = "Elemental Attunement";
			[204393] = "Control of Lava";
			[204398] = "Earthfury";
			[204403] = "Traveling Storms";
			[204437] = "Lightning Lasso";
			[204261] = "Spectral Recovery";
			[204330] = "Skyfury Totem";
			[204331] = "Counterstrike Totem";
			[204247] = "Purifying Waters";
			[204336] = "Grounding Totem";
			[204264] = "Swelling Waves";
		},
		[263] = { --Enhancement Shaman
			[204349] = "Forked Lightning";
			[211062] = "Static Cling";
			[204357] = "Ride the Lightning";
			[193876] = "Shamanism";
			[204366] = "Thundercharge";
			[210918] = "Ethereal Form";
			[204330] = "Skyfury Totem";
			[204331] = "Counterstrike Totem";
			[204247] = "Purifying Waters";
			[204261] = "Spectral Recovery";
			[204336] = "Grounding Totem";
			[204264] = "Swelling Waves";
		},
		[264] = { --Restoration Shaman
			[204330] = "Skyfury Totem";
			[204331] = "Counterstrike Totem";
			[204264] = "Swelling Waves";
			[204268] = "Voodoo Mastery";
			[206642] = "Electrocute";
			[204336] = "Grounding Totem";
			[204269] = "Rippling Waters";
			[204293] = "Spirit Link";
			[204247] = "Purifying Waters";
			[236501] = "Tidebringer";
			[221678] = "Calming Waters";
			[204261] = "Spectral Recovery";
		},
		[265] = { --Affliction Warlock
			[199890] = "Curse of Tongues";
			[199892] = "Curse of Weakness";
			[199954] = "Curse of Fragility";
			[213400] = "Endless Affliction";
			[212356] = "Soulshatter";
			[248855] = "Gateway Mastery";
			[212371] = "Rot and Decay";
			[234877] = "Curse of Shadows";
			[212295] = "Nether Ward";
			[221711] = "Essence Drain";
			[221703] = "Casting Circle";
		},
		[266] = { --Demonology Warlock
			[212623] = "Singe Magic";
			[212619] = "Call Felhunter";
			[212618] = "Pleasure through Pain";
			[212459] = "Call Fel Lord";
			[201996] = "Call Observer";
			[212628] = "Master Summoner";
			[199954] = "Curse of Fragility";
			[199890] = "Curse of Tongues";
			[199892] = "Curse of Weakness";
			[212295] = "Nether Ward";
			[221711] = "Essence Drain";
			[221703] = "Casting Circle";
		},
		[267] = { --Destruction Warlock
			[233577] = "Focused Chaos";
			[200586] = "Fel Fissure";
			[212282] = "Cremation";
			[233581] = "Entrenched in Flame";
			[200546] = "Bane of Havoc";
			[199954] = "Curse of Fragility";
			[199890] = "Curse of Tongues";
			[199892] = "Curse of Weakness";
			[212295] = "Nether Ward";
			[221711] = "Essence Drain";
			[221703] = "Casting Circle";
		},
		[268] = { --Brewmaster monk
			[202107] = "Microbrew";
			[202126] = "Hot Trub";
			[202200] = "Guided Meditation";
			[202162] = "Avert Harm";
			[213658] = "Craft: Nimble Brew";
			[202272] = "Incendiary Breath";
			[202335] = "Double Barrel";
			[202370] = "Mighty Ox Kick";
			[205147] = "Eerie Fermentation";
			[207025] = "Admonishment";
			[232876] = "Niuzao's Essence";
			[201201] = "Fast Feet";
		},
		[269] = { --Windwalker Monk
			[201318] = "Fortifying Brew";
			[201372] = "Ride the Wind";
			[247483] = "Tigereye Brew";
			[233765] = "Control the Mists";
			[232879] = "Yu'lon's Gift";
			[201769] = "Disabling Reach";
			[233759] = "Grapple Weapon";
			[201201] = "Fast Feet";
			[216255] = "Eminence";
			[232054] = "Heavy-Handed Strikes";
			[206743] = "Tiger Style";
			[216255] = "Eminence";
 		},
		[270] = { --Mistweaver Monk
			[216255] = "Eminence";
			[216113] = "Way of the Crane";
			[202424] = "Chrysalis";
			[202428] = "Counteract Magic";
			[202577] = "Dome of Mist";
			[227344] = "Surging Mist";
			[202523] = "Refreshing Breeze";
			[205234] = "Healing Sphere";
			[209584] = "Zen Focus Tea";
			[159534] = "Yu'lon's Gift";
			[201201] = "Fast Feet";
			[233759] = "Grapple Weapon";
		},
		[577] = { --Havoc DH
			[211509] = "Solitude";
			[205604] = "Reverse Magic";
			[206649] = "Eye of Leotheras";
			[235903] = "Mana Rift";
			[235893] = "Demonic Origins";
			[206803] = "Rain from Above";
			[205596] = "Detainment";
			[203704] = "Mana Break";
			[203468] = "Glimpse";
			[227635] = "Cover of Darkness";
			[213480] = "Unending Hatred";
		},
		[581] = { --Vengeance DH
			[211509] = "Solitude";
			[205625] = "Cleansed by Flame";
			[205626] = "Everlasting Hunt";
			[205627] = "Jagged Spikes";
			[205630] = "Illidan's Grasp";
			[207029] = "Tormentor";
			[211489] = "Sigil Mastery";
			[205629] = "Demonic Trample";
			[205604] = "Reverse Magic";
			[205596] = "Detainment";
			[213480] = "Unending Hatred";
		}
	}
end
-- constants
local _G = _G

-- blizzard api
local CreateFrame = _G.CreateFrame

-- lua api
local next = _G.next
local pairs = _G.pairs
local strmatch = _G.strmatch
local tonumber = _G.tonumber
local type = _G.type

--[[if not lib.spells then
	lib.spells = {
		byName     = {},
		byId       = {},
		lastSeen   = {},
		book       = {},
	}
end]]

--[[if not lib.frame then
	lib.frame = CreateFrame("Frame")
	lib.frame:SetScript('OnEvent', function() return lib:ScanSpellbooks() end)
	lib.frame:RegisterEvent('SPELLS_CHANGED')
	lib.frame:RegisterEvent('PLAYER_ENTERING_WORLD')
end]]

function lib:TalentIsSelected(talentId)
	for i,v in ipairs(C_SpecializationInfo.GetAllSelectedPvpTalentIDs()) do 
		local _, name, _, _, _, id = GetPvpTalentInfoByID(v); 
		if (id == talentId) then
			return true
		end
	end 
	return false
end

function lib:GetSpecTalents(specId)
	specId = tonumber(specId);
	talents = lib.talents[specId];
	for k, v in pairs(lib.talents[0]) do
		talents[k] = v;
	end
	if (not talents) then
		return nil;
	end
	table.sort(talents);
	return talents;
end

function lib:GetTalentFromName(specId, name)
	specId = tonumber(specId);
	for k, v in pairs(lib.talents[specId]) do
		if (v:lower() == name:lower()) then
			return k, v;
		end
	end
	return nil
end