function debug(a, b, c, msg)
    print(a.n, b.n, c.n, orient_tri(a, b, c), msg)
end

function table.score(t, scorer)
    if not scorer then
        scorer = function(a) return a end
    end

    local best_key = nil
    local best_score = nil

    for key, val in pairs(t) do
        local score = scorer(val)
        
        if best_score == nil or score > best_score then    
            best_key = key
            best_score = score
        end
    end
    
    return best_key, best_score
end

function orient_poly(v)
    local n = table.getn(v)

    local area = v[n].x * v[1].y - v[1].x * v[n].y;

    for i = 1, n - 1 do
        area = v[i].x * v[i + 1].y - v[i + 1].x * v[i].y
    end
    
    if area > 0 then
        return "ccw"
    end
    
    return "cw"
end

function orient_tri(a, b, c)
    if (b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y) > 0 then
        return "ccw"
    end
    
    return "cw"
end

local function leftmost(t)
    return table.score(t, function(point) return -point.x end)
end

local function same_side(p1, p2, l1, l2)
    return  ((p1.x - l1.x) * (l2.y - l1.y) - (l2.x - l1.x) * (p1.y - l1.y)) *
            ((p2.x - l1.x) * (l2.y - l1.y) - (l2.x - l1.x) * (p2.y - l1.y)) > 0
end

local function in_triangle(p, a, b, c)
    return same_side(p, a, b, c) and same_side(p, b, a, c) and same_side(p, c, a, b)
end

local function edges(a, b, c)
    debug(a, b, c, "edges")
    local key = table.contains(vertices, b)
    local prev, next = get_keys(key)
    local edges = 0

    if vertices[prev] == a then
        print("has prev")
        edges = edges + 1
    end
    
    if vertices[next] == c then
        print("has next")
        edges = edges - 2
    end
    
    if edges == -1 then
        return 2
    end

    return edges
end

local function sub_triangle(a, b, c)
    local n = table.getn(vertices)

    if dir ~= orient_tri(a, b, c) then
        a, c = c, a
        debug(a, b, c, "reorder")
    end
    
    debug(a, b, c, "subtract")
    
    local tris = { 
                    { a, b, c }, 
                    { b, c, a }, 
                    { c, a, b } 
                 }
    
    local edge = {
                    edges(unpack(tris[1])), 
                    edges(unpack(tris[2])), 
                    edges(unpack(tris[3])) 
                 }
                    
    local key, score = table.score(edge)
    print("best key", key, score)
    
    debug(tris[key][1], tris[key][2], tris[key][3], "new triangle")
    
    if score == 2 then
        table.remove(vertices, table.contains(vertices, tris[key][2]))
    elseif score == 1 then
        table.insert(vertices, table.contains(vertices, tris[key][2]), tris[key][3])
    else
        table.insert(vertices, table.contains(vertices, tris[key][2]), tris[key][1])
    end
end

local function test_triangle(a, b, c)
    local topleft = vec(math.min(a.x, b.x, c.x),
                        math.min(a.y, b.y, c.y))
    local botright= vec(math.max(a.x, b.x, c.x),
                        math.max(a.y, b.y, c.y))
    
    local bounds = rect.create(topleft, botright - topleft)
    --table.insert(rects, bounds)
    local isfine = true
    
    local contents = { }
    for key, point in pairs(vertices) do
        if bounds.contains(point) and in_triangle(point, a, b, c) then
            debug(a, b, c, "has point " .. point.n)
            table.insert(contents, point)
        end
    end
    
    if #contents == 0 then
        return nil
    end
    
    return contents[leftmost(contents)]
end

function get_keys(key)
    local next = key + 1
    local prev = key - 1
    
    if prev == 0 then
        prev = #vertices
    end
    
    if next == #vertices + 1 then
        next = 1
    end

    return prev, next
end


function get_triangles()
    print()

    local key = leftmost(vertices)
    local prev, next = get_keys(key)
    
    decompose(key, vertices[key], vertices[next], vertices[prev])
end

function decompose(key, a, b, c)
    local d = test_triangle(a, b, c)
    debug(a, b, c, "decomposing")
    
    if d then
        print("d is ", d.n)
    end
    
    if not d then
        debug(a, b, c, "ok")
    
        table.insert(triangles, {a, b, c})
        
        sub_triangle(a, b, c)
    else
        debug(a, b, c, "not ok")
        decompose(key, a, b, d)
    end
end


dir = false
local logic = function()
    if engine.mouse.is_click("left") then
        table.insert(vertices, vec(engine.mouse.pos))
        vertices[#vertices].n = string.sub("abcdefghijklmnopqrstuvwxyz", #vertices, #vertices)
        dir = orient_poly(vertices)
    end
    
    if engine.mouse.is_click("right") then
        vertices[#vertices] = nil
    end
    
    if engine.keys.is_press("space") then
        --triangles = { }
        get_triangles()
    end
    
    if engine.keys.is_press("n") then
        triangles = { }
        init()
    end

    engine.mouse.pump()
    engine.keys.pump()
end

function list()
    return table.map(vertices, function(v) return v.n end)
end

function init()
    vertices = { }

    local mid = vec(screen_width, screen_height) * 0.5
    local n = 10

    for i = 0, n - 1 do
        local x = math.cos((-90 + 360 / n * i) * 3.14159 / 180)
        local y = math.sin((-90 + 360 / n * i) * 3.14159 / 180)
        local p = vec(x, y)
        
        if i % 2 == 0 then
            p = p * 100
        else
            p = p * 50
        end
        
        table.insert(vertices, mid + p)
        vertices[#vertices].n = string.sub("abcdefghijklmnopqrstuvwxyz", #vertices, #vertices)
    end
    
    --vertices = table.load("path.dat")
    
    dir = orient_poly(vertices)
    print("poly is", dir)
    
    --[[get_triangles()
    get_triangles()
    get_triangles()
    get_triangles()]]
end

init()

events.game.tick.sub(logic)