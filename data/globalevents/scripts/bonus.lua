local effects = {
    {position = Position(676, 1038, 7), text = 'Training Room', effect = 15},  
	{position = Position(708, 1032, 7), text = 'Town Portal', effect = 15}, 
	{position = Position(771, 1028, 5), text = 'Dark Tower', effect = 15}, 
	{position = Position(691, 1029, 7), text = 'Market Place', effect = 15}, 
	{position = Position(674, 1034, 8), text = 'Melee Offline', effect = 15},
	{position = Position(674, 1035, 8), text = 'Distance Offline', effect = 15},
	{position = Position(674, 1036, 8), text = 'Magic Power Offline', effect = 15},
	{position = Position(668, 1043, 7), text = 'Crafting', effect = 15},
	{position = Position(668, 1045, 7), text = 'Crafting', effect = 15},
	{position = Position(668, 1047, 7), text = 'Crafting', effect = 15},

}

function onThink(player, interval)
if player then
 player:addBuff()
end
   return true
end