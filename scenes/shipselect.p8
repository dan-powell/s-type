pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
s_ship = {}
s_ship._init = function()
    s_ship.state = 0
  	s_ship.ships = c_ship.ships
    s_ship.selected = 0
end
s_ship._update = function()

    if s_ship.state == 0 then

        if btnp(5) then
            s_ship.ship = c_ship.select(s_ship.selected + 1)
            s_ship.state = 1
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

    if s_ship.state == 1 then
        if(timer.get("selectoutro") < 50) then
            s_ship.ship.x = s_ship.ship.x + 3
        else
            timer.remove("selectoutro")
            switchScene("game")
        end
    end

end
s_ship._draw = function()
    cls(1)
    camera(0,0)

    if s_ship.state == 0 then

        print("choose your ship", 64-14*2, 20, 3)

        local i = 0

        -- display each of the ship types
        for s in all(s_ship.ships) do
            local y = i * 30 + 40
            print(s.n, 40, y + 2, 12) -- name
            print(s.d, 40, y + 10, 3) -- description
            spr(s.sp[frame%(count(s.sp))+1], 30, y) -- sprite
            if s_ship.selected == i then
                spr(10, 20, y)
            end
            i += 1
        end

    end

    if s_ship.state == 1 then
        
        local y = s_ship.selected * 30 + 40
        spr(s_ship.ship.sp[frame%(count(s_ship.ship.sp))+1], s_ship.ship.x + 30, y) -- sprite

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
