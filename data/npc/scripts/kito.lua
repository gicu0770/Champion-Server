local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}

local ACTIONS = {
	OPEN = 7,
	CLOSE = 8,
}

function onCreatureAppear(cid)
	npcHandler:onCreatureAppear(cid)
end

function onCreatureDisappear(cid)
	npcHandler:onCreatureDisappear(cid)
end

function onThink()
	npcHandler:onThink()
end

function onCreatureSay(cid, type, msg)
	if getDistanceBetween(getThingPos(cid), Creature(getNpcCid()):getPosition()) >= 5 then
		return false
	end

	local lowerMsg = msg:lower()
	if lowerMsg == "hi" or lowerMsg == "hello" then
		local player = Player(cid)
		if player then
			player:sendExtendedOpcode(ExtendedOPCodes.CODE_ROCOMBOBULATOR, json.encode({ACTIONS.OPEN}))
		end
	end

	npcHandler:onCreatureSay(cid, type, msg)
end

function creatureSayCallback(cid, type, msg)
	if (not npcHandler:isFocused(cid)) then
		return false
	end

	if getDistanceBetween(getThingPos(cid), Creature(getNpcCid()):getPosition()) >= 5 then
		return false
	end

	local lowerMsg = msg:lower()
	if string.find(lowerMsg, "fusion") or string.find(lowerMsg, "altar") or string.find(lowerMsg, "combine") or string.find(lowerMsg, "open") then
		local player = Player(cid)
		if player then
			player:sendExtendedOpcode(ExtendedOPCodes.CODE_ROCOMBOBULATOR, json.encode({ACTIONS.OPEN}))
			selfSay("Here is the Fusion Altar. Place your items to fuse them.", cid)
		end
		return true
	end

	return true
end

local function onReleaseFocus(cid)
	local player = Player(cid)
	if player then
		player:sendExtendedOpcode(ExtendedOPCodes.CODE_ROCOMBOBULATOR, json.encode({ACTIONS.CLOSE}))
	end
	npcHandler:releaseFocus(cid)
end

npcHandler:setCallback(CALLBACK_ONRELEASEFOCUS, onReleaseFocus)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
