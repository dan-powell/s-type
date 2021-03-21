pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- fizzlefade
-- https://www.lexaloffle.com/bbs/?tid=29862
--
-- algorithm from
-- antirez.com/news/113
function transition_fizzle(c)
    local x = 0
    local y = 0
    local c = c
    local x2 = 0
    local y2 = 0
    local f = {}
    f.step = function()
        -- next pixel
        if x < 127 then
            x += 1
        elseif y < 127 then
            x = 0
            y += 1
        else
            x = 0
            y = 0
        end
  
    -- function for feistel
    -- transform
    --
    -- this is the transform
    -- from antirez's page, but
    -- the final binary and is
    -- 0x7f instead of 0xff to
    -- match pico-8's drawable
    -- range of 0,127
    function f(n)
        n = bxor((n*11)+shr(n,5)+7*127,n)
        n = band(n,0x7f)
        return n
    end

    -- permute with feistel net
    -- use x2 as "left", y2 as
    -- "right"
    x2=x
    y2=y
    for round=1,8 do
        next_x2=y2
        y2=bxor(x2,f(y2))
        x2=next_x2
    end
    -- no need for a final
    -- recomposition step
    -- in our case:
    -- we just use x2 and y2
    -- (l and r) directly
    end
    f.draw = function()
        pset(x2,y2,c)
    end
    return f
end

-- Fade colours
-- https://gist.github.com/smallfx/c46645b7279e7d64ec37
-- "fa" is a number ranging from 0 to 1
-- 1 = 100% faded out
-- 0 = 0% faded out
-- 0.5 = 50% faded out, etc.
function fade_screen(fa)
	fa=max(min(1,fa),0)
	local fn=8
	local pn=15
	local fc=1/fn
	local fi=flr(fa/fc)+1
	local fades={
		{1,1,1,1,0,0,0,0},
		{2,2,2,1,1,0,0,0},
		{3,3,4,5,2,1,1,0},
		{4,4,2,2,1,1,1,0},
		{5,5,2,2,1,1,1,0},
		{6,6,13,5,2,1,1,0},
		{7,7,6,13,5,2,1,0},
		{8,8,9,4,5,2,1,0},
		{9,9,4,5,2,1,1,0},
		{10,15,9,4,5,2,1,0},
		{11,11,3,4,5,2,1,0},
		{12,12,13,5,5,2,1,0},
		{13,13,5,5,2,1,1,0},
		{14,9,9,4,5,2,1,0},
		{15,14,9,4,5,2,1,0}
	}
	for n=1,pn do
		pal(n,fades[n][fi],0)
	end
end