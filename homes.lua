-- [[ THIS CODE IS WRITTEN BY LIQUIDV2 (76561198118979386) DONT COPY OR STEAL! ]] -- 

--	discord: Liquid#4783
--	Steam:   https://steamcommunity.com/profiles/76561198118979386



PLUGIN = PLUGIN or {}

PLUGIN.name = "Homes"
PLUGIN.author = "Liquidv2"
PLUGIN.description = "Adds a home system [like in minecraft]"
PLUGIN.readme = [[
Adds most things that come to mind, like:
    /sethome  -Sets a home at the current position.
    /delhome  -Deletes specified home [all will delete ALL homes].
    /home     -Teleports you to a specified home.
    /homelist -Lists all your homes in chat.
If no args are given will default to default value ( normally: 'home' )

Configs:
    AdminOnly
    HomeLimit -How many homes people can create [0 for infinite]
    TeleportTime -How long it takes to TP
    DamageCheck -Cancel TP when getting damage
    MovementCheck -Cancel TP when moving
    WeaponCheck -Cancel TP when switching to another weapon

Custom Privilege: 'Helix - Homes'
]]

PLUGIN.license = [[
The MIT License (MIT)

Copyright (c) 2021 Liquidv2

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

-----[LANGUAGE STUFF]-----
ix.lang.AddTable("english", {
    /*
    --[You need to set these on the command itself]--
    TPSetHome = "Sets a home[TP] at your current location",
    TPDelHome = "Deletes the specefied home",
    TPHome = "Teleports you to your home(s)",
    */
	TPSuccess = "Successfully teleported to home: %s",
    TPSuccessSet = "Successfully set home: %s",
    TPSuccessDel = "Successfully removed home: %s",
    TPSuccessDelAll = "Successfully removed all homes!",
    TPInProgress = "You are already teleporting to a home!",
    TPNoHome = "No home with the name: %s",
    TPTime = "Teleporting in: %s",
    TPLimit = "Limit reached: %s",
    TPCanceled = "Teleport canceled: %s",
    TPMoved = "You Moved!",
    TPDamage = "Took Damage!",
    TPWeapon = "Switched Weapon!",
    TPYourHomes = "Your Homes: %s",
})
--[CREDIT TO: MediQ#9657 - his GitHub: github.com/Niobiyd]--
ix.lang.AddTable("russian", {
    /*
    --[You need to set these on the command itself]--
    TPSetHome = "Устанавливает точку телепорта к вашему дому.",
    TPDelHome = "Удаляет точку телепорта к вашему дому.",
    TPHome = "Телепортирует вас к точке вашего дома.",
    */
    TPSuccess = "Вы успешно перенесенны к вашей точке: %s",
    TPSuccessSet = "Вы успешно установили точку вашего дома: %s",
    TPSuccessDel = "Вы успешно удалили точку вашего дома: %s",
    TPSuccessDelAll = "Вы успешно удалили все точки ваших домов!",
    TPInProgress = "Вы уже телепортируете!",
    TPNoHome = "У вас нету активной точки телепорта: %s",
    TPTime = "Телепортация в: %s",
    TPLimit = "Лимит достигнут: %s",
    TPCanceled = "Телепорт отменен: %s",
    TPMoved = "Вы были передвижены!",
    TPDamage = "Получен урон!",
    TPWeapon = "Оружие переключено!",
    TPYourHomes = "Ваши активные точки домов: %s",
})

-----[CONFIG STUFF]-----
PLUGIN.defaultHome = "home"
PLUGIN.defaultSwep = "ix_keys" --change this to something that the player always has on him and cant be abused, like: keys, hands etc.

ix.config.Add("AdminOnly", true, "Set to 'true' if all HOMES commands should be admin only.", nil, {
    category = "Homes"
},true)
ix.config.Add("DamageCheck", true, "Set to 'true' if you want home teleports to be canceled when the player receives damage of any kind.", nil, {
    category = "Homes"
},true)
ix.config.Add("MovementCheck", true, "Set to 'true' if you want home teleports to be canceled when the player moves.", nil, {
    category = "Homes"
},true)
ix.config.Add("WeaponCheck", true, "Set to 'true' if you want home teleports to be canceled when the player switches his weapon. [will force the players current weapon to default (set in the plugin file)]", nil, {
    category = "Homes"
},true)
ix.config.Add("TeleportTime", 5, "Sets the time it takes to teleport to a home.", nil, {
    data = {min = 0, max = 120},
    category = "Homes"
},true)
ix.config.Add("HomeLimit", 5, "Sets the limit of homes a single player can have. This will not remove existing homes. [Set to 0 to remove limit]", nil, {
    data = {min = 1, max = 15},
    category = "Homes"
},true)


if (SERVER) then
    
    function PLUGIN.TimerID(client)
        if IsValid(client) then return "Home_Delay_" .. client:UserID() end
    end

    function PLUGIN.Timer(id, rep, repfunc, func)
        local curRep = 1
        timer.Create(id, 1, rep, function() 
            if curRep != rep then --not really necessary but a tiny bit convenient for the notify
                repfunc(id, curRep, rep)
            else
                func()
            end
            curRep = curRep + 1
        end) 
    end
    
    function PLUGIN.HomeTP(client,data)
        local function TP()
            --add stuck protection here
            client:SetPos(data["pos"])
            client:SetEyeAngles(data["ang"])
            ix.util.Notify(L("TPSuccess", client, data["name"]) , client)
        end
        
        --this, in combination with the switchweapons hook, should fix most major problems that would arise with the tp and weapons (if the check is enabled)
        if ix.config.Get("WeaponCheck", true) then
            client:SelectWeapon(PLUGIN.defaultSwep)
        end

        if ix.config.Get("TeleportTime", 5) == (nil or 0) then
            TP()
        else
            local oldpos = client:GetPos()
            PLUGIN.Timer(PLUGIN.TimerID(client), ix.config.Get("TeleportTime", 5),function(id, curRep, rep)
                ix.util.Notify(L("TPTime", client, (rep - curRep)), client)
                if ix.config.Get("MovementCheck", true) and client:GetPos() != oldpos then --easy "movement" check
                    timer.Remove(id)
                    ix.util.Notify(L("TPCanceled", client, L("TPMoved", client)), client)
                end
            end, function()
                TP()
            end)
        end
    end

    -----[HOOK STUFF]-----
    function PLUGIN:PlayerSwitchWeapon(client)
        if ix.config.Get("WeaponCheck", true) and timer.Exists(PLUGIN.TimerID(client)) then
            timer.Remove(PLUGIN.TimerID(client))
            ix.util.Notify(L("TPCanceled", client, L("TPWeapon", client)), client)
        end
    end

    function PLUGIN:PostEntityTakeDamage( ent, dmg, took )
        if took and ix.config.Get("DamageCheck", true) and ent:IsPlayer() and timer.Exists(PLUGIN.TimerID(ent)) then
            timer.Remove(PLUGIN.TimerID(ent))
            ix.util.Notify(L("TPCanceled", ent, L("TPDamage", ent)), ent)
        end
    end

end

-----[COMMANDS]-----
ix.command.Add("sethome", {
    description = "Sets a home[TP] at your current location", --Lanugage function need a player to localize said player's language settings, DM me if you know another way.
    adminOnly = ix.config.Get("AdminOnly", true),
    privilege = "Homes", --Not sure how this + adminOnly will affect things
    arguments = {bit.bor(ix.type.string, ix.type.optional)},
    argumentNames = {"Name"},
    OnRun = function(self, client, homeName)
        local char = client:GetCharacter()
        local homes = char:GetData("homes") or {}
        homeName = homeName or PLUGIN.defaultHome
        local indexName = string.lower(homeName)

        local homeLimit = ix.config.Get("HomeLimit", 5)
        if !homes[indexName] and homeLimit != 0 and table.Count(homes) >= homeLimit then
            ix.util.Notify(L("TPLimit", client, homeLimit), client)
            return
        end

        homes[indexName] = {["pos"] = client:GetPos(), ["ang"] = client:EyeAngles()}
        char:SetData("homes", homes)
        ix.util.Notify(L("TPSuccessSet", client, homeName), client)
    end
})

ix.command.Add("delhome", {
    description = "Deletes the specefied home ['all' will delete ALL homes]", --Lanugage function need a player to localize said player's language settings, DM me if you know another way.
    adminOnly = ix.config.Get("AdminOnly", true),
    privilege = "Homes", --Not sure how this + adminOnly will affect things
    arguments = {bit.bor(ix.type.string, ix.type.optional)},
    argumentNames = {"Name"},
    OnRun = function(self, client, homeName)
        local char = client:GetCharacter()
        local homes = char:GetData("homes") or {}
        homeName = homeName or PLUGIN.defaultHome
        local indexName = string.lower(homeName)
        if indexName == "all" then
            homes = {}
            char:SetData("homes", homes)
            ix.util.Notify(L("TPSuccessDelAll", client), client)
        elseif homes[indexName] then
            homes[indexName] = nil
            char:SetData("homes", homes)
            ix.util.Notify(L("TPSuccessDel", client, homeName), client)
        else
            ix.util.Notify(L("TPNoHome", client, homeName), client)
        end
    end
})

ix.command.Add("home", {
    description = "Teleports you to your home(s)", --Lanugage function need a player to localize said player's language settings, DM me if you know another way.
    adminOnly = ix.config.Get("AdminOnly", true),
    privilege = "Homes", --Not sure how this + adminOnly will affect things
    arguments = {bit.bor(ix.type.string, ix.type.optional)},
    argumentNames = {"Name"},
    OnRun = function(self, client, homeName)
        if timer.Exists(PLUGIN.TimerID(client)) then 
            ix.util.Notify(L("TPInProgress", client), client)
            return
        end

        local char = client:GetCharacter()
        local homes = char:GetData("homes") or {}
        homeName = homeName or PLUGIN.defaultHome
        local indexName = string.lower(homeName)

        local data = homes[indexName]
        if data then
            data["name"] = homeName -- T_T
            PLUGIN.HomeTP(client,data) -- i hate using timers, dm me if you have a better way of doing this
        else
            ix.util.Notify(L("TPNoHome", client, homeName), client)
        end
    end
})

ix.command.Add("homelist", {
    description = "Teleports you to your home(s)", --Lanugage function need a player to localize said player's language settings, DM me if you know another way.
    adminOnly = ix.config.Get("AdminOnly", true),
    privilege = "Homes", --Not sure how this + adminOnly will affect things
    OnRun = function(self, client, args)
        local char = client:GetCharacter()
        local homes = char:GetData("homes") or {}

        client:ChatNotify( L("TPYourHomes", client, table.Count(homes) or 0) )
        local curRun = 1
        for k,v in pairs(homes) do
            client:ChatNotify("      " .. curRun .. ": " .. k)
            curRun = curRun + 1
        end
    end
})
