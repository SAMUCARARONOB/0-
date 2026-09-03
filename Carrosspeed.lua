--[[
    CAR WHEEL BOOST DETECTOR - v4.1 (ONLY_FORWARD corrigido)
    - Boost apenas para frente com margem para aceleração inicial
    - Destaque especial no carro do jogador (⭐ VOCÊ)
]]

-- ============================================
-- Serviços
-- ============================================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- ============================================
-- Anti-Duplicata
-- ============================================
if _G.CarWheelBoostDetectorRunning then
    script:Destroy()
    return
end
_G.CarWheelBoostDetectorRunning = true
script.Destroying:Connect(function()
    _G.CarWheelBoostDetectorRunning = nil
end)

-- ============================================
-- Configurações Globais
-- ============================================
_G.CarWheelBoostConfig = _G.CarWheelBoostConfig or {
    ACCELERATION_RATE = 20,
    MAX_ROT_VELOCITY = 650,
    BOOST_DURATION = 2,
    PAUSE_DURATION = 1,
    ONLY_FORWARD = true
}

-- ============================================
-- Tema
-- ============================================
local theme = {
    background = Color3.fromRGB(12, 12, 20),
    surface = Color3.fromRGB(18, 18, 28),
    surface2 = Color3.fromRGB(25, 25, 38),
    surface3 = Color3.fromRGB(32, 32, 48),
    accent = Color3.fromRGB(255, 60, 60),
    accent2 = Color3.fromRGB(255, 150, 0),
    text = Color3.fromRGB(230, 230, 240),
    textDim = Color3.fromRGB(160, 160, 180),
    border = Color3.fromRGB(40, 40, 55),
    green = Color3.fromRGB(80, 200, 120),
    red = Color3.fromRGB(255, 80, 80),
    blue = Color3.fromRGB(100, 150, 255),
    gold = Color3.fromRGB(255, 215, 0)
}

local isMobile = UserInputService.TouchEnabled

-- ============================================
-- Variáveis de Estado
-- ============================================
local activeCars = {}
local carListOrder = {}
local selectedCar = nil
local currentTab = "Detector"
local playerCar = nil
local boostTimers = {}

-- ============================================
-- Salvamento
-- ============================================
local function saveDetectedCars()
    local saveData = {}
    for _, car in ipairs(carListOrder) do
        local data = activeCars[car]
        if data then
            table.insert(saveData, {
                name = car.Name,
                fullName = car:GetFullName(),
                wheels = #data.parts
            })
        end
    end
    pcall(function()
        if writefile then
            writefile("car_boost_detector_save.json", game:GetService("HttpService"):JSONEncode(saveData))
        end
    end)
    _G.SavedCarList = saveData
end

local function loadDetectedCars()
    local saveData = nil
    pcall(function()
        if readfile then
            local content = readfile("car_boost_detector_save.json")
            if content then
                saveData = game:GetService("HttpService"):JSONDecode(content)
            end
        end
    end)
    if not saveData then
        saveData = _G.SavedCarList
    end
    return saveData or {}
end

-- ============================================
-- Interface Gráfica
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CarWheelBoostDetectorGUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = isMobile and UDim2.new(0, 600, 0, 550) or UDim2.new(0, 850, 0, 600)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = theme.surface
MainFrame.BorderColor3 = theme.accent
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local TopLine = Instance.new("Frame")
TopLine.Size = UDim2.new(1, 0, 0, 3)
TopLine.BackgroundColor3 = theme.accent
TopLine.BorderSizePixel = 0
TopLine.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.Position = UDim2.new(0, 0, 0, 3)
Header.BackgroundColor3 = theme.background
Header.BorderSizePixel = 0
Header.Parent = MainFrame
local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 14)
HeaderCorner.Parent = Header

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
})
HeaderGradient.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.Text = "⚡ CAR WHEEL BOOST"
Title.TextColor3 = theme.accent
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local originalTitleSize = Title.Size
local originalTitleText = "⚡️CAR Dealership Tycoon WHEEL BOOST"

local StatusBadge = Instance.new("TextLabel")
StatusBadge.Size = UDim2.new(0, 30, 0, 20)
StatusBadge.Position = UDim2.new(0, 220, 0.5, -10)
StatusBadge.Text = "0"
StatusBadge.TextColor3 = Color3.new(1, 1, 1)
StatusBadge.BackgroundColor3 = theme.accent
StatusBadge.BorderSizePixel = 0
StatusBadge.Font = Enum.Font.GothamBold
StatusBadge.TextSize = 14
StatusBadge.Parent = Header
local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(1, 0)
BadgeCorner.Parent = StatusBadge

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 36, 0, 36)
MinimizeBtn.Position = UDim2.new(1, -85, 0.5, -18)
MinimizeBtn.Text = "−"
MinimizeBtn.BackgroundColor3 = theme.surface3
MinimizeBtn.TextColor3 = theme.text
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 22
MinimizeBtn.ZIndex = 2
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.Parent = Header
local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 10)
MinimizeCorner.Parent = MinimizeBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 36, 0, 36)
CloseBtn.Position = UDim2.new(1, -42, 0.5, -18)
CloseBtn.Text = "✕"
CloseBtn.BackgroundColor3 = theme.surface3
CloseBtn.TextColor3 = theme.text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.ZIndex = 2
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = CloseBtn

