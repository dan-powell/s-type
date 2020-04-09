pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
c_game = {}
c_game._init = function()
    c_game.state = 0
    c_game.timeline = 0
    c_game.timeline_speed = 1
    c_game.pickups = {}
    c_game.shots = {}
    c_game.tiles = {}
    c_game.explosions = {}
    c_game.thrusttrails = {}
    c_game.enemy_queue = {}
    c_game.level = levels[1]
    c_game.starfield = {}
    enemies._init()
end
c_game._focus = function(ship)
    c_game.selectedship = ship
    for k,p in pairs(config.ship) do
        c_game.selectedship[k] = p
    end
    c_game.setup()
end
c_game.setup = function()
    c_game.state = 0
    status = 1
    player = {}
    player.lives = 6
    player.score = 10
    player.lvl = 0
    ship = c_game.new_ship()
end
c_game._update = function()

    c_game.create_star(0)

    if c_game.state == 0 then
        -- start of level
        if btnp(5) then
            c_game.state = 1
        end
        c_game.timeline_speed = 10
    end

    if c_game.state == 1 then
        c_game.timeline_speed = 1
        -- level in progress
        c_game.move_actors()
        c_game.move_ship()
        c_game.update_ship()
        c_game.update_shots()
        enemies._update()
        c_game.update_tiles()

        c_game.timeline += c_game.timeline_speed
    end

    if c_game.state == 2 then
        -- level complete
        if btnp(5) then
            next()
        end
    end

    if c_game.state == 3 then
        -- level lost
        if btnp(5) then
            finish()
        end
    end

    if c_game.state == 4 then
        -- game won
        if btnp(5) then
            finish()
        end
    end
end
c_game.reset = function()
    c_game.state = 0
    c_game.timeline -= 128
    c_game.pickups = {}
    c_game.shots = {}
    c_game.tiles = {}
    enemies.reset()
    ship = c_game.new_ship()
end
c_game.new_ship = function()
    local s = {}
    for k, v in pairs(c_game.selectedship) do
        s[k] = v
    end
    return s
end
c_game.add_shot = function(x, y)
    local s = {}
    s.vx = config.shot.vx
    s.x = x
    s.y = y
    add(c_game.shots, s)
end
c_game.add_explosion = function(x, y, t)
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
    add(c_game.explosions, e)
end
c_game.add_thrusttrail = function(x, y)
     -- Set default parameters
    local t = {
        x = x,
        y = y,
        c = 1, -- current cycle
        lc = 15 -- lifecycles (lasts for x frames)
    }
    t.cl = {7,10,9,8,1} -- colour list to cycle through
    -- Set the sprites
    add(c_game.thrusttrails, t)
end

c_game.new_tile = function(tile)
    local t = {}
    for k, v in pairs(tile) do
        t[k] = v
    end
    t.x = 128
    t.st = 0 -- Sprite timer
    return t
end

c_game.update_tiles = function()

    for k,t in pairs(c_game.level.t) do
        if (ceil(c_game.timeline) == t.t) then
            add(c_game.tiles, c_game.new_tile(t))
        end
    end

    for k1,t in pairs(c_game.tiles) do
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
        if collision(ship, t) then
            c_game.add_explosion(ship.x, ship.y, 2)
            del(c_game.tiles, t)
            ship.s = 0
            c_game.reset()
        end
    end
end
c_game.move_tile = function(t)
    -- Base updated position on a bezier curve (quad)
    t.x -= c_game.timeline_speed
    -- Check for end of life and remove
    if (t.x < 0) then
        del(c_game.tiles, t)
    end
end

c_game.update_ship = function()
    -- Check if ship has collided with brick
    if  collision_tile(ship.x, ship.y, c_game.level) or
        collision_tile(ship.x + ship.w, ship.y, c_game.level) or
        collision_tile(ship.x, ship.y + ship.h, c_game.level) or
        collision_tile(ship.x + ship.w, ship.y + ship.h, c_game.level) then
        player.score -= 99
        c_game.add_explosion(ship.x, ship.y, 2)
        ship.s = 0
        c_game.reset()
    end
end

c_game.update_camera = function()
    
end
c_game.update_shots = function()
    if(not debounce) debounce=0
    debounce += 1
    if btn(5) and debounce > 10 then
       c_game.add_shot(ship.x + 3, ship.y)
       c_game.add_shot(ship.x + 3, ship.y + ship.h - 1)
       debounce = 0
    end
end
c_game.move_ship = function()
    
    -- create a force acting on the ship
    local f = 0
    if btn(0) then ship.vx -= ship.f end
    if btn(1) then ship.vx += ship.f end
    if btn(2) then ship.vy -= ship.f end
    if btn(3) then ship.vy += ship.f end

    -- apply friction
    ship.vx *= ship.fx
    ship.vy *= ship.fy

    -- set the direction
    if ship.vx > 1 or ship.vx < -1 then
        ship.dx = ship.vx
    end

    if ship.vy > 1 or ship.vy < -1 then
        ship.dy = ship.vy
    end

    -- set new position of ship
    ship.x += ship.vx
    ship.y += ship.vy

    -- ship can't leave level edges
    local offset = 0
    if status == 0 then
        offset = 8
    end

    if ship.x < offset then
        ship.x = offset
        ship.vx = 0
    end
    if ship.x > c_game.level.w - ship.w - offset then
        ship.x = c_game.level.w - ship.w - offset
        ship.vx = 0
    end

    if ship.y < offset then
        ship.y = offset
        ship.vy = 0
    end
    if ship.y > c_game.level.h - ship.h - offset then
        ship.y = c_game.level.h - ship.h - offset
        ship.vy = 0
    end

    -- ship can't leave camera edges
    local offset = 0
    if status == 0 then
        offset = 8
    end

    if ship.x < area.x then
        ship.x = area.x
        ship.vx = 0
    end
    if ship.x > area.x + area.w - ship.w then
        ship.x = area.x + area.w - ship.w
        ship.vx = 0
    end

    if ship.y < area.y then
        ship.y = area.y
        ship.vy = 0
    end
    if ship.y > area.y + area.h - ship.h then
        ship.y = area.y + area.h - ship.h
        ship.vy = 0
    end


    -- Add thrust trails
    c_game.add_thrusttrail(ship.x, ship.y + 1)
    c_game.add_thrusttrail(ship.x, ship.y + ship.h - 2)

