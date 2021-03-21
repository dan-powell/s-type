pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- ===========
-- Curve Easing Helpers
-- ===========

-- Calculate a bezier curve
-- Should be called once for X, and again for Y
-- l: length of time (frames)
-- s: Start value
-- e: End value
-- p1: Bezier point 1
function bezier(l,s,e,p1)
    local t = frame%l
    t = t/l*100
    t = t/100
    return (1-t)*((1-t)*s + t*p1) + t*((1-t)*p1 + t*e)
end

-- Calculate a quadratic bezier curve
-- Should be called once for X, and again for Y
-- l: length of time (frames)
-- o: offset
-- s: Start value
-- e: End value
-- p1: Bezier point 1
-- p2: Bezier point 2
function bezier_quad(l,o,s,e,p1,p2)
    local t = (frame-o)%l
    t = t/l*100
    t = t/100
    return (1-t)*(1-t)*(1-t)*s + 3*(1-t)*(1-t)*t*p1 + 3*(1-t)*t*t*p2 + t*t*t*e
end

-- calculate a value between s & e using easing
-- t: current time
-- l: length of time of one complete cycle
-- s: start value
-- e: end value
function up_down(t,l,s,e)

    -- math
    local ct = t%l
    local ct2 = (ct/l*200)/100
    local ct3 = ct2 % 1
    local ct4 = abs(ct2 - ct3 * 2)

    -- distance
    local d = e - s

    --easing
    return easeInOutQuad(ct4) * d + s

end

-- cubic easing
function easeInOutCubic(t)
    if t<.5 then
        return 4*t*t*t
    else
        return (t-1)*(2*t-2)*(2*t-2)+1
    end
end

-- quadratic easing
function easeInQuad(t)
    return t*t
end

-- accelerating from zero velocity
function easeOutQuad(t)
    return t*(2-t)
end

-- acceleration until halfway, then deceleration
function easeInOutQuad(t)
    if t<.5 then
        return 2*t*t
    else
        return -1+(4-2*t)*t
    end
end

-- accelerating from zero velocity
function easeInCubic(t)
    return t*t*t
end

-- decelerating to zero velocity
function easeOutCubic(t)
    return (1-t-t)*t*t+1
end

-- acceleration until halfway, then deceleration
function easeInOutCubic(t)
    if t<.5 then
        return 4*t*t*t
    else
        return (t-1)*(2*t-2)*(2*t-2)+1
    end
end

-- accelerating from zero velocity
function easeInQuart(t)
    return t*t*t*t
end

-- decelerating to zero velocity
function easeOutQuart(t)
    return 1-(1-t-t)*t*t*t
end

-- acceleration until halfway, then deceleration
function easeInOutQuart(t)
    if t<.5 then
        return 8*t*t*t*t
    else
        return 1-8*(1-t-t)*t*t*t
    end
end

-- accelerating from zero velocity
function easeInQuint(t)
    return t*t*t*t*t
end

-- decelerating to zero velocity
function easeOutQuint(t)
    return 1+(1-t-t)*t*t*t*t
end

-- acceleration until halfway, then deceleration
function easeInOutQuint(t)
    if t<.5 then
        return 16*t*t*t*t*t
    else
        return 1+16*(1-t-t)*t*t*t*t
    end
end