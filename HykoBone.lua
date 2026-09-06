repeat task.wait() until game:IsLoaded()

print("Hyko v1.1 - Dead Rails Auto Bond")

-- // Cấu hình
getgenv().Game_config = {
    Auto_reset = true,
    Auto_teleport = true,
    Only_drop_bond = false
}
getgenv().Lobby_config = {
    Players_number = 4,
    Auto_create_party = true,
    Auto_recreate_party = true
}

local ScriptURL = "https://raw.githubusercontent.com/hongmuoitranbsh-lang/Hyko/refs/heads/main/HykoBone.lua"

-- // Tự động load lại script khi teleport
if queue_on_teleport then
    queue_on_teleport("loadstring(game:HttpGet('" .. ScriptURL .. "'))()")
end

local Prefix = getgenv().Game_config
local LobbyPrefix = getgenv().Lobby_config

-- // ============== GAME CHÍNH ==============
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
    local LP = Player.LocalPlayer

    local world = require(RS:WaitForChild("Shared"):WaitForChild("Universe"):WaitForChild("ECS"):WaitForChild("world"))
    local comps = require(RS:WaitForChild("Shared"):WaitForChild("Universe"):WaitForChild("ECS"):WaitForChild("components"))
    local replicator = require(RS:WaitForChild("Client"):WaitForChild("Universe"):WaitForChild("Replication"):WaitForChild("clientReplicator"))
    local Remotes = require(RS:WaitForChild("Shared"):WaitForChild("Universe"):WaitForChild("Remotes"))
    local Event = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Universe"):WaitForChild("Network"):WaitForChild("RemoteEvent"):WaitForChild("Actionable")

    local CollectedBond = 0

    -- // ============== UI HYko v1.1 ==============
    local TweenService = game:GetService("TweenService")
    local CoreGui = (gethui and gethui() or game:GetService("CoreGui"))

    if CoreGui:FindFirstChild("HykoUI") then
        CoreGui["HykoUI"]:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "HykoUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Nền mờ
    local Background = Instance.new("Frame", ScreenGui)
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Background.BackgroundTransparency = 0.5
    Background.BorderSizePixel = 0

    -- Khung chính
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 400, 0, 180)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -90)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 27)
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true

    local Corner = Instance.new("UICorner", MainFrame)
    Corner.CornerRadius = UDim.new(0, 18)

    -- Glow viền
    local Glow1 = Instance.new("UIStroke", MainFrame)
    Glow1.Thickness = 2
    Glow1.Color = Color3.fromRGB(0, 200, 255)
    Glow1.Transparency = 0.2
    local Glow2 = Instance.new("UIStroke", MainFrame)
    Glow2.Thickness = 6
    Glow2.Color = Color3.fromRGB(0, 150, 255)
    Glow2.Transparency = 0.6
    local Glow3 = Instance.new("UIStroke", MainFrame)
    Glow3.Thickness = 12
    Glow3.Color = Color3.fromRGB(0, 100, 255)
    Glow3.Transparency = 0.85

    -- Gradient nền
    local Gradient = Instance.new("UIGradient", MainFrame)
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 26))
    }
    Gradient.Rotation = 45

    -- Header
    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 38)
    Header.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    Header.BackgroundTransparency = 0.3
    Header.BorderSizePixel = 0
    local HeaderCorner = Instance.new("UICorner", Header)
    HeaderCorner.CornerRadius = UDim.new(0, 18)

    -- Logo (icon Roblox)
    local Logo = Instance.new("ImageLabel", Header)
    Logo.Size = UDim2.new(0, 28, 0, 28)
    Logo.Position = UDim2.new(0, 10, 0, 5)
    Logo.BackgroundTransparency = 1
    Logo.Image = "rbxassetid://7484762806" -- Roblox logo
    Logo.ScaleType = Enum.ScaleType.Fit

    -- Tiêu đề
    local TitleLabel = Instance.new("TextLabel", Header)
    TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    TitleLabel.Position = UDim2.new(0, 45, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "Hyko v1.1 - Auto Bond"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Đường kẻ
    local Divider = Instance.new("Frame", MainFrame)
    Divider.Size = UDim2.new(1, -40, 0, 1)
    Divider.Position = UDim2.new(0, 20, 0, 38)
    Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Divider.BackgroundTransparency = 0.7
    Divider.BorderSizePixel = 0

    -- Nhãn bond thu thập (icon + text)
    local BondIcon = Instance.new("ImageLabel", MainFrame)
    BondIcon.Size = UDim2.new(0, 22, 0, 22)
    BondIcon.Position = UDim2.new(0, 25, 0, 50)
    BondIcon.BackgroundTransparency = 1
    BondIcon.Image = "rbxassetid://7484763188" -- Coin icon
    BondIcon.ScaleType = Enum.ScaleType.Fit

    local BondLabel = Instance.new("TextLabel", MainFrame)
    BondLabel.Size = UDim2.new(0, 180, 0, 24)
    BondLabel.Position = UDim2.new(0, 55, 0, 50)
    BondLabel.BackgroundTransparency = 1
    BondLabel.Text = "Bond(s): 0"
    BondLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    BondLabel.TextSize = 15
    BondLabel.Font = Enum.Font.GothamBold
    BondLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Nhãn current bond (icon + text)
    local CurrentIcon = Instance.new("ImageLabel", MainFrame)
    CurrentIcon.Size = UDim2.new(0, 22, 0, 22)
    CurrentIcon.Position = UDim2.new(0, 25, 0, 82)
    CurrentIcon.BackgroundTransparency = 1
    CurrentIcon.Image = "rbxassetid://7484763674" -- Bag icon
    CurrentIcon.ScaleType = Enum.ScaleType.Fit

    local CurrentBondLabel = Instance.new("TextLabel", MainFrame)
    CurrentBondLabel.Size = UDim2.new(0, 220, 0, 24)
    CurrentBondLabel.Position = UDim2.new(0, 55, 0, 82)
    CurrentBondLabel.BackgroundTransparency = 1
    CurrentBondLabel.Text = "Current: ???"
    CurrentBondLabel.TextColor3 = Color3.fromRGB(100, 180, 255)
    CurrentBondLabel.TextSize = 15
    CurrentBondLabel.Font = Enum.Font.GothamBold
    CurrentBondLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Nhãn trạng thái (icon + text)
    local StatusIcon = Instance.new("ImageLabel", MainFrame)
    StatusIcon.Size = UDim2.new(0, 22, 0, 22)
    StatusIcon.Position = UDim2.new(0, 25, 0, 114)
    StatusIcon.BackgroundTransparency = 1
    StatusIcon.Image = "rbxassetid://7484762896" -- Settings icon
    StatusIcon.ScaleType = Enum.ScaleType.Fit

    local StatusLabel = Instance.new("TextLabel", MainFrame)
    StatusLabel.Size = UDim2.new(0, 220, 0, 24)
    StatusLabel.Position = UDim2.new(0, 55, 0, 114)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Đang hoạt động..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    StatusLabel.TextSize = 14
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Fade in
    MainFrame.BackgroundTransparency = 1
    local fadeIn = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.15
    })
    fadeIn:Play()

    -- Cập nhật current bond
    local CurrentBond = LP:WaitForChild("PlayerGui"):WaitForChild("BondGui"):WaitForChild("BondInfo"):WaitForChild("BondCount")
    CurrentBond:GetPropertyChangedSignal("Text"):Connect(function()
        CurrentBondLabel.Text = "Current: " .. tostring(CurrentBond.Text)
    end)

    -- // ============== LOGIC FARM ==============
    task.wait(3.2)
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
                        BondLabel.Text = "Bond(s): " .. CollectedBond
                        task.wait(0.20)
                    end
                end
                if id > 99999 then
                    if Config.Auto_reset == true then
                        LP.Character:WaitForChild("Humanoid").Health = 0
                    end
                    if Config.Auto_teleport == true then
                        TeleportService:Teleport(116495829188952, LP)
                    end
                end
            end
        end
    end)

