local config = {
  [1] = {
    id = 37413,
  },
  [2] = {
    id = 37414,
  },
  [3] = {
    id = 37420,
  },
  [4] = {
    id = 37419,
  },
  [5] = {
    id = 37417,
  },
}

local OnOpenRewardChest = Action()
function OnOpenRewardChest.onUse(player, item)
  -- local realUID = item:getRealUID()
  -- sendCreatureCorpse(player, realUID, "Reward Chest")
  -- sendLoot(player, {}, realUID)
  item:getPosition():sendMagicEffect(3)
  item:remove()
  return true
end

for _, chest in ipairs(config) do 
  OnOpenRewardChest:id(chest.id)
end

OnOpenRewardChest:register()

