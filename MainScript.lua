local GuiLibrary = isfile("GuiLibrary.txt") and loadstring(readfile("GuiLibrary.txt"))() or loadstring(game:HttpGet("https://raw.githubusercontent.com/ImagineGoogle/AimBote/main/GuiLibrary.lua"))()

GuiLibrary.Init()

GuiLibrary.CreateWindow {Name = "Combat"}
GuiLibrary.CreateWindow {Name = "Movement"}
GuiLibrary.CreateWindow {Name = "Render"}
GuiLibrary.CreateWindow {Name = "Utility"}
GuiLibrary.CreateWindow {Name = "Miscellaneous"}

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

GuiLibrary.CreateModule {
    Window = "Movement",
    Name = "Sprint",
    Toggleable = true,
    Function = function(callback)
        if callback then
            print("Enabled")
        else
            print("Disabled")
        end
    end
}
