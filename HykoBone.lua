repeat task.wait() until game:IsLoaded()

print("Hyko v1.1 - Dead Rails Auto Bond [Fixed UI]")

-- // Configuration
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

-- // Auto reload script on teleport
if queue_on_teleport then
    queue_on_teleport("loadstring(game:HttpGet('" .. ScriptURL .. "'))()")
end

local Prefix = getgenv().Game_config
local LobbyPrefix = getgenv().Lobby_config

-- // ============== MAIN GAME ==============
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

    -- // ============== UI ENGINE (FIXED DISPLAY) ==============
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
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 360, 0, 210)
    MainFrame.Position = UDim2.new(0.5, -180, 0.5, -105)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 12)

    -- Rainbow Glow Stroke
    local NeonStroke = Instance.new("UIStroke", MainFrame)
    NeonStroke.Thickness = 2
    NeonStroke.Color = Color3.fromRGB(0, 255, 200)

    local RainbowGradient = Instance.new("UIGradient", NeonStroke)
    RainbowGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 128)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 230, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 255))
    }

    task.spawn(function()
        while task.wait(0.03) do
            RainbowGradient.Rotation = (RainbowGradient.Rotation + 2) % 360
        end
    end)

    -- Header Panel
    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Header.BackgroundTransparency = 0.2
    Header.BorderSizePixel = 0

    local HeaderCorner = Instance.new("UICorner", Header)
    HeaderCorner.CornerRadius = UDim.new(0, 12)

    local HeaderIcon = Instance.new("ImageLabel", Header)
    HeaderIcon.Size = UDim2.new(0, 20, 0, 20)
    HeaderIcon.Position = UDim2.new(0, 12, 0.5, -10)
    HeaderIcon.BackgroundTransparency = 1
    HeaderIcon.Image = "rbxassetid://6031280882"
    HeaderIcon.ImageColor3 = Color3.fromRGB(0, 230, 255)

    local TitleLabel = Instance.new("TextLabel", Header)
    TitleLabel.Size = UDim2.new(1, -45, 1, 0)
    TitleLabel.Position = UDim2.new(0, 40, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "HYKO // AUTO FARM v1.1"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 13
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local Line = Instance.new("Frame", MainFrame)
    Line.Size = UDim2.new(1, -24, 0, 1)
    Line.Position = UDim2.new(0, 12, 0, 40)
    Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Line.BackgroundTransparency = 0.8
    Line.BorderSizePixel = 0

    -- Cards Container
    local ContentContainer = Instance.new("Frame", MainFrame)
    ContentContainer.Size = UDim2.new(1, -24, 0, 150)
    ContentContainer.Position = UDim2.new(0, 12, 0, 48)
    ContentContainer.BackgroundTransparency = 1

    -- Card 1: Collected
    local Card1 = Instance.new("Frame", ContentContainer)
    Card1.Size = UDim2.new(1, 0, 0, 42)
    Card1.Position = UDim2.new(0, 0, 0, 0)
    Card1.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    Card1.BackgroundTransparency = 0.3
    Card1.BorderSizePixel = 0
    Instance.new("UICorner", Card1).CornerRadius = UDim.new(0, 8)

    local Icon1 = Instance.new("ImageLabel", Card1)
    Icon1.Size = UDim2.new(0, 18, 0, 18)
    Icon1.Position = UDim2.new(0, 12, 0.5, -9)
    Icon1.BackgroundTransparency = 1
    Icon1.Image = "rbxassetid://6034043463"
    Icon1.ImageColor3 = Color3.fromRGB(0, 255, 170)

    local BondLabel = Instance.new("TextLabel", Card1)
    BondLabel.Size = UDim2.new(1, -40, 1, 0)
    BondLabel.Position = UDim2.new(0, 38, 0, 0)
    BondLabel.BackgroundTransparency = 1
    BondLabel.Text = "COLLECTED : 0"
    BondLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
    BondLabel.TextSize = 12
    BondLabel.Font = Enum.Font.GothamBold
    BondLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Card 2: Inventory
    local Card2 = Instance.new("Frame", ContentContainer)
    Card2.Size = UDim2.new(1, 0, 0, 42)
    Card2.Position = UDim2.new(0, 0, 0, 48)
    Card2.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    Card2.BackgroundTransparency = 0.3
    Card2.BorderSizePixel = 0
    Instance.new("UICorner", Card2).CornerRadius = UDim.new(0, 8)

    local Icon2 = Instance.new("ImageLabel", Card2)
    Icon2.Size = UDim2.new(0, 18, 0, 18)
    Icon2.Position = UDim2.new(0, 12, 0.5, -9)
    Icon2.BackgroundTransparency = 1
    Icon2.Image = "rbxassetid://6034451733"
    Icon2.ImageColor3 = Color3.fromRGB(0, 180, 255)

    local CurrentBondLabel = Instance.new("TextLabel", Card2)
    CurrentBondLabel.Size = UDim2.new(1, -40, 1, 0)
    CurrentBondLabel.Position = UDim2.new(0, 38, 0, 0)
    CurrentBondLabel.BackgroundTransparency = 1
    CurrentBondLabel.Text = "INVENTORY : ???"
    CurrentBondLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
    CurrentBondLabel.TextSize = 12
    CurrentBondLabel.Font = Enum.Font.GothamBold
    CurrentBondLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Card 3: Status
    local Card3 = Instance.new("Frame", ContentContainer)
    Card3.Size = UDim2.new(1, 0, 0, 42)
    Card3.Position = UDim2.new(0, 0, 0, 96)
    Card3.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    Card3.BackgroundTransparency = 0.3
    Card3.BorderSizePixel = 0
    Instance.new("UICorner", Card3).CornerRadius = UDim.new(0, 8)

    local Icon3 = Instance.new("ImageLabel", Card3)
    Icon3.Size = UDim2.new(0, 18, 0, 18)
    Icon3.Position = UDim2.new(0, 12, 0.5, -9)
    Icon3.BackgroundTransparency = 1
    Icon3.Image = "rbxassetid://6031097225"
    Icon3.ImageColor3 = Color3.fromRGB(255, 180, 0)

    local StatusLabel = Instance.new("TextLabel", Card3)
    StatusLabel.Size = UDim2.new(1, -40, 1, 0)
    StatusLabel.Position = UDim2.new(0, 38, 0, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "SYSTEM : Active & Running"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 180, 0)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.GothamMedium
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Dynamic Inventory Counter Listener
    local CurrentBond = LP:WaitForChild("PlayerGui"):WaitForChild("BondGui"):WaitForChild("BondInfo"):WaitForChild("BondCount")
    CurrentBondLabel.Text = "INVENTORY : " .. tostring(CurrentBond.Text)
    CurrentBond:GetPropertyChangedSignal("Text"):Connect(function()
        CurrentBondLabel.Text = "INVENTORY : " .. tostring(CurrentBond.Text)
    end)

    -- // ============== FARM LOGIC ==============
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
                        BondLabel.Text = "COLLECTED : " .. CollectedBond
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

    -- // ============== UI ENGINE (LOBBY FIXED) ==============
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

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 360, 0, 160)
    MainFrame.Position = UDim2.new(0.5, -180, 0.5, -80)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 12)

    local NeonStroke = Instance.new("UIStroke", MainFrame)
    NeonStroke.Thickness = 2
    NeonStroke.Color = Color3.fromRGB(0, 230, 255)

    local RainbowGradient = Instance.new("UIGradient", NeonStroke)
    RainbowGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 230, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 170))
    }

    task.spawn(function()
        while task.wait(0.03) do
            RainbowGradient.Rotation = (RainbowGradient.Rotation + 2) % 360
        end
    end)

    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Header.BackgroundTransparency = 0.2
    Header.BorderSizePixel = 0

    local HeaderCorner = Instance.new("UICorner", Header)
    HeaderCorner.CornerRadius = UDim.new(0, 12)

    local HeaderIcon = Instance.new("ImageLabel", Header)
    HeaderIcon.Size = UDim2.new(0, 20, 0, 20)
    HeaderIcon.Position = UDim2.new(0, 12, 0.5, -10)
    HeaderIcon.BackgroundTransparency = 1
    HeaderIcon.Image = "rbxassetid://6034287594"
    HeaderIcon.ImageColor3 = Color3.fromRGB(0, 230, 255)

    local TitleLabel = Instance.new("TextLabel", Header)
    TitleLabel.Size = UDim2.new(1, -45, 1, 0)
    TitleLabel.Position = UDim2.new(0, 40, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "HYKO // AUTO PARTY v1.1"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 13
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local Line = Instance.new("Frame", MainFrame)
    Line.Size = UDim2.new(1, -24, 0, 1)
    Line.Position = UDim2.new(0, 12, 0, 40)
    Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Line.BackgroundTransparency = 0.8
    Line.BorderSizePixel = 0

    local Card = Instance.new("Frame", MainFrame)
    Card.Size = UDim2.new(1, -24, 0, 90)
    Card.Position = UDim2.new(0, 12, 0, 52)
    Card.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    Card.BackgroundTransparency = 0.3
    Card.BorderSizePixel = 0
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

    local LobbyIcon = Instance.new("ImageLabel", Card)
    LobbyIcon.Size = UDim2.new(0, 20, 0, 20)
    LobbyIcon.Position = UDim2.new(0, 12, 0.5, -10)
    LobbyIcon.BackgroundTransparency = 1
    LobbyIcon.Image = "rbxassetid://6031097225"
    LobbyIcon.ImageColor3 = Color3.fromRGB(0, 230, 255)

    local StatusLabel = Instance.new("TextLabel", Card)
    StatusLabel.Size = UDim2.new(1, -45, 1, 0)
    StatusLabel.Position = UDim2.new(0, 40, 0, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "PARTY STATUS :\nInitializing matchmaking..."
    StatusLabel.TextColor3 = Color3.fromRGB(0, 230, 255)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.GothamMedium
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.TextYAlignment = Enum.TextYAlignment.Center
    StatusLabel.TextWrapped = true

    -- // Party Logic
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
                        StatusLabel.Text = "PARTY STATUS :\nParty created (Max: " .. Config.Players_number .. " players)"
                    end
                end
            end)

            createdConnection = Remotes.CreateParty.OnClientEvent:Connect(function()
                partyCreated = true
                waitingForReservation = false
                stuckCheckStart = 0
                StatusLabel.Text = "PARTY STATUS :\nParty created successfully!"
            end)

            exitConnection = Remotes.ExitParty.OnClientEvent:Connect(function()
                partyCreated = false
                partyMembers = 0
                StatusLabel.Text = "PARTY STATUS :\nLeft party, recreating..."
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
                StatusLabel.Text = "PARTY STATUS :\nCurrent Members: " .. partyMembers
            end)

            expiredConnection = Remotes.PartyZoneReservationExpired.OnClientEvent:Connect(function()
                partyCreated = false
                waitingForReservation = false
                stuckCheckStart = 0
                StatusLabel.Text = "PARTY STATUS :\nReservation expired, retrying..."
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
                        StatusLabel.Text = "PARTY STATUS :\nParty created (Max: " .. Config.Players_number .. " players)"
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
