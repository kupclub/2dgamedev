bump = require 'libs.bump'
fun = require 'libs.fun'
sti = require 'libs.sti'
beholder = require 'libs.beholder'

states = {
    menu = require 'menu',
    game = require 'game'
}

-- math utility function
require 'math'

function sandboxLoad(file)
    local scriptEnv = {}
    local chunk = loadfile(file)
    setfenv(chunk, scriptEnv)
    return scriptEnv, chunk()
end

curState = states.game

function love.load()
    if not curState["load"] then
        error("YOU NEED TO IMPLEMENT A LOAD CALL!")
    end
    curState:load()
end

function love.draw()
    if not curState["draw"] then
        error("YOU NEED TO IMPLEMENT A DRAW CALL!")
    end
    curState:draw()
end

function love.update(dt)
    if not curState["update"] then
        error("YOU NEED TO IMPLEMENT AN UPDATE CALL! (with signature module:update(dt))")
    end

    local r = curState:update(dt)
    -- XXX: for now, we assume that any string is a request to change state
    if type(r) == "string" then
        if not states[r] then
            error("invalid state", r)
        end
        curState = states[r]
        curState:load()
    end

    if love.keyboard.isDown("left") then
        beholder.trigger("control-left")
    end

    if love.keyboard.isDown("right") then
        beholder.trigger("control-right")
    end

    if love.keyboard.isDown("up") then
        beholder.trigger("control-up")
    end

    if love.keyboard.isDown("down") then
        beholder.trigger("control-down")
    end
end
