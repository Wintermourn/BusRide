local pathOverride = ...
pathOverride = pathOverride or ''
if pathOverride ~= '' and pathOverride:sub(-1) ~= '/' then
    pathOverride = pathOverride ..'/'
end

local __VERSION = setmetatable({major=0,minor=3,patch=2}, {
    __tostring = function(t)
        return t.major ..'.'.. t.minor ..'.'.. t.patch
    end
})

local function testVersion(a, b)
    if a ~= nil and b == nil then return 5 end
    if a == nil and b ~= nil then return -5 end
    if a.major ~= b.major then
        return a.major < b.major and -4 or 4
    elseif a.minor ~= b.minor then
        return a.minor < b.minor and -3 or 3
    elseif a.patch ~= b.patch then
        return a.patch < b.patch and -2 or 2
    else
        return 0
    end
end

local isFirstInit = BUSRIDE == nil
local isNewerVersion = not isFirstInit and testVersion(__VERSION, BUSRIDE._VERSION) > 0
local isIndividual = SMODS.current_mod.id == "EventBusRide"

if not isFirstInit and not isNewerVersion then
    print(string.format(
        "[BusRide] version packaged in %s is not up to date (%s vs loaded %s)", SMODS.current_mod.id, tostring(__VERSION), tostring(BUSRIDE._VERSION)))
    return
end
local _BUSRIDE = {
    _VERSION = __VERSION,
    callbacks = {
        on = {},
        once = {}
    },
    hookedFns = {

    },
    routines = {},
    op = {
        STILL_WORKING = {1}
    }
}

if isIndividual then
    SMODS.Atlas {
        key = "modicon",
        path = "icon.png",
        px = 34,
        py = 34
    }
end

---@alias busride.defaults
---| 'G.main_menu#pre' Balatro
---| 'EventManager.clear_queue#pre' Balatro
---| 'love.mousemoved#pre' Internal
---| 'love.mousepressed#pre' Internal
---| 'love.mousereleased#pre' Internal
---| 'love.keypressed#pre' Internal
---| 'love.keyreleased#pre' Internal
---| 'love.gamepadpressed#pre' Internal
---| 'love.gamepadreleased#pre' Internal
---| 'love.update#pre' Internal
---| 'love.draw#pre' Internal

---@alias busride.defaults.cancellable
---| 'G.main_menu' Cancellable | Balatro
---| 'EventManager.clear_queue' Cancellable | Balatro
---| 'love.mousemoved' Cancellable | Internal
---| 'love.mousepressed' Cancellable | Internal
---| 'love.mousereleased' Cancellable | Internal
---| 'love.keypressed' Cancellable | Internal
---| 'love.keyreleased' Cancellable | Internal
---| 'love.gamepadpressed' Cancellable | Internal
---| 'love.gamepadreleased' Cancellable | Internal
---| 'love.update' Cancellable | Internal
---| 'love.draw' Cancellable | Internal

---@alias busride.defaults.post
---| 'G.main_menu#post' Balatro
---| 'EventManager.clear_queue#post' Balatro
---| 'love.mousemoved#post' Internal
---| 'love.update#post' Internal
---| 'love.draw#post' Internal
---| 'love.mousepressed#post' Internal
---| 'love.mousereleased#post' Internal
---| 'love.keypressed#post' Internal
---| 'love.keyreleased#post' Internal
---| 'love.gamepadpressed#post' Internal
---| 'love.gamepadreleased#post' Internal

