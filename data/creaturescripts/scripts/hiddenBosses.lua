local cfg = {
	['forei champion'] = {storage = 726532, textKill="Hidden Boss {Forei Champion} was defeated! You character enchantment increased!"},
	['shenlong'] = {storage = 726533, textKill="Hidden Boss {Shenlong} was defeated! You character enchantment increased!"},
	['golden falcon'] = {storage = 726534, textKill="Hidden Boss {Golden Falcon} was defeated! You character enchantment increased!"},
	['dark slime'] = {storage = 726535, textKill="Hidden Boss {Dark Slime} was defeated! You character enchantment increased!"},
	['forgotten ferumbras'] = {storage = 726536, textKill="Hidden Boss {Forgotten Ferumbras} Champion was defeated! You character enchantment increased!"},
	['orron'] = {storage = 726537, textKill="Hidden Boss {Orron} was defeated! You character enchantment increased!"},
	['behenees'] = {storage = 726538, textKill="Hidden Boss {Behenees} was defeated! You character enchantment increased!"},
	['abomination'] = {storage = 726539, textKill="Hidden Boss {Abomination} was defeated! You character enchantment increased!"},
	['guolong'] = {storage = 726540, textKill="Hidden Boss {Guolong} was defeated! You character enchantment increased!"},
	['guardian of hell'] = {storage = 726541, textKill="Hidden Boss {Guardian of Hell} was defeated! You character enchantment increased!"}
}
-- 726541 MAX
function onDeath(creature, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
	if not killer then return false end
    local tmp = cfg[creature:getName():lower()]
    if tmp and creature:isMonster() then
		local player = Player(killer:getId())
		if player then
			if player:getStorageValue(tmp.storage) == -1 then
				local stor = player:getStorageValue(PlayerStorage.bossesPassive)
				player:setStorageValue(PlayerStorage.bossesPassive, stor + 1)
				player:sendExtendedOpcode(71, json.encode({text = tmp.textKill, color = "#f7ef8a"}))
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, tmp.textKill)
				player:setStorageValue(tmp.storage, 1)
			end
		end
	end
    return true
end