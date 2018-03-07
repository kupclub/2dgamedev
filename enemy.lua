--[[ Enemies and Enemy Interactions ]]--

local enemy = {}

function enemy:load()
	enemy.stack = {} --All currently active enemies

	enemy.sheet = love.graphics.newImage("res/img/enemies_spritesheet.png")

	enemy.slime = {
		frames = {
			love.graphics.newQuad(0, 127, 51,28, enemy.sheet:getDimensions()),
			love.graphics.newQuad(51,125, 53,28, enemy.sheet:getDimensions()),
			love.graphics.newQuad(0, 112, 59,12, enemy.sheet:getDimensions()),
		},
		anims = {
			walk = {2,3},
			dead = {1},
		},
		width = 52,
		height = 25,
		animspeed = 0.5,

		speed = 2,

		bt = 5, --Boredom Threshold: gets bored after ~5 seconds TEMP
	}
end

function enemy:update(dt)
	for i,v in ipairs(enemy.stack) do 

		--Test behavior
		v.boredom = v.boredom + 1 * dt
		if v.boredom >= enemy[v.type].bt then
			v.boredom = 0
			v.dir = v.dir * -1
			v.vx = 0
		end

		v.vx = v.vx + (enemy[v.type].speed*v.dir)

		v.vy = v.vy + GRAVITY
    		local goalX, goalY = v.x + v.vx * dt, v.y + v.vy * dt
    		local actualX, actualY, cols, len = map.world:move(v, goalX, goalY)
		v.x, v.y = actualX,actualY

		--Animations
		v.timer = v.timer + 1 * dt
		if v.timer > enemy[v.type].animspeed then
			v.timer = 0
			v.iter = v.iter + 1
			if v.iter > 2 then --remove magic number
				v.iter = 1
			end
		end
	end
end

function enemy:draw()
	for i,v in ipairs(enemy.stack) do
		love.graphics.draw(enemy.sheet, enemy.slime.frames[v.iter], v.x+enemy[v.type].width/2,v.y, 0, -v.dir, 1, enemy[v.type].width/2)
		--[[love.graphics.setColor(255,0,0)
		love.graphics.print(v.vx, v.x,v.y)
		love.graphics.setColor(255,255,255)]]--
	end
end

function enemy:new(type, x,y)
	local id = #enemy.stack + 1

	enemy.stack[id] = {
		type  = type,
		x     = x,
		y     = y,
		vx    = 0,
		vy    = 0,
		iter  = 1,
		timer = 0,
		dir   = 1,
		boredom = 0, --temp
	}
	
	return id
end

return enemy
