function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
  if not creature or not attacker then
     return primaryDamage, primaryType, secondaryDamage, secondaryType
   end
   if creature:isPlayer() and creature:getParty() and attacker:isPlayer() and attacker:getParty() then
     if creature:getParty() == attacker:getParty() then
       return primaryDamage, primaryType, secondaryDamage, secondaryType
     end
   end
 
   if primaryType == COMBAT_LIFEDRAIN or secondaryType == COMBAT_LIFEDRAIN then
     return primaryDamage, primaryType, secondaryDamage, secondaryType
   end
 
   if creature == attacker and primaryType ~= COMBAT_HEALING then
     return primaryDamage, primaryType, secondaryDamage, secondaryType
   end
 
   return endlessMobs_onDamaged(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
 end
 
 function onManaChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
   if not creature or not attacker then
     return primaryDamage, primaryType, secondaryDamage, secondaryType
   end
 
   if creature:isPlayer() and creature:getParty() and attacker:isPlayer() and attacker:getParty() then
     if creature:getParty() == attacker:getParty() then
       return primaryDamage, primaryType, secondaryDamage, secondaryType
     end
   end
 
   if primaryType == COMBAT_LIFEDRAIN or secondaryType == COMBAT_LIFEDRAIN then
     return primaryDamage, primaryType, secondaryDamage, secondaryType
   end
 
   if primaryType == COMBAT_MANADRAIN or secondaryType == COMBAT_MANADRAIN then
     return primaryDamage, primaryType, secondaryDamage, secondaryType
   end
 
   if creature == attacker and primaryType ~= COMBAT_HEALING then
     return primaryDamage, primaryType, secondaryDamage, secondaryType
   end
   
   return endlessMobs_onDamaged(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
 end
 
 function endlessMobs_onDamaged(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
   if attacker:isPlayer() then --  redukcja obrazen MOBY
     local damageReductionBoost = 0.1
     if creature:getStorageValue(PlayerStorage.endlesscoruptMobs) == 1 then damageReductionBoost = damageReductionBoost * 2 end
     local skull = creature:getSkull()
     local primalTotal = 0
     local secondaryTotal = 0
     local floorLevel = creature:getStorageValue(PlayerStorage.endlessBoss) --creature:getFloor() --creature:getStorageValue(PlayerStorage.endlessBoss)
     if floorLevel > 0 then
       primalTotal = primalTotal + (floorLevel * damageReductionBoost + 1)
       secondaryTotal = secondaryTotal + (floorLevel * damageReductionBoost + 1)
     end
     --[[
     local redu10time = true
     if redu10time then
       primaryDamage = math.floor(primaryDamage - (primaryDamage * 50 / 100))
     end
     if redu10time then
       secondaryDamage = math.floor(secondaryDamage - (secondaryDamage * 50 / 100))
     end
      --]]
    if floorLevel > 0 then
     if primalTotal ~= 0 then
     primaryDamage = math.floor(primaryDamage - (primaryDamage * primalTotal / 100))
     end
    end
     ---END attack:isPlayer() -- celem jest elite monster
   end 
 
   if creature:isPlayer() then --  zwiekszenie attacku
     local damageBoost = 10
     if attacker:getStorageValue(PlayerStorage.endlesscoruptMobs) == 1 then damageBoost = damageBoost * 9 end
     local skull = attacker:getSkull()
     local primalTotal = 0
     local secondaryTotal = 0
     local floorLevel = attacker:getStorageValue(PlayerStorage.endlessBoss) -- attacker:getFloor() -- attacker:getStorageValue(PlayerStorage.endlessBoss)
     if floorLevel > 0 then
       primaryDamage = math.floor(primaryDamage + (primaryDamage * (floorLevel * damageBoost) / 100))
      local damage = primaryDamage
      if damage < 0 then
      damage = damage * -1
      end
      local dmgRedu = damage - creature:getTotalArmor()
      if dmgRedu < 0 then
        dmgRedu = 1
      end
      primaryDamage = dmgRedu
     end

    local manaDamage = false
    if creature:isPlayer() then
    if creature:hasBuff(UTAMO_VITA) then
      manaDamage = true
    end
    if creature:hasBuff(UTAMO_VITA_TALENT) then
      manaDamage = true
    end

    if manaDamage then
     if creature:getMana() >= (creature:getMaxMana() * 0.05) then
      local damage = (primaryDamage + secondaryDamage)
      if damage < 0 then
       damage = damage * -1
      end
       creature:addMana(-damage, true)
       primaryDamage = 0
       secondaryDamage = 0
      end
     end
    end
 
     ---END creature:isPlayer() celem jest gracz
     if creature:isPlayer() then
       if creature:getStorageValue(PlayerStorage.damageTakenInfo) == 1 then
       local reductionEndlessarena = attacker:getStorageValue(PlayerStorage.endlessBoss) -- attacker:getFloor()
       local endTotal = reductionEndlessarena * 0.2
       if origin == ORIGIN_RANGED or origin == ORIGIN_MELEE or origin == ORIGIN_WAND then
         if primaryType == COMBAT_PHYSICALDAMAGE then
           if reductionEndlessarena > 0 then
             creature:sendChannelMessage("", "[Basic Damage] [Type Physical]\n> Endlessarena Damage Reduction: +"..endTotal.."% ["..primaryDamage.."]", TALKTYPE_CHANNEL_Y, 18)
           end
         else
           if reductionEndlessarena > 0 then
             creature:sendChannelMessage("", "[Basic Damage] [Type Elemental]\n> Endlessarena Damage Reduction: +"..endTotal.."% ["..primaryDamage.."]", TALKTYPE_CHANNEL_Y, 18)
           end
         end
       end
         
       if origin == ORIGIN_SPELL then
         if primaryType == COMBAT_PHYSICALDAMAGE then
           if reductionEndlessarena > 0 then
             creature:sendChannelMessage("", "[Spell Damage] [Type Physical]\n> Endlessarena Damage Reduction: +"..endTotal.."% ["..primaryDamage.."]", TALKTYPE_CHANNEL_Y, 18)
           end
         else
           if reductionEndlessarena > 0 then
             creature:sendChannelMessage("", "[Spell Damage] [Type Elemental]\n> Endlessarena Damage Reduction: +"..endTotal.."% ["..primaryDamage.."]", TALKTYPE_CHANNEL_Y, 18)
           end
         end
       end
     end
   end
 end
 
     return primaryDamage, primaryType, secondaryDamage, secondaryType, origin
 end