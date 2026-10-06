function onUpdate(elapsed)
misses = getProperty('songMisses')
	if misses >3 then
		setProperty('health', 0)
	end
end