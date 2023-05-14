function Button()
    
    local button = {}
    
    button.label = "Button"
    button.posX = nil
    button.posY = nil
    button.width = 3
    button.height = 1
    button.colorNormal = colors.blue
    button.colorPressed = colors.red
    button.textColorNormal = colors.white
    button.textColorPressed = colors.yellow
    button.isPressed = false
    button.justDrawn = true
    button.func = function ()
        print("No function set yet")
    end
    button.active = true
    
    --getter method
    function button.get(property)
        if property == "label" then
            return button.label
        elseif property == "posX" then
            return button.posX
        elseif property == "posY" then
            return button.posY
        elseif property == "width" then
            return button.width
        elseif property == "height" then
            return button.height
        elseif property == "colorNormal" then
            return button.colorNormal
        elseif property == "colorPressed" then
            return button.colorPressed
        elseif property == "textColorNormal" then
            return button.textColorNormal
        elseif property == "textColorPressed" then
            return button.textColorPressed
        elseif property == "isPressed" then
            return button.isPressed
        elseif property == "justDrawn" then
            return button.justDrawn
        elseif property == "func" then
            return button.func
        elseif property == "active" then
            return button.active
        else
            return "That is not a valid property"
        end
    end

    --setter methods
    function button.set(property, value)
        if property == "label" then
            button.label = value
        elseif property == "posX" then
            button.posX = value
        elseif property == "posY" then
            button.posY = value
        elseif property == "width" then
            button.width = value
        elseif property == "height" then
            button.height = value
        elseif property == "colorNormal" then
            button.colorNormal = value
        elseif property == "colorPressed" then
            button.colorPressed = value
        elseif property == "textColorNormal" then
            button.textColorNormal = value
        elseif property == "textColorPressed" then
            button.textColorPressed = value
        elseif property == "isPressed" then
            button.isPressed = value
        elseif property == "justDrawn" then
            button.justDrawn = value
        elseif property == "func" then
            button.func = value
        elseif property == "active" then
            button.active = value
        else
            return "That is not a valid property"
        end
    end
    
    --changes the state of the button when pressed
    function button.pressed()
        button.isPressed = not button.isPressed
    end
    
    --checks if the button was clicked or not
    function button.clicked(column, row)
        return (column >= button.posX and column < button.posX + button.width and row >= button.posY and row < button.posY + button.height)
    end
    
    --draws the button
    function button.draw(mon)
    --gets the screen size
        local x, y = mon.getSize()
        
        --if no x position specified
        if button.width < #button.label then
            button.width = #button.label
        end

        if button.justDrawn then
            if not button.posX then
                button.posX = math.ceil(x/2) - math.floor(button.width/2)
            else
                button.posX = button.posX - math.floor(button.width/2)
            end
        
            --if no y position specified
            if not button.posY then
                button.posY = math.ceil(y/2)
            end
            
            button.justDrawn = false
        end
        
        --checks if the button has been pressed or not
        if button.isPressed then
            mon.setBackgroundColor(button.colorPressed)
            mon.setTextColor(button.textColorPressed)
        else
            mon.setBackgroundColor(button.colorNormal)
            mon.setTextColor(button.textColorNormal)
        end
        
        --Draw Background
        for i=0, button.height-1, 1 do
            mon.setCursorPos(button.posX, button.posY+i)
            mon.write(string.rep(" ", button.width))
        end
        
        --Draw the Label
        mon.setCursorPos(button.posX+math.ceil((button.width-#button.label)/2), button.posY+math.ceil(button.height/2)-1)
        mon.write(button.label)
    end
    
    --toggles the button on then off again
    function button.toggle(mon)
        button.pressed()
        button.draw(mon)
        sleep(0.2)
        button.pressed()
        button.draw(mon)
    end
    
    return button
end