MinimizeBtn.MouseEnter:Connect(function()
    TweenService:Create(MinimizeBtn, TweenInfo.new(0.2), {BackgroundColor3 = theme.accent}):Play()
end)
MinimizeBtn.MouseLeave:Connect(function()
    TweenService:Create(MinimizeBtn, TweenInfo.new(0.2), {BackgroundColor3 = theme.surface3}):Play()
end)
CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = theme.red}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = theme.surface3}):Play()
end)

-- Corpo
local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, 0, 1, -53)
Body.Position = UDim2.new(0, 0, 0, 53)
Body.BackgroundTransparency = 1
Body.Parent = MainFrame

-- Tabs
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 40)
TabBar.BackgroundColor3 = theme.surface2
TabBar.BorderSizePixel = 0
TabBar.Parent = Body

local TabDetector = Instance.new("TextButton")
TabDetector.Size = UDim2.new(0.5, 0, 1, 0)
TabDetector.Text = "🚗 DETECTOR"
TabDetector.Font = Enum.Font.GothamBold
TabDetector.TextSize = 14
TabDetector.BackgroundColor3 = theme.accent
TabDetector.TextColor3 = Color3.new(1, 1, 1)
TabDetector.BorderSizePixel = 0
TabDetector.AutoButtonColor = false
TabDetector.Parent = TabBar

local TabConfig = Instance.new("TextButton")
TabConfig.Size = UDim2.new(0.5, 0, 1, 0)
TabConfig.Position = UDim2.new(0.5, 0, 0, 0)
TabConfig.Text = "⚙️ CONFIG"
TabConfig.Font = Enum.Font.GothamBold
TabConfig.TextSize = 14
TabConfig.BackgroundColor3 = theme.surface2
TabConfig.TextColor3 = theme.textDim
TabConfig.BorderSizePixel = 0
TabConfig.AutoButtonColor = false
TabConfig.Parent = TabBar

-- Páginas
local DetectorPage = Instance.new("Frame")
DetectorPage.Size = UDim2.new(1, 0, 1, -40)
DetectorPage.Position = UDim2.new(0, 0, 0, 40)
DetectorPage.BackgroundTransparency = 1
DetectorPage.Parent = Body

local ConfigPage = Instance.new("Frame")
ConfigPage.Size = UDim2.new(1, 0, 1, -40)
ConfigPage.Position = UDim2.new(0, 0, 0, 40)
ConfigPage.BackgroundTransparency = 1
ConfigPage.Visible = false
ConfigPage.Parent = Body

TabDetector.MouseButton1Click:Connect(function()
    DetectorPage.Visible = true
    ConfigPage.Visible = false
    TabDetector.BackgroundColor3 = theme.accent
    TabDetector.TextColor3 = Color3.new(1, 1, 1)
    TabConfig.BackgroundColor3 = theme.surface2
    TabConfig.TextColor3 = theme.textDim
end)

TabConfig.MouseButton1Click:Connect(function()
    DetectorPage.Visible = false
    ConfigPage.Visible = true
    TabConfig.BackgroundColor3 = theme.accent
    TabConfig.TextColor3 = Color3.new(1, 1, 1)
    TabDetector.BackgroundColor3 = theme.surface2
    TabDetector.TextColor3 = theme.textDim
end)

-- Painel Esquerdo (Lista de Carros)
local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0.35, 0, 1, 0)
LeftPanel.BackgroundColor3 = theme.background
LeftPanel.BorderSizePixel = 0
LeftPanel.Parent = DetectorPage
local LeftCorner = Instance.new("UICorner")
LeftCorner.CornerRadius = UDim.new(0, 10)
LeftCorner.Parent = LeftPanel

local LeftHeader = Instance.new("Frame")
LeftHeader.Size = UDim2.new(1, 0, 0, 40)
LeftHeader.BackgroundColor3 = theme.surface2
LeftHeader.BorderSizePixel = 0
LeftHeader.Parent = LeftPanel
local LeftHeaderLabel = Instance.new("TextLabel")
LeftHeaderLabel.Size = UDim2.new(1, -10, 1, 0)
LeftHeaderLabel.Position = UDim2.new(0, 10, 0, 0)
LeftHeaderLabel.Text = "🚗 CARROS DETECTADOS"
LeftHeaderLabel.TextColor3 = theme.accent2
LeftHeaderLabel.BackgroundTransparency = 1
LeftHeaderLabel.Font = Enum.Font.GothamBold
LeftHeaderLabel.TextSize = 13
LeftHeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
LeftHeaderLabel.Parent = LeftHeader

