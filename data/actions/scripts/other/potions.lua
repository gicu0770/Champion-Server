local melee = Condition(CONDITION_ATTRIBUTES)
melee:setParameter(CONDITION_PARAM_TICKS, 20 * 1000)
melee:setParameter(CONDITION_PARAM_SKILL_MELEE, 120)
melee:setParameter(CONDITION_PARAM_SUBID, 768999)

local shielding = Condition(CONDITION_ATTRIBUTES)
shielding:setParameter(CONDITION_PARAM_TICKS, 20 * 1000)
shielding:setParameter(CONDITION_PARAM_SKILL_SHIELD, 200)
shielding:setParameter(CONDITION_PARAM_SUBID, 768999)

local magic = Condition(CONDITION_ATTRIBUTES)
magic:setParameter(CONDITION_PARAM_TICKS, 20 * 1000)
magic:setParameter(CONDITION_PARAM_SKILL_FISHING, 120)
magic:setParameter(CONDITION_PARAM_SUBID, 768999)

local healing = Condition(CONDITION_ATTRIBUTES)
healing:setParameter(CONDITION_PARAM_TICKS, 20 * 1000)
healing:setParameter(CONDITION_PARAM_SKILL_FIST, 100)
healing:setParameter(CONDITION_PARAM_SUBID, 768999)

local leech = Condition(CONDITION_ATTRIBUTES)
leech:setParameter(CONDITION_PARAM_TICKS, 20 * 1000)
leech:setParameter(CONDITION_PARAM_SPECIALSKILL_LIFELEECHAMOUNT, 1)
leech:setParameter(CONDITION_PARAM_SPECIALSKILL_MANALEECHAMOUNT, 1)
leech:setParameter(CONDITION_PARAM_SUBID, 768999)

local distance = Condition(CONDITION_ATTRIBUTES)
distance:setParameter(CONDITION_PARAM_TICKS, 20 * 1000)
distance:setParameter(CONDITION_PARAM_SKILL_DISTANCE, 120)
distance:setParameter(CONDITION_PARAM_SUBID, 768999)

local criticalchance = Condition(CONDITION_ATTRIBUTES)
criticalchance:setParameter(CONDITION_PARAM_TICKS, 20 * 1000)
criticalchance:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE, 5)
criticalchance:setParameter(CONDITION_PARAM_SUBID, 768999)

local criticalamount = Condition(CONDITION_ATTRIBUTES)
criticalamount:setParameter(CONDITION_PARAM_TICKS, 20 * 1000)
criticalamount:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT, 20)
criticalamount:setParameter(CONDITION_PARAM_SUBID, 768999)

local movements = Condition(CONDITION_HASTE)
movements:setParameter(CONDITION_PARAM_TICKS, 20 * 1000)
movements:setFormula(0.15, 0, 0.15, 0)
movements:setParameter(CONDITION_PARAM_SUBID, 768999)






