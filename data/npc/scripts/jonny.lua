local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)              npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)           npcHandler:onCreatureDisappear(cid)         end
function onThink()                          npcHandler:onThink()                        end
function onPlayerSellMultiple(cid, items)   npcHandler:onPlayerSellMultiple(cid, items) end

local function onTradeRequest(cid)
    return true
end

local shopModule = ShopModule:new()
npcHandler:addModule(shopModule)

function onAddFocus(cid)
    npcHandler:addFocus(cid)
    shopModule.requestTrade(cid, "trade", nil, {module = shopModule})
    return true
end

function onCreatureSay(cid, type, msg)
	if getDistanceBetween(getThingPos(cid), Creature(getNpcCid()):getPosition()) >= 4 then
		return false
	end

    if not cid:isShopping() then
        shopModule.requestTrade(cid:getId(), "trade", nil, {module = shopModule})
    end
    npcHandler:onCreatureSay(cid, type, msg)
end

-- Sell only the 7 level-1 base items
local JONNY_ITEMS = {
  {"Bronze Axe", 26618, {
    {6, 10}, -- Physical Attack: +10
  }, 0, 300},
  {"Druid Rod", 26445, {
    {7, 10}, -- Magic Attack: +10
  }, 0, 300},
  {"Amplifying Tome", 1955, {
    {7, 10}, -- Magic Attack: +10
  }, 0, 400},
  {"Doran's Blade", 2406, {
    {6, 10}, -- Physical Attack: +10
    {1, 80}, -- Health: +80
    {17, 3}, -- Physical Lifesteal: +3%
  }, 0, 450},
  {"Doran's Ring", 2124, {
    {7, 18}, -- Magic Attack: +18
    {1, 90}, -- Health: +90
    {5, 5},  -- Mana Regeneration: +5
  }, 0, 400},
  {"Doran's Shield", 2512, {
    {1, 110}, -- Health: +110
    {4, 7},   -- Health Regeneration: +7
  }, 0, 450},
  {"Doran's Wand", 2186, {
    {7, 10}, -- Magic Attack: +10
    {1, 50}, -- Health: +50
    {18, 3}, -- Magic Lifesteal: +3%
  }, 0, 450},
}

local function setupBaseItem(item, baseData)
  local implicitsSlots = #baseData[3]
  item:setImplictSlots(implicitsSlots)
  item:setRarity(baseData[4] or 0)
  item:setAttribute(ITEM_ATTRIBUTE_NAME, baseData[1])
  item:setCustomAttribute("checksum", ITEM_CHECKSUM)
  for x = 1, implicitsSlots do
    local impId = baseData[3][x][1]
    local value = baseData[3][x][2]
    item:setImplictValue(x, impId .. "|" .. value .. "|1")
  end
end

for _, baseData in ipairs(JONNY_ITEMS) do
  local name   = baseData[1]
  local itemId = baseData[2]
  local price  = baseData[5]
  shopModule:addBuyableItem({name}, itemId, price, 1, name, function(item, player)
    setupBaseItem(item, baseData)
  end)
end

npcHandler:setCallback(CALLBACK_ONTRADEREQUEST, onTradeRequest)
npcHandler:setCallback(CALLBACK_ONADDFOCUS, onAddFocus)
npcHandler:addModule(FocusModule:new())