-- ScrollingFrame da lista
local CarsList = Instance.new("ScrollingFrame")
CarsList.Size = UDim2.new(1, -10, 1, -50)
CarsList.Position = UDim2.new(0, 5, 0, 45)
CarsList.BackgroundColor3 = theme.background
CarsList.BorderSizePixel = 0
CarsList.ScrollBarThickness = 5
CarsList.ScrollBarImageColor3 = theme.accent
CarsList.CanvasSize = UDim2.new(0, 0, 0, 0)
CarsList.AutomaticCanvasSize = Enum.AutomaticSize.None
CarsList.ClipsDescendants = true
CarsList.ScrollingDirection = Enum.ScrollingDirection.Y
CarsList.Parent = LeftPanel

local CarsGrid = Instance.new("UIGridLayout")
CarsGrid.SortOrder = Enum.SortOrder.LayoutOrder
CarsGrid.CellSize = UDim2.new(1, -10, 0, 50)
CarsGrid.CellPadding = UDim2.new(0, 0, 0, 5)
CarsGrid.Parent = CarsList

-- Painel Direito
local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(0.65, -6, 1, 0)
RightPanel.Position = UDim2.new(0.35, 6, 0, 0)
RightPanel.BackgroundColor3 = theme.background
RightPanel.BorderSizePixel = 0
RightPanel.Parent = DetectorPage
local RightCorner = Instance.new("UICorner")
RightCorner.CornerRadius = UDim.new(0, 10)
RightCorner.Parent = RightPanel

local RightHeader = Instance.new("Frame")
RightHeader.Size = UDim2.new(1, 0, 0, 40)
RightHeader.BackgroundColor3 = theme.surface2
RightHeader.BorderSizePixel = 0
RightHeader.Parent = RightPanel
local RightHeaderLabel = Instance.new("TextLabel")
RightHeaderLabel.Size = UDim2.new(1, -10, 1, 0)
RightHeaderLabel.Position = UDim2.new(0, 10, 0, 0)
RightHeaderLabel.Text = "⚙️ DETALHES DO CARRO"
RightHeaderLabel.TextColor3 = theme.accent2
RightHeaderLabel.BackgroundTransparency = 1
RightHeaderLabel.Font = Enum.Font.GothamBold
RightHeaderLabel.TextSize = 13
RightHeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
RightHeaderLabel.Parent = RightHeader

local DetailFrame = Instance.new("Frame")
DetailFrame.Size = UDim2.new(1, -20, 0, 140)
DetailFrame.Position = UDim2.new(0, 10, 0, 50)
DetailFrame.BackgroundColor3 = theme.surface2
DetailFrame.BorderSizePixel = 0
DetailFrame.Parent = RightPanel
local DetailCorner = Instance.new("UICorner")
DetailCorner.CornerRadius = UDim.new(0, 10)
DetailCorner.Parent = DetailFrame

local DetailGradient = Instance.new("UIGradient")
DetailGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, theme.surface3),
    ColorSequenceKeypoint.new(1, theme.surface2)
})
DetailGradient.Parent = DetailFrame

local CarNameLabel = Instance.new("TextLabel")
CarNameLabel.Size = UDim2.new(1, -20, 0.4, 0)
CarNameLabel.Position = UDim2.new(0, 10, 0, 10)
CarNameLabel.Text = "Nenhum carro selecionado"
CarNameLabel.TextColor3 = theme.text
CarNameLabel.BackgroundTransparency = 1
CarNameLabel.Font = Enum.Font.GothamBold
CarNameLabel.TextSize = 16
CarNameLabel.TextXAlignment = Enum.TextXAlignment.Left
CarNameLabel.Parent = DetailFrame

local WheelInfoLabel = Instance.new("TextLabel")
WheelInfoLabel.Size = UDim2.new(1, -20, 0.3, 0)
WheelInfoLabel.Position = UDim2.new(0, 10, 0.4, 0)
WheelInfoLabel.Text = "🛞 Rodas: 0"
WheelInfoLabel.TextColor3 = theme.textDim
WheelInfoLabel.BackgroundTransparency = 1
WheelInfoLabel.Font = Enum.Font.Gotham
WheelInfoLabel.TextSize = 14
WheelInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
WheelInfoLabel.Parent = DetailFrame

local BoostStatusLabel = Instance.new("TextLabel")
BoostStatusLabel.Size = UDim2.new(1, -20, 0.3, 0)
BoostStatusLabel.Position = UDim2.new(0, 10, 0.7, 0)
BoostStatusLabel.Text = "Status: 🔴 Inativo"
BoostStatusLabel.TextColor3 = theme.textDim
BoostStatusLabel.BackgroundTransparency = 1
BoostStatusLabel.Font = Enum.Font.Gotham
BoostStatusLabel.TextSize = 14
BoostStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
BoostStatusLabel.Parent = DetailFrame

