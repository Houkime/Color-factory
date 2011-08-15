local level = Gamestate.new()

function level:init()
	local lg = love.graphics
	level.header_image = lg.newImage('images/header.png')
	level.play_image	 = lg.newImage('images/play.png')
	level.pause_image	 = lg.newImage('images/pause.png')
	level.stop_image	 = lg.newImage('images/stop.png')
	level.togglewaldo_image = lg.newImage('images/togglewaldo.png')
end

function level:enter( previous, levelData )
	love.audio.stop()
	flash_sound:play()
	
	Objects 			= {}
	commandQueue 	= {}
	commandQueue[ WALDO_RED ]	 = CommandQueue:new( WALDO_RED )
	commandQueue[ WALDO_GREEN ] = CommandQueue:new( WALDO_GREEN )
	
	currentWaldo = WALDO_RED
	waldos		 = {}
	
	waldos[WALDO_GREEN] 	= Waldo:new( 0, 0, "Green Waldo", WALDO_GREEN )
	waldos[WALDO_GREEN]:setColor( 55, 255, 55 )
	waldos[WALDO_RED] 	= Waldo:new( 0, 0, "Red Waldo", WALDO_RED )
	waldos[WALDO_RED]:setColor( 255, 55, 55 )
	
	dtTimer = 0
	waitingQueue = {}
	
	self.levelData = levelData
	self:loadLevel( levelData )
	
	-- create playback buttons.
	Button:new( level.togglewaldo_image, 870, 12, {255,255,255}, switchWaldo )
	Button:new( level.stop_image, 900, 12, {255,255,255}, resetLevel )
	Button:new( level.pause_image, 930, 12, {255,255,255}, Beholder.trigger, 'pause' )
	Button:new( level.play_image, 960, 12, {255,255,255}, Beholder.trigger, 'play' )
	
	self.fade = { a = 255 }
	Tween( 3, self.fade, { a = 0 }, 'inQuad' )
end

function level:leave()
	self:saveState()
	Objects = nil
	commandQueue = nil
	waldos = nil
	waitingQueue = nil
	currentLevel = nil
	Button.instances = {}
end

function level:quit()
	self:saveState()
end

function level:update( dt )
	Tween.update(dt)
	local dt = dt * GAME_SPEED
	
	for k, v in ipairs( Objects ) do
		v:update( dt )
	end
	
	dtTimer = dtTimer + dt
	if dtTimer >= 1 then
		dtTimer = 0
		commandQueue[WALDO_RED]:runCommand()
		commandQueue[WALDO_GREEN]:runCommand()
	end
end

function level:draw()
	local lg = love.graphics
	-- Draw grid lines.
	lg.setColor( 64, 64, 64 )
	lg.setLine( 1, 'rough' )
	for x = 0, 1024, TILE_SIZE do
		lg.line( x, 0, x, 768 )
	end
	for y = 0, 768, TILE_SIZE do
		lg.line( 0, y, 1024, y )
	end
	lg.setLine( 1, 'smooth' )
	
	-- Draw items.
	table.sort( Objects, function(a,b) return a.z < b.z end)
	for k, v in ipairs( Objects ) do v:draw() end
	
	-- Draw header image.
	lg.setColor( 255, 255, 255, 255 )
	lg.draw( self.header_image, 0, 0 )
	
	-- Draw commands.
	for k, v in pairs( commandQueue ) do v:draw( 0, (k*40)+7 ) end
	
	-- Draw currently selected waldo color.
	lg.setColor( waldos[currentWaldo].color )
	lg.setLine( 10, 'rough' )
	lg.line( 0, 0, 1024, 0 )
	
	Button:apply('draw')
	
	lg.setColor( 255,255,255,50 )
	lg.rectangle( 'fill', 512-25, 40, 50, 87 )
	
	-- draw tutorial.
	if self.tutorial then
		lg.setColor( 255, 255, 255, 255 )
		lg.rectangle( 'fill', 0, 184-25, 1024, 400+(25*2) )
		lg.setColor( 255, 255, 255, 255 )
		lg.draw( self.tutorial, 0, 184 )
	end
	
	-- draw fade in.
	lg.setColor( 255, 255, 255, self.fade.a )
	lg.rectangle( 'fill', 0, 0, 1024, 768 )
end

function setupWaldo( waldoColor, gridX, gridY, length, direction )
	waldos[waldoColor]:setup( gridX, gridY+2, length, direction )
	waldos[waldoColor].disabled = false
end

function removeWaldo( waldoColor )
	waldos[waldoColor].disabled = true
end

function addItem( className, gridX, gridY, ... )
	item = className:new()
	item:setup( gridX, gridY+2, ... )
	return item
end

function resetLevel()
	-- Stop all command queues.
	Beholder.trigger("stop")
	Beholder.trigger("resetInputs")
	-- Reload all objects to their saved position.
	for k, v in ipairs( Objects ) do
		v:loadPos()
	end
	
	clearPaint()
	waitingQueue = {}
end

function clearPaint()
	local size = #Objects
	for i=1,size do
		local obj = Objects[i]
		if obj and instanceOf( Paint, obj ) then
			obj:destroy()
		end
	end
end

function switchWaldo()
	if currentWaldo == WALDO_RED then
		currentWaldo = WALDO_GREEN
	else
		currentWaldo = WALDO_RED
	end
end

function level:mousepressed( x, y, key )
	for k, v in ipairs( Objects ) do
		v:mousepressed( x, y, key )
	end
	
	if self.tutorial then self.tutorial = nil end
	
	Button:apply('onMousePressed', x, y, key )
end

function level:mousereleased( x, y, key )
	
	for k, v in ipairs( Objects ) do
		v:mousereleased( x, y, key )
	end
end

