-- Declaration of classes and libraries required
push = require 'push'
Class = require 'class'
require 'Paddle'
require 'Ball'

-- Definition of window real and virtual size
WIN_H = 720
WIN_W = 1280
VIRTUAL_W= 432
VIRTUAL_H= 243

-- This function is called exactly once at the beginning of the game.
-- It sets variables and resources so that they can be used repeatedly in other functions
function love.load()

	-- Defines window title
	love.window.setTitle('Pong VACL')

	-- Sets the default scaling filters used with Images, Canvases, and Fonts.
	love.graphics.setDefaultFilter('nearest', 'nearest')

	-- Plants random seed
	math.randomseed(os.time())
	
	-- Definition and set of fonts
	smallFont=love.graphics.newFont('fonts/font.ttf',16)
	scoreFont=love.graphics.newFont('fonts/font.ttf',36)
	love.graphics.setFont(smallFont)
	
	-- Initialization of the window
	push:setupScreen(VIRTUAL_W, VIRTUAL_H, WIN_W, WIN_H,{ fullscreen = false, resizable = false, vsync = true})
	
	-- Initialization of the ball
	ball = Ball(VIRTUAL_W/2-3, VIRTUAL_H/2-3,6,6)

	-- Initialization of the 2 paddles (players)
	player1 = Paddle(10,VIRTUAL_H/2-13,6,25)
	player2 = Paddle(VIRTUAL_W-16,VIRTUAL_H/2-13,6, 25)
	
	-- Initialiation of player's scores
	pl1score = 0
	pl2score = 0
	
	-- Initialization of the player's turn to serve
	servingPlayer = 1
	
	-- Initializaiton of Paddles and Ball velocities
	paddleSpeed = 150 -- Initial Paddle velocity
	levelSpeedL = 100 -- Initial Lower limit on ball velocity
	levelSpeedU = 120 -- Initial Upper limit on ball velocity

	-- Initialization of the game's state machine
	gameState = 'start'

	-- Definition of the image resources
	logo = love.graphics.newImage("images/ponglogo.png")

	-- Definition of the sound resources
	sounds = {
		['walls'] = love.audio.newSource('sounds/walls.wav', 'static'),
        ['point'] = love.audio.newSource('sounds/point.wav', 'static'),
		['paddles'] = love.audio.newSource('sounds/paddles.wav', 'static'),
        ['gameover'] = love.audio.newSource('sounds/gameover.wav', 'static')
    }
end

-- Callback function triggered when a key is pressed.
-- Game's state machine and other variables change according to the definitions in this function
function love.keypressed(key)

	-- Definition to quit the game
    if key == 'escape' then 
        love.event.quit()

	-- Definitions to change game's state machine
	elseif key == 'enter' or key == 'return' then
		if gameState=='start' then
			gameState ='serve'

		elseif gameState=='serve' then
			gameState ='play'
		
		-- Besides changing state machine, it resets game variables when the game finishes
		elseif gameState == 'done' then
			gameState = 'serve'
			pl1score=0
			pl2score=0
			ball:reset()
			if winningPlayer == 1 then
				servingPlayer = 2

			else
				servingPlayer = 1
			end
		end
    end
end