local BoostToggleBtn = Instance.new("TextButton")
BoostToggleBtn.Size = UDim2.new(0.5, 0, 0, 45)
BoostToggleBtn.Position = UDim2.new(0, 10, 0, 200)
BoostToggleBtn.Text = "🚀 ATIVAR BOOST"
BoostToggleBtn.Font = Enum.Font.GothamBold
BoostToggleBtn.TextSize = 15
BoostToggleBtn.BackgroundColor3 = theme.surface3
BoostToggleBtn.TextColor3 = theme.text
BoostToggleBtn.BorderSizePixel = 0
BoostToggleBtn.AutoButtonColor = false
BoostToggleBtn.Parent = RightPanel
local BoostToggleCorner = Instance.new("UICorner")
BoostToggleCorner.CornerRadius = UDim.new(0, 10)
BoostToggleCorner.Parent = BoostToggleBtn

local BoostIndicator = Instance.new("Frame")
BoostIndicator.Size = UDim2.new(0.4, 0, 0, 45)
BoostIndicator.Position = UDim2.new(0.55, 10, 0, 200)
BoostIndicator.BackgroundColor3 = theme.surface2
BoostIndicator.BorderSizePixel = 0
BoostIndicator.Parent = RightPanel
local BoostIndicatorCorner = Instance.new("UICorner")
BoostIndicatorCorner.CornerRadius = UDim.new(0, 10)
BoostIndicatorCorner.Parent = BoostIndicator

local BoostIndicatorBar = Instance.new("Frame")
BoostIndicatorBar.Size = UDim2.new(0, 0, 1, 0)
BoostIndicatorBar.BackgroundColor3 = theme.green
BoostIndicatorBar.BorderSizePixel = 0
BoostIndicatorBar.Parent = BoostIndicator
local BoostIndicatorBarCorner = Instance.new("UICorner")
BoostIndicatorBarCorner.CornerRadius = UDim.new(0, 10)
BoostIndicatorBarCorner.Parent = BoostIndicatorBar

local BoostIndicatorLabel = Instance.new("TextLabel")
BoostIndicatorLabel.Size = UDim2.new(1, 0, 1, 0)
BoostIndicatorLabel.Text = "0%"
BoostIndicatorLabel.TextColor3 = Color3.new(1, 1, 1)
BoostIndicatorLabel.BackgroundTransparency = 1
BoostIndicatorLabel.Font = Enum.Font.GothamBold
BoostIndicatorLabel.TextSize = 14
BoostIndicatorLabel.Parent = BoostIndicator

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0.3, 0, 0, 40)
RefreshBtn.Position = UDim2.new(0, 10, 1, -50)
RefreshBtn.Text = "🔄 ATUALIZAR"
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.TextSize = 13
RefreshBtn.BackgroundColor3 = theme.surface3
RefreshBtn.TextColor3 = theme.text
RefreshBtn.BorderSizePixel = 0
RefreshBtn.AutoButtonColor = false
RefreshBtn.Parent = RightPanel
local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 10)
RefreshCorner.Parent = RefreshBtn

RefreshBtn.MouseEnter:Connect(function()
    TweenService:Create(RefreshBtn, TweenInfo.new(0.2), {BackgroundColor3 = theme.accent2}):Play()
end)
RefreshBtn.MouseLeave:Connect(function()
    TweenService:Create(RefreshBtn, TweenInfo.new(0.2), {BackgroundColor3 = theme.surface3}):Play()
end)

-- Página de Configuração
local ConfigTitle = Instance.new("TextLabel")
ConfigTitle.Size = UDim2.new(1, -20, 0, 30)
ConfigTitle.Position = UDim2.new(0, 10, 0, 10)
ConfigTitle.Text = "⚙️ CONFIGURAÇÕES GLOBAIS"
ConfigTitle.TextColor3 = theme.accent
ConfigTitle.BackgroundTransparency = 1
ConfigTitle.Font = Enum.Font.GothamBold
ConfigTitle.TextSize = 18
ConfigTitle.TextXAlignment = Enum.TextXAlignment.Left
ConfigTitle.Parent = ConfigPage

local function createConfigInput(parent, label, posY, default, callback)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 0, 30)
    Label.Position = UDim2.new(0, 20, 0, posY)
    Label.Text = label
    Label.TextColor3 = theme.text
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parent

    local Input = Instance.new("TextBox")
    Input.Size = UDim2.new(0.3, -30, 0, 30)
    Input.Position = UDim2.new(0.55, 20, 0, posY)
    Input.Text = tostring(default)
    Input.Font = Enum.Font.Gotham
    Input.TextSize = 14
    Input.BackgroundColor3 = theme.surface3
    Input.TextColor3 = theme.text
    Input.BorderSizePixel = 0
    Input.TextXAlignment = Enum.TextXAlignment.Center
    Input.Parent = parent
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 8)
    InputCorner.Parent = Input

    Input.FocusLost:Connect(function(enterPressed)
        local num = tonumber(Input.Text)
        if num then
            callback(num)
        else
            Input.Text = tostring(default)
        end
    end)
    return Input
end

