pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
c_help = {}
c_help._update = function()
    if btnp(5) then
        switchController("title")
    end
end
c_help._draw = function()
    camera(0,0)
    print("how to play", 48, 32, 7)
end
controllers["help"] = c_help