if not BUSRIDE.check(Game.main_menu) then
    BUSRIDE.hookFunction("G.main_menu", Game, "main_menu")
    BUSRIDE.hookFunction("EventManager.clear_queue", EventManager, "clear_queue")
end