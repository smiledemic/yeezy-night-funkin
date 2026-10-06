function onUpdate(elapsed)
misses = getProperty('songMisses')
	if misses >0 then
		setProperty('health', 0)
	end
end