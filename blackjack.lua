--init
os.loadAPI("button.lua")

local mon = peripheral.find("monitor")
local dis = peripheral.find("drive")

local x, y = mon.getSize()

local playerHand = {}
local dealerHand = {}
local deck = {}

local  bet = 1
local playerMoney = 0

local buttons = {}

local cards = {
    {"A", "\3"}, {"A", "\4"}, {"A", "\5"}, {"A", "\6"},
    {"K", "\3", "split"}, {"K", "\4", "split"}, {"K", "\5", "split"}, {"K", "\6", "split"},
    {"Q", "\3", "split"}, {"Q", "\4", "split"}, {"Q", "\5", "split"}, {"Q", "\6", "split"},
    {"J", "\3", "split"}, {"J", "\4", "split"}, {"J", "\5", "split"}, {"J", "\6", "split"},
    {"10","\3", "split"}, {"10","\4", "split"}, {"10","\5", "split"}, {"10","\6", "split"},
    {"9", "\3"}, {"9", "\4"}, {"9", "\5"}, {"9", "\6"},
    {"8", "\3"}, {"8", "\4"}, {"8", "\5"}, {"8", "\6"},
    {"7", "\3"}, {"7", "\4"}, {"7", "\5"}, {"7", "\6"},
    {"6", "\3"}, {"6", "\4"}, {"6", "\5"}, {"6", "\6"},
    {"5", "\3"}, {"5", "\4"}, {"5", "\5"}, {"5", "\6"},
    {"4", "\3"}, {"4", "\4"}, {"4", "\5"}, {"4", "\6"},
    {"3", "\3"}, {"3", "\4"}, {"3", "\5"}, {"3", "\6"},
    {"2", "\3"}, {"2", "\4"}, {"2", "\5"}, {"2", "\6"}
}

--resets the monitor
local function resetMon()
    mon.setBackgroundColor(colors.green)
    mon.setTextColor(colors.white)
    mon.clear()
end

