if not game:IsLoaded() then
    game.Loaded:Wait()
end

if shared.AimBoteInjected then
    error("[AimBote]: Already injected.")
end
shared.AimBoteInjected = true

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local mouse = game:GetService("Players").LocalPlayer:GetMouse()

local GuiLibrary = {
    Settings = {
        Theme = Color3.fromRGB(255, 160, 0),
        ToggleKey = Enum.KeyCode.RightShift
    },
    TemporaryObjects = {},
    Connections = {},
    Modules = {},
    Windows = {}
}
local directoryName = "aimbote"
local currentSaveName = string.format("%s.json", tostring(game.GameId))

local function saveModules()
    local saveTable = GuiLibrary.Modules
    for _, module in pairs(saveTable) do
        module.Api = nil
        for _, option in pairs(module.Options) do
            for _, theOption in pairs(option) do
                theOption.Api = nil
            end
        end
    end

    if not isfolder(directoryName) then
        makefolder(directoryName)
    end
    if not isfolder(string.format("%s/Saves", directoryName)) then
        makefolder(string.format("%s/Saves", directoryName))
    end
    writefile(string.format("%s/Saves/%s", directoryName, currentSaveName), HttpService:JSONEncode(saveTable))
end

local function loadModules()
    if isfile(string.format("%s/Saves/%s", directoryName, currentSaveName)) then
        GuiLibrary.Modules = HttpService:JSONDecode(readfile(string.format("%s/Saves/%s", directoryName, currentSaveName)))
    end
end

function GuiLibrary.Init()
    local function randomString()
		local randomlength = math.random(10, 100)
		local array = {}

		for i = 1, randomlength do
			array[i] = string.char(math.random(32, 126))
		end

		return table.concat(array)
	end

    local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = randomString()
	ScreenGui.DisplayOrder = 9999
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	ScreenGui.OnTopOfCoreBlur = true
	if gethui and (not KRNL_LOADED) then
		ScreenGui.Parent = gethui()
	elseif not is_sirhurt_closure and syn and syn.protect_gui then
		syn.protect_gui(ScreenGui)
		ScreenGui.Parent = CoreGui
	else
		ScreenGui.Parent = CoreGui
	end
	GuiLibrary.MainGui = ScreenGui

    local ClickGui = Instance.new("Frame")
    ClickGui.Name = "ClickGui"
    ClickGui.AnchorPoint = Vector2.new(0.5, 0.5)
    ClickGui.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ClickGui.BackgroundTransparency = 1.000
    ClickGui.Position = UDim2.new(0.5, 0, 0.5, 0)
    ClickGui.Size = UDim2.new(0.980000019, 0, 0.970000029, 0)
    ClickGui.Visible = false
    ClickGui.Parent = ScreenGui

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 25)
    UIListLayout.Parent = ClickGui

    table.insert(GuiLibrary.Connections, UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if not gameProcessedEvent and input.KeyCode == GuiLibrary.Settings.ToggleKey then
            ClickGui.Visible = not ClickGui.Visible
            RunService:SetRobloxGuiFocused(ClickGui.Visible)
        end
    end))
end

function GuiLibrary.Uninject()
    for _, connection: RBXScriptConnection in ipairs(GuiLibrary.Connections) do
        connection:Disconnect()
    end
    for _, module in pairs(GuiLibrary.Modules) do
        if module.Enabled then
            module.Api.Function(false)
        end
        for _, connection in ipairs(module.Api.Connections) do
            if connection.Disconnect then pcall(function() connection:Disconnect() end) continue end
            if connection.disconnect then pcall(function() connection:disconnect() end) continue end
        end
        table.clear(module.Api.Connections)
        for _, toggle in pairs(module.Options.Toggles) do
            for _, connection in ipairs(toggle.Api.Connections) do
                if connection.Disconnect then pcall(function() connection:Disconnect() end) continue end
                if connection.disconnect then pcall(function() connection:disconnect() end) continue end
            end
        end
    end
    if GuiLibrary.MainGui.ClickGui.Visible then
        RunService:SetRobloxGuiFocused(false)
    end
    GuiLibrary.MainGui:Destroy()
    for _, obj in ipairs(GuiLibrary.TemporaryObjects) do
        obj:Destroy()
    end

    shared.AimBoteInjected = false
