local game = {}

GRAVITY = 9.8

player = {
  speed = 180,
  jumpSpeed = 400,
  x = 0, y = 0,
  w = 70, h = 95,
  vx = 0, vy = 0,
  canJump = false,
  direction = 1,
  lastfire = 0,
  bullets = {},
  type = "player"
}


function player:left()
  self.vx = -self.speed
  self.direction=-1
end

function player:right()
  self.vx = self.speed
  player.direction=1
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
  beholder.observe("control-fire", function() player:fire() end)
end)

FIRETIME = 0.2
MAXBULLETS = 40

function player:fire()
  if love.timer.getTime() - self.lastfire > FIRETIME then
    local b = {type = 'bullet', x = self.x + self.w / 2, y = self.y + self.h / 2, vx = 400, vy = 0}
    map.world:add(b, b.x, b.y, 10, 10)
    table.insert(self.bullets, b)
    self.lastfire = love.timer.getTime()
  end
end

cam = require 'camera'
map = require 'map'

enemy = require 'enemy'

enemy:load()
map:load()

local foo = enemy:new("slime", 200,150)
map.world:add(enemy.stack[foo], enemy.stack[foo].x,enemy.stack[foo].y, 32,32)

function player:update(dt)
  player.vy = player.vy + GRAVITY
  local goalX, goalY = player.x + player.vx * dt, player.y + player.vy * dt
  local actualX, actualY, cols, len = map.world:move(player, goalX, goalY, function(item, other)
    if other.type == "bullet" then
      return nil
    end
    return "slide"
  end)
  player.x, player.y = actualX, actualY

  if len > 0 then
    player.canJump = true
  end

  -- reset vx so player input doesn't keep vx going when a key is released
  player.vx = 0

  for i, b in ipairs(player.bullets) do
    b.vy = b.vy + GRAVITY
    local x, y, _, _ = map.world:move(b, b.x + b.vx * dt, b.y + b.vy * dt,
    function(item, other)
      if other.type == "player" then
        return nil
      end
      return "slide"
    end)
    b.x = x
    b.y = y
    if #player.bullets > MAXBULLETS then
      map.world:remove(table.remove(player.bullets, 1))
    end
  end
end

function game:load()
end

function game:update(dt)
  player:update(dt)
  enemy:update(dt)
  map:update(dt)
end

player1 = love.graphics.newImage('res/img/p1_spritesheet.png')
stand=love.graphics.newQuad(0,0,70,95,player1:getDimensions())
jump=love.graphics.newQuad(436,92,70,95,player1:getDimensions())
run1=love.graphics.newQuad(0,92,70,95,player1:getDimensions())
run2=love.graphics.newQuad(73,98,70,95,player1:getDimensions())
gun1 = love.graphics.newImage('res/img/gun.png')

function game:draw()
  cam:follow(player)

  -- start the camera
  cam:set()

  map:draw()

  enemy:draw()

  --love.graphics.rectangle('line', player.x, player.y, player.w, player.h)
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
  if player.direction == 1 then
    love.graphics.draw(gun1, drawX+30, player.y+60,0,0.55,0.72)
  else
    love.graphics.draw(gun1, drawX-30, player.y+60,0,-0.55,0.72)
  end


  -- draw bullets
  for _, b in pairs(player.bullets) do
    love.graphics.rectangle('fill', b.x, b.y, 10, 10)
  end

  cam:unset()
end

return game
