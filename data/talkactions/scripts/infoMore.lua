
function onSay(player, words, param)
local target = Player(param)
if target == nil then
 player:sendTextMessage(MESSAGE_INFO_DESCR,"A player with that name is not online.")
 return false
end
if(param == "") then
	target = player
	else
end

--	setEternalStorage(67856, -1)
--	setEternalStorage(67857, -1)
--	setEternalStorage(67858, -1)
local specialSkills = {
	[SPECIALSKILL_CRITICALHITCHANCE] = "cc",
	[SPECIALSKILL_CRITICALHITAMOUNT] = "ca",
	[SPECIALSKILL_LIFELEECHCHANCE] = "lc",
	[SPECIALSKILL_LIFELEECHAMOUNT] = "la",
	[SPECIALSKILL_MANALEECHCHANCE] = "mc",
	[SPECIALSKILL_MANALEECHAMOUNT] = "ma"
}
  
local skills = {
	[SKILL_FIST] = "fist",
	[SKILL_MELEE] = "melee",
	[SKILL_DISTANCE] = "dist",
	[SKILL_SHIELD] = "shield",
	[SKILL_FISHING] = "fish"
}
  
local stats = {
	[STAT_MAGICPOINTS] = "mag",
	[STAT_MAXHITPOINTS] = "maxhp",
	[STAT_MAXMANAPOINTS] = "maxmp"
}
  
local statsPercent = {
	[STAT_MAXHITPOINTS] = "maxhp_p",
	[STAT_MAXMANAPOINTS] = "maxmp_p"
}
  
local combatTypeNames = {
	[COMBAT_PHYSICALDAMAGE] = "Physical",
	[COMBAT_ENERGYDAMAGE] = "Energy",
	[COMBAT_EARTHDAMAGE] = "Earth",
	[COMBAT_FIREDAMAGE] = "Fire",
	[COMBAT_LIFEDRAIN] = "Lifedrain",
	[COMBAT_MANADRAIN] = "Manadrain",
	[COMBAT_HEALING] = "Healing",
	[COMBAT_DROWNDAMAGE] = "Drown",
	[COMBAT_ICEDAMAGE] = "Ice",
	[COMBAT_HOLYDAMAGE] = "Holy",
	[COMBAT_DEATHDAMAGE] = "Death"
}
  
local combatShortNames = {
	[COMBAT_PHYSICALDAMAGE] = "a_phys",
	[COMBAT_ENERGYDAMAGE] = "a_ene",
	[COMBAT_EARTHDAMAGE] = "a_earth",
	[COMBAT_FIREDAMAGE] = "a_fire",
	[COMBAT_LIFEDRAIN] = "a_ldrain",
	[COMBAT_MANADRAIN] = "a_mdrain",
	[COMBAT_HEALING] = "a_heal",
	[COMBAT_DROWNDAMAGE] = "a_drown",
	[COMBAT_ICEDAMAGE] = "a_ice",
	[COMBAT_HOLYDAMAGE] = "a_holy",
	[COMBAT_DEATHDAMAGE] = "a_death"
}

