--Map
--Created by Colby Eckert (Tahlwyn)

local map = {}

function map:load() 

	map.maps = {
		test = sti("res/test.lua")
	}

end

function map:update(dt)
	map.maps.test:update(dt)
end

function map:draw()
	map.maps.test:draw()
end

return map