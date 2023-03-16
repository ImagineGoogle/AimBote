if shared.AimBoteShouldLoad == false then
    shared.AimBoteShouldLoad = true
    return
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GuiLibrary = isfile("GuiLibrary.txt") and shared.AimBoteDeveloper and loadstring(readfile("GuiLibrary.txt"))() or loadstring(game:HttpGet("https://raw.githubusercontent.com/ImagineGoogle/AimBote/main/GuiLibrary.lua"))()

GuiLibrary.Init()

local function runFunction(func)
    func()
end

local queueonteleport = syn and syn.queue_on_teleport or queue_on_teleport or function(str) end
local localPlayer = Players.LocalPlayer
local bedwars

runFunction(function() -- Queue On Teleport
    local teleportScript = [[
        if shared.AimBoteDeveloper then 
            loadstring(readfile("MainScript.txt"))() 
        else 
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ImagineGoogle/AimBote/MainScript.lua"))() 
        end
    ]]
    if shared.AimBoteDeveloper then
        teleportScript = "shared.AimBoteDeveloper = true\n" .. teleportScript
    end
    queueonteleport(teleportScript)
end)

runFunction(function() -- Knit and modules
    local KnitGotten, KnitClient
	repeat
		KnitGotten, KnitClient = pcall(function()
			return debug.getupvalue(require(localPlayer.PlayerScripts.TS.knit).setup, 6)
		end)
		if KnitGotten then break end
		task.wait()
	until KnitGotten
	repeat task.wait() until debug.getupvalue(KnitClient.Start, 1)

    bedwars = {
        SprintController = KnitClient.Controllers.SprintController,
        KnockbackUtil = require(ReplicatedStorage.TS.damage["knockback-util"]).KnockbackUtil,
    }
end)

runFunction(function() -- Windows
    GuiLibrary.CreateWindow {Name = "Combat"}
    GuiLibrary.CreateWindow {Name = "Movement"}
    GuiLibrary.CreateWindow {Name = "Render"}
    GuiLibrary.CreateWindow {Name = "Utility"}
    GuiLibrary.CreateWindow {Name = "Miscellaneous"}
end)

runFunction(function() -- Uninject
    GuiLibrary.CreateModule {
        Window = "Miscellaneous",
        Name = "Uninject",
        Toggleable = false,
        Function = function(callback)
            if callback then
                GuiLibrary.Uninject()
            end
        end
    }
end)

runFunction(function() -- Sprint
    local oldSprintFunction

    local Sprint
    Sprint = GuiLibrary.CreateModule {
        Window = "Movement",
        Name = "Sprint",
        Toggleable = true,
        Function = function(callback)
            if callback then
                oldSprintFunction = bedwars.SprintController.stopSprinting
                bedwars.SprintController.stopSprinting = function(...)
                    local originalCall = oldSprintFunction(...)
                    bedwars.SprintController:startSprinting()
                    return originalCall
                end
                table.insert(Sprint.Api.Connections, localPlayer.CharacterAdded:Connect(function(character)
                    character:WaitForChild("Humanoid", 9e9)
                    task.wait(0.5)
                    bedwars.SprintController:stopSprinting()
                end))
                task.spawn(function()
                    bedwars.SprintController:startSprinting()
                end)
            else
                bedwars.SprintController.stopSprinting = oldSprintFunction
                bedwars.SprintController:stopSprinting()
            end
        end
    }
end)

runFunction(function() -- Velocity
	local VelocityX = {Value = 100}
	local VelocityY = {Value = 100}
	local applyKnockback

    local Velocity = GuiLibrary.CreateModule {
        Window = "Combat",
        Name = "Velocity",
        Toggleable = true,
        Function = function(callback)
			if callback then
				applyKnockback = bedwars.KnockbackUtil.applyKnockback
				bedwars.KnockbackUtil.applyKnockback = function(root, mass, dir, knockback, ...)
					knockback = knockback or {}
					if VelocityX.Value == 0 and VelocityY.Value == 0 then return end
					knockback.horizontal = (knockback.horizontal or 1) * (VelocityX.Value / 100)
					knockback.vertical = (knockback.vertical or 1) * (VelocityY.Value / 100)
					return applyKnockback(root, mass, dir, knockback, ...)
				end
			else
				bedwars.KnockbackUtil.applyKnockback = applyKnockback
			end
		end,
    }
    VelocityX = Velocity.Api.CreateSlider {
        Name = "X",
        DefaultValue = 0,
        MaxValue = 100,
        MinValue = 0,
        Function = function() end
    }
    VelocityY = Velocity.Api.CreateSlider {
        Name = "Y",
        DefaultValue = 0,
        MaxValue = 100,
        MinValue = 0,
        Function = function() end
    }
end)

GuiLibrary.LoadModules()
