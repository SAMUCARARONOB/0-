--[[
    RANOX - Script para MESCLAR UMA BOMBA NUCLEAR
    Desenvolvido por Keybrew
    Atualizado com aba Configurações e Auto Drop no Merge
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "RANOX",
    LoadingTitle = "RANOX Hub",
    LoadingSubtitle = "by Keybrew",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "RANOXHubConfigs",
        FileName = "RANOXHub"
    },
    KeySystem = false,
    Theme = "Default",
    ToggleUIKeybind = Enum.KeyCode.RightAlt
})

local Players = game:GetService("Players")
local Main = Window:CreateTab("Principal", 4483362458)
local UniversalTab = Window:CreateTab("Universal", 4483362458)
local ConfigTab = Window:CreateTab("Configurações", 4483362458)
local CreditsTab = Window:CreateTab("Créditos", 4483362458)
local LocalPlayer = Players.LocalPlayer
local PlayerId = tonumber(LocalPlayer.UserId)
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

local function GetPlayerBase()
    local BasesFolder = Workspace:FindFirstChild("Bases")
    if BasesFolder then
        for _, folder in ipairs(BasesFolder:GetChildren()) do
            local attributeValue = folder:GetAttribute("OwnerUserId")
            if attributeValue and tonumber(attributeValue) == PlayerId then
                return folder
            end
        end
    end
    return nil
end

local function TeleportTo(object)
    if not object or not LocalPlayer.Character then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local position = nil
    if object:IsA("Model") then
        position = object:GetPivot().Position
    elseif object:IsA("BasePart") then
        position = object.Position
    end
    if root and position then
        root.CFrame = CFrame.new(position + Vector3.new(0, 2, 0))
    end
end
Main:CreateLabel("FUNÇÕES DE GUERRA")
-- Botão para carregar a interface de guerra (com cooldown de 5s)
Main:CreateButton({
    Name = "GUERRA INTERFACE FUNÇÕES 🧨",
    Callback = function()
        -- Verifica se o cooldown está ativo
        if _G.GuerraCooldown then
            Rayfield:Notify({
                Title = "Aguarde",
                Content = "Você precisa esperar 5 segundos para usar novamente.",
                Duration = 3,
                Image = 4483362458,
            })
            return
        end

        -- Ativa o cooldown
        _G.GuerraCooldown = true

        -- Executa o script externo com segurança
        local sucesso, erro = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/SAMUCARARONOB/Inf/refs/heads/main/RANOXv2.lua"))()
        end)

        if not sucesso then
            Rayfield:Notify({
                Title = "Erro",
                Content = "Falha ao carregar o script de guerra.",
                Duration = 3,
                Image = 4483362458,
            })
            warn("Erro no script de guerra:", erro)
        else
            Rayfield:Notify({
                Title = "Sucesso",
                Content = "Interface de guerra carregada!",
                Duration = 3,
                Image = 4483362458,
            })
        end

        -- Remove o cooldown após 5 segundos
        task.delay(5, function()
            _G.GuerraCooldown = false
        end)
    end
})
Main:CreateLabel("FUNÇÕES GERAIS")
-- ==================== AUTO FUSÃO (ORIGINAL) ====================
Main:CreateToggle({
    Name = "Auto Fusão",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        _G.AutoMerge = Value
        while _G.AutoMerge do
            local myBase = GetPlayerBase()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                ReplicatedStorage.NukeRemotes.Drop:FireServer(root.CFrame)
            end

            if myBase and myBase:FindFirstChild("Nukes") then
                local nukeCounts = {}
                for _, nuke in ipairs(myBase.Nukes:GetChildren()) do
                    if nuke.Name == "Nuke" and nuke:FindFirstChild("OverheadNuke") and nuke.OverheadNuke:FindFirstChild("TextLabel") then
                        local nukeType = nuke.OverheadNuke.TextLabel.Text
                        if nukeType and nukeType ~= "" then
                            if not nukeCounts[nukeType] then
                                nukeCounts[nukeType] = {}
                            end
                            table.insert(nukeCounts[nukeType], nuke)
                        end
                    end
                end
                for _, matches in pairs(nukeCounts) do
                    if #matches >= 2 then
                        local PickUpEvent = ReplicatedStorage.NukeRemotes.PickUp
                        local MergeEvent = ReplicatedStorage.NukeRemotes.MergeRequest
                        local firstNuke = matches[1]
                        local secondNuke = matches[2]
                        PickUpEvent:FireServer(firstNuke)
                        task.wait(0.01)
                        MergeEvent:FireServer(secondNuke)
                        break
                    end
                end
            end
            RunService.Heartbeat:Wait()
        end
    end
})

