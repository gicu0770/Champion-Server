local TOWN_PORTALS_VERSION = "1.0.1"

TOWN_PORTALS = {
  creatorOnly = true, -- only portal creator can teleport back to town
  creatorDestroy = true, -- remove Town Portal only when creator teleports back, false = destroy portal when any player teleports back
  duration = 300, -- in seconds, for how long should created portal be active, -1 = unlimited
  townText = "Town Portal", -- Text on the portal in a town, nil = nothing
  portalText = nil, -- text on the portal create by a player, nil = Town Name
  townPortals = { -- list of Town Portals in towns that are used to teleport back to player portal
    Position(691, 1035, 7)
  }
}

TOWN_PORTALS_ACTIVE = {}
TOWN_PORTALS_PLAYERS = {}

function onStepIn(player, item, position, fromPosition)
  if player:isPlayer() then
    local cid = player:getId()
    if item.actionid == 5623 then
      if TOWN_PORTALS_PLAYERS[cid] then
        local portalId = TOWN_PORTALS_PLAYERS[cid].portalId
        local portal = TOWN_PORTALS_ACTIVE[portalId]
        if portal then
          player:teleportTo(portal.pos)
          player:getPosition():sendMagicEffect(CONST_ME_ENERGYAREA)
          if TOWN_PORTALS.creatorDestroy == true then
            if portal.creator == cid then
              removePortal(cid)
            end
          else
            removePortal(cid)
          end
        end
      else
        player:teleportTo(fromPosition, true)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "There are no active Town Portals for you.")
      end
    elseif item.actionid == 5624 then
      if TOWN_PORTALS.creatorOnly == true then
	  local dungeon = player:getDungeon()
		if dungeon then
		local instance = dungeon:getPlayerInstance(player)
			if instance then
        dungeon:onPlayerLeave(player, true)
        removePortal(player:getId())
        player:teleportTo(Position(691, 1035, 7))
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You back to town and left dungeon!")
        return true
			end
		end
    if player:getStorageValue(PlayerStorage.riftBlokade) == 1 then
      player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You are in Portal Realms, you cannot use the portal")
      player:getPosition():sendMagicEffect(CONST_ME_POFF)
      player:teleportTo(fromPosition, true)
      return false
    end
        if not TOWN_PORTALS_PLAYERS[cid] then
          player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "This is not your Town Portal.")
        --  player:teleportTo(fromPosition, true)
          return false
        else
          local portal = TOWN_PORTALS_ACTIVE[TOWN_PORTALS_PLAYERS[cid].portalId]
          if portal.item:getPosition() ~= position then
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "This is not your Town Portal.")
         --   player:teleportTo(fromPosition, true)
            return false
          end
        end
		 if player:hasBuff(PVP_CONDITION) then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You are in PvP combat, you cannot use the portal")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false 
		 end
		 if player:getSkull() == 3 then
		   player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You are in PvP combat, you cannot use the portal")
		   player:getPosition():sendMagicEffect(CONST_ME_POFF)
		  return false 
		 end
        local portal = TOWN_PORTALS_ACTIVE[TOWN_PORTALS_PLAYERS[cid].portalId]
        if portal then
          player:teleportTo(Position(691, 1035, 7))
          player:getPosition():sendMagicEffect(CONST_ME_ENERGYAREA)
          return
        end
      else
        for i = 1, #TOWN_PORTALS_ACTIVE do
          local portal = TOWN_PORTALS_ACTIVE[i]
          if portal then
            if portal.item:getPosition() == position then
              if TOWN_PORTALS_PLAYERS[cid] then
                local tempPortal = TOWN_PORTALS_ACTIVE[TOWN_PORTALS_PLAYERS[cid].portalId]
                if tempPortal and portal ~= tempPortal and tempPortal.creator == cid then
                  removePortal(cid)
                end
              end
              if portal.creator ~= cid then
                TOWN_PORTALS_PLAYERS[cid] = {}
                TOWN_PORTALS_PLAYERS[cid].portalId = i
              end
              
              player:teleportTo(Position(691, 1035, 7))
              player:getPosition():sendMagicEffect(CONST_ME_ENERGYAREA)
              break
            end
          end
        end
      end
    end
  end
end

function removePortal(cid)
  TOWN_PORTALS_ACTIVE[TOWN_PORTALS_PLAYERS[cid].portalId].item:remove()
  if TOWN_PORTALS_ACTIVE[TOWN_PORTALS_PLAYERS[cid].portalId].event then
    stopEvent(TOWN_PORTALS_ACTIVE[TOWN_PORTALS_PLAYERS[cid].portalId].event)
  end
  TOWN_PORTALS_ACTIVE[TOWN_PORTALS_PLAYERS[cid].portalId] = nil
  TOWN_PORTALS_PLAYERS[cid] = nil
end
