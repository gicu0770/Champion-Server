SPELL_CACHE = {}
POTION_CONFIG = {}
SPELLS = {}
POTIONS = {}
local healthCast = {}

-- Global table for tracking combat objects that need cleanup per player
-- This allows proper cleanup when players logout
SPELL_COMBATS_TO_REMOVE = {}

local LoginEvent = CreatureEvent("SpellsLogin")
function LoginEvent.onLogin(player)
  player:registerEvent("SpellsExtendedEvent")
  player:registerEvent("SpellHealthChangeEvent")
  player:registerEvent("SpellEndScriptOnEndMana")
  player:registerEvent("SpellMinusRegenHp")
  -- player:registerEvent("SpellsReconnect")
  for i = 1, 4 do
    local item = player:getSlotItem(11+i)
    if item then
      local name = item:getSpellName()
      local SPELL = SPELLS[name]
      if SPELL then
        if SPELL.disable then
          SPELL.disable(player, item)
        end
        local playerId = player:getId()
        local realUID = item:getRealUID()
        addEvent(function()
          local item = Game.getRealUniqueItem(realUID)
          if not item then return end
          item:applySupportSpells(SPELL:getConfig(), playerId)
        end, 200)
      end
    end
  end

  return true
end

local ReconnectEvent = CreatureEvent("SpellsReconnect")
function ReconnectEvent.onReconnect(player)
  for i = 1, 4 do
    local item = player:getSlotItem(11+i)
    if item then
      local name = item:getSpellName()
      local SPELL = SPELLS[name]
      if SPELL and SPELL.isActive and SPELL.isActive(player) then
        player:sendExtendedOpcode(ExtendedOPCodes.CODE_CASTSPELL, json.encode({slot = i, enabled = true}))
      end
    end
  end
  return true
end

local LogoutEvent = CreatureEvent("SpellsLogout")
function LogoutEvent.onLogout(player)
  local playerId = player:getId()
  healthCast[playerId] = nil
  
  -- Clean up spell items
  for i = 1, 4 do
    local item = player:getSlotItem(11+i)
    if item then
      local name = item:getSpellName()
      local SPELL = SPELLS[name]
      if SPELL and SPELL.disable then
        SPELL.disable(player, item)
      end
      -- Clear spell cache for this item
      SPELL_CACHE[item:getRealUID()] = nil
    end
  end
  
  -- Clean up any accumulated combat objects for this player
  if SPELL_COMBATS_TO_REMOVE[playerId] then
    if SPELL_COMBATS_TO_REMOVE[playerId].combats then
      for i = 1, #SPELL_COMBATS_TO_REMOVE[playerId].combats do
        local combat = SPELL_COMBATS_TO_REMOVE[playerId].combats[i]
        if combat then
          pcall(function() combat:delete() end)
        end
      end
    end
    SPELL_COMBATS_TO_REMOVE[playerId] = nil
  end
  
  return true
end

function addHealthCast(id, value, force)
  healthCast[id] = healthCast[id] and healthCast[id] + value or value
  local player = Player(id)
  if not player or not player:isPlayer() then
    return
  end
  local amountToCast = player:getMaxHealth() * 0.001
  local amountToCastES = player:getMaxEnergyShield() * 0.001
  local castH = math.max(amountToCast, amountToCastES)
  if healthCast[id] <= (-castH) and not force then
    player:autoCastSpell(3)
    healthCast[id] = 0
  end
end

local ExtendedEvent = CreatureEvent("SpellsExtendedEvent")
function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
  local status, data = pcall(function()
    return json.decode(buffer)
  end)

  if not status then
    return false
  end

  if opcode == ExtendedOPCodes.CODE_CASTSPELL then
    if data[1] > 4 then 
      player:usePotion(data[1]-4)
      return
    end

    local pos = nil
    if data[2] then
      pos = Position(data[2].x, data[2].y, data[2].z)
    end
    player:castSpell(data[1], pos)
    return
  end
end

function Player:sendMarketSpellTooltip(data, spellName)
  local item = Game.createItem(data.id)
  if not item then
    return false
  end

  item:setRealUID(0)
  item:setRarity(data.r or 0)
  item:setCustomAttribute("level", data.sl or 1)
  local SPELL = SPELLS[spellName]
  if not SPELL then
    item:remove()
    return false
  end

  local infoToSend = SPELL.getInfo(self, item)
  if not infoToSend then
    item:remove()
    return false
  end
  item:remove()

  if GLOBAL_SPELL_COOLDOWNS[SPELL.spellId] and GLOBAL_SPELL_COOLDOWNS[SPELL.spellId].tag then
    infoToSend.tag = GLOBAL_SPELL_COOLDOWNS[SPELL.spellId].tag
  end
  infoToSend.sx = data.sx or 0
  infoToSend.sl = data.sl or 1
  infoToSend.mx = data.mx or 100
  infoToSend.cs = data.cs or 0
  infoToSend.cm = data.cm or nil
  infoToSend.gp = data.gp or 0
  self:sendExtendedOpcode(106, json.encode({3, infoToSend}))
  return true
