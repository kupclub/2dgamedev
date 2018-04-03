--Map
--Created by Colby Eckert (Tahlwyn)

local map = {}

function map:load()
	map.maps = {
		test = sti("res/test.lua", {"bump"})
	}

	map.cur = map.maps.test --Current map

	map.world = bump.newWorld()

	map.cur:bump_init(map.world)

end

function map:update(dt)
	map.cur:update(dt)
end

function map:draw()
	love.graphics.setBackgroundColor(135, 206, 235) --sky blue
	map.cur:draw()
	map.cur:bump_draw(map.world)
end

return map
