bump = require 'libs.bump'
fun = require 'libs.fun'
sti = require 'libs.sti'
beholder = require 'libs.beholder'
inspect = require 'libs.inspect'

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

function love.keypressed(key, scancode, isrepeat)
    if key == 'down' then
        beholder.trigger("player1-crouch")
    end

    if key == 's' then
        beholder.trigger("player2-crouch")
    end

    if key == "r" then
	    love.event.quit("restart")
    end
end

function love.keyreleased(key, scancode)
    if key == 'down' then
        beholder.trigger("player1-uncrouch")
    end

    if key == 's' then
        beholder.trigger("player2-uncrouch")
    end
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
        beholder.trigger("player1-left")
    end

    if love.keyboard.isDown("right") then
        beholder.trigger("player1-right")
    end

    if love.keyboard.isDown("up") then
        beholder.trigger("player1-up")
    end

    if love.keyboard.isDown("down") then
        beholder.trigger("player1-down")
    end

    if love.keyboard.isDown("space") then
        beholder.trigger("player1-fire")
    end

    if love.keyboard.isDown("a") then
        beholder.trigger("player2-left")
    end

    if love.keyboard.isDown("d") then
        beholder.trigger("player2-right")
    end

    if love.keyboard.isDown("w") then
        beholder.trigger("player2-up")
    end

    if love.keyboard.isDown("s") then
        beholder.trigger("player2-down")
    end

    if love.keyboard.isDown("f") then
        beholder.trigger("player2-fire")
    end

	if love.keyboard.isDown("return") then
		beholder.trigger("restart-game")
	end

    if love.keyboard.isDown("f8") then
        debug.debug()
    end

end
