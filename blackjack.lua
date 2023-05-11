--init
os.loadAPI("button.lua")

mon = peripheral.find("monitor")
mon.setBackgroundColor(colors.green)
mon.setTextColor(colors.white)
mon.clear()
local x, y = mon.getSize()

playerHand = {}
dealerHand = {}
deck = {}
buttons = {}

cards = {
    {"A", "\3"}, {"A", "\4"}, {"A", "\5"}, {"A", "\6"},
    {"K", "\3"}, {"K", "\4"}, {"K", "\5"}, {"K", "\6"},
    {"Q", "\3"}, {"Q", "\4"}, {"Q", "\5"}, {"Q", "\6"},
    {"J", "\3"}, {"J", "\4"}, {"J", "\5"}, {"J", "\6"},
    {"10","\3"}, {"10","\4"}, {"10","\5"}, {"10","\6"},
    {"9", "\3"}, {"9", "\4"}, {"9", "\5"}, {"9", "\6"},
    {"8", "\3"}, {"8", "\4"}, {"8", "\5"}, {"8", "\6"},
    {"7", "\3"}, {"7", "\4"}, {"7", "\5"}, {"7", "\6"},
    {"6", "\3"}, {"6", "\4"}, {"6", "\5"}, {"6", "\6"},
    {"5", "\3"}, {"5", "\4"}, {"5", "\5"}, {"5", "\6"},
    {"4", "\3"}, {"4", "\4"}, {"4", "\5"}, {"4", "\6"},
    {"3", "\3"}, {"3", "\4"}, {"3", "\5"}, {"3", "\6"},
    {"2", "\3"}, {"2", "\4"}, {"2", "\5"}, {"2", "\6"}
}

function resetMon()
    mon.setBackgroundColor(colors.green)
    mon.setTextColor(colors.white)
    mon.clear()
end

