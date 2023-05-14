--init
os.loadAPI("button.lua")

local mon = peripheral.find("monitor")

mon.setBackgroundColor(colors.black)
mon.setTextColor(colors.white)
mon.setTextScale(2)
mon.clear()

local x, y = mon.getSize()

--resets the monitor
local function resetMon()
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.white)
    mon.setTextScale(2)
    mon.clear()
end

local function deposit()
    shell.run("deposit")
end

local function withdraw()
    shell.run("withdraw")
end

local dep = button.Button()
dep.set("label", "Deposit")
dep.set("posX", math.ceil(x*0.5))
dep.set("posY", math.floor(y*0.4))
dep.set("func", deposit)

local with = button.Button()
with.set("label", "Withdraw")
with.set("posX", math.ceil(x*0.5))
with.set("posY", math.floor(y*0.6)+1)
with.set("func", withdraw)

while true do
    resetMon()

    dep.draw(mon)
    with.draw(mon)

    local event = {os.pullEvent()}

    if event[1] == "monitor_touch" then
        if dep.clicked(event[3], event[4]) then
            dep.toggle(mon)
            dep.get("func")()
        elseif with.clicked(event[3], event[4]) then
            with.toggle(mon)
            with.get("func")()
        end
    end
end