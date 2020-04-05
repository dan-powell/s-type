pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
c_end = {}
c_end._init = function(player)
    c_end.player = player
end
c_end._update = function()
    if btnp(5) then
        switchController("title")
    end
end
c_end._draw = function()
    if c_end.player.lives > 0 then
        cls(3)
        print("good jorb", 48, 24, 11)
    else
        cls(2)
        print("try again next time", 24, 24, 11)
    end
    camera(0,0)
    spr(76, 96, 96, 4, 4) -- bork

    print("score: " .. c_end.player.score, 48, 32, 7)
    print("levels: " .. c_end.player.lvl, 48, 48, 7)
    print("bricks: " .. c_end.player.bricks, 48, 56, 7)
    print("bounces: " .. c_end.player.bounces, 48, 64, 7)
    print("lives left: " .. c_end.player.lives, 48, 72, 7)
    print("❎ to try again", 24, 96, 9)
end
controllers["end"] = c_end