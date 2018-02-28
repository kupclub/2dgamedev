local Menu = {options = {"Play", "Credits"}}

function Menu:show()
	local font = love.graphics.newFont("fonts/Berkshire_Swash/BerkshireSwash-Regular.ttf", 20)
	love.graphics.setFont(font)
	-- Width of the canvas
	local w = love.graphics.getWidth()
	local title = "TITLE HERE"
	-- Width of the menu strings to calculate the center of the screen
	local tW = font:getWidth(title)
	local pW = font:getWidth(self.options[1])
	local cW = font:getWidth(self.options[2])
	love.graphics.printf("TITLE HERE", w/2 - tW/2, 150, tW, "center")
	love.graphics.printf(self.options[1], w/2 - pW/2, 300, pW, "center")
	love.graphics.printf(self.options[2], w/2 - cW/2, 350, cW, "center")
end

return Menu
