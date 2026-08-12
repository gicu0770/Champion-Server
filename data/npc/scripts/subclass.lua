local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)            npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)        npcHandler:onCreatureDisappear(cid)            end
function onCreatureSay(cid, type, msg)    npcHandler:onCreatureSay(cid, type, msg)    end
function onThink()                        npcHandler:onThink()    end

function creatureSayCallback(cid, type, msg)
    if not npcHandler:isFocused(cid) then
        return false
    end

	if msgcontains(msg, "Second Talent") then
		local player = Player(cid)
		if player:getStorageValue(999997) < 0 then -- Uklonczenie dunga
			selfSay("You not finish Otherworld Arena!", player)
		elseif player:getStorageValue(PlayerStorage.secondTalnet) >= 0 then -- jesli masz juz second talent
			selfSay("You got Second Talents!", player)
		elseif player:getStorageValue(999997) >= 0 then -- mozna wybrac second talent
			player:showSecondTalentSelector()
			player:sendCurrentTalents()
		else
			selfSay("You got Second Talents or you not finished Otherworld Arena!", player)
		end
	end 

	if msgcontains(msg, "Second Trait") then
		local player = Player(cid)
		if player:getStorageValue(PlayerStorage.trait) < 0 then
			selfSay("You have not finished the Frostbound Arena!", player) -- Ukonczony dung
		elseif player:getStorageValue(PlayerStorage.secondTrait) > 0 then
			selfSay("You already have a sub-trait", player) -- masz juz trait
		else
			player:showTraitSelector()
		end
	end

	if msgcontains(msg, "Subtalent Reset") then
		local player = Player(cid)
		if player:getStorageValue(PlayerStorage.voortResetTalent) <= 0 and player:getStorageValue(PlayerStorage.endGame) > 0  then -- Uklonczenie dunga
			player:showSecondTalentSelector()
			player:sendCurrentTalents()
			player:setStorageValue(PlayerStorage.voortResetTalent, 0)
		else
			selfSay("You can use the Subtalent Reset, but only after defeating Voort for the first time.", player)
		end
	end 

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())


