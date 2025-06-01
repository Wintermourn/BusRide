SMODS.Atlas {
    key = "modicon",
    path = "icon.png",
    px = 34,
    py = 34
}

BUSRIDE = BUSRIDE or {
    callbacks = {
        on = {},
        once = {}
    },
    hookedFns = {

    }
}

---@alias busride.defaults
---| 'G.main_menu#pre' Balatro
---| 'love.mousemoved#pre' Internal
---| 'love.update#pre' Internal
---| 'love.draw#pre' Internal

---@alias busride.defaults.cancellable
---| 'G.main_menu' Cancellable | Balatro
---| 'love.mousemoved' Cancellable | Internal
---| 'love.update' Cancellable | Internal
---| 'love.draw' Cancellable | Internal

---@alias busride.defaults.post
---| 'G.main_menu#post' Balatro
---| 'love.mousemoved#post' Internal
---| 'love.update#post' Internal
---| 'love.draw#post' Internal

--- Subscribes to an event.
---@param event string The event being subscribed to.
---@param fn fun(args: any[]) The subscriber to the event. 
---@param order integer? Places the subscriber into the list at a specified position, if your subscriber needs to run before or after something.
---@return integer subscribers the new count of event subscribers.
---@overload fun(event: busride.defaults, fn: fun(args: any[]), order: integer?): integer
---@overload fun(event: busride.defaults.cancellable, fn: fun(args: any[]): (boolean?), order: integer?): integer
---@overload fun(event: busride.defaults.post, fn: fun(args: any[], returnValues: any[]?), order: integer?): integer
function BUSRIDE.on(event, fn, order)
    if BUSRIDE.callbacks.on[event] == nil then
        BUSRIDE.callbacks.on[event] = {
            fn
        } 
        return 1
    end
    if order == nil then
        BUSRIDE.callbacks.on[event][#BUSRIDE.callbacks.on[event]+1] = fn
        return #BUSRIDE.callbacks.on[event]+1
    else
        table.insert(BUSRIDE.callbacks.on[event], math.min(order, #BUSRIDE.callbacks.on[event]+1), fn)
        return #BUSRIDE.callbacks.on[event]+1
    end
end

function BUSRIDE.removeOn(event, fn)
    if BUSRIDE.callbacks.on[event] == nil then return end
    for i,k in ipairs(BUSRIDE.callbacks.on[event]) do
        if k == fn then
            table.remove(BUSRIDE.callbacks.on[event], i)
            return
        end
    end
end

--- Subscribes to an event. Only activates once.
---@param event string The event being subscribed to.
---@param fn fun(...): ... any The subscriber to the event. 
---@param order integer? Places the subscriber into the list at a specified position, if your subscriber needs to run before or after something.
---@return integer subscribers the new count of event subscribers.
function BUSRIDE.once(event, fn, order)
    if BUSRIDE.callbacks.once[event] == nil then
        BUSRIDE.callbacks.once[event] = {
            fn
        } 
        return 1
    end
    if order == nil then
        BUSRIDE.callbacks.once[event][#BUSRIDE.callbacks.once[event]+1] = fn
        return #BUSRIDE.callbacks.once[event]+1
    else
        table.insert(BUSRIDE.callbacks.once[event], math.min(order, #BUSRIDE.callbacks.once[event]+1), fn)
        return #BUSRIDE.callbacks.once[event]+1
    end
end

function BUSRIDE.removeOnce(event, fn)
    if BUSRIDE.callbacks.once[event] == nil then return end
    for i,k in ipairs(BUSRIDE.callbacks.once[event]) do
        if k == fn then
            table.remove(BUSRIDE.callbacks.once[event], i)
            return
        end
    end
end

function BUSRIDE.fire(event, ...)
    local continue = true
    local res
    if BUSRIDE.callbacks.on[event] then
        for _i,k in ipairs(BUSRIDE.callbacks.on[event]) do
            res = k(...)
            if res == false then continue = false end
        end
    end
    if BUSRIDE.callbacks.once[event] then
        for _i,k in ipairs(BUSRIDE.callbacks.once[event]) do
            res = k(...)
            if res == false then continue = false end
        end
        BUSRIDE.callbacks.once[event] = nil
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
function BUSRIDE.hookFunction(eventName, table, key, ...)
    if (type(table[key])) ~= "function" then return false end
    local og = table[key]
    local defret = {...}
    local new = function(...)
        BUSRIDE.fire(eventName.."#pre", {...})
        local ret
        if BUSRIDE.fire(eventName, {...}) then
            ret = {og(...)}
            BUSRIDE.fire(eventName.."#post", {...}, ret)
            return unpack(ret)
        else
            BUSRIDE.fire(eventName.."#post", {...})
            return unpack(defret)
        end
    end
    table[key] = new

    BUSRIDE.hookedFns[new] = og
end

--- Runs the original function directly, ignoring the busride hook placed on it.
---@param fn function
---@param ... any
---@return unknown
function BUSRIDE.skipHook(fn, ...)
    if BUSRIDE.hookedFns[fn] then
        return BUSRIDE.hookedFns[fn](...)
    end
end

--- Runs the original function directly, ignoring the busride hook placed on it. Supports consecutive busride hooks on the same function.
---If the function isn't hooked, it's still run anyways.
---@param fn function
---@param ... any
---@return unknown
function BUSRIDE.skipAnyHooks(fn, ...)
    if BUSRIDE.hookedFns[fn] then
        return BUSRIDE.skipAnyHooks(BUSRIDE.hookedFns[fn], ...)--BUSRIDE.hookedFns[fn](...)
    else
        return fn(...)
    end
end

--- Checks if the function is one of busride's hooks.
---@param fn function
---@return boolean
function BUSRIDE.check(fn)
    if BUSRIDE.hookedFns[fn] then
        return true
    end
    return false
end

SMODS.load_file("hooks/love.lua")()
SMODS.load_file("hooks/balatro.lua")()