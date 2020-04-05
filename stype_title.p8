pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
c_title = {}
-- ====================================
-- focus
-- ====================================
c_title._focus = function()

    -- reset lvl select input table
    c_title.lvlselect_input = {-1,-1,-1,-1,-1,-1}

    -- reset the starfield
    c_title.starfield = {}
    
    -- prepopulate starfield
    for i=1,60 do
        c_title.create_star(rnd(128))
    end


    c_title.s = {
        s = 128,
        x = -32,
        y = 16,
        w = 2,
        h = 4,
        xd = 24,
        xs = -32
    }

    c_title.type = {
        s = 130,
        x = 160,
        y = 16,
        w = 8,
        h = 4,
        xd = 40,
        xs = 160
    }
end
-- ====================================
-- update
-- ====================================
c_title._update = function()

    -- record keypresses for lvl select
    if btnp(0) then
        del(c_title.lvlselect_input, c_title.lvlselect_input[1])
        add(c_title.lvlselect_input, 0)
    end
    if btnp(1) then
        del(c_title.lvlselect_input, c_title.lvlselect_input[1])
        add(c_title.lvlselect_input, 1)
    end

    -- test for correct lselect input pattern
    local test_for_lselect = true
    for k, v in pairs(c_title.lvlselect_input) do
        if v != lvlselect[k] then
            test_for_lselect = false
        end
    end
    if test_for_lselect then
        switchController("levelselect")
    end

    -- start the game
    if btnp(5) then
        switchController("shipselect")
    end

    -- show the help screen
    if btnp(4) then
        switchController("help")
    end

    -- create new star
    c_title.create_star(0)

    -- animate title
    if c_title.s.x < c_title.s.xd then 
        -- c_title.s.x = ceil(c_title.s.x + 1)
        c_title.s.x += (c_title.s.xd - c_title.s.xs) / 40
    end
    if c_title.type.x > c_title.type.xd then 
        -- c_title.type.x = ceil(c_title.type.x - 2)
        c_title.type.x += (c_title.type.xd - c_title.type.xs) / 40
    end
end
c_title._draw = function()
    cls(0)
    foreach(c_title.starfield, c_title.draw_starfield)
    spr(c_title.s.s, c_title.s.x, c_title.s.y, c_title.s.w, c_title.s.h)
    spr(c_title.type.s, c_title.type.x, c_title.type.y, c_title.type.w, c_title.type.h)

    if c_title.type.x == c_title.type.xd and flash2 == nil then 
        flash2 = true
        cls(7)
    end

    if(not flash) flash=0
    if(frame%(30/2)==0) then
        flash += 1
    end
    local c
    if flash%2 == 1 then
        c = 9
    else
        c = 8
    end
    print("❎ to start", 42, 64, c)
    print("🅾️ for help", 80, 120, 5)
    print(version, 3, 120, 2)
end
c_title.create_star = function(y)
    local s = {}
    s.x = rnd(128)
    s.y = y
    s.c = 7
    s.vy = rnd(1) * 3
    col = {1,5,6,13} -- colour pool
    s.c = col[ceil(rnd(count(col)))] -- pick a colour
    add(c_title.starfield, s)
end
c_title.draw_starfield = function(s)
    s.y += s.vy
    pset(s.x, s.y, s.c)
    if s.y > 128 then
        del(c_title.starfield, s)
    end
end
controllers["title"] = c_title