local potions = {
	[7618] = {health = {100, 100}, level = 1, flask = 7636, client_version = 810, effect = 304}, -- health potion
	[7620] = {mana = {100, 100}, level = 1, percent = 5, flask = 7636, client_version = 810, effect = 305}, -- mana potion
	[7588] = {health = {300, 300}, level = 50, flask = 7634, description = "Only for players of level 50 or above may drink this fluid.", client_version = 810, effect = 304}, -- strong health potion
	[7589] = {mana = {300, 300}, percent = 5, level = 50, flask = 7634, description = "Only for players of level 50 or above may drink this fluid.", client_version = 810, effect = 305}, -- strong mana potion
	[7591] = {health = {650, 650}, level = 110, flask = 7635, description = "Only for players of level 110 or above may drink this fluid.", client_version = 810, effect = 304}, -- great health potion
	[7590] = {mana = {650, 650}, percent = 5, level = 110, flask = 7635, description = "Only for players of level 110 or above may drink this fluid.", client_version = 810, effect = 305}, -- great mana potion
	[8472] = {health = {750, 750}, mana = {750, 750}, percent = 5, level = 110, flask = 7635, description = "Only for players of level 110 or above may drink this fluid.", client_version = 820, effect = 306}, -- great spirit potion
	[8473] = {health = {1100, 1100}, level = 190, flask = 7635, description = "Only for players of level 190 or above may drink this fluid.", client_version = 820, effect = 304}, -- ultimate health potion
	[26029] = {mana = {1100, 1100}, percent = 5, level = 190, flask = 7635, description = "Only for players of level 190 or above may drink this fluid.", client_version = 1092, effect = 305}, -- ultimate mana potion
	[26030] = {health = {1250, 1250}, mana = {1250, 1250}, percent = 5, level = 190, flask = 7635, description = "Only for players of level 190 or above may drink this fluid.", client_version = 1092, effect = 304}, -- supreme health potion
	[27217] = {mana = {1600, 1600}, percent = 5, level = 270, flask = 7635, description = "Only for players of level 270 or above may drink this fluid.", client_version = 1092, effect = 305},
	[26031] = {health = {1600, 1600}, level = 270, flask = 7635, description = "Only for players of level 270 or above may drink this fluid.", client_version = 1092, effect = 306}, -- ultimate spirit potion
	[36912] = {health = {2200, 2200}, level = 350, flask = 7635, description = "Only for players of level 350 or above may drink this fluid.", client_version = 1092, effect = 304}, -- health potion
	[36913] = {mana = {2200, 2200}, percent = 5, level = 350, flask = 7635, description = "Only for players of level 350 or above may drink this fluid.", client_version = 1092, effect = 305}, -- mana potion
	[36916] = {health = {3000, 3000}, mana = {3000, 3000}, percent = 5, level = 430, flask = 7635, description = "Only for players of level 430 or above may drink this fluid.", client_version = 1092, effect = 306}, -- spirit potion
	
	[34256] = {health = {5000, 5000}, level = 545, flask = 7635, description = "Only for players of level 545 or above may drink this fluid.", client_version = 1092, effect = 304}, -- health potion
	[21705] = {mana = {5000, 5000}, percent = 5, level = 545, flask = 7635, description = "Only for players of level 545 or above may drink this fluid.", client_version = 1092, effect = 305}, -- mana potion
	[32367] = {health = {7777, 7777}, mana = {8000, 8000}, percent = 5, level = 777, flask = 7635, description = "Only for players of level 777 or above may drink this fluid.", client_version = 1092, effect = 306}, -- ultimate spirit potion
	
	[34292] = {condition = true, level = 100, effect = CONST_ME_MAGIC_RED, description = "Only for players of level 100 or above may drink this fluid.", text = "You feel stronger.", client_version = 800}, -- berserk potion
	[35487] = {condition = true, level = 100, effect = CONST_ME_MAGIC_RED, description = "Only for players of level 100 or above may drink this fluid.", text = "You feel stronger.", client_version = 800}, -- berserk potion
	[36909] = {condition = true, level = 100, effect = CONST_ME_MAGIC_RED, description = "Only for players of level 100 or above may drink this fluid.", text = "You feel stronger.", client_version = 800}, -- berserk potion
	[36910] = {condition = true, level = 100, effect = CONST_ME_MAGIC_RED, description = "Only for players of level 100 or above may drink this fluid.", text = "You feel stronger.", client_version = 800}, -- berserk potion

	
	[6558] = {transform = {7588, 7589}, effect = CONST_ME_DRAWBLOOD, client_version = 790}, -- concentrated demonic blood
--	[7440] = {condition = mastermind, vocations = {1, 2, 5, 6, 9, 10, 13, 14}, effect = CONST_ME_MAGIC_BLUE, description = "Only sorcerers and druids may drink this potion.", text = "You feel smarter.", client_version = 800}, -- mastermind potion
--	[7443] = {condition = bullseye, vocations = {3, 7, 11, 15}, effect = CONST_ME_MAGIC_GREEN, description = "Only paladins may drink this potion.", text = "You feel more accurate.", client_version = 800}, -- bullseye potion
	[8474] = {antidote = true, flask = 7636, client_version = 820}, -- antidote potion
	[8704] = {health = {60, 90}, level = 1, flask = 7636, client_version = 820} -- small health potion
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if type(target) == "userdata" and not target:isPlayer() then
		return false
	end


	local potion = potions[item:getId()]
	local reborn = player:getStorageValue(PlayerStorage.reborn)
	local rebornLevel = 0
	if reborn >= 1 then
	 rebornLevel = reborn * 500
	end
	local potionLevel = potion.level - rebornLevel
	if potionLevel and player:getLevel() < potionLevel or potion.vocations and not table.contains(potion.vocations, player:getVocation():getId()) then
		player:say(potion.description, TALKTYPE_MONSTER_SAY)
		return true
	end

	local configTRUE = {
		[34292] = FLASK_BERSERK,
		[35487] = FLASK_ARMORED,
		[36909] = FLASK_SPELL,
		[36910] = FLASK_HEALING
		}
	if potion.condition then
	--	player:addCondition(potion.condition)
		target:say(potion.text, TALKTYPE_MONSTER_SAY)
		target:getPosition():sendMagicEffect(potion.effect)
		target:addBuff(configTRUE[item:getId()], 10800000)
		
	elseif potion.transform then
		item:transform(potion.transform[math.random(#potion.transform)])
		item:getPosition():sendMagicEffect(potion.effect)
		return true
	else
	local healingPrimary = 0
	local manaPrimary = 0
	for slot = CONST_SLOT_HEAD, CONST_SLOT_RING2 do
        local itemPlayer = player:getSlotItem(slot)
        if itemPlayer then
          local values = itemPlayer:getBonusAttributes()
          if values then
            for key, value in pairs(values) do
              value[1] = value[1]
              value[2] = value[2]
              local attr = US_ENCHANTMENTS[value[1]]
              if attr then
                if attr.name == "Health Flask Recovery" then
                 	healingPrimary = healingPrimary + value[2]
                end
				if attr.name == "Mana Flask Recovery" then
                 	manaPrimary = manaPrimary + value[2]
                end
              end
            end
          end
        end
      end
		local config = {
		[1] = FLASK_DAMAGE,
		[2] = FLASK_REDUCTION,
		[3] = FLASK_H,
		[4] = FLASK_DODGE,
		[5] = FLASK_PEN
		}
		local configCondition = {
		[1] = {condition = melee},
		[2] = {condition = distance},
		[3] = {condition = magic},
		[4] = {condition = shielding},
		[5] = {condition = false, buff = FLASK_MELEE_DAMAGE}, -- melee damage
		[6] = {condition = criticalamount}, -- critical chance
		[7] = {condition = false, buff = FLASK_DOT}, -- dot damage
		[8] = {condition = false, buff = FLASK_REFLECT}, -- reflect
		[9] = {condition = healing}, -- healing power
		[10] = {regen = true}, -- regen
		[11] = {condition = leech}, -- leech
		[12] = {condition = false, buff = FLASK_CAST}, -- cast
		}
		if item:isFlask() then
		 target:addBuff(config[item:getFlask()])
		end
		if item:isFlaskBonus() then
			if configCondition[item:getFlaskBonus()].condition then
		 		target:addCondition(configCondition[item:getFlaskBonus()].condition)
			end
			if configCondition[item:getFlaskBonus()].buff then
				target:addBuff(configCondition[item:getFlaskBonus()].buff)
			end
			if configCondition[item:getFlaskBonus()].regen then
				local regen_HP = target:getMaxHealth() * 0.02
				local regen_MP = target:getMaxMana() * 0.02
				local regen = Condition(CONDITION_REGENERATION)
				regen:setParameter(CONDITION_PARAM_TICKS, 5 * 1000)
				regen:setParameter(CONDITION_PARAM_HEALTHGAIN,  regen_HP)
				regen:setParameter(CONDITION_PARAM_HEALTHTICKS,  1000)
				regen:setParameter(CONDITION_PARAM_MANAGAIN,  regen_MP)
				regen:setParameter(CONDITION_PARAM_MANATICKS,  1000)
				regen:setParameter(CONDITION_PARAM_SUBID, 768999)
				target:addMana(regen_MP)
			end
		end
		if item:isFlaskAttribute() then
			local flask_bonus_attribute = {
				[1] = FLASK_EXTRA_DOT_DAMAGE,
				[2] = FLASK_EXTRA_REFLECT_DAMAGE,
				[3] = FLASK_EXTRA_BASIC_DAMAGE,
				[4] = FLASK_EXTRA_FLAT_DAMAGE,
				[5] = FLASK_EXTRA_CAST_DAMAGE,
			}
			target:addBuff(flask_bonus_attribute[item:getFlaskAttribute()])
		end
		if potion.health then
		local HP = math.ceil(potion.health[1] + ((potion.health[1] * healingPrimary) / 100))
			doTargetCombat(player:getId(), target, COMBAT_HEALING, HP, HP)
		end

		if potion.mana then
		local manaPercent = (player:getMaxMana() * potion.percent) / 100
		local manaRecovery = potion.mana[1] + manaPercent
		local manaEnd = manaRecovery + ((manaRecovery * manaPrimary) / 100)
			doTargetCombat(player:getId(), target, COMBAT_MANADRAIN, manaEnd, manaEnd)
		end

	--	player:addItem(potion.flask)
	--	target:say("Aaaah...", TALKTYPE_MONSTER_SAY)
	 if target:getPosition():sendMagicEffect(potion.effect) then
	  target:getPosition():sendMagicEffect(potion.effect)
	 else
	  target:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
	 end
	end
	
	if not configManager.getBoolean(configKeys.REMOVE_POTION_CHARGES) then
		return true
	end
	
	if item:getId() == 34256 or item:getId() == 21705 or item:getId() == 32367 then
	else
	item:remove(1)
	end
	
	return true
end