end

function Player:sendSpellTooltip(item, floor)
  if not item then
    return false
  end

  local name = item:getSpellName()
  local SPELL = SPELLS[name]
  if not SPELL then
    return false
  end

  local infoToSend = SPELL.getInfo(self, item)
  if not infoToSend then
    return false
  end
  if GLOBAL_SPELL_COOLDOWNS[SPELL.spellId] and GLOBAL_SPELL_COOLDOWNS[SPELL.spellId].tag then
    infoToSend.tag = GLOBAL_SPELL_COOLDOWNS[SPELL.spellId].tag
  end
  infoToSend.fl = floor
  infoToSend.sx = item:getCustomAttribute("exp") or 0
  infoToSend.sl = item:getCustomAttribute("level") or 1

  local tier = self:getDungeonTier()
  if tier < 0 then
    tier = 0
  end

  infoToSend.mx = 100 + (tier * 2)
  infoToSend.mx = math.min(infoToSend.mx, 500)

  infoToSend.cs = item:getCrystalSlots()
  if infoToSend.cs and infoToSend.cs > 0 then
    infoToSend.cm = item:getBonusFromCrystals() or nil
  end

  infoToSend.gp = item:calculateItemCost()

  self:sendExtendedOpcode(106, json.encode({3, infoToSend}))
  return true
end

function Player:castSpell(id, pos, force)
  local item = self:getSlotItem(11+id)
  if not item then
    return
  end

  local name = item:getSpellName()
  local SPELL = SPELLS[name]
  if not SPELL then
    return
  end

  SPELL.cast(self, item, force, pos)
end

function Player:usePotion(id)
  local item = self:getSlotItem(15+id)
  if not item then
    return
  end

  local name = item:getPotionName()
  local POTION = POTIONS[name]
  if not POTION then
    return
  end

  self:autoCastSpell(4)
  POTION.use(self, item, id)
end

local EndScriptOnEndMana = CreatureEvent("SpellEndScriptOnEndMana")
function EndScriptOnEndMana.onEndScriptsRegen(player, health)
  if player then
    for i = 1, 4 do
      local item = player:getSlotItem(11+i)
      if item then
        local name = item:getSpellName()
        local SPELL = SPELLS[name]
        if SPELL then
          local data = SPELL_CACHE[item:getRealUID()]
          if SPELL.overTimeMana and data and data.lifeTap == health then
            SPELL.disable(player, item)
          end
        end
      end
    end
  end
end


-- local MinusRegenHp = CreatureEvent("SpellMinusRegenHp")
-- function MinusRegenHp.onMinusRegenHP(player, value)
--   player:autoCastSpell(3)
-- end

function Player:autoCastSpell(cast)
  for i = 1, 4 do
    local item = self:getSlotItem(11+i)
    if item then
      local sup_config = SPELL_CACHE[item:getRealUID()]
      if sup_config and sup_config.cast then
        if sup_config.cast == cast then
          self:castSpell(i, nil, true)
        end
      end 
    end
  end
end

local HealthChangeEvent = CreatureEvent("SpellHealthChangeEvent")
function HealthChangeEvent.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, critical)
  if origin == ORIGIN_AUTOCAST then
    return primaryDamage, primaryType, secondaryDamage, secondaryType, origin
  end

  if attacker and attacker:isPlayer() and critical then
    attacker:autoCastSpell(1)
  end
  if creature and creature:isPlayer() then
    local dmg = primaryDamage + secondaryDamage
    if dmg < 0 then
      creature:autoCastSpell(3)
    end
  end

  return primaryDamage, primaryType, secondaryDamage, secondaryType, origin
end


-- MinusRegenHp:type("minusregenhp")
-- MinusRegenHp:register()
HealthChangeEvent:type("healthchange")
HealthChangeEvent:register()
EndScriptOnEndMana:type("endscriptsregen")
EndScriptOnEndMana:register()
LogoutEvent:type("logout")
LogoutEvent:register()
ReconnectEvent:type("reconnect")
ReconnectEvent:register()
LoginEvent:type("login")
LoginEvent:register()
ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()