createConfigInput(ConfigPage, "Aceleração (rad/s²)", 60, _G.CarWheelBoostConfig.ACCELERATION_RATE, function(val)
    _G.CarWheelBoostConfig.ACCELERATION_RATE = val
end)
createConfigInput(ConfigPage, "Velocidade Máxima (rad/s)", 100, _G.CarWheelBoostConfig.MAX_ROT_VELOCITY, function(val)
    _G.CarWheelBoostConfig.MAX_ROT_VELOCITY = val
end)
createConfigInput(ConfigPage, "Duração Boost (s)", 140, _G.CarWheelBoostConfig.BOOST_DURATION, function(val)
    _G.CarWheelBoostConfig.BOOST_DURATION = val
end)
createConfigInput(ConfigPage, "Duração Pausa (s)", 180, _G.CarWheelBoostConfig.PAUSE_DURATION, function(val)
    _G.CarWheelBoostConfig.PAUSE_DURATION = val
end)

-- Toggle "Apenas Frente"
local OnlyForwardBtn = Instance.new("TextButton")
OnlyForwardBtn.Size = UDim2.new(0.6, 0, 0, 35)
OnlyForwardBtn.Position = UDim2.new(0, 20, 0, 220)
OnlyForwardBtn.Font = Enum.Font.GothamBold
OnlyForwardBtn.TextSize = 14
OnlyForwardBtn.BackgroundColor3 = _G.CarWheelBoostConfig.ONLY_FORWARD and theme.green or theme.surface3
OnlyForwardBtn.TextColor3 = _G.CarWheelBoostConfig.ONLY_FORWARD and Color3.new(1,1,1) or theme.text
OnlyForwardBtn.Text = "🚫 BOOST APENAS PARA FRENTE: " .. (_G.CarWheelBoostConfig.ONLY_FORWARD and "ON" or "OFF")
OnlyForwardBtn.BorderSizePixel = 0
OnlyForwardBtn.AutoButtonColor = false
OnlyForwardBtn.Parent = ConfigPage
local OnlyForwardCorner = Instance.new("UICorner")
OnlyForwardCorner.CornerRadius = UDim.new(0, 8)
OnlyForwardCorner.Parent = OnlyForwardBtn

OnlyForwardBtn.MouseButton1Click:Connect(function()
    _G.CarWheelBoostConfig.ONLY_FORWARD = not _G.CarWheelBoostConfig.ONLY_FORWARD
    OnlyForwardBtn.BackgroundColor3 = _G.CarWheelBoostConfig.ONLY_FORWARD and theme.green or theme.surface3
    OnlyForwardBtn.TextColor3 = _G.CarWheelBoostConfig.ONLY_FORWARD and Color3.new(1,1,1) or theme.text
    OnlyForwardBtn.Text = "🚫 BOOST APENAS PARA FRENTE: " .. (_G.CarWheelBoostConfig.ONLY_FORWARD and "ON" or "OFF")
end)

-- ============================================
-- Funções de Detecção
-- ============================================
local function getWheelParts(car)
    local parts = {}
    local wheelFolders = {
        "FL.Wheel", "FR.Wheel", "RL.Wheel", "RR.Wheel",
        "WheelFL", "WheelFR", "WheelRL", "WheelRR",
        "FL", "FR", "RL", "RR",
    }

    for _, folderPath in ipairs(wheelFolders) do
        local folder = car
        local success = true
        for segment in string.gmatch(folderPath, "[^%.]+") do
            folder = folder:FindFirstChild(segment)
            if not folder then
                success = false
                break
            end
        end
        if success and (folder:IsA("Folder") or folder:IsA("Model")) then
            for _, descendant in ipairs(folder:GetDescendants()) do
                if descendant:IsA("BasePart") and not descendant:IsA("Seat") then
                    local name = descendant.Name:lower()
                    if name:find("wheel") or name:find("tire") or name:find("roda") or name:find("pneu") then
                        table.insert(parts, descendant)
                    end
                end
            end
        end
    end

    if #parts == 0 then
        for _, descendant in ipairs(car:GetDescendants()) do
            if descendant:IsA("BasePart") then
                local name = descendant.Name:lower()
                if name:find("wheel") or name:find("tire") or name:find("roda") or name:find("pneu") then
                    table.insert(parts, descendant)
                end
            end
        end
    end

    if #parts == 0 then
        for _, descendant in ipairs(car:GetDescendants()) do
            if descendant:IsA("HingeConstraint") or descendant:IsA("CylindricalConstraint") then
                local attachment = descendant.Attachment0
                if attachment and attachment.Parent and attachment.Parent:IsA("BasePart") then
                    table.insert(parts, attachment.Parent)
                end
            end
        end
    end

    return parts
end

local function isPlayerCar(car)
    if not car then return false end
    local character = Player.Character
    if not character then return false end

    local carCFrame = car:GetPivot()
    local charCFrame = character:GetPivot()
    local distance = (carCFrame.Position - charCFrame.Position).Magnitude
    if distance < 30 then
        local seats = car:GetDescendants()
        for _, obj in ipairs(seats) do
            if obj:IsA("Seat") and obj.Occupant == character then
                return true
            end
        end
        if car.Name:lower():find(Player.Name:lower()) then
            return true
        end
        for _, obj in ipairs(car:GetDescendants()) do
            if obj:IsA("Humanoid") and obj.Parent and obj.Parent == character then
                return true
            end
        end
    end
    return false
