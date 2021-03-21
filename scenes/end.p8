pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
s_end = {}
-- ===========
-- core
-- ===========
s_end._init = function()
    s_end.player = player
end
s_end._focus = function(player)
    s_end.player = player
end
s_end._update = function()
    if btnp(5) then
        switchScene("title")
    end
end
s_end._draw = function()
    if s_end.player.lives > 0 then
        cls(3)
        print("good jorb", 48, 24, 11)
    else
        cls(2)
        print("try again next time", 24, 24, 11)
    end
    camera(0,0)
    spr(76, 96, 96, 4, 4) -- bork

    print("score: " .. s_end.player.score, 48, 32, 7)
    print("levels: " .. s_end.player.lvl, 48, 48, 7)
    print("bricks: " .. s_end.player.bricks, 48, 56, 7)
    print("bounces: " .. s_end.player.bounces, 48, 64, 7)
    print("lives left: " .. s_end.player.lives, 48, 72, 7)
    print("❎ to try again", 24, 96, 9)
end
scenes["end"] = s_end
