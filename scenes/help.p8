pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
s_help = {}
-- ===========
-- core
-- ===========
s_help._update = function()
    if btnp(5) then
        switchScene("title")
    end
end
s_help._draw = function()
    camera(0,0)
    print("how to play", 48, 32, 7)
end
scenes["help"] = s_help
