# Event Bus Ride
Provides an event bus system to Love and Balatro specific functions.

## Installation
This system is a mod for *Balatro* and requires *Steamodded* to run.
Simply place into your mods folder and it should work fine.

## Usage
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

`BUSRIDE.hookFunction(name, table, key)`
- Hooks onto a function, providing `[name]#pre`, `[name]`, and `[name]#post` events.

`BUSRIDE.skipHook(fun(...): (...), ...)`
- Ignores a layer of Bus Ride hooks on the function

`BUSRIDE.skipAnyHooks(fun(...): (...), ...)`
- Ignores all consecutive layers of Bus Ride hooks on the function

`BUSRIDE.check(fun(...): (...), ...)`
- Checks if a function is a Bus Ride hook.

## Examples
```lua
BUSRIDE.on("G.main_menu", function (args)
    return false -- blocks the main menu from ever opening
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