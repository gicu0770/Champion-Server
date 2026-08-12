function onThink(interval)
	local time = os.time()
	collectgarbage("collect")
	collectgarbage("collect")
	local elapsed = os.time() - time
	print(string.format("Garbage collection took %d seconds.", elapsed))
	return true
end