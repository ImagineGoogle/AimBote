if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")

local GuiLibrary = isfile("GuiLibrary.txt") and loadstring(readfile("GuiLibrary.txt"))() or loadstring(game:HttpGet("https://raw.githubusercontent.com/ImagineGoogle/AimBote/main/GuiLibrary.lua"))()

GuiLibrary.Init()

local function runFunction(func)
    func()
end

local localPlayer = Players.LocalPlayer
local bedwars

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
    }
end)

runFunction(function() -- Windows
    GuiLibrary.CreateWindow {Name = "Combat"}
    GuiLibrary.CreateWindow {Name = "Movement"}
    GuiLibrary.CreateWindow {Name = "Render"}
    GuiLibrary.CreateWindow {Name = "Utility"}
    GuiLibrary.CreateWindow {Name = "Miscellaneous"}
end)

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
                table.insert(Sprint.Connections, localPlayer.CharacterAdded:Connect(function(character)
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
    local Velocity = GuiLibrary.CreateModule {
        Window = "Combat",
        Name = "Velocity",
        Toggleable = true,
        Function = function(callback)
            if callback then
    
            end
        end
    }
    Velocity.CreateSlider {
        Name = "X",
        DefaultValue = 0,
        MaxValue = 100,
        MinValue = 0,
        Function = function() end
    }
    Velocity.CreateSlider {
        Name = "Y",
        DefaultValue = 0,
        MaxValue = 100,
        MinValue = 0,
        Function = function() end
    }
end)
