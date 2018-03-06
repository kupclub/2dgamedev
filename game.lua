local game = {}

GRAVITY = 9.8

player = {
    speed = 180,
    jumpSpeed = 200,
    x = 0, y = 0,
    w = 70, h = 95,
    vx = 0, vy = 0,
    canJump = false,
    direction = 1
}

cam = require 'camera'
map = require 'map'

enemy = require 'enemy'

enemy:load()
map:load()


enemy:new("slime", 200,150)

function player:update(dt)
    local goalX, goalY = player.x + player.vx * dt, player.y + player.vy * dt
    local actualX, actualY, cols, len = map.world:move(player, goalX, goalY)
    player.x, player.y = actualX, actualY

    if len > 0 then
        player.canJump = true
    end
end

function game:load()
end

function game:update(dt)
    player:update(dt)
    map:update(dt)
	
    enemy:update(dt)
    -- TODO use beholder, make a signal, and move this update code
    -- to the player update function
    if love.keyboard.isDown('left') then
        player.vx = -player.speed
        player.direction=-1
    elseif love.keyboard.isDown('right') then
        player.vx = player.speed
        player.direction=1
    else
        player.vx = 0
    end
    if player.canJump and love.keyboard.isDown('up') then
        player.vy = -player.jumpSpeed
        player.canJump = false
    else
        player.vy = player.vy + GRAVITY
    end
end

function game:draw()
  cam:follow(player)

  -- start the camera
  cam:set()

  map:draw()

  enemy:draw()

  --love.graphics.rectangle('line', player.x, player.y, player.w, player.h)
  player1 = love.graphics.newImage('res/img/p1_spritesheet.png')
  stand=love.graphics.newQuad(0,0,70,95,player1:getDimensions())
  jump=love.graphics.newQuad(436,92,70,95,player1:getDimensions())
  run1=love.graphics.newQuad(0,92,70,95,player1:getDimensions())
  run2=love.graphics.newQuad(73,98,70,95,player1:getDimensions())
  local drawX = player.x
  if player.direction == -1 then
    drawX = drawX + player.w
  end
  time=love.timer.getTime() * 10
  if player.canJump then
    if (time % 6) > 3 then
      love.graphics.draw(player1, run1, drawX, player.y,0,player.direction,1)
    else
      love.graphics.draw(player1, run2, drawX, player.y,0,player.direction,1)
    end
  else
    if (time % 6) > 3 then
      love.graphics.draw(player1, jump, drawX, player.y,0,player.direction,1)
    else
      love.graphics.draw(player1, jump, drawX, player.y,0,player.direction,1)
    end
  end
  cam:unset()
end

return game
