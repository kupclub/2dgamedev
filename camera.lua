vec = require "libs.brinevector"
function clamp(low, n, high) return math.min(math.max(low, n), high) end

local camera = {}
camera.x = 0
camera.y = 0
camera.scaleX = 1
camera.scaleY = 1
camera.rotation = 0

function camera:set()
  love.graphics.push()
  love.graphics.rotate(-self.rotation)
  love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
  love.graphics.translate(-self.x, -self.y)
end

function camera:unset()
  love.graphics.pop()
end

function camera:move(dx, dy)
  self.x = self.x + (dx or 0)
  self.y = self.y + (dy or 0)
end

function camera:rotate(dr)
  self.rotation = self.rotation + dr
end

function camera:scale(sx, sy)
  sx = sx or 1
  self.scaleX = self.scaleX * sx
  self.scaleY = self.scaleY * (sy or sx)
end

function camera:setPosition(x, y)
  self.x = x or self.x
  self.y = y or self.y
end

function camera:setScale(sx, sy)
  self.scaleX = sx or self.scaleX
  self.scaleY = sy or self.scaleY
end

local cameraPadding = 600

function camera:follow(a, b)
    if type(a) ~= "table" then
      error("expected to follow a table object")
    end

    local av = vec(a.x + a.w / 2, a.y - a.h / 2)
    local bv = vec(b.x + b.w / 2, b.y - b.h / 2)
    local t = av - bv

    local x = math.min(av.x, bv.x) - cameraPadding / 2
    local y = math.min(av.y, bv.y) - cameraPadding / 2

    local w = math.abs(t.x) + cameraPadding
    local h = math.abs(t.y) + cameraPadding

    local s = math.max(w / love.graphics.getWidth(), h / love.graphics.getHeight(), 1)

    self.x = x
    self.y = y
    self.scaleX = s
    self.scaleY = s
end

return camera
