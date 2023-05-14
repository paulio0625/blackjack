os.loadAPI("button.lua")

local mon = peripheral.find("monitor")

mon.setBackgroundColor(colors.black)
mon.setTextColor(colors.white)
mon.setTextScale(1)
mon.clear()

local x, y = mon.getSize()

local dragonsteelChest = peripheral.wrap("sophisticatedstorage:chest_1")
local shelliteChest = peripheral.wrap("sophisticatedstorage:chest_2")
local chest = peripheral.wrap("sophisticatedstorage:chest_0")

local cardValue = 0
local chestValue = 0

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

resetMon()

center("In chest: $"..chestValue)

sleep(4)