-- ==================== AUTO FUSÃO ULTRA (TELEPORTE RÁPIDO, MUITO MAIS VELOZ) ====================
Main:CreateToggle({
    Name = "Auto Fusão Ultra",
    CurrentValue = false,
    Flag = "ToggleUltraMerge",
    Callback = function(Value)
        _G.AutoMergeUltra = Value
        while _G.AutoMergeUltra do
            local myBase = GetPlayerBase()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")

            if not myBase or not root then
                task.wait(0.1)
                continue
            end

            -- Drop da nuke atual (libera inventário)
            ReplicatedStorage.NukeRemotes.Drop:FireServer(root.CFrame)

            if myBase:FindFirstChild("Nukes") then
                local typeMap = {}
                for _, nuke in ipairs(myBase.Nukes:GetChildren()) do
                    if nuke.Name == "Nuke" and nuke:FindFirstChild("OverheadNuke") and nuke.OverheadNuke:FindFirstChild("TextLabel") then
                        local nukeType = nuke.OverheadNuke.TextLabel.Text
                        if nukeType and nukeType ~= "" then
                            if not typeMap[nukeType] then
                                typeMap[nukeType] = {}
                            end
                            table.insert(typeMap[nukeType], nuke)
                        end
                    end
                end

                local originalCFrame = root.CFrame

                -- Processa todos os pares encontrados
                for nukeType, nukeList in pairs(typeMap) do
                    if not _G.AutoMergeUltra then break end
                    if #nukeList >= 2 then
                        local firstNuke = nukeList[1]
                        local secondNuke = nukeList[2]

                        TeleportTo(firstNuke)
                        task.wait(0.02)

                        ReplicatedStorage.NukeRemotes.PickUp:FireServer(firstNuke)
                        task.wait(0.02)

                        ReplicatedStorage.NukeRemotes.MergeRequest:FireServer(secondNuke)
                        task.wait(0.02)
                    end
                end

                if originalCFrame then
                    root.CFrame = originalCFrame
                    task.wait(0.05)
                end
            end

            task.wait(0.1)
        end
    end
})

-- ==================== AUTO PEGAR TUDO (TELEPORTE) ====================
Main:CreateToggle({
    Name = "Auto Pegar Tudo",
    CurrentValue = false,
    Flag = "Toggle2",
    Callback = function(Value)
        _G.AutoPickUp = Value
        while _G.AutoPickUp do
            local myBase = GetPlayerBase()
            if myBase and myBase:FindFirstChild("Nukes") then
                local nukeCounts = {}
                for _, nuke in ipairs(myBase.Nukes:GetChildren()) do
                    if nuke.Name == "Nuke" and nuke:FindFirstChild("OverheadNuke") and nuke.OverheadNuke:FindFirstChild("TextLabel") then
                        local nukeType = nuke.OverheadNuke.TextLabel.Text
                        if nukeType and nukeType ~= "" then
                            if not nukeCounts[nukeType] then
                                nukeCounts[nukeType] = {}
                            end
                            table.insert(nukeCounts[nukeType], nuke)
                        end
                    end
                end

                for _, nuke in ipairs(myBase.Nukes:GetChildren()) do
                    if not _G.AutoPickUp then break end
                    if nuke.Name == "Nuke" and nuke:FindFirstChild("OverheadNuke") and nuke.OverheadNuke:FindFirstChild("TextLabel") then
                        local nukeType = nuke.OverheadNuke.TextLabel.Text
                        local matchCount = nukeCounts[nukeType] and #nukeCounts[nukeType] or 0

                        local PickUpEvent = ReplicatedStorage.NukeRemotes.PickUp
                        local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local originalCFrame = rootPart and rootPart.CFrame

                        TeleportTo(nuke)
                        task.wait()
                        PickUpEvent:FireServer(nuke)
                        task.wait()

                        if matchCount < 2 then
                            local DropEvent = ReplicatedStorage.NukeRemotes.Drop
                            if rootPart then
                                DropEvent:FireServer(rootPart.CFrame)
                            else
                                DropEvent:FireServer(CFrame.new(290.03, 17.20, 249.74))
                            end
                            task.wait()
                        end

                        if rootPart and originalCFrame then
                            rootPart.CFrame = originalCFrame
                        end
                    end
                end
            end
            task.wait()
        end
    end
})

