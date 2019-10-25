pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- s-Type - an game by Matt and Dan

-- todo
-- everything

-- basic de-buggery
debug = {}
frame = 0
version = "0.0.1 alpha"
lvlselect = {0,0,1,1,0,1}

-- tile grid
grid = {}
grid.w = 8
grid.h = 8

-- actor tables
pickups = {}
shots = {}
enemies = {}

enemy_queue = {}

-- core physics values
physics = {}
physics.gravity = 0.2
physics.fx = 0.02
physics.fy = 0.03
physics.vxmax = 2 -- max x velocity
physics.vymax = 5 -- max y velocity
physics.vymax_pos = 10 -- max y velocity


-- config defaults
config = {
    ship = {
        t = 1, -- type 1 = main, 2 = space
        w = 8, -- width
        h = 8, -- height
        x = 64, -- absolute x position
        y = 64, -- absolute y position
        vx = 0, -- x velocity (pixels moved per frame)
        vy = 0, -- y velocity (pixels moved per frame)
        fx = 0.7, -- horizontal friction
        fy = 0.7, -- vertical friction
        f = 2, -- force applied when moved
        sw = 1, -- sprite width (in tiles)
        sh = 1, -- sprite height (in tiles)
        dx = -1, -- direction (+1 right -1 left)
        dy = -1 -- direction (+1 down -1 up)
    },
    shot = {
        w = 8, -- width
        h = 8, -- height
        x = 0, -- absolute x position
        y = 0, -- absolute y position
        sw = 1, -- sprite width (in tiles)
        sh = 1, -- sprite height (in tiles)
        vx = 3, -- x velocity (pixels moved per frame)
    },
    enemy = {
        t = 3,
        h = 10,
        w = 8, -- width
        h = 8, -- height
        l = 0, -- lifetime
        x = 0, -- absolute x position
        y = 0, -- absolute y position
        sw = 1, -- sprite width (in tiles)
        sh = 1, -- sprite height (in tiles)
    }
}


-- camera attributes
cam = {
    x = 0,
    y = 0,
    w = 128,
    h = 128,
    b = 0,
    vx = 0.5
}
cam.c = flr(cam.h/2)

-- level attributes
levels = {
    {
        title = "level 1",
        next = 2,
        tw = 128, -- width in tiles
        th = 16, -- height in tiles
        w = 1024, -- width in pixels
        h = 128, -- height in pixels
        mx = 0, -- map tile x coordinate
        my = 0, -- map tile y coordinate
        e = {
            a = {
                tx = 128, -- Trigger x coord
                n = 10, -- number to generate
                s = 3, -- sprite
                l = 10, -- Life (health)
                w = 8, -- width
                h = 8, -- height
                lt = 75, -- lifetime (how long to exist)
                x = 0, -- absolute x position
                y = 0, -- absolute y position
                sw = 1, -- sprite width (in tiles)
                sh = 1, -- sprite height (in tiles)

                psx = 0, -- path start position relative to tx
                psy = 0, -- path start position relative to top of level
                pex = 128, -- path end position relative to tx
                pey = 128, -- path end position relative to top of level
                p1x = 0, -- path bezier point 1 relative to tx
                p1y = 128, -- path bezier point 1 relative top of level
                p2x = 128, -- path bezier point 1 relative to tx
                p2y = 0, -- path bezier point 1 relative top of level
            },
            b = {
                tx = 256,
                n = 5,
                s = 5,
                l = 10,
                w = 8,
                h = 8,
                lt = 100,
                x = 0,
                y = 0,
                sw = 1,
                sh = 1,

                psx = 0,
                psy = 128,
                pex = 0,
                pey = 0,
                p1x = 128,
                p1y = 0,
                p2x = 128,
                p2y = 128,
            },
            c = {
                tx = 512,
                n = 10,
                s = 3,
                l = 10,
                w = 8,
                h = 8,
                lt = 75,
                x = 0,
                y = 0,
                sw = 1,
                sh = 1,

                psx = 0,
                psy = 0, -- path start position relative to top of level
                pex = 128, -- path end position relative to tx
                pey = 128, -- path end position relative to top of level
                p1x = 0, -- path bezier point 1 relative to tx
                p1y = 128, -- path bezier point 1 relative top of level
                p2x = 128, -- path bezier point 1 relative to tx
                p2y = 0, -- path bezier point 1 relative top of level
            },
            d = {
                tx = 768,
                n = 5,
                s = 5,
                l = 10,
                w = 8,
                h = 8,
                lt = 100,
                x = 0,
                y = 0,
                sw = 1,
                sh = 1,

                psx = 0,
                psy = 128,
                pex = 0,
                pey = 0,
                p1x = 128,
                p1y = 0,
                p2x = 128,
                p2y = 128,
            }
        }
    },
}
level = levels[1]

-- ====================================
-- title
-- ====================================

function init_title()
    state = 0
    -- 0 start screen
    -- 1 game
    -- 2 score screen
    -- music(01)
    lvlselect_input = {-1,-1,-1,-1,-1,-1}
end

