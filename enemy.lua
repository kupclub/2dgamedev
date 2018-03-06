--[[ Enemies and Enemy Interactions ]]--

local enemy = {}

function enemy:load()
	enemy.stack = {} --All currently active enemies

	enemy.sheet = love.graphics.newImage("res/img/enemies_spritesheet.png")

	enemy.slime = {
		frames = {
			love.graphics.quad(0,125,  52,28, enemy.sheet:getDimensions()),
			love.graphics.quad(51,125, 53,28, enemy.sheet:getDimensions()),
			love.graphics.quad(0,112,  59,12, enemy.sheet:getDimensions()),
		},
		anims = {
			walk = {2,3},
			dead = {1},
		},
		animspeed = 0.2,
	}
end

function enemy:update(dt)
	for i,v in ipairs(enemy.stack) do 
		v.timer = v.timer + 1 * dt
		if v.timer > v.animspeed then
			v.timer = 0
			v.iter = v.iter + 1
			if v.iter >= 2 then --remove magic number
				v.iter = 1
			end
		end
	end
end

function enemy:draw()
	for i,v in ipairs(enemy.stack) do
		love.graphics.draw(enemy.sheet, enemy[v.type].frames[1][v.iter], v.x,v.y)
	end
end

function enemy:new(type, x,y)
	local id = #enemy.stack + 1

	enemy.stack[id] = {
		type  = type,
		x     = x,
		y     = y,
		iter  = 1,
		timer = 0,
	}

	return id
end


return enemy