end

local function addCar(car)
    if not car:IsA("Model") and not car:IsA("Folder") then return end
    if activeCars[car] then return end

    local wheelParts = getWheelParts(car)
    if #wheelParts > 0 then
        local mainPart = nil
        -- Tenta achar uma parte principal do carro (não roda) para referência de direção
        if car:IsA("Model") and car.PrimaryPart then
            mainPart = car.PrimaryPart
        else
            for _, descendant in ipairs(car:GetDescendants()) do
                if descendant:IsA("BasePart") and not table.find(wheelParts, descendant) then
                    mainPart = descendant
                    break
                end
            end
            -- Se não achou, tenta a primeira roda como mainPart
            if not mainPart and #wheelParts > 0 then
                mainPart = wheelParts[1]
            end
        end

        activeCars[car] = {
            parts = wheelParts,
            axisStore = {},
            boostEnabled = false,
            mainPart = mainPart
        }
        table.insert(carListOrder, car)
        print("Carro detectado:", car:GetFullName(), "| Rodas:", #wheelParts, "| MainPart:", mainPart and mainPart.Name or "N/A")
        if isPlayerCar(car) then
            playerCar = car
        end
        updateCarsList()
        updateTitle()
    end
end

local function removeCar(car)
    if activeCars[car] then
        activeCars[car] = nil
        boostTimers[car] = nil
        for i, c in ipairs(carListOrder) do
            if c == car then
                table.remove(carListOrder, i)
                break
            end
        end
        if playerCar == car then
            playerCar = nil
            for _, otherCar in ipairs(carListOrder) do
                if isPlayerCar(otherCar) then
                    playerCar = otherCar
                    break
                end
            end
        end
        if selectedCar == car then
            selectedCar = nil
            updateDetailPanel()
        end
        updateCarsList()
        updateTitle()
        saveDetectedCars()
    end
end

-- ============================================
-- Atualização da Interface
-- ============================================
function updateCarsList()
    for _, child in ipairs(CarsList:GetChildren()) do
        if child ~= CarsGrid then
            child:Destroy()
        end
    end

    local sortedOrder = {}
    if playerCar and activeCars[playerCar] then
        table.insert(sortedOrder, playerCar)
    end
    for _, car in ipairs(carListOrder) do
        if car ~= playerCar then
            table.insert(sortedOrder, car)
        end
    end

    for idx, car in ipairs(sortedOrder) do
        local data = activeCars[car]
        if data then
            local isPlayer = (car == playerCar)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 50)
            frame.BackgroundColor3 = car == selectedCar and Color3.fromRGB(60, 60, 80) or (isPlayer and Color3.fromRGB(70, 60, 20) or theme.surface3)
            frame.BorderSizePixel = isPlayer and 2 or 0
            frame.BorderColor3 = isPlayer and theme.gold or theme.border
            frame.LayoutOrder = idx
            frame.Parent = CarsList

            local frameCorner = Instance.new("UICorner")
            frameCorner.CornerRadius = UDim.new(0, 8)
            frameCorner.Parent = frame

            if data.boostEnabled then
                local indicator = Instance.new("Frame")
                indicator.Size = UDim2.new(0, 4, 1, 0)
                indicator.BackgroundColor3 = theme.green
                indicator.BorderSizePixel = 0
                indicator.Parent = frame
                local indCorner = Instance.new("UICorner")
                indCorner.CornerRadius = UDim.new(1, 0)
                indCorner.Parent = indicator
            end

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -15, 0.5, 0)
            nameLabel.Position = UDim2.new(0, 15, 0, 4)
            nameLabel.Text = (isPlayer and "⭐ " or "") .. car.Name
            nameLabel.TextColor3 = isPlayer and theme.gold or theme.text
            nameLabel.BackgroundTransparency = 1
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 14
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            nameLabel.Parent = frame

            local subLabel = Instance.new("TextLabel")
            subLabel.Size = UDim2.new(1, -15, 0.4, 0)
            subLabel.Position = UDim2.new(0, 15, 0.6, 0)
            subLabel.Text = "🛞 " .. #data.parts .. " rodas"
            if isPlayer then
                subLabel.Text = "🛞 " .. #data.parts .. " rodas | 👤 VOCÊ"
            end
            subLabel.TextColor3 = isPlayer and theme.gold or theme.textDim
            subLabel.BackgroundTransparency = 1
            subLabel.Font = Enum.Font.Gotham
            subLabel.TextSize = 12
            subLabel.TextXAlignment = Enum.TextXAlignment.Left
            subLabel.Parent = frame

            frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    selectedCar = car
                    updateCarsList()
                    updateDetailPanel()
                end
            end)
        end
    end

    local itemCount = #sortedOrder
    local itemHeight = 50
    local itemPadding = 5
    local totalHeight = itemCount * itemHeight + (itemCount - 1) * itemPadding
    CarsList.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end

