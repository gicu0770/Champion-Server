function getFullBonus(player)
  local attrTable = {}
  local fullBonus = ""
  for i = CONST_SLOT_HEAD, CONST_SLOT_RING2 do
    local slotItem = player:getSlotItem(i)
    if slotItem ~= nil and slotItem:getType():isUpgradable() then
      if slotItem:getType():usesSlot(i) then
        for i = 1, slotItem:getMaxAttributes() do
          local enchant = slotItem:getBonusAttribute(i)
          if enchant then
            local attr = US_ENCHANTMENTS[enchant[1]]
            if attrTable[enchant[1]] ~= nil then
              attrTable[enchant[1]].value = attrTable[enchant[1]].value + enchant[2]
			  if attr.name:find("Protection") then
				attrTable[enchant[1]].value = math.min(50, attrTable[enchant[1]].value)
			  end
              attrTable[enchant[1]].text = attr.format(attrTable[enchant[1]].value):gsub("%%%%", "%%")
            else
              attrTable[enchant[1]] = {text = attr.format(enchant[2]):gsub("%%%%", "%%"), value = enchant[2]}
			  if attr.name:find("Protection") then
				attrTable[enchant[1]].value = math.min(50, attrTable[enchant[1]].value)
			  end
            end
          end
        end
      end
    end
  end
  for key, value in pairs(attrTable) do
    fullBonus = fullBonus .. "\n   " .. value.text
  end
  return fullBonus
end


function onSay(player, words, param)
  local bonus = getFullBonus(player)
  if bonus == "" then
    bonus = "No attributes"
  end
  player:popupFYI(bonus)

  return false
end
