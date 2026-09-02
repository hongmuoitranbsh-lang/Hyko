-- ╔══════════════════════════════════════════════════════════════╗
-- ║        Hyko v1.1 - Glassmorphism Server Hop UI               ║
-- ╚══════════════════════════════════════════════════════════════╝

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- ═══════════════════════════════════════════════════════════════
-- SCREEN GUI SETUP
-- ═══════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HykoHopUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game.CoreGui
else
    ScreenGui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or game.CoreGui
end

-- ═══════════════════════════════════════════════════════════════
-- COLOR PALETTE (Glass & Neon)
-- ═══════════════════════════════════════════════════════════════
local Theme = {
    GlassBg = Color3.fromRGB(15, 15, 25),
    GlassTrans = 0.25,
    Surface = Color3.fromRGB(255, 255, 255),
    SurfaceTrans = 0.94,
    AccentGlow = Color3.fromRGB(99, 102, 241), -- Electric Indigo
    AccentHover = Color3.fromRGB(129, 140, 248),
    Success = Color3.fromRGB(52, 211, 153),   -- Emerald
    Danger = Color3.fromRGB(248, 113, 113),   -- Rose
    Warning = Color3.fromRGB(251, 191, 36),   -- Amber
    TextMain = Color3.fromRGB(243, 244, 246),
    TextSub = Color3.fromRGB(156, 163, 175),
    Border = Color3.fromRGB(255, 255, 255),
    BorderTrans = 0.85
}

-- ═══════════════════════════════════════════════════════════════
-- MAIN FRAME (Glass Canvas)
-- ═══════════════════════════════════════════════════════════════
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Theme.GlassBg
MainFrame.BackgroundTransparency = Theme.GlassTrans
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -120)
MainFrame.Size = UDim2.new(0, 300, 0, 240)
MainFrame.Active = true
MainFrame.ClipsDescendants = false

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 16)

-- Glass Border & Inner Glow
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Theme.Border
MainStroke.Thickness = 1.2
MainStroke.Transparency = Theme.BorderTrans

-- Neon Glow Shadow Effect
local GlowShadow = Instance.new("ImageLabel", MainFrame)
GlowShadow.Name = "GlowShadow"
GlowShadow.AnchorPoint = Vector2.new(0.5, 0.5)
GlowShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
GlowShadow.Size = UDim2.new(1, 30, 1, 30)
GlowShadow.BackgroundTransparency = 1
GlowShadow.Image = "rbxassetid://1316045217"
GlowShadow.ImageColor3 = Theme.AccentGlow
GlowShadow.ImageTransparency = 0.75
GlowShadow.ZIndex = 0

MainFrame.ZIndex = 1

-- ═══════════════════════════════════════════════════════════════
-- HEADER / TITLE BAR
-- ═══════════════════════════════════════════════════════════════
local Header = Instance.new("Frame", MainFrame)
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundTransparency = 1

local TitleText = Instance.new("TextLabel", Header)
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Position = UDim2.new(0, 16, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "Hyko v1.1 <font color=\"rgb(129, 140, 248)\">•</font> Server Hop"
TitleText.RichText = true
TitleText.TextColor3 = Theme.TextMain
TitleText.TextSize = 13
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Name = "CloseBtn"
CloseBtn.Position = UDim2.new(1, -32, 0, 10)
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.BackgroundColor3 = Theme.Surface
CloseBtn.BackgroundTransparency = Theme.SurfaceTrans
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.TextSub
CloseBtn.TextSize = 11
CloseBtn.AutoButtonColor = false

local CloseCorner = Instance.new("UICorner", CloseBtn)
CloseCorner.CornerRadius = UDim.new(0, 8)

CloseBtn.MouseButton1Click:Connect(function() 
    ScreenGui:Destroy() 
end)

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.5,
        TextColor3 = Theme.Danger
    }):Play()
end)

CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {
        BackgroundTransparency = Theme.SurfaceTrans,
        TextColor3 = Theme.TextSub
    }):Play()
end)

-- Divider Line
local Divider = Instance.new("Frame", MainFrame)
Divider.Position = UDim2.new(0, 16, 0, 42)
Divider.Size = UDim2.new(1, -32, 0, 1)
Divider.BackgroundColor3 = Theme.Border
Divider.BackgroundTransparency = 0.9
Divider.BorderSizePixel = 0

-- ═══════════════════════════════════════════════════════════════
-- CONTENT AREA
-- ═══════════════════════════════════════════════════════════════
local Content = Instance.new("Frame", MainFrame)
Content.Position = UDim2.new(0, 16, 0, 50)
Content.Size = UDim2.new(1, -32, 1, -58)
Content.BackgroundTransparency = 1

