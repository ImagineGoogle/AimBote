if not game:IsLoaded() then
    game.Loaded:Wait()
end

if shared.AimBoteInjected then
    error("[AimBote]: Already injected.")
end
shared.AimBoteInjected = true

local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local GuiLibrary = {
    Settings = {
        Theme = Color3.fromRGB(255, 160, 0),
        ToggleKey = Enum.KeyCode.RightShift
    },
    Modules = {},
    Windows = {}
}
local directoryName = "aimbote"
local currentSaveName = string.format("%s.json", tostring(game.GameId))

local function saveModules()
    if not isfolder(directoryName) then
        makefolder(directoryName)
    end
    if not isfolder(string.format("%s/Saves", directoryName)) then
        makefolder(string.format("%s/Saves", directoryName))
    end
    writefile(string.format("%s/Saves/%s", directoryName, currentSaveName), HttpService:JSONEncode(GuiLibrary.Modules))
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
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 25)
    UIListLayout.Parent = ClickGui

    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if not gameProcessedEvent and input.KeyCode == GuiLibrary.Settings.ToggleKey then
            ClickGui.Visible = not ClickGui.Visible
        end
    end)
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
    Frame.Parent = GuiLibrary.MainGui

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

    table.insert(GuiLibrary.Windows, Frame)
    return Frame
end

return GuiLibrary
