--Map
--Created by Colby Eckert (Tahlwyn)

local map = {}

function map:load()
	map.maps = {
		hyrule = sti("data/maps/hyrule.lua", {"bump"}),
	}

	map.cur = map.maps.hyrule --Current map

	map.world = bump.newWorld()

	map.cur:bump_init(map.world)

end

function map:update(dt)
	map.cur:update(dt)
end

function map:draw()
	love.graphics.setBackgroundColor(135/255, 206/255, 235/255) --sky blue
	map.cur:draw()
	map.cur:bump_draw(map.world)
end

return map