function level:keypressed( key, unicode )
	if key == 'tab' then
		switchWaldo()
	elseif key == 'q' then
		commandQueue[currentWaldo]:addCommand( CMD_ROTATE_CCW )
	elseif key == 'w' then
		commandQueue[currentWaldo]:addCommand( CMD_GRABDROP )
	elseif key == 'e' then
		commandQueue[currentWaldo]:addCommand( CMD_ROTATE_CW )
	elseif key == 'r' then
		commandQueue[currentWaldo]:addCommand( CMD_EXTEND )
	elseif key == 'i' then
		--commandQueue[currentWaldo]:addCommand( CMD_INPUT )
	elseif key == 'o' then
		--commandQueue[currentWaldo]:addCommand( CMD_OUTPUT )
	elseif key == 'a' then
		commandQueue[currentWaldo]:addCommand( CMD_SENSE )
	elseif key == 's' then
		commandQueue[currentWaldo]:addCommand( CMD_JUMP )
	elseif key == 'd' then
		commandQueue[currentWaldo]:addCommand( CMD_LOOPIN )
	elseif key == ' ' then
		for k, v in pairs( commandQueue ) do v:toggleRun() end
	elseif key == '.' then
		resetLevel(  )
	elseif key == 'up' then
		GAME_SPEED = GAME_SPEED * 2
	elseif key == 'down' then
		GAME_SPEED = GAME_SPEED / 2
	elseif key == 'backspace' then
		commandQueue[currentWaldo]:removeCommand()
	elseif key == 't' then
		commandQueue[currentWaldo]:addCommand( CMD_VERTICAL )
	elseif key == 'f' then
		commandQueue[currentWaldo]:addCommand( CMD_HORIZONTAL )
	elseif key == 'left' then
		commandQueue[currentWaldo]:prev()
	elseif key == 'right' then
		commandQueue[currentWaldo]:next()
	elseif key == 'x' then
		commandQueue[currentWaldo]:addCommand( CMD_JUMPOUT )
	elseif key == 'escape' then
		Gamestate.switch( stateMenu )
	elseif key == 'k' then
		self:saveState()
	elseif key == 'l' then
		self:loadState()
	end
end

function level:loadLevelNumber( levelNumber )
	clearPaint()
	
	local levelData = loadfile(LEVEL_PATH .. 'level_' .. levelNumber .. '.lua')
	currentLevel = levelData()
	currentLevel.load()
	
	if currentLevel.enableAllButtons then
		Button.createCommands()
	else
		Button.createCommands( currentLevel.enabledButtons )
	end
	
	self.cash = 0
end

function level:loadLevel( levelData )
	self.cash = 0
	
	levelData.load()
	if levelData.enableAllButtons then
		Button.createCommands()
	else
		Button.createCommands( levelData.enabledButtons )
	end
	
	if levelData.tutorial then
		self.tutorial = love.graphics.newImage("images/tutorials/"..levelData.tutorial)
	end
	
	self:loadState()
end

function level:onOutputSuccessfull()
	self.cash = self.cash + 10
	print( "$" .. self.cash )
end

function addCommand( waldoColor, command )
	commandQueue[ waldoColor ]:addCommand( command )
end

function moveWaldo( waldoColor, gridX, gridY )
	local waldo = waldos[ waldoColor ]
	waldo:setGridPos( gridX, gridY )
end

function moveItem( idString, gridX, gridY )
	for i,v in ipairs(Objects) do
		if v.idString == idString then 
			v:setGridPos( gridX, gridY )
			break
		end
	end
end

function level:loadState()
	local fs = love.filesystem
	local format = string.format

	local saveFilename
	if self.levelData.custom then
	   saveFilename = format( "levelsave_%s.lua", self.levelData.filename )
	else
	   saveFilename = format( "levelsave_%03d.lua", self.levelData.number )
	end
	
	if love.filesystem.exists( saveFilename ) then
		local saveChunk = fs.load( saveFilename )
		local saveTable = saveChunk()
		resetLevel()
		commandQueue[ WALDO_RED ]:clearCommands()
		commandQueue[ WALDO_GREEN ]:clearCommands()
		saveTable.load()
		return true
	end
end

function level:saveState()
	local fs = love.filesystem
	local format = string.format
	
	local saveFilename
	if self.levelData.custom then
	   saveFilename = format( "levelsave_%s.lua", self.levelData.filename )
	else
	   saveFilename = format( "levelsave_%03d.lua", self.levelData.number )
	end
	
	local savefile = fs.newFile( saveFilename )
	savefile:open('w')
	savefile:write("local save = {}\n")
	savefile:write("function save.load()\n")
	for i,v in ipairs(commandQueue[WALDO_RED].commands) do
		savefile:write( format( "addCommand(%d,%d)\n", WALDO_RED, v ) )
	end
	for i,v in ipairs(commandQueue[WALDO_GREEN].commands) do
		savefile:write( format( "addCommand(%d,%d)\n", WALDO_GREEN, v ) )
	end
	for i,v in ipairs(Objects) do
		if not instanceOf( Paint, v ) and not instanceOf( InputOutput, v ) and not instanceOf( Waldo, v) then
			local pos = v:gridPos()
			savefile:write( format( "moveItem('%s',%d,%d)\n", v.idString, pos.x, pos.y ) )
		end
	end
	savefile:write( format( "moveWaldo(%d,%d,%d)\n", WALDO_RED, waldos[WALDO_RED]:gridPos().x, waldos[WALDO_RED]:gridPos().y ) )
	savefile:write( format( "moveWaldo(%d,%d,%d)\n", WALDO_GREEN, waldos[WALDO_GREEN]:gridPos().x, waldos[WALDO_GREEN]:gridPos().y ) )
	savefile:write("end\n")
	savefile:write("return save\n")
	savefile:close()
end

return level