local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)            npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)        npcHandler:onCreatureDisappear(cid)            end
function onCreatureSay(cid, type, msg)    npcHandler:onCreatureSay(cid, type, msg)    end
function onThink()                        npcHandler:onThink()    end

local vocAfterPromo = {9, 10, 11, 12}
function creatureSayCallback(cid, type, msg)
    if not npcHandler:isFocused(cid) then
        return false
    end
------------------------------------------FIRST------------------------------------------------
if msgcontains(msg, "vocation fusion") then
    local player = Player(cid)
	if player:getStorageValue(PlayerStorage.reborn) >= 1 and player:getStorageValue(PlayerStorage.subTalents) < 0 then
	 player:getPosition():sendMagicEffect(CONST_ME_FIREWORK_BLUE)
	 player:getPosition():sendMagicEffect(50)
	 
	player:registerEvent("ModalWindow_Tutorial")
	local vocName = player:getVocation():getName()
    local title = "Pick your new Talent!"
    local message = "Congratulations!\nChoose the vocation you want to have talents!"
    local window = ModalWindow(1005, title, message)
    window:addButton(100, "Confirm")
	if not player:isSorcerer() then
    window:addChoice(1, "Sorcerer")
	end
	if not player:isDruid() then
    window:addChoice(2, "Druid")
	end
	if not player:isArcher() then
    window:addChoice(3, "Archer")
	end
	if not player:isKnight() then
    window:addChoice(4, "Knight")
	end
	if not player:isPaladin() then
    window:addChoice(17, "Paladin")
	end
	if not player:isShadow() then
    window:addChoice(21, "Shadow")
	end
    window:setDefaultEnterButton(100)
    window:sendToPlayer(player)
	
	else
	 selfSay("You dont have Second Promotion or you have Fusion!", cid)
	end
end --slowo
if msgcontains(msg, "fusion info") then
 selfSay("If you complete the Flame Cave Dungeon, you gain an additional Sub Talents tree from another vocations.!\nIf we connect with a different vocation we get a new bonus.\nAnd completing the Undead Cave Dungeon grants you a Traits from another vocations.", cid)
end
if msgcontains(msg, "trait info") then
 selfSay("Check out the wiki on our website!\nWe choose a passive bonus of another vocation which is at level 3.", cid)
end

if msgcontains(msg, "trait") then
    local player = Player(cid)
	if player:getStorageValue(PlayerStorage.reborn) == 2 and player:getStorageValue(PlayerStorage.subTrait) < 0 then
	 player:getPosition():sendMagicEffect(CONST_ME_FIREWORK_BLUE)
	 player:getPosition():sendMagicEffect(50)
	 
	player:registerEvent("ModalWindow_Third_Promotion")
	local vocName = player:getVocation():getName()
    local title = "Pick your new Vocation Trait!"
    local message = "Congratulations!\nChoose the Vocation Trait you want to have!"
    local window = ModalWindow(1006, title, message)
    window:addButton(100, "Confirm")
	if not player:isSorcerer() then
    window:addChoice(1, "Sorcerer")
	end
	if not player:isDruid() then
    window:addChoice(2, "Druid")
	end
	if not player:isArcher() then
    window:addChoice(3, "Archer")
	end
	if not player:isKnight() then
    window:addChoice(4, "Knight")
	end
	if not player:isPaladin() then
    window:addChoice(17, "Paladin")
	end
	if not player:isShadow() then
    window:addChoice(21, "Shadow")
	end
	window:setDefaultEnterButton(100)
    window:sendToPlayer(player)
	
	else
	 selfSay("You dont have Third Promotion or you have New Trait!", cid)
	end
end --slowo

---end script
    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())