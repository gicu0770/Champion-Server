local mType = Game.createMonsterType("The Final Witness")

local FinalWitness = {}
FinalWitness.experience = 0
FinalWitness.outfit = {
	lookType = 9,
}

FinalWitness.health = 10
FinalWitness.maxHealth = 10
FinalWitness.corpse = 0
FinalWitness.speed = 0
FinalWitness.tier = 0
FinalWitness.monsterLevel = 0
FinalWitness.bestiary = 9999
FinalWitness.race = "undead"

FinalWitness.flags = {
	summonable = false,
	attackable = false,
	hostile = true,
	convinceable = false,
	illusionable = false,
	pushable = false,
	canPushItems = true,
	canPushCreatures = true,
	unique = true,
}

function mType.onThink(monster, interval)
	local mid = monster:getId()
	if mid == 0 then return end
	if not BOSS_MONSTER_CONFIG[mid] then
    local boss_item = Game.createItem(38715, 1, monster:getPosition())
		BOSS_MONSTER_CONFIG[mid] = {
			ready = 0,
			phase = 0,
			spells = {},
      boss_item = boss_item
		}
	end
	onThinkBoss(monster, interval, SPELLS_CONFIG, BOSS_MONSTER_CONFIG[mid])
end

function mType.onAppear(monster, creature)
	if monster and creature then
		local id = monster:getId()
		if id == creature:getId() then
			monster:setMaxHealth(FinalWitness.health)
			monster:setHealth(FinalWitness.maxHealth)
			monster:registerEvent("FinalWitness_death_hp")
			monster:registerEvent("FinalWitness_death")
			mType:isAttackable(true)
			monster:setMonsterLevel(FinalWitness.monsterLevel)
			monster:setSkull(FinalWitness.skull)
			mType:tier(FinalWitness.tier)
			mType:items(FinalWitness.items)
      local boss_item = Game.createItem(38715, 1, monster:getPosition())
			BOSS_MONSTER_CONFIG[id] = {
				ready = 0,
				phase = 0,
				spells = {},
        boss_item = boss_item
			}
		end
	end
end
mType:register(FinalWitness)

local eventHealth = CreatureEvent("FinalWitness_death_hp")

function eventHealth.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not attacker then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local eventDeath = CreatureEvent("FinalWitness_death")

function eventDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if not creature then
		return true
	end

  local cid = creature:getId()
  if not BOSS_MONSTER_CONFIG[cid] then
    return true
  end

  local boss_item = BOSS_MONSTER_CONFIG[cid].boss_item
  if boss_item then
    boss_item:transform(38723)
  end

  addEvent(function()
    if not BOSS_MONSTER_CONFIG[cid] then
      return true
    end

    if boss_item then
      boss_item:remove()
    end
    BOSS_MONSTER_CONFIG[cid] = nil
  end, 62 * 100)

	return true
end

eventDeath:register()
eventHealth:register()
