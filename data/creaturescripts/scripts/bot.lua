local STORAGESx = {
    PlayerStorage.autolootActive, 
    PlayerStorage.autolootrarityActivated,	-- rarity
    PlayerStorage.autolootindifityActivated, -- indification
}

function onExtendedOpcode(player, opcode, buffer)
    if opcode == 220 then
      local status, json_data =
      pcall(
        function()
          return json.decode(buffer)
        end
      )
      if not status then
        return false
      end
      
      if json_data.action == "OPEN" then
        GetStorageBot(player)
        return true
      elseif json_data.action == "SET" then
        player:setStorageValue(STORAGESx[json_data.ID[1]], json_data.ID[2])
        GetStorageBot(player)
        return true
      end
    end
    return false
  end

function GetStorageBot(player)
  local datax = {}
  for i = 1, #STORAGESx do
      local storage = player:getStorageValue(STORAGESx[i])
      if i == 1 then
        if storage > 0 then storage = true else storage = false end
      elseif i == 2 then
        if player:getStorageValue(PlayerStorage.autolootrarity) >= os.time() then
          if storage > 0 then storage = true else storage = false end
        else
          storage = false
        end
      elseif i == 3 then
        if player:getStorageValue(PlayerStorage.autolootindifity) >= os.time() then
          if storage > 0 then storage = true else storage = false end
        else
          storage = false
        end
      end
      table.insert(datax, storage)
  end
  player:sendExtendedOpcode(220, json.encode({action = "OPEN", data = datax}))
end