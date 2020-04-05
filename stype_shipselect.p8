pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
c_ship = {}
c_ship._init = function()
    c_ship.ships = config.ships
    c_ship.selected = 1
end
c_ship._update = function()

    if btnp(5) then
        switchController("game", c_ship.ships[c_ship.selected + 1])
    end

    if btnp(2) then
        c_ship.selected = c_ship.prev_ship()
        printh("up")
        printh(c_ship.selected)
    end

    if btnp(3) then
        c_ship.selected = c_ship.next_ship()
        printh("down")
        printh(c_ship.selected)
    end

end
c_ship._draw = function()
    cls(0)
    camera(0,0)

    print("choose your ship", 64-14*2, 20, 2)

    local i = 0
    
    -- display each of the ship types
    for s in all(c_ship.ships) do
        local y = i * 30 + 40
        spr(s.sp[frame%(count(s.sp))+1], 30, y) -- sprite
        print(s.n, 40, y + 2, 12) -- name
        print(s.d, 40, y + 10, 1) -- description
        if c_ship.selected == i then
            spr(10, 20, y)
        end
        i += 1
    end

end
c_ship.next_ship = function()
    local i = c_ship.selected + 1
    return min(i, #c_ship.ships - 1)
end
c_ship.prev_ship = function()
    local i = c_ship.selected - 1
    return max(i, 0)
end
controllers["shipselect"] = c_ship