-- ==================== AUTO ANDAR E PEGAR + DROP POR INATIVIDADE ====================
local walkPickUpSpeed = 50

Main:CreateToggle({
    Name = "Auto Andar e Pegar",
    CurrentValue = false,
    Flag = "Toggle5",
    Callback = function(Value)
        _G.AutoWalkPickUp = Value
        if not Value then return end

        -- Thread de inatividade
        task.spawn(function()
            local lastPos = nil
            local idleTime = 0
            local dropCFrame = CFrame.new(
                293.7734375, 18.536102294921875, 268.0876770019531,
                0.763247549533844, -2.8403025709167196e-08, 0.6461061239242554,
                3.596164432906335e-08, 1, 1.478682287725519e-09,
                -0.6461061239242554, 2.2106439345748186e-08, 0.763247549533844
            )

            while _G.AutoWalkPickUp do
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")

                if root then
                    local currentPos = root.Position
                    if lastPos and (currentPos - lastPos).Magnitude <= 1 then
                        idleTime += task.wait()
                    else
                        idleTime = 0
                    end
                    lastPos = currentPos

                    if idleTime >= 3 then
                        ReplicatedStorage.NukeRemotes.Drop:FireServer(dropCFrame)
                        idleTime = 0
                    end
                end
                task.wait(0.5)
            end
        end)

        -- Loop principal (anti-quebra com WASD)
        while _G.AutoWalkPickUp do
            local myBase = GetPlayerBase()
            local character = LocalPlayer.Character
            local hum = character and character:FindFirstChildOfClass("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")

            if not myBase or not hum or not root then
                task.wait(0.5)
                continue
            end

            local nukeCounts = {}
            local nukeList = {}
            for _, nuke in ipairs(myBase.Nukes:GetChildren()) do
                if nuke.Name == "Nuke" and nuke:FindFirstChild("OverheadNuke") and nuke.OverheadNuke:FindFirstChild("TextLabel") then
                    local nukeType = nuke.OverheadNuke.TextLabel.Text
                    if nukeType and nukeType ~= "" then
                        if not nukeCounts[nukeType] then
                            nukeCounts[nukeType] = {}
                        end
                        table.insert(nukeCounts[nukeType], nuke)
                        table.insert(nukeList, nuke)
                    end
                end
            end

            for _, nuke in ipairs(nukeList) do
                if not _G.AutoWalkPickUp or not nuke.Parent then break end
                local nukeType = nuke.OverheadNuke.TextLabel.Text
                local matchCount = nukeCounts[nukeType] and #nukeCounts[nukeType] or 0

                local targetPos = nuke:GetPivot().Position
                local PickUpEvent = ReplicatedStorage.NukeRemotes.PickUp
                local DropEvent = ReplicatedStorage.NukeRemotes.Drop

                hum.WalkSpeed = walkPickUpSpeed

                while _G.AutoWalkPickUp and nuke.Parent and root.Parent do
                    hum:MoveTo(targetPos)
                    local dist = (root.Position - targetPos).Magnitude
                    if dist < 5 then
                        PickUpEvent:FireServer(nuke)
                        task.wait(0.1)

                        if matchCount < 2 then
                            DropEvent:FireServer(root.CFrame)
                            task.wait(0.1)
                        end

                        break
                    end
                    task.wait()
                end

                if not _G.AutoWalkPickUp then break end
            end

            task.wait(0.5)
        end
    end
})

Main:CreateSlider({
    Name = "Velocidade de Caminhada",
    Range = {16, 160},
    Increment = 1,
    Suffix = "studs/s",
    CurrentValue = 50,
    Flag = "WalkPickUpSpeedSlider",
    Callback = function(Value)
        walkPickUpSpeed = Value
    end
})

