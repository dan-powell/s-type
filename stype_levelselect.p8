pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
c_lselect = {}
c_lselect._update = function()
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
c_lselect._draw = function()
    cls(0)
    print("level select", 48, 32, 7)
    print(select, 48, 48, 7)
end
controllers["levelselect"] = c_lselect