
Paint = Node:subclass("Paint")
Paint.image = love.graphics.newImage( 'images/objects/paint.png' )

PAINT_ANY		= 0
PAINT_RED 		= 1
PAINT_YELLOW 	= 2
PAINT_ORANGE	= 3
PAINT_BLUE		= 4
PAINT_PURPLE	= 5
PAINT_GREEN		= 6
PAINT_ANY		= 7

Paint.colors	= {}
Paint.colors[PAINT_ANY]		= { 255, 255, 255 }
Paint.colors[PAINT_RED]		= { 255, 0, 0 }
Paint.colors[PAINT_YELLOW]	= { 255, 255, 0 }
Paint.colors[PAINT_BLUE]	= { 0, 0, 255 }
Paint.colors[PAINT_GREEN]	= { 0, 255, 0 }
Paint.colors[PAINT_ORANGE]	= { 255, 128, 0 }
Paint.colors[PAINT_PURPLE] = { 128, 0, 255 }

function Paint:initialize(...)
	Node.initialize( self, ... )
	table.insert( Objects, self )
	self.moveCount = 0
	self:setZ( 999 )
end

function Paint:update( dt )
	if self.isMoving then
		local direction = (self.targetPos - self.pos):normalized() * TILE_SIZE * dt
		self:moveBy( direction )
		self.moveCount = self.moveCount + direction:len()
		if self.moveCount >= TILE_SIZE then
			self.moveCount = 0
			self.isMoving = false
			self.pos = self.targetPos
		end
	end
end

function Paint:setColor( paintColor )
	self.paintColor = paintColor
end

function Paint:draw( override )
   if self.isHidden and not override then return false end
   
	love.graphics.setColor( Paint.colors[self.paintColor] )
	love.graphics.draw( self.image, self.pos.x - 7, self.pos.y - 7)
	--love.graphics.circle( 'fill', self.pos.x, self.pos.y, 5, 50 )
end