bump = require 'libs.bump'
fun = require 'libs.fun'
sti = require 'libs.sti'
beholder = require 'libs.beholder'
repl = require 'libs.repl'

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
    repl.initialize()
end

function love.mousepressed(x, y, button)
  if repl.toggled() then
    repl.mousepressed(x, y, button)
    return
  end
end

function love.keypressed(k, u)
  if repl.toggled() then
    repl.keypressed(k, u)
    return
  end
  -- Your key handling code here

  -- You'll need a key bound to open the REPL, f8 by default
  -- If you want to change it, set repl.toggle_key to that key before doing so
  -- Note that love-repl doesn't care about key modifiers like ctrl, shift, etc.
  -- So if you want your toggle to be Shift-F8, that's fine, but set toggle_key to 'f8'.

  if k == 'f8' then
    repl.toggle()
  end
end

function love.textinput(t)
  if repl.toggled() then
    repl.textinput(t)
  end
end

function love.draw()
    if repl.toggled() then
        repl.draw()
        return
    end

    if not curState["draw"] then
        error("YOU NEED TO IMPLEMENT A DRAW CALL!")
    end
    curState:draw()
end

function love.update(dt)
    if repl.toggled() then
        return
    end

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