--- Subscribes to an event.
---@param event string The event being subscribed to.
---@param fn fun(args: any[]) The subscriber to the event. 
---@param order integer? Places the subscriber into the list at a specified position, if your subscriber needs to run before or after something.
---@return integer subscribers the new count of event subscribers.
---@overload fun(event: busride.defaults, fn: fun(args: any[]), order: integer?): integer
---@overload fun(event: busride.defaults.cancellable, fn: fun(args: any[]): (boolean?), order: integer?): integer
---@overload fun(event: busride.defaults.post, fn: fun(args: any[], returnValues: any[]?, wasCancelled: boolean), order: integer?): integer
function _BUSRIDE.on(event, fn, order)
    if _BUSRIDE.callbacks.on[event] == nil then
        _BUSRIDE.callbacks.on[event] = {
            fn
        } 
        return 1
    end
    if order == nil then
        _BUSRIDE.callbacks.on[event][#_BUSRIDE.callbacks.on[event]+1] = fn
        return #_BUSRIDE.callbacks.on[event]+1
    else
        table.insert(_BUSRIDE.callbacks.on[event], math.min(order, #_BUSRIDE.callbacks.on[event]+1), fn)
        return #_BUSRIDE.callbacks.on[event]+1
    end
end

--- Unsubscribe from an event.
---@param event string
---@param fn function
function _BUSRIDE.removeOn(event, fn)
    if _BUSRIDE.callbacks.on[event] == nil then return end
    for i,k in ipairs(_BUSRIDE.callbacks.on[event]) do
        if k == fn then
            table.remove(_BUSRIDE.callbacks.on[event], i)
            return
        end
    end
end

--- Subscribes to an event. Only activates once.
---@param event string The event being subscribed to.
---@param fn fun(...): ... any The subscriber to the event. 
---@param order integer? Places the subscriber into the list at a specified position, if your subscriber needs to run before or after something.
---@return integer subscribers the new count of event subscribers.
function _BUSRIDE.once(event, fn, order)
    if _BUSRIDE.callbacks.once[event] == nil then
        _BUSRIDE.callbacks.once[event] = {
            fn
        } 
        return 1
    end
    if order == nil then
        _BUSRIDE.callbacks.once[event][#_BUSRIDE.callbacks.once[event]+1] = fn
        return #_BUSRIDE.callbacks.once[event]+1
    else
        table.insert(_BUSRIDE.callbacks.once[event], math.min(order, #_BUSRIDE.callbacks.once[event]+1), fn)
        return #_BUSRIDE.callbacks.once[event]+1
    end
end

--- Unsubscribe from an event. Note that this won't work if the hooked function has already fired and forgotten the subscriber.
---@param event string
---@param fn function
function _BUSRIDE.removeOnce(event, fn)
    if _BUSRIDE.callbacks.once[event] == nil then return end
    for i,k in ipairs(_BUSRIDE.callbacks.once[event]) do
        if k == fn then
            table.remove(_BUSRIDE.callbacks.once[event], i)
            return
        end
    end
end

function _BUSRIDE.fire(event, ...)
    local continue = true
    local res
    if _BUSRIDE.callbacks.on[event] then
        for _i,k in ipairs(_BUSRIDE.callbacks.on[event]) do
            res = k(...)
            if res == false then continue = false end
        end
    end
    if _BUSRIDE.callbacks.once[event] then
        for _i,k in ipairs(_BUSRIDE.callbacks.once[event]) do
            res = k(...)
            if res == false then continue = false end
        end
        _BUSRIDE.callbacks.once[event] = nil
    end
    return continue
end

--- Hooks onto a method and provides events on BusRide.
---@param eventName string Base name for events.
---
---For example, a hook with eventName `"load"` would provide events `"load#pre"`, `"load"`, and `"load#post".`
---@param table table Table that contains the function being hooked onto. (e.g. `love.update` would be `love`)
---@param key any Key that represents the function being hooked onto. (e.g. `love.update` would need `"update"`)
---@param ... any? Default return values. If the hooked function is cancelled, this provides defaults to the caller.
function _BUSRIDE.hookFunction(eventName, table, key, ...)
    if (type(table[key])) ~= "function" then return false end
    local og = table[key]
    local defret = {...}
    local new = function(...)
        _BUSRIDE.fire(eventName.."#pre", {...})
        local ret
        if _BUSRIDE.fire(eventName, {...}) then
            ret = {og(...)}
            _BUSRIDE.fire(eventName.."#post", {...}, ret, false)
            return unpack(ret)
        else
            _BUSRIDE.fire(eventName.."#post", {...}, nil, true)
            return unpack(defret)
        end
    end
    table[key] = new

    _BUSRIDE.hookedFns[new] = og
end

--- Runs the original function directly, ignoring the busride hook placed on it.
---@param fn function
---@param ... any
---@return unknown
function _BUSRIDE.skipHook(fn, ...)
    if _BUSRIDE.hookedFns[fn] then
        return _BUSRIDE.hookedFns[fn](...)
    end
end

--- Runs the original function directly, ignoring the busride hook placed on it. Supports consecutive busride hooks on the same function.
---If the function isn't hooked, it's still run anyways.
---@param fn function
---@param ... any
---@return unknown
function _BUSRIDE.skipAnyHooks(fn, ...)
    if _BUSRIDE.hookedFns[fn] then
        return _BUSRIDE.skipAnyHooks(_BUSRIDE.hookedFns[fn], ...)
    else
        return fn(...)
    end
end

--- Checks if the function is one of busride's hooks.
---@param fn function
---@return boolean
function _BUSRIDE.check(fn)
    if _BUSRIDE.hookedFns[fn] then
        return true
    end
    return false
end

--- Runs an async task as a Balatro event.
---@param fn async fun(...)
---@param evArgs table|{onComplete:fun(...),onCleared:fun()} Pass specific arguments to the event ([SMODS Docs](https://github.com/Steamodded/smods/wiki/Guide-%E2%80%90-Event-Manager)).
---@param ... any Initial thread/routine arguments
---@return Event
function _BUSRIDE.runBalatroEvent(fn, evArgs, ...)
    local args = {...}
    local co = coroutine.create(fn)
    local wait, waitres

    local eventTable = {
        trigger = 'immediate',
        blockable = false,
        blocking = false
    }
    if type(evArgs) == 'table' then
        for i,k in pairs(evArgs) do
            eventTable[i] = k
        end
    end
    eventTable.func = function()
        if type(wait) == "function" then
            waitres = {wait()}
            if waitres[1] == _BUSRIDE.op.STILL_WORKING then
                return false
            end
            wait = nil
            args = waitres
        end
        local res = {coroutine.resume(co, unpack(args))}
        args = {}
        wait = res[2]
        if coroutine.status(co) == "dead" then
            if eventTable.onComplete then
                table.remove(res,1)
                eventTable.onComplete(unpack(res))
            end
            return true
        end
    end
    local event = Event(eventTable)
    if type(evArgs) == 'table' then
        event.onCleared = evArgs.onCleared
        event.onCompletez = evArgs.onComplete
        G.E_MANAGER:add_event(event, evArgs.queue, evArgs.front)
    else
        G.E_MANAGER:add_event(event)
    end

    return event
end

--- Runs a function asynchronously. This allows for the use of certain functions like `BUSRIDE.wait` and `BUSRIDE.awaitTask`.
---@param fn async fun(...)
---@param ... any Initial thread/routine arguments
---@return Event
function _BUSRIDE.runAsync(fn, ...)
    return _BUSRIDE.runBalatroEvent(fn, nil, ...)
end

--- Works like `BUSRIDE.runAsync`, but runs a function afterwards that takes in the task's return values.
---@generic T
---@param fn async fun(...): `T`
---@param onComplete fun(T) Function that fires upon task completion. ***Does not fire if the event is cleared from the manager.***
---@param ... any Initial thread/routine arguments
---@return Event
function _BUSRIDE.runAsyncTask(fn, onComplete, ...)
    return _BUSRIDE.runBalatroEvent(fn, {onComplete=onComplete}, ...)
end

--- Pauses the current thread until the specified amount of time has passed.
--- ! Note: Wait time is not exact. Thread resumes on the next frame.
---@async
---@return true
function _BUSRIDE.wait(ms)
    if not coroutine.running() then return end
    local target = love.timer.getTime() + (ms/1000)
    return coroutine.yield(function()
        return love.timer.getTime() >= target or _BUSRIDE.op.STILL_WORKING
    end)
end

--- Runs a task asynchronously, resuming the current thread/coroutine after finishing.
---@async
---@param task async fun(...): ...
---@return ...
function _BUSRIDE.awaitTask(task, ...)
    if not coroutine.running() then return end
    local todo = coroutine.create(task)

    local res = {coroutine.resume(todo)}
    if coroutine.status(todo) == "dead" then table.remove(res,1) return res end
    local wait = res[2]
    return coroutine.yield(function()
        if type(wait) == "function" then
            res = {wait()}
            if res[1] ~= _BUSRIDE.op.STILL_WORKING then
                res = {coroutine.resume(todo, unpack(res))}
                if not res[1] or coroutine.status(todo) == "dead" then
                    table.remove(res, 1)
                    return unpack(res)
                else
                    wait = newwait
                    return _BUSRIDE.op.STILL_WORKING
                end
            else
                return _BUSRIDE.op.STILL_WORKING
            end
        else
            res = {coroutine.resume(todo)}
            if coroutine.status(todo) == "dead" then
                table.remove(res, 1)
                return unpack(res)
            else
                wait = res[2]
                return _BUSRIDE.op.STILL_WORKING
            end
        end
    end)
end

if isNewerVersion then
    _BUSRIDE.routines = BUSRIDE.routines
    _BUSRIDE.hookedFns = BUSRIDE.hookedFns
    _BUSRIDE.callbacks.on = BUSRIDE.callbacks.on
    _BUSRIDE.callbacks.once = BUSRIDE.callbacks.once
end
BUSRIDE = _BUSRIDE

local function loadHookFile(path)
    local file = SMODS.load_file(path)
    if file then file() end
end
loadHookFile(pathOverride .. "hooks/love.lua")
loadHookFile(pathOverride .. "hooks/balatro.lua")

BUSRIDE.on("EventManager.clear_queue", function (args)
    local eventManager = args[1]
    ---@cast eventManager EventManager
    if not args[2] then -- queue
        for _k, q in pairs(eventManager.queues) do
            local i = 1
            local e
            while i <= #q do
                e = q[i]
                if not e.no_delete and e.onCleared ~= nil then
                    e.onCleared()
                end
                i=i+1
            end
        end
    elseif args[3] then -- exception
        for k, q in pairs(eventManager.queues) do
            if k == args[3] then goto continue end
            local i = 1
            local e
            while i <= #q do
                e = q[i]
                if not e.no_delete and e.onCleared ~= nil then
                    e.onCleared()
                end
                i=i+1
            end
            ::continue::
        end
    else
        local q = eventManager.queues[args[2]]
        local i = 1
        local e
        while i <= #q do
            e = q[i]
            if not e.no_delete and e.onCleared ~= nil then
                e.onCleared()
            end
            i=i+1
        end
    end
end)

return _BUSRIDE