function onUse(player, item, fromPosition, target, toPosition, isHotkey)
  local portalId = getFreePortalId()
  if portalId ~= nil then
  
  
local dungeon = player:getDungeon()
if dungeon then
local instance = dungeon:getPlayerInstance(player)
	if instance then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You are in the dungeons, you cannot use the portal.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true
	end
end

  if player:getStorageValue(PlayerStorage.riftBlokade) == 1 then
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You are in Portal Realms, you cannot use the portal")
	  player:getPosition():sendMagicEffect(CONST_ME_POFF)
	  return false
  end
  
  
    local portalPos = getClosePosition(player:getPosition())
    if portalPos then
      local cid = player:getId()
      local town = player:getTown()
      if player:getPosition():getDistance(Position(711, 1034, 7)) <= 60 then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You are too close to the city.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return true
      end
	 if player:getSkull() == 3 then
	  player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You are in PvP combat, you cannot use the portal")
	  player:getPosition():sendMagicEffect(CONST_ME_POFF)
	  return false 
	 end
	 if player:hasBuff(PVP_CONDITION) then
	    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You are in PvP combat, you cannot use the portal")
      player:getPosition():sendMagicEffect(CONST_ME_POFF)
      return true 
	 end
      if TOWN_PORTALS_PLAYERS[cid] then
        local tempPortal = TOWN_PORTALS_ACTIVE[TOWN_PORTALS_PLAYERS[cid].portalId]
        if tempPortal and tempPortal.creator == cid then
          removePortal(cid)
        end
      end
      TOWN_PORTALS_PLAYERS[cid] = {}
      TOWN_PORTALS_PLAYERS[cid].portalId = portalId
	  local portalItem = nil
      if item:getId() == 6533 then
	  portalItem = Game.createItem(28302, 1, portalPos)
      portalItem:setActionId(5624)
	  elseif item:getId() == 35938 then
	  portalItem = Game.createItem(36879, 1, portalPos)
      portalItem:setActionId(5624)
	  elseif item:getId() == 15427 then
	  portalItem = Game.createItem(31101, 1, portalPos)
      portalItem:setActionId(5624)
	  elseif item:getId() == 15428 then
	  portalItem = Game.createItem(31100, 1, portalPos)
      portalItem:setActionId(5624)
	  
	  
	  
	  
	  
	  
	  end
--	  PortalEffects()

      TOWN_PORTALS_ACTIVE[portalId] = {}
      TOWN_PORTALS_ACTIVE[portalId].item = portalItem
      TOWN_PORTALS_ACTIVE[portalId].creator = cid
      TOWN_PORTALS_ACTIVE[portalId].town = town
      TOWN_PORTALS_ACTIVE[portalId].pos = player:getPosition()
      if TOWN_PORTALS.duration ~= -1 then
        TOWN_PORTALS_ACTIVE[portalId].event = addEvent(removePortal, TOWN_PORTALS.duration * 1000, cid)
      end
 --     player:removeItem(item:getId(), 1)
    else
      player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "No space to create portal. Please move somewhere else.")
      player:getPosition():sendMagicEffect(CONST_ME_POFF)
      return false
    end
  end
  return true
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