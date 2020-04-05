pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
controller_title = {}
controller_title.update = function()
    if btnp(0) then
        del(lvlselect_input, lvlselect_input[1])
        add(lvlselect_input, 0)
    end
    if btnp(1) then
        del(lvlselect_input, lvlselect_input[1])
        add(lvlselect_input, 1)
    end
    local test = true
    for k, v in pairs(lvlselect_input) do
        if v != lvlselect[k] then
            test = false
        end
    end
    if test then
        init_lvlselect()
    end
    if btnp(5) then
        switchController("controller_game")
    end
    controller_title.create_star(0)
    if s.x < s.xd then 
        s.x = ceil(s.x + 1)
    end
    if logotype.x > logotype.xd then 
        logotype.x = ceil(logotype.x - 2)
    end

end
controller_title.draw = function()
    cls(0)
    foreach(starfield, controller_title.draw_starfield)

    spr(s.s, s.x, s.y, s.w, s.h)
    spr(logotype.s, logotype.x, logotype.y, logotype.w, logotype.h)

    if(not flash) flash=0
    if(frame%(30/2)==0) then
        flash += 1
    end

    if logotype.x == logotype.xd + 2 then 
        cls(7)
    end

    if flash%2 == 1 then
        print("press ❎ to start", 30, 64, 9)
    end

    print(version, 3, 120, 2)
end
controller_title.focus = function()
    state = 0
    -- 0 start screen
    -- 1 game
    -- 2 score screen
    -- music(01)
    lvlselect_input = {-1,-1,-1,-1,-1,-1}
    
    starfield = {}
    -- prepopulate starfield
    for i=1,60 do
        controller_title.create_star(rnd(128))
    end

    s = {
        s = 128,
        x = -32,
        y = 16,
        w = 2,
        h = 4,
        xd = 24
    }

    logotype = {
        s = 130,
        x = 160,
        y = 16,
        w = 8,
        h = 4,
        xd = 40
    }
end
controller_title.create_star = function(y)
    local s = {}
    s.x = rnd(128)
    s.y = y
    s.c = 7
    s.vy = rnd(1) * 3
    col = {1,5,6,13} -- colour pool
    s.c = col[ceil(rnd(count(col)))] -- pick a colour
    add(starfield, s)
end
controller_title.draw_starfield = function(s)
    s.y += s.vy
    pset(s.x, s.y, s.c)
    if s.y > 128 then
        del(starfield, s)
    end
end

controllers["controller_title"] = controller_title