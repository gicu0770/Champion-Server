local config = {
    -- Lizards
    ['vexclaw'] = {name = 'Vexclaws', amount = 500, storage = 59000, startstorage = 50100, startvalue = 1, nameQ = 'Draken'},
    ['hellflayer'] = {name = 'Vexclaws', amount = 500, storage = 59000, startstorage = 50100, startvalue = 1, nameQ = 'Draken'},
    ['grimeleech'] = {name = 'Vexclaws', amount = 500, storage = 59000, startstorage = 50100, startvalue = 1, nameQ = 'Draken'},
	   -- Drakens
    ['draken warmaster'] = {name = 'Draken Orclops', amount = 3000, storage = 59001, startstorage = 50101, startvalue = 1, nameQ = 'Forgotten Land'},
    ['draken spellweaver'] = {name = 'Draken Orclops', amount = 3000, storage = 59001, startstorage = 50101, startvalue = 1, nameQ = 'Forgotten Land'},
    ['draken elite'] = {name = 'Draken Orclops', amount = 3000, storage = 59001, startstorage = 50101, startvalue = 1, nameQ = 'Forgotten Land'},
    ['draken abomination'] = {name = 'Draken Orclops', amount = 3000, storage = 59001, startstorage = 50101, startvalue = 1, nameQ = 'Forgotten Land'},

    ['orclops doomhauler'] = {name = 'Draken Orclops', amount = 3000, storage = 59001, startstorage = 50101, startvalue = 1, nameQ = 'Forgotten Land'},
    ['orclops mage'] = {name = 'Draken Orclops', amount = 3000, storage = 59001, startstorage = 50101, startvalue = 1, nameQ = 'Forgotten Land'},
    ['orclops ravager'] = {name = 'Draken Orclops', amount = 3000, storage = 59001, startstorage = 50101, startvalue = 1, nameQ = 'Forgotten Land'},
	
	   -- Forgotten
    ['forgotten knight'] = {name = 'Forgotten', amount = 5000, storage = 59002, startstorage = 50102, startvalue = 1, nameQ = 'Brotherhood Castle'},
    ['forgotten wizard'] = {name = 'Forgotten', amount = 5000, storage = 59002, startstorage = 50102, startvalue = 1, nameQ = 'Brotherhood Castle'},
    ['forgotten lancer'] = {name = 'Forgotten', amount = 5000, storage = 59002, startstorage = 50102, startvalue = 1, nameQ = 'Brotherhood Castle'},
    ['forgotten archer'] = {name = 'Forgotten', amount = 5000, storage = 59002, startstorage = 50102, startvalue = 1, nameQ = 'Brotherhood Castle'},
	
	   -- Burning  ---- storageACCESS = 51203, mstorage = 81102, storage = 81002
    ['burning knight'] = {name = 'Burning', amount = 3000, storage = 81102, startstorage = 81002, startvalue = 1, nameQ = 'Prism Set'},
    ['burning wizard'] = {name = 'Burning', amount = 3000, storage = 81102, startstorage = 81002, startvalue = 1, nameQ = 'Prism Set'},
    ['burning lancer'] = {name = 'Burning', amount = 3000, storage = 81102, startstorage = 81002, startvalue = 1, nameQ = 'Prism Set'},
    ['burning archer'] = {name = 'Burning', amount = 3000, storage = 81102, startstorage = 81002, startvalue = 1, nameQ = 'Prism Set'},


	   -- Brotherhood ---- storageACCESS = 51204, mstorage = 81103, storage = 81003
    ['brotherhood lady'] = {name = 'Brotherhood', amount = 7000, storage = 81103, startstorage = 81003, startvalue = 1, nameQ = 'Undead Fortress'},
    ['brotherhood reaper'] = {name = 'Brotherhood', amount = 7000, storage = 81103, startstorage = 81003, startvalue = 1, nameQ = 'Undead Fortress'},
    ['brotherhood assassin'] = {name = 'Brotherhood', amount = 7000, storage = 81103, startstorage = 81003, startvalue = 1, nameQ = 'Undead Fortress'},
    ['brotherhood wizard'] = {name = 'Brotherhood', amount = 7000, storage = 81103, startstorage = 81003, startvalue = 1, nameQ = 'Undead Fortress'},

	
	   -- Undead storageACCESS = storageACCESS = 51205, mstorage = 81104, storage = 81004
 --   ['undead warrior'] = {name = 'Undead Warrior', amount = 2000, storage = 81104, startstorage = 81004, startvalue = 1, nameQ = 'Stage 1'},
	
  --  ['undead dragon lord'] = {name = 'Undead Dragon', amount = 2000, storage = 81105, startstorage = 81005, startvalue = 1, nameQ = 'Stage 2'},

  --  ['undead reaper'] = {name = 'Undead Reaper', amount = 2000, storage = 81106, startstorage = 81006, startvalue = 1, nameQ = 'Stage 3'},
	
	-- Royal
   ['royal lancer'] = {name = 'Royal', amount = 12000, storage = 81108, startstorage = 81008, startvalue = 1, nameQ = 'Hell Underground'},
   ['royal slayer'] = {name = 'Royal', amount = 12000, storage = 81108, startstorage = 81008, startvalue = 1, nameQ = 'Hell Underground'},
   ['royal leader'] = {name = 'Royal', amount = 12000, storage = 81108, startstorage = 81008, startvalue = 1, nameQ = 'Hell Underground'},
   ['royal mage'] = {name = 'Royal', amount = 12000, storage = 81108, startstorage = 81008, startvalue = 1, nameQ = 'Hell Underground'},

	   -- Rage
	['rage champion'] = {name = 'Rage', amount = 12000, storage = 81109, startstorage = 81009, startvalue = 1, nameQ = 'Hell Stone'},
	['rage druid'] = {name = 'Rage', amount = 12000, storage = 81109, startstorage = 81009, startvalue = 1, nameQ = 'Hell Stone'},
	['rage spearman'] = {name = 'Rage', amount = 12000, storage = 81109, startstorage = 81009, startvalue = 1, nameQ = 'Hell Stone'},
	['rage berserker'] = {name = 'Rage', amount = 12000, storage = 81109, startstorage = 81009, startvalue = 1, nameQ = 'Hell Stone'}
	
}



