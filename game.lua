cam = require 'camera'
map = require 'map'
enemy = require 'enemy'
net = require 'net'

local regFont = love.graphics.newFont("fonts/Berkshire_Swash/BerkshireSwash-Regular.ttf", 24)

local game = {}

local state = {
    livePlayers = {},
    deadPlayers = {},
    bullets = {}
}

FIRETIME = 0.2
MAXBULLETS = 40
GRAVITY = 9.8

player_attrs = {
    speed = 180,
    jumpSpeed = 400,
    skins ={
      pink=love.graphics.newImage('res/img/p3_spritesheet.png'),
      green=love.graphics.newImage('res/img/p1_spritesheet.png'),
      blue=love.graphics.newImage('res/img/p2_spritesheet.png')
    }
}

enemy:load()
map:load()

function newPlayer(x_, y_, skin_, name_)
    local p = {
	type = "player",
	x = x_, y = y_,
	vx = 0, vy = GRAVITY,
	canJump = false,
	iscrouched=false,
	direction = 1,
	lastfire = 0,
	w = 70, h = 95,
  	skin=skin_,
  	hp = 100,
  	lives = 4,
	name=name_,
	curSpeed=1,
	numBullets=100,
	index = #state.livePlayers + 1,
    }
    table.insert(state.livePlayers, p)
    map.world:add(p, p.x, p.y, p.w, p.h)
    return p
end

function left(player)
    player.vx = -player_attrs.speed * player.curSpeed
    player.direction=-1
end

function right(player)
    player.vx = player_attrs.speed * player.curSpeed
    player.direction=1
end

function jump(player)
    if player.canJump then
	player.vy = -player_attrs.jumpSpeed * player.curSpeed
	player.canJump = false
    end
end

function crouch(player)
  player.h=72
  player.iscrouched=true
  player.y=player.y + 23
  player.curSpeed=0.5
  map.world:update(player,player.x,player.y,player.w,player.h)
end

function uncrouch(player)
  player.h=95
  player.iscrouched=false
  player.y=player.y - 23
  player.curSpeed=1
  map.world:update(player,player.x,player.y,player.w,player.h)
end

function love.gamepadpressed(joystick, button)
	for i = 1,#state.livePlayers do
		if joysticks[i] then
			if button == "dpup" then
				beholder.trigger("player"..i.."-crouch")
			end
		end
	end
end

function love.gamepadreleased(joystick, button)
	for i = 1,#state.livePlayers do
		if joysticks[i] then
			if button == "dpdown" then
				beholder.trigger("player"..i.."-uncrouch")
			end
		end
	end
end

function gamepadInput()
	joysticks = love.joystick.getJoysticks()

	for i = 1,#state.livePlayers do
		if joysticks[i] then
			if joysticks[i]:isGamepadDown("dpleft") then
				beholder.trigger("player"..i.."-left")
			end

			if joysticks[i]:isGamepadDown("dpright") then
				beholder.trigger("player"..i.."-right")
			end

			if joysticks[i]:isGamepadDown("dpup") or joysticks[i]:isGamepadDown("a") then
				beholder.trigger("player"..i.."-up")
			end

			if joysticks[i]:isGamepadDown("rightshoulder") then
				beholder.trigger("player"..i.."-fire")
			end

			if joysticks[i]:isGamepadDown("start") then
				beholder.trigger("restart-game")
			end

      			if joysticks[i]:isGamepadDown("guide") then
			        debug.debug()
			end
		end
	end
end

function updatePlayer(dt, player)
    player.vy = player.vy + GRAVITY
    local goalX, goalY = player.x + player.vx * dt, player.y + player.vy * dt
    local actualX, actualY, cols, len = map.world:move(player, goalX, goalY, function(item, other)
	if other.type == "bullet" then
	    return nil
	end
	return "slide"
    end)
    player.x, player.y = actualX, actualY

	gamepadInput()

    -- reset vy, since we're touching the ground
    for _, c in pairs(cols) do
      if c.normal.y == -1 then
	player.vy = GRAVITY
      end
    end

    if len > 0 then
	player.canJump = true
    end

    -- reset vx so player input doesn't keep vx going when a key is released
    player.vx = 0
end

fire = love.audio.newSource("res/sound/shoot.ogg", "static")

function fireGun(player)
    if love.timer.getTime() - player.lastfire > FIRETIME and player.numBullets > 0 then
	local b = {
	    type = 'bullet',
	    owner = player,
	    x = player.x + player.w / 2,
	    y = player.y + player.h / 2,
	    vx = (400 * player.direction) + player.vx,
	    vy = 0 + player.vy,
	    ttl = 3
	}
	map.world:add(b, b.x, b.y, 10, 10)
  fire:seek(0)
  fire:play()
	table.insert(state.bullets, b)
	player.lastfire = love.timer.getTime()
	player.numBullets = player.numBullets - 1
    end
