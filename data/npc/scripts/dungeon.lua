

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}

function onCreatureAppear(cid)            npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)        npcHandler:onCreatureDisappear(cid)            end
function onThink()                        npcHandler:onThink()                        end

function onCreatureSay(cid, type, msg)
	if getDistanceBetween(getThingPos(cid), Creature(getNpcCid()):getPosition()) >= 5 then
	return false
	end
	if msg == "hi" then
		cid:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "open", tier = cid:getDungeonTier()}))
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
	local talkUser = NPCHANDLER_CONVBEHAVIOR == CONVERSATION_PRIVATE and 0 or cid
	
	if table.contains({"dungeon", "dung"}, msg:lower()) then
		local player = Player(cid)
		player:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "open", tier = player:getDungeonTier()}))
		selfSay("There you can see the following dungeons.", cid)
	end

	return true
end

local function onReleaseFocus(cid)
	local player = Player(cid)
	if player then
		player:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "close"}))
	end
end

npcHandler:setCallback(CALLBACK_ONRELEASEFOCUS, onReleaseFocus)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