function onKill(player, target)
    local monster = config[target:getName():lower()]
    if not target or target:isPlayer() or not monster or target:getMaster() then
        return true
    end

player:openChannel(16)
	local party = player:getParty()
if party then
    local members = party:getMembers()
    for i = 1, #members do
        local member = members[i]
        if member:getPosition():getDistance(target:getPosition()) <= 20 then
    local stor = member:getStorageValue(monster.storage)+1
    if stor < monster.amount and member:getStorageValue(monster.startstorage) >= monster.startvalue then
        member:setStorageValue(monster.storage, stor)
 		member:sendChannelMessage('','[Access '..monster.nameQ..'] '..(stor +1)..' of '..monster.amount..' '..(monster.name or target:getName())..'s killed.', TALKTYPE_CHANNEL_O, 12)
    end
    if (stor +1) == monster.amount then
		member:sendChannelMessage('','[Access '..monster.nameQ..'] Congratulations, you have killed '..(stor +1)..' '..monster.name..'s and completed the '..monster.name..'s mission.', TALKTYPE_CHANNEL_R1, 12)
        member:setStorageValue(monster.storage, stor +1)
    end
        end
    end
    local leader = party:getLeader()
    if leader:getPosition():getDistance(target:getPosition()) <= 20 then
    local stor = leader:getStorageValue(monster.storage)+1
    if stor < monster.amount and leader:getStorageValue(monster.startstorage) >= monster.startvalue then
        leader:setStorageValue(monster.storage, stor)
 		leader:sendChannelMessage('','[Access '..monster.nameQ..'] '..(stor +1)..' of '..monster.amount..' '..(monster.name or target:getName())..'s killed.', TALKTYPE_CHANNEL_O, 12)
    end
    if (stor +1) == monster.amount then
		leader:sendChannelMessage('','[Access '..monster.nameQ..'] Congratulations, you have killed '..(stor +1)..' '..monster.name..'s and completed the '..monster.name..'s mission.', TALKTYPE_CHANNEL_R1, 12)
        leader:setStorageValue(monster.storage, stor +1)
    end
    end
else
   local stor = player:getStorageValue(monster.storage)+1
    if stor < monster.amount and player:getStorageValue(monster.startstorage) >= monster.startvalue then
        player:setStorageValue(monster.storage, stor)
 		player:sendChannelMessage('','[Access '..monster.nameQ..'] '..(stor +1)..' of '..monster.amount..' '..(monster.name or target:getName())..'s killed.', TALKTYPE_CHANNEL_O, 12)
    end
    if (stor +1) == monster.amount then
		player:sendChannelMessage('','[Access '..monster.nameQ..'] Congratulations, you have killed '..(stor +1)..' '..monster.name..'s and completed the '..monster.name..'s mission.', TALKTYPE_CHANNEL_R1, 12)
        player:setStorageValue(monster.storage, stor +1)
    end
end
    return true
end