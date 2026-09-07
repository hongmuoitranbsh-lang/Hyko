Repeat task.wait() until game:IsLoaded()

print("Hyko v1.3.5 - Auto Farm & Back to Lobby Loop (Redesigned UI)")

-- // Configuration
getgenv().Game_config = {
    Auto_reset = true,
    Auto_teleport = true,
    Only_drop_bond = false
}
getgenv().Lobby_config = {
    Players_number = 1, -- Auto tạo room Solo 1 người
    Auto_create_party = true,
    Auto_recreate_party = true
}

local ScriptURL = "https://raw.githubusercontent.com/hongmuoitranbsh-lang/Hyko/refs/heads/main/HykoBone.lua"

if queue_on_teleport then
    queue_on_teleport("loadstring(game:HttpGet('" .. ScriptURL .. "'))()")
end

local Prefix = getgenv().Game_config
local LobbyPrefix = getgenv().Lobby_config

-- // Helper Function: Tạo hiệu ứng Glow
local function ApplyModernStyle(frame, cornerRadius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius or 12)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.2
    stroke.Color = Color3.fromRGB(0, 240, 255)
    stroke.Transparency = 0.4
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame

    return stroke
end

-- // ============== MAIN GAME (IN-GAME FARM BONE) ==============
if game.PlaceId == 70876832253163 then
    task.wait()
    local Config = {
        Auto_reset = Prefix.Auto_reset,
        Auto_teleport = Prefix.Auto_teleport,
        Only_drop_bond = Prefix.Only_drop_bond
    }

    local Player = game:GetService("Players")
    local RS = game:GetService("ReplicatedStorage")
    local TeleportService = game:GetService("TeleportService")
    local TweenService = game:GetService("TweenService")
    local LP = Player.LocalPlayer

    local world = require(RS:WaitForChild("Shared"):WaitForChild("Universe"):WaitForChild("ECS"):WaitForChild("world"))
    local comps = require(RS:WaitForChild("Shared"):WaitForChild("Universe"):WaitForChild("ECS"):WaitForChild("components"))
    local replicator = require(RS:WaitForChild("Client"):WaitForChild("Universe"):WaitForChild("Replication"):WaitForChild("clientReplicator"))
    local Remotes = require(RS:WaitForChild("Shared"):WaitForChild("Universe"):WaitForChild("Remotes"))
    local Event = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Universe"):WaitForChild("Network"):WaitForChild("RemoteEvent"):WaitForChild("Actionable")

    local CollectedBond = 0

    -- Core UI Cleanup
    local CoreGui = (gethui and gethui() or game:GetService("CoreGui"))
    if CoreGui:FindFirstChild("HykoUI") then
        CoreGui["HykoUI"]:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "HykoUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999999
    ScreenGui.Parent = CoreGui

    -- Main Container Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 340, 0, 0) -- Khởi tạo height = 0 để làm animation bung ra
    MainFrame.Position = UDim2.new(0.5, -170, 0.5, -110)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainStroke = ApplyModernStyle(MainFrame, 16)

    -- Glow Gradient Effect
    local RainbowGradient = Instance.new("UIGradient")
    RainbowGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 240, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(140, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 150))
    }
    RainbowGradient.Parent = MainStroke

    task.spawn(function()
        while task.wait(0.02) do
            RainbowGradient.Rotation = (RainbowGradient.Rotation + 1.5) % 360
        end
    end)

    -- Header Panel
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    Header.BackgroundTransparency = 0.2
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 16)
    HeaderCorner.Parent = Header

    local HeaderIcon = Instance.new("ImageLabel")
    HeaderIcon.Size = UDim2.new(0, 22, 0, 22)
    HeaderIcon.Position = UDim2.new(0, 14, 0.5, -11)
    HeaderIcon.BackgroundTransparency = 1
    HeaderIcon.Image = "rbxassetid://6031280882"
    HeaderIcon.ImageColor3 = Color3.fromRGB(0, 240, 255)
    HeaderIcon.Parent = Header

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    TitleLabel.Position = UDim2.new(0, 44, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "HYKO HUB <font color=\"#00F0FF\">// AUTO FARM</font>"
    TitleLabel.RichText = true
    TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    TitleLabel.TextSize = 13
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header

    -- Content Wrapper
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -28, 0, 160)
    ContentContainer.Position = UDim2.new(0, 14, 0, 52)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame

    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 8)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Parent = ContentContainer

    -- Card Creator Function
    local function CreateDataCard(iconId, iconColor, defaultTitle, layoutOrder)
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 44)
        Card.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        Card.BorderSizePixel = 0
        Card.LayoutOrder = layoutOrder
        Card.Parent = ContentContainer

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 10)
        Corner.Parent = Card

        local Stroke = Instance.new("UIStroke")
        Stroke.Thickness = 1
        Stroke.Color = Color3.fromRGB(255, 255, 255)
        Stroke.Transparency = 0.92
        Stroke.Parent = Card

        local Icon = Instance.new("ImageLabel")
        Icon.Size = UDim2.new(0, 20, 0, 20)
        Icon.Position = UDim2.new(0, 12, 0.5, -10)
        Icon.BackgroundTransparency = 1
        Icon.Image = iconId
        Icon.ImageColor3 = iconColor
        Icon.Parent = Card

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -44, 1, 0)
        Label.Position = UDim2.new(0, 40, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = defaultTitle
        Label.TextColor3 = Color3.fromRGB(220, 220, 230)
        Label.TextSize = 12
        Label.Font = Enum.Font.GothamMedium
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Card

        return Label
    end

    local BondLabel = CreateDataCard("rbxassetid://6034684937", Color3.fromRGB(0, 255, 170), "COLLECTED : 0", 1)
    local CurrentBondLabel = CreateDataCard("rbxassetid://6031265976", Color3.fromRGB(0, 180, 255), "INVENTORY : --", 2)
    local StatusLabel = CreateDataCard("rbxassetid://6031097225", Color3.fromRGB(255, 180, 0), "STATUS : Initializing...", 3)

    -- Opening Animation
    TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 340, 0, 220)
    }):Play()

    local CurrentBond = LP:WaitForChild("PlayerGui"):WaitForChild("BondGui"):WaitForChild("BondInfo"):WaitForChild("BondCount")
    CurrentBondLabel.Text = "INVENTORY : " .. tostring(CurrentBond.Text)
    CurrentBond:GetPropertyChangedSignal("Text"):Connect(function()
        CurrentBondLabel.Text = "INVENTORY : " .. tostring(CurrentBond.Text)
    end)

    -- // Logic Farm & Out ra Lobby
    task.wait(2.5)
    StatusLabel.Text = "STATUS : Farming Bones..."
    
    task.spawn(function()
        local char = world:get_resource(comps.ClientStateResource).localCharacter
        if char then
            if not world:has(char, comps.Sack) then
                world:add(char, comps.Sack)
                world:set(char, comps.Sack, { contents = {}, maxContents = 10 })
            end
            
            for id = 1, 100000 do
                if world:has(id, comps.Storable) and world:get(id, comps.ObjectId) == "bond" then
                    local sr = replicator:get_server_entity(id)
                    if sr and sr ~= id then
                        Remotes.Store:FireServer(sr)
                        Remotes.Store:FireServer()
                        if Config.Only_drop_bond == false then
                            Event:FireServer(sr)
                        end

                        CollectedBond += 1
                        BondLabel.Text = "COLLECTED : " .. CollectedBond
                        task.wait(0.20)
                    end
                end
            end

            -- Khi gom xong Bone: Chuyển về Lobby
            StatusLabel.Text = "STATUS : Returning to Lobby..."
            task.wait(0.3)
            if Config.Auto_reset == true and LP.Character and LP.Character:FindFirstChild("Humanoid") then
                LP.Character.Humanoid.Health = 0
            end
            
            if Config.Auto_teleport == true then
                TeleportService:Teleport(116495829188952, LP)
            end
        end
    end)

