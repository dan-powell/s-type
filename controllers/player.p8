pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
c_player = {}
c_player.lives = 0
c_player.score = 0

c_player._init = function()
    c_player.new()
end

c_player._update = function()

end

c_player.reset = function()
    c_player.new()
end

c_player.new = function()
    c_player.lives = 6
    c_player.score = 10
end

c_player.lives_get = function()
    return c_player.lives
end

c_player.lives_lose = function()
    c_player.lives -= 1
end

c_player.score_get = function()
    return c_player.score
end

c_player.score_add = function(n)
    c_player.score += n
end
