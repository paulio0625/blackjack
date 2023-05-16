os.loadAPI("button.lua")

local mon = peripheral.find("monitor")
local dis = peripheral.find("drive")

mon.setBackgroundColor(colors.black)
mon.setTextColor(colors.white)
mon.setTextScale(1)
mon.clear()

local x, y = mon.getSize()

local dragonsteelChest = peripheral.wrap("sophisticatedstorage:chest_1")
local shelliteChest = peripheral.wrap("sophisticatedstorage:chest_2")
local chest = peripheral.wrap("sophisticatedstorage:chest_0")

local cardValue = 0
local withdrawAmount = 0

--resets the monitor
local function resetMon()
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.white)
    mon.setTextScale(1)
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

local function setWithdraw(amount)
    if withdrawAmount + amount < 0 then
        withdrawAmount = 0
    else
        withdrawAmount = withdrawAmount + amount
    end
end

--Add/Subtract Money buttons
local plusOne = button.Button()
plusOne.set("label", "+1")
plusOne.set("func", setWithdraw)
plusOne.set("posX", math.ceil(x/2) + 2)
plusOne.set("posY", math.floor(y*0.75))

local plusTen = button.Button()
plusTen.set("label", "+10")
plusTen.set("func", setWithdraw)
plusTen.set("posX", math.ceil(x/2) + 6)
plusTen.set("posY", math.floor(y*0.75))

local plusHundred = button.Button()
plusHundred.set("label", "+100")
plusHundred.set("func", setWithdraw)
plusHundred.set("posX", math.ceil(x/2) + 11)
plusHundred.set("posY", math.floor(y*0.75))

local minusOne = button.Button()
minusOne.set("label", "-1")
minusOne.set("func", setWithdraw)
minusOne.set("posX", math.ceil(x/2) - 2)
minusOne.set("posY", math.floor(y*0.75))

local minusTen = button.Button()
minusTen.set("label", "-10")
minusTen.set("func", setWithdraw)
minusTen.set("posX", math.ceil(x/2) - 6)
minusTen.set("posY", math.floor(y*0.75))

local minusHundred = button.Button()
minusHundred.set("label", "-100")
minusHundred.set("func", setWithdraw)
minusHundred.set("posX", math.ceil(x/2) - 10)
minusHundred.set("posY", math.floor(y*0.75))

--confirm button
local confirm = button.Button()
confirm.set("label", "Confirm?")
confirm.set("posX", math.ceil(x/2))
confirm.set("posY", math.floor(y*0.85))

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
    center("Are you sure?")

    yes.draw(mon)
    no.draw(mon)

    while true do
        local event = {os.pullEvent()}

        if event[1] == "monitor_touch" then
            --if yes quit
            if yes.clicked(event[3], event[4]) then
                yes.toggle(mon)
                error()
            --if no continue
            elseif no.clicked(event[3], event[4]) then
                no.toggle(mon)
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

checkCard()

resetMon()

if dis.getDiskID() == 0 then
    center("Hello Paul")
elseif dis.getDiskID() == 1 then
    center("Hello Mystic")
elseif dis.getDiskID() == 2 then
    center("Hello Lorb")
elseif dis.getDiskID() == 3 then
    center("Hello Waffles")
elseif dis.getDiskID() == 4 then
    center("Hello Micro")
end

sleep(2)

resetMon()

while true do
    resetMon()

    if not dis.isDiskPresent() then
        checkCard()
    end

    local label = dis.getDiskLabel()
    cardValue = tonumber(string.match(label, "%d+"), 10)

    center("How much would you like to", -8)
    center("withdraw?", -7)
    center("On card: $"..cardValue, -6)

    center("Withdraw amount: $"..withdrawAmount)

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
        if plusOne.clicked(event[3], event[4]) then
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
        elseif confirm.clicked(event[3], event[4]) then
            confirm.toggle(mon)

            if cardValue < withdrawAmount then
                resetMon()
                center("Not enough money!")
            else
                while true do
                    resetMon()

                    center("Are you sure you want to", -1)
                    center("withdraw:")
                    center("$"..withdrawAmount, 1)

                    yes.draw(mon)
                    no.draw(mon)
                    quit.draw(mon)

                    local e = {os.pullEvent()}

                    if event[1] == "monitor_touch" then
                        if yes.clicked(e[3], e[4]) then
                            yes.toggle(mon)
    
                            if not dis.isDiskPresent() then
                                checkCard()
                            end
    
                            local hundreds = math.floor(withdrawAmount / 100)
                            local tens = withdrawAmount % 100
    
                            chest.pullItems(peripheral.getName(dragonsteelChest), 1, hundreds)
                            chest.pullItems(peripheral.getName(shelliteChest), 1, tens)
    
                            cardValue = cardValue - withdrawAmount
                            dis.setDiskLabel("$"..cardValue)
    
                            resetMon()
    
                            center("Remaining Blance:")
                            center("$"..cardValue, 1)
    
                            sleep(2)
            
                            error()
                        elseif no.clicked(e[3], e[4]) then
                            no.toggle(mon)
                            break
                        elseif quit.clicked(e[3], e[4]) then
                            quit.toggle(mon)
                            quit.get("func")()
                        end
                    end 
                end
            end
        elseif quit.clicked(event[3], event[4]) then
            quit.toggle(mon)
            quit.get("func")()
        end
    end
end