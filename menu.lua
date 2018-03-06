local Menu = {title = "TITLE HERE", options = {"Play", "Credits"}}

-- Define outside of draw function to prevent redefinition on every call
local largeFont = love.graphics.newFont("fonts/Berkshire_Swash/BerkshireSwash-Regular.ttf", 48)
local regFont = love.graphics.newFont("fonts/Berkshire_Swash/BerkshireSwash-Regular.ttf", 24)

-- Width of the menu strings to calculate the center of the screen
local tW = largeFont:getWidth(Menu.title)
local pW = regFont:getWidth(Menu.options[1])
local cW = regFont:getWidth(Menu.options[2])

function Menu:load()
end

function Menu:draw()
	-- Width of the canvas
	local w = love.graphics.getWidth()

	-- Use largeFont for the title
	love.graphics.setFont(largeFont)
	love.graphics.printf(self.title, w/2 - tW/2, 150, tW, "center")

	-- Use regFont for menu options
	love.graphics.setFont(regFont)
	love.graphics.printf(self.options[1], w/2 - pW/2, 300, pW, "center")
	love.graphics.printf(self.options[2], w/2 - cW/2, 350, cW, "center")
end

function Menu:update(dt)
end

return Menu
