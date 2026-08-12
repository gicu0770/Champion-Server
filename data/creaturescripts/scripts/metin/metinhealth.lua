local Rift_Portal = {
    ["First Rift Portal"] = {
        {percentHealth = 90, monsters = {"Rift Minion", "Rift Minion","Rift Minion"}}, --from biggest to lowest hp %
        {percentHealth = 75, monsters = {"Rift Minion","Rift Minion","Rift Warrior"}},
        {percentHealth = 50, monsters = {"Rift Warrior","Rift Warrior","Rift Scorpion"}},
        {percentHealth = 25, monsters = {"Rift Warrior","Rift Scorpion","Rift Scorpion"}},
        {percentHealth = 10, monsters = {"Rift Warrior","Rift Scorpion","Rift Scorpion"}},
    },
    ["Second Rift Portal"] = {
        {percentHealth = 90, monsters = {"Rift Minion", "Rift Minion","Rift Warrior"}}, --from biggest to lowest hp %
        {percentHealth = 75, monsters = {"Rift Minion","Rift Scorpion","Rift Warrior"}},
        {percentHealth = 50, monsters = {"Rift Scorpion","Rift Warrior","Rift Scorpion"}},
        {percentHealth = 25, monsters = {"Rift Intruder","Rift Scorpion","Rift Nightmare"}},
        {percentHealth = 10, monsters = {"Rift Intruder","Rift Scorpion","Rift Nightmare"}},
    },
   ["Third Rift Portal"] = {
        {percentHealth = 90, monsters = {"Rift Scorpion", "Rift Scorpion","Rift Scorpion"}}, --from biggest to lowest hp %
        {percentHealth = 75, monsters = {"Rift Intruder","Rift Scorpion","Rift Intruder"}},
        {percentHealth = 50, monsters = {"Rift Nightmare","Rift Intruder","Rift Scorpion"}},
        {percentHealth = 25, monsters = {"Rift Nightmare","Rift Nightmare","Rift Nightmare"}},
        {percentHealth = 10, monsters = {"Rift Nightmare","Rift Nightmare","Rift Nightmare"}},
    }
}
function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
if creature:isMonster() then
if (#creature:getSummons() > 0) then
    primaryDamage = 0
    secondaryDamage = 0
    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local maxHP = creature:getMaxHealth()
local HP = creature:getHealth()
local nameMonster = creature:getName()
local monstersName = Rift_Portal[nameMonster]
for i = 1, #monstersName do
    if monstersName[i] then
        local sto = creature:getStorageValue(PlayerStorage.riftPortal)
        local HPneed = (monstersName[i].percentHealth)
        local actualHP = (maxHP * HPneed) / 100
        if HP >= actualHP and HP <= actualHP then
            local monstersCreate = monstersName[i].monsters
            for i = 1, #monstersCreate do
                local summon = Game.createMonster(monstersCreate[i], creature:getPosition(), true, false, creature)
                creature:addSummon(summon)
            end	
        end
    end
end
attacker:setStorageValue(PlayerStorage.riftReward, 1)
primaryDamage = 1
secondaryDamage = 0
end
return primaryDamage, primaryType, secondaryDamage, secondaryType
end