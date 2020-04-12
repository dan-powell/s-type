pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
s_ship = {}
s_ship._init = function()
  	s_ship.ships = c_ship.ships
    s_ship.selected = 0
end
s_ship._update = function()

    if btnp(5) then
        c_ship.select(s_ship.selected + 1)
        switchScene("game")
    end

    if btnp(2) then
        s_ship.selected = s_ship.prev_ship()
        printh("up")
        printh(s_ship.selected)
    end

    if btnp(3) then
        s_ship.selected = s_ship.next_ship()
        printh("down")
        printh(s_ship.selected)
    end

end
s_ship._draw = function()
    cls(0)
    camera(0,0)

    print("choose your ship", 64-14*2, 20, 2)

    local i = 0

    -- display each of the ship types
    for s in all(s_ship.ships) do
        local y = i * 30 + 40
        spr(s.sp[frame%(count(s.sp))+1], 30, y) -- sprite
        print(s.n, 40, y + 2, 12) -- name
        print(s.d, 40, y + 10, 1) -- description
        if s_ship.selected == i then
            spr(10, 20, y)
        end
        i += 1
    end

end
-- ===========
-- private methods
-- ===========
s_ship.next_ship = function()
    local i = s_ship.selected + 1
    return min(i, #s_ship.ships - 1)
end
s_ship.prev_ship = function()
    local i = s_ship.selected - 1
    return max(i, 0)
end
scenes["shipselect"] = s_ship
