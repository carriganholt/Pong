--[[
	ball class
	carrigan holt
]]

Ball = Class{}

--[[
	initialize ball
]]
function Ball:init(x, y, width, height)

    self.x = x
    self.y = y
    self.width = width
    self.height = height
	
	--set random velocity
    self.dy = math.random(2) == 1 and -100 or 100
    self.dx = math.random(2) == 1 and math.random(-80, -100) or math.random(80, 100)
	
end

--[[
	collision detection
]]
function Ball:collides(paddle)

	--check x axis
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end
	
	--check y axis
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end 
	
	--there is a collision
    return true
	
end

--[[
	reset ball
]]
function Ball:reset()

    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.dy = math.random(2) == 1 and -100 or 100
    self.dx = math.random(-50, 50)
	
end

--[[
	update ball
]]
function Ball:update(dt)

    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
	
end

--[[
	draw ball
]]
function Ball:render()

    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
	
end