function updateDetailPanel()
    if not selectedCar then
        CarNameLabel.Text = "Nenhum carro selecionado"
        WheelInfoLabel.Text = "🛞 Rodas: 0"
        BoostStatusLabel.Text = "Status: 🔴 Inativo"
        BoostToggleBtn.Text = "🚀 ATIVAR BOOST"
        BoostToggleBtn.BackgroundColor3 = theme.surface3
        return
    end

    local data = activeCars[selectedCar]
    CarNameLabel.Text = selectedCar.Name
    WheelInfoLabel.Text = "🛞 Rodas: " .. #data.parts

    if data.boostEnabled then
        BoostStatusLabel.Text = "Status: 🟢 Ativo"
        BoostStatusLabel.TextColor3 = theme.green
        BoostToggleBtn.Text = "🛑 DESATIVAR BOOST"
        BoostToggleBtn.BackgroundColor3 = theme.red
    else
        BoostStatusLabel.Text = "Status: 🔴 Inativo"
        BoostStatusLabel.TextColor3 = theme.textDim
        BoostToggleBtn.Text = "🚀 ATIVAR BOOST"
        BoostToggleBtn.BackgroundColor3 = theme.surface3
    end
end

function updateTitle()
    local count = #carListOrder
    StatusBadge.Text = tostring(count)
    if not isMinimized then
        Title.Text = originalTitleText
    end
end

-- ============================================
-- Conexões da Interface
-- ============================================
BoostToggleBtn.MouseButton1Click:Connect(function()
    if not selectedCar then return end
    local data = activeCars[selectedCar]
    data.boostEnabled = not data.boostEnabled
    updateDetailPanel()
    updateCarsList()
end)

RefreshBtn.MouseButton1Click:Connect(function()
    for car, data in pairs(activeCars) do
        local newParts = getWheelParts(car)
        if #newParts > 0 then
            data.parts = newParts
        end
    end
    for _, folder in ipairs(foldersToWatch) do
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                addCar(child)
            end
        end
    end
    updateCarsList()
    updateDetailPanel()
    saveDetectedCars()
end)

-- Minimizar
local isMinimized = false
local originalSize = MainFrame.Size
local minimizeTween

local function toggleMinimize()
    isMinimized = not isMinimized
    if minimizeTween then
        minimizeTween:Cancel()
    end

    if isMinimized then
        minimizeTween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
            Size = UDim2.new(0, 250, 0, 53)
        })
        minimizeTween:Play()
        minimizeTween.Completed:Connect(function()
            Body.Visible = false
            Title.Size = UDim2.new(0, 100, 1, 0)
            Title.Text = "RANOX"
            MinimizeBtn.Text = "+"
            StatusBadge.Visible = false
        end)
    else
        Body.Visible = true
        minimizeTween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
            Size = originalSize
        })
        minimizeTween:Play()
        minimizeTween.Completed:Connect(function()
            Title.Size = originalTitleSize
            Title.Text = originalTitleText
            MinimizeBtn.Text = "−"
            StatusBadge.Visible = true
        end)
    end
end
MinimizeBtn.MouseButton1Click:Connect(toggleMinimize)

-- Fechar com bolinha
local BallButton
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    if isMobile then
        if not BallButton then
            BallButton = Instance.new("ImageButton")
            BallButton.Size = UDim2.new(0, 60, 0, 60)
            BallButton.Position = UDim2.new(0, 100, 0, 100)
            BallButton.BackgroundColor3 = theme.accent
            BallButton.BorderSizePixel = 0
            BallButton.Parent = ScreenGui
            local BallCorner = Instance.new("UICorner")
            BallCorner.CornerRadius = UDim.new(1, 0)
            BallCorner.Parent = BallButton
            local BallIcon = Instance.new("ImageLabel")
            BallIcon.Size = UDim2.new(0.7, 0, 0.7, 0)
            BallIcon.Position = UDim2.new(0.15, 0, 0.15, 0)
            BallIcon.BackgroundTransparency = 1
            BallIcon.Image = "rbxassetid://3926307971"
            BallIcon.ImageRectOffset = Vector2.new(324, 364)
            BallIcon.ImageRectSize = Vector2.new(36, 36)
            BallIcon.ImageColor3 = Color3.new(1, 1, 1)
            BallIcon.Parent = BallButton

            local dragBall = false
            local ballStartPos, ballStartOffset
            BallButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragBall = true
                    ballStartPos = input.Position
                    ballStartOffset = BallButton.Position
                end
            end)
            BallButton.InputChanged:Connect(function(input)
                if dragBall and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local delta = input.Position - ballStartPos
                    local newX = ballStartOffset.X.Offset + delta.X
                    local newY = ballStartOffset.Y.Offset + delta.Y
                    newX = math.clamp(newX, 0, ScreenGui.AbsoluteSize.X - BallButton.AbsoluteSize.X)
                    newY = math.clamp(newY, 0, ScreenGui.AbsoluteSize.Y - BallButton.AbsoluteSize.Y)
                    BallButton.Position = UDim2.new(0, newX, 0, newY)
                end
            end)
            BallButton.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragBall = false
                end
            end)
            BallButton.MouseButton1Click:Connect(function()
                BallButton.Visible = false
                MainFrame.Visible = true
                MainFrame.Size = UDim2.new(0, 0, 0, 0)
                TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = originalSize,
                    Position = UDim2.new(0.5, 0, 0.5, 0)
                }):Play()
            end)
        end
        BallButton.Visible = true
    end
