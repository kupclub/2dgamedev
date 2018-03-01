local Menu = {options = {"Play", "Credits"}}

function Menu:draw()
	local largeFont = love.graphics.newFont("fonts/Berkshire_Swash/BerkshireSwash-Regular.ttf", 48)
	local regFont = love.graphics.newFont("fonts/Berkshire_Swash/BerkshireSwash-Regular.ttf", 24)

	-- Width of the canvas
	local w = love.graphics.getWidth()
	local title = "TITLE HERE"

	-- Width of the menu strings to calculate the center of the screen
	local tW = largeFont:getWidth(title)
	local pW = regFont:getWidth(self.options[1])
	local cW = regFont:getWidth(self.options[2])

	-- Use largeFont for the title
	love.graphics.setFont(largeFont)
	love.graphics.printf("TITLE HERE", w/2 - tW/2, 150, tW, "center")

	-- Use regFont for menu options
	love.graphics.setFont(regFont)
	love.graphics.printf(self.options[1], w/2 - pW/2, 300, pW, "center")
	love.graphics.printf(self.options[2], w/2 - cW/2, 350, cW, "center")
end

return Menu
