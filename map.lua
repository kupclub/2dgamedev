--Map
--Created by Colby Eckert (Tahlwyn)

local map = {}

function map:load()
	map.maps = {
		test = sti("res/test.lua", {"bump"})
	}

	map.world = bump.newWorld()

	map.maps.test:bump_init(map.world)

	map.world:add(player, player.x, player.y, player.w, player.h)
end

function map:update(dt)
	map.maps.test:update(dt)
end

function map:draw()
	love.graphics.setBackgroundColor(135, 206, 235) --sky blue
	map.maps.test:draw()
end

return map
