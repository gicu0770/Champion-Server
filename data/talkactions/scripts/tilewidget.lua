function onSay(player, words, param)
  if not player:getGroup():getAccess() then
    return true
  end
  	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end
  if player:getAccountType() < ACCOUNT_TYPE_GOD then
    return false
  end
  local tile = Tile(player:getPosition())
  
  if param == "remove" then
    tile:removeWidget()
  else
    local data = {
      "5", -- | RARITY |
      "Cursed Strongbox", -- | TITLE |
      "Guarded by 3 {packs} of Monsters,#8888FF,red,true", -- | TEXT | COLOR | COLOR2 | SEP |
      "Dziku to kox, red",
      "Dziku to kox, blue",
      "Dziku to kox, green",
    }
    tile:setWidget(3, data)
  end

  return false
end