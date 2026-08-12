BOSS_MONSTER_CONFIG = {}

function sendWarning(mid, area, spell, combat)
	if not combat then return end
	local monster = Creature(mid)
  if not monster or monster:isRemoved() then
    return
  end

	local targetPosition = monster:getPosition()
	local target = monster:getTarget()
	if spell.onTarget then
		if not target then return end
		targetPosition = target:getPosition()
	end

	if spell.wave and target and not target:isRemoved() then
		local dir = monster:getDirection()

		if dir == DIRECTION_NORTH then
			targetPosition.y = targetPosition.y - 1
		elseif dir == DIRECTION_EAST then
			targetPosition.x = targetPosition.x + 1
		elseif dir == DIRECTION_SOUTH then
			targetPosition.y = targetPosition.y + 1
		elseif dir == DIRECTION_WEST then
			targetPosition.x = targetPosition.x - 1
		end
	end

	if not area then return end
		local pos = Position(targetPosition)
	if spell.random_size then
		pos.y = pos.y - math.random(-spell.random_size, spell.random_size)
		pos.x = pos.x - math.random(-spell.random_size, spell.random_size)
	end

	local area = createCombatArea(area)
	doAreaCombatHealth(monster:getId(), COMBAT_PHYSICALDAMAGE, pos, area, 0, 0, 145, ORIGIN_AUTOCAST, 0, 0)
	addEvent(function(area)
		local monster = Creature(mid)
		if not monster or monster:isRemoved() then
			return
		end
		if spell.jump_position then
			if monster:getTarget() then
			local distance = getDistanceBetween(monster:getPosition(), pos)
			monster:jump(8 * distance, 70 * distance)
			monster:teleportTo(pos, true)
			end
		end
		combat:setArea(area)
		combat:execute(monster, Variant(pos))
	end, spell.exhaust, area)
end

function setupBossCombat(spell, void)
	local combat = Combat()
	combat:setParameter(COMBAT_PARAM_BLOCKARMOR, true)
	combat:setParameter(COMBAT_PARAM_BLOCKSHIELD, true)
	combat:setParameter(COMBAT_PARAM_EFFECT, spell.effect)
	combat:setOrigin(ORIGIN_AUTOCAST)
	combat:setParameter(COMBAT_PARAM_TYPE, spell.damageType)
	combat:setParameter(COMBAT_PARAM_DAMAGE, -spell.damageRaw)

	if spell.bottomEffect then
		combat:setParameter(COMBAT_PARAM_BOTTOMEFFECT, 1)
	end

	if void then
		combat:setParameterText(COMBAT_PARAM_COLOR, "Void")
	end

	if spell.center then
		combat:setParameter(COMBAT_PARAM_CENTEREFFECT, spell.center)
	end
	if spell.offsetX then
		combat:setParameter(COMBAT_PARAM_OFFSETXEFFECT, spell.offsetX)
	end
	if spell.offsetY then
		combat:setParameter(COMBAT_PARAM_OFFSETYEFFECT, spell.offsetY)
	end
	if spell.distanceeffect then
		combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, spell.distanceeffect)
	end
	local onHit = {
		conditions = {},
		funcs = {}
	}
	if spell.onHit then
		for _, debuff in ipairs(spell.onHit) do
			if type(debuff[1]) == "function" then
				table.insert(onHit.funcs, debuff[1])
			else
				local condition = Condition(debuff[1])
				condition:setParameter(CONDITION_PARAM_TICKS, debuff[2])

				table.insert(onHit.conditions, {condition, debuff[3]})
			end
		end

		function onTargetCombat(boss, target)
			if not target or not boss then
				return
			end
			for _, debuffCond in ipairs(onHit.conditions) do
				local condition = debuffCond[1]
				if debuffCond[2] then
					debuffCond[2](condition, target)
				end

				target:addCondition(condition)
			end

			for _, debuffFunc in ipairs(onHit.funcs) do
				if debuffFunc then
					debuffFunc(target, boss)
				end
			end
		end
		combat:setCallback(CALLBACK_PARAM_TARGETCREATURE, "onTargetCombat")
	end
	
	if spell.tileEffect then
		function onTargetTile(boss, position, fromPos)
			if not boss then return end
			position:sendMagicEffect(spell.tileEffect)
		end
    	combat:setCallback(CALLBACK_PARAM_TARGETTILE, "onTargetTile")
	end
	if spell.tileDistanceEffect then
		function onTargetTile(boss, position, fromPos)
			if not boss then return end
			boss:getPosition():sendDistanceEffect(position, spell.tileDistanceEffect)
		end
    	combat:setCallback(CALLBACK_PARAM_TARGETTILE, "onTargetTile")
	end
	return combat
end