end

hit = love.audio.newSource("res/sound/hit.mp3", "static")
gameOverS = love.audio.newSource("res/sound/gameOver.wav", "static")
gameOverS:setVolume(1)

function killPlayer(player)
  -- FIXME(charles) this doesn't fail gracefully
  local ii = 1
  for i, p in ipairs(state.livePlayers) do
    if p == player then
      ii = i
      break
    end
  end
  map.world:remove(player)
  table.remove(state.livePlayers, ii)
  table.insert(state.deadPlayers, player)
  beholder.stopObserving(player)
  gameOverS:play()

end

function takeDamage(player)
	if joysticks[player.index] then joysticks[player.index]:setVibration(1,1, 0.2) end
	player.hp = player.hp - 10
  hit:seek(0)
  hit:play()
  	-- death state
	if player.hp <= 0 then
		player.hp = 100
		player.lives = player.lives - 1
	end
	if player.lives <= 0 then
	  if joysticks[player.index] then joysticks[player.index]:setVibration(1,1, 2) end
	  killPlayer(player)
	end
end

-- setup game
function restartGame()
  for _, p in pairs(state.livePlayers) do
    map.world:remove(p)
    beholder.stopObserving(p)
  end

  state.livePlayers = {}
  state.deadPlayers = {}

  me = newPlayer(3500, 0,"pink", "Charles")
  me2 = newPlayer(3600, 0,"green", "Aaron")

  beholder.group(me, function()
      beholder.observe("player1-up", function() jump(me) end)
      beholder.observe("player1-crouch", function() crouch(me) end)
      beholder.observe("player1-uncrouch", function() uncrouch(me) end)
      --beholder.observe("control-down", player:jump)
      beholder.observe("player1-left", function() left(me) end)
      beholder.observe("player1-right", function() right(me) end)
      beholder.observe("player1-fire", function() fireGun(me) end)
  end)

  beholder.group(me2, function()
      beholder.observe("player2-up", function() jump(me2) end)
      --beholder.observe("control-down", player:jump)
      beholder.observe("player2-crouch", function() crouch(me2) end)
      beholder.observe("player2-uncrouch", function() uncrouch(me2) end)
      beholder.observe("player2-left", function() left(me2) end)
      beholder.observe("player2-right", function() right(me2) end)
      beholder.observe("player2-fire", function() fireGun(me2) end)
  end)
end

restartGame()
beholder.observe("take-damage", function(player) takeDamage(player) end)
beholder.observe("restart-game", function()
  if #state.livePlayers <= 1 then
    restartGame()
  end
end)

function game:load()
end

function game:update(dt)
    fun.each(function(p) updatePlayer(dt, p) end, state.livePlayers)

    for i, b in ipairs(state.bullets) do
	b.vy = b.vy + GRAVITY
	local x, y, cols, _ = map.world:move(b, b.x + b.vx * dt, b.y + b.vy * dt,
	function(item, other)
	    if other.type == "player" and other == item.owner then
			return nil
	    end

		if other.type == "player" and other ~= item.owner then
			return "touch"
		end

	    return "bounce"
	end)

	b.x = x
	b.y = y

	for i, col in ipairs(cols) do
	  local shouldKillBullet = false
	  -- the bullet is hitting a wall
	  if col.type == "bounce" then
	    col.item.ttl = col.item.ttl - 1

	    if col.item.ttl <= 0 then
	      shouldKillBullet = true
	    end

	    if col.normal.x ~= 0 then
	      col.item.vx = math.abs(col.item.vx) * col.normal.x
	    end

	    col.item.vy = math.abs(col.item.vy) * col.normal.y

	  elseif col.type == "touch" then
	    -- remove the bullet if it hits another player
	    shouldKillBullet = true
	    beholder.trigger("take-damage", col.other)
	  end

	  if shouldKillBullet then
	    local n = table.remove(state.bullets, i)
	    if n then
	      map.world:remove(n)
	    else
	      print("RERRRRRR CHARLES ITS HAPPENING AGINNNNN")
	    end
	  end
	end

	if #state.bullets > MAXBULLETS then
	    map.world:remove(table.remove(state.bullets, 1))
	end

    end

    enemy:update(dt)
    map:update(dt)
end

stand=love.graphics.newQuad(0,0,70,95,player_attrs.skins["pink"]:getDimensions())
jumpFrame=love.graphics.newQuad(436,92,70,95,player_attrs.skins["pink"]:getDimensions())
run1=love.graphics.newQuad(0,95,70,95,player_attrs.skins["pink"]:getDimensions())
run2=love.graphics.newQuad(73,98,70,95,player_attrs.skins["pink"]:getDimensions())
crouchFrame=love.graphics.newQuad(364,98,70,72,player_attrs.skins["pink"]:getDimensions())
deadplayer=love.graphics.newImage('res/img/skeleton.png')

