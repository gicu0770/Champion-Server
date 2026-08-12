

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid)        npcHandler:onCreatureDisappear(cid)            end
function onThink()                        npcHandler:onThink()                        end

function onCreatureSay(cid, type, msg)
	if getDistanceBetween(getThingPos(cid), Creature(getNpcCid()):getPosition()) >= 5 then
		return false
	end
	npcHandler:onCreatureSay(cid, type, msg)
end

function creatureSayCallback(cid, type, msg)
	if (not npcHandler:isFocused(cid)) then
		return false
	end

	local player = Player(cid)
	if msgcontains(msg, "Forge with crystals") then
		selfSay("Place your item, and we will see if a crystal can be forged within it. Not all items are worthy.{Forge with crystals}{Ask about crystals}", cid)
		player:sendExtendedOpcode(ExtendedOPCodes.CODE_CRYSTALS, json.encode({4, 1}))
		return true
	end

	if msgcontains(msg, "Ask about crystals") then
		selfSay("Crystals are rare now, the mines are sealed. You can still find them, but only by defeating powerful creatures, like the Forgottens.{What does they do}{How to obtain them}{How to put it in item}{Forge with crystals}", cid)
		return true
	end

	if msgcontains(msg, "How to obtain them") then
		selfSay("Only strong creatures carry them now. Seek out the Forgottens or creatures even stronger. The more powerful the creature, the greater the crystal it may yield.{What does they do}{How to put it in item}{Forge with crystals}", cid)
		return true
	end

	if msgcontains(msg, "How to put it in item") then
		selfSay("Bring the crystal to me, and I can forge it into your item... for a fee, of course. Nothing of power comes without a price.{What does they do}{How to obtain them}{Forge with crystals}", cid)
		return true
	end

	if msgcontains(msg, "What does they do") then
		selfSay("Each crystal holds a unique energy. When forged into your item, it enchants it with different powers.{How to obtain them}{How to put it in item}{Forge with crystals}", cid)
		return true
	end

	return true
end

local function onReleaseFocus(cid)
	local player = Player(cid)
	if player then
		player:sendExtendedOpcode(ExtendedOPCodes.CODE_CRYSTALS, json.encode({4, 0}))
	end
	npcHandler:releaseFocus(cid)
end

npcHandler:setCallback(CALLBACK_ONRELEASEFOCUS, onReleaseFocus)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
