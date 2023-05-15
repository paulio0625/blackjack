os.loadAPI("button.lua")

local mon = peripheral.find("monitor")
local dis = peripheral.find("drive")

mon.setBackgroundColor(colors.black)
mon.setTextColor(colors.white)
mon.setTextScale(1)
mon.clear()

local x, y = mon.getSize()

local chest = peripheral.wrap("sophisticatedstorage:chest_0")
local trash = peripheral.wrap("trashcans:item_trash_can_tile_0")

local cardValue = 0
local depositAmount = 0

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

--scan button
local scan = button.Button()
scan.set("label", "Scan")
scan.set("posX", math.ceil(x/2))
scan.set("posY", math.floor(y*0.75))

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

while true do
    resetMon()
    depositAmount = 0

    if not dis.isDiskPresent() then
        checkCard()
    end
    
    local label = dis.getDiskLabel()
    cardValue = tonumber(string.match(label, "%d+"), 10)

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

    center("Please deposit your coins")
    center("into the chest", 1)

    scan.draw(mon)
    quit.draw(mon)

    local event = {os.pullEvent()}

    if event[1] == "monitor_touch" then
        if scan.clicked(event[3], event[4]) then
            local numDragonsteelCoins = 0
            local numShelliteCoins = 0
            scan.toggle(mon)

            for slot, item in pairs(chest.list()) do
                if item.name == "thermal_extra:dragonsteel_coin" then
                    depositAmount = depositAmount + (item.count*100)
                    numDragonsteelCoins = numDragonsteelCoins + item.count
                elseif item.name == "thermal_extra:shellite_coin" then
                    depositAmount = depositAmount + item.count
                    numShelliteCoins = numShelliteCoins + item.count
                end
            end

            while true do
                resetMon()

                center("Please confirm deposit of:")
                center("$"..depositAmount, 1)

                yes.draw(mon)
                no.draw(mon)
                quit.draw(mon)

                event = {os.pullEvent()}

                if event[1] == "monitor_touch" then
                    if yes.clicked(event[3], event[4]) then
                        yes.toggle(mon)
    
                        resetMon()
    
                        center("Depositing please wait")
    
                        for i=1, chest.size() do
                            if chest.getItemDetail(i) then
                                local item = chest.getItemDetail(i)
                                if item.name == "thermal_extra:dragonsteel_coin" then
                                    local num = chest.pushItems(peripheral.getName(trash), i)
                                    numDragonsteelCoins = numDragonsteelCoins - num
                                elseif item.name == "thermal_extra:shellite_coin" then
                                    local num = chest.pushItems(peripheral.getName(trash), i)
                                    numShelliteCoins = numShelliteCoins - num
                                end
                            end
                        end
                        
                        depositAmount = depositAmount - (numDragonsteelCoins*100) - numShelliteCoins
    
                        resetMon()
    
                        center("Successfully Deposited")
                        center("$".. depositAmount, 1)

                        cardValue = cardValue + depositAmount
                        dis.setDiskLabel("$"..cardValue)
    
                        sleep(1)
                        error()
                    elseif no.clicked(event[3], event[4]) then
                        no.toggle(mon)
                        break
                    elseif quit.clicked(event[3], event[4]) then
                        quit.toggle(mon)
                        quit.get("func")()
                    end
                end 
            end
        elseif quit.clicked(event[3], event[4]) then
            quit.toggle(mon)
            quit.get("func")()
        end
    end
end