-- Live Player Card
local InfoCard = Instance.new("Frame", Content)
InfoCard.Size = UDim2.new(1, 0, 0, 36)
InfoCard.BackgroundColor3 = Theme.Surface
InfoCard.BackgroundTransparency = Theme.SurfaceTrans

local InfoCorner = Instance.new("UICorner", InfoCard)
InfoCorner.CornerRadius = UDim.new(0, 10)

local InfoStroke = Instance.new("UIStroke", InfoCard)
InfoStroke.Color = Theme.Border
InfoStroke.Transparency = 0.92

local NowLabel = Instance.new("TextLabel", InfoCard)
NowLabel.Size = UDim2.new(1, -20, 1, 0)
NowLabel.Position = UDim2.new(0, 10, 0, 0)
NowLabel.BackgroundTransparency = 1
NowLabel.Font = Enum.Font.GothamMedium
NowLabel.Text = "Current Players: <font color=\"rgb(52, 211, 153)\">0</font>"
NowLabel.RichText = true
NowLabel.TextColor3 = Theme.TextMain
NowLabel.TextSize = 12
NowLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Status Banner
local StatusLabel = Instance.new("TextLabel", Content)
StatusLabel.Position = UDim2.new(0, 0, 0, 42)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "System ready"
StatusLabel.TextColor3 = Theme.TextSub
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Threshold Input Card
local InputCard = Instance.new("Frame", Content)
InputCard.Position = UDim2.new(0, 0, 0, 68)
InputCard.Size = UDim2.new(1, 0, 0, 38)
InputCard.BackgroundColor3 = Theme.Surface
InputCard.BackgroundTransparency = Theme.SurfaceTrans

local InputCorner = Instance.new("UICorner", InputCard)
InputCorner.CornerRadius = UDim.new(0, 10)

local InputStroke = Instance.new("UIStroke", InputCard)
InputStroke.Color = Theme.Border
InputStroke.Transparency = 0.92

local MaxLabel = Instance.new("TextLabel", InputCard)
MaxLabel.Position = UDim2.new(0, 10, 0, 0)
MaxLabel.Size = UDim2.new(1, -60, 1, 0)
MaxLabel.BackgroundTransparency = 1
MaxLabel.Font = Enum.Font.GothamMedium
MaxLabel.Text = "Hop if players exceed:"
MaxLabel.TextColor3 = Theme.TextSub
MaxLabel.TextSize = 11
MaxLabel.TextXAlignment = Enum.TextXAlignment.Left

local MaxBox = Instance.new("TextBox", InputCard)
MaxBox.Position = UDim2.new(1, -42, 0.5, -12)
MaxBox.Size = UDim2.new(0, 32, 0, 24)
MaxBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MaxBox.BackgroundTransparency = 0.5
MaxBox.Font = Enum.Font.GothamBold
MaxBox.Text = "1"
MaxBox.TextColor3 = Theme.TextMain
MaxBox.TextSize = 12
MaxBox.ClearTextOnFocus = false

local BoxCorner = Instance.new("UICorner", MaxBox)
BoxCorner.CornerRadius = UDim.new(0, 6)

local BoxStroke = Instance.new("UIStroke", MaxBox)
BoxStroke.Color = Theme.AccentGlow
BoxStroke.Transparency = 0.6

-- Button Container
local BtnGrid = Instance.new("Frame", Content)
BtnGrid.Position = UDim2.new(0, 0, 0, 116)
BtnGrid.Size = UDim2.new(1, 0, 0, 42)
BtnGrid.BackgroundTransparency = 1

-- Hop Once Button
local HopBtn = Instance.new("TextButton", BtnGrid)
HopBtn.Size = UDim2.new(0.48, 0, 1, 0)
HopBtn.BackgroundColor3 = Theme.AccentGlow
HopBtn.BackgroundTransparency = 0.15
HopBtn.Font = Enum.Font.GothamBold
HopBtn.Text = "Hop Once"
HopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HopBtn.TextSize = 12
HopBtn.AutoButtonColor = false

local HopCorner = Instance.new("UICorner", HopBtn)
HopCorner.CornerRadius = UDim.new(0, 10)

local HopGlow = Instance.new("UIStroke", HopBtn)
HopGlow.Color = Theme.AccentGlow
HopGlow.Thickness = 1.5
HopGlow.Transparency = 0.5

-- Auto Hop Button
local AutoBtn = Instance.new("TextButton", BtnGrid)
AutoBtn.Position = UDim2.new(0.52, 0, 0, 0)
AutoBtn.Size = UDim2.new(0.48, 0, 1, 0)
AutoBtn.BackgroundColor3 = Theme.Surface
AutoBtn.BackgroundTransparency = Theme.SurfaceTrans
AutoBtn.Font = Enum.Font.GothamBold
AutoBtn.Text = "Auto Hop: OFF"
AutoBtn.TextColor3 = Theme.TextSub
AutoBtn.TextSize = 12
AutoBtn.AutoButtonColor = false

