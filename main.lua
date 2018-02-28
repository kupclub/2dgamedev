bump = require 'libs.bump'
fun = require 'libs.fun'
sti = require 'libs.sti'
beholder = require 'libs.beholder'

map = require 'map'

GRAVITY = 9.8

player = {
    speed = 180,
    jumpSpeed = 200,
    x = 0, y = 0,
    w = 10, h = 10,
    vx = 0, vy = 0,
    canJump = false
}

map:load()

function player:update(dt)
    local goalX, goalY = player.x + player.vx * dt, player.y + player.vy * dt
    local actualX, actualY, cols, len = map.world:move(player, goalX, goalY)
    player.x, player.y = actualX, actualY

    if len > 0 then
        player.canJump = true
    end
end

function love.draw()
    map:draw()
    love.graphics.rectangle('fill', player.x, player.y, player.w, player.h)
end

function love.update(dt)
    player:update(dt)
    map:update(dt)

    -- TODO use beholder, make a signal, and move this update code
    -- to the player update function
    if love.keyboard.isDown('left') then
        player.vx = -player.speed
    elseif love.keyboard.isDown('right') then
        player.vx = player.speed
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