-- Callback function used to update the state of the game every frame.
-- Actions are taken based on the state of the game's state machine
function love.update(dt)

	-- Sets ball direction and velocity based on the serving turn
	if gameState == 'serve' then
		if servingPlayer == 1 then 
			ball.dx = math.random(levelSpeedL,levelSpeedU)

		else 
			ball.dx = -math.random(levelSpeedL,levelSpeedU)

		end
		ball.dy = math.random(levelSpeedL,levelSpeedU)

	-- Chages ball's direction in case of collision
	elseif gameState == 'play' then

		-- Top wall
		if ball.y <= 0 then
			ball.y = 0
			ball.dy = -ball.dy
			sounds['walls']:play() -- Wall collision sound
		end
		
		-- Bottom wall collision
		if ball.y >= VIRTUAL_H -6 then
			ball.y =  VIRTUAL_H -6 
			ball.dy = -ball.dy
			sounds['walls']:play() -- Wall collision sound
		end

		-- Player 1 interception
		if ball:collides(player1) then
			ball.dx=-ball.dx * 1.10
			ball.x = player1.x + 6
			if ball.dy <0 then
				ball.dy = -math.random(levelSpeedL,levelSpeedU)
			else
				ball.dy = math.random(levelSpeedL,levelSpeedU)
			end
			sounds['paddles']:play() -- Paddle collision sound

			-- Paddle speed increases and interval limits of the ball velocity increase too
			paddleSpeed = paddleSpeed+5
			levelSpeedL = levelSpeedL+6
			levelSpeedU = levelSpeedU+6

		end
		
		-- Player 2 interception
		if ball:collides(player2) then
			ball.dx=-ball.dx * 1.10
			ball.x = player2.x - 6
			if ball.dy <0 then
				ball.dy = -math.random(levelSpeedL,levelSpeedU)
			else
				ball.dy = math.random(levelSpeedL,levelSpeedU)
			end
			sounds['paddles']:play() -- Paddle collision sound
			
			-- Paddle speed increases and interval limits of the ball velocity increase too
			paddleSpeed = paddleSpeed+5
			levelSpeedL = levelSpeedL+6
			levelSpeedU = levelSpeedU+6
			
		end
	end

	-- Changes score and game state if 10 points are reached by any player

	-- Player 2 scores a point
	if ball.x<0 then 
		pl2score=pl2score+1
		if pl2score == 10 then 
			winningPlayer = 2
			gameState = 'done'
			sounds['gameover']:play() -- Game over sound

			-- Paddle and ball velocities are reset
			paddleSpeed = 150
			levelSpeedL = 100
			levelSpeedU = 120
		else
			servingPlayer = 1
			gameState = 'serve'
			sounds['point']:play() -- Point scored sound
		end
		ball:reset()
	end
	
	-- Player 1 scores a point
	if ball.x>VIRTUAL_W then 
		pl1score=pl1score+1
		if pl1score == 10 then 
			winningPlayer = 1
			gameState = 'done'
			sounds['gameover']:play() -- Game over sound

			-- Paddle and ball velocities are reset
			paddleSpeed = 150
			levelSpeedL = 100
			levelSpeedU = 120
		else
			servingPlayer = 2
			gameState = 'serve'
			sounds['point']:play() -- Point scored sound
		end
		ball:reset()
	end

	-- Player's 1 movement definition
	if love.keyboard.isDown('w')then
		player1.dy = -paddleSpeed
	elseif love.keyboard.isDown('s')then
		player1.dy = paddleSpeed
	else
		player1.dy = 0
	end
	
	-- Player's 2 movement definition
	if love.keyboard.isDown('up')then
		player2.dy = -paddleSpeed
	elseif love.keyboard.isDown('down')then
		player2.dy = paddleSpeed
	else	
		player2.dy = 0
	end
	
	-- Ball's position definition
	if gameState == 'play' then
		ball:update(dt)
	end

	-- Players' position definition
	player1:update(dt)
	player2:update(dt)
end

-- Callback function used to draw on the screen every frame.
-- Based on the state of the game's state machine, the screen is set to show or not specific resources
function love.draw()
	
	-- Set of background color
	love.graphics.setBackgroundColor( 255, 255, 255 )
	love.graphics.clear(love.graphics.getBackgroundColor())
	
	-- Drawing starts
	push:apply("start")

	-- Sets color and font to be used in game messages
	love.graphics.setColor(0,0,0)
	love.graphics.setFont(smallFont)

	-- Draws information according to game state
	if gameState =='start' then 
		love.graphics.setColor(255,255,255) -- Resets color to correctly draw the image
		love.graphics.draw(logo,VIRTUAL_W/2-16,VIRTUAL_H/2-50,0,0.1,0.1) -- Draws Image
		love.graphics.setColor(0,0,0)		-- Resets color to be used in game messages

		-- Draws messages of 'start' game state
		love.graphics.printf('Welcome to Pong!',0, 10 ,VIRTUAL_W,'center')
		love.graphics.printf('\nPress enter to begin',0, 20 ,VIRTUAL_W,'center')

	elseif gameState == 'serve' then
		-- Draws messages of 'serve' game state
		love.graphics.printf('Player ' .. tostring(servingPlayer) .. ' serving',0, 10 ,VIRTUAL_W,'center')
		love.graphics.printf('\nHello players!',0, 20 ,VIRTUAL_W,'center')

	elseif gameState == 'done' then
		-- Draws messages of 'done' game state
		love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',0, 10 ,VIRTUAL_W,'center')
		love.graphics.printf('\nPress enter to play again',0, 20 ,VIRTUAL_W,'center')
	else
		-- Pass
	end

	-- Draws Scoreboard
	love.graphics.setFont(scoreFont)
	love.graphics.print(tostring(pl1score),VIRTUAL_W/2-50, VIRTUAL_H/4)
	love.graphics.print(tostring(pl2score),VIRTUAL_W/2+30, VIRTUAL_H/4)
	
	-- Draws Ball and Players (paddles)
	player1:render()
	player2:render()
	ball:render() 	
	
	-- Drawing finishes
	push:apply("end")
end