function center(str)
    
    local posX = math.ceil(x/2)-math.floor(#str/2)
    local posY = math.ceil(y/2)
    
    mon.setCursorPos(posX, posY)
    mon.write(str)
end

function shuffle()
    resetMon()
    center("Shuffling Deck...")
    
    for i, card in pairs(cards) do
        repeat
            pos = math.random(1,52)
        until deck[pos] == nil
        deck[pos] = card
        
        sleep(0)
    end
    
    mon.clear()
    center("Done!")
    sleep(1)
    mon.clear()
end

function quitGame()
    error()
end

function printCard(card, x, y)
    mon.setCursorPos(x, y)
    
    if card[2] == "\3" or card[2] == "\4" then
        mon.setBackgroundColor(colors.white)
        mon.setTextColor(colors.red)
    else
        mon.setBackgroundColor(colors.white)
        mon.setTextColor(colors.black)
    end
    
    if card[1] == "flipped" then
        -- print("drawing flipped card")
        mon.setBackgroundColor(colors.red)
        mon.setTextColor(colors.white)
        
        mon.write("+-+")
        mon.setCursorPos(x, y+1)
        mon.write("|*|")
        mon.setCursorPos(x, y+2)
        mon.write("+-+")
    elseif card[1] == "10" then
        mon.write("10 ")
        mon.setCursorPos(x, y+1)
        mon.write(" " .. card[2] .. " ")
        mon.setCursorPos(x, y+2)
        mon.write(" 10")
    else
        -- print("Printing normal Card")
        mon.write(card[1].."  ")
        mon.setCursorPos(x, y+1)
        mon.write(" "..card[2].." ")
        mon.setCursorPos(x, y+2)
        mon.write("  "..card[1])
    end
end

function redraw()
    mon.setBackgroundColor(colors.green)
    mon.setTextColor(colors.white)
    mon.clear()
    local spacing = x/2 - (#dealerHand*2-2)
    --Draw dealer's Hand
    -- print("Drawing dealer's hand")
    for i=1, #dealerHand, 1 do
        -- print("Printing Dealer's card".. i)
        card = dealerHand[i]
        
        printCard(card, spacing, y*0.3)

        spacing = spacing + 4
    end
    
    --Draw the player's hand
    -- print("Drawing player's hand")
    spacing = x/2 - (#playerHand*2-2)
    for i, card in pairs(playerHand) do
        printCard(card, spacing, y*0.6)

        spacing = spacing + 4
    end

    --Draw Deck
    printCard({"flipped"}, x/2, y*0.45)
end

function dealPlayer()
    -- print("Dealing to player")
    playerHand[#playerHand+1] = deck[#deck]
    deck[#deck] = nil
end

function dealHouse(hide)
    -- print("Dealing to House")
    dealerHand[#dealerHand+1] = deck[#deck]
    if hide then
        -- print("Hiding Card")
        dealerHand[#dealerHand] = {"flipped", deck[#deck]}
    else
        -- print("Showing Card")
    end
    deck[#deck] = nil
end

function drawButtons()
    for i, but in pairs(buttons) do
        but.draw(mon)
    end
end

function getHandValue(hand)
    local handValue = 0;
    local numAces = 0;
    local soft = false;

    for i, v in pairs(hand) do
        if v[1] == "2" then
            handValue = handValue +2
        elseif v[1] == "3" then
            handValue = handValue +3
        elseif v[1] == "4" then
            handValue = handValue +4
        elseif v[1] == "5" then
            handValue = handValue +5
        elseif v[1] == "6" then
            handValue = handValue +6
        elseif v[1] == "7" then
            handValue = handValue +7
        elseif v[1] == "8" then
            handValue = handValue +8
        elseif v[1] == "9" then
            handValue = handValue +9
        elseif v[1] == "10" then
            handValue = handValue +10
        elseif v[1] == "J" then
            handValue = handValue +10
        elseif v[1] == "Q" then
            handValue = handValue +10
        elseif v[1] == "K" then
            handValue = handValue +10
        elseif v[1] == "A" then
            handValue = handValue +11
            numAces = numAces +1
        end

        repeat
            if handValue > 21 and numAces > 0 then
                numAces = numAces - 1
                handValue = handValue - 10
            end
        until numAces <= 0 or handValue <= 21

        if handValue == 17 and numAces > 0 then
            soft = true;
        end
    end

    return handValue, soft
end

function standPlay()
    -- print("Checking dealerHand")

    -- print(#dealerHand)
    for i=1, #dealerHand do
        if dealerHand[i][1] == "flipped" then
            -- print(dealerHand[i][2])
            dealerHand[i][1] = dealerHand[i][2][1]
            dealerHand[i][2] = dealerHand[i][2][2]
        end
    end

    local dealerValue, soft = getHandValue(dealerHand)

    if dealerValue == 17 and soft then
        -- print("Soft 17")
        dealHouse()
    elseif dealerValue >= 17 then
        -- print("Greater then or equal to 17")
        return true
    elseif dealerValue < 17 then
        -- print("less then 17")
        dealHouse()
    end
end

--create buttons
local quit = button.Button()
quit.set("label", "Quit")
quit.set("func", quitGame)
quit.set("posY", math.floor(y*0.97))
quit.set("posX", math.ceil(x*0.95))
quit.set("height", 3)
quit.set("width", 6)
table.insert(buttons, quit)

local hit = button.Button()
hit.set("label", "Hit")
hit.set("func", dealPlayer)
hit.set("posY", math.floor(y*0.85))
hit.set("posX", math.ceil(x*0.40))
table.insert(buttons, hit)

local stand = button.Button()
stand.set("label", "Stand")
stand.set("posY", math.floor(y*0.85))
stand.set("posX", math.ceil(x*0.60))
stand.set("func", standPlay)
table.insert(buttons, stand)

local playAgain = button.Button()
playAgain.set("label", "Play again")
playAgain.set("func", playHand)

function playHand()
    -- print("Starting new hand")
    --Empties the dealer and player hands
    playerHand = {}
    dealerHand = {}

    --Reset local variables
    local playerBust = false
    local continue = false
    local hidden = false
    local dealerBust = false
    local blackJack = false

    -- Deals cards out to the player and the house
    while #playerHand < 2 do
        sleep(0.25)
        dealPlayer()
        redraw()
        sleep(0.25)
        dealHouse(hidden)
        redraw()
        hidden = true
    end

    drawButtons()

    if getHandValue(playerHand) == 21 then
        continue = true
        blackJack = true
        stand.get("func")
        redraw()
        drawButtons()
    end

    --Until the player busts or stands
    repeat
        local event = {os.pullEvent()}
    
        if event[1] == "monitor_touch" then
            if quit.clicked(event[3], event[4]) then
                quit.toggle(mon)
                quit.get("func")()
            elseif hit.clicked(event[3], event[4]) then
                hit.toggle(mon)
                hit.get("func")()
                redraw()
                drawButtons()
                local playerValue = getHandValue(playerHand)

                if playerValue > 21 then
                    playerBust = true
                end
            elseif stand.clicked(event[3], event[4]) then
                stand.toggle(mon)

                repeat
                    continue = stand.get("func")()
                    redraw()
                    drawButtons()
                    sleep(0.25)
                until continue
                -- print("Continuing Play")
            end
        end
    until playerBust or continue

    local old = term.redirect(mon)
    paintutils.drawFilledBox(1, y/2-2, x, y/2+2, colors.blue)
    term.redirect(old)

    if getHandValue(dealerHand) > 21 then
        dealerBust = true
    end

    if playerBust then
        center("Bust!")
    else
        if blackJack then
            center("Blackjack!")
        elseif getHandValue(playerHand) > getHandValue(dealerHand) or dealerBust then
            center("You win!")
        elseif getHandValue(playerHand) == getHandValue(dealerHand) then
            center("You Push")
        else
            center("You Lose!")
        end
    end
    sleep(3)
end

shuffle()

local play = true
--Run
while true do
    if play then
        --Begins the hand
        playHand()
        play = false
    end

    --Clears the monitor
    resetMon()
    playAgain.draw(mon)
    quit.draw(mon)

    local event = {os.pullEvent()}

    if event[1] == "monitor_touch" then
        if quit.clicked(event[3], event[4]) then
            quit.toggle(mon)
            quit.get("func")()
        elseif playAgain.clicked(event[3], event[4]) then
            playAgain.toggle(mon)
            play = true
        else
            play = false
        end
    end
end
