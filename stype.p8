pico-8 cartridge // http://www.pico-8.com
version 32
__lua__

-- S-Type - an game by Matt and Dan

-- ===========
-- Global Variables
-- ===========

-- basic de-buggery
debug = true
frame = 0
tick = 0
version = "0.0.2 alpha"
lvlselect = {0,0,1,1,0,1}

scene_current = {}
scenes = {}

-- tile grid
grid = {}
grid.w = 8
grid.h = 8



timer = {}
timer.timers = {}
timer.new = function(n) 
    timer.timers[n] = {
        v = 0,
        s = 1,
        p = false
    }
end
timer._update = function()
    for k,v in pairs(timer.timers) do
        -- check if paused
        if (not v.p) then
            v.v += v.s
        end
    end
end
timer.get = function(n)
    if (not timer.timers[n]) then
        timer.new(n)
    end
    return timer.timers[n].v
end
timer.pause = function(n)
    if (timer.timers[n]) then
        timer.timers[n].p = true
    else
        printh('pause timer error - not found')
    end
end
timer.resume = function(n)
    if (timer.timers[n]) then
        timer.timers[n].p = false
    else
        printh('resume timer error - not found')
    end
end
timer.toggle = function(n)
    if (timer.timers[n]) then
        if timer.timers[n].p == false then
            timer.timers[n].p = true
        else
            timer.timers[n].p = false
        end
    else
        printh('toggle timer error - not found')
    end
end
timer.reset = function(n)
    timer.new(n)
end
timer.remove = function(n)
    if (timer.timers[n]) then
        timer.timers[n] = nil
    else
        printh('remove timer error - not found')
    end
end


-- camera attributes

cam = {
    x = 0,
    y = 0,
    w = 128,
    h = 128,
}
-- position of camera
cam.rel_x = function(x)
    return cam.x + x
end
cam.rel_y = function(y)
    return cam.y + y
end
-- position of camera from center
cam.rel_cy = function(x)
    return ceil(cam.w/2) + cam.x + x
end
cam.rel_cy = function(y)
    return ceil(cam.h/2) + cam.y + y
end

area = {
    x = 0,
    y = 7,
    w = 128,
    h = 121,
}
area.cx = function()
    return ceil(area.w/2) + ceil(area.x/2)
end
area.cy = function()
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
        l = 200, -- length of level (time)
        t = {
            -- t = trigger time, tp = type, y = entry coordinate
            {t=100, tp="a", y=40},
            {t=100, tp="b", y=49},
            {t=100, tp="b", y=60},
            {t=120, tp="a", y=60},
            {t=130, tp="b", y=50},
            {t=140, tp="b", y=40},
            {t=200, tp="a", y=100},
            {t=200, tp="a", y=20},
            {t=250, tp="b", y=40},
            {t=270, tp="b", y=40},
            {t=270, tp="a", y=70},
            {t=300, tp="a", y=40},
        },
        e = {
            {
                -- t = trigger time, tp = type, n = number to generate, lt = lifetime (how long to exist)
                t = 20, tp = "a", n = 10, lt = 75,
                psx = 0, -- path start position relative to tx
                psy = 0, -- path start position relative to top of level
                pex = 128, -- path end position relative to tx
                pey = 128, -- path end position relative to top of level
                p1x = 0, -- path bezier point 1 relative to tx
                p1y = 128, -- path bezier point 1 relative top of level
                p2x = 128, -- path bezier point 1 relative to tx
                p2y = 0, -- path bezier point 1 relative top of level
            },
            {
                t = 40, tp = "a", n = 5, lt = 100,
                psx = 0, psy = 128,  pex = 0,  pey = 0, p1x = 128, p1y = 0, p2x = 128, p2y = 128,
            },
            {
                t = 80, tp = "a", n = 5, lt = 100,
                psx = 0, psy = 128,  pex = 0,  pey = 0, p1x = 128, p1y = 0, p2x = 128, p2y = 128,
            },
            {
                t = 120, tp = "a", n = 5, lt = 100,
                psx = 0, psy = 128,  pex = 0,  pey = 0, p1x = 128, p1y = 0, p2x = 128, p2y = 128,
            },
        }
    },
}

-- ===========
-- Helpers
-- ===========
#include helpers/general.p8
#include helpers/collision.p8
#include helpers/curves.p8
#include helpers/transitions.p8

-- ===========
-- Controllers
-- ===========
#include controllers/enemies.p8
#include controllers/ship.p8
#include controllers/tiles.p8
#include controllers/shots.p8
#include controllers/explosions.p8
#include controllers/player.p8
#include controllers/boss.p8

-- ===========
-- Scenes
-- ===========
#include scenes/title.p8
#include scenes/help.p8
#include scenes/shipselect.p8
#include scenes/game.p8
#include scenes/end.p8
#include scenes/levelselect.p8

-- ===========
-- scene management
-- ===========

function _update()
    tick += 1
    timer._update()
    if (scene_current._update) then scene_current._update() end
end

function _draw()
    frame += 1
    if (scene_current._draw) then scene_current._draw() end
end

function switchScene(newScene, data)
    printh('switching to ' .. newScene)
    found = scenes[newScene]
    if (found == nil) then
        printh('controller not found')
        return
    end
    if (found) then newScene = found end
    if (scene_current._blur) then
        printh('controller blur')
        scene_current._blur()
    end
    scene_current = newScene
    if (scene_current._init and scene_current.init == nil) then
        printh('controller init')
        scene_current.init = true
        scene_current._init(data)
    end
    if (scene_current._focus) then
        printh('controller focus')
        scene_current._focus(data)
    end
