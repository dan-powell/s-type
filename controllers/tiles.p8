pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
c_tiles = {}
c_tiles.types = {
    a = {
        s={32,33}, -- sprites
        sd=35, -- damage sprite
        w=8, -- width
        h=8, -- height
        sw=1, -- sprite width (in tiles)
        sh=1, -- sprite height (in tiles)
        l=10 -- Life (health)
    },
    b = {
        s={36,37,38,39,40}, -- sprites
        sd=41, -- damage sprite
        w=8, -- width
        h=8, -- height
        sw=1, -- sprite width (in tiles)
        sh=1, -- sprite height (in tiles)
        l=40 -- Life (health)
    }
}
-- --------------------------
-- init
-- --------------------------
c_tiles._init = function()
   c_tiles.actors = {}
end

c_tiles._update = function()

    foreach(c_tiles.actors, c_tiles.move)

    for k,t in pairs(s_game.level.t) do
        if (ceil(s_game.timeline) == t.t) then
            add(c_tiles.actors, c_tiles.new(t))
        end
    end

    for k1,t in pairs(c_tiles.actors) do
        -- Check if enemy has collided with shot
        for k2,s in pairs(c_shots.actors) do
            if (s.x > t.x and s.x < (t.x + t.w) and s.y > t.y and s.y < (t.y + t.h)) then
                c_tiles.damage(t, s.d)
                c_shots.delete(s)
            end
        end
        -- Check if enemy has collided with ship
        local s = c_ship.get()
        if collision(s, t) then
            c_tiles.destroy(t)
            c_player.lives_lose()
            c_ship.hide()
            s_game.state = 2
        end
    end
end

c_tiles.damage = function(t, d)
    t.s_d = 5 -- set timer for displaying damage sprite

    -- decriment life
    if not d then
        t.l -= 1
    else
        t.l -= d
    end

    -- check if destroyed
    if t.l <= 0 then
        c_tiles.destroy(t)
    end
end

c_tiles.destroy = function(t)
    c_explosions.new(t.x, t.y, 2)
    del(c_tiles.actors, t)
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

    if t.s_d > 0 and frame%(2)==0 then
        spr(t.sd, t.x, t.y, t.sw, t.sh)
    else
        spr(t.s[t.st], t.x, t.y, t.sw, t.sh)
    end
end

-- --------------------------
-- methods
-- --------------------------
c_tiles.reset = function()
    c_tiles.actors = {}
end

c_tiles.new = function(tile)
    local t = {}

    -- Load up the values from enemy type config
    for k, v in pairs(c_tiles.types[tile.tp]) do
        t[k] = v
    end

    -- Load up the values from level enemy config
    for k, v in pairs(tile) do
        t[k] = v
    end

    t.x = 128
    t.st = 0 -- Sprite timer
    t.s_d = 0 -- Damage timer
    return t
end

c_tiles.move = function(t)
    t.x -= s_game.timeline_speed

    if t.s_d > 0 then
        t.s_d -= 1
    end

    -- Check for end of life and remove
    if (t.x < 0) then
        del(s_game.tiles, t)
    end
end