local implicits = {
	["ca"] = "Critical Damage",
	["cc"] = "Critical Chance",
	["la"] = "Life Leech Amount",
	["lc"] = "Life Leech Chance",
	["ma"] = "Mana Leech Amount",
	["mc"] = "Mana Leech Chance",
	["speed"] = "Movement Speed",
	["fist"] = "Fist Fighting",
	["melee"] = "Melee Fighting",
	["dist"] = "Distance Fighting",
	["shield"] = "Shielding",
	["fish"] = "Magic Power",
	["mag"] = "Mastary",
	["a_phys"] = "Physical Protection",
	["a_ene"] = "Energy Protection",
	["a_earth"] = "Earth Protection",
	["a_fire"] = "Fire Protection",
	["a_ldrain"] = "Lifedrain Protection",
	["a_mdrain"] = "Manadrain Protection",
	["a_heal"] = "Healing Protection",
	["a_drown"] = "Drown Protection",
	["a_ice"] = "Ice Protection",
	["a_holy"] = "Holy Protection",
	["a_death"] = "Death Protection",
	["a_all"] = "Protection All",
	["maxhp"] = "Health",
	["maxmp"] = "Mana",
	["maxhp_p"] = "Max HP",
	["maxmp_p"] = "Max MP",
	["hpgain"] = "Health Regen",
	["mpgain"] = "Mana Regen"
}
local impPercent = {
	["ca"] = true,
	["cc"] = true,
	["la"] = true,
	["lc"] = true,
	["ma"] = true,
	["mc"] = true,
	["a_phys"] = true,
	["a_ene"] = true,
	["a_earth"] = true,
	["a_fire"] = true,
	["a_ldrain"] = true,
	["a_mdrain"] = true,
	["a_heal"] = true,
	["a_drown"] = true,
	["a_ice"] = true,
	["a_holy"] = true,
	["a_death"] = true,
	["a_all"] = true,
	["maxhp_p"] = true,
	["maxmp_p"] = true
}
local implicit = {}
for i = CONST_SLOT_HEAD, CONST_SLOT_RING2 do
    local slotItem = target:getSlotItem(i)
    if slotItem ~= nil and slotItem:getType():isUpgradable() then
		if slotItem:getType():usesSlot(i) then
		local itemType = slotItem:getType()
		
		
			for key, value in pairs(stats) do
				local s = itemType:getStat(key)	-- value to nazwa s to ilosc key to numer skilla
				if s and s >= 1 then
					if implicit[value] ~= nil then
						implicit[value] = implicit[value] + s
						else
						implicit[value] = s
					end
				end
			end
			for key, value in pairs(skills) do
				local s = itemType:getSkill(key)	-- value to nazwa s to ilosc key to numer skilla
				if s and s >= 1 then
					if implicit[value] ~= nil then
						implicit[value] = implicit[value] + s
						else
						implicit[value] = s
					end
				end
			end
			for key, value in pairs(specialSkills) do
				local s = itemType:getSpecialSkill(key)	-- value to nazwa s to ilosc key to numer skilla
				if s and s >= 1 then
					if implicit[value] ~= nil then
						implicit[value] = implicit[value] + s
						else
						implicit[value] = s
					end
				end
			end
		  local allprot = itemType:getAbsorbPercent(0)

		  if allprot ~= 0 then
			for i = 0, COMBAT_COUNT - 1 do
			  if itemType:getAbsorbPercent(i) ~= allprot then
				allprot = 0
				break
			  end
			end
		  end

		  if allprot == 0 then
			for i = 0, COMBAT_COUNT - 1 do
			  if itemType:getAbsorbPercent(i) ~= 0 then
				local combatType = bit.lshift(1, i)
				if combatType ~= COMBAT_UNDEFINEDDAMAGE then
				  implicit[combatShortNames[combatType]] = itemType:getAbsorbPercent(i)
				end
			  end
			end
		  else
			implicit.a_all = allprot
		  end
			
	  for key, value in pairs(statsPercent) do
		local s = itemType:getStatPercent(key)
		if s and s >= 1 then
			if implicit[value] ~= nil then
				implicit[value] = implicit[value] + s - 100
			else
				implicit[value] = s - 100
			end
		end
	  end

	  local healthGain = itemType:getHealthGain()
	  if healthGain and healthGain > 0 then
			if implicit.hpgain ~= nil then
				implicit.hpgain = implicit.hpgain + healthGain
			else
				implicit.hpgain = healthGain
			end
	  end

	  local manaGain = itemType:getManaGain()
	  if manaGain and manaGain > 0 then
			if implicit.mpgain ~= nil then
				implicit.mpgain = implicit.mpgain + manaGain
			else
				implicit.mpgain = manaGain
			end
	  end

	  local speed = itemType:getSpeed()
	  if speed and speed > 0 then
		implicit.speed = speed
			if implicit.speed ~= nil then
				implicit.speed = implicit.speed + speed
			else
				implicit.speed = speed
			end
	  end
			
			
			
			
			
			
		end
	end
end
local desc = "[---------Statistic---------]\nPlayer: "..target:getName().."\nItems Basic Attributes\nVitality"
local desc2 = "Offensive"
local desc3 = "Defensive"
local desc4 = "\nItems Enchantment Attributes"
local towerBonus = (target:getStorageValue(PlayerStorage.darkTower) + 1 )
local dungeonChalleng = (target:getStorageValue(PlayerStorage.progressBonuses) + 1 )
local quest = (target:getStorageValue(PlayerStorage.questPassive) + 1 )
local boss = (target:getStorageValue(PlayerStorage.bossesPassive) + 1 )
local totalEnchantment = towerBonus + dungeonChalleng + quest + boss
local desc5 = "\nCharacter Enchantment Level "..totalEnchantment.."/70\n>Dark Tower Level: "..towerBonus.."/10"
local desc6 = "\n>Dungeon Challenges done: "..dungeonChalleng.."/40"
local desc7 = "\n>Secret Quests found: "..quest.."/10"
local desc8 = "\n>Hidden Bosses defeated: "..boss.."/10"
for key, value in pairs(implicit) do
	if key == key then
		if key == "maxhp" or key == "maxmp" then
			desc = string.format("%s\n   %s %s", desc, implicits[key], value)
		end
		if key == "maxhp_p" or key == "maxmp_p" then
			desc = string.format("%s\n   %s %s%%", desc, implicits[key], value)
		end
		if key == "hpgain" or key == "mpgain" then
			desc = string.format("%s\n   %s %s", desc, implicits[key], value)
		end
		if key == "fist" or key == "melee" or key == "dist" or key == "fish" or key == "mag" then
			desc2 = string.format("%s\n   %s %s", desc2, implicits[key], value)
		end
		if key == "cc" or key == "ca" then
			desc2 = string.format("%s\n   %s %s%%", desc2, implicits[key], value)
		end
		if key == "a_all" or key == "a_phys" or key == "a_ene" or key == "a_earth" or key == "a_fire" or key == "a_ice" or key == "a_holy" or key == "a_death" then
			desc3 = string.format("%s\n   %s %s%%", desc3, implicits[key], value)
		end
		if key == "shield" then
			desc3 = string.format("%s\n   %s %s", desc3, implicits[key], value)
		end
	end
