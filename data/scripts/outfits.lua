local footPrints = {
  [1] = {"Poison", 21, RARITYS_STORE.COMMON},
  [2] = {"Dice", 27, RARITYS_STORE.COMMON},
  [3] = {"Heart", 36, RARITYS_STORE.COMMON},

  [4] = {"Ice", 42, RARITYS_STORE.MAGIC},
  [5] = {"Bleeding", 94, RARITYS_STORE.MAGIC},
  [6] = {"Ghost", 66, RARITYS_STORE.MAGIC},
  [7] = {"Rainbow", 28, RARITYS_STORE.MAGIC},
  [8] = {"Smoke", 96, RARITYS_STORE.MAGIC},
  [9] = {"Stars", 32, RARITYS_STORE.MAGIC},
  [10] = {"Angel Shrine", 78, RARITYS_STORE.MAGIC},
  [11] = {"Black Devil", 79, RARITYS_STORE.MAGIC},
  [12] = {"Fire Shrine", 80, RARITYS_STORE.MAGIC},
  [13] = {"Fairy", 81, RARITYS_STORE.MAGIC},
  [14] = {"Grey Slush", 82, RARITYS_STORE.MAGIC},

  [15] = {"Rain of Stones", 45, RARITYS_STORE.RARE},
  [16] = {"Rain of Holy", 261, RARITYS_STORE.RARE},
  [17] = {"Frozen Ground", 475, RARITYS_STORE.LIMITED},
  [18] = {"Yellow Note", 22, RARITYS_STORE.RARE},
  [19] = {"Purple Note", 23, RARITYS_STORE.RARE},
  [20] = {"Blue Note", 24, RARITYS_STORE.RARE},
  [21] = {"White Note", 25, RARITYS_STORE.RARE},
  [22] = {"Plants", 46, RARITYS_STORE.RARE},
  
  [23] = {"Death", 200, RARITYS_STORE.LEGENDARY},
  [24] = {"Black Decay", 92, RARITYS_STORE.LEGENDARY},
  [25] = {"Dollar", 141, RARITYS_STORE.LEGENDARY},
  [26] = {"Bats", 67, RARITYS_STORE.LEGENDARY},
  [27] = {"Skeleton", 155, RARITYS_STORE.LEGENDARY},
  [28] = {"Medusa", 359, RARITYS_STORE.LEGENDARY},
  [29] = {"Rain Cloud", 206, RARITYS_STORE.LEGENDARY},
  [30] = {"Gold Coin", 405, RARITYS_STORE.LEGENDARY},
  [31] = {"Pentagram", 85, RARITYS_STORE.LEGENDARY},
  [32] = {"Rainbow", 148, RARITYS_STORE.LEGENDARY},
  [33] = {"Dark Hand", 180, RARITYS_STORE.RARE},
  [34] = {"Solari Steps", 360, RARITYS_STORE.LIMITED},
  [35] = {"Magma Steps", 220, RARITYS_STORE.LIMITED},
  [36] = {"Void Steps", 668, RARITYS_STORE.LIMITED},
  [37] = {"Void Skull", 666, RARITYS_STORE.LIMITED},
}

local portals = {
  [1] = {"Portal", 1387, 0, RARITYS_STORE.COMMON},
  [2] = {"Fire Portal", 28300, 0, RARITYS_STORE.COMMON},
  [3] = {"Golden Portal", 28302, 0, RARITYS_STORE.COMMON},
  [4] = {"Purple Portal", 28298, 0, RARITYS_STORE.COMMON},
  [5] = {"Green Portal", 28296, 0, RARITYS_STORE.COMMON},
  [6] = {"Gray Portal", 28294, 0, RARITYS_STORE.COMMON},
  
  [7] = {"Red Fiery Portal", 38160, 0, RARITYS_STORE.MAGIC},
  [8] = {"Gold Fiery Portal", 31100, 0, RARITYS_STORE.MAGIC},
  [9] = {"Blue Fiery Portal", 31101, 0, RARITYS_STORE.MAGIC},
  [10] = {"Otherworld Portal", 29724, 0, RARITYS_STORE.MAGIC},
  
  [11] = {"Purplelight Essence Portal", 37093, 0, RARITYS_STORE.NORMAL},
  
  [12] = {"Firelight Portal", 37094, 0, RARITYS_STORE.MAGIC},

  [13] = {"Crystal Gate", 34762, 0, RARITYS_STORE.RARE},
  [14] = {"Arcane Conduit", 34766, 0, RARITYS_STORE.RARE},
  
  [15] = {"Vortex Gate", 34761, 0, RARITYS_STORE.LEGENDARY},
  [16] = {"Hell Gate", 37108, 0, RARITYS_STORE.LEGENDARY},
  [17] = {"Poison Portal", 37100, 0, RARITYS_STORE.LEGENDARY},
  [18] = {"Flamebound Portal", 38215, 0, RARITYS_STORE.LIMITED},
  [19] = {"Blood Portal", 37099, 0, RARITYS_STORE.LIMITED},
  [20] = {"Hand Portal", 37101, 0, RARITYS_STORE.LIMITED},
}