local AutoCorner = Instance.new("UICorner", AutoBtn)
AutoCorner.CornerRadius = UDim.new(0, 10)

local AutoStroke = Instance.new("UIStroke", AutoBtn)
AutoStroke.Color = Theme.Border
AutoStroke.Transparency = 0.92

-- Hover Effects
HopBtn.MouseEnter:Connect(function()
    TweenService:Create(HopBtn, TweenInfo.new(0.2), {
        BackgroundTransparency = 0,
        BackgroundColor3 = Theme.AccentHover
    }):Play()
end)

HopBtn.MouseLeave:Connect(function()
    TweenService:Create(HopBtn, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.15,
        BackgroundColor3 = Theme.AccentGlow
    }):Play()
end)

-- ═══════════════════════════════════════════════════════════════
-- SMOOTH DRAG SYSTEM
-- ═══════════════════════════════════════════════════════════════
local dragging, dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- HOPPING LOGIC
-- ═══════════════════════════════════════════════════════════════
local autoEnabled = false
local autoThread = nil

task.spawn(function()
    while ScreenGui.Parent do
        local count = #Players:GetPlayers()
        NowLabel.Text = "Current Players: <font color=\"rgb(52, 211, 153)\">" .. count .. "</font>"
        task.wait(1)
    end
end)

local function getRandomServer()
    local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local ok, raw = pcall(function() return game:HttpGet(url) end)
    if not ok or not raw or raw == "" then return nil end

    local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok2 or not data or not data.data or #data.data == 0 then return nil end

    local currentId = tostring(game.JobId)
    local candidates = {}
    for _, s in ipairs(data.data) do
        if s.id and tostring(s.id) ~= currentId then
            table.insert(candidates, tostring(s.id))
        end
    end

    if #candidates == 0 then return nil end
    return candidates[math.random(1, #candidates)]
end

local function hopOnce()
    local threshold = math.max(1, math.floor(tonumber(MaxBox.Text) or 1))
    local currentCount = #Players:GetPlayers()

    if currentCount <= threshold then
        StatusLabel.Text = "✓ Current server meets condition (" .. currentCount .. ")"
        StatusLabel.TextColor3 = Theme.Success
        return false
    end

    StatusLabel.Text = "Searching for a new server..."
    StatusLabel.TextColor3 = Theme.Warning
    task.wait(0.5)

    local serverId = getRandomServer()
    if not serverId then
        StatusLabel.Text = "Failed to fetch server list."
        StatusLabel.TextColor3 = Theme.Danger
        return false
    end

    StatusLabel.Text = "Teleporting..."
    StatusLabel.TextColor3 = Theme.AccentGlow
    task.wait(0.5)

    local ok, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(PlaceId, serverId, LocalPlayer)
    end)

    if not ok then
        StatusLabel.Text = "Error: " .. tostring(err):sub(1, 45)
        StatusLabel.TextColor3 = Theme.Danger
        return false
    end

    return true
end

HopBtn.MouseButton1Click:Connect(function()
    HopBtn.Active = false
    hopOnce()
    task.wait(2)
    HopBtn.Active = true
end)

AutoBtn.MouseButton1Click:Connect(function()
    autoEnabled = not autoEnabled

    if autoEnabled then
        AutoBtn.Text = "Auto Hop: ON"
        AutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        AutoBtn.BackgroundColor3 = Theme.Success
        AutoBtn.BackgroundTransparency = 0.2
        AutoStroke.Color = Theme.Success

        autoThread = task.spawn(function()
            while autoEnabled and ScreenGui.Parent do
                local threshold = math.max(1, math.floor(tonumber(MaxBox.Text) or 1))
                local count = #Players:GetPlayers()

                if count <= threshold then
                    StatusLabel.Text = "✓ " .. count .. " players online. Waiting..."
                    StatusLabel.TextColor3 = Theme.Success
                    task.wait(3)
                else
                    hopOnce()
                    task.wait(5)
                end
            end
        end)
    else
        AutoBtn.Text = "Auto Hop: OFF"
        AutoBtn.TextColor3 = Theme.TextSub
        AutoBtn.BackgroundColor3 = Theme.Surface
        AutoBtn.BackgroundTransparency = Theme.SurfaceTrans
        AutoStroke.Color = Theme.Border

        if autoThread then
            task.cancel(autoThread)
            autoThread = nil
        end
        StatusLabel.Text = "Auto Hop disabled."
        StatusLabel.TextColor3 = Theme.TextSub
    end
end)

-- Initial Status
StatusLabel.Text = "System ready."
StatusLabel.TextColor3 = Theme.TextSub