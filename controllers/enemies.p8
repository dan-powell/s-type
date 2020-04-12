pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
c_enemies = {}

c_enemies.types = {
    a = {
        s={32,33,34}, -- sprites
        sd=35, -- damage sprite
        w=8, -- width
        h=8, -- height
        sw=1, -- sprite width (in tiles)
        sh=1, -- sprite height (in tiles)
        l=10, -- Life (health)
        pv=100, -- value in points (for scoring)
    }
}

-- --------------------------
-- init
-- --------------------------
c_enemies._init = function()
    c_enemies.actors = {}
    c_enemies.queue = {}
end

-- --------------------------
-- update
-- --------------------------
c_enemies._update = function()

    c_enemies.trigger()
    c_enemies.process_queue()

    foreach(c_enemies.actors, c_enemies.update)

    for k1,e in pairs(c_enemies.actors) do
        -- Check if enemy has collided with shot
        for k2,s in pairs(c_shots.actors) do
            if (s.x > e.x and s.x < (e.x + e.w) and s.y > e.y and s.y < (e.y + e.h)) then
                c_enemies.damage(e, s.d)
                c_shots.delete(s)
            end
        end
        -- Check if enemy has collided with ship
        local s = c_ship.get()
        if collision(s, e) then
            c_explosions.new(s.x, s.y, 2)
            c_enemies.destroy(e)
            c_player.lives_lose()
            c_ship.hide()
            s_game.state = 2
        end
    end
end

-- --------------------------
-- methods
-- --------------------------
c_enemies.reset = function()
    c_enemies.actors = {}
    c_enemies.queue = {}
end

c_enemies.new = function(t, rt)
    local e = {}

    -- Load up the values from enemy type config
    for k, v in pairs(c_enemies.types[t.tp]) do
        e[k] = v
    end

    -- Load up the values from level enemy config
    for k, v in pairs(t) do
        e[k] = v
    end

    e.s_d = 0 -- sprite damage counter

    e.x = 0 -- absolute x position
    e.y = 0 -- absolute y position

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

c_enemies.damage = function(e, d)
    e.s_d = 5 -- set timer for displaying damage sprite

    -- decriment life
    if not d then
        e.l -= 1
    else
        e.l -= d
    end

    -- check if destroyed
    if e.l <= 0 then
        c_enemies.destroy(e)
    end
end

c_enemies.destroy = function(e)
    c_player.score_add(e.pv)
    c_explosions.new(e.x, e.y, 1)
    del(c_enemies.actors, e)
end

c_enemies.process_queue = function()
    for k,e in pairs(c_enemies.queue) do
        if(e.rt <= 0) then
            e.o = frame
            add(c_enemies.actors, e)
            del(c_enemies.queue, e)
        end
        e.rt -= 1
    end
end

c_enemies.trigger = function()
    for k, es in pairs(s_game.level.e) do
        if (ceil(s_game.timeline) == es.t) then
            for i=1,es.n do
                add(c_enemies.queue, c_enemies.new(es, i*10))
            end
        end
    end
end

c_enemies.update = function(e)

    if e.s_d > 0 then
        e.s_d -= 1
    end

    -- Base updated position on a bezier curve (quad)
    e.x = bezier_quad(e.lt,e.o,e.sx,e.ex,e.p1x,e.p2x)
    e.y = bezier_quad(e.lt,e.o,e.sy,e.ey,e.p1y,e.p2y)
    -- Check for end of life and remove
    if (e.ltr <= 1) then
        del(c_enemies.actors, e)
    else
        e.ltr -= 1
    end
end

-- --------------------------
-- draw
-- --------------------------

c_enemies._draw = function()
    foreach(c_enemies.actors, c_enemies.draw_actor)
end

c_enemies.draw_actor = function(e)
    if(frame%(4)==0) then
        e.st += 1
        if(e.st > tablelength(e.s)) then
            e.st = 1
        end
    end
    if e.s_d > 0 and frame%(2)==0 then
        spr(e.sd, e.x, e.y, e.sw, e.sh)
    else
        spr(e.s[e.st], e.x, e.y, e.sw, e.sh)
    end
end
