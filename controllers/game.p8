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
    c_game.enemy_queue = {}
    c_game.level = levels[1]
    c_game.starfield = {}
    enemies._init()
end
c_game._focus = function(ship)
    c_ship.select(ship)
    c_game.setup()
end
c_game.setup = function()
    c_game.state = 0
    status = 1
    player = {}
    player.lives = 6
    player.score = 10
    player.lvl = 0
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
        c_ship._update()
        c_game.move_ship()
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
    c_ship.reset()
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
        local s = c_ship.get()
        if collision(s, t) then
            c_game.add_explosion(s.x, s.y, 2)
            del(c_game.tiles, t)
            c_ship.hide()
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


c_game.update_camera = function()
    
end
c_game.update_shots = function()
    if(not debounce) debounce=0
    debounce += 1
    if btn(5) and debounce > 10 then
        local s = c_ship.get()
        c_game.add_shot(s.x + 3, s.y)
        c_game.add_shot(s.x + 3, s.y + s.h - 1)
        debounce = 0
    end
end
c_game.move_ship = function()
    if btn(0) then c_ship.move('l') end
    if btn(1) then c_ship.move('r') end
    if btn(2) then c_ship.move('u') end
    if btn(3) then c_ship.move('d') end
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
    enemies._draw()
    c_ship._draw()
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
    if s.x < 0 then
        del(c_game.starfield, s)
    end
end
c_game.draw_actors = function()
    foreach(c_game.shots, c_game.draw_shot)
    
    foreach(c_game.tiles, c_game.draw_tile)
    foreach(c_game.explosions, c_game.draw_explosion)
    
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