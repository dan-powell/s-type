pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
c_shots = {}
c_shots.conf = {
    vx = 4
}
c_shots._init = function()
    c_shots.actors = {}
end

c_shots.reset = function()
    c_shots.actors = {}
end

c_shots.new = function(x, y)
    sfx(1);
    local s = {}
    s.vx = c_shots.conf.vx
    s.x = x
    s.y = y
    s.d = 3.5 -- damage per shot
    add(c_shots.actors, s)
end

c_shots._update = function()
    foreach(c_shots.actors, c_shots.move)
    if(not debounce) debounce=0
    debounce += 1
    if btn(5) and debounce > 5 then
        local s = c_ship.get()
        c_shots.new(s.x + 3, s.y)
        c_shots.new(s.x + 3, s.y + s.h - 1)
        debounce = 0
    end
end

c_shots.delete = function(s)
    del(c_shots.actors, s)
end

c_shots.move = function(s)
    s.x += s.vx

    -- If the shot hits a physical tile
    if collision_tile(s.x, s.y, s_game.level) then
        del(c_shots.actors, s)
    end

    -- If the shot leaves camera, remove it from memory
    if s.x > area.x + area.w then
        del(c_shots.actors, s)
    end
end

c_shots._draw = function()
    foreach(c_shots.actors, c_shots.draw)
end


c_shots.draw = function(s)
    pset(s.x, s.y, 7)
end
