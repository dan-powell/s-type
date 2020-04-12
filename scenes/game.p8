pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
s_game = {}
-- ===========
-- core
-- ===========
s_game._init = function()
    s_game.state = 0
    s_game.timeline = 0
    s_game.timeline_speed = 1
    s_game.level = levels[1]
    s_game.starfield = {}
end
s_game._focus = function()
    s_game.setup()
end
s_game._update = function()

    s_game.create_star(0)

    if s_game.state == 0 then
        -- intro
        if(timer.get('intro') < 50) then
            c_ship.move_x(1)
        else
            timer.remove('intro')
            s_game.state = 1
        end
        s_game.timeline_speed = 10
    end

    if s_game.state == 1 then
        s_game.timeline_speed = 1
        -- level in progress
        s_game.move_ship()
        c_ship._update()
        c_shots._update()
        c_enemies._update()
        c_tiles._update()

        s_game.timeline += s_game.timeline_speed
    end

    if s_game.state == 2 then
        -- death
        if(timer.get('outro') < 50) then

        else
            s_game.reset()
            timer.remove('outro')
            s_game.state = 0
        end
        s_game.timeline_speed = 0.25
    end

    if s_game.state == 3 then
        -- level lost
        if btnp(5) then
            finish()
        end
    end

    if s_game.state == 4 then
        -- game won
        if btnp(5) then
            finish()
        end
    end
end
s_game._draw = function()
    camera(0,0)
    cls(1)
    map(s_game.level.mx,s_game.level.my,0,0,s_game.level.tw,s_game.level.th)
    if debug then
        print('t: ' .. s_game.timeline, 80, 121, 7) -- debug memory
        print('mem: ' .. stat(0), 2, 113, 7) -- debug memory
        print('cpu: ' .. stat(1), 2, 121, 7) -- debug cpu
    end
    foreach(s_game.starfield, s_game.draw_starfield)

    c_tiles._draw()
    c_enemies._draw()
    c_ship._draw()
    c_explosions._draw()
    c_shots._draw()
    s_game.draw_ui()

    if s_game.state == 0 then
        print('stand by', cam.x + flr(cam.w/2) - 24, cam.y + flr(cam.h/2) + 30, 9)
    end

    if s_game.state == 2 then
        print('destruction', cam.x + flr(cam.w/2) - 24, cam.y + flr(cam.h/2) + 30, 9)
    end

end
-- ===========
-- core
-- ===========
s_game.setup = function()
    s_game.reset()
    c_player.reset()
end
s_game.reset = function()
    s_game.state = 0
    s_game.timeline -= 128

    c_enemies.reset()
    c_tiles.reset()
    c_shots.reset()
    c_ship.reset()

    c_ship.move_to_x(-8)
    c_ship.move_to_cy(0)

    timer.new('intro')
end
s_game.move_ship = function()
    if btn(0) then c_ship.move_d('l') end
    if btn(1) then c_ship.move_d('r') end
    if btn(2) then c_ship.move_d('u') end
    if btn(3) then c_ship.move_d('d') end
end
s_game.create_star = function(x)
    local s = {}
    s.x = 128
    s.y = rnd(128)
    s.c = 7
    s.vx = rnd(1) * 3
    col = {1,5,6,13} -- colour pool
    s.c = col[ceil(rnd(count(col)))] -- pick a colour
    add(s_game.starfield, s)
end
s_game.draw_starfield = function(s)
    s.x -= s.vx * s_game.timeline_speed
    pset(s.x, s.y, s.c)
    if s.x < 0 then
        del(s_game.starfield, s)
    end
end
s_game.draw_ui = function()

    rectfill(0,0,127,6,2)

    -- draw lives
    -- spr(5, 127 - (i*9), 2)
    sspr(8,0,8,8, 114,1, 5,5)
    print(c_player.lives_get(), 120, 1, 9)

    -- draw score
    print(c_player.score_get(), 1, 1, 9)
end
scenes["game"] = s_game
