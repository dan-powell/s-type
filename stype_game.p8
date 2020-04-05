pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
c_game = {}
c_game._init = function()
    c_game.pickups = {}
    c_game.shots = {}
    c_game.enemies = {}
    c_game.explosions = {}
    c_game.thrusttrails = {}
    c_game.enemy_queue = {}
end
c_game._focus = function(ship)
    c_game.selectedship = ship
    for k,p in pairs(config.ship) do
        c_game.selectedship[k] = p
    end
    c_game.setup()
end
c_game.setup = function()
    state = 1
    status = 1
    player = {}
    player.lives = 6
    player.score = 10
    player.lvl = 0
    ship = c_game.new_ship()
end
c_game._update = function()
    if status == 0 then
        -- start of level
        if btnp(5) then
            status = 1
        end
    end

    if status == 1 then
        -- level in progress
        c_game.move_actors()
        c_game.move_ship()
        c_game.update_ship()
        c_game.update_shots()
        c_game.update_enemies()
        c_game.update_camera()
    end

    if status == 2 then
        -- level complete
        if btnp(5) then
            next()
        end
    end

    if status == 3 then
        -- level lost
        if btnp(5) then
            finish()
        end
    end

    if status == 4 then
        -- game won
        if btnp(5) then
            finish()
        end
    end
end
c_game.reset = function()
    status = 0
    c_game.pickups = {}
    c_game.shots = {}
    c_game.enemies = {}
    c_game.enemy_queue = {}
    --cam.x -= 256
    if cam.x < 0 then
        cam.x = 0
    end
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
c_game.new_enemy = function(t, rt)
    local e = {}
    for k, v in pairs(t) do
        e[k] = v
    end

    e.rt = rt -- Release timer
    e.lt = t.lt -- Lifetime (total)
    e.ltr = t.lt -- Lifetime remaining
    e.st = 0 -- Sprite timer

    e.sx = t.psx + t.tx
    e.sy = t.psy + 0
    e.ex = t.pex + t.tx
    e.ey = t.pey + 0

    e.p1x = t.p1x + t.tx
    e.p1y = t.p1y + 0
    e.p2x = t.p2x + t.tx
    e.p2y = t.p2y + 0

    return e
end
c_game.trigger_enemies = function()
    for k,es in pairs(level.e) do
        if ((cam.x + cam.w) == es.tx) then
            for i=1,es.n do
                add(c_game.enemy_queue, c_game.new_enemy(es, i*10))
            end
            -- level.e[k] = nil
        end
    end
end
c_game.process_enemy_queue = function()
    for k,enemy in pairs(c_game.enemy_queue) do
        if(enemy.rt <= 0) then
            enemy.o = frame
            add(c_game.enemies, enemy)
            del(c_game.enemy_queue, enemy)
        end
        enemy.rt -= 1
    end
end
c_game.update_enemies = function()
    c_game.trigger_enemies()

    c_game.process_enemy_queue()

    for k1,e in pairs(c_game.enemies) do
        -- Check if enemy has collided with shot
        for k2,s in pairs(c_game.shots) do
            if (s.x > e.x and s.x < (e.x + e.w) and s.y > e.y and s.y < (e.y + e.h)) then
                player.score += e.pv
                c_game.add_explosion(e.x, e.y, 1)
                del(c_game.enemies, e)
                del(c_game.shots, s)
            end
        end
        -- Check if enemy has collided with ship
        if collision(ship, e) then
            player.score -= e.pv
            c_game.add_explosion(ship.x, ship.y, 2)
            del(c_game.enemies, e)
            ship.s = 0
            c_game.reset()
        end
    end
end
c_game.update_ship = function()
    -- Check if ship has collided with brick
    if  collision_tile(ship.x, ship.y) or
        collision_tile(ship.x + ship.w, ship.y) or
        collision_tile(ship.x, ship.y + ship.h) or
        collision_tile(ship.x + ship.w, ship.y + ship.h) then
        player.score -= 99
        c_game.add_explosion(ship.x, ship.y, 2)
        ship.s = 0
        c_game.reset()
    end
end
c_game.move_enemy = function(e)
    -- Base updated position on a bezier curve (quad)
    e.x = bezier_quad(e.lt,e.o,e.sx,e.ex,e.p1x,e.p2x)
    e.y = bezier_quad(e.lt,e.o,e.sy,e.ey,e.p1y,e.p2y)
    -- Check for end of life and remove
    if (e.ltr <= 1) then
        del(c_game.enemies, e)
    else
        e.ltr -= 1
    end