end

function GuiLibrary.CreateWindow(configuration: table): Frame
    local Frame = Instance.new("Frame")
    local UIListLayout = Instance.new("UIListLayout")
    local WindowTitle = Instance.new("TextLabel")
    local UIPadding = Instance.new("UIPadding")

    Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Frame.BackgroundTransparency = 1.000
    Frame.Size = UDim2.new(0, 200, 0, 1)
    Frame.AutomaticSize = Enum.AutomaticSize.Y
    Frame.Name = configuration.Name
    Frame.Parent = GuiLibrary.MainGui.ClickGui

    UIListLayout.Parent = Frame

    WindowTitle.Name = "!WindowTitle"
    WindowTitle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    WindowTitle.BackgroundTransparency = 0.300
    WindowTitle.BorderSizePixel = 0
    WindowTitle.LayoutOrder = -1
    WindowTitle.Size = UDim2.new(1, 0, 0, 35)
    WindowTitle.Font = Enum.Font.SourceSans
    WindowTitle.Text = configuration.Name
    WindowTitle.TextColor3 = GuiLibrary.Settings.Theme
    WindowTitle.TextSize = 25.000
    WindowTitle.TextXAlignment = Enum.TextXAlignment.Left
    WindowTitle.Parent = Frame

    UIPadding.PaddingLeft = UDim.new(0, 10)
    UIPadding.Parent = WindowTitle

    GuiLibrary.Windows[configuration.Name] = Frame
    return Frame
end