for i = 1, #portals do
  local itemType = ItemType(portals[i][2])
  if itemType then
    portals[i][3] = itemType:getClientId()
  end
end

local PORTAL_EVENTS = {}

local LoginEvent = CreatureEvent("OutfitsLogin")
function LoginEvent.onLogin(player)
  player:setStorageValue(PlayerStorage.portals + 1, 1)
  player:registerEvent("OutfitsExtendedEvent")
  player:registerEvent("TownPortalHealthChange")
  return true
end

local ExtendedEvent = CreatureEvent("OutfitsExtendedEvent")
function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
  if opcode == ExtendedOPCodes.CODE_OUTFITS then
    local status, json_data =
      pcall(
      function()
        return json.decode(buffer)
      end
    )
    if not status then
      return false
    end

    if json_data.action == "open" then
      player:sendMissingOutfits()
    elseif json_data.action == "change" then
      local values = json_data.values
      if player:getAccountStorageValue(PlayerStorage.footPrints + values[1]) == 1 or values[1] == 0 then
        player:setStorageValue(PlayerStorage.footChoosen, values[1])
      end

      if player:getAccountStorageValue(PlayerStorage.portals + values[2]) == 1 or values[2] == 1 then
        player:setStorageValue(PlayerStorage.portalSelected, values[2])
      end
    elseif json_data.action == "tp" then
      if PORTAL_EVENTS[player:getId()] then
        return
      end
      if not player:checkBeforeTownPortal() then
        return
      end
      player:setProgressBar(2000, false)
      local pid = player:getId()
      PORTAL_EVENTS[player:getId()] = addEvent(function()
        local player = Player(pid)
        if player then
          player:openTownPortal()
        end
      end, 2000)
    end
  end
end

function Player:sendMissingOutfits()
  local missingOutfits = {
    footSelected = self:getStorageValue(PlayerStorage.footChoosen),
    portalSelected = self:getStorageValue(PlayerStorage.portalSelected),
    foot = {},
    portals = {},
  }
  for i = 1, #footPrints do
    local rarity = 0
    if footPrints[i][3] then
      rarity = footPrints[i][3]
    end
    local tempData = {i, footPrints[i][1], footPrints[i][2], self:getAccountStorageValue(PlayerStorage.footPrints + i) == 1, rarity}
    table.insert(missingOutfits.foot, tempData)
  end

  for i = 1, #portals do
    local unlocked = self:getAccountStorageValue(PlayerStorage.portals + i) == 1
    if i == 1 then
      unlocked = true
    end
    local rarity = 0
    if portals[i][4] then
      rarity = portals[i][4]
    end
    local tempData = {i, portals[i][1], portals[i][2], portals[i][3], unlocked, rarity}
    table.insert(missingOutfits.portals, tempData)
  end
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_OUTFITS, json.encode({action = "open", data = missingOutfits}))
end

function Player:showFootprint(position)
  if PORTAL_EVENTS[self:getId()] then
    stopEvent(PORTAL_EVENTS[self:getId()])
    PORTAL_EVENTS[self:getId()] = nil
    self:setProgressBar(0, false)
  end

  local footPrint = self:getStorageValue(PlayerStorage.footChoosen)
  if colleftInfo[self:getId()].attributesItems[52] then -- Evansion
    local buff = self:getBuff(EVANSION)
    if buff then
      if buff.stacks >= 10 then
        self:removeBuff(EVANSION)
      else
        self:addBuff(EVANSION)
      end
      else
        self:addBuff(EVANSION)
    end
  end

  if colleftInfo[self:getId()].attributesItems[172] then
    self:addBuff(FLEETFOOT)
    if self:getBuff(FLEETFOOT) then
      local hasteAdded = self:getBaseSpeed() * US_ENCHANTMENTS[172].subvalue / 100
      local conditionHaste = Condition(CONDITION_HASTE, CONDITIONID_DEFAULT)
      conditionHaste:setParameter(CONDITION_PARAM_SUBID, 777778)
      conditionHaste:setParameter(CONDITION_PARAM_TICKS, 1 * 1000) --2 secs
      conditionHaste:setFormula(0.0, hasteAdded, 0.0, hasteAdded)
      self:addCondition(conditionHaste)
      local conditionAS = Condition(CONDITION_ATTRIBUTES)
			conditionAS:setParameter(CONDITION_PARAM_SUBID, 712349)
			conditionAS:setParameter(CONDITION_PARAM_ATTACKSPEED, 15)
			conditionAS:setParameter(CONDITION_PARAM_TICKS, 3000)
			self:addCondition(conditionAS)
    end
  end

  if footPrint > 0 then
    local foot = footPrints[footPrint]
    if foot then
      position:sendMagicEffect(foot[2])
    end
  end
	return true
end