function update_title()
    if btnp(0) then
        del(lvlselect_input, lvlselect_input[1])
        add(lvlselect_input, 0)
    end
    if btnp(1) then
        del(lvlselect_input, lvlselect_input[1])
        add(lvlselect_input, 1)
    end
    local test = true
    for k, v in pairs(lvlselect_input) do
        if v != lvlselect[k] then
            test = false
        end
    end
    if test then
        init_lvlselect()
    end

    if btnp(5) then
        init_game()
    end
end

function draw_title()
    cls(1)

    print("s-type", 50, 20, 9)

    if(not flash) flash=0
    if(frame%(30/2)==0) then
        flash += 1
    end

    if flash%2 == 1 then
        print("press ❎ to start", 30, 40, 9)
    end

    print("instructions:", 2, 64, 15)
    print("wreck shit", 2, 72, 10)
    print(version, 3, 120, 2)
end

-- ====================================
-- game
-- ====================================

function init_game()
    start()
    state = 1
    status = 1
    reset()
end

-- --------------------------
-- game logic
-- --------------------------

function update_game()

    if status == 0 then
        -- start of level
        if btnp(5) then
            status = 1
        end
    end

    if status == 1 then
        -- level in progress
        update_camera()
        move_actors()
        move_ship()
        update_shots()
        update_enemies()
        check_win()
        if status == 1 then
            check_lost()
        end
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

-- start the game
function start()
    player = {}
    player.lives = 6
    player.score = 0
    player.lvl = 0
    ship = new_ship()
end

-- reset balls & paddles
function reset()
    status = 0
    balls = {}
    player = {}
end

function next()
    if level.next == 0 then
        init_scores()
    else
        level = levels[level.next]
    end
    player.lvl += 1
    reset()
end

function finish()
    init_scores()
end


function new_ship()
    local s = {}
    for k, v in pairs(config.ship) do
        s[k] = v
    end
    return s
end

function new_shot()
    local s = {}
    for k, v in pairs(config.shot) do
        s[k] = v
    end
    return s
end

function add_shot(x, y)
    local s = new_shot()
    s.x = x
    s.y = y
    add(shots, s)
end

function new_enemy(t, rt)
    local e = {}
    for k, v in pairs(t) do
        e[k] = v
    end

    e.rt = rt -- Release timer
    e.lt = t.lt -- Lifetime (total)
    e.ltr = t.lt -- Lifetime remaining

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


function trigger_enemies()
    for k,es in pairs(level.e) do
        if ((cam.x + cam.w) >= es.tx) then
            for i=1,es.n do
                add(enemy_queue, new_enemy(es, i*10))
            end
            level.e[k] = nil
        end
    end
end

function process_enemy_queue()

    printh('queue: ' .. tablelength(enemy_queue))
    for k,enemy in pairs(enemy_queue) do
        if(enemy.rt <= 0) then
            enemy.o = frame
            add(enemies, enemy)
            del(enemy_queue, enemy)
        end
        enemy.rt -= 1
    end

end

-- update enemies
function update_enemies()


    trigger_enemies()

    process_enemy_queue()

end

-- Update the enemy position
function move_enemy(e)
    -- Base updated position on a bezier curve (quad)
    e.x = bezier_quad(e.lt,e.o,e.sx,e.ex,e.p1x,e.p2x)
    e.y = bezier_quad(e.lt,e.o,e.sy,e.ey,e.p1y,e.p2y)
    -- Check for end of life and remove
    if (e.ltr <= 1) then
        del(enemies, e)
    else
        e.ltr -= 1
    end
end

-- update the camera position
function update_camera()

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

-- update shots
function update_shots()
    if(not shot_debounce) shot_debounce=0
    shot_debounce += 1
    if btn(5) and shot_debounce > 2 then
       add_shot(ship.x, ship.y)
       shot_debounce = 0
    end
end

-- update ship position
function move_ship()

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

end



-- Update the shot position
function move_shot(s)
    s.x += s.vx

    if collide(s.x, s.y) then
        del(shots, s)
    end

    -- If the shot leaves camera, remove it from memory
    if s.x > cam.x + cam.w then
        del(shots, s)
    end

end



-- update all actors
function move_actors()
    foreach(shots, move_shot)
    foreach(enemies, move_enemy)
end




-- check if level win critera achieved
function check_win()
    --if level.b <= 0 then
    --    if level.next == 0 then
    --        status = 4
    --    else
    --        status = 2
    --    end
    --end
end

-- check if lost life criteria achieved
function check_lost()
    -- if count(balls) <= 0 then
    --     -- todo lose a life
    --     player.lives -= 1
    --     reset()
    --     if player.lives <= 0 then
    --         status = 3
    --     end
    -- end
end


-- Helper Functions

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

-- collide with a collidable tile
function collide(x, y)
    t=tget(x, y)
    -- test if tile is physical
    if fget(t, 0) then
        tset(x, y, 0)
        return true
    else
        return false
    end
end

-- return the tile at a given pixel position
function tget(x, y)
    x += (level.mx * 8)
    y += (level.my * 8)
    return mget(flr(x/grid.w), flr(y/grid.h))
end

-- set the tile at a given pixel position
function tset(x, y, v)
    x += (level.mx * 8)
    y += (level.my * 8)
    return mset(flr(x/grid.w), flr(y/grid.h), v)
end

-- Calculate a bezier curve
-- Should be called once for X, and again for Y
-- l: length of time (frames)
-- s: Start value
-- e: End value
-- p1: Bezier point 1
function bezier(l,s,e,p1)
    local t = frame%l
    t = t/l*100
    t = t/100
    return (1-t)*((1-t)*s + t*p1) + t*((1-t)*p1 + t*e)
end

-- Calculate a quadratic bezier curve
-- Should be called once for X, and again for Y
-- l: length of time (frames)
-- s: Start value
-- e: End value
-- p1: Bezier point 1
-- p2: Bezier point 2
function bezier_quad(l,o,s,e,p1,p2)
    local t = (frame-o)%l
    t = t/l*100
    t = t/100
    return (1-t)*(1-t)*(1-t)*s + 3*(1-t)*(1-t)*t*p1 + 3*(1-t)*t*t*p2 + t*t*t*e
end

-- --------------------------
-- game drawing
-- --------------------------

function draw_game()
    cls(0)
    map(level.mx,level.my,0,0,level.tw,level.th)
    draw_actors()
    print(stat(0), cam.x, cam.y + cam.h - 16, 7) -- debug memory
    print(stat(1), cam.x, cam.y + cam.h - 8, 7) -- debug cpu
    camera(ceil(cam.x), ceil(cam.y))
    draw_ui()
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

function draw_actors()
    draw_ship()
    foreach(shots, draw_shot)
    foreach(enemies, draw_enemy)
end

function draw_ship()
    spr(1, ceil(ship.x), ceil(ship.y))
end

function draw_shot(s)
    spr(2, ceil(s.x), ceil(s.y))
end

function draw_enemy(e)
    spr(e.s, ceil(e.x), ceil(e.y))
end

function draw_ui()
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

-- ====================================
-- lose
-- ====================================

function init_scores()
    state = 2
end

function update_scores()
    if btnp(5) then
        run()
    end
end

function draw_scores()
    if player.lives > 0 then
        cls(3)
        print("good jorb", 48, 24, 11)
    else
        cls(2)
        print("try again next time", 24, 24, 11)
    end
    camera(0,0)
    spr(76, 96, 96, 4, 4) -- bork

    print("score: " .. player.score, 48, 32, 7)
    print("levels: " .. player.lvl, 48, 48, 7)
    print("bricks: " .. player.bricks, 48, 56, 7)
    print("bounces: " .. player.bounces, 48, 64, 7)
    print("lives left: " .. player.lives, 48, 72, 7)
    print("❎ to try again", 24, 96, 9)
end

-- ====================================
-- lose
-- ====================================

function init_lvlselect()
    state = 3
    select = 1
end

function update_lvlselect()
    if btnp(0) and select > 1 then
        select -= 1
    end

    if btnp(1) and select < count(levels) then
        select += 1
    end

    if btnp(5) then
        level = levels[select]
        init_game()
    end
end

function draw_lvlselect()
    cls(0)
    print("level select", 48, 32, 7)
    print(select, 48, 48, 7)
end

-- ====================================
-- state management
-- ====================================

function _init()
    printh('game start')
    init_title() -- does title things.
end

function _update()
    frame += 1
    if (state == 0) then --title screen state
        update_title()
    elseif (state == 1) then
        update_game()
    elseif (state == 2) then
        update_scores()
    elseif (state == 3) then
        update_lvlselect()
    end
end

function _draw()
    if (state == 0) then
        draw_title()
    elseif (state == 1) then
        draw_game()
    elseif (state == 2) then
        draw_scores()
    elseif (state == 3) then
        draw_lvlselect()
    end
end
__gfx__
000000000800000000000000000ee000444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888000000000000000e00e00400000050000900000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070088800000000000000e0000e0400000050099990000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000888888800777700e000000e400000050999990000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000888888800000000e00e000e400000050099999000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070088800000000000000e0000e0400000050099990000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888000000000000000e00e00400000050000900000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000800000000000000000ee000455555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0404040404040404040404040404040404040404040404040404040404000404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0400000000000000000000000000000000000000000000040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040000000000040400000000000000000000000000000000000000000000000000000000000000000000000000000000000004
0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000004
0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004
0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004
0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004
0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004
0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004
0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004
0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004
0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004
0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004
0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040000000000000000000000000000000000000000000000000004
0400000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040404040404000000000000000000000000000000000000000000000004
0400000000040404040404040404040400000000000000000000000000000000000000000000000000000000000000000000000000040404040400000000000000000000000000000000000000000000000000000000000000000000000000000004040000000404040400000000000000000000000000000000000000000004
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
__sfx__
00100000000000000013700177001a7001d70020700237002670028700297002a7002a700297002770024700207001c700147000e7000b7000b7000d700117001670000000000000000000000000000000000000
00100000000002c700297002870023700207001f7001e7002f7001f7001e7001d7001b7001d70015700217002170016700167001670016700167001670018700187001b7001d7001c7001c700000000000000000
__music__
01 00414344
00 01424344
02 01020304
02 01024344
