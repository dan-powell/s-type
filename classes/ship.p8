pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

c_ship = {}
c_ship._init = function()
    c_ship.ship = {}
end

c_ship._update = function()
    c_ship.update_position()
    if  collision_tile(c_ship.ship.x, c_ship.ship.y, c_game.level) or
        collision_tile(c_ship.ship.x + c_ship.ship.w, c_ship.ship.y, c_game.level) or
        collision_tile(c_ship.ship.x, c_ship.ship.y + c_ship.ship.h, c_game.level) or
        collision_tile(c_ship.ship.x + c_ship.ship.w, c_ship.ship.y + c_ship.ship.h, c_game.level) then
        player.score -= 99
        c_game.add_explosion(c_ship.ship.x, c_ship.ship.y, 2)
        c_ship.hide()
        c_game.reset()
    end
end

c_ship.select = function(s)
    c_ship.selectedship = s
    for k,p in pairs(config.ship) do
        c_ship.selectedship[k] = p
    end
    c_ship.ship = c_ship.new()
    --ship = c_ship.new() -- temp
end

c_ship.new = function()
    local s = {}
    for k, v in pairs(c_ship.selectedship) do
        s[k] = v
    end
    return s
end

c_ship.reset = function()
    c_ship.ship = c_ship.new()
    --ship = c_ship.new() -- temp
end

c_ship.get = function()
    return c_ship.ship
end

c_ship.hide = function()
    c_ship.ship.s = 0
end

c_ship.move = function(d)
    local s = c_ship.get()
    -- create a force acting on the ship
    if d == 'l' then s.vx -= s.f end
    if d == 'r' then s.vx += s.f end
    if d == 'u' then s.vy -= s.f end
    if d == 'd' then s.vy += s.f end
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
    if c_game.state == 0 then
        offset = 8
    end

    if s.x < offset then
        s.x = offset
        s.vx = 0
    end
    if s.x > c_game.level.w - s.w - offset then
        s.x = c_game.level.w - s.w - offset
        s.vx = 0
    end

    if s.y < offset then
        s.y = offset
        s.vy = 0
    end
    if s.y > c_game.level.h - s.h - offset then
        s.y = c_game.level.h - s.h - offset
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

c_ship._draw = function()
    local s = c_ship.get()
    spr(s.sp[frame%(count(s.sp))+1], s.x, s.y)
end