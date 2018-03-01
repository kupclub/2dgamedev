bump = require 'libs.bump'
fun = require 'libs.fun'
sti = require 'libs.sti'
menu = require 'menu'
game = require 'game'
beholder = require 'libs.beholder'

-- math utility function
require 'math'

function sandboxLoad(file)
    local scriptEnv = {}
    local chunk = loadfile(file)
    setfenv(chunk, scriptEnv)
    return scriptEnv, chunk()
end

curState = game

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
    curState:update(dt)
end
