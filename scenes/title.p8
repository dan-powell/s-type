pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
s_title = {}
-- ===========
-- core
-- ===========
s_title._focus = function()

    music(0)

    s_title.state = 0

    -- reset lvl select input table
    s_title.lvlselect_input = {-1,-1,-1,-1,-1,-1}

    -- reset some tables
    s_title.starfield = {}
    s_title.lines = {}

    -- prepopulate starfield
    for i=1,60 do
        s_title.create_star(rnd(128))
    end

    s_title.s = {
        s = 128,
        x = -32,
        y = 16,
        w = 2,
        h = 4,
        xd = 24,
        xs = -32
    }

    s_title.type = {
        s = 130,
        x = 160,
        y = 16,
        w = 8,
        h = 4,
        xd = 40,
        xs = 160
    }
end
s_title._update = function()

    if s_title.state == 0 then

        -- record keypresses for lvl select
        if btnp(0) then
            del(s_title.lvlselect_input, s_title.lvlselect_input[1])
            add(s_title.lvlselect_input, 0)
        end
        if btnp(1) then
            del(s_title.lvlselect_input, s_title.lvlselect_input[1])
            add(s_title.lvlselect_input, 1)
        end

        -- test for correct lselect input pattern
        local test_for_lselect = true
        for k, v in pairs(s_title.lvlselect_input) do
            if v != lvlselect[k] then
                test_for_lselect = false
            end
        end
        if test_for_lselect then
            switchScene("levelselect")
        end

        -- start the game
        if btnp(5) then
            sfx(2)
            s_title.t = transition_fizzle(1)
            s_title.state = 1
        end

        -- show the help screen
        if btnp(4) then
            sfx(2)
            switchScene("help")
        end

    end

    if s_title.state == 1 then
        if(timer.get("outro") < 40) then

        else
            timer.remove("outro")
            switchScene("shipselect")
        end
    end

    -- create new star
    s_title.create_star(0)

    -- animate title
    if s_title.s.x < s_title.s.xd then
        -- s_title.s.x = ceil(s_title.s.x + 1)
        s_title.s.x += (s_title.s.xd - s_title.s.xs) / 40
    end
    if s_title.type.x > s_title.type.xd then
        -- s_title.type.x = ceil(s_title.type.x - 2)
        s_title.type.x += (s_title.type.xd - s_title.type.xs) / 40
    end
end
s_title._draw = function()
    if s_title.state == 0 then
        cls(0)
        foreach(s_title.starfield, s_title.draw_starfield)
        spr(s_title.s.s, s_title.s.x, s_title.s.y, s_title.s.w, s_title.s.h)
        spr(s_title.type.s, s_title.type.x, s_title.type.y, s_title.type.w, s_title.type.h)

        if s_title.type.x == s_title.type.xd and flash2 == nil then
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
    
    if s_title.t then
        for i=0,510 do
            s_title.t.draw()
            s_title.t.step()
        end
    end

end
-- ===========
-- private methods
-- ===========
s_title.create_star = function(y)
    local s = {}
    s.x = rnd(128)
    s.y = y
    s.c = 7
    s.vy = rnd(1) * 3
    col = {1,5,6,13} -- colour pool
    s.c = col[ceil(rnd(count(col)))] -- pick a colour
    add(s_title.starfield, s)
end
s_title.draw_starfield = function(s)
    s.y += s.vy
    pset(s.x, s.y, s.c)
    if s.y > 128 then
        del(s_title.starfield, s)
    end
end

scenes["title"] = s_title
