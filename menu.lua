local Menu = {title = "TITLE HERE", options = {"Play", "Credits"}, oWidths = {}, selected = 1}

-- Define outside of draw function to prevent redefinition on every call
local largeFont = love.graphics.newFont("fonts/Berkshire_Swash/BerkshireSwash-Regular.ttf", 48)
local regFont = love.graphics.newFont("fonts/Berkshire_Swash/BerkshireSwash-Regular.ttf", 24)

-- Width of the menu strings to calculate the center of the screen
local tW = largeFont:getWidth(Menu.title)

for i,v in ipairs(Menu.options) do
	local newWidth = regFont:getWidth(v)
	Menu.oWidths[i] = newWidth
end

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
	
	-- Starting Y coordinate in px
	startingYCoord = 300
	yCoord = startingYCoord
	
	for i,v in ipairs(self.options) do
		if self.selected == i then
			-- Slightly darker than the sky blue in the game
			love.graphics.setColor(135, 206, 255)
		end

		love.graphics.printf(v, w/2 - self.oWidths[i]/2, yCoord, self.oWidths[i], "center")
		yCoord = yCoord + 50
		-- Reset the color
		love.graphics.setColor(255, 255, 255)
	end

	-- Set the color for the circle
	love.graphics.setColor(135, 206, 255)

	-- Add menu dots to the selected option
	love.graphics.circle("fill", w/2 - self.oWidths[self.selected], startingYCoord + (50 * (self.selected - 1)) + 15, 7)
	love.graphics.circle("fill", w/2 + self.oWidths[self.selected], startingYCoord + (50 * (self.selected - 1)) + 15, 7)

	-- Reset the color
	love.graphics.setColor(255, 255, 255)
end

function Menu:update(dt)
	-- If you press enter on the play option
	if love.keyboard.isDown("return") and self.selected == 1 then
		return "game"
	end
end

-- Built in call back
function love.keyreleased(key)
	if key == "up" then 
		if Menu.selected == 1 then 
			Menu.selected = table.getn(Menu.options) 
		else 
			Menu.selected = Menu.selected - 1 
		end
	end

	if key == "down" then 
		if Menu.selected == table.getn(Menu.options) then 
			Menu.selected = 1 
		else
			Menu.selected = Menu.selected + 1
		end	
	end
end

return Menu