--centers text with potiential for a vertical offset
local function center(str, offset)
    --makes sure the offset has a value
    offset = offset or 0

    --get the center of the monitor
    local posX = math.ceil(x/2)-math.floor(#str/2)
    local posY = math.floor(y/2)
    
    mon.setCursorPos(posX, posY + offset)
    mon.write(str)
end

--adds cards to the player's hand
local function dealPlayer()
    playerHand[#playerHand+1] = deck[#deck]
    deck[#deck] = nil
end

--deals cards to dealer's hand
local function dealHouse(hide)
    dealerHand[#dealerHand+1] = deck[#deck]

    --If card is hidden set primary value to flipped and second value to the card
    if hide then
        dealerHand[#dealerHand] = {"flipped", deck[#deck]}
    end

    deck[#deck] = nil
end

local function drawButtons()
    for i, but in pairs(buttons) do
        but.draw(mon)
    end
end

--draws the card on the screen at position x, y
local function printCard(card, x, y)
    mon.setCursorPos(x, y)
    
    --check if the card is a heart or diamond
    if card[2] == "\3" or card[2] == "\4" then
        mon.setBackgroundColor(colors.white)
        mon.setTextColor(colors.red)
    else
        mon.setBackgroundColor(colors.white)
        mon.setTextColor(colors.black)
    end
    
    --check if the card is a flipped card
    if card[1] == "flipped" then
        mon.setBackgroundColor(colors.red)
        mon.setTextColor(colors.white)
        
        mon.write("+-+")
        mon.setCursorPos(x, y+1)
        mon.write("|*|")
        mon.setCursorPos(x, y+2)
        mon.write("+-+")
    --check if the card is a 10
    elseif card[1] == "10" then
        mon.write("10 ")
        mon.setCursorPos(x, y+1)
        mon.write(" " .. card[2] .. " ")
        mon.setCursorPos(x, y+2)
        mon.write(" 10")
    else
        mon.write(card[1].."  ")
        mon.setCursorPos(x, y+1)
        mon.write(" "..card[2].." ")
        mon.setCursorPos(x, y+2)
        mon.write("  "..card[1])
    end
end

--redraws the whole ui
local function redraw()
    resetMon()

    --Add spacing to the card
    local spacing = (math.ceil(x/2) - #dealerHand*2) + 1

    --for all cards in the dealerHand
    for i=1, #dealerHand do
        --get the card from the dealerHand
        local card = dealerHand[i]

        --draw the card
        printCard(card, spacing, math.floor(y*0.25))

        --add more spacing for the next card
        spacing = spacing + 4
    end

    --reset spacing for new hand
    spacing = (math.ceil(x/2) - #playerHand*2) + 1

    --for all cards in the playerHand
    for i=1, #playerHand do
        --get the card from the playerHand
        local card = playerHand[i]

        --draw the card
        printCard(card, spacing, math.floor(y*0.65))

        --add more spacing for the next card
        spacing = spacing + 4
    end

    --Draw deck in the center of the board
    printCard({"flipped"}, x/2, y*0.45)
end

--shuffles the deck
local function shuffle()
    resetMon()
    center("Shuffling Deck...")
    sleep(1)
    
    --for all the cards
    for i, card in pairs(cards) do
        local pos

        --get a random empty position in the deck
        repeat
            pos = math.random(1,52)
        until deck[pos] == nil

        --slot a card into that position
        deck[pos] = card
    end
    
    resetMon()
    center("Done!")

    sleep(1.5)
    resetMon()
end

--gets the value of the given hand
local function getHandValue(hand)
    local handValue = 0;
    local numAces = 0;
    local soft = false;

    --for each card in the hand add its value to the hand
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

        --if hand has a value greater then 21 and there is an ace change it's value to 1 and check value again
        repeat
            if handValue > 21 and numAces > 0 then
                numAces = numAces - 1
                handValue = handValue - 10
            end
        until numAces <= 0 or handValue <= 21

        --check if the hand has a soft 17
        if handValue == 17 and numAces > 0 then
            soft = true;
        end
    end

    return handValue, soft
end

--adds the value given to the bet
local function setBet(betValue)
    --makes sure the player is at least betting 1 dollar
    if bet + betValue < 1 then
        bet = 1
    else
        bet = bet + betValue
    end
end

--Check that there is a payment card
local function checkCard()
    resetMon()
    --check disk drive for disk
    local isDisk = dis.isDiskPresent()

    --while there is no disk ask for disk and check again
    while not isDisk do
        center("Please insert card")

        isDisk = dis.isDiskPresent()
        sleep(0.5)
    end
end

--if the player stands
local function standPlay(blackjack)
    --reveal the dealers flipped card
    if dealerHand[2][1] == "flipped" then
        dealerHand[2][1] = dealerHand[2][2][1]
        dealerHand[2][2] = dealerHand[2][2][2]
    end

    --get's the dealer's hand value and if it is a soft hand
    local dealerValue, soft = getHandValue(dealerHand)

    --if both the dealer and player have blackjack
    if blackjack and dealerValue == 21 then
        return true
    elseif blackjack then
        return false
    --if the dealer has a soft 17 deal another card
    elseif dealerValue == 17 and soft then
        dealHouse()
    --if the dealer has less then 17 deal another card
    elseif dealerValue < 17 then
        dealHouse()
    end
end

--if the player doubles down
local function doublePlay()
    --Make sure the player has enough money to double
    if bet > playerMoney then
        resetMon()
        center("Not enough money!")
        sleep(2)
        return false
    else
        --check to make sure card is still in drive
        checkCard()

        --adjust the players card total
        playerMoney = playerMoney - bet
        dis.setDiskLabel("$"..playerMoney)

        --confirm the double is allowed
        return true
    end
end

--Yes/No Buttons
local yes = button.Button()
yes.set("label", "Yes")
yes.set("posX", math.ceil(x/2) - 2)
yes.set("posY", math.ceil(y/2) + 2)

local no = button.Button()
no.set("label", "No")
no.set("posX", math.ceil(x/2) + 2)
no.set("posY", math.ceil(y/2) + 2)

--quit function
local function quitGame()    
    resetMon()
    --prompt for if player is sure
    center("Are you sure?", -8)
    center("If you have confirmed a bet", -7)
    center("you will lose the money", -6)

    yes.draw(mon)
    no.draw(mon)

    while true do
        local event = {os.pullEvent()}

        if event[1] == "monitor_touch" then
            --if yes quit the game
            if yes.clicked(event[3], event[4]) then
                yes.toggle(mon)
                error()
            --if no continue the game
            elseif no.clicked(event[3], event[4]) then
                no.toggle(mon)
                
                redraw()
                drawButtons()
                return
            end
        end
    end
end

--Quit button
local quit = button.Button()
quit.set("label", "Quit")
quit.set("func", quitGame)
quit.set("posY", math.floor(y*0.97))
quit.set("posX", math.ceil(x*0.95))
quit.set("height", 3)
quit.set("width", 6)

--Add/Subtract Money buttons
local plusOne = button.Button()
plusOne.set("label", "+1")
plusOne.set("func", setBet)
plusOne.set("posX", math.ceil(x/2) + 2)
plusOne.set("posY", math.floor(y*0.75))

local plusTen = button.Button()
plusTen.set("label", "+10")
plusTen.set("func", setBet)
plusTen.set("posX", math.ceil(x/2) + 6)
plusTen.set("posY", math.floor(y*0.75))

local plusHundred = button.Button()
plusHundred.set("label", "+100")
plusHundred.set("func", setBet)
plusHundred.set("posX", math.ceil(x/2) + 11)
plusHundred.set("posY", math.floor(y*0.75))

local minusOne = button.Button()
minusOne.set("label", "-1")
minusOne.set("func", setBet)
minusOne.set("posX", math.ceil(x/2) - 2)
minusOne.set("posY", math.floor(y*0.75))

local minusTen = button.Button()
minusTen.set("label", "-10")
minusTen.set("func", setBet)
minusTen.set("posX", math.ceil(x/2) - 6)
minusTen.set("posY", math.floor(y*0.75))

local minusHundred = button.Button()
minusHundred.set("label", "-100")
minusHundred.set("func", setBet)
minusHundred.set("posX", math.ceil(x/2) - 10)
minusHundred.set("posY", math.floor(y*0.75))

--confirm bet button
local confirm = button.Button()
confirm.set("label", "Confirm?")
confirm.set("posX", math.ceil(x/2))
confirm.set("posY", math.floor(y*0.85))

--gets the player to place a bet
local function placeBet()
    resetMon()
    local askMessage = "How much would you like to bet?"
    local betMessage = "Bet: "..bet

    --checks for card
    if not dis.isDiskPresent() then
        checkCard()
    end

    --gets the card ammount
    local labelString = dis.getDiskLabel()

    --converts the amount to a number
    playerMoney = tonumber(string.match(labelString, "%d+"))

    resetMon()

    repeat
        resetMon()

        betMessage = "Bet: "..bet

        --Ask for bet from player
        mon.setCursorPos(math.ceil(x/2) - math.floor(#askMessage/2), math.floor(y*0.25))
        mon.write(askMessage)

        mon.setCursorPos(math.ceil(x/2) - math.floor(#betMessage/2), math.floor(y*0.30))
        mon.write(betMessage)

        --Prompt with buttons for +-1 +-10 +-100, confirm and quit
        plusOne.draw(mon)
        plusTen.draw(mon)
        plusHundred.draw(mon)
        minusOne.draw(mon)
        minusTen.draw(mon)
        minusHundred.draw(mon)
        confirm.draw(mon)
        quit.draw(mon)

        local event = {os.pullEvent()}

        if event[1] == "monitor_touch" then
            --if quit go to quit function 
            if quit.clicked(event[3], event[4]) then
                quit.toggle(mon)
                quit.get("func")()
            --confirms the players bet
            elseif confirm.clicked(event[3], event[4]) then
                confirm.toggle(mon)
                --If bet exceeds player currency fail and return to bet screen
                if bet > playerMoney then
                    resetMon()
                    local failMessage = "Not enough money!"
                    mon.setCursorPos(math.ceil(x/2) - math.floor(#failMessage/2), math.floor(y/2))
                    mon.write(failMessage)
                    sleep(3)
                --If bet under player currency succeed and subtract bet from total before continuing on
                else
                    checkCard()
                    playerMoney = playerMoney - bet
                    dis.setDiskLabel("$"..playerMoney)
                   return 
                end
            --If money button increment or decrement the players bet
            elseif plusOne.clicked(event[3], event[4]) then
                plusOne.toggle(mon)
                plusOne.get("func")(1)
            elseif plusTen.clicked(event[3], event[4]) then
                plusTen.toggle(mon)
                plusTen.get("func")(10)
            elseif plusHundred.clicked(event[3], event[4]) then
                plusHundred.toggle(mon)
                plusHundred.get("func")(100)
            elseif minusOne.clicked(event[3], event[4]) then
                minusOne.toggle(mon)
                minusOne.get("func")(-1)
            elseif minusTen.clicked(event[3], event[4]) then
                minusTen.toggle(mon)
                minusTen.get("func")(-10)
            elseif minusHundred.clicked(event[3], event[4]) then
                minusHundred.toggle(mon)
                minusHundred.get("func")(-100)
            end
        end
    until false
end

local hit = button.Button()
hit.set("label", "Hit")
hit.set("func", dealPlayer)
hit.set("posY", math.floor(y*0.85))
hit.set("posX", math.ceil(x*0.20))

local stand = button.Button()
stand.set("label", "Stand")
stand.set("posY", math.floor(y*0.85))
stand.set("posX", math.ceil(x*0.40))
stand.set("func", standPlay)

local double = button.Button()
double.set("label", "Double")
double.set("posY", math.floor(y*0.85))
double.set("posX", math.ceil(x*0.60))
double.set("func", doublePlay)

local split = button.Button()
split.set("label", "Split")
split.set("posY", math.floor(y*0.85))
split.set("posX", math.ceil(x*0.80))
split.set("active", false)

table.insert(buttons, hit)
table.insert(buttons, stand)
table.insert(buttons, double)
table.insert(buttons, split)
table.insert(buttons, quit)

local function playHand(player, dealer)
    --Empty the dealerHand and playerHand
    if not player then
        playerHand = {}
        dealerHand = {}
    --if hand is being passed in set it to that
    else
        playerHand = {}
        dealerHand = {}
        playerHand = player
        dealerHand = dealer
    end

    --Create local variables
    local playerBust = false
    local dealerBust = false
    local blackjack = false
    local dealerjack = false
    local doubleBet = false
    local splitHand = false

    local hidden = false

    --Deal to player and dealer
    while #playerHand < 2 do
        if #dealerHand < 2 then
            sleep(0.25)
            dealHouse(hidden)
            redraw()
        end
        sleep(0.25)
        dealPlayer()
        redraw()
        hidden = true
    end

    if playerHand[1][1] == playerHand[2][1] then
        split.set("active", true)
        split.set("colorNormal", colors.blue)
    elseif playerHand[1][3] and playerHand[2][3] then
        split.set("active", true)
        split.set("colorNormal", colors.blue)
    else
        split.set("active", false)
        split.set("colorNormal", colors.gray)
    end
    --draw the gameplay buttons
    drawButtons()

    --Check for a blackjack
    if getHandValue(playerHand) == 21 then
        blackjack = true

        --go to stand function
        if stand.get("func")(blackjack) then
            dealerjack = true
        end
        redraw()
    end

    --continue the game while not standing or bust
    while true and not blackjack do
        local event = {os.pullEvent()}

        if event[1] == "monitor_touch" then
            --if quit go to quit function
            if quit.clicked(event[3], event[4]) then
                quit.toggle(mon)
                quit.get("func")()
            --if hit deal the player a new card
            elseif hit.clicked(event[3], event[4]) then
                hit.toggle(mon)
                hit.get("func")()

                redraw()
                drawButtons()

                --get the playerHand value
                local playerValue = getHandValue(playerHand)

                --make sure player hasn't bust
                if playerValue > 21 then
                    playerBust = true
                    break
                end
            --if stand go to the stand function and set continue to true
            elseif stand.clicked(event[3], event[4]) then
                stand.toggle(mon)

                while getHandValue(dealerHand) < 17 do
                    stand.get("func")(blackjack)
                    redraw()
                    sleep(0.25)
                end
                break
            --go to double function
            elseif double.clicked(event[3], event[4]) then
                double.toggle(mon)
                doubleBet = double.get("func")()

                if doubleBet then
                    --deal the player one more card
                    dealPlayer()
                    redraw()

                    --check playerHand value
                    local playerValue = getHandValue(playerHand)

                    --make sure player hasn't bust
                    if playerValue > 21 then
                        playerBust = true
                        break
                    end

                    --player stands
                    while getHandValue(dealerHand) < 17 do
                        stand.get("func")(blackjack)
                        redraw()
                        sleep(0.25)
                    end
                    break
                else
                    redraw()
                    drawButtons()
                end
            --go to split function
            elseif split.clicked(event[3], event[4]) then
                if split.get("active") then
                    split.toggle(mon)

                    local tempDealerHand = dealerHand
                    local splitCard = playerHand[2]
                    local splitBet = bet
                    if bet > playerMoney then
                        resetMon()
                        center("Not enough money!")
                        sleep(2)
                        return
                    else
                        --check to make sure card is still in slot
                        checkCard()

                        splitHand = true

                        --adjust the players card total
                        dis.setDiskLabel("$"..playerMoney-bet)
                        playerMoney = playerMoney - bet

                        playerHand[2] = nil

                        playHand(playerHand, dealerHand)

                        bet = splitBet
                        playerHand = {}
                        playerHand[1] = splitCard

                        redraw()
                        
                        playHand(playerHand, tempDealerHand)

                        redraw()
                        return
                    end

                    break
                end
            end
        end
    end

    --prep to draw the results
    local old = term.redirect(mon)
    paintutils.drawFilledBox(1, y/2-2, x, y/2+2, colors.blue)
    term.redirect(old)

    --check for dealer bust
    if getHandValue(dealerHand) > 21 then
        dealerBust = true
    end

    --check to see if there was a split
    if splitHand then
        center("Split hand done!")
    --check player bust
    elseif playerBust then
        center("Bust!")
    --print the results
    elseif dealerjack or getHandValue(playerHand) == getHandValue(dealerHand) then
        center("You Push")
        if doubleBet then
            playerMoney = playerMoney + bet * 2
        else
            playerMoney = playerMoney + bet 
        end
    elseif blackjack then
        center("Blackjack!")
        playerMoney = playerMoney + math.floor(bet*2.5)
    elseif dealerBust then
        center("Dealer Bust!")
        if doubleBet then
            playerMoney = playerMoney + bet * 4
        else
            playerMoney = playerMoney + bet * 2
        end
    elseif getHandValue(playerHand) > getHandValue(dealerHand) then
        center("You win!")
        if doubleBet then
            playerMoney = playerMoney + bet * 4
        else
            playerMoney = playerMoney + bet * 2
        end
    else
        center("You Lose!")
    end
    dis.setDiskLabel("$"..playerMoney)
    bet = 1
    sleep(3)
end

local function startGame()
    --Ask the player to place their bet
    placeBet()

    if #deck < 12 then
        deck = {}
        --shuffle the deck
        shuffle()
    end

    --begin a hand
    playHand()
end

startGame()

local playAgain = button.Button()
playAgain.set("label", "Play again")
playAgain.set("func", startGame)
playAgain.set("posY", math.floor(y/2) + 1)

local notNow = button.Button()
notNow.set("label", "Not right now")
notNow.set("posY", math.floor(y/2) + 3)

while true do
    resetMon()

    --ask to play again
    center("Play again?", -2)
    playAgain.draw(mon)
    notNow.draw(mon)

    local event = {os.pullEvent()}

    if event[1] == "monitor_touch" then
        if playAgain.clicked(event[3], event[4]) then
            playAgain.toggle(mon)
            playAgain.get("func")()
        elseif notNow.clicked(event[3], event[4]) then
            notNow.toggle(mon)
            break
        end
    end
end

return