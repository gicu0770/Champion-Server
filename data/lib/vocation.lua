function Player:sendVocationWindow(outfits)
	local function buttonCallback(button, choice)
		local outfitName = string.lower(outfits[choice.id].name) -- Converts the outfit name to lowercase
	-- Modal window functionallity
		if button.text == "Confirm" then 
		-- Start Checks
			-- Check if player has addon doll in backpack.
			if self:getItemCount(outfits.dollID) == 0 then
				self:sendVocationWindow_noDoll(outfits)
				return false
			end
			
			-- If choiceID equals 0 return false and close window (If player alread has all addons choiceID will be 0).
			if choice.id == 0 then
				return false
			end
			
			if self:getVocation():getId() == outfits[choice.id].voc or self:getVocation():getId() == (outfits[choice.id].voc + 4)  or self:getVocation():getId() == (outfits[choice.id].voc + 8)  or self:getVocation():getId() == (outfits[choice.id].voc + 12) then
				self:sendVocationWindow_owned(outfits)
				return false
			end
			if self:getVocation():getId() == outfits[choice.id].voc or self:getVocation():getId() == (outfits[choice.id].voc + 1)  or self:getVocation():getId() == (outfits[choice.id].voc + 2)  or self:getVocation():getId() == (outfits[choice.id].voc + 3) then
				self:sendVocationWindow_owned(outfits)
				return false
			end
			
			if outfits[choice.id].name == "Knight" or outfits[choice.id].name == "Archer" or outfits[choice.id].name == "Sorcerer" or outfits[choice.id].name == "Druid" then
			local reborn = (self:getStorageValue(707070) + 1)
			self:setVocation(outfits[choice.id].voc + (reborn * 4))
			elseif outfits[choice.id].name == "Paladin" or outfits[choice.id].name == "Archer" then
			local reborn = (self:getStorageValue(707070) + 1)
			self:setVocation(outfits[choice.id].voc + reborn)
			end
			
		end
		-- End Checks
			
		-- Remove addon doll, send confirmation message and send super special sparkles. 
		self:removeItem(outfits.dollID, 1)
		self:getPosition():sendMagicEffect(CONST_ME_FIREWORK_YELLOW)
		self:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You can now wear the " ..outfitName.. " outfit and addons!")
	end
	
-- Modal window design
	local window = ModalWindow {
		title = outfits.mainTitle, -- Title of the modal window
		message = outfits.mainMsg, -- The message to be displayed on the modal window
	}

	-- Add buttons to the window (Note: if you change the names of these you must change the functions in the modal window functionallity!)
	window:addButton("Confirm", buttonCallback)
	window:addButton("Cancel")

	-- Set what button is pressed when the player presses enter or escape
	window:setDefaultEnterButton("Confirm")
	window:setDefaultEscapeButton("Cancel")

	-- Add choices from the action script
	for i = 1, #outfits do
	local o = outfits[i].name
	
		-- Checks what outfits player has/doesnt
--		if not self:hasOutfit(outfits[i].male, 3) and not self:hasOutfit(outfits[i].female, 3) then
		if self:getVocation():getId() ~= outfits[i].voc or self:getVocation():getId() ~= (outfits[i].voc + 4)  or self:getVocation():getId() ~= (outfits[i].voc + 8) or self:getVocation():getId() ~= (outfits[i].voc + 12) then
		local choice = window:addChoice(o)
		elseif self:getVocation():getId() == outfits[i].voc or self:getVocation():getId() == (outfits[i].voc + 1)  or self:getVocation():getId() == (outfits[i].voc + 2)  or self:getVocation():getId() == (outfits[i].voc + 3) then
				
			-- Add choice if player does not have outfit
			local choice = window:addChoice(o)
		else
			-- Add "[Owned]" to the choice if player already has it.
			local choice = window:addChoice(o.." [You vocation]")
		end
    end

	-- Send the window to player
	window:sendToPlayer(self)
end

--- The modal window that is played if player already has the addon.
function Player:sendVocationWindow_owned(outfits)
	local function buttonCallback(button, choice)
	
		if button.text == "Back" then
			self:sendVocationWindow(outfits)
		end
	end
-- Modal window design
	local window = ModalWindow {
		title = outfits.ownedTitle, -- Title of the modal window
		message = outfits.ownedMsg, -- The message to be displayed on the modal window
	}

	-- Add buttons to the window (Note: if you change the names of these you must change the functions in the modal window functionallity!)
	window:addButton("Back", buttonCallback)

	-- Set what button is pressed when the player presses enter or escape
	window:setDefaultEnterButton("Back")
	window:setDefaultEscapeButton("Back")

	-- Send the window to player
	window:sendToPlayer(self)
end

--- The modal window that is displayed if the player doesnt have the doll in his BP
function Player:sendVocationWindow_noDoll(outfits)
	local function buttonCallback(button, choice)

		if button.text == "Back" then
			self:sendVocationWindow(outfits)
		end
		
	end
-- Modal window design
	local window = ModalWindow {
		title = outfits.dollTitle, -- Title of the modal window
		message = outfits.dollMsg, -- The message to be displayed on the modal window
	}

	-- Add buttons to the window (Note: if you change the names of these you must change the functions in the modal window functionallity!)
	window:addButton("Back", buttonCallback)

	-- Set what button is pressed when the player presses enter or escape
	window:setDefaultEnterButton("Back")
	window:setDefaultEscapeButton("Back")

	-- Send the window to player
	window:sendToPlayer(self)
end