end
c_game.move_shot = function(s)
    s.x += s.vx

    -- If the shot hits a physical tile
    if collision_tile(s.x, s.y, c_game.level) then
        del(c_game.shots, s)
    end

    -- If the shot leaves camera, remove it from memory
    if s.x > area.x + area.w then
        del(c_game.shots, s)
    end
end
c_game.move_actors = function()
    foreach(c_game.shots, c_game.move_shot)
    foreach(c_game.tiles, c_game.move_tile)
end

-- --------------------------
-- draw
-- --------------------------
c_game._draw = function()
    camera(0,0)
    cls(1)
    map(c_game.level.mx,c_game.level.my,0,0,c_game.level.tw,c_game.level.th)
    if debug then
        print('t: ' .. c_game.timeline, 80, 121, 7) -- debug memory
        print('mem: ' .. stat(0), 2, 113, 7) -- debug memory
        print('cpu: ' .. stat(1), 2, 121, 7) -- debug cpu
    end
    foreach(c_game.starfield, c_game.draw_starfield)
    c_game.draw_actors()
    c_game.draw_ui()
    -- if status == 0 then
    --     print('❎ to launch', cam.x + flr(cam.w/2) - 24, cam.y + flr(cam.h/2) + 30, 9)
    -- end
    -- if status == 2 then
    --     print('level complete', cam.x + flr(cam.w/2) - 26, cam.y + flr(cam.h/2) + 20, 12)
    --     print('❎ for next level', cam.x + flr(cam.w/2) - 32, cam.y + flr(cam.h/2) + 30, 9)
    -- end
    -- if status == 3 then
    --     print('you lost :(', cam.x + flr(cam.w/2) - 20, cam.y + flr(cam.h/2) + 20, 8)
    --     print('❎ for scores', cam.x + flr(cam.w/2) - 28, cam.y + flr(cam.h/2) + 30, 9)
    -- end
    -- if status == 4 then
    --     print('you win!', cam.x + flr(cam.w/2) - 16, cam.y + flr(cam.h/2) + 20, 3)
    --     print('❎ for scores', cam.x + flr(cam.w/2) - 28, cam.y + flr(cam.h/2) + 30, 9)
    -- end
end
c_game.create_star = function(x)
    local s = {}
    s.x = 128
    s.y = rnd(128)
    s.c = 7
    s.vx = rnd(1) * 3
    col = {1,5,6,13} -- colour pool
    s.c = col[ceil(rnd(count(col)))] -- pick a colour
    add(c_game.starfield, s)
end
c_game.draw_starfield = function(s)
    s.x -= s.vx * c_game.timeline_speed
    pset(s.x, s.y, s.c)
    if s.y > 128 then
        del(c_game.starfield, s)
    end
end
c_game.draw_actors = function()
    foreach(c_game.shots, c_game.draw_shot)
    enemies._draw()
    foreach(c_game.tiles, c_game.draw_tile)
    foreach(c_game.explosions, c_game.draw_explosion)
    foreach(c_game.thrusttrails, c_game.draw_thrusttrail)
    c_game.draw_ship()
end
c_game.draw_ship = function()
    spr(ship.sp[frame%(count(ship.sp))+1], ship.x, ship.y)
end
c_game.draw_shot = function(s)
    pset(s.x, s.y, 7)
end
c_game.draw_tile = function(t)
    if(frame%(4)==0) then
        t.st += 1
        if(t.st > tablelength(t.s)) then
            t.st = 1
        end
    end
    spr(t.s[t.st], t.x, t.y, t.sw, t.sh)
end
c_game.draw_explosion = function(e)
    if(e.cs >= count(e.as)) then
        del(c_game.explosions, e)
    else
       if(frame%(4)==0) then
           e.cs += 1;
       end
    end
    spr(e.as[e.cs], e.x, e.y)
end
c_game.draw_thrusttrail = function(t)
    if(t.c >= t.lc) then
        del(c_game.thrusttrails, t)
    else
        t.c += 1;
    end
    pset(t.x, t.y, t.cl[ceil(count(t.cl)/(t.lc/t.c))])
end
c_game.draw_ui = function()

    rectfill(0,0,127,10,2)

    -- draw lives
    for i = 1, min(player.lives,6) do
        spr(5, 127 - (i*9), 2)
    end

    -- if player.lives - 6 > 0 then
      --  print('+' .. player.lives - 6, cam.x + cam.w - 68, cam.y + 9, 8)
    -- end

    -- draw score
    print(player.score, 2, 2, 9)
end
controllers["game"] = c_game