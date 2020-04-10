pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
c_tiles = {}
-- --------------------------
-- init
-- --------------------------
c_tiles._init = function()
   c_tiles.actors = {}
end

c_tiles._update = function()

    foreach(c_tiles.actors, c_tiles.move)

    for k,t in pairs(c_game.level.t) do
        if (ceil(c_game.timeline) == t.t) then
            add(c_tiles.actors, c_tiles.new(t))
        end
    end

    for k1,t in pairs(c_tiles.actors) do
        -- Check if enemy has collided with shot
        -- for k2,s in pairs(c_game.shots) do
        --     if (s.x > e.x and s.x < (e.x + e.w) and s.y > e.y and s.y < (e.y + e.h)) then
        --         player.score += e.pv
        --         c_game.add_explosion(e.x, e.y, 1)
        --         del(c_game.enemies, e)
        --         del(c_game.shots, s)
        --     end
        -- end
        -- Check if enemy has collided with ship
        local s = c_ship.get()
        if collision(s, t) then
            c_explosions.new(s.x, s.y, 2)
            del(c_tiles.actors, t)
            c_ship.hide()
            c_game.reset()
        end
    end
end

c_tiles._draw = function()
    foreach(c_tiles.actors, c_tiles.draw)
end

c_tiles.draw = function(t)
    if(frame%(4)==0) then
        t.st += 1
        if(t.st > tablelength(t.s)) then
            t.st = 1
        end
    end
    spr(t.s[t.st], t.x, t.y, t.sw, t.sh)
end

-- --------------------------
-- methods
-- --------------------------
c_tiles.reset = function()
    c_tiles.actors = {}
end

c_tiles.new = function(tile)
    local t = {}
    for k, v in pairs(tile) do
        t[k] = v
    end
    t.x = 128
    t.st = 0 -- Sprite timer
    return t
end

c_tiles.move = function(t)
    t.x -= c_game.timeline_speed
    -- Check for end of life and remove
    if (t.x < 0) then
        del(c_game.tiles, t)
    end
end

