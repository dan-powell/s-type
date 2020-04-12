pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
c_ship = {}
c_ship.ship = {}
c_ship.trails = {}
c_ship.current = 1
c_ship.conf = {
    s = 1,
    t = 1, -- type 1 = main, 2 = space
    w = 8, -- width
    h = 8, -- height
    x = 0, -- absolute x position
    y = 0, -- absolute y position
    vx = 0, -- x velocity (pixels moved per frame)
    vy = 0, -- y velocity (pixels moved per frame)
    sw = 1, -- sprite width (in tiles)
    sh = 1, -- sprite height (in tiles)
    dx = -1, -- direction (+1 right -1 left)
    dy = -1, -- direction (+1 down -1 up)
}
c_ship.ships = {
    {
        n = "zander",
        d = "all rounder",
        l = 5,
        fx = 0.7, -- horizontal friction
        fy = 0.7, -- vertical friction
        f = 2, -- force applied when moved
        sp = {1,2,3} -- sprites
    },
    {
        n = "henkler",
        d = "slow and solid",
        l = 10,
        fx = 0.5, -- horizontal friction
        fy = 0.5, -- vertical friction
        f = 1.5, -- force applied when moved
        sp = {4,5,6} -- sprites
    },
    {
        n = "zweiss",
        d = "speedy yet delicate",
        l = 3,
        fx = 0.7, -- horizontal friction
        fy = 0.7, -- vertical friction
        f = 2.5, -- force applied when moved
        sp = {7,8,9} -- sprites
    }
}

c_ship._init = function()
    c_ship.select(1)
end

c_ship._update = function()
    c_ship.update_position()
    if  collision_tile(c_ship.ship.x, c_ship.ship.y, s_game.level) or
        collision_tile(c_ship.ship.x + c_ship.ship.w, c_ship.ship.y, s_game.level) or
        collision_tile(c_ship.ship.x, c_ship.ship.y + c_ship.ship.h, s_game.level) or
        collision_tile(c_ship.ship.x + c_ship.ship.w, c_ship.ship.y + c_ship.ship.h, s_game.level) then
        s_game.add_explosion(c_ship.ship.x, c_ship.ship.y, 2)
        c_ship.hide()
        s_game.reset()
    end
end

-- Select a new ship
c_ship.select = function(s)
    c_ship.current = s
    c_ship.ship = c_ship.new()
end

-- generate ship object
c_ship.new = function()
    local s = {}
    for k,v in pairs(c_ship.conf) do
        s[k] = v
    end
    for k,v in pairs(c_ship.ships[c_ship.current]) do
        s[k] = v
    end
    return s
end

-- -----------
-- Ship Positioning & Movement
-- -----------

-- Move ship to coordinates relative to camera position
c_ship.move_to = function(x, y)
    c_ship.ship.x = cam.rel_x(x)
    c_ship.ship.y = cam.rel_y(y)
end
c_ship.move_to_x = function(x)
    c_ship.ship.x = cam.rel_x(x)
end
c_ship.move_to_y = function(y)
    c_ship.ship.y = cam.rel_y(y)
end

-- Move ship to coordinates relative to camera center position
c_ship.move_to_c = function(x, y)
    c_ship.ship.x = cam.rel_cx(x)
    c_ship.ship.y = cam.rel_cy(y)
end
c_ship.move_to_cx = function(x)
    c_ship.ship.x = cam.rel_cx(x)
end
c_ship.move_to_cy = function(y)
    c_ship.ship.y = cam.rel_cy(y)
end

-- Move ship by x
c_ship.move_x = function(x)
    c_ship.ship.x += x
    c_ship.add_trails()
end
c_ship.move_y = function(y)
    c_ship.ship.y += y
    c_ship.add_trails()
end

-- Move ship in a direction
c_ship.move_d = function(d)
    local s = c_ship.get()

    -- create a force acting on the ship
    if d == 'l' then s.vx -= s.f end
    if d == 'r' then s.vx += s.f end
    if d == 'u' then s.vy -= s.f end
    if d == 'd' then s.vy += s.f end

    -- Add some nce trails
    c_ship.add_trails()
end

c_ship.add_trails = function()
    c_ship.add_trail(c_ship.ship.x, c_ship.ship.y + 1)
    c_ship.add_trail(c_ship.ship.x, c_ship.ship.y + c_ship.ship.h - 2)
end

c_ship.reset = function()
    c_ship.ship = c_ship.new()
end

c_ship.get = function()
    return c_ship.ship
end

c_ship.hide = function()
    c_ship.ship.sp = {0}
end



c_ship.update_position = function()

    local s = c_ship.get()

    -- apply friction
    s.vx *= s.fx
    s.vy *= s.fy

    -- set the direction
    if s.vx > 1 or s.vx < -1 then
        s.dx = s.vx
    end

    if s.vy > 1 or s.vy < -1 then
        s.dy = s.vy
    end

    -- set new position of ship
    s.x += s.vx
    s.y += s.vy

    -- ship can't leave level edges
    local offset = 0
    if s_game.state == 0 then
        offset = 8
    end

    if s.x < offset then
        s.x = offset
        s.vx = 0
    end
    if s.x > s_game.level.w - s.w - offset then
        s.x = s_game.level.w - s.w - offset
        s.vx = 0
    end

    if s.y < offset then
        s.y = offset
        s.vy = 0
    end
    if s.y > s_game.level.h - s.h - offset then
        s.y = s_game.level.h - s.h - offset
        s.vy = 0
    end

    -- ship can't leave camera edges
    if s.x < area.x then
        s.x = area.x
        s.vx = 0
    end
    if s.x > area.x + area.w - s.w then
        s.x = area.x + area.w - s.w
        s.vx = 0
    end

    if s.y < area.y then
        s.y = area.y
        s.vy = 0
    end
    if s.y > area.y + area.h - s.h then
        s.y = area.y + area.h - s.h
        s.vy = 0
    end

end

c_ship.add_trail = function(x, y)
     -- Set default parameters
    local t = {
        x = x,
        y = y,
        c = 1, -- current cycle
        lc = 15 -- lifecycles (lasts for x frames)
    }
    t.cl = {7,10,9,8,1} -- colour list to cycle through
    -- Set the sprites
    add(c_ship.trails, t)
end

c_ship._draw = function()
    local s = c_ship.get()
    foreach(c_ship.trails, c_ship.draw_trail)
    spr(s.sp[frame%(count(s.sp))+1], s.x, s.y)
end

c_ship.draw_trail = function(t)
    if(t.c >= t.lc) then
        del(c_ship.trails, t)
    else
        t.c += 1;
    end
    pset(t.x, t.y, t.cl[ceil(count(t.cl)/(t.lc/t.c))])
end
