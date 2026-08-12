function onExtendedOpcode(player, opcode, buffer)

	if opcode == ExtendedOPCodes.CODE_ATTRIBUTE_SKILLS then
local status, json_data =
        pcall(
        function()

          return json.decode(buffer)
        end
      )
      if not status then

        return false
      end

	  if json_data.Reload then

		local mlvl = player:getMagicLevel()
		local startMagiclvl = player:getBaseMagicLevel() --getMlvlSQL(player)
		player:sendExtendedOpcode(ExtendedOPCodes.CODE_ATTRIBUTE_SKILLS, json.encode({startMagiclvl = startMagiclvl}))  
		local totalMagiclvl = mlvl - startMagiclvl
		player:sendExtendedOpcode(ExtendedOPCodes.CODE_ATTRIBUTE_SKILLS, json.encode({totalMagiclvl = totalMagiclvl}))
	end

end

end