end

  local attrTable = {}
  local fullBonus = ""
  for i = CONST_SLOT_HEAD, CONST_SLOT_RING2 do
    local slotItem = target:getSlotItem(i)
    if slotItem ~= nil and slotItem:getType():isUpgradable() then
      if slotItem:getType():usesSlot(i) then
        for i = 1, slotItem:getMaxAttributes() do
          local enchant = slotItem:getBonusAttribute(i)
          if enchant then
            local attr = US_ENCHANTMENTS[enchant[1]]
            if attrTable[enchant[1]] ~= nil then
              attrTable[enchant[1]].value = attrTable[enchant[1]].value + enchant[2]
			  if attr.name:find("Protection") then
				attrTable[enchant[1]].value = math.min(50, attrTable[enchant[1]].value)
			  end
              attrTable[enchant[1]].text = attr.format(attrTable[enchant[1]].value):gsub("%%%%", "%%")
            else
              attrTable[enchant[1]] = {text = attr.format(enchant[2]):gsub("%%%%", "%%"), value = enchant[2]}
			  if attr.name:find("Protection") then
				attrTable[enchant[1]].value = math.min(50, attrTable[enchant[1]].value)
			  end
            end
          end
        end
      end
    end
  end

--	player:sendTextMessage(MESSAGE_INFO_DESCR, ""..attrTable[15].text.."")
local bonus = getFullBonus(target)
  if bonus == "" then
    bonus = "No attributes"
  end
local towerBonusDWA = towerBonus / 2
local towerBonusPOL = towerBonus / 4
local towerBonusHEAL = towerBonus * 2
local pasiveBonuses = "   None."
if towerBonus > 0 then
 pasiveBonuses = "   "..towerBonusHEAL.."% recovery effectiveness\n   Increased damage to monster "..towerBonusDWA.."%\n   Increased damage to elite monsters "..towerBonusDWA.."%\n   Increased damage to boss "..towerBonusDWA.."%"
end

local cooldown = dungeonChalleng / 4
local castSpeed = dungeonChalleng * 0.625
local dungeonChallengBonus = "   None."
if dungeonChalleng > 0 then
 dungeonChallengBonus = "   Spells cooldown +"..cooldown.."%\n   Spells cast speed +"..castSpeed.."%"
end

local attackSpeed = quest * 2
local gold = quest * 2
local helingQuest = quest
local questBonus = "   None."
if quest > 0 then
 questBonus = "   Attack Speed increased by "..attackSpeed.."%\n   Gold increased by "..gold.."%\n   "..helingQuest.."% recovery effectiveness"
end

local hpMana = boss * 2
local expBonus = boss * 2
local bossDD = boss / 2
local bossBonus = "   None."
if boss > 0 then
 bossBonus = "   EXP increased by "..expBonus.."%\n   Health and Mana increased by "..hpMana.."%\n   Increased damage to boss "..bossDD.."%"
end

	desc4 = string.format("%s %s %s", desc4, "", bonus)
	desc5 = string.format("%s\n%s", desc5, pasiveBonuses)
	desc6 = string.format("%s\n%s", desc6, dungeonChallengBonus)
	desc7 = string.format("%s\n%s", desc7, questBonus)
	desc8 = string.format("%s\n%s", desc8, bossBonus)
	local tekst = ""..desc.."\n"..desc2.."\n"..desc3.."\n"..desc4.."\n"..desc5.."\n"..desc6.."\n"..desc7.."\n"..desc8..""
--	player:popupFYI(tekst)
	player:showTextDialog(1950, tekst)
	return false
end