end

function _init()
    printh('_init')
    switchScene("title")
    c_player._init()
    c_ship._init()
    c_shots._init()
    c_tiles._init()
    c_explosions._init()
    c_enemies._init()
    c_boss._init()
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
000ee000000ff000000ee00000077000000ee000000ff000000bb00000033000000ee00000088000000bb00000033000000ee000000ff000000bb00000033000
00eeee0000eeee0000eeee000077770000eeee0000ffff0000bbbb000033330000eeee000088880000bbbb000033330000eeee0000ffff0000bbbb0000333300
0eeeeee00eeeeee00eeeeee0077777700eeeeee00ffffff00bbbbbb0033333300eeeeee0088888800bbbbbb0033333300eeeeee00ffffff00bbbbbb003333330
eeeeeeeefeeeeeefeeeeeeee77777777eeeeeeeeffffffffbbbbbbbb33333333eeeeeeee88888888bbbbbbbb33333333eeeeeeeeffffffffbbbbbbbb33333333
eeeeeeeefeeeeeefeeeeeeee77777777eeeeeeeeffffffffbbbbbbbb33333333eeeeeeee88888888bbbbbbbb33333333eeeeeeeeffffffffbbbbbbbb33333333
0eeeeee00eeeeee00eeeeee0077777700eeeeee00ffffff00bbbbbb0033333300eeeeee0088888800bbbbbb0033333300eeeeee00ffffff00bbbbbb003333330
00eeee0000eeee0000eeee000077770000eeee0000ffff0000bbbb000033330000eeee000088880000bbbb000033330000eeee0000ffff0000bbbb0000333300
000ee000000ff000000ee00000077000000ee000000ff000000bb00000033000000ee00000088000000bb00000033000000ee000000ff000000bb00000033000
00088000000ee000000ff000000bb00000033000000ee000000ff000000bb00000033000000ee000000ff000000bb00000033000000ee000000ff000000bb000
0088880000eeee0000ffff0000bbbb000033330000eeee0000ffff0000bbbb000033330000eeee0000ffff0000bbbb000033330000eeee0000ffff0000bbbb00
088888800eeeeee00ffffff00bbbbbb0033333300eeeeee00ffffff00bbbbbb0033333300eeeeee00ffffff00bbbbbb0033333300eeeeee00ffffff00bbbbbb0
88888888eeeeeeeeffffffffbbbbbbbb33333333eeeeeeeeffffffffbbbbbbbb33333333eeeeeeeeffffffffbbbbbbbb33333333eeeeeeeeffffffffbbbbbbbb
88888888eeeeeeeeffffffffbbbbbbbb33333333eeeeeeeeffffffffbbbbbbbb33333333eeeeeeeeffffffffbbbbbbbb33333333eeeeeeeeffffffffbbbbbbbb
088888800eeeeee00ffffff00bbbbbb0033333300eeeeee00ffffff00bbbbbb0033333300eeeeee00ffffff00bbbbbb0033333300eeeeee00ffffff00bbbbbb0
0088880000eeee0000ffff0000bbbb000033330000eeee0000ffff0000bbbb000033330000eeee0000ffff0000bbbb000033330000eeee0000ffff0000bbbb00
00088000000ee000000ff000000bb00000033000000ee000000ff000000bb00000033000000ee000000ff000000bb00000033000000ee000000ff000000bb000
400000bbbbbbbbbb400000bbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000bbbbbbbbbbb00000bbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000bbbbbbbbbbb00000bbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000bbbbbbbbbbbb0000bbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000bbbbbbbbbbbb0000bbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bbbbbbbbbbbbb000bbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bbbbbbbbbbbbb000bbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00bbbbbbbbbbbbbb00bbbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33bbbbbbbbbbbbbb33bbbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33bbbbbbbbbbbbb033bbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33bbbbbbbbbbbb0033bbbbbbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00bbbbbbbbbbbb0000bbbbbbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bbbbbbbbbbb00000bbbbbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bbbbbbbbbbb00000bbbbbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000bbbbbbbbbb000000bbbbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000bbbbbbbbbb000000bbbbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000bbbbbbbbbb000000bbbbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000bbbbbbbbbb000000bbbbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bbbbbbbbbbb00000bbbbbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bbbbbbbbbbb00000bbbbbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00bbbbbbbbbbbb0000bbbbbbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33bbbbbbbbbbbb0033bbbbbbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33bbbbbbbbbbbbb033bbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33bbbbbbbbbbbbbb33bbbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00bbbbbbbbbbbbbb00bbbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bbbbbbbbbbbbb000bbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bbbbbbbbbbbbb000bbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000bbbbbbbbbbbb0000bbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000bbbbbbbbbbbb0000bbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000bbbbbbbbbbb00000bbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000bbbbbbbbbbb00000bbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
400000bbbbbbbbbb400000bbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00100000196402265028660216601b67018670106700e6700b660086500365000640006300c63000630096200962007620056100560002600026000d700117001670031700000000000000000000000000000000
001000003475018700007002870023700207001f7001e7002f7001f7001e7001d7001b7001d70015700217002170016700167001670016700167001670018700187001b7001d7001c7001c700000000000000000
001000001c64006630036100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 00414344
00 01424344
02 01020304
02 01024344