function Player:checkBeforeTownPortal()
  local player = self
  if player:hasCondition(CONDITION_SPELLCOOLDOWN, 999999) then 
    player:sendTextMessage(MESSAGE_STATUS_WARNING, "You are still exhausted.")
    return false
  end
  
  local portalId = getFreePortalId()
  if portalId == nil then
    player:sendTextMessage(MESSAGE_STATUS_WARNING, "We are sorry, but all portals are in use. Please try again later.")
    return false
  end

  if player:getStorageValue(PlayerStorage.riftBlokade) == 1 then
    player:sendTextMessage(MESSAGE_STATUS_WARNING, "You are in Portal Realms, you cannot use the portal")
	  return false
  end

  local portalPos = getClosePosition(player:getPosition())
  if not portalPos then
    player:sendTextMessage(MESSAGE_STATUS_WARNING, "No space to create portal. Please move somewhere else.")
    return false
  end

  local cid = player:getId()
  local town = player:getTown()
  if player:getPosition():getDistance(Position(691, 1035, 7)) <= 30 then
    player:sendTextMessage(MESSAGE_STATUS_WARNING, "You are too close to the city.")
    return false
  end

  if player:getSkull() == 3 then
    player:sendTextMessage(MESSAGE_STATUS_WARNING, "You are in PvP combat, you cannot use the portal")
    return false 
  end

  if player:hasBuff(PVP_CONDITION) then
    player:sendTextMessage(MESSAGE_STATUS_WARNING, "You are in PvP combat, you cannot use the portal")
    return false 
  end

  if player:getStorageValue(PlayerStorage.portalVoort) >= 1 then
    player:sendTextMessage(MESSAGE_STATUS_WARNING, "You are in Voort combat, you cannot use the portal")
    return false 
  end

  return true
end

function Player:openTownPortal()
  local player = self
  local cid = player:getId()
  local town = player:getTown()
  local portalId = getFreePortalId()
  local portalPos = getClosePosition(player:getPosition())
  if PORTAL_EVENTS[player:getId()] then
    stopEvent(PORTAL_EVENTS[player:getId()])
    PORTAL_EVENTS[player:getId()] = nil
    player:setProgressBar(0, false)
  end

  if not player:checkBeforeTownPortal() then
    return
  end

  if TOWN_PORTALS_PLAYERS[cid] then
    local tempPortal = TOWN_PORTALS_ACTIVE[TOWN_PORTALS_PLAYERS[cid].portalId]
    if tempPortal and tempPortal.creator == cid then
      removePortal(cid)
    end
  end

  TOWN_PORTALS_PLAYERS[cid] = {}
  TOWN_PORTALS_PLAYERS[cid].portalId = portalId

  local teleportCd = Condition(CONDITION_SPELLCOOLDOWN)
  teleportCd:setParameter(CONDITION_PARAM_TICKS, 2000)
  teleportCd:setParameter(CONDITION_PARAM_SUBID, 999999)
  player:addCondition(teleportCd)

  local id = player:getStorageValue(PlayerStorage.portalSelected)
  if id == -1 or id == 0 then
    id = 1 
    player:setStorageValue(PlayerStorage.portalSelected, id)
  end
  local portalItem = Game.createItem(portals[id][2], 1, portalPos)
  portalItem:setActionId(5624)

  TOWN_PORTALS_ACTIVE[portalId] = {}
  TOWN_PORTALS_ACTIVE[portalId].item = portalItem
  TOWN_PORTALS_ACTIVE[portalId].creator = cid
  TOWN_PORTALS_ACTIVE[portalId].town = town
  TOWN_PORTALS_ACTIVE[portalId].pos = player:getPosition()
  if TOWN_PORTALS.duration ~= -1 then
    TOWN_PORTALS_ACTIVE[portalId].event = addEvent(removePortal, TOWN_PORTALS.duration * 1000, cid)
  end
end

function getClosePosition(center)
  local position = nil
  local tile = nil

  for i = -1, 1 do
    position = Position(center.x + i, center.y, center.z)
    tile = Tile(position)
    if isFreeTile(tile) then return position end
  end

  for i = -1, 1 do
    position = Position(center.x, center.y + i, center.z)
    tile = Tile(position)
    if isFreeTile(tile) then return position end
  end

  return nil
end

function getFreePortalId()
  for i = 1, 255 do
    if not TOWN_PORTALS_ACTIVE[i] then
      return i
    end
  end
  return nil
end

function isFreeTile(tile)
	return not (tile == nil or tile:getGround() == nil or tile:hasProperty(TILESTATE_NONE) or tile:hasProperty(TILESTATE_FLOORCHANGE_EAST) or isItem(tile:getThing()) and not isMoveable(tile:getThing()) or tile:getTopCreature())
end

local HealthChangeEvent = CreatureEvent("TownPortalHealthChange")
function HealthChangeEvent.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, critical)

  if creature and attacker and creature ~= attacker then
    if PORTAL_EVENTS[creature:getId()] then
      stopEvent(PORTAL_EVENTS[creature:getId()])
      PORTAL_EVENTS[creature:getId()] = nil
      creature:setProgressBar(0, false)
    end
  end

  return primaryDamage, primaryType, secondaryDamage, secondaryType, origin
end

HealthChangeEvent:type("healthchange")
HealthChangeEvent:register()
LoginEvent:type("login")
LoginEvent:register()
ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()