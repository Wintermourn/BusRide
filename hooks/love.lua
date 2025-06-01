BUSRIDE.hookFunction("love.load", love, "load") -- This doesn't seem to be called after this mod loads, but why not have this?
BUSRIDE.hookFunction("love.update", love, "update")
BUSRIDE.hookFunction("love.draw", love, "draw")

BUSRIDE.hookFunction("love.mousemoved", love, "mousemoved")
BUSRIDE.hookFunction("love.mousepressed", love, "mousepressed")
BUSRIDE.hookFunction("love.mousereleased", love, "mousereleased")

BUSRIDE.hookFunction("love.keypressed", love, "keypressed")
BUSRIDE.hookFunction("love.keyreleased", love, "keyreleased")

BUSRIDE.hookFunction("love.gamepadpressed", love, "gamepadpressed")
BUSRIDE.hookFunction("love.gamepadreleased", love, "gamepadreleased")