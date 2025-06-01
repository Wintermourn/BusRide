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
### Love2D
- `love.update#pre`
- `love.update` (Cancellable - return `false` to block)
- `love.update#post`
- `love.mousemoved#pre`
- `love.mousemoved` (Cancellable - return `false` to block)
- `love.mousemoved#post`
- `love.draw#pre`
- `love.draw` (Cancellable - return `false` to block)
- `love.draw#post`
### Balatro
- `G.main_menu#pre`
- `G.main_menu` (Cancellable - return `false` to block)
- `G.main_menu#post`