function onThinkBoss(monster, interval, config, selfConfig)
	local mid = monster:getId()
	if mid == 0 then
    	print("Error: Missing monster id")
		return
	end

	if selfConfig and selfConfig.ready == 0 then
		local specs = Game.getSpectators(monster:getPosition(), false, true, 8, 8, 7, 7)
		if #specs > 0 then
			selfConfig.ready = 1
			local isVoid = monster:getStorageValue(MonsterStorages.voidRelict)
			if isVoid > 0 then
				monster:transformToVoidBoss()
			end
		end
	else
		if not config then
			return
		end

		if monster:getStorageValue(1) == 1 then
			return
		end

		for _ = 1, #config do
			local i = math.random(#config)
			local spell = config[i]
			if spell then
				if monster:getStorageValue(1) == 1 then
					return
				end

				if not selfConfig.spells[i] then
					selfConfig.spells[i] = 0
				else
					selfConfig.spells[i] = selfConfig.spells[i] + interval
				end

				if selfConfig.spells[i] >= spell.interval then
					local currentArea = spell.area
					if spell.hp_precent then
						local percentHP = monster:getHealth() * 100 / monster:getMaxHealth()
						if percentHP <= spell.hp_precent then
							currentArea = spell.area_change
						end
					end

					if spell.stay then
						monster:setInPlace(true)
					end
					monster:setStorageValue(1, 1)

					selfConfig.spells = {}
					selfConfig.spells[i] = 0 - (spell.exhaust + spell.startTime)
					local combat = setupBossCombat(spell, selfConfig.void)
					for x = 1, #currentArea do 
						addEvent(function()
							if spell.count then
								for y = 1, spell.count do
									addEvent(function()
										sendWarning(mid, currentArea[x], spell, combat)
									end, spell.multiDelay * y)
								end
							else
								sendWarning(mid, currentArea[x], spell, combat)
							end
						end, spell.startTime * x)
					end
					if spell.immortal then
						monster:addBuff(BOSS_IMMORTAL)
					end

					local castedAfter = spell.exhaust + spell.startTime * #currentArea
					if spell.multiDelay then
						castedAfter = spell.multiDelay * spell.count
					end
					monster:setProgressBar(castedAfter, false)
					addEvent(function()
						local monster = Creature(mid)
						if not monster or monster:isRemoved() then
							return
						end
						monster:setStorageValue(1, 0)
						monster:setInPlace(false)
					end, castedAfter)

					addEvent(function()
						combat:delete()
					end, castedAfter + 5000)
				end
			end
		end
	end
end

local voidDeath = CreatureEvent("VoidBoss_onDeath")
function voidDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

	local relict = mostdamagekiller:getBossRelict()
	if relict then
		local voidCount = relict:getCustomAttribute("void")
		if not voidCount then
			voidCount = 0
		end

		if voidCount < 6 then
			relict:setCustomAttribute("void", voidCount + 1)
			mostdamagekiller:sendTextMessage(MESSAGE_INFO_DESCR, "Your Relict has absorbed the essence of the Void Boss. ("..(voidCount + 1).." total)")
			return true
		end

		local dungeon = mostdamagekiller:getDungeon()
		if not dungeon then
			dungeon = lasthitkiller:getDungeon()
			if not dungeon then
				return true
			end
		end

		local instance = dungeon:getPlayerInstance(mostdamagekiller)
		if not instance then
			instance = dungeon:getPlayerInstance(lasthitkiller)
			if not instance then
				return true
			end
		end

		local runners = instance:getRunners()
		for _, runner in pairs(runners) do
			local voidRelict = runner:getBossRelict()
			if voidRelict then
				local voidCount = relict:getCustomAttribute("void")
				if not voidCount then
					voidCount = 0
				end

				if voidCount < 6 then
					voidRelict:setCustomAttribute("void", voidCount + 1)
					runner:sendTextMessage(MESSAGE_INFO_DESCR, "Your Relict has absorbed the essence of the Void Boss. ("..(voidCount + 1).." total)")
					return true
				end
			end
		end
	end
	return true
end
voidDeath:register()

function Monster:transformToVoidBoss()
	local id = self:getId()
	if BOSS_MONSTER_CONFIG[id] then
		BOSS_MONSTER_CONFIG[id].void = true
	else
		print("[Transform To Void] Error: Missing boss monster config for id "..id)
		return
	end

	self:setInPlace(true)
	self:jump(15, 500)
	self:registerEvent("VoidBoss_onDeath")
	addEvent(function()
		local monster = Monster(id)
		if not monster then return end
		local pos = monster:getPosition()
		pos.x = pos.x + 6
		pos.y = pos.y + 6
		pos:sendMagicEffect(576, 1, "Void")
		addEvent(function()
			local monster = Monster(id)
			if not monster then return end
			monster:setSkull(0)
			monster:setTitle("124 12FC4", "hex-14px", "#c900c9")
			local outfit = monster:getOutfit()
			outfit.lookShader = "Void"
			monster:setOutfit(outfit)
			monster:setInPlace(false)
		end, 500)
	end, 500)
end
