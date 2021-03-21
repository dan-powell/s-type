pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- ===========
-- Global Helpers
-- ===========

-- Get the length of a table
function tablelength(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end