function GuiLibrary.CreateModule(configuration: table): table
    local Module = Instance.new("Frame")
    local Toggle = Instance.new("TextButton")
    local UIPadding = Instance.new("UIPadding")
    local Separator = Instance.new("Frame")
    local OptionsMenu = Instance.new("Frame")

    Module.Name = configuration.Name
    Module.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Module.BackgroundTransparency = 1.000
    Module.Size = UDim2.new(1, 0, 0, 35)
    Module.Parent = GuiLibrary.Windows[configuration.Window]

    Toggle.Name = "Toggle"
    Toggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Toggle.BackgroundTransparency = 0.300
    Toggle.BorderSizePixel = 0
    Toggle.Size = UDim2.new(1, 0, 0, 35)
    Toggle.AutoButtonColor = false
    Toggle.Font = Enum.Font.SourceSans
    Toggle.Text = configuration.Name
    Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.TextSize = 20.000
    Toggle.TextXAlignment = Enum.TextXAlignment.Left
    Toggle.Parent = Module

    UIPadding.PaddingLeft = UDim.new(0, 10)
    UIPadding.Parent = Toggle

    Separator.Name = "Separator"
    Separator.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Separator.BackgroundTransparency = 0.500
    Separator.BorderSizePixel = 0
    Separator.Size = UDim2.new(1, 0, 0, 1)
    Separator.Parent = Module

    OptionsMenu.Name = "OptionsMenu"
    OptionsMenu.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    OptionsMenu.BackgroundTransparency = 1.000
    OptionsMenu.Position = UDim2.new(0, 0, 0, 35)
    OptionsMenu.Size = UDim2.new(1, 0, 0, 1)
    OptionsMenu.AutomaticSize = Enum.AutomaticSize.Y
    OptionsMenu.Visible = false
    OptionsMenu.Parent = Module

    local layout = Instance.new("UIListLayout")
    layout.Parent = OptionsMenu
    layout.SortOrder = Enum.SortOrder.Name

    GuiLibrary.Modules[configuration.Name] = {
        Api = {
            Connections = {},
            Function = configuration.Function
        },
        Options = {
            Toggles = {},
            Sliders = {}
        },
        Enabled = false,
    }
    local module = GuiLibrary.Modules[configuration.Name]

    function module.Api.Toggle()
        if configuration.Toggleable == nil or configuration.Toggleable == true then
            module.Enabled = not module.Enabled
            configuration.Function(module.Enabled)
            Toggle.BackgroundColor3 = module.Enabled and GuiLibrary.Settings.Theme or Color3.fromRGB(0, 0, 0)
            if module.Enabled == false then
                for _, connection in ipairs(module.Api.Connections) do
                    if connection.Disconnect then pcall(function() connection:Disconnect() end) continue end
                    if connection.disconnect then pcall(function() connection:disconnect() end) continue end
                end
                table.clear(module.Api.Connections)
            end
        else
            configuration.Function(true)
        end
    end

    Toggle.MouseButton1Down:Connect(function()
        module.Api.Toggle()
    end)
    Toggle.MouseButton2Down:Connect(function()
        OptionsMenu.Visible = not OptionsMenu.Visible
    end)

    function module.Api.CreateToggle(toggleConfiguration: table): table
        local ToggleFrame = Instance.new("Frame")
        local TextLabel = Instance.new("TextLabel")
        local ToggleUIPadding = Instance.new("UIPadding")
        local Toggle_2 = Instance.new("TextButton")
        local Indicator = Instance.new("Frame")
        local UICorner = Instance.new("UICorner")
        local UICorner_2 = Instance.new("UICorner")

        ToggleFrame.Name = toggleConfiguration.Name
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        ToggleFrame.BackgroundTransparency = 0.300
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
        ToggleFrame.Position = UDim2.fromOffset(0, Module.Size)
        ToggleFrame.Parent = OptionsMenu

        TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.BackgroundTransparency = 1.000
        TextLabel.Size = UDim2.new(0, 200, 1, 0)
        TextLabel.Font = Enum.Font.SourceSans
        TextLabel.Text = toggleConfiguration.Name
        TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.TextSize = 15.000
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.Parent = ToggleFrame

        ToggleUIPadding.Parent = TextLabel
        ToggleUIPadding.PaddingLeft = UDim.new(0, 10)

        Toggle_2.Name = "ToggleButton"
        Toggle_2.AnchorPoint = Vector2.new(0, 0.5)
        Toggle_2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Toggle_2.BorderSizePixel = 0
        Toggle_2.Position = UDim2.new(0, 157, 0.5, 0)
        Toggle_2.Size = UDim2.new(0, 35, 0, 15)
        Toggle_2.AutoButtonColor = false
        Toggle_2.Font = Enum.Font.SourceSans
        Toggle_2.Text = ""
        Toggle_2.TextColor3 = Color3.fromRGB(0, 0, 0)
        Toggle_2.TextSize = 14.000
        Toggle_2.Parent = ToggleFrame

        Indicator.Name = "Indicator"
        Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Indicator.BorderSizePixel = 0
        Indicator.Size = UDim2.new(0, 15, 0, 15)
        Indicator.Parent = Toggle_2

        UICorner.Parent = Indicator
        UICorner_2.Parent = Toggle_2

        module.Options.Toggles[toggleConfiguration.Name] = {
            Api = {
                Connections = {},
                Function = toggleConfiguration.Function
            },
            Enabled = false,
        }
        local toggle = module.Options.Toggles[toggleConfiguration.Name]

        function toggle.Api.Toggle()
            toggle.Enabled = not toggle.Enabled
            toggleConfiguration.Function(toggle.Enabled)
            TweenService:Create(Indicator, TweenInfo.new(0.25), {Position = toggle.Enabled and UDim2.fromOffset(20, 0) or UDim2.fromOffset(0, 0)}):Play()
            TweenService:Create(Toggle_2, TweenInfo.new(0.25), {BackgroundColor3 = toggle.Enabled and GuiLibrary.Settings.Theme or Color3.fromRGB(0, 0, 0)}):Play()

            if module.Enabled == false then
                for _, connection in ipairs(toggle.Api.Connections) do
                    if connection.Disconnect then pcall(function() connection:Disconnect() end) continue end
                    if connection.disconnect then pcall(function() connection:disconnect() end) continue end
                end
                table.clear(toggle.Api.Connections)
            end
        end

        Toggle_2.MouseButton1Down:Connect(function()
            toggle.Api.Toggle()
        end)
    end

    function module.Api.CreateSlider(sliderConfiguration: table): table
        local Slider = Instance.new("Frame")
        local TextLabel = Instance.new("TextLabel")
        local UIPadding_2 = Instance.new("UIPadding")
        local SliderLine = Instance.new("Frame")
        local SliderProgress = Instance.new("Frame")
        local Indicator = Instance.new("TextButton")
        local UICorner = Instance.new("UICorner")
        local UICorner_2 = Instance.new("UICorner")

        Slider.Name = sliderConfiguration.Name
        Slider.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        Slider.BackgroundTransparency = 0.300
        Slider.BorderSizePixel = 0
        Slider.Size = UDim2.new(1, 0, 0, 30)
        Slider.Parent = OptionsMenu

        TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.BackgroundTransparency = 1.000
        TextLabel.Size = UDim2.new(0, 200, 1, 0)
        TextLabel.Font = Enum.Font.SourceSans
        TextLabel.Text = string.format("%s (%s)", sliderConfiguration.Name, sliderConfiguration.DefaultValue)
        TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.TextSize = 15.000
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.Parent = Slider

        UIPadding_2.PaddingLeft = UDim.new(0, 10)
        UIPadding_2.Parent = TextLabel

        SliderLine.Name = "SliderLine"
        SliderLine.Active = true
        SliderLine.AnchorPoint = Vector2.new(0, 0.5)
        SliderLine.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        SliderLine.BorderSizePixel = 0
        SliderLine.Position = UDim2.new(0, 92, 0.5, 0)
        SliderLine.Selectable = true
        SliderLine.Size = UDim2.new(0, 100, 0, 5)
        SliderLine.Parent = Slider

        SliderProgress.Name = "SliderProgress"
        SliderProgress.BackgroundColor3 = GuiLibrary.Settings.Theme
        SliderProgress.BorderSizePixel = 0
        SliderProgress.Position = UDim2.new(0, 0, 0, 0)
        SliderProgress.Size = UDim2.new(sliderConfiguration.DefaultValue / sliderConfiguration.MaxValue, 0, 1, 0)
        SliderProgress.Parent = SliderLine

        Indicator.Name = "Indicator"
        Indicator.Text = ""
        Indicator.AnchorPoint = Vector2.new(0, 0.5)
        Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Indicator.BorderSizePixel = 0
        Indicator.Position = UDim2.new(0, 0, 0.5, 0)
        Indicator.Size = UDim2.new(0, 15, 0, 15)
        Indicator.AutoButtonColor = false
        Indicator.Parent = SliderLine

        UICorner.Parent = Indicator
        UICorner_2.Parent = SliderLine

        module.Options.Sliders[sliderConfiguration.Name] = {
            Api = {
                Function = sliderConfiguration.Function
            },
            Value = sliderConfiguration.DefaultValue,
        }
        local slider = module.Options.Sliders[sliderConfiguration.Name]

        function slider.Api.SetValue(newValue)
            slider.Value = newValue
            slider.Api.Function(newValue)
            TextLabel.Text = string.format("%s (%s)", sliderConfiguration.Name, slider.Value)
        end
        local sliderAbsolutePos = SliderLine.AbsolutePosition
        local sliderAbsoluteSize = SliderLine.AbsoluteSize
        local minXPos = sliderAbsolutePos.X
        local maxXPos = sliderAbsolutePos.X + sliderAbsoluteSize.X
        local range = sliderConfiguration.MaxValue - sliderConfiguration.MinValue

        local sliderConnection
        local endInputConnection

        local function sliderMoved(value)
            Indicator.Position = UDim2.new(0, SliderProgress.AbsoluteSize.X - (Indicator.Size.X.Offset / 2), 0.5, 0)
            slider.Api.SetValue(math.round(value))
        end

        sliderMoved(SliderProgress.AbsoluteSize.X / sliderAbsoluteSize.X * range + sliderConfiguration.MinValue)

        Indicator.MouseButton1Down:Connect(function()
            local function mouseMoved()
                if mouse.X < minXPos then
                    SliderProgress.Size = UDim2.new(0, 0, 1, 0)
                elseif mouse.X > maxXPos then
                    SliderProgress.Size = UDim2.new(1, 0, 1, 0)
                else
                    SliderProgress.Size = UDim2.new(0, mouse.X - minXPos, 1, 0)
                end
                sliderMoved(SliderProgress.AbsoluteSize.X / sliderAbsoluteSize.X * range + sliderConfiguration.MinValue)
            end
            mouseMoved()
            sliderConnection = mouse.Move:Connect(mouseMoved)

            endInputConnection = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliderConnection:Disconnect()
                    endInputConnection:Disconnect()
                end
            end)
        end)

        return slider.Api
    end

    return module.Api
end

shared.AimBoteGuiLibrary = GuiLibrary
return GuiLibrary