function drawDeadPlayer(player)
  love.graphics.draw(deadplayer, player.x, player.y)
end

function drawPlayer(player)
    img=player_attrs.skins[player.skin]
    --love.graphics.rectangle('line', player.x, player.y, player.w, player.h)
    local drawX = player.x
    if player.direction == -1 then
	     drawX = drawX + player.w
    end
    time=love.timer.getTime() * 10
    --love.graphics.rectangle('line',player.x,player.y,player.w,player.h)
    --love.graphics.rectangle('line',map.world:getRect(player))
    if player.iscrouched then
       love.graphics.draw(img, crouchFrame, drawX, player.y,0,player.direction,1)
    else
      if player.canJump then
        if player.vx ~= 0 then
           if (time % 6) > 3 then
    	        love.graphics.draw(img, run1, drawX, player.y,0,player.direction,1)
    	     else
    	        love.graphics.draw(img, run2, drawX, player.y,0,player.direction,1)
    	     end
        else
          if (time % 6) > 3 then
             love.graphics.draw(img, stand, drawX, player.y,0,player.direction,1)
          else
             love.graphics.draw(img, stand, drawX, player.y,0,player.direction,1)
          end
        end
      else
	       love.graphics.draw(img, jumpFrame, drawX, player.y,0,player.direction,1)
      end
    end

	health = player.w * (player.hp / 100)

	if player.hp > 30 then
		-- light green
		love.graphics.setColor(129/255, 199/255, 132/255)
	else
		love.graphics.setColor(239/255, 83/255, 80/255)
	end

	love.graphics.rectangle("fill", player.x, player.y - 20, health, 10)

	-- reset colors
	love.graphics.setColor(255, 255, 255)
end

hudsprite=love.graphics.newImage('res/img/hud_spritesheet.png')
hart=love.graphics.newQuad(0,92,52,49,hudsprite:getDimensions())
hartless=love.graphics.newQuad(0,45,52,49,hudsprite:getDimensions())
faces={
  pink =love.graphics.newQuad(97,97,52,49,hudsprite:getDimensions()),
  green =love.graphics.newQuad(0,140,48,49,hudsprite:getDimensions()),
  blue =love.graphics.newQuad(0,189,48,49,hudsprite:getDimensions())
}



function game:draw()
    -- set the font
    love.graphics.setFont(regFont)
    cam:follow(me, me2)

    -- start the camera
    cam:set()

    map:draw()

    fun.each(drawPlayer, state.livePlayers)
    fun.each(drawDeadPlayer, state.deadPlayers)

    enemy:draw()

    -- draw bullets
    for _, b in pairs(state.bullets) do
	if b.owner.skin == "blue" then
	    love.graphics.setColor(20, 20, 100)
	elseif b.owner.skin == "pink" then
	    love.graphics.setColor(255, 50, 50)
	end
	love.graphics.rectangle('fill', b.x, b.y, 10, 10)
	love.graphics.setColor(255, 255, 255)
    end

    cam:unset()

	if #state.livePlayers == 1 then
		drawEndGame(state.livePlayers[1].name)

	end

    for i = 1, #state.livePlayers do
      local p = state.livePlayers[i]
      numLives(10,30 * i, p.skin,p.lives, p.numBullets)
    end
end

function numLives(x,y,avatar,lives,bullets)
  love.graphics.draw(hudsprite, faces[avatar], x, y,0,0.5,0.5)

  for i = 1, 4 do
    if i<=lives then
      img = hart
    else
      img= hartless
    end
    love.graphics.draw(hudsprite, img, x + (i * (52/2)), y,0,0.5,0.5)
  end
  love.graphics.print(bullets,x + (5 * (52/2)),y)
end

function drawEndGame(playerName)
	screenWidth = love.graphics.getWidth()
	screenHeight = love.graphics.getHeight()
	love.graphics.setColor(244/255, 67/255, 54/255, 200/255)
	love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

	-- reset the color
	love.graphics.setColor(1, 1, 1)

	-- set the font
	love.graphics.setFont(regFont)

	msg = "Player " .. playerName .. " wins!"
	directions = "Press enter to play again"
	msgWidth = regFont:getWidth(msg)
	dirWidth = regFont:getWidth(directions)
	love.graphics.printf(msg, screenWidth/2 - msgWidth/2, screenHeight/2, msgWidth, "center")
	love.graphics.printf(directions, screenWidth/2 - dirWidth/2, screenHeight/2 + 100, dirWidth, "center")
end

return game
