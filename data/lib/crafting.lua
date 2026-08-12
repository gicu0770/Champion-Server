-- Main Crafting Window -- This is the modal window that is displayed first 
function Player:sendMainCraftWindow(config)
	local function buttonCallback(button, choice)

	-- Modal Window Functionallity 
		if button.text == "Select" then
			self:sendVocCraftWindow(config, choice.id)
		end	
	end
	
	-- Modal window design
	local window = ModalWindow {
		title = config.mainTitleMsg, -- Title of the main craft modal window
		message = config.mainMsg.."\n\n" -- Message of the main craft modal window
	}

	-- Add buttons to the window (Note: if you change the names of these you must change the functions in the modal window functionallity!)
	window:addButton("Select", buttonCallback)
	window:addButton("Exit", buttonCallback)
	
	-- Add choices from the action script
    for i = 1, #config.system do
		window:addChoice(config.system[i].vocation)
    end

	-- Set what button is pressed when the player presses enter or escape.
	window:setDefaultEnterButton("Select")
	window:setDefaultEscapeButton("Exit")
	
	-- Send the window to player
	window:sendToPlayer(self)
end
-- End of the first modal window



-- This is the modal window that displays all avalible items for the chosen vocation.
function Player:sendVocCraftWindow(config, lastChoice)
    local function buttonCallback(button, choice)	

-- Modal Window Functionallity 
		-- If the user presses the back button they will be redirected to the main window.
		if button.text == "Back" then
			self:sendMainCraftWindow(config)
		end
		-- If the user presses the details button they will be redirected to a text window with information about the item they want to craft.
		if button.text == "Details" then
		local item = config.system[lastChoice].items[choice.id].item
		local details = "In order to craft "..item.." you must collect the following items.\n\nRequired Items:"

			for i = 1, #config.system[lastChoice].items[choice.id].reqItems do
			local reqItems = config.system[lastChoice].items[choice.id].reqItems[i].item
			local reqItemsCount = config.system[lastChoice].items[choice.id].reqItems[i].count 
			local reqItemsOnPlayer = self:getItemCount(config.system[lastChoice].items[choice.id].reqItems[i].item)
				details = details.."\n- "..capAll(getItemName(reqItems).." ["..reqItemsOnPlayer.."/"..reqItemsCount.."]")
			end	
		
			self:showTextDialog(item, details)
			self:sendVocCraftWindow(config, lastChoice)
		end
		
		-- if the player presses the craft button then begin checks. 
		if button.text == "Craft" then
		
			-- Check if player has required items to craft the item. If they dont send needItems message.
			for i = 1, #config.system[lastChoice].items[choice.id].reqItems do
				if self:getItemCount(config.system[lastChoice].items[choice.id].reqItems[i].item) < config.system[lastChoice].items[choice.id].reqItems[i].count then
					self:say(config.needItems..config.system[lastChoice].items[choice.id].item, TALKTYPE_MONSTER_SAY)
					return false
				end
			end	
			-- Remove the required items and there count from the player.
			for i = 1, #config.system[lastChoice].items[choice.id].reqItems do
				self:removeItem(config.system[lastChoice].items[choice.id].reqItems[i].item, config.system[lastChoice].items[choice.id].reqItems[i].count)
			end				
		-- Send effect and give player item.
	local result = self:addItem(config.system[lastChoice].items[choice.id].itemID)
	result:setCustomAttribute("unidentified", true)
	set1 = {26404, 26405, 26406, 26407, 26408, 26551, 26631, 26386, 26387, 26388, 26389, 22418, 26391, 22421, 26414, 26415, 26416, 26417, 26413, 26418, 26419, 26420, 26421}
	set2 = {26728, 26729, 26730, 26731, 26732, 26603, 26607, 26564, 26565, 26566, 26567, 26536, 26829, 26594, 26476, 26477, 26478, 26479, 26480, 26481, 23547, 7431, 26834, 26836}
	set3 = {26464, 26465, 26466, 26467, 26468, 16112, 26544, 26485, 26486, 26487, 26488, 8856, 26489, 15644, 26724, 26725, 26726, 26727, 26589, 26614, 26611, 24716, 21693}
	set4 = {26382, 26383, 26384, 21708, 25411, 26630, 26604, 26471, 26472, 26473, 26474, 26550, 26475, 16111, 26775, 26768, 26762, 26720, 26750, 26648, 26656, 26642, 26183, 26835}
	set5 = {21253, 21252}
	if isInArray(set1, result:getId()) then  --galaxy cheetos octo
	result:setItemLevel(90)
	end
	if isInArray(set2, result:getId()) then --forest heavy crown
	result:setItemLevel(120)
	end
	if isInArray(set3, result:getId()) then --platinum guardian wizard
	result:setItemLevel(160)
	end
	if isInArray(set4, result:getId()) then --watcher glory death
	result:setItemLevel(210)
	end
	if isInArray(set5, result:getId()) then --vampire
	result:setItemLevel(240)
	end
	
		self:getPosition():sendMagicEffect(50)
		end	
    end
 
	-- Modal window design
    local window = ModalWindow {
        title = config.craftTitle..config.system[lastChoice].vocation, -- The title of the vocation specific window
        message = config.craftMsg..config.system[lastChoice].vocation..".\n\n", -- The message of the vocation specific window
    }
	
	-- Add buttons to the window (Note: if you change the names of these you must change the functions in the modal window functionallity!)
	window:addButton("Back", buttonCallback)
	window:addButton("Exit")
	window:addButton("Details", buttonCallback)
	window:addButton("Craft", buttonCallback)
	
	-- Set what button is pressed when the player presses enter or escape
    window:setDefaultEnterButton("Craft")
    window:setDefaultEscapeButton("Exit")
   
	-- Add choices from the action script
    for i = 1, #config.system[lastChoice].items do
        window:addChoice(config.system[lastChoice].items[i].item)
    end
    
	-- Send the window to player
    window:sendToPlayer(self)
end