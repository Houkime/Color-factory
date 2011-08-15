require "MenuButton"
local menu = Gamestate.new()

function menu:init()
	font_secretcode_16 = love.graphics.newFont( 'fonts/SECRCODE.TTF', 16 )
	self.levelData = self:loadLevels()
	self.buttons = {}
	local title
	for i, level in ipairs( self.levelData ) do
	   if level.author then
	      title = string.format( "%s (by %s)", level.name, level.author )
	   else
	      title = level.name
	   end
		self.buttons[#self.buttons+1] = MenuButton:new( 100, 100+(i-1)*28, title, self.runLevel, self, level )
	end
	
	self.keys = [[
tab    - switch waldo
left   - previous command
right  - next command
backspace - remove command
l      - load
k      - save
escape - return to menu at any time
f12    - toggle fullscreen
m      - toggle mute
space  - run / pause program
period - stop program
up     - speed up program
down   - slow down program
]]
end

function menu:enter( previous )
end

function menu:update( dt )
	for i, button in ipairs( self.buttons ) do button:update(dt) end
	if splash_song:isStopped() then
		menu_song:play()
	end
end

function menu:draw()
	love.graphics.setBackgroundColor( 30, 30, 30 )
	love.graphics.setFont( font_secretcode_12 )
	for i, button in ipairs( self.buttons ) do button:draw() end
	love.graphics.setColor( 255,255,255,255 )
	love.graphics.print( self.keys, 450, 100 )
	love.graphics.print( "v"..GAME_VERSION, 10, 10 )
end

function menu:mousepressed( x, y, key )
	for i, button in ipairs( self.buttons ) do button:mousereleased( x, y, key ) end
end

function menu:runLevel( level )
	Gamestate.switch( stateLevel, level )
end

function menu:loadLevels()
	local lfs = love.filesystem
	
	local levelData = {}
	self:readLevelFiles( "levels/", levelData )
	self:readLevelFiles( "customlevels/", levelData )
	
	return levelData
end

function menu:readLevelFiles( levelDir, levelData )
	local lfs = love.filesystem
	local levelFilenames = lfs.enumerate( levelDir )
	local levelChunks = {}
	for i, levelFilename in ipairs( levelFilenames ) do
		local chunkPos =  #levelChunks+1
		local dataPos	=  #levelData+1
		levelChunks[chunkPos] 	= lfs.load( levelDir .. levelFilename )
		levelData[dataPos] 		= levelChunks[chunkPos]() 
		levelData[dataPos].filename = string.sub( levelFilename, 1, -5 )
	end
	return levelData
end

return menu