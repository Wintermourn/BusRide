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
`BUSRIDE.skipHook(fun(...): (...), ...)`
- Ignores a layer of Bus Ride hooks on the function

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