-- ==================== PEGAR INSTANTÂNEO ====================
Main:CreateToggle({
    Name = "Pegar Instantâneo",
    CurrentValue = false,
    Flag = "InstantPickUp",
    Callback = function(Value)
        _G.InstantPickUp = Value

        task.spawn(function()
            local PickUpEvent = ReplicatedStorage.NukeRemotes.PickUp
            local DropEvent = ReplicatedStorage.NukeRemotes.Drop

            while _G.InstantPickUp do
                local myBase = GetPlayerBase()

                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    DropEvent:FireServer(root.CFrame)
                end

                if myBase and myBase:FindFirstChild("Nukes") then
                    local lista = {}

                    for _, nuke in ipairs(myBase.Nukes:GetChildren()) do
                        if nuke.Name == "Nuke" and nuke.Parent then
                            table.insert(lista, nuke)
                        end
                    end

                    for i = #lista, 2, -1 do
                        local j = math.random(i)
                        lista[i], lista[j] = lista[j], lista[i]
                    end

                    for _, nuke in ipairs(lista) do
                        if not _G.InstantPickUp then break end
                        if nuke and nuke.Parent then
                            PickUpEvent:FireServer(nuke)
                            task.wait(0.01)
                        end
                    end
                end

                task.wait(0.05)
            end
        end)
    end
})

-- ==================== AUTO TRAVAR BASE ====================
Main:CreateToggle({
    Name = "Auto Travar Base",
    CurrentValue = false,
    Flag = "Toggle3",
    Callback = function(Value)
        lock = Value
        while lock do
            task.wait()
            ReplicatedStorage.NukeRemotes.RequestLockBase:FireServer()
        end
    end,
})

-- ==================== SELEÇÃO DE UPGRADES + AUTO UPGRADE ====================
Main:CreateDropdown({
    Name = "Selecionar Upgrades",
    Options = {"MAX", "TIER", "LOCKBASE"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "Dropdown1",
    Callback = function(Options)
        SelectedUpgrades = Options
    end,
})

Main:CreateToggle({
    Name = "Auto Upgrade",
    CurrentValue = false,
    Flag = "Toggle4",
    Callback = function(Value)
        _G.AutoUpgrade = Value
        while _G.AutoUpgrade do
            local Event = ReplicatedStorage.NukeRemotes.PurchaseUpgrade
            for _, upgradeType in ipairs(SelectedUpgrades) do
                if not _G.AutoUpgrade then break end
                Event:FireServer(upgradeType)
            end
            task.wait()
        end
    end,
})

-- ==================== ABA UNIVERSAL ====================
shared.InfJumpEnabled = false
shared.FlyEnabled = false
shared.EspEnabled = false
shared.NoclipEnabled = false
shared.FlySpeed = 50

shared.WalkSpeedEnabled = false
shared.JumpPowerEnabled = false
shared.TargetWalkSpeed = 16
shared.TargetJumpPower = 50

shared.FlyConnection = nil
shared.NoclipConnection = nil
shared.EspConnections = {}
shared.EspFolder = Workspace:FindFirstChild("RANOXESP") or Instance.new("Folder", Workspace)
shared.EspFolder.Name = "RANOXESP"

UniversalTab:CreateSection("Modificações de Movimento")

UniversalTab:CreateSlider({
    Name = "Velocidade",
    Range = {16, 250},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        shared.TargetWalkSpeed = Value
        if shared.WalkSpeedEnabled then
            local Char = LocalPlayer.Character
            local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
            if Hum then Hum.WalkSpeed = Value end
        end
    end,
})

UniversalTab:CreateToggle({
    Name = "Ativar Velocidade",
    CurrentValue = false,
    Flag = "WalkSpeedToggle",
    Callback = function(Value)
        shared.WalkSpeedEnabled = Value
        if not Value then
            local Char = LocalPlayer.Character
            local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
            if Hum then Hum.WalkSpeed = 16 end
        end
    end,
})

UniversalTab:CreateSlider({
    Name = "Pulo",
    Range = {50, 500},
    Increment = 1,
    Suffix = "Power",
    CurrentValue = 50,
    Flag = "JumpPowerSlider",
    Callback = function(Value)
        shared.TargetJumpPower = Value
        if shared.JumpPowerEnabled then
            local Char = LocalPlayer.Character
            local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
            if Hum then
                Hum.UseJumpPower = true
                Hum.JumpPower = Value
            end
        end
    end,
})

UniversalTab:CreateToggle({
    Name = "Ativar Pulo",
    CurrentValue = false,
    Flag = "JumpPowerToggle",
    Callback = function(Value)
        shared.JumpPowerEnabled = Value
        if not Value then
            local Char = LocalPlayer.Character
            local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
            if Hum then
                Hum.JumpPower = 50
            end
        end
    end,
})

RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    if not Hum then return end

    if shared.WalkSpeedEnabled then
        if Hum.WalkSpeed ~= shared.TargetWalkSpeed then
            Hum.WalkSpeed = shared.TargetWalkSpeed
        end
    end

    if shared.JumpPowerEnabled then
        if not Hum.UseJumpPower then
            Hum.UseJumpPower = true
        end
        if Hum.JumpPower ~= shared.TargetJumpPower then
            Hum.JumpPower = shared.TargetJumpPower
        end
    end
end)

