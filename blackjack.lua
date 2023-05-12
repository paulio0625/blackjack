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

local cards = {
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

--exits the current process
function quitGame()
    error()
end

--adds the value given to the bet
function addBet(betValue)
    if bet + betValue < 1 then
        bet = 1
    else
        bet = bet + betValue
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

local plusOne = button.Button()
plusOne.set("label", "+1")
plusOne.set("func", addBet)
plusOne.set("posX", math.ceil(x/2) + 2)
plusOne.set("posY", math.floor(y*0.75))

local plusTen = button.Button()
plusTen.set("label", "+10")
plusTen.set("func", addBet)
plusTen.set("posX", math.ceil(x/2) + 6)
plusTen.set("posY", math.floor(y*0.75))

local plusHundred = button.Button()
plusHundred.set("label", "+100")
plusHundred.set("func", addBet)
plusHundred.set("posX", math.ceil(x/2) + 11)
plusHundred.set("posY", math.floor(y*0.75))

local minusOne = button.Button()
minusOne.set("label", "-1")
minusOne.set("func", addBet)
minusOne.set("posX", math.ceil(x/2) - 2)
minusOne.set("posY", math.floor(y*0.75))

local minusTen = button.Button()
minusTen.set("label", "-10")
minusTen.set("func", addBet)
minusTen.set("posX", math.ceil(x/2) - 6)
minusTen.set("posY", math.floor(y*0.75))

local minusHundred = button.Button()
minusHundred.set("label", "-100")
minusHundred.set("func", addBet)
minusHundred.set("posX", math.ceil(x/2) - 10)
minusHundred.set("posY", math.floor(y*0.75))

local confirm = button.Button()
confirm.set("label", "Confirm?")
confirm.set("posX", math.ceil(x/2))
confirm.set("posY", math.floor(y*0.85))

function center(str)
    
    local posX = math.ceil(x/2)-math.floor(#str/2)
    local posY = math.ceil(y/2)
    
    mon.setCursorPos(posX, posY)
    mon.write(str)
end

--If no card inserted ask for payment card
function checkCard()
    resetMon()
    local isDisk = dis.isDiskPresent()

    while not isDisk do
        center("Please insert card")

        isDisk = dis.isDiskPresent()
    end
end

function placeBet()
    resetMon()
    local askMessage = "How much would you like to bet?"
    local betMessage = "Bet: "..bet

    if not dis.isDiskPresent() then
        checkCard()
    end

    local labelString = dis.getDiskLabel()

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

        --Prompt with buttons for +-1 +-5 +-10 +-100, confirm and quit
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
            --if confirm check the players bet against their ammount
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
                    dis.setDiskLabel("$"..playerMoney-bet)
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
--begin a hand
--deal cards to player and to dealer
    --check to see if the player has a blackjack
--Prompt for stand, hit, double, split if available or quit
--if stand check dealers hand to see value
    --Move to stand function
--if hit deal player another card and check to see if they have bust
    --if not bust then check against the dealer's hand to see who wins
--if double then double the players bet and give one last card
    --Move to the stand function
--if the player has 2 of the same value card offer split
    --on split seperate into 2 hands of the same value bet
    --run through one hand after the other
    --re-prompt the same buttons for each hand
--If quit go to quit function

--Stand Function
    --if dealer hand value is less then hard 17 or has soft 17 then take more cards until either bust or above 17

--quit function
    --prompt for if player is sure
        --if yes go to quit function
        --if no continue game

placeBet()