-- // ============== LOBBY ==============
elseif game.PlaceId == 116495829188952 then
    task.wait(1.8)
    local Config = {
        Players_number = math.clamp(LobbyPrefix.Players_number or 1, 1, 10),
        Auto_create_party = LobbyPrefix.Auto_create_party,
        Auto_recreate_party = LobbyPrefix.Auto_recreate_party
    }

    local Players = game:GetService("Players")
    local RS = game:GetService("ReplicatedStorage")
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

    -- // UI Lobby (Hyko v1.1)
    local TweenService = game:GetService("TweenService")
    local CoreGui = (gethui and gethui() or game:GetService("CoreGui"))
    if CoreGui:FindFirstChild("HykoUILobby") then
        CoreGui["HykoUILobby"]:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "HykoUILobby"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Background = Instance.new("Frame", ScreenGui)
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Background.BackgroundTransparency = 0.5
    Background.BorderSizePixel = 0

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 400, 0, 160)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -80)
    MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true

    local Corner = Instance.new("UICorner", MainFrame)
    Corner.CornerRadius = UDim.new(0, 18)

    local Glow1 = Instance.new("UIStroke", MainFrame)
    Glow1.Thickness = 2
    Glow1.Color = Color3.fromRGB(255, 100, 255)
    Glow1.Transparency = 0.2
    local Glow2 = Instance.new("UIStroke", MainFrame)
    Glow2.Thickness = 6
    Glow2.Color = Color3.fromRGB(200, 50, 255)
    Glow2.Transparency = 0.6
    local Glow3 = Instance.new("UIStroke", MainFrame)
    Glow3.Thickness = 12
    Glow3.Color = Color3.fromRGB(150, 0, 255)
    Glow3.Transparency = 0.85

    local Gradient = Instance.new("UIGradient", MainFrame)
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 30, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 20, 35))
    }
    Gradient.Rotation = -45

    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 38)
    Header.BackgroundColor3 = Color3.fromRGB(50, 45, 65)
    Header.BackgroundTransparency = 0.3
    Header.BorderSizePixel = 0
    local HeaderCorner = Instance.new("UICorner", Header)
    HeaderCorner.CornerRadius = UDim.new(0, 18)

    local Logo = Instance.new("ImageLabel", Header)
    Logo.Size = UDim2.new(0, 28, 0, 28)
    Logo.Position = UDim2.new(0, 10, 0, 5)
    Logo.BackgroundTransparency = 1
    Logo.Image = "rbxassetid://7484762806"
    Logo.ScaleType = Enum.ScaleType.Fit

    local TitleLabel = Instance.new("TextLabel", Header)
    TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    TitleLabel.Position = UDim2.new(0, 45, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "Hyko v1.1 - Auto Party"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local Divider = Instance.new("Frame", MainFrame)
    Divider.Size = UDim2.new(1, -40, 0, 1)
    Divider.Position = UDim2.new(0, 20, 0, 38)
    Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Divider.BackgroundTransparency = 0.7
    Divider.BorderSizePixel = 0

    local StatusIcon = Instance.new("ImageLabel", MainFrame)
    StatusIcon.Size = UDim2.new(0, 22, 0, 22)
    StatusIcon.Position = UDim2.new(0, 25, 0, 55)
    StatusIcon.BackgroundTransparency = 1
    StatusIcon.Image = "rbxassetid://7484762896"
    StatusIcon.ScaleType = Enum.ScaleType.Fit

    local StatusLabel = Instance.new("TextLabel", MainFrame)
    StatusLabel.Size = UDim2.new(0, 280, 0, 24)
    StatusLabel.Position = UDim2.new(0, 55, 0, 55)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Đang xử lý party..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    StatusLabel.TextSize = 14
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    MainFrame.BackgroundTransparency = 1
    local fadeIn = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.15
    })
    fadeIn:Play()

    -- // Logic party (như cũ, thêm cập nhật StatusLabel)
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
                        StatusLabel.Text = "Đã tạo party (tối đa " .. Config.Players_number .. " người)"
                    end
                end
            end)

            createdConnection = Remotes.CreateParty.OnClientEvent:Connect(function()
                partyCreated = true
                waitingForReservation = false
                stuckCheckStart = 0
                StatusLabel.Text = "Party đã được tạo"
            end)

            exitConnection = Remotes.ExitParty.OnClientEvent:Connect(function()
                partyCreated = false
                partyMembers = 0
                StatusLabel.Text = "Party đã rời, đang tạo lại..."
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
                StatusLabel.Text = "Thành viên: " .. partyMembers
            end)

            expiredConnection = Remotes.PartyZoneReservationExpired.OnClientEvent:Connect(function()
                partyCreated = false
                waitingForReservation = false
                stuckCheckStart = 0
                StatusLabel.Text = "Hết hạn, tạo lại..."
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
                        StatusLabel.Text = "Đã tạo party (tối đa " .. Config.Players_number .. " người)"
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
    print("Vui lòng vào đúng game Dead Rails (Game hoặc Lobby)!")
end
