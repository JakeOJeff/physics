local class = require("middleclass")

-- Define the Slider class
Slider = class("Slider")
local Sliders = {}

function Slider:initialize(x, y, width, height, min, max)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.min = min
    self.max = max
    self.value = min -- Initial value
    self.dragging = false
    table.insert(Sliders, self)
	return self
end

function Slider:update()
    if self.dragging then
        local mx, _ = love.mouse.getPosition()
        -- Calculate the value based on the mouse position
        self.value = self.min + (mx - self.x) / self.width * (self.max - self.min)
        -- Clamp the value to the min and max range
        self.value = math.max(self.min, math.min(self.max, self.value))
    end
end

function Slider:draw()
    -- Draw the slider track
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", self.x, self.y + self.height / 2 - 2, self.width, 4)
    
    -- Draw the slider knob
    local knobX = self.x + (self.value - self.min) / (self.max - self.min) * self.width
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", knobX - 5, self.y, 10, self.height)
end

function Slider:mousepressed(mx, my, button)
    if button == 1 and mx >= self.x and mx <= self.x + self.width and my >= self.y and my <= self.y + self.height then
        self.dragging = true
    end
end

function Slider:mousereleased(mx, my, button)
    if button == 1 then
        self.dragging = false
    end
end
function Slider:getValue()
    return self.value
end
function mousepressed_sliders(x, y, button)
    for i, v in pairs(Sliders) do
		v:mousepressed(x, y, button)
	end
end
function mousereleased_sliders(x, y, button)
    for i, v in pairs(Sliders) do
		v:mousereleased(x, y, button)
	end
end
function update_sliders()
	for i, v in pairs(Sliders) do
		v:update()
	end
end

function draw_sliders()
	for i, v in pairs(Sliders) do
		v:draw()
	end 
end
-- Example usage

