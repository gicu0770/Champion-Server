function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end
local start = 1
for i = 1, 15 do
	  start = start + 1
	local dataPos = player:getPosition()
	local from = Position(dataPos.x - 5, dataPos.y - 5, dataPos.z)
	local to = Position(dataPos.x + 5, dataPos.y + 5, dataPos.z)
	
	local spawnPos = Position(math.random(from.x, to.x), math.random(from.y, to.y), dataPos.z)
	local tile = Tile(spawnPos)
	local spawnTest = 0
	 while spawnTest < 100 do
	  if dataPos == spawnPos or isBadTileOEN(tile) then
	   spawnPos = Position(math.random(from.x, to.x), math.random(from.y, to.y), dataPos.z)
	   tile = Tile(spawnPos)
	   spawnTest = spawnTest + 1
	 else
	  break
	 end
	end
	
	if spawnTest < 100 then
	local function boxCreate(cid)
	 local player = Player(cid)
	 if player then
	  local monster = Game.createMonster("Demon", spawnPos, true)
	  if monster then
	   monster:setStorageValue(PlayerStorage.strongBoxMonster, monsterAffix)
	   monster:registerEvent("StrongBox")
	   monster:getPosition():sendMagicEffect(11)
	  end
	 end
	end
	 
	 addEvent(boxCreate, start * 200, player.uid)
	end
	
	end

    return false
end