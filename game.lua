local game = {}

GRAVITY = 9.8

player = {
    speed = 180,
    jumpSpeed = 200,
    x = 0, y = 0,
    w = 70, h = 95,
    vx = 0, vy = 0,
    canJump = false
}

function player:left()
  self.vx = -self.speed
end

function player:right()
  self.vx = self.speed
end

function player:jump()
  if self.canJump then
    self.vy = -self.jumpSpeed
    self.canJump = false
  end
end

beholder.group(player, function()
  beholder.observe("control-up", function() player:jump() end)
  --beholder.observe("control-down", player:jump)
  beholder.observe("control-left", function() player:left() end)
  beholder.observe("control-right", function() player:right() end)
end)

cam = require 'camera'
map = require 'map'
map:load()

function player:update(dt)
    player.vy = player.vy + GRAVITY
    local goalX, goalY = player.x + player.vx * dt, player.y + player.vy * dt
    local actualX, actualY, cols, len = map.world:move(player, goalX, goalY)
    player.x, player.y = actualX, actualY

    if len > 0 then
        player.canJump = true
    end

    -- reset vx so player input doesn't keep vx going when a key is released
    player.vx = 0
end

function game:load()
end

function game:update(dt)
    player:update(dt)
    map:update(dt)
end

function game:draw()
  cam:follow(player)

  -- start the camera
  cam:set()

  map:draw()
  --love.graphics.rectangle('line', player.x, player.y, player.w, player.h)
  player1 = love.graphics.newImage('res/img/p1_spritesheet.png')
  stand=love.graphics.newQuad(0,0,70,95,player1:getDimensions())
  jump=love.graphics.newQuad(436,92,70,95,player1:getDimensions())
  if player.canJump then
    love.graphics.draw(player1, stand, player.x, player.y)
  else
    love.graphics.draw(player1, jump, player.x, player.y)
  end
  cam:unset()
end

return game
