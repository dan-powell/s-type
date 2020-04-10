pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
c_explosions = {}
c_explosions._init = function()
    c_explosions.actors = {}
end

c_explosions.reset = function()
    c_explosions.actors = {}
end

c_explosions.new = function(x, y, t)
    -- Set default parameters
    local e = {
        w = 8, -- width
        h = 8, -- height
        x = x,
        y = y,
        cs = 1
    }
    -- Set the sprites
    if(t == 2) then
        e.as = {22,23,24,25} -- sprites
    else
        e.as = {16,17,18,19,20} -- sprites
    end
    add(c_explosions.actors, e)
end

c_explosions._draw = function()
    foreach(c_explosions.actors, c_explosions.draw)
end

c_explosions.draw = function(e)
    if(e.cs >= count(e.as)) then
        del(c_explosions.actors, e)
    else
       if(frame%(4)==0) then
           e.cs += 1;
       end
    end
    spr(e.as[e.cs], e.x, e.y)
end