end
c_game.update_camera = function()
    local y = ship.y - (cam.y+cam.h/2) -- x offset of ship from center of cam

    -- center the camera on the ship, but only if it approaches edges of screen
    if y > 30 or y < -30 then
        cam.y += ceil(y/12)
    end

    -- limit the camera to stop it revealing outside of map
    if cam.x < 0 then
        cam.vx = 0
    elseif cam.x > level.w - cam.w then
        cam.vx = 0
    end

    -- move the camera +x automatically
    cam.x += cam.vx

    if cam.y < 0 then
        cam.y = 0
    elseif cam.y > level.h - cam.h then
        cam.y = level.h - cam.h
    end

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

    -- move with cam
    ship.x += cam.vx

    -- ship can't leave level edges
    local offset = 0
    if status == 0 then
        offset = 8
    end

    if ship.x < offset then
        ship.x = offset
        ship.vx = 0
    end
    if ship.x > level.w - ship.w - offset then
        ship.x = level.w - ship.w - offset
        ship.vx = 0
    end

    if ship.y < offset then
        ship.y = offset
        ship.vy = 0
    end
    if ship.y > level.h - ship.h - offset then
        ship.y = level.h - ship.h - offset
        ship.vy = 0
    end

    -- ship can't leave camera edges
    local offset = 0
    if status == 0 then
        offset = 8
    end

    if ship.x < cam.x then
        ship.x = cam.x
        ship.vx = 0
    end
    if ship.x > cam.x + cam.w - ship.w then
        ship.x = cam.x + cam.w - ship.w
        ship.vx = 0
    end

    -- Add thrust trails
    c_game.add_thrusttrail(ship.x, ship.y + 1)
    c_game.add_thrusttrail(ship.x, ship.y + ship.h - 2)

end
c_game.move_shot = function(s)
    s.x += s.vx

    -- If the shot hits a physical tile
    if collision_tile(s.x, s.y) then
        del(c_game.shots, s)
    end

    -- If the shot leaves camera, remove it from memory
    if s.x > cam.x + cam.w then
        del(c_game.shots, s)
    end
end
c_game.move_actors = function()
    foreach(c_game.shots, c_game.move_shot)
    foreach(c_game.enemies, c_game.move_enemy)
end

-- --------------------------
-- draw
-- --------------------------
c_game._draw = function()
    camera(cam.x, cam.y)
    cls(0)
    map(level.mx,level.my,0,0,level.tw,level.th)
    print(stat(0), cam.x, cam.y + cam.h - 16, 7) -- debug memory
    print(stat(1), cam.x, cam.y + cam.h - 8, 7) -- debug cpu
    c_game.draw_actors()
    c_game.draw_ui()
    if status == 0 then
        print('❎ to launch', cam.x + flr(cam.w/2) - 24, cam.y + flr(cam.h/2) + 30, 9)
    end
    if status == 2 then
        print('level complete', cam.x + flr(cam.w/2) - 26, cam.y + flr(cam.h/2) + 20, 12)
        print('❎ for next level', cam.x + flr(cam.w/2) - 32, cam.y + flr(cam.h/2) + 30, 9)
    end
    if status == 3 then
        print('you lost :(', cam.x + flr(cam.w/2) - 20, cam.y + flr(cam.h/2) + 20, 8)
        print('❎ for scores', cam.x + flr(cam.w/2) - 28, cam.y + flr(cam.h/2) + 30, 9)
    end
    if status == 4 then
        print('you win!', cam.x + flr(cam.w/2) - 16, cam.y + flr(cam.h/2) + 20, 3)
        print('❎ for scores', cam.x + flr(cam.w/2) - 28, cam.y + flr(cam.h/2) + 30, 9)
    end
end
c_game.draw_actors = function()
    foreach(c_game.shots, c_game.draw_shot)
    foreach(c_game.enemies, c_game.draw_enemy)
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
c_game.draw_enemy = function(e)
    if(frame%(4)==0) then
        e.st += 1
        if(e.st > tablelength(e.s)) then
            e.st = 1
        end
    end
    spr(e.s[e.st], e.x, e.y, e.sw, e.sh)
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
    -- draw lives
    for i = 1, min(player.lives,6) do
        spr(5, cam.x + cam.w - 9 - (i*8), cam.y + 9)
    end

    -- if player.lives - 6 > 0 then
      --  print('+' .. player.lives - 6, cam.x + cam.w - 68, cam.y + 9, 8)
    -- end

    -- draw score
    print(player.score, cam.x + 9, cam.y + 9, 9)
end
controllers["game"] = c_game