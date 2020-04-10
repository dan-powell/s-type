pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- S-Type - an game by Matt and Dan

-- ====================================
-- Global Variables
-- ====================================

-- basic de-buggery
debug = true
frame = 0
tick = 0
version = "0.0.2 alpha"
lvlselect = {0,0,1,1,0,1}

controller_current = {}
controllers = {}

-- tile grid
grid = {}
grid.w = 8
grid.h = 8

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
        s = 1,
        t = 1, -- type 1 = main, 2 = space
        w = 8, -- width
        h = 8, -- height
        x = 64, -- absolute x position
        y = 64, -- absolute y position
        vx = 0, -- x velocity (pixels moved per frame)
        vy = 0, -- y velocity (pixels moved per frame)
        sw = 1, -- sprite width (in tiles)
        sh = 1, -- sprite height (in tiles)
        dx = -1, -- direction (+1 right -1 left)
        dy = -1, -- direction (+1 down -1 up)
    },
    ships = {
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
    },
    shot = {
        vx = 10, -- x velocity (pixels moved per frame)
    },
    explosion = {
        w = 8, -- width
        h = 8, -- height
        x = 0, -- absolute x position
        y = 0, -- absolute y position
        cs = 1,
    },
    enemy = {
        t = 3,
        h = 10, --
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
area = {
    x = 0,
    y = 11,
    w = 128,
    h = 117,
}
area.center_x = function()
    return ceil(area.w/2) + ceil(area.x/2)
end
area.center_y = function()
    return ceil(area.h/2) + ceil(area.y/2)
end

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
        t = {
            {t = 100, y = 40,  s = {32,33}, w = 8, h = 8, sw = 1, sh = 1 },
            {t = 100, y = 49,  s = {32,33}, w = 8, h = 8, sw = 1, sh = 1 },
            {t = 100, y = 60,  s = {32,33}, w = 8, h = 8, sw = 1, sh = 1 },
            {t = 120, y = 60,  s = {32,33}, w = 8, h = 8, sw = 1, sh = 1 },
            {t = 130, y = 50,  s = {32,33}, w = 8, h = 8, sw = 1, sh = 1 },
            {t = 140, y = 40,  s = {32,33}, w = 8, h = 8, sw = 1, sh = 1 },
            {t = 200, y = 100, s = {32,33}, w = 8, h = 8, sw = 1, sh = 1 },
            {t = 200, y = 20,  s = {32,33}, w = 8, h = 8, sw = 1, sh = 1 },
            {t = 250, y = 40,  s = {32,33}, w = 8, h = 8, sw = 1, sh = 1 },
            {t = 270, y = 40,  s = {32,33}, w = 8, h = 8, sw = 1, sh = 1 },
            {t = 270, y = 70,  s = {32,33}, w = 8, h = 8, sw = 1, sh = 1 },
            {t = 300, y = 40,  s = {32,33}, w = 8, h = 8, sw = 1, sh = 1 },
        },
        e = {
            a = {
                t = 40, -- trigger time
                n = 10, -- number to generate
                s = {32,33}, -- sprites
                sw = 1, -- sprite width (in tiles)
                sh = 1, -- sprite height (in tiles)
                l = 10, -- Life (health)
                w = 8, -- width
                h = 8, -- height
                lt = 75, -- lifetime (how long to exist)
                x = 0, -- absolute x position
                y = 0, -- absolute y position

                pv = 100, -- value in points (for scoring)

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
                t = 250,
                n = 5,
                s = {34,35},
                sw = 1,
                sh = 1,
                l = 10,
                w = 8,
                h = 8,
                lt = 100,
                x = 0,
                y = 0,

                pv = 150,

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
                t = 512,
                n = 10,
                s = {32,33},
                sw = 1,
                sh = 1,
                l = 10,
                w = 8,
                h = 8,
                lt = 75,
                x = 0,
                y = 0,

                pv = 100,

                psx = 0,
                psy = 0, 
                pex = 128, 
                pey = 128, 
                p1x = 0, 
                p1y = 128, 
                p2x = 128, 
                p2y = 0,
            },
            d = {
                t = 768,
                n = 5,
                s = {34,35},
                sw = 1,
                sh = 1,
                l = 10,
                w = 8,
                h = 8,
                lt = 100,
                x = 0,
                y = 0,
                pv = 150,

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

-- ====================================
-- includes
-- ====================================

#include classes/enemies.p8
#include classes/ship.p8
#include classes/tiles.p8
#include classes/shots.p8
#include classes/explosions.p8

#include controllers/title.p8
#include controllers/help.p8
#include controllers/shipselect.p8
#include controllers/game.p8
#include controllers/end.p8
#include controllers/levelselect.p8

-- ====================================
-- Global Helpers
-- ====================================

-- Get the length of a table
function tablelength(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

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

-- ====================================
-- state management
-- ====================================

function _update()
    tick += 1
    if (controller_current._update) then controller_current._update() end
end

function _draw()
    frame += 1
    if (controller_current._draw) then controller_current._draw() end
end

function switchController(newController, data)
    printh('switching to ' .. newController)
    found = controllers[newController]
    if (found == nil) then 
        printh('controller not found')
        return 
    end
    if (found) then newController = found end
    if (controller_current._blur) then 
        printh('controller blur')
        controller_current._blur()
    end
    controller_current = newController
    if (controller_current._init and controller_current.init == nil) then 
        printh('controller init')
        controller_current.init = true
        controller_current._init(data)
    end
    if (controller_current._focus) then 
        printh('controller focus')
        controller_current._focus(data)
    end
end

function _init()
    printh('_init')
    switchController("title")
    c_ship._init()
    c_shots._init()
    c_tiles._init()
    c_explosions._init()
    enemies._init()
end

__gfx__
0000000066c0000066d0000066c000006666666b666666636666666b066668000666680006666e00800000000000000000000000000000000000000000000000
000000009666000096660000a6660000a5556660955566609555666096600000a6600000966000000800000000000000000000000080800000e0e00000808000
00000000666760006667600066676000066666000666660006666600666600006666000066660000009000000000000000000000088888000e8e8e0008080800
00000000056676660566766605667666066700000667000006670000066766660667666606676666000a00000000000000000000088888000e888e0008000800
000000000566766605667666056676660667000006670000066700000667666606676666066766660090000000000000000000000088800000e8e00000808000
0000000066676000666760006667600006666600066666000666660066660000666600006666000008000000000000000000000000080000000e000000080000
0000000096660000a66600009666000095556660a5556660955566609660000096600000a6600000800000000000000000000000000000000000000000000000
0000000066c0000066d0000066c000006666666b666666636666666b066668000666680006666e00000000000000000000000000000000000000000000000000
00000000000000000000000000999900008888000022220000000000000000000000000090000009000000000000000000000000000000000000000000000000
00000000000000000009900009000090080000800200002000000000000000000900009000000000000000000000000000000000000000000000000000000000
00000000000990000090090090000009800000082000000200000000009009000000000000000000000000000000000000000000000000000000000000000000
00099000009009000900009090000009800000082000000200099000000000000000000000000000000000000000000000000000000000000000000000000000
00099000009009000900009090000009800000082000000200099000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000990000090090090000009800000082000000200000000009009000000000000000000000000000000000000000000000000000000000000000000
00000000000000000009900009000090080000800200002000000000000000000900009000000000000000000000000000000000000000000000000000000000
00000000000000000000000000999900008888000022220000000000000000000000000090000009000000000000000000000000000000000000000000000000
000ee000000ff000000bb00000033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00eeee0000ffff0000bbbb0000333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0eeeeee00ffffff00bbbbbb003333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeffffffffbbbbbbbb33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeffffffffbbbbbbbb33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0eeeeee00ffffff00bbbbbb003333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00eeee0000ffff0000bbbb0000333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ee000000ff000000bb00000033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666660000005555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666660055555665555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666665556666666555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666665666666666665555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666665665666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66665555556556566666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55550050055555556666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00500000000000056666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777777777000000077777777777777770007000000000700007777777777000007777777770000000000000000000000000000000000000000000000000
00776666666666700000566666666666666667056700000005670056666666666700056666666667000000000000000000000000000000000000000000000000
07765555555556770000055555556665555550056700000005670056655555556670056655555550000000000000000000000000000000000000000000000000
07675000000055670000000000055675000000056700000005670056750000005670056500000000000000000000000000000000000000000000000000000000
07670000000005670000000000005670000000056700000005670056700000005670056700000000000000000000000000000000000000000000000000000000
07670000000005670000000000005670000000056700000005670056700000005670056700000000000000000000000000000000000000000000000000000000
07670000000005670000000000005670000000056700000005670056700000005670056700000000000000000000000000000000000000000000000000000000
07670000000005670000000000005670000000056700000005670056700000005670056700000000000000000000000000000000000000000000000000000000
05667000000005670000000000005670000000056700000005670056700000005670056700000000000000000000000000000000000000000000000000000000
00566700000005670000000000005670000000056700000005670056700000005670056700000000000000000000000000000000000000000000000000000000
00056670000005570000000000005670000000056700000005670056700000005670056700000000000000000000000000000000000000000000000000000000
00005667000000500000000000005670000000056700000005670056700000005670056700000000000000000000000000000000000000000000000000000000
00000566700000000000000000005670000000056700000005670056700000005670056700000000000000000000000000000000000000000000000000000000
00000056670000000000000000005670000000056700000005670056700000005670056700000000000000000000000000000000000000000000000000000000
00000005667000000007777700005670000000056677777776670056677777776670056777777770000000000000000000000000000000000000000000000000
00000000566700000056666670005670000000055666666666500056666666666500056666666667000000000000000000000000000000000000000000000000
00000000056670000056666670005670000000005555666555000056655555555000056555555550000000000000000000000000000000000000000000000000
00000000005667000005555500005670000000000005567000000056700000000000056700000000000000000000000000000000000000000000000000000000
00700000000566700000000000005670000000000000567000000056700000000000056700000000000000000000000000000000000000000000000000000000
05770000000056670000000000005670000000000000567000000056700000000000056700000000000000000000000000000000000000000000000000000000
05670000000005670000000000005670000000000000567000000056700000000000056700000000000000000000000000000000000000000000000000000000
05670000000005670000000000005670000000000000567000000056700000000000056700000000000000000000000000000000000000000000000000000000
05670000000005670000000000005670000000000000567000000056700000000000056700000000000000000000000000000000000000000000000000000000
05670000000005670000000000005670000000000000567000000056700000000000056700000000000000000000000000000000000000000000000000000000
05670000000005670000000000005670000000000000567000000056700000000000056700000000000000000000000000000000000000000000000000000000
05670000000005670000000000005670000000000000567000000056700000000000056700000000000000000000000000000000000000000000000000000000
05670000000005670000000000005670000000000000567000000056700000000000056700000000000000000000000000000000000000000000000000000000
05670000000005670000000000005670000000000000567000000056700000000000056700000000000000000000000000000000000000000000000000000000
05677000000077670000000000005670000000000000567000000056700000000000056700000000000000000000000000000000000000000000000000000000
05567777777776770000000000005670000000000000567000000056700000000000056677777770000000000000000000000000000000000000000000000000
00556666666667700000000000005670000000000000567000000056700000000000056666666667000000000000000000000000000000000000000000000000
00055555555555000000000000000500000000000000050000000005000000000000005555555550000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000004041404140414040414041404140404140414041404140410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000004243424342434243424342434243424342434243424342430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00100000000000000013700177001a7001d70020700237002670028700297002a7002a700297002770024700207001c700147000e7000b7000b7000d700117001670000000000000000000000000000000000000
00100000000002c700297002870023700207001f7001e7002f7001f7001e7001d7001b7001d70015700217002170016700167001670016700167001670018700187001b7001d7001c7001c700000000000000000
__music__
01 00414344
00 01424344
02 01020304
02 01024344

