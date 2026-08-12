local outfits = {
 
-- Config
	dollID = 36596, -- Change this to your dolls or items, item ID
 
	-- Main Window Messages (The first window the player sees)
	mainTitle = "Choose an outfit",
	mainMsg = "You will recieve both addons aswell as the outfit you choose.",
 
	-- Already Owned Window (The window that appears when the player already owns the addon)
	ownedTitle = "Whoops!",
	ownedMsg = "You already have this addon. Please choose another.",
 
	-- No Doll in Backpack (The window that appears when the player doesnt have the doll in their backpack)
	dollTitle = "Whoops!",
	dollMsg = "The addon doll must be in your backpack.",
-- End Config
	-- Outfit Table
	[1] = {name = "Knight", voc = 4},
	[2] = {name = "Archer", voc = 3},
	[3] = {name = "Sorcerer", voc = 1},
	[4] = {name = "Druid", voc = 2}, 
	[5] = {name = "Paladin", voc = 17},
	[6] = {name = "Shadow", voc = 21},

}
 
function onUse(player, item, fromPosition, itemEx, toPosition, isHotkey)
    player:sendVocationWindow(outfits)
    return true
end