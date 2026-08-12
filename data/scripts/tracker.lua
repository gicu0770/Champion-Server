local MAX_QUESTS = 100

local NOT_STARTED_QUEST = 0
local STARTED_QUEST = 1
local COMPLETED_QUEST = 2
local FAILED_QUEST = 3

local LoginEvent = CreatureEvent("TrackerLogin")
function LoginEvent.onLogin(player)
  player:registerEvent("TrackerReconnectEvent")
  player:sendActiveQuests()
  player:sendWaypointsBosses()
  player:sendExtendedOpcode(ExtendedOPCodes.CODE_INSPECT, json.encode({block =  player:getStorageValue(PlayerStorage.inspectable)}))
  return true
end

function Player:sendWaypointsBosses()
  local dataWidgetsData = {}
  for i = 1, #UNIQUE_BOSS_STORAGES do
    dataWidgetsData[i] = self:getStorageValue(UNIQUE_BOSS_STORAGES[i])
  end

  self:sendExtendedOpcode(ExtendedOPCodes.CODE_WAYPOINTS, json.encode({4, dataWidgetsData}))
end

local ReconnectEvent = CreatureEvent("TrackerReconnectEvent")
function ReconnectEvent.onReconnect(player)
  player:sendActiveQuests()
  player:sendWaypointsBosses()
  player:sendExtendedOpcode(ExtendedOPCodes.CODE_INSPECT, json.encode({block =  player:getStorageValue(PlayerStorage.inspectable)}))
  return true
end

local ExtendedEvent = CreatureEvent("TrackerExtendedOpcode")
function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
  if opcode ~= ExtendedOPCodes.CODE_QUESTTRACKER then return false end
  local status, data = pcall(function() return json.decode(buffer) end)
  if not status then return false end

end

function Player:sendActiveQuests()
  local trackedQuests = {}
  local activeQuests = self:getStorageValue(PlayerStorage.QuestTrackerActive)
  if activeQuests ~= nil and activeQuests > 0 then
    for i = 1, activeQuests do
      local trackedQuest = self:getStorageValue(PlayerStorage.QuestTracked + i)
      if trackedQuest ~= nil and trackedQuest > 0 then
        table.insert(trackedQuests, trackedQuest)
      end
    end
  end

  self:sendExtendedOpcode(ExtendedOPCodes.CODE_QUESTTRACKER, json.encode({1, trackedQuests}))
end

function Player:startQuest(id)
  if id < 1 or id > MAX_QUESTS then
    print("QuestTracker: Invalid quest id:", id)
    return
  end

  if self:completedQuest(id) or self:isQuestAlreadyActive(id) then
    return
  end

  local trackCount = self:getStorageValue(PlayerStorage.QuestTrackerActive) + 1
  if trackCount <= 0 then
    trackCount = 1
  end

  self:setStorageValue(PlayerStorage.QuestTrackerActive, trackCount)
  self:setStorageValue(PlayerStorage.QuestTracked + trackCount, id)

  self:setStorageValue(PlayerStorage.QuestStatus + id, STARTED_QUEST)
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_QUESTTRACKER, json.encode({2, id}))
end

function Player:finishQuest(id)
  if self:completedQuest(id) then
    print("Trying to finish completed quest: " .. id)
    return
  end

  local activeQuests = self:getStorageValue(PlayerStorage.QuestTrackerActive)
  for i = 1, activeQuests do
    local trackedQuest = self:getStorageValue(PlayerStorage.QuestTracked + i)
    if trackedQuest == id then
      for j = i, activeQuests - 1 do
        local nextQuest = self:getStorageValue(PlayerStorage.QuestTracked + j + 1)
        self:setStorageValue(PlayerStorage.QuestTracked + j, nextQuest)
      end
      self:setStorageValue(PlayerStorage.QuestTracked + activeQuests, -1)
      break
    end
  end

  self:setStorageValue(PlayerStorage.QuestTrackerActive, activeQuests - 1)
  self:setStorageValue(PlayerStorage.QuestTracked + activeQuests, -1)

  self:setStorageValue(PlayerStorage.QuestStatus + id, COMPLETED_QUEST)
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_QUESTTRACKER, json.encode({3, id}))
end

function Player:completedQuest(id)
  return self:getStorageValue(PlayerStorage.QuestStatus + id) == COMPLETED_QUEST
end

function Player:isQuestAlreadyActive(id)
  return self:getStorageValue(PlayerStorage.QuestStatus + id) == STARTED_QUEST
end

function Player:resetQuest(id)
  self:setStorageValue(PlayerStorage.QuestStatus + id, NOT_STARTED_QUEST)
  self:startQuest(id)
end

LoginEvent:type("login")
LoginEvent:register()

ReconnectEvent:type("reconnect")
ReconnectEvent:register()

ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()