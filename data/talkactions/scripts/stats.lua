function onSay(player, words, param)
	local descopop = "***Stats***"
	local attackPower = player:getStorageValue(6786789)
	local defensePower = player:getTotalDefense() + player:getTotalArmor() + player:getEffectiveSkillLevel(SKILL_SHIELD)
	local damageMelee = player:getStorageValue(PlayerStorage.increaseDamageMelee)
	local damageSpell = player:getStorageValue(PlayerStorage.increaseDamageSpell)
	local damageMeleePvP = player:getStorageValue(PlayerStorage.increaseDamageMeleePvP)
	local damageSpellPvP = player:getStorageValue(PlayerStorage.increaseDamageSpellPvP)
	local dps = player:getStorageValue(DPS_STORAGE)
	descopop = string.format("%s\nAttack Power: %s", descopop, attackPower)
	descopop = string.format("%s\nDefense Power: %s", descopop, defensePower)
	descopop = string.format("%s\nGreatest Melee/Distance Damage Dealt: %s", descopop, damageMelee)
	descopop = string.format("%s\nGreatest Spell Damage Dealt: %s", descopop, damageSpell)
	descopop = string.format("%s\nGreatest Melee/Distance Damage Dealt vs Player: %s", descopop, damageMeleePvP)
	descopop = string.format("%s\nGreatest Spell Damage Dealt vs Player: %s", descopop, damageSpellPvP)
	descopop = string.format("%s\nDPS: %s", descopop, dps)
	player:popupFYI(descopop)
	return false
end