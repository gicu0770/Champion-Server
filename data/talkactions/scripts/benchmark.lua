function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		player:sendCancelMessage("You do not have permission to use this command.")
		return false
	end

	-- Parsowanie liczby powtorzen
	local iterations = 10000
	local paramNum = tonumber(param)
	if paramNum then
		iterations = math.min(math.max(math.floor(paramNum), 1000), 100000)
	end

	local engineVersion = _VERSION
	if jit and jit.version then
		engineVersion = jit.version
	end

	local playersOnline = #Game.getPlayers()
	
	-- Podwojne wymuszenie GC przed startem dla czystego punktu odniesienia (Pass 1: __gc, Pass 2: sweep)
	collectgarbage("collect")
	collectgarbage("collect")
	local memStart = collectgarbage("count")

	local lines = {}
	table.insert(lines, "========================================")
	table.insert(lines, "       TFS VISION BENCHMARK REPORT      ")
	table.insert(lines, "========================================")
	table.insert(lines, string.format("Engine: %s", engineVersion))
	table.insert(lines, string.format("Players Online: %d | Test Iterations: %d", playersOnline, iterations))
	table.insert(lines, string.format("Initial Lua RAM: %.2f MB (%.2f KB)", memStart / 1024, memStart))
	table.insert(lines, "----------------------------------------")

	-- 1. TEST: Core Combat & Overpower Calculations
	local mBefore1 = collectgarbage("count")
	local t0 = os.clock()
	for i = 1, iterations do
		spellOverpower(player, COMBAT_PHYSICALDAMAGE, 1)
		spellMoreDamage(player, COMBAT_FIREDAMAGE, 1)
	end
	local t1 = os.clock()
	local mDelta1 = collectgarbage("count") - mBefore1
	local combatTime = math.max((t1 - t0) * 1000, 0.0001)
	local combatOps = math.floor((iterations * 2) / (combatTime / 1000))
	local combatLatency = (combatTime / (iterations * 2)) * 1000 -- us

	table.insert(lines, "[1] Combat Overpower & MoreDamage:")
	table.insert(lines, string.format("    Czas: %.2f ms | %s ops/s (%.2f us/call)", combatTime, string.format("%d", combatOps), combatLatency))
	table.insert(lines, string.format("    Alokacja RAM: %+.2f KB", mDelta1))

	-- 2. TEST: Spell Power Total
	local testItem = player:getSlotItem(CONST_SLOT_LEFT) or player:getSlotItem(CONST_SLOT_RIGHT) or player:getSlotItem(CONST_SLOT_HEAD)
	if testItem and getSpellPowerTotal then
		local mBefore2 = collectgarbage("count")
		t0 = os.clock()
		for i = 1, iterations do
			getSpellPowerTotal(player, 1, testItem, 0, 1)
		end
		t1 = os.clock()
		local mDelta2 = collectgarbage("count") - mBefore2
		local spTime = math.max((t1 - t0) * 1000, 0.0001)
		local spOps = math.floor(iterations / (spTime / 1000))
		local spLatency = (spTime / iterations) * 1000

		table.insert(lines, "[2] Spell Power Total (colleftInfo lookup):")
		table.insert(lines, string.format("    Czas: %.2f ms | %s ops/s (%.2f us/call)", spTime, string.format("%d", spOps), spLatency))
		table.insert(lines, string.format("    Alokacja RAM: %+.2f KB", mDelta2))
	else
		table.insert(lines, "[2] Spell Power Total: Pominieto (brak przedmiotu w rece)")
	end

	-- 3. TEST: Attack Speed (Pure Math) & Cooldown Reduction
	local mBefore3 = collectgarbage("count")
	t0 = os.clock()
	for i = 1, iterations do
		player:getAST()
		player:getCooldownReduction()
	end
	t1 = os.clock()
	local mDelta3 = collectgarbage("count") - mBefore3
	local statsTime = math.max((t1 - t0) * 1000, 0.0001)
	local statsOps = math.floor((iterations * 2) / (statsTime / 1000))
	local statsLatency = (statsTime / (iterations * 2)) * 1000

	table.insert(lines, "[3] Stats Math (getAST & Cooldown):")
	table.insert(lines, string.format("    Czas: %.2f ms | %s ops/s (%.2f us/call)", statsTime, string.format("%d", statsOps), statsLatency))
	table.insert(lines, string.format("    Alokacja RAM: %+.2f KB", mDelta3))

	-- 4. TEST: Condition Apply (getTotalAttackSpeed)
	local condIters = math.min(iterations, 1000)
	local mBefore4 = collectgarbage("count")
	t0 = os.clock()
	for i = 1, condIters do
		player:getTotalAttackSpeed()
	end
	t1 = os.clock()
	local mDelta4 = collectgarbage("count") - mBefore4
	local asCondTime = math.max((t1 - t0) * 1000, 0.0001)
	local asCondOps = math.floor(condIters / (asCondTime / 1000))

	table.insert(lines, string.format("[4] Condition Apply (getTotalAttackSpeed, %d iters):", condIters))
	table.insert(lines, string.format("    Czas: %.2f ms | %s ops/s", asCondTime, string.format("%d", asCondOps)))
	table.insert(lines, string.format("    Alokacja RAM: %+.2f KB", mDelta4))

	-- 5. TEST: Full Player Gear Recalculation (setStatistics)
	local statIters = math.min(iterations, 1000)
	local mBefore5 = collectgarbage("count")
	t0 = os.clock()
	for i = 1, statIters do
		player:setStatistics()
	end
	t1 = os.clock()
	local mDelta5 = collectgarbage("count") - mBefore5
	local fullStatsTime = math.max((t1 - t0) * 1000, 0.0001)
	local fullStatsOps = math.floor(statIters / (fullStatsTime / 1000))

	table.insert(lines, string.format("[5] Full Gear Stats Recalculate (%d iters):", statIters))
	table.insert(lines, string.format("    Czas: %.2f ms | %s ops/s", fullStatsTime, string.format("%d", fullStatsOps)))
	table.insert(lines, string.format("    Alokacja RAM: %+.2f KB", mDelta5))

	-- 6. TEST: Memory & Multi-pass Garbage Collector Evaluation
	local memPeak = collectgarbage("count")
	local memGrossAllocated = memPeak - memStart
	
	-- Cykl 1: uruchomienie __gc (destruktory C++ dla obiektow Condition)
	collectgarbage("collect")
	local memAfterGC1 = collectgarbage("count")
	
	-- Cykl 2: zwolnienie naglowkow userdata ze sterty Lua
	collectgarbage("collect")
	local memAfterGC2 = collectgarbage("count")
	local memNetDiff = memAfterGC2 - memStart

	table.insert(lines, "----------------------------------------")
	table.insert(lines, string.format("Total Temp RAM Allocated: %+.2f KB", memGrossAllocated))
	table.insert(lines, string.format("RAM after GC Pass 1 (C++ __gc): %+.2f KB", memAfterGC1 - memStart))
	table.insert(lines, string.format("Net RAM after GC Pass 2 (Sweep): %+.2f KB", memNetDiff))
	local leakStatus = "IDEALNY (0.00 KB)"
	if memNetDiff > 50 then
		leakStatus = "UWAGA WYCIEK (" .. string.format("%.2f KB", memNetDiff) .. ")"
	elseif memNetDiff > 10 then
		leakStatus = "MINIMALNY SLAD (" .. string.format("%.2f KB", memNetDiff) .. ")"
	end
	table.insert(lines, string.format("Status pamieci: %s", leakStatus))
	table.insert(lines, "========================================")

	local fullReport = table.concat(lines, "\n")
	
	-- Wypisanie do konsoli glownej serwera
	print(fullReport)

	-- Wypisanie do konsoli gracza
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, fullReport)

	-- Okienko dialogowe z pelnym podsumowaniem
	if player.showTextDialog then
		player:showTextDialog(1945, fullReport)
	end

	return false
end