-- // ============== LOBBY (TỰ TẠO PARTY ĐỂ VÀO GAME LẠI) ==============
elseif game.PlaceId == 116495829188952 then
    task.wait(1.5)
    local Config = {
        Players_number = math.clamp(LobbyPrefix.Players_number or 1, 1, 10),
        Auto_create_party = LobbyPrefix.Auto_create_party,
        Auto_recreate_party = LobbyPrefix.Auto_recreate_party
    }

    local Players = game:GetService("Players")
    local RS = game:GetService("ReplicatedStorage")
    local TweenService = game:GetService("TweenService")
    local LP = Players.LocalPlayer

    local Remotes = require(RS:WaitForChild("Shared"):WaitForChild("Universe"):WaitForChild("Remotes"))
    local PartyCreationState = require(RS:WaitForChild("Client"):WaitForChild("Lobby"):WaitForChild("Party"):WaitForChild("PartyCreationState"))

    local partyZones = workspace:WaitForChild("PartyZones"):GetChildren()
    table.sort(partyZones, function(a, b) return a.Name < b.Name end)

    local partyCreated = false
    local partyMembers = 0
    local currentZoneIndex = 1
    local stuckCheckStart = 0
    local waitingForReservation = false

    local CoreGui = (gethui and gethui() or game:GetService("CoreGui"))
    if CoreGui:FindFirstChild("HykoUILobby") then
        CoreGui["HykoUILobby"]:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "HykoUILobby"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999999
    ScreenGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 340, 0, 0)
    MainFrame.Position = UDim2.new(0.5, -170, 0.5, -80)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainStroke = ApplyModernStyle(MainFrame, 16)

    local RainbowGradient = Instance.new("UIGradient")
    RainbowGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 230, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 170))
    }
    RainbowGradient.Parent = MainStroke

    task.spawn(function()
        while task.wait(0.02) do
            RainbowGradient.Rotation = (RainbowGradient.Rotation + 1.5) % 360
        end
    end)

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    Header.BackgroundTransparency = 0.2
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 16)
    HeaderCorner.Parent = Header

    local HeaderIcon = Instance.new("ImageLabel")
    HeaderIcon.Size = UDim2.new(0, 22, 0, 22)
    HeaderIcon.Position = UDim2.new(0, 14, 0.5, -11)
    HeaderIcon.BackgroundTransparency = 1
    HeaderIcon.Image = "rbxassetid://6034287594"
    HeaderIcon.ImageColor3 = Color3.fromRGB(0, 230, 255)
    HeaderIcon.Parent = Header

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    TitleLabel.Position = UDim2.new(0, 44, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "HYKO HUB <font color=\"#00E6FF\">// AUTO PARTY</font>"
    TitleLabel.RichText = true
    TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    TitleLabel.TextSize = 13
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header

    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -28, 0, 85)
    Card.Position = UDim2.new(0, 14, 0, 55)
    Card.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    Card.BorderSizePixel = 0
    Card.Parent = MainFrame

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 10)
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Thickness = 1
    CardStroke.Color = Color3.fromRGB(255, 255, 255)
    CardStroke.Transparency = 0.92
    CardStroke.Parent = Card

    local LobbyIcon = Instance.new("ImageLabel")
    LobbyIcon.Size = UDim2.new(0, 22, 0, 22)
    LobbyIcon.Position = UDim2.new(0, 14, 0.5, -11)
    LobbyIcon.BackgroundTransparency = 1
    LobbyIcon.Image = "rbxassetid://6031097225"
    LobbyIcon.ImageColor3 = Color3.fromRGB(0, 230, 255)
    LobbyIcon.Parent = Card

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -48, 1, 0)
    StatusLabel.Position = UDim2.new(0, 44, 0, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "<b>STATUS :</b>\nCreating Party to Enter Game..."
    StatusLabel.RichText = true
    StatusLabel.TextColor3 = Color3.fromRGB(0, 230, 255)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.GothamMedium
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.TextYAlignment = Enum.TextYAlignment.Center
    StatusLabel.TextWrapped = true
    StatusLabel.Parent = Card

    -- Entrance Animation
    TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 340, 0, 155)
    }):Play()

    -- // Party Auto Loop
    if Config.Auto_create_party == true then
        task.spawn(function()
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp and partyZones[1] and partyZones[1]:FindFirstChild("Hitbox") then
                hrp.CFrame = partyZones[1].Hitbox.CFrame + Vector3.new(0, 3, 0)
            end

            reservedConnection = Remotes.PartyZoneReserved.OnClientEvent:Connect(function()
                waitingForReservation = false
                if not partyCreated then
                    task.wait(0.2)
                    local settings = PartyCreationState.partySettings()
                    if not settings then
                        waitingForReservation = true
                    else
                        local newSettings = table.clone(settings)
                        newSettings.maxMembers = Config.Players_number
                        newSettings.isPrivate = false
                        PartyCreationState.partySettings(newSettings)
                        Remotes.CreateParty:FireServer(PartyCreationState.partySettings())
                        partyCreated = true
                        stuckCheckStart = 0
                        StatusLabel.Text = "<b>STATUS :</b>\nParty Created! Entering game..."
                    end
                end
            end)

            createdConnection = Remotes.CreateParty.OnClientEvent:Connect(function()
                partyCreated = true
                waitingForReservation = false
                stuckCheckStart = 0
                StatusLabel.Text = "<b>STATUS :</b>\nParty created successfully!"
            end)

            exitConnection = Remotes.ExitParty.OnClientEvent:Connect(function()
                partyCreated = false
                partyMembers = 0
                StatusLabel.Text = "<b>STATUS :</b>\nLeft party, recreating..."
                if Config.Auto_recreate_party then
                    task.spawn(function()
                        task.wait(0.5)
                        partyCreated = false
                        waitingForReservation = false
                        stuckCheckStart = 0
                        currentZoneIndex += 1
                        if currentZoneIndex > #partyZones then
                            currentZoneIndex = 1
                        end
                        local zone = partyZones[currentZoneIndex]
                        if zone and zone:FindFirstChild("Hitbox") then
                            local charHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                            if charHrp then
                                charHrp.CFrame = zone.Hitbox.CFrame + Vector3.new(0, 3, 0)
                            end
                        end
                    end)
                end
            end)

            joinedConnection = Remotes.JoinnedParty.OnClientEvent:Connect(function()
                partyMembers += 1
                StatusLabel.Text = "<b>STATUS :</b>\nCurrent Members: " .. partyMembers
            end)

            expiredConnection = Remotes.PartyZoneReservationExpired.OnClientEvent:Connect(function()
                partyCreated = false
                waitingForReservation = false
                stuckCheckStart = 0
                StatusLabel.Text = "<b>STATUS :</b>\nReservation expired, retrying..."
                if Config.Auto_recreate_party then
                    task.spawn(function()
                        task.wait(0.3)
                        partyCreated = false
                        waitingForReservation = false
                        stuckCheckStart = 0
                        currentZoneIndex += 1
                        if currentZoneIndex > #partyZones then
                            currentZoneIndex = 1
                        end
                        local zone = partyZones[currentZoneIndex]
                        if zone and zone:FindFirstChild("Hitbox") then
                            local charHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                            if charHrp then
                                charHrp.CFrame = zone.Hitbox.CFrame + Vector3.new(0, 3, 0)
                            end
                        end
                    end)
                end
            end)

            while Config.Auto_create_party do
                task.wait(0.3)

                if waitingForReservation and not partyCreated then
                    if stuckCheckStart == 0 then
                        stuckCheckStart = tick()
                    elseif tick() - stuckCheckStart > 2 then
                        partyCreated = false
                        waitingForReservation = false
                        stuckCheckStart = 0
                        currentZoneIndex += 1
                        if currentZoneIndex > #partyZones then
                            currentZoneIndex = 1
                        end
                        local zone = partyZones[currentZoneIndex]
                        if zone and zone:FindFirstChild("Hitbox") then
                            local charHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                            if charHrp then
                                charHrp.CFrame = zone.Hitbox.CFrame + Vector3.new(0, 3, 0)
                            end
                        end
                    end
                end

                if PartyCreationState.isOpen() and not partyCreated and not waitingForReservation then
                    task.wait(0.2)
                    local settings = PartyCreationState.partySettings()
                    if not settings then
                        waitingForReservation = true
                    else
                        local newSettings = table.clone(settings)
                        newSettings.maxMembers = Config.Players_number
                        newSettings.isPrivate = false
                        PartyCreationState.partySettings(newSettings)
                        Remotes.CreateParty:FireServer(PartyCreationState.partySettings())
                        partyCreated = true
                        stuckCheckStart = 0
                        StatusLabel.Text = "<b>STATUS :</b>\nParty Created! Entering game..."
                    end
                end

                if not partyCreated and not PartyCreationState.isOpen() and not waitingForReservation then
                    if Config.Auto_recreate_party then
                        partyCreated = false
                        waitingForReservation = false
                        stuckCheckStart = 0
                        currentZoneIndex += 1
                        if currentZoneIndex > #partyZones then
                            currentZoneIndex = 1
                        end
                        local zone = partyZones[currentZoneIndex]
                        if zone and zone:FindFirstChild("Hitbox") then
                            local charHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                            if charHrp then
                                charHrp.CFrame = zone.Hitbox.CFrame + Vector3.new(0, 3, 0)
                            end
                        end
                        task.wait(1)
                    end
                end
            end

            if reservedConnection then reservedConnection:Disconnect() end
            if createdConnection then createdConnection:Disconnect() end
            if exitConnection then exitConnection:Disconnect() end
            if joinedConnection then joinedConnection:Disconnect() end
            if expiredConnection then expiredConnection:Disconnect() end
        end)
    end
else
    print("[Error] Please enter Dead Rails (Game or Lobby)!")
end
