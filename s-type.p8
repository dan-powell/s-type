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
balls = {}
paddles = {}

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
        x = 0, -- absolute x position
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
    }
}


-- camera attributes
cam = {
    x = 0,
    y = 0,
    w = 128,
    h = 128,
    b = 0
}
cam.c = flr(cam.h/2)

-- level attributes
levels = {
    {
        title = "level 1",
        next = 2,
        tw = 64, -- width in tiles
        th = 32, -- height in tiles
        w = 512, -- width in pixels
        h = 256, -- height in pixels
        mx = 0, -- map tile x coordinate
        my = 0, -- map tile y coordinate
        paddles = {}
    },

}
level = levels[1]

-- ====================================
-- title
-- ====================================

function init_title()
    printh('title')
    -- set the state of the game
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

    if status < 2 then
        -- level in progress
        move_actors()
        move_ship()
        update_camera()
        check_win()
        if status == 1 then
            check_lost()
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
    if count(balls) <= 0 then
        -- todo lose a life
        player.lives -= 1
        reset()
        if player.lives <= 0 then
            status = 3
        end
    end
end

-- update the camera position
function update_camera()

    local x = ship.x - (cam.x+cam.w/2) -- x offset of ship from center of cam
    local y = ship.y - (cam.y+cam.h/2) -- x offset of ship from center of cam

    -- center the camera on the ship, but only if it approaches edges of screen
    if x > 30 or x < -30 then
        cam.x += ceil(x/12);
    end

    if y > 30 or y < -30 then
        cam.y += ceil(y/12);
    end

    -- limit the camera to stop it revealing outside of map
    if cam.x < 0 then
        cam.x = 0
    elseif cam.x > level.w - cam.w then
        cam.x = level.w - cam.w
    end

    if cam.y < 0 then
        cam.y = 0
    elseif cam.y > level.h - cam.h then
        cam.y = level.h - cam.h
    end

end

-- update all actors
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

end

-- update all actors
function move_actors()
    foreach(balls, move_ball)
    foreach(pickups, move_pickup)
end


-- collide with a collidable tile
function collide(x, y)
    t=tget(x, y)
    -- test if tile is physical
    if fget(t, 0) then
        -- test if tile is a brick
        if fget(t, 1) then

            -- check if tile has a debounce value
            if has_debounce(x,y) == false then
                if fget(t, 5) then
                    -- 4th brick
                    tset(x, y, t-1)
                    player.score += 25
                    sfx(2)
                elseif fget(t, 4) then
                    -- 3rd brick
                    tset(x, y, t-1)
                    player.score += 50
                    sfx(3)
                elseif fget(t, 3) then
                    -- 2nd brick
                    tset(x, y, t-1)
                    player.score += 75
                    sfx(4)
                elseif fget(t, 2) then
                    -- lightest brick
                    tset(x, y, 0)
                    player.score += 100
                    level.b -= 1
                    player.bricks += 1
                    if ceil(rnd(100)) <= level.pc then
                        add_pickup(x,y)
                        sfx(2)
                    else
                        sfx(5)
                    end
                end
                set_debounce(x,y,4) -- set a debounce on tile
            end
        end
        return true
    else
        return false
    end
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
    camera(cam.x, cam.y)
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
    -- foreach(balls, draw_ball)
end

function draw_ship()
    spr(1, ship.x, ship.y)
end

function draw_ball(b)
    spr(b.s, b.x, b.y)
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
00000000888000000000000000e00e00400000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070088800000000000000e0000e0400000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000888888800777700e000000e400000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000888888800000000e00e000e400000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070088800000000000000e0000e0400000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888000000000000000e00e00400000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000800000000000000000ee000455555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0404040404040404040404040404040404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000000000000000000040404040400000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000000000000000000000004000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000004000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000040404040404040404040400000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404040404040404040404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00100000000000000013700177001a7001d70020700237002670028700297002a7002a700297002770024700207001c700147000e7000b7000b7000d700117001670000000000000000000000000000000000000
00100000000002c700297002870023700207001f7001e7002f7001f7001e7001d7001b7001d70015700217002170016700167001670016700167001670018700187001b7001d7001c7001c700000000000000000
__music__
01 00414344
00 01424344
02 01020304
02 01024344
