pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- ===========
-- Collison Helpers
-- ===========

-- Detect collision with a collidable tile
function collision_tile(x, y, level)
    t=tget(x, y, level)
    -- test if tile has flag
    if fget(t, 0) then
        return true
    else
        return false
    end
end

-- Detects collisions between objects
function collision(o1, o2)
    if
        o2.x+o2.w > o1.x and
        o2.y+o2.h > o1.y and
        o2.x < o1.x+o1.w and
        o2.y < o1.y+o1.h
    then
        return true
    end
end

-- Detects collisions between objects using hitboxes
function collision_hitbox(o1, o2)
    if
        o2.x+o2.hbx+o2.hbw > o1.x+o1.hbx and
        o2.y+o2.hby+o2.hbh > o1.y+o1.hby and
        o2.x+o2.hbx < o1.x+o1.hbx+o1.hbw and
        o2.y+o2.hby < o1.y+o1.hby+o1.hbh
    then
        return true
    end
end

-- return the tile at a given pixel position
function tget(x, y, level)
    x += (level.mx * 8)
    y += (level.my * 8)
    return mget(flr(x/grid.w), flr(y/grid.h))
end

-- set the tile at a given pixel position
function tset(x, y, v, level)
    x += (level.mx * 8)
    y += (level.my * 8)
    return mset(flr(x/grid.w), flr(y/grid.h), v)
end