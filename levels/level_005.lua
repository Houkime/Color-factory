-- This is a level file, it describes the level.
-- Lines with double dashes are a comment, they are ignored by the game.
local level = {}
level.number	=	5
level.name		=	"Using your senses"
level.enableAllButtons = true
level.enabledButtons = {
	CMD_ROTATE_CW, CMD_ROTATE_CCW, CMD_GRABDROP, CMD_EXTEND, CMD_HORIZONTAL, CMD_VERTICAL, CMD_WAIT, CMD_LOOP
}
level.tutorial = "sensor.png"

function level.load( l )
	l:setupWaldo( WALDO_GREEN, 4, 7, 2, LEFT )
	l:setupWaldo( WALDO_RED, 8, 7, 2, LEFT )

	l:addItem( Input, 4, 2, PAINT_PURPLE, PAINT_GREEN, PAINT_GREEN, PAINT_GREEN )
	l:addItem( Output, 10, 4, PAINT_GREEN )
	l:addItem( Output, 10, 5, PAINT_PURPLE )
	l:addItem( Sensor, 8, 3, PAINT_PURPLE )
end

return level
