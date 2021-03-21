pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
c_boss = {}
c_boss.actor = {}
c_boss.types = {
    a = {
        s={64,66}, -- sprites
        sd=68, -- damage sprite
        w=16, -- width
        h=32, -- height
        sw=2, -- sprite width (in tiles)
        sh=4, -- sprite height (in tiles)
        l=100 -- Life (health)
    },
}
-- --------------------------
-- init
-- --------------------------
c_boss._init = function()
    c_boss.reset()
    printh(c_boss.actor.l)
end

c_boss._update = function()

    c_boss.actor.x = up_down(timer.get('boss_x'), 200, 0, 128 - c_boss.actor.w)
    c_boss.actor.y = up_down(timer.get('boss_y'), 200, 0, 128 - c_boss.actor.h)

    if btnp(4) then
        timer.toggle('boss_y')
    end

    -- damage sprite timer
    if c_boss.actor.s_d > 0 then
        c_boss.actor.s_d -= 1
    end

    -- Check if enemy has collided with shot
    for k,s in pairs(c_shots.actors) do
        if (s.x > c_boss.actor.x and s.x < (c_boss.actor.x + c_boss.actor.w) and s.y > c_boss.actor.y and s.y < (c_boss.actor.y + c_boss.actor.h)) then
            c_boss.damage(s.d)
            c_shots.delete(s)
        end
    end

    -- Check if enemy has collided with ship
    local s = c_ship.get()
    if collision(s, c_boss.actor) then
        c_player.lives_lose()
        c_ship.hide()
        s_game.state = 2
    end

end

c_boss.damage = function(d)
    c_boss.actor.s_d = 5 -- set timer for displaying damage sprite

    -- decriment life
    if not d then
        c_boss.actor.l -= 1
    else
        c_boss.actor.l -= d
    end

    -- check if destroyed
    if c_boss.actor.l <= 0 then
        c_boss.destroy()
    end
end

c_boss.destroy = function()
    s_game.state = 5
end

c_boss._draw = function()
    local t = c_boss.actor

    if(frame%(4)==0) then
        t.s_t += 1
        if(t.s_t > tablelength(t.s)) then
            t.s_t = 1
        end
    end

    if t.s_d > 0 and frame%(2)==0 then
        spr(t.sd, t.x, t.y, t.sw, t.sh)
    else
        spr(t.s[t.s_t], t.x, t.y, t.sw, t.sh)
    end
end

-- --------------------------
-- methods
-- --------------------------
c_boss.reset = function()
    c_boss.actor = c_boss.new("a")
end

c_boss.new = function(t)
    local b = {}

    -- Load up the values from enemy type config
    for k, v in pairs(c_boss.types[t]) do
        b[k] = v
    end

    b.x = 110
    b.y = 20
    b.s_t = 0 -- Sprite timer
    b.s_d = 0 -- Damage timer
    return b
end
