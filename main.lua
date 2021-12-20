--[[
	pong clone
	carrigan holt
]]

push = require 'push'
Class = require 'class'
require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243
PADDLE_SPEED = 200

--[[
	initializes screen
]]
function love.load()

	--change filter for pixellation
    love.graphics.setDefaultFilter('nearest', 'nearest')
	
	--set title
    love.window.setTitle('Pong')
	
	--set random seed
    math.randomseed(os.time())
	
	--create fonts
    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
	
	--set active font
    love.graphics.setFont(smallFont)
	
	--create sound objects
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }
	
	--initialize screen
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })
	
	--initialize score counters
    player1Score = 0
    player2Score = 0
	
	--initialize serve variable
    servingPlayer = 1
	
	--initialize paddles
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
	
	--initialize ball
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
	
	--set game state
    gameState = 'start'
	
end

--[[
	resize screen function
]]
function love.resize(w, h)

    push:resize(w, h)
	
end

--[[
	update frame function
]]
function love.update(dt)
	
	--serve game state
    if gameState == 'serve' then
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
		
		--play game state
    elseif gameState == 'play' then
	
		--player 1 ball bounce
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.1
            ball.x = player1.x + 5
			
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
			
            sounds['paddle_hit']:play()
        end
		
		--player 2 ball bounce
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.1
            ball.x = player2.x - 4
			
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
			
            sounds['paddle_hit']:play()
        end
		
		--bottom wall bounce
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end
		
		--top wall bounce
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end
		
		--player 2 score
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()
            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
		
		--player 1 score
        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()
            
            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end
	
	--player 1 controls
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end
	
	--player 2 controls
    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end
	
	--update ball
    if gameState == 'play' then
        ball:update(dt)
    end
	
	--update paddles
    player1:update(dt)
    player2:update(dt)
	
end

--[[
	keyboard handler function
]]
function love.keypressed(key)

	--'escape' key
    if key == 'escape' then
        love.event.quit()
		
	--'enter' key
    elseif key == 'enter' or key == 'return' then
	
        if gameState == 'start' then
            gameState = 'serve'
			
        elseif gameState == 'serve' then
            gameState = 'play'
			
        elseif gameState == 'done' then
            gameState = 'serve'
            ball:reset()
            player1Score = 0
            player2Score = 0
			
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
	
end

--[[
	draw function
]]
function love.draw()

    push:apply('start')
	
	--background color
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)
	
	--set active font
    love.graphics.setFont(smallFont)
	
	--display score
    displayScore()
	
	--start game state
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
		
	--serve game state
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
	
	--done play state
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end
	
	--draw objects
    player1:render()
    player2:render()
    ball:render()
	
	--show fps
    displayFPS()
	
    push:apply('end')
	
end

--[[
	display FPS function
]]
function displayFPS()

	--set active font
    love.graphics.setFont(smallFont)
	
	--set font color
    love.graphics.setColor(0, 255/255, 0, 255/255)
	
	--print string
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
	
end

--[[
	display score function
]]
function displayScore()

	--set active font
    love.graphics.setFont(scoreFont)
	
	--player 1 score
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
		
	--player 2 score
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
	
end
