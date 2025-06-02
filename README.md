# Event Bus Ride
Provides an event bus system to Love and Balatro specific functions.
Also provides async task support!

## Installation
This system is a mod for *Balatro* and requires *Steamodded* to run.
Simply place into your mods folder and it should work fine.

Alternatively, if you want to pack this mod in with yours as a library, that's also possible! Just run `SMODS.load_file("path/to/busride.lua")("path/to/busride/")` and it will automatically load.

## Usage
### Event Bus
`BUSRIDE.on(eventName, fun(...): (...), order: integer?)`
- Activates whenever event is fired
- Arguments depend on the event
- Return values depend on event

`BUSRIDE.once(eventName, fun(...): (...), order: integer?)`
- Activates only once when event is fired
- Arguments depend on the event
- Return values depend on event

`BUSRIDE.removeOn(eventName, fun(...): (...))`

`BUSRIDE.removeOnce(eventName, fun(...): (...))`
- Removes an identical subscriber from the event bus

`BUSRIDE.fire(eventName, ...): boolean`
- Fires an event, activating all subscribers. Returns a boolean for cancelling purposes

`BUSRIDE.hookFunction(name: string, table: table, key: string)`
- Hooks onto a function, providing `[name]#pre`, `[name]`, and `[name]#post` events.

`BUSRIDE.skipHook(fun(...): (...), ...)`
- Ignores a layer of Bus Ride hooks on the function

`BUSRIDE.skipAnyHooks(fun(...): (...), ...)`
- Ignores all consecutive layers of Bus Ride hooks on the function

`BUSRIDE.check(fun(...): (...)): boolean`
- Checks if a function is a Bus Ride hook.
### Async
`BUSRIDE.runAsync(fun(...): (...), ...): Balatro Event`
- Runs the provided function as a coroutine. This allows it to span for multiple frames, given that it yields (see `BUSRIDE.wait` and `BUSRIDE.awaitTask`)
- `...` is any number of arguments. They are passed to the routine on startup.

`BUSRIDE.runAsyncTask(fun(...): T, fun(T), ...): Balatro Event`
- Runs the former function as a coroutine (see `BUSRIDE.runAsync`). When it finishes, its return values are passed to the latter function.
- `...` is any number of arguments. They are passed to the routine on startup.

`BUSRIDE.runBalatroEvent(fun(...), eventArgs: table, ...): Balatro Event`
- Allows providing specific settings to the event (see [SMODS Docs](https://github.com/Steamodded/smods/wiki/Guide-%E2%80%90-Event-Manager))

async `BUSRIDE.wait(ms: number): number`
- Pauses the current task for a specified amount of time, resuming the task **on the next frame**.
- Returns the real wait time

async `BUSRIDE.awaitTask(fun(...): T, ...): T`
- Pauses the current task while another one runs, returning its results to the current routine.
- `...` is any number of arguments. They are passed to the routine on startup.

## Examples
### Event Bus
```lua
BUSRIDE.on("G.main_menu", function (args)
    return false -- blocks the main menu from ever opening
end)
```
### Async
```lua
BUSRIDE.runAsync(function()
    local t = love.timer.getTime()
    for i = 1, 50 do
        BUSRIDE.wait(100)
        print("BUSRIDE: ".. i/10 .." (estimated) seconds have passed!")
    end
    print("actual wait time: ", love.timer.getTime() - t)
    BUSRIDE.awaitTask(function (...)
        BUSRIDE.wait(5000)
        print("waiting finished")
        BUSRIDE.awaitTask(function (...)
            BUSRIDE.wait(5000)
            print("i heard you liked waiting, so i")
        end)
    end)
    print("awaitTask cleared!")
end)
```

## Included Events
Every included event has three phases, `event#pre`, `event`, and `event#post`. Only the middle phase is cancellable (return `false` to block).
The `#post` phase also has access to return values if the function wasn't cancelled.
This means you have:
- `event#pre(args: {...})`
- `event(args: {...}): boolean`
- `event#post(args: {...}, returnValues: {...}?)`
### Love2D
- `love.update`
- `love.draw`
- `love.mousemoved`
- `love.mousepressed`
- `love.mousereleased`
- `love.keypressed`
- `love.keyreleased`
- `love.gamepadpressed`
- `love.gamepadreleased`
### Balatro
- `G.main_menu`
- `UIBox.draw`
- `EventManager.clear_queue`