pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
enemies = {}
-- --------------------------
-- init
-- --------------------------
enemies._init = function()
    enemies.actors = {}
    enemies.queue = {}
end

-- --------------------------
-- update
-- --------------------------
enemies._update = function()
    enemies.trigger()
    enemies.process_queue()
    foreach(enemies.actors, enemies.move)

    for k1,e in pairs(enemies.actors) do
        -- Check if enemy has collided with shot
        for k2,s in pairs(c_game.shots) do
            if (s.x > e.x and s.x < (e.x + e.w) and s.y > e.y and s.y < (e.y + e.h)) then
                player.score += e.pv
                c_game.add_explosion(e.x, e.y, 1)
                del(enemies.actors, e)
                del(c_game.shots, s)
            end
        end
        -- Check if enemy has collided with ship
        local s = c_ship.get()
        if collision(s, e) then
            player.score -= e.pv
            c_game.add_explosion(s.x, s.y, 2)
            del(enemies.actors, e)
            c_ship.hide()
            c_game.reset()
        end
    end
end

-- --------------------------
-- methods
-- --------------------------
enemies.reset = function()
    enemies.actors = {}
    enemies.queue = {}
end

enemies.new = function(t, rt)
    local e = {}
    for k, v in pairs(t) do
        e[k] = v
    end

    e.rt = rt -- Release timer
    e.lt = t.lt -- Lifetime (total)
    e.ltr = t.lt -- Lifetime remaining
    e.st = 0 -- Sprite timer

    e.sx = t.psx
    e.sy = t.psy
    e.ex = t.pex
    e.ey = t.pey

    e.p1x = t.p1x
    e.p1y = t.p1y
    e.p2x = t.p2x
    e.p2y = t.p2y

    return e
end

enemies.process_queue = function()
    for k,e in pairs(enemies.queue) do
        if(e.rt <= 0) then
            e.o = frame
            add(enemies.actors, e)
            del(enemies.queue, e)
        end
        e.rt -= 1
    end
end

enemies.trigger = function()
    for k,es in pairs(c_game.level.e) do
        if (ceil(c_game.timeline) == es.t) then
            for i=1,es.n do
                add(enemies.queue, enemies.new(es, i*10))
            end
        end
    end
end

enemies.move = function(e)
    -- Base updated position on a bezier curve (quad)
    e.x = bezier_quad(e.lt,e.o,e.sx,e.ex,e.p1x,e.p2x)
    e.y = bezier_quad(e.lt,e.o,e.sy,e.ey,e.p1y,e.p2y)
    -- Check for end of life and remove
    if (e.ltr <= 1) then
        del(enemies.actors, e)
    else
        e.ltr -= 1
    end
end

-- --------------------------
-- draw
-- --------------------------

enemies._draw = function()
    foreach(enemies.actors, enemies.draw_actor)
end

enemies.draw_actor = function(e)
    if(frame%(4)==0) then
        e.st += 1
        if(e.st > tablelength(e.s)) then
            e.st = 1
        end
    end
    spr(e.s[e.st], e.x, e.y, e.sw, e.sh)
end

