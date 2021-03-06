-- This is a level file, it describes the level.
-- Lines with double dashes are a comment, they are ignored by the game.
local level = {}
level.number	=	2
level.name		=	"The Boxer"
level.enableAllButtons = false
level.enabledButtons = {
	CMD_ROTATE_CW, CMD_ROTATE_CCW, CMD_GRABDROP, CMD_EXTEND, CMD_INPUT, CMD_OUTPUT
}
level.tutorial = "boxer.png"

function level.load( l )
	l:setupWaldo( WALDO_GREEN, 1, 1, 2, RIGHT )
	l:setupWaldo( WALDO_RED, 8, 5, 2, LEFT )

	l:addItem( Input, 6, 5, PAINT_RED, PAINT_BLUE )
	l:addItem( Output, 10, 5, PAINT_RED, PAINT_BLUE )
	l:addItem( Boxer, 8, 3 )
end

return level
