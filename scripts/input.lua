input = {
    mouse = {
        cursor = 0,
        pos = vec(0),
        buttons = {
            left = false,
            middle = false,
            right = false,
            
            last_left = false,
            last_middle = false,
            last_right = false
        }
    },
    
    keys = {
        pressed = { },
        released = { }
    }
}

function input.mouse.is_click(button)
    return input.mouse.buttons[button] 
        and not input.mouse.buttons["last_" .. button]
end

function input.mouse.is_upclick(button)
    return not input.mouse.buttons[button] 
        and input.mouse.buttons["last_" .. button]
end

function input.mouse.pump()
    local mouse = input.mouse

    for button, value in pairs(mouse.buttons) do
        if type(mouse.buttons["last_" .. button]) ~= "nil"  then
            mouse.buttons["last_" .. button] = mouse.buttons[button]
        end
    end
end

function input.keys.is_press(key)
    return input.keys.pressed[tostring(key)]
end

function input.keys.is_release(key)
    return input.keys.released[tostring(key)]
end

function input.keys.pump()
    input.keys.pressed = { }
    input.keys.released = { }
end