UniversalTab:CreateToggle({
    Name = "Pulo Infinito",
    CurrentValue = false,
    Flag = "InfJumpToggle",
    Callback = function(Value)
        shared.InfJumpEnabled = Value
    end,
})

UserInputService.JumpRequest:Connect(function()
    if shared.InfJumpEnabled then
        local Char = LocalPlayer.Character
        local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
        if Hum then Hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

UniversalTab:CreateSection("Movimento Avançado")

UniversalTab:CreateSlider({
    Name = "Velocidade de Voo",
    Range = {10, 300},
    Increment = 5,
    Suffix = "Studs",
    CurrentValue = 50,
    Flag = "FlySpeedSlider",
    Callback = function(Value)
        shared.FlySpeed = Value
    end,
})

shared.HandleFlight = function()
    local Camera = Workspace.CurrentCamera
    local Character = LocalPlayer.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    local Hum = Character and Character:FindFirstChildOfClass("Humanoid")

    if not Root or not Hum then return end

    local BVel = Root:FindFirstChild("RANOXFlyForce") or Instance.new("BodyVelocity")
    BVel.Name = "RANOXFlyForce"
    BVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    BVel.Parent = Root

    local LGyro = Root:FindFirstChild("RANOXFlyGyro") or Instance.new("BodyGyro")
    LGyro.Name = "RANOXFlyGyro"
    LGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    LGyro.CFrame = Root.CFrame
    LGyro.Parent = Root

    Hum.PlatformStand = true

    shared.FlyConnection = RunService.RenderStepped:Connect(function()
        if not shared.FlyEnabled or not Character or not Root.Parent then
            BVel:Destroy()
            LGyro:Destroy()
            if Hum then Hum.PlatformStand = false end
            if shared.FlyConnection then shared.FlyConnection:Disconnect() end
            return
        end

        local Dir = Vector3.new(0,0,0)
        local CamCFrame = Camera.CFrame

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then Dir = Dir + CamCFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then Dir = Dir - CamCFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then Dir = Dir - CamCFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then Dir = Dir + CamCFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then Dir = Dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then Dir = Dir - Vector3.new(0, 1, 0) end

        BVel.Velocity = Dir.Magnitude > 0 and Dir.Unit * shared.FlySpeed or Vector3.new(0,0,0)
        LGyro.CFrame = CamCFrame
    end)
end

UniversalTab:CreateToggle({
    Name = "Voar",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        shared.FlyEnabled = Value
        if shared.FlyEnabled then
            shared.HandleFlight()
        else
            if shared.FlyConnection then shared.FlyConnection:Disconnect() end
            local Char = LocalPlayer.Character
            local Root = Char and Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
            if Root then
                if Root:FindFirstChild("RANOXFlyForce") then Root.RANOXFlyForce:Destroy() end
                if Root:FindFirstChild("RANOXFlyGyro") then Root.RANOXFlyGyro:Destroy() end
            end
            if Hum then Hum.PlatformStand = false end
        end
    end,
})

UniversalTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value)
        shared.NoclipEnabled = Value
        if shared.NoclipEnabled then
            shared.NoclipConnection = RunService.Stepped:Connect(function()
                if not shared.NoclipEnabled then
                    if shared.NoclipConnection then shared.NoclipConnection:Disconnect() end
                    return
                end
                if LocalPlayer.Character then
                    for _, Part in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if Part:IsA("BasePart") and Part.CanCollide then
                            Part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if shared.NoclipConnection then shared.NoclipConnection:Disconnect() end
        end
    end,
})

UniversalTab:CreateSection("Visuais")

local function CleanUpPlayerESP(Player)
    if shared.EspConnections[Player] then
        for _, Connection in ipairs(shared.EspConnections[Player]) do
            Connection:Disconnect()
        end
        shared.EspConnections[Player] = nil
    end
    if shared.EspFolder then
        local Container = shared.EspFolder:FindFirstChild(Player.Name)
        if Container then Container:Destroy() end
    end
end

local function ConstructFullESP(Player)
    if Player == LocalPlayer then return end
    CleanUpPlayerESP(Player)

    shared.EspConnections[Player] = {}
    if not shared.EspFolder then return end

    local Container = Instance.new("Folder")
    Container.Name = Player.Name
    Container.Parent = shared.EspFolder

    local function CreateNameTag(Char)
        if not Char then return end
        local Root = Char:WaitForChild("HumanoidRootPart", 5)
        if not Root then return end

        local BbGui = Instance.new("BillboardGui")
        BbGui.Name = "EspNameTag"
        BbGui.AlwaysOnTop = true
        BbGui.Size = UDim2.new(0, 200, 0, 50)
        BbGui.StudsOffset = Vector3.new(0, 3, 0)
        BbGui.Adornee = Root
        BbGui.Parent = Container

        local TextLabel = Instance.new("TextLabel")
        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.Text = Player.Name
        TextLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        TextLabel.TextSize = 14
        TextLabel.Font = Enum.Font.SourceSansBold
        TextLabel.TextStrokeTransparency = 0
        TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel.Parent = BbGui
    end

    if Player.Character then CreateNameTag(Player.Character) end

    local CharAdded = Player.CharacterAdded:Connect(function(Char)
        task.wait(0.5)
        CreateNameTag(Char)
    end)
    table.insert(shared.EspConnections[Player], CharAdded)
end

UniversalTab:CreateToggle({
    Name = "ESP dos Jogadores",
    CurrentValue = false,
    Flag = "EspToggle",
    Callback = function(Value)
        shared.EspEnabled = Value
        if shared.EspEnabled then
            for _, Player in ipairs(Players:GetPlayers()) do
                ConstructFullESP(Player)
            end
            shared.PlayerAddedConn = Players.PlayerAdded:Connect(ConstructFullESP)
            shared.PlayerRemovingConn = Players.PlayerRemoving:Connect(CleanUpPlayerESP)
        else
            if shared.PlayerAddedConn then shared.PlayerAddedConn:Disconnect() end
            if shared.PlayerRemovingConn then shared.PlayerRemovingConn:Disconnect() end
            for _, Player in ipairs(Players:GetPlayers()) do
                CleanUpPlayerESP(Player)
            end
        end
    end,
})

-- ==================== ABA CONFIGURAÇÕES ====================
ConfigTab:CreateSection("Utilidades Gerais")

ConfigTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(Value)
        if Value then
            local VirtualUser = game:GetService("VirtualUser")
            LocalPlayer.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end
})

ConfigTab:CreateToggle({
    Name = "Modo Leve (FPS Boost)",
    CurrentValue = false,
    Flag = "LowGraphics",
    Callback = function(Value)
        if Value then
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("Bloom") or v:IsA("SunRays") or v:IsA("ColorCorrection") then
                    v.Enabled = false
                end
            end
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                    v.Enabled = false
                end
            end
            workspace.Terrain.TextureGrid = Enum.TerrainTextureGrid.NoTexture
        else
            Lighting.GlobalShadows = true
            Lighting.FogEnd = 500
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("Bloom") or v:IsA("SunRays") or v:IsA("ColorCorrection") then
                    v.Enabled = true
                end
            end
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                    v.Enabled = true
                end
            end
            workspace.Terrain.TextureGrid = Enum.TerrainTextureGrid.Default
        end
    end
})

