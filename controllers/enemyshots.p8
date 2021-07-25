pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
c_enemyshots = {}
c_enemyshots.conf = {
    vx = 4,
    vy = 4,
    dam = 3.5
}
c_enemyshots._init = function()
    c_enemyshots.actors = {}
end

c_enemyshots.reset = function()
    c_enemyshots.actors = {}
end

c_enemyshots.new = function(x, y, vx, vy)
    sfx(1);
    local s = {}
    s.vx = vx
    s.vy = vy
    s.x = x
    s.y = y
    s.d = c_enemyshots.conf.dam
    add(c_enemyshots.actors, s)
end

c_enemyshots._update = function()
    foreach(c_enemyshots.actors, c_enemyshots.move)
end

c_enemyshots.delete = function(s)
    del(c_enemyshots.actors, s)
end

c_enemyshots.move = function(s)
    s.x += s.vx
    s.y += s.vy

    -- If the shot hits a physical tile
    if collision_tile(s.x, s.y, s_game.level) then
        del(c_enemyshots.actors, s)
    end

    -- If the shot leaves camera, remove it from memory
    if s.x > area.x + area.w then
        del(c_enemyshots.actors, s)
    end
    if s.y > area.y + area.h then
        del(c_enemyshots.actors, s)
    end
end

c_enemyshots._draw = function()
    foreach(c_enemyshots.actors, c_enemyshots.draw)
end


c_enemyshots.draw = function(s)
    pset(s.x-1, s.y-1, 11)
    pset(s.x+1, s.y+1, 11)
    pset(s.x, s.y, 11)
    pset(s.x-1, s.y+1, 11)
    pset(s.x+1, s.y-1, 11)
end