end)

-- ============================================
-- Sistema de Detecção Contínua
-- ============================================
local foldersToWatch = {}
local function setupDetection()
    local possibleFolders = {
        workspace:FindFirstChild("Cars"),
        workspace:FindFirstChild("Vehicles"),
        workspace:FindFirstChild("Carros"),
        workspace:FindFirstChild("Automobiles"),
        workspace:FindFirstChild("VehicleSpawns"),
    }
    for _, folder in ipairs(possibleFolders) do
        if folder then
            table.insert(foldersToWatch, folder)
            folder.ChildAdded:Connect(function(child)
                task.wait(0.5)
                addCar(child)
            end)
            folder.ChildRemoved:Connect(function(child)
                removeCar(child)
            end)
            for _, child in ipairs(folder:GetChildren()) do
                addCar(child)
            end
        end
    end

    workspace.ChildAdded:Connect(function(child)
        if child:IsA("Folder") or child:IsA("Model") then
            local name = child.Name:lower()
            if name:find("car") or name:find("vehicle") or name:find("carro") then
                table.insert(foldersToWatch, child)
                child.ChildAdded:Connect(function(grandChild)
                    task.wait(0.5)
                    addCar(grandChild)
                end)
                task.wait(1)
                for _, grandChild in ipairs(child:GetChildren()) do
                    addCar(grandChild)
                end
            end
        end
    end)
end

-- ============================================
-- Loop de Boost (com ONLY_FORWARD corrigido)
-- ============================================
RunService.Heartbeat:Connect(function(dt)
    local config = _G.CarWheelBoostConfig
    for car, data in pairs(activeCars) do
        if data.boostEnabled then
            if not boostTimers[car] then
                boostTimers[car] = {timer = 0, active = true}
            end
            local boostState = boostTimers[car]
            boostState.timer = boostState.timer + dt
            if boostState.active and boostState.timer >= config.BOOST_DURATION then
                boostState.active = false
                boostState.timer = 0
            elseif not boostState.active and boostState.timer >= config.PAUSE_DURATION then
                boostState.active = true
                boostState.timer = 0
            end

            if boostState.active then
                local canBoost = true
                if config.ONLY_FORWARD and data.mainPart then
                    local velocity = data.mainPart.AssemblyLinearVelocity
                    local forward = data.mainPart.CFrame.LookVector
                    if velocity and forward then
                        local dot = velocity:Dot(forward)
                        -- Se estiver claramente andando de ré (dot < -5), bloqueia
                        if dot < -5 then
                            canBoost = false
                        end
                    end
                end

                if canBoost then
                    for _, part in ipairs(data.parts) do
                        if part and part.Parent then
                            local currentRot = part.RotVelocity
                            local currentMag = currentRot.Magnitude
                            if currentMag > 0.1 then
                                local axis = currentRot.Unit
                                data.axisStore[part] = axis
                                local newMag = math.min(currentMag + config.ACCELERATION_RATE * dt, config.MAX_ROT_VELOCITY)
                                part.RotVelocity = axis * newMag
                            end
                        end
                    end
                end
            end
        else
            boostTimers[car] = nil
        end
    end
end)

-- ============================================
-- Carregar carros salvos
-- ============================================
local function loadSavedCars()
    local savedList = loadDetectedCars()
    for _, savedCar in ipairs(savedList) do
        local foundCar = nil
        pcall(function()
            local parts = savedCar.fullName:split(".")
            local current = workspace
            for _, part in ipairs(parts) do
                if part ~= "workspace" then
                    current = current:FindFirstChild(part)
                    if not current then break end
                end
            end
            if current and current:IsA("Instance") then
                foundCar = current
            end
        end)
        if foundCar then
            addCar(foundCar)
        end
    end
end

-- ============================================
-- Inicialização
-- ============================================
MainFrame.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = originalSize,
    Position = UDim2.new(0.5, 0, 0.5, 0)
}):Play()
MainFrame.Visible = true

setupDetection()
loadSavedCars()
updateCarsList()
updateDetailPanel()
updateTitle()

task.spawn(function()
    while true do
        task.wait(30)
        saveDetectedCars()
    end
end)

print("✅ Car Wheel Boost Detector v4.1 ativado com sucesso!")
print("📁 Pastas monitoradas:", #foldersToWatch)