ConfigTab:CreateToggle({
    Name = "Mostrar FPS",
    CurrentValue = false,
    Flag = "FPSDisplay",
    Callback = function(Value)
        if Value then
            local fpsGui = Instance.new("ScreenGui")
            fpsGui.Name = "RANOX_FPS"
            fpsGui.Parent = LocalPlayer.PlayerGui

            local fpsLabel = Instance.new("TextLabel")
            fpsLabel.Name = "FPS_Label"
            fpsLabel.AnchorPoint = Vector2.new(1, 0)
            fpsLabel.Position = UDim2.new(1, -10, 0, 10)
            fpsLabel.Size = UDim2.new(0, 100, 0, 20)
            fpsLabel.BackgroundTransparency = 1
            fpsLabel.TextColor3 = Color3.new(1, 1, 1)
            fpsLabel.TextStrokeTransparency = 0
            fpsLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            fpsLabel.Text = "FPS: ..."
            fpsLabel.Parent = fpsGui

            local lastUpdate = 0
            local frameCount = 0
            RunService.RenderStepped:Connect(function(delta)
                frameCount = frameCount + 1
                if tick() - lastUpdate >= 0.5 then
                    local fps = math.round(frameCount / (tick() - lastUpdate))
                    fpsLabel.Text = "FPS: " .. fps
                    lastUpdate = tick()
                    frameCount = 0
                end
            end)
        else
            local gui = LocalPlayer.PlayerGui:FindFirstChild("RANOX_FPS")
            if gui then gui:Destroy() end
        end
    end
})

ConfigTab:CreateToggle({
    Name = "Mostrar Ping",
    CurrentValue = false,
    Flag = "PingDisplay",
    Callback = function(Value)
        if Value then
            local pingGui = Instance.new("ScreenGui")
            pingGui.Name = "RANOX_PING"
            pingGui.Parent = LocalPlayer.PlayerGui

            local pingLabel = Instance.new("TextLabel")
            pingLabel.AnchorPoint = Vector2.new(1, 0)
            pingLabel.Position = UDim2.new(1, -10, 0, 35)
            pingLabel.Size = UDim2.new(0, 100, 0, 20)
            pingLabel.BackgroundTransparency = 1
            pingLabel.TextColor3 = Color3.new(1, 1, 1)
            pingLabel.TextStrokeTransparency = 0
            pingLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            pingLabel.Text = "Ping: ..."
            pingLabel.Parent = pingGui

            task.spawn(function()
                while true do
                    if not LocalPlayer.PlayerGui:FindFirstChild("RANOX_PING") then break end
                    local ping = Stats:FindFirstChild("PerformanceStats") and Stats.PerformanceStats:FindFirstChild("Ping")
                    if ping then
                        pingLabel.Text = "Ping: " .. ping:GetValue() .. " ms"
                    end
                    task.wait(1)
                end
            end)
        else
            local gui = LocalPlayer.PlayerGui:FindFirstChild("RANOX_PING")
            if gui then gui:Destroy() end
        end
    end
})

ConfigTab:CreateButton({
    Name = "Limpar Terreno",
    Callback = function()
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
                if v.Name:lower():find("grass") or v.Name:lower():find("rock") or v.Name:lower():find("tree") or v.Name:lower():find("bush") then
                    v:Destroy()
                end
            end
        end
        Rayfield:Notify({
            Title = "RANOX",
            Content = "Terreno limpo!",
            Duration = 2,
            Image = 4483362458,
        })
    end
})

-- ==================== CRÉDITOS ====================
CreditsTab:CreateSection("Comunidade")

CreditsTab:CreateButton({
    Name = "Copiar YouTube",
    Callback = function()
        setclipboard("https://youtube.com/@rnox_ofc123?si=K9qUjgf5XzMgwU_9")
        Rayfield:Notify({
            Title = "Sucesso",
            Content = "Link do Discord copiado!",
            Duration = 3,
            Image = 4483362458,
        })
    end
})

-- ==================== MANTER AJUSTES APÓS RESPAWN ====================
LocalPlayer.CharacterAdded:Connect(function(Character)
    local Humanoid = Character:WaitForChild("Humanoid")
    task.wait(0.5)

    if Rayfield.Flags["WalkSpeedSlider"] then
        Humanoid.WalkSpeed = Rayfield.Flags["WalkSpeedSlider"].CurrentValue
    end
    if Rayfield.Flags["JumpPowerSlider"] then
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = Rayfield.Flags["JumpPowerSlider"].CurrentValue
    end
    if shared.FlyEnabled then
        shared.HandleFlight()
    end
end)
