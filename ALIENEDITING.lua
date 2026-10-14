--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║  NINOMAX UI LIBRARY · v1.0.0                                                 ║
    ║  Fusion of Rayfield + RedzLib + Luna Interface Suite                          ║
    ║  Superior performance, smart theming, professional elements.                  ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
]]

--=====================================================================
-- SERVICES
--=====================================================================
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local HttpService      = game:GetService("HttpService")
local player           = Players.LocalPlayer

--=====================================================================
-- UTILITIES
--=====================================================================
local function clamp(v, min, max) return math.clamp(v, min, max) end
local function tw(inst, dur, props, style, dir)
    local t = TweenService:Create(inst,
        TweenInfo.new(dur or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props)
    t:Play()
    return t
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, 8)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(60, 60, 70)
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.4
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function padding(parent, t, l, r, b)
    local p = Instance.new("UIPadding", parent)
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    return p
end

-- Conversão de cores
local function hexToColor(hex)
    hex = tostring(hex):gsub("#", ""):gsub("%s", "")
    if #hex == 3 then
        hex = hex:sub(1,1):rep(2) .. hex:sub(2,2):rep(2) .. hex:sub(3,3):rep(2)
    end
    if #hex ~= 6 then return nil end
    local r = tonumber(hex:sub(1,2), 16)
    local g = tonumber(hex:sub(3,4), 16)
    local b = tonumber(hex:sub(5,6), 16)
    if not r or not g or not b then return nil end
    return Color3.fromRGB(r, g, b)
end

local function colorToHex(c)
    return string.format("#%02X%02X%02X",
        math.floor(c.R * 255 + 0.5),
        math.floor(c.G * 255 + 0.5),
        math.floor(c.B * 255 + 0.5))
end

local function mix(a, b, t)
    return Color3.new(
        a.R + (b.R - a.R) * t,
        a.G + (b.G - a.G) * t,
        a.B + (b.B - a.B) * t
    )
end

local function luminance(c)
    return 0.2126 * c.R + 0.7152 * c.G + 0.0722 * c.B
end

local function contrastText(bg)
    return luminance(bg) > 0.55
        and Color3.fromRGB(20, 20, 25)
        or Color3.fromRGB(245, 245, 250)
end

--=====================================================================
-- TEMA INTELIGENTE
--=====================================================================
local BaseTheme = {
    Bg          = Color3.fromRGB(16, 16, 20),
    BgSolid     = Color3.fromRGB(20, 20, 25),
    Surface     = Color3.fromRGB(28, 28, 34),
    SurfaceHi   = Color3.fromRGB(40, 40, 48),
    SurfaceLow  = Color3.fromRGB(22, 22, 28),
    Border      = Color3.fromRGB(52, 52, 62),
    Text        = Color3.fromRGB(245, 245, 250),
    TextDim     = Color3.fromRGB(175, 175, 185),
    TextMute    = Color3.fromRGB(120, 120, 130),
    Success     = Color3.fromRGB(0, 220, 130),
    Warning     = Color3.fromRGB(255, 180, 50),
    Danger      = Color3.fromRGB(255, 80, 100),
}

local P = {}
for k, v in pairs(BaseTheme) do P[k] = v end

local function applySmartTheme(accent)
    local h, s, v = Color3.toHSV(accent)
    s = math.max(s, 0.35)
    v = math.max(v, 0.40)
    local clean = Color3.fromHSV(h, s, v)

    P.Accent       = clean
    P.AccentHi     = Color3.fromHSV(h, math.min(1, s * 1.15), math.min(1, v * 1.35))
    P.AccentSoft   = Color3.fromHSV(h, s, math.max(0.18, v * 0.45))
    P.AccentDeep   = Color3.fromHSV(h, s, math.max(0.10, v * 0.22))
    P.Glow         = Color3.fromHSV(h, math.max(0.55, s * 0.75), 1)
    P.TextOnAccent = contrastText(clean)
    P.BorderTint   = mix(BaseTheme.Border, clean, 0.35)
    P.SurfaceTint  = mix(BaseTheme.Surface, clean, 0.08)
end

applySmartTheme(Color3.fromRGB(200, 30, 30))

--=====================================================================
-- BIBLIOTECA NINOMAX
--=====================================================================
local NINOMAX = {}
NINOMAX.Flags = {}
NINOMAX._themeCallbacks = {}

local function registerTheme(fn) table.insert(NINOMAX._themeCallbacks, fn) end
local function broadcastTheme()
    for _, fn in ipairs(NINOMAX._themeCallbacks) do pcall(fn) end
end

--=====================================================================
-- CRIAÇÃO DA JANELA
--=====================================================================
function NINOMAX:CreateWindow(config)
    config = config or {}
    local Window = {}
    local titleText = config.Title or "NINOMAX"
    local subtitleText = config.Subtitle or "by NINOMAX"

    -- Dimensões
    local DEFAULT_SIZE = Vector2.new(600, 400)
    local MIN_SIZE     = Vector2.new(420, 320)
    local MAX_SIZE     = Vector2.new(1200, 900)
    local currentSize  = DEFAULT_SIZE

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NINOMAX_UI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 99e99
    pcall(function() screenGui.Parent = CoreGui end)
    if not screenGui.Parent then screenGui.Parent = player:WaitForChild("PlayerGui") end

    -- Sombra
    local shadowHolder = Instance.new("Frame", screenGui)
    shadowHolder.BackgroundTransparency = 1
    shadowHolder.Size = UDim2.new(0, currentSize.X + 10, 0, currentSize.Y + 10)
    shadowHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadowHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    shadowHolder.ZIndex = 0
    local shadowImg = Instance.new("ImageLabel", shadowHolder)
    shadowImg.Size = UDim2.new(1, 0, 1, 0)
    shadowImg.BackgroundTransparency = 1
    shadowImg.Image = "rbxassetid://1316045217"
    shadowImg.ImageColor3 = Color3.new(0, 0, 0)
    shadowImg.ImageTransparency = 0.55
    shadowImg.ScaleType = Enum.ScaleType.Slice
    shadowImg.SliceCenter = Rect.new(6, 6, 122, 122)

    -- Main Frame
    local mainFrame = Instance.new("TextButton")
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = P.Bg
    mainFrame.Text = ""
    mainFrame.AutoButtonColor = false
    mainFrame.ClipsDescendants = true
    mainFrame.Draggable = true
    mainFrame.Active = true
    mainFrame.Parent = screenGui
    corner(mainFrame, UDim.new(0, 12))

    local mainStroke = stroke(mainFrame, P.Accent, 1.5, 0.25)
    local mainGrad = Instance.new("UIGradient", mainFrame)
    mainGrad.Rotation = 135
    mainGrad.Color = ColorSequence.new(P.BgSolid, P.Bg)

    -- Grid decorativo
    local gridHolder = Instance.new("Frame", mainFrame)
    gridHolder.Size = UDim2.new(1, 0, 1, 0)
    gridHolder.BackgroundTransparency = 1
    gridHolder.ClipsDescendants = true
    gridHolder.ZIndex = 0
    for i = 0, 16 do
        local l = Instance.new("Frame", gridHolder)
        l.BackgroundColor3 = P.Border
        l.BackgroundTransparency = 0.92
        l.BorderSizePixel = 0
        l.Size = UDim2.new(0, 1, 1, 0)
        l.Position = UDim2.new(0, i * 44, 0, 0)
    end
    for i = 0, 12 do
        local l = Instance.new("Frame", gridHolder)
        l.BackgroundColor3 = P.Border
        l.BackgroundTransparency = 0.92
        l.BorderSizePixel = 0
        l.Size = UDim2.new(1, 0, 0, 1)
        l.Position = UDim2.new(0, 0, 0, i * 42)
    end

    -- Orbs animados
    local decor = Instance.new("Frame", mainFrame)
    decor.Size = UDim2.new(1, 0, 1, 0)
    decor.BackgroundTransparency = 1
    decor.ClipsDescendants = true
    decor.ZIndex = 0
    local orb1 = Instance.new("Frame", decor)
    orb1.Size = UDim2.new(0, 280, 0, 280)
    orb1.Position = UDim2.new(-0.3, 0, -0.3, 0)
    orb1.BackgroundColor3 = P.Accent
    orb1.BackgroundTransparency = 0.9
    orb1.BorderSizePixel = 0
    corner(orb1, UDim.new(1, 0))
    local orb2 = Instance.new("Frame", decor)
    orb2.Size = UDim2.new(0, 240, 0, 240)
    orb2.Position = UDim2.new(0.9, 0, 0.8, 0)
    orb2.BackgroundColor3 = P.AccentSoft
    orb2.BackgroundTransparency = 0.92
    orb2.BorderSizePixel = 0
    corner(orb2, UDim.new(1, 0))

    task.spawn(function()
        local t = 0
        while mainFrame.Parent do
            t += task.wait(0.033)
            orb1.Position = UDim2.new(-0.3 + math.sin(t*0.6)*0.08, 0, -0.3 + math.cos(t*0.5)*0.08, 0)
            orb2.Position = UDim2.new(0.9 + math.cos(t*0.4)*0.06, 0, 0.8 + math.sin(t*0.7)*0.06, 0)
        end
    end)

    -- Top glow
    local topGlow = Instance.new("Frame", mainFrame)
    topGlow.Size = UDim2.new(0, 140, 0, 2)
    topGlow.Position = UDim2.new(0, 0, 0, 0)
    topGlow.BackgroundColor3 = P.AccentHi
    topGlow.BorderSizePixel = 0
    topGlow.ZIndex = 6
    corner(topGlow, UDim.new(0, 3))
    task.spawn(function()
        while topGlow.Parent do
            topGlow.Position = UDim2.new(0, -140, 0, 0)
            tw(topGlow, 2.8, { Position = UDim2.new(1, 0, 0, 0) }, Enum.EasingStyle.Linear)
            task.wait(2.8)
        end
    end)

    -- Título NINOMAX com efeito
    local titleContainer = Instance.new("Frame", mainFrame)
    titleContainer.Size = UDim2.new(1, -50, 0, 28)
    titleContainer.Position = UDim2.new(0, 14, 0, 0)
    titleContainer.BackgroundTransparency = 1
    titleContainer.ZIndex = 5

    local titleNino = Instance.new("TextLabel", titleContainer)
    titleNino.Size = UDim2.new(0, 100, 1, 0)
    titleNino.Position = UDim2.new(0, 0, 0, 0)
    titleNino.BackgroundTransparency = 1
    titleNino.Text = "NINO"
    titleNino.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleNino.Font = Enum.Font.GothamBold
    titleNino.TextSize = 18
    titleNino.TextXAlignment = Enum.TextXAlignment.Left
    titleNino.TextYAlignment = Enum.TextYAlignment.Center
    titleNino.ZIndex = 5

    local titleMax = Instance.new("TextLabel", titleContainer)
    titleMax.Size = UDim2.new(0, 100, 1, 0)
    titleMax.Position = UDim2.new(0, 52, 0, 0)
    titleMax.BackgroundTransparency = 1
    titleMax.Text = "MAX"
    titleMax.TextColor3 = Color3.fromRGB(220, 30, 30)
    titleMax.Font = Enum.Font.GothamBold
    titleMax.TextSize = 18
    titleMax.TextXAlignment = Enum.TextXAlignment.Left
    titleMax.TextYAlignment = Enum.TextYAlignment.Center
    titleMax.ZIndex = 5

    -- Efeito de gradiente no NINO (branco -> cinza claro)
    local titleGrad = Instance.new("UIGradient", titleNino)
    titleGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 220, 230)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
    })
    titleGrad.Rotation = 90

    -- Efeito de brilho no MAX
    local titleGlow = Instance.new("ImageLabel", titleMax)
    titleGlow.Size = UDim2.new(1, 20, 1, 20)
    titleGlow.Position = UDim2.new(0, -10, 0, -10)
    titleGlow.BackgroundTransparency = 1
    titleGlow.Image = "rbxassetid://1316045217"
    titleGlow.ImageColor3 = Color3.fromRGB(220, 30, 30)
    titleGlow.ImageTransparency = 0.7
    titleGlow.ScaleType = Enum.ScaleType.Slice
    titleGlow.SliceCenter = Rect.new(10, 10, 118, 118)
    titleGlow.ZIndex = 4

    task.spawn(function()
        while titleMax.Parent do
            tw(titleGlow, 1.5, { ImageTransparency = 0.4 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.5)
            tw(titleGlow, 1.5, { ImageTransparency = 0.8 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.5)
        end
    end)

    -- Subtítulo editável
    local subtitle = Instance.new("TextLabel", mainFrame)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = subtitleText
    subtitle.TextColor3 = P.TextMute
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 10
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.TextYAlignment = Enum.TextYAlignment.Center
    subtitle.Size = UDim2.new(0, 200, 0, 28)
    subtitle.Position = UDim2.new(0, 118, 0, 0)
    subtitle.ZIndex = 5

    -- Botão minimizar
    local hideButton = Instance.new("TextButton", mainFrame)
    hideButton.Size = UDim2.new(0, 26, 0, 26)
    hideButton.Position = UDim2.new(1, -34, 0, 1)
    hideButton.BackgroundColor3 = P.Surface
    hideButton.BackgroundTransparency = 0.4
    hideButton.Text = "−"
    hideButton.TextColor3 = P.TextDim
    hideButton.TextSize = 16
    hideButton.Font = Enum.Font.GothamBold
    hideButton.AutoButtonColor = false
    hideButton.BorderSizePixel = 0
    hideButton.ZIndex = 5
    corner(hideButton, UDim.new(0, 6))
    local hideStroke = stroke(hideButton, P.Border, 1, 0.4)
    hideButton.MouseEnter:Connect(function()
        tw(hideButton, 0.2, { BackgroundColor3 = P.AccentSoft })
        tw(hideStroke, 0.2, { Color = P.Accent })
    end)
    hideButton.MouseLeave:Connect(function()
        tw(hideButton, 0.2, { BackgroundColor3 = P.Surface, BackgroundTransparency = 0.4 })
        tw(hideStroke, 0.2, { Color = P.Border, Transparency = 0.4 })
    end)

    -- Linha divisória
    local line = Instance.new("Frame", mainFrame)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0, 28)
    line.BackgroundColor3 = P.Accent
    line.BackgroundTransparency = 0.3
    line.BorderSizePixel = 0
    line.ZIndex = 4

    -- Sidebar
    local sidebar = Instance.new("ScrollingFrame", mainFrame)
    sidebar.Size = UDim2.new(0.22, 0, 1, -28)
    sidebar.Position = UDim2.new(0, 0, 0, 28)
    sidebar.BackgroundColor3 = P.BgSolid
    sidebar.BackgroundTransparency = 0.3
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebar.ScrollBarThickness = 3
    sidebar.ScrollBarImageColor3 = P.Accent
    sidebar.BorderSizePixel = 0
    sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
    corner(sidebar, UDim.new(0, 4))
    local sidebarLayout = Instance.new("UIListLayout", sidebar)
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Padding = UDim.new(0, 3)
    padding(sidebar, 5, 5, 5, 0)

    -- Search
    local searchBox = Instance.new("TextBox", sidebar)
    searchBox.Size = UDim2.new(1, 0, 0, 26)
    searchBox.BackgroundColor3 = P.Surface
    searchBox.BorderSizePixel = 0
    searchBox.PlaceholderText = "🔍 Buscar..."
    searchBox.PlaceholderColor3 = P.TextMute
    searchBox.TextColor3 = P.Text
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 11
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus = false
    searchBox.LayoutOrder = -1
    corner(searchBox, UDim.new(0, 6))
    stroke(searchBox, P.Border, 1, 0.5)
    padding(searchBox, 0, 8, 8, 0)

    local tabButtons, pages, selectedTab = {}, {}, nil

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = string.lower(searchBox.Text)
        for name, btn in pairs(tabButtons) do
            btn.Visible = (q == "") or (string.find(string.lower(name), q, 1, true) ~= nil)
        end
    end)

    local scrollHolder = Instance.new("ScrollingFrame", mainFrame)
    scrollHolder.Position = UDim2.new(0.22, 4, 0, 33)
    scrollHolder.Size = UDim2.new(0.78, -8, 1, -38)
    scrollHolder.BackgroundTransparency = 1
    scrollHolder.BorderSizePixel = 0
    scrollHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollHolder.ScrollBarThickness = 4
    scrollHolder.ScrollBarImageColor3 = P.Accent
    scrollHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y

    -- Botão flutuante (restaurar)
    local ballButton = Instance.new("ImageButton")
    ballButton.Size = UDim2.new(0, 50, 0, 50)
    ballButton.Position = UDim2.new(0.1, 0, 0.9, -150)
    ballButton.AnchorPoint = Vector2.new(0.5, 0.5)
    ballButton.BackgroundColor3 = P.Accent
    ballButton.Image = "rbxassetid://6337069410"
    ballButton.Visible = false
    ballButton.Draggable = true
    ballButton.Parent = screenGui
    corner(ballButton, UDim.new(0.5, 0))
    local ballStroke = stroke(ballButton, P.AccentHi, 2, 0.2)

    -- Resize handle
    local resizeHandle = Instance.new("TextButton", mainFrame)
    resizeHandle.Size = UDim2.new(0, 20, 0, 20)
    resizeHandle.Position = UDim2.new(1, -24, 1, -24)
    resizeHandle.BackgroundColor3 = P.Surface
    resizeHandle.BackgroundTransparency = 0.35
    resizeHandle.Text = "◢"
    resizeHandle.TextColor3 = P.TextDim
    resizeHandle.TextSize = 14
    resizeHandle.Font = Enum.Font.GothamBold
    resizeHandle.AutoButtonColor = false
    resizeHandle.ZIndex = 20
    corner(resizeHandle, UDim.new(0, 5))
    local resizeStroke = stroke(resizeHandle, P.Border, 1.2, 0.35)

    local hoveredResize = false
    resizeHandle.MouseEnter:Connect(function()
        hoveredResize = true
        tw(resizeHandle, 0.18, {
            BackgroundColor3 = P.AccentSoft,
            BackgroundTransparency = 0.1,
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(1, -28, 1, -28)
        }, Enum.EasingStyle.Back)
        tw(resizeStroke, 0.18, { Color = P.AccentHi, Transparency = 0 })
    end)
    resizeHandle.MouseLeave:Connect(function()
        hoveredResize = false
        tw(resizeHandle, 0.2, {
            BackgroundColor3 = P.Surface,
            BackgroundTransparency = 0.35,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(1, -24, 1, -24)
        }, Enum.EasingStyle.Back)
        tw(resizeStroke, 0.2, { Color = P.Border, Transparency = 0.35 })
    end)

    -- Lógica de resize
    do
        local dragging, startSize, startPos
        resizeHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
               or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                startSize = mainFrame.AbsoluteSize
                startPos = input.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging
               and (input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - startPos
                local w = clamp(startSize.X + delta.X, MIN_SIZE.X, MAX_SIZE.X)
                local h = clamp(startSize.Y + delta.Y, MIN_SIZE.Y, MAX_SIZE.Y)
                mainFrame.Size = UDim2.new(0, w, 0, h)
                currentSize = Vector2.new(w, h)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
               or input.UserInputType == Enum.UserInputType.Touch then
                if dragging then
                    dragging = false
                    local fs = mainFrame.AbsoluteSize
                    currentSize = Vector2.new(fs.X, fs.Y)
                end
            end
        end)
    end

    -- Sincronizar sombra
    RunService.RenderStepped:Connect(function()
        if not mainFrame or not mainFrame.Parent then return end
        shadowHolder.Position = UDim2.new(
            mainFrame.Position.X.Scale,
            mainFrame.Position.X.Offset,
            mainFrame.Position.Y.Scale,
            mainFrame.Position.Y.Offset + 2
        )
        shadowHolder.Size = UDim2.new(0, mainFrame.AbsoluteSize.X + 10, 0, mainFrame.AbsoluteSize.Y + 10)
    end)

    -- Animar entrada
    task.spawn(function()
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        mainFrame.BackgroundTransparency = 1
        shadowImg.ImageTransparency = 1
        task.wait(0.05)
        mainFrame.Size = UDim2.new(0, currentSize.X - 40, 0, currentSize.Y - 20)
        tw(mainFrame, 0.55, { Size = UDim2.new(0, currentSize.X, 0, currentSize.Y) }, Enum.EasingStyle.Back)
        tw(mainFrame, 0.4, { BackgroundTransparency = 0 })
        tw(shadowImg, 0.5, { ImageTransparency = 0.55 })
        sidebar.Position = UDim2.new(0, -50, 0, 28)
        task.wait(0.15)
        tw(sidebar, 0.45, { Position = UDim2.new(0, 0, 0, 28) })
    end)

    --=================================================================
    -- CREATE TAB
    --=================================================================
    function Window:CreateTab(tabName, iconId)
        local tabBtn = Instance.new("TextButton", sidebar)
        tabBtn.Size = UDim2.new(1, 0, 0, 32)
        tabBtn.Text = ""
        tabBtn.BackgroundColor3 = P.Surface
        tabBtn.AutoButtonColor = false
        tabBtn.ClipsDescendants = true
        corner(tabBtn, UDim.new(0, 6))
        local uiStroke = stroke(tabBtn, P.Border, 1, 0.6)

        local marker = Instance.new("Frame", tabBtn)
        marker.Name = "TabMarker"
        marker.Size = UDim2.new(0, 3, 1, -8)
        marker.Position = UDim2.new(0, 0, 0, 4)
        marker.BackgroundColor3 = P.AccentHi
        marker.BorderSizePixel = 0
        marker.Visible = false
        corner(marker, UDim.new(0, 4))

        local label = Instance.new("TextLabel", tabBtn)
        label.BackgroundTransparency = 1
        label.Text = tabName
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 12
        label.TextColor3 = P.Text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextWrapped = true

        if iconId then
            local icon = Instance.new("ImageLabel", tabBtn)
            icon.Size = UDim2.new(0, 16, 0, 16)
            icon.Position = UDim2.new(0, 8, 0.5, -8)
            icon.BackgroundTransparency = 1
            icon.Image = "rbxassetid://" .. tostring(iconId)
            icon.ImageColor3 = P.TextMute
            label.Position = UDim2.new(0, 30, 0, 0)
            label.Size = UDim2.new(1, -32, 1, 0)
        else
            label.Position = UDim2.new(0, 12, 0, 0)
            label.Size = UDim2.new(1, -12, 1, 0)
        end

        tabButtons[tabName] = tabBtn
        registerTheme(function()
            if selectedTab == tabName then
                tw(tabBtn, 0.35, { BackgroundColor3 = P.SurfaceHi })
            end
            tw(marker, 0.35, { BackgroundColor3 = P.AccentHi })
        end)

        tabBtn.MouseEnter:Connect(function()
            if selectedTab ~= tabName then
                tw(tabBtn, 0.2, { BackgroundColor3 = P.SurfaceHi })
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if selectedTab ~= tabName then
                tw(tabBtn, 0.2, { BackgroundColor3 = P.Surface })
            end
        end)

        local tabPage = Instance.new("Frame", scrollHolder)
        tabPage.Name = tabName
        tabPage.Size = UDim2.new(1, 0, 0, 1000)
        tabPage.BackgroundTransparency = 1
        tabPage.Visible = false
        local layout = Instance.new("UIListLayout", tabPage)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)
        padding(tabPage, 4, 4, 8, 4)
        pages[tabName] = tabPage

        tabBtn.MouseButton1Click:Connect(function()
            for name, button in pairs(tabButtons) do
                if name == tabName then
                    tw(button, 0.15, { BackgroundColor3 = P.SurfaceHi })
                    tw(button, 0.12, { Size = UDim2.new(1, 0, 0, 36) })
                    task.delay(0.12, function()
                        tw(button, 0.15, { Size = UDim2.new(1, 0, 0, 32) }, Enum.EasingStyle.Back)
                    end)
                    button.TabMarker.Visible = true
                else
                    tw(button, 0.2, { BackgroundColor3 = P.Surface })
                    button.TabMarker.Visible = false
                end
            end
            for tn, f in pairs(pages) do
                local active = (tn == tabName)
                f.Visible = active
                if active then
                    f.Position = UDim2.new(0, 20, 0, 0)
                    tw(f, 0.28, { Position = UDim2.new(0, 0, 0, 0) })
                end
            end
            selectedTab = tabName
        end)

        if not selectedTab then
            selectedTab = tabName
            tabPage.Visible = true
            tabBtn.TabMarker.Visible = true
        end

        return tabPage
    end

    --=================================================================
    -- ELEMENTOS
    --=================================================================

    --[[ BOTÃO ]]--
    function Window:CreateButton(tabName, text, callback, options)
        options = options or {}
        local tab = pages[tabName]; if not tab then return end

        local btn = Instance.new("TextButton", tab)
        btn.Size = UDim2.new(1, -20, 0, 32)
        btn.Position = UDim2.new(0, 10, 0, 0)
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.ClipsDescendants = true
        corner(btn, UDim.new(0, 7))
        btn.BackgroundColor3 = P.SurfaceHi

        local bgGrad = Instance.new("UIGradient", btn)
        bgGrad.Rotation = 90
        bgGrad.Color = ColorSequence.new(P.SurfaceHi, mix(P.SurfaceHi, P.Accent, 0.08))

        local btnStroke = stroke(btn, P.Border, 1, 0.5)

        local accentBar = Instance.new("Frame", btn)
        accentBar.Size = UDim2.new(0, 3, 1, 0)
        accentBar.BackgroundColor3 = P.Accent
        accentBar.BorderSizePixel = 0

        local innerGlow = Instance.new("Frame", btn)
        innerGlow.Size = UDim2.new(0, 8, 1, 0)
        innerGlow.BackgroundColor3 = P.Accent
        innerGlow.BackgroundTransparency = 0.75
        innerGlow.BorderSizePixel = 0
        innerGlow.ZIndex = 0

        local iconLbl = nil
        if options.Icon then
            iconLbl = Instance.new("ImageLabel", btn)
            iconLbl.Size = UDim2.new(0, 16, 0, 16)
            iconLbl.Position = UDim2.new(0, 12, 0.5, -8)
            iconLbl.BackgroundTransparency = 1
            iconLbl.Image = "rbxassetid://" .. tostring(options.Icon)
            iconLbl.ImageColor3 = P.Text
            iconLbl.ZIndex = 3
        end

        local label = Instance.new("TextLabel", btn)
        label.BackgroundTransparency = 1
        label.Text = text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 14
        label.TextColor3 = P.Text
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.TextTruncate = Enum.TextTruncate.AtEnd
        label.ZIndex = 3
        if iconLbl then
            label.Position = UDim2.new(0, 34, 0, 0)
            label.Size = UDim2.new(1, -40, 1, 0)
            label.TextXAlignment = Enum.TextXAlignment.Left
        else
            label.Position = UDim2.new(0, 14, 0, 0)
            label.Size = UDim2.new(1, -20, 1, 0)
            label.TextXAlignment = Enum.TextXAlignment.Left
        end

        local shine = Instance.new("Frame", btn)
        shine.Size = UDim2.new(0, 60, 1, 0)
        shine.Position = UDim2.new(-0.3, 0, 0, 0)
        shine.BackgroundColor3 = Color3.new(1, 1, 1)
        shine.BackgroundTransparency = 0.88
        shine.BorderSizePixel = 0
        shine.ZIndex = 4
        local shineGrad = Instance.new("UIGradient", shine)
        shineGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 1),
        })

        registerTheme(function()
            tw(btnStroke, 0.4, { Color = P.Border })
            tw(accentBar, 0.4, { BackgroundColor3 = P.Accent })
            tw(innerGlow, 0.4, { BackgroundColor3 = P.Accent })
            tw(bgGrad, 0.4, { Color = ColorSequence.new(P.SurfaceHi, mix(P.SurfaceHi, P.Accent, 0.08)) })
        end)

        local cooling = false
        local cooldown = options.Cooldown or 0.6

        btn.MouseEnter:Connect(function()
            tw(btn, 0.2, { BackgroundColor3 = mix(P.SurfaceHi, P.Accent, 0.18) })
            tw(btnStroke, 0.2, { Color = P.AccentHi, Transparency = 0.15 })
            tw(accentBar, 0.2, { Size = UDim2.new(0, 6, 1, 0) })
            shine.Position = UDim2.new(-0.3, 0, 0, 0)
            tw(shine, 0.7, { Position = UDim2.new(1.2, 0, 0, 0) }, Enum.EasingStyle.Quart)
        end)

        btn.MouseLeave:Connect(function()
            tw(btn, 0.2, { BackgroundColor3 = P.SurfaceHi })
            tw(btnStroke, 0.2, { Color = P.Border, Transparency = 0.5 })
            tw(accentBar, 0.2, { Size = UDim2.new(0, 3, 1, 0) })
        end)

        btn.MouseButton1Click:Connect(function()
            if cooling then return end
            cooling = true
            local flash = Instance.new("Frame", btn)
            flash.Size = UDim2.new(1, 0, 1, 0)
            flash.BackgroundColor3 = P.Success
            flash.BackgroundTransparency = 0.7
            flash.BorderSizePixel = 0
            flash.ZIndex = 1
            corner(flash, UDim.new(0, 7))
            tw(flash, 0.5, { BackgroundTransparency = 1 })
            task.delay(0.5, function() flash:Destroy() end)

            tw(btn, 0.08, { Size = UDim2.new(1, -22, 0, 30) })
            task.delay(0.08, function()
                tw(btn, 0.15, { Size = UDim2.new(1, -20, 0, 32) }, Enum.EasingStyle.Back)
            end)

            if callback then pcall(callback) end
            task.delay(cooldown, function() cooling = false end)
        end)
    end

    --[[ TOGGLE ]]--
    function Window:CreateToggle(tabName, cfg)
        local tab = pages[tabName]; if not tab then return end
        cfg = cfg or {}

        local f = Instance.new("Frame", tab)
        f.Size = UDim2.new(1, -20, 0, 46)
        f.BackgroundColor3 = P.Surface
        f.ClipsDescendants = true
        f.BorderSizePixel = 0
        corner(f, UDim.new(0, 8))
        local fStroke = stroke(f, P.Border, 1, 0.6)

        local title = Instance.new("TextLabel", f)
        title.Text = cfg.Text or "Toggle"
        title.TextColor3 = P.Text
        title.Font = Enum.Font.GothamMedium
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextYAlignment = Enum.TextYAlignment.Top
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1, -70, 0, 16)
        title.Position = UDim2.new(0, 12, 0, 5)

        local desc = Instance.new("TextLabel", f)
        desc.Text = cfg.Description or ""
        desc.TextColor3 = P.TextMute
        desc.Font = Enum.Font.Gotham
        desc.TextSize = 11
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.TextYAlignment = Enum.TextYAlignment.Top
        desc.BackgroundTransparency = 1
        desc.Size = UDim2.new(1, -70, 0, 14)
        desc.Position = UDim2.new(0, 12, 0, 24)

        local sw = Instance.new("Frame", f)
        sw.Size = UDim2.new(0, 44, 0, 24)
        sw.Position = UDim2.new(1, -56, 0.5, -12)
        sw.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        sw.BorderSizePixel = 0
        corner(sw, UDim.new(1, 0))
        local swStroke = stroke(sw, P.Border, 1, 0.5)

        local ball = Instance.new("Frame", sw)
        ball.Size = UDim2.new(0, 18, 0, 18)
        ball.Position = UDim2.new(0, 3, 0.5, -9)
        ball.BackgroundColor3 = Color3.fromRGB(210, 210, 215)
        ball.BorderSizePixel = 0
        corner(ball, UDim.new(1, 0))
        local ballStroke = stroke(ball, P.Border, 1, 0.4)

        local glowFrame = Instance.new("Frame", sw)
        glowFrame.Size = UDim2.new(1, 0, 1, 0)
        glowFrame.BackgroundColor3 = P.Accent
        glowFrame.BackgroundTransparency = 1
        glowFrame.BorderSizePixel = 0
        corner(glowFrame, UDim.new(1, 0))
        glowFrame.ZIndex = 0

        local btn = Instance.new("TextButton", sw)
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""

        local isOn = false
        local cooling = false
        local cooldown = cfg.Cooldown or 0.3

        registerTheme(function()
            if isOn then
                tw(sw, 0.4, { BackgroundColor3 = P.Accent })
                tw(glowFrame, 0.4, { BackgroundColor3 = P.Accent })
            end
            tw(swStroke, 0.4, { Color = P.BorderTint })
        end)

        task.spawn(function()
            while sw.Parent do
                if isOn then
                    tw(glowFrame, 1.4, { BackgroundTransparency = 0.55 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                    task.wait(1.4)
                    tw(glowFrame, 1.4, { BackgroundTransparency = 0.85 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                    task.wait(1.4)
                else
                    task.wait(0.5)
                end
            end
        end)

        btn.MouseEnter:Connect(function()
            tw(fStroke, 0.2, { Color = P.AccentHi, Transparency = 0.25 })
        end)
        btn.MouseLeave:Connect(function()
            tw(fStroke, 0.2, { Color = P.Border, Transparency = 0.6 })
        end)

        local function setState(newState, silent)
            if cooling and not silent then return end
            cooling = true
            isOn = newState

            local bg = isOn and P.Accent or Color3.fromRGB(50, 50, 55)
            local bp = isOn and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            local bc = isOn and Color3.new(1, 1, 1) or Color3.fromRGB(210, 210, 215)

            tw(sw, 0.3, { BackgroundColor3 = bg }, Enum.EasingStyle.Back)
            tw(ball, 0.32, { Position = bp, BackgroundColor3 = bc }, Enum.EasingStyle.Back)
            tw(glowFrame, 0.3, { BackgroundTransparency = isOn and 0.7 or 1 })

            if isOn then
                local flash = Instance.new("Frame", sw)
                flash.Size = UDim2.new(1, 0, 1, 0)
                flash.BackgroundColor3 = Color3.new(1, 1, 1)
                flash.BackgroundTransparency = 0.6
                flash.BorderSizePixel = 0
                flash.ZIndex = 5
                corner(flash, UDim.new(1, 0))
                tw(flash, 0.4, { BackgroundTransparency = 1 })
                task.delay(0.4, function() flash:Destroy() end)
            end

            if cfg.Callback then pcall(cfg.Callback, isOn) end
            task.delay(cooldown, function() cooling = false end)
        end

        btn.MouseButton1Click:Connect(function() setState(not isOn) end)

        return {
            Set = function(_, v) setState(v, true) end,
            Get = function() return isOn end,
        }
    end

    --[[ SLIDER ]]--
    function Window:CreateSlider(tabName, cfg)
        local tab = pages[tabName]; if not tab then return end
        cfg = cfg or {}

        local holder = Instance.new("Frame", tab)
        holder.Size = UDim2.new(1, -20, 0, 0)
        holder.Position = UDim2.new(0, 10, 0, 0)
        holder.BackgroundTransparency = 1
        holder.AutomaticSize = Enum.AutomaticSize.Y
        local lay = Instance.new("UIListLayout", holder)

        local bg = Instance.new("Frame", holder)
        bg.Size = UDim2.new(1, 0, 0, 58)
        bg.BackgroundColor3 = P.SurfaceLow
        bg.BorderSizePixel = 0
        corner(bg, UDim.new(0, 8))
        stroke(bg, P.Border, 1, 0.5)

        local t = Instance.new("TextLabel", bg)
        t.Size = UDim2.new(1, -60, 0, 16)
        t.Position = UDim2.new(0, 12, 0, 6)
        t.Text = cfg.Text or "Slider"
        t.TextColor3 = P.Text
        t.TextSize = 14
        t.Font = Enum.Font.GothamMedium
        t.BackgroundTransparency = 1
        t.TextXAlignment = Enum.TextXAlignment.Left

        local d = Instance.new("TextLabel", bg)
        d.Size = UDim2.new(1, -20, 0, 11)
        d.Position = UDim2.new(0, 12, 0, 24)
        d.Text = cfg.Description or ""
        d.TextColor3 = P.TextMute
        d.TextSize = 11
        d.Font = Enum.Font.Gotham
        d.BackgroundTransparency = 1
        d.TextXAlignment = Enum.TextXAlignment.Left

        local vl = Instance.new("TextLabel", bg)
        vl.Size = UDim2.new(0, 50, 0, 16)
        vl.Position = UDim2.new(1, -62, 0, 6)
        vl.TextColor3 = P.AccentHi
        vl.TextSize = 14
        vl.Font = Enum.Font.GothamBold
        vl.BackgroundTransparency = 1
        vl.TextXAlignment = Enum.TextXAlignment.Right

        local bar = Instance.new("Frame", bg)
        bar.Size = UDim2.new(1, -24, 0, 8)
        bar.Position = UDim2.new(0, 12, 0, 46)
        bar.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
        bar.BorderSizePixel = 0
        corner(bar, UDim.new(1, 0))

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = P.Accent
        fill.BorderSizePixel = 0
        corner(fill, UDim.new(1, 0))
        local fg = Instance.new("UIGradient", fill)
        fg.Color = ColorSequence.new(P.AccentSoft, P.AccentHi)

        local fillStroke = Instance.new("UIStroke", fill)
        fillStroke.Thickness = 2
        fillStroke.Transparency = 0.4
        fillStroke.Color = P.AccentHi

        local knob = Instance.new("Frame", bar)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = UDim2.new(0, 0, 0.5, 0)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        knob.BorderSizePixel = 0
        knob.ZIndex = 4
        corner(knob, UDim.new(1, 0))
        local knobStroke = stroke(knob, P.AccentHi, 2, 0.2)

        local knobGlow = Instance.new("ImageLabel", knob)
        knobGlow.Size = UDim2.new(1, 14, 1, 14)
        knobGlow.Position = UDim2.new(0, -7, 0, -7)
        knobGlow.BackgroundTransparency = 1
        knobGlow.Image = "rbxassetid://1316045217"
        knobGlow.ImageColor3 = P.AccentHi
        knobGlow.ImageTransparency = 0.6
        knobGlow.ScaleType = Enum.ScaleType.Slice
        knobGlow.SliceCenter = Rect.new(10, 10, 118, 118)
        knobGlow.ZIndex = 3

        registerTheme(function()
            tw(fill, 0.4, { BackgroundColor3 = P.Accent })
            tw(fg, 0.4, { Color = ColorSequence.new(P.AccentSoft, P.AccentHi) })
            tw(fillStroke, 0.4, { Color = P.AccentHi })
            tw(knobStroke, 0.4, { Color = P.AccentHi })
            tw(knobGlow, 0.4, { ImageColor3 = P.AccentHi })
            tw(vl, 0.4, { TextColor3 = P.AccentHi })
        end)

        local min, max = cfg.Min or 0, cfg.Max or 100
        local function round(v, dd)
            local m = 10^dd
            return math.floor(v * m + 0.5) / m
        end

        local function update(x)
            local bp = bar.AbsolutePosition.X
            local bw = bar.AbsoluteSize.X
            if bw <= 0 then return end
            local c = clamp((x - bp) / bw, 0, 1)
            local val = round(min + (max - min) * c, 2)
            fill.Size = UDim2.new(c, 0, 1, 0)
            knob.Position = UDim2.new(c, 0, 0.5, 0)
            vl.Text = tostring(val)
            if cfg.Callback then pcall(cfg.Callback, val) end
        end

        local drag = false
        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
               or i.UserInputType == Enum.UserInputType.Touch then
                drag = true
                tw(knob, 0.15, { Size = UDim2.new(0, 20, 0, 20) }, Enum.EasingStyle.Back)
                tw(knobGlow, 0.15, { ImageTransparency = 0.25 })
                update(i.Position.X)
            end
        end)

        UserInputService.InputChanged:Connect(function(i)
            if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
                         or i.UserInputType == Enum.UserInputType.Touch) then
                update(i.Position.X)
            end
        end)

        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
               or i.UserInputType == Enum.UserInputType.Touch then
                drag = false
                tw(knob, 0.2, { Size = UDim2.new(0, 16, 0, 16) }, Enum.EasingStyle.Back)
                tw(knobGlow, 0.2, { ImageTransparency = 0.6 })
            end
        end)

        update(bar.AbsolutePosition.X)
    end

    --[[ DROPDOWN ]]--
    function Window:CreateDropdown(tabName, cfg)
        local tab = pages[tabName]; if not tab then return end
        cfg = cfg or {}
        local options = cfg.Options or {}
        local open = false

        local f = Instance.new("Frame", tab)
        f.Size = UDim2.new(1, -20, 0, 38)
        f.Position = UDim2.new(0, 10, 0, 0)
        f.BackgroundColor3 = P.Surface
        f.BorderSizePixel = 0
        f.ZIndex = 2
        corner(f, UDim.new(0, 8))
        local fStroke = stroke(f, P.Border, 1, 0.5)

        local leftIcon = Instance.new("TextLabel", f)
        leftIcon.Size = UDim2.new(0, 16, 0, 16)
        leftIcon.Position = UDim2.new(0, 10, 0.5, -8)
        leftIcon.BackgroundTransparency = 1
        leftIcon.Text = "☰"
        leftIcon.TextColor3 = P.TextMute
        leftIcon.Font = Enum.Font.GothamBold
        leftIcon.TextSize = 14

        local title = Instance.new("TextLabel", f)
        title.BackgroundTransparency = 1
        title.Text = cfg.Text or "Selecione..."
        title.TextColor3 = P.TextDim
        title.Font = Enum.Font.GothamSemibold
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Size = UDim2.new(0, 200, 1, 0)
        title.Position = UDim2.new(0, 32, 0, 0)

        local arrow = Instance.new("TextLabel", f)
        arrow.Size = UDim2.new(0, 14, 0, 14)
        arrow.Position = UDim2.new(1, -24, 0.5, -7)
        arrow.BackgroundTransparency = 1
        arrow.Text = "˅"
        arrow.TextColor3 = P.TextDim
        arrow.Font = Enum.Font.GothamBold
        arrow.TextSize = 14

        local sel = Instance.new("TextLabel", f)
        sel.BackgroundTransparency = 1
        sel.Text = cfg.Default or "None"
        sel.TextColor3 = P.Text
        sel.Font = Enum.Font.GothamBold
        sel.TextSize = 13
        sel.TextXAlignment = Enum.TextXAlignment.Right
        sel.Size = UDim2.new(0, 0, 1, 0)
        sel.Position = UDim2.new(1, -34, 0, 0)
        sel.TextTruncate = Enum.TextTruncate.AtEnd

        local function updateSel(t)
            sel.Text = t
            local w = math.min(sel.TextBounds.X + 6, 200)
            sel.Size = UDim2.new(0, w, 1, 0)
            sel.Position = UDim2.new(1, -34 - w, 0, 0)
        end
        updateSel(sel.Text)

        local btn = Instance.new("TextButton", f)
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 4

        local list = Instance.new("Frame", tab)
        list.Size = UDim2.new(1, -20, 0, 0)
        list.Position = UDim2.new(0, 10, 0, 0)
        list.BackgroundColor3 = P.SurfaceLow
        list.Visible = false
        list.ClipsDescendants = true
        list.ZIndex = 5
        corner(list, UDim.new(0, 8))
        stroke(list, P.Border, 1, 0.4)

        local hasSearch = #options > 5
        local searchH = hasSearch and 30 or 0

        local searchField = nil
        if hasSearch then
            searchField = Instance.new("TextBox", list)
            searchField.Size = UDim2.new(1, -8, 0, 26)
            searchField.Position = UDim2.new(0, 4, 0, 4)
            searchField.BackgroundColor3 = P.Surface
            searchField.BorderSizePixel = 0
            searchField.PlaceholderText = "🔍 Filtrar..."
            searchField.PlaceholderColor3 = P.TextMute
            searchField.TextColor3 = P.Text
            searchField.Font = Enum.Font.Gotham
            searchField.TextSize = 12
            searchField.ClearTextOnFocus = false
            searchField.TextXAlignment = Enum.TextXAlignment.Left
            corner(searchField, UDim.new(0, 5))
            stroke(searchField, P.Border, 1, 0.5)
            padding(searchField, 0, 8, 8, 0)
        end

        local scrollOpt = Instance.new("ScrollingFrame", list)
        scrollOpt.Size = UDim2.new(1, 0, 1, -searchH - 8)
        scrollOpt.Position = UDim2.new(0, 0, 0, searchH + 4)
        scrollOpt.BackgroundTransparency = 1
        scrollOpt.BorderSizePixel = 0
        scrollOpt.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollOpt.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scrollOpt.ScrollBarThickness = 3
        scrollOpt.ScrollBarImageColor3 = P.Accent

        local optLay = Instance.new("UIListLayout", scrollOpt)
        optLay.Padding = UDim.new(0, 3)
        padding(scrollOpt, 2, 4, 4, 6)

        local optionButtons = {}
        local currentlySelected = cfg.Default

        local function closeDropdown()
            open = false
            arrow.Text = "˅"
            tw(arrow, 0.25, { Rotation = 0 })
            list:TweenSize(UDim2.new(1, -20, 0, 0), "In", "Back", 0.22, true)
            tw(fStroke, 0.25, { Color = P.Border, Transparency = 0.5 })
            tw(leftIcon, 0.25, { TextColor3 = P.TextMute })
            task.delay(0.25, function() list.Visible = false end)
        end

        for i, opt in ipairs(options) do
            local o = Instance.new("TextButton", scrollOpt)
            o.Size = UDim2.new(1, 0, 0, 30)
            o.Text = ""
            o.BackgroundColor3 = P.SurfaceHi
            o.AutoButtonColor = false
            o.ZIndex = 6
            o.LayoutOrder = i
            corner(o, UDim.new(0, 5))
            local oStroke = stroke(o, P.Border, 1, 0.6)

            local dot = Instance.new("Frame", o)
            dot.Size = UDim2.new(0, 6, 0, 6)
            dot.Position = UDim2.new(0, 10, 0.5, -3)
            dot.BackgroundColor3 = P.Accent
            dot.BorderSizePixel = 0
            dot.Visible = (currentlySelected == opt)
            corner(dot, UDim.new(1, 0))

            local lbl = Instance.new("TextLabel", o)
            lbl.BackgroundTransparency = 1
            lbl.Text = opt
            lbl.TextColor3 = P.Text
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Size = UDim2.new(1, -40, 1, 0)
            lbl.Position = UDim2.new(0, 24, 0, 0)
            lbl.TextTruncate = Enum.TextTruncate.AtEnd

            local chk = Instance.new("TextLabel", o)
            chk.BackgroundTransparency = 1
            chk.Text = "✔"
            chk.TextColor3 = P.AccentHi
            chk.Font = Enum.Font.GothamBold
            chk.TextSize = 14
            chk.Size = UDim2.new(0, 20, 1, 0)
            chk.Position = UDim2.new(1, -24, 0, 0)
            chk.Visible = (currentlySelected == opt)

            optionButtons[opt] = { frame = o, dot = dot, chk = chk, label = lbl }

            o.MouseEnter:Connect(function()
                tw(o, 0.15, { BackgroundColor3 = mix(P.SurfaceHi, P.Accent, 0.35) })
                tw(oStroke, 0.15, { Color = P.AccentHi, Transparency = 0.2 })
            end)
            o.MouseLeave:Connect(function()
                tw(o, 0.15, { BackgroundColor3 = P.SurfaceHi })
                tw(oStroke, 0.15, { Color = P.Border, Transparency = 0.6 })
            end)
            o.MouseButton1Click:Connect(function()
                for _, v in pairs(optionButtons) do
                    v.dot.Visible = false
                    v.chk.Visible = false
                end
                dot.Visible = true
                chk.Visible = true
                currentlySelected = opt
                updateSel(opt)
                if cfg.Callback then pcall(cfg.Callback, opt) end
                closeDropdown()
            end)
        end

        if hasSearch then
            searchField:GetPropertyChangedSignal("Text"):Connect(function()
                local q = string.lower(searchField.Text)
                local visibleCount = 0
                for _, data in pairs(optionButtons) do
                    local match = (q == "") or (string.find(string.lower(data.label.Text), q, 1, true) ~= nil)
                    data.frame.Visible = match
                    if match then visibleCount += 1 end
                end
                if open then
                    local h = math.min(visibleCount * 33 + searchH + 12, 240)
                    list:TweenSize(UDim2.new(1, -20, 0, h), "Out", "Back", 0.2, true)
                end
            end)
        end

        btn.MouseButton1Click:Connect(function()
            open = not open
            list.Visible = true
            local count = 0
            for _, data in pairs(optionButtons) do
                if data.frame.Visible then count += 1 end
            end
            local h = open and math.min(count * 33 + searchH + 12, 240) or 0
            arrow.Text = open and "˄" or "˅"
            tw(arrow, 0.3, { Rotation = open and 180 or 0 }, Enum.EasingStyle.Back)
            list:TweenSize(UDim2.new(1, -20, 0, h), "Out", "Back", 0.28, true)
            tw(fStroke, 0.25, { Color = open and P.AccentHi or P.Border, Transparency = open and 0 or 0.5 })
            tw(leftIcon, 0.25, { TextColor3 = open and P.AccentHi or P.TextMute })

            if open then
                if hasSearch and searchField then searchField.Text = "" end
                local i = 0
                for _, data in pairs(optionButtons) do
                    if data.frame.Visible then
                        i += 1
                        data.frame.BackgroundTransparency = 1
                        data.label.TextTransparency = 1
                        local delay = i * 0.02
                        task.delay(delay, function()
                            if data.frame.Parent then
                                tw(data.frame, 0.25, { BackgroundTransparency = 0 })
                                tw(data.label, 0.25, { TextTransparency = 0 })
                            end
                        end)
                    end
                end
            else
                task.delay(0.28, function() list.Visible = false end)
            end
        end)

        registerTheme(function()
            for _, v in pairs(optionButtons) do
                tw(v.dot, 0.4, { BackgroundColor3 = P.Accent })
                tw(v.chk, 0.4, { TextColor3 = P.AccentHi })
            end
            tw(scrollOpt, 0.4, { ScrollBarImageColor3 = P.Accent })
        end)
    end

    --[[ COLOR PICKER ]]--
    function Window:CreateColorPicker(tabName, colorConfig)
        colorConfig = colorConfig or {}
        local tab = pages[tabName]; if not tab then return end

        local current = colorConfig.Default or Color3.fromRGB(255, 60, 60)
        local h, s, v = Color3.toHSV(current)
        local recentColors = {}

        local frame = Instance.new("Frame", tab)
        frame.Size = UDim2.new(1, -20, 0, 44)
        frame.Position = UDim2.new(0, 10, 0, 0)
        frame.BackgroundColor3 = P.Surface
        frame.ClipsDescendants = true
        frame.BorderSizePixel = 0
        corner(frame, UDim.new(0, 10))
        local fStroke = stroke(frame, P.Border, 1, 0.5)

        local header = Instance.new("TextButton", frame)
        header.Size = UDim2.new(1, 0, 0, 44)
        header.BackgroundTransparency = 1
        header.Text = ""

        local lbl = Instance.new("TextLabel", header)
        lbl.Size = UDim2.new(1, -80, 0, 24)
        lbl.Position = UDim2.new(0, 14, 0, 4)
        lbl.BackgroundTransparency = 1
        lbl.Text = colorConfig.Text or "Cor Personalizada"
        lbl.TextColor3 = P.Text
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local sub = Instance.new("TextLabel", header)
        sub.Size = UDim2.new(1, -80, 0, 12)
        sub.Position = UDim2.new(0, 14, 0, 26)
        sub.BackgroundTransparency = 1
        sub.Text = colorConfig.Description or "Clique para expandir"
        sub.TextColor3 = P.TextMute
        sub.Font = Enum.Font.Gotham
        sub.TextSize = 10
        sub.TextXAlignment = Enum.TextXAlignment.Left

        local previewDot = Instance.new("Frame", header)
        previewDot.Size = UDim2.new(0, 22, 0, 22)
        previewDot.Position = UDim2.new(1, -60, 0.5, -11)
        previewDot.BackgroundColor3 = current
        previewDot.BorderSizePixel = 0
        corner(previewDot, UDim.new(0, 6))
        stroke(previewDot, Color3.new(1,1,1), 1.5, 0.4)

        local arrow = Instance.new("TextLabel", header)
        arrow.Size = UDim2.new(0, 20, 0, 20)
        arrow.Position = UDim2.new(1, -30, 0.5, -10)
        arrow.BackgroundTransparency = 1
        arrow.Text = "▼"
        arrow.TextColor3 = P.Text
        arrow.Font = Enum.Font.GothamBold
        arrow.TextSize = 12

        local body = Instance.new("Frame", frame)
        body.Size = UDim2.new(1, 0, 0, 0)
        body.Position = UDim2.new(0, 0, 0, 44)
        body.BackgroundTransparency = 1
        body.ClipsDescendants = true

        local padSize = 150
        local pad = Instance.new("Frame", body)
        pad.Size = UDim2.new(0, padSize, 0, padSize)
        pad.Position = UDim2.new(0, 14, 0, 12)
        pad.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        pad.BorderSizePixel = 0
        corner(pad, UDim.new(0, 8))
        pad.ClipsDescendants = true
        stroke(pad, P.Border, 1, 0.4)

        local satOv = Instance.new("Frame", pad)
        satOv.Size = UDim2.new(1, 0, 1, 0)
        satOv.BackgroundColor3 = Color3.new(1, 1, 1)
        satOv.BorderSizePixel = 0
        local satGrad = Instance.new("UIGradient", satOv)
        satGrad.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1))
        satGrad.Transparency = NumberSequence.new(0, 1)

        local valOv = Instance.new("Frame", pad)
        valOv.Size = UDim2.new(1, 0, 1, 0)
        valOv.BackgroundColor3 = Color3.new(0, 0, 0)
        valOv.BorderSizePixel = 0
        local valGrad = Instance.new("UIGradient", valOv)
        valGrad.Rotation = 90
        valGrad.Transparency = NumberSequence.new(1, 0)

        local padMarker = Instance.new("Frame", pad)
        padMarker.Size = UDim2.new(0, 12, 0, 12)
        padMarker.AnchorPoint = Vector2.new(0.5, 0.5)
        padMarker.BackgroundColor3 = Color3.new(1, 1, 1)
        padMarker.BorderSizePixel = 0
        corner(padMarker, UDim.new(1, 0))
        stroke(padMarker, Color3.new(0, 0, 0), 2, 0.2)
        padMarker.ZIndex = 5

        local hueBar = Instance.new("Frame", body)
        hueBar.Size = UDim2.new(0, 20, 0, padSize)
        hueBar.Position = UDim2.new(0, 14 + padSize + 12, 0, 12)
        hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
        hueBar.BorderSizePixel = 0
        corner(hueBar, UDim.new(0, 6))
        stroke(hueBar, P.Border, 1, 0.4)
        local hueGrad = Instance.new("UIGradient", hueBar)
        hueGrad.Rotation = 90
        hueGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,    Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1,    Color3.fromRGB(255, 0, 0)),
        })

        local hueMarker = Instance.new("Frame", hueBar)
        hueMarker.Size = UDim2.new(1, 6, 0, 6)
        hueMarker.AnchorPoint = Vector2.new(0.5, 0.5)
        hueMarker.Position = UDim2.new(0.5, 0, 0, 0)
        hueMarker.BackgroundColor3 = Color3.new(1, 1, 1)
        hueMarker.BorderSizePixel = 0
        corner(hueMarker, UDim.new(1, 0))
        stroke(hueMarker, Color3.new(0, 0, 0), 2, 0.3)

        local previewCol = Instance.new("Frame", body)
        previewCol.Size = UDim2.new(0, 110, 0, padSize)
        previewCol.Position = UDim2.new(1, -124, 0, 12)
        previewCol.BackgroundTransparency = 1

        local previewLbl = Instance.new("TextLabel", previewCol)
        previewLbl.Size = UDim2.new(1, 0, 0, 14)
        previewLbl.BackgroundTransparency = 1
        previewLbl.Text = "PRÉVIA"
        previewLbl.TextColor3 = P.TextMute
        previewLbl.Font = Enum.Font.GothamBold
        previewLbl.TextSize = 10
        previewLbl.TextXAlignment = Enum.TextXAlignment.Left

        local preview = Instance.new("Frame", previewCol)
        preview.Size = UDim2.new(1, 0, 0, 40)
        preview.Position = UDim2.new(0, 0, 0, 18)
        preview.BackgroundColor3 = current
        preview.BorderSizePixel = 0
        corner(preview, UDim.new(0, 6))
        stroke(preview, Color3.new(1,1,1), 1, 0.6)

        local hexLabel = Instance.new("TextLabel", previewCol)
        hexLabel.Size = UDim2.new(1, 0, 0, 12)
        hexLabel.Position = UDim2.new(0, 0, 0, 64)
        hexLabel.BackgroundTransparency = 1
        hexLabel.Text = "HEX"
        hexLabel.TextColor3 = P.TextMute
        hexLabel.Font = Enum.Font.GothamBold
        hexLabel.TextSize = 10
        hexLabel.TextXAlignment = Enum.TextXAlignment.Left

        local hexBox = Instance.new("TextBox", previewCol)
        hexBox.Size = UDim2.new(1, 0, 0, 24)
        hexBox.Position = UDim2.new(0, 0, 0, 78)
        hexBox.BackgroundColor3 = P.SurfaceHi
        hexBox.TextColor3 = P.Text
        hexBox.Font = Enum.Font.Code
        hexBox.TextSize = 13
        hexBox.Text = colorToHex(current)
        hexBox.ClearTextOnFocus = false
        corner(hexBox, UDim.new(0, 5))
        stroke(hexBox, P.Border, 1, 0.5)

        local rgbHolder = Instance.new("Frame", previewCol)
        rgbHolder.Size = UDim2.new(1, 0, 0, 24)
        rgbHolder.Position = UDim2.new(0, 0, 0, 108)
        rgbHolder.BackgroundTransparency = 1
        local rgbLay = Instance.new("UIListLayout", rgbHolder)
        rgbLay.FillDirection = Enum.FillDirection.Horizontal
        rgbLay.Padding = UDim.new(0, 4)

        local function makeRGB(col)
            local ff = Instance.new("Frame", rgbHolder)
            ff.Size = UDim2.new(0, 34, 1, 0)
            ff.BackgroundColor3 = P.SurfaceHi
            ff.BorderSizePixel = 0
            corner(ff, UDim.new(0, 5))
            stroke(ff, P.Border, 1, 0.5)
            local tb = Instance.new("TextBox", ff)
            tb.Size = UDim2.new(1, 0, 1, 0)
            tb.BackgroundTransparency = 1
            tb.Text = tostring(math.floor(col * 255 + 0.5))
            tb.TextColor3 = Color3.fromRGB(245, 245, 250)
            tb.Font = Enum.Font.Code
            tb.TextSize = 11
            tb.ClearTextOnFocus = false
            return tb
        end
        local rIn = makeRGB(current.R)
        local gIn = makeRGB(current.G)
        local bIn = makeRGB(current.B)

        local presetsRow = Instance.new("Frame", body)
        presetsRow.Size = UDim2.new(1, -28, 0, 20)
        presetsRow.Position = UDim2.new(0, 14, 0, 12 + padSize + 12)
        presetsRow.BackgroundTransparency = 1
        local presetsLay = Instance.new("UIListLayout", presetsRow)
        presetsLay.FillDirection = Enum.FillDirection.Horizontal
        presetsLay.Padding = UDim.new(0, 4)

        local presetColors = {
            Color3.fromRGB(255, 60, 60),   Color3.fromRGB(255, 140, 50),
            Color3.fromRGB(255, 220, 60),  Color3.fromRGB(120, 220, 90),
            Color3.fromRGB(60, 200, 220),  Color3.fromRGB(80, 120, 255),
            Color3.fromRGB(160, 90, 255),  Color3.fromRGB(255, 90, 200),
            Color3.fromRGB(255, 255, 255), Color3.fromRGB(80, 80, 90),
        }
        for _, pc in ipairs(presetColors) do
            local sw2 = Instance.new("TextButton", presetsRow)
            sw2.Size = UDim2.new(0, 20, 0, 20)
            sw2.BackgroundColor3 = pc
            sw2.Text = ""
            sw2.AutoButtonColor = false
            corner(sw2, UDim.new(1, 0))
            stroke(sw2, Color3.new(0, 0, 0), 1, 0.6)
            sw2.MouseButton1Click:Connect(function()
                local nh, ns, nv = Color3.toHSV(pc)
                h, s, v = nh, ns, nv
                updateAll()
            end)
        end

        local actionRow = Instance.new("Frame", body)
        actionRow.Size = UDim2.new(1, -28, 0, 26)
        actionRow.Position = UDim2.new(0, 14, 0, 12 + padSize + 68)
        actionRow.BackgroundTransparency = 1

        local randBtn = Instance.new("TextButton", actionRow)
        randBtn.Size = UDim2.new(0.5, -3, 1, 0)
        randBtn.Position = UDim2.new(0, 0, 0, 0)
        randBtn.Text = "🎲 Aleatório"
        randBtn.BackgroundColor3 = P.SurfaceHi
        randBtn.TextColor3 = P.Text
        randBtn.Font = Enum.Font.GothamMedium
        randBtn.TextSize = 12
        randBtn.AutoButtonColor = false
        corner(randBtn, UDim.new(0, 6))
        stroke(randBtn, P.Border, 1, 0.5)

        local cycleBtn = Instance.new("TextButton", actionRow)
        cycleBtn.Size = UDim2.new(0.5, -3, 1, 0)
        cycleBtn.Position = UDim2.new(0.5, 3, 0, 0)
        cycleBtn.Text = "🌈 Ciclar"
        cycleBtn.BackgroundColor3 = P.SurfaceHi
        cycleBtn.TextColor3 = P.Text
        cycleBtn.Font = Enum.Font.GothamMedium
        cycleBtn.TextSize = 12
        cycleBtn.AutoButtonColor = false
        corner(cycleBtn, UDim.new(0, 6))
        stroke(cycleBtn, P.Border, 1, 0.5)

        local cycling = false

        local function updateAll()
            local color = Color3.fromHSV(h, s, v)
            current = color
            pad.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            padMarker.Position = UDim2.new(s, 0, 1 - v, 0)
            hueMarker.Position = UDim2.new(0.5, 0, h, 0)
            preview.BackgroundColor3 = color
            previewDot.BackgroundColor3 = color
            hexBox.Text = colorToHex(color)
            rIn.Text = tostring(math.floor(color.R * 255 + 0.5))
            gIn.Text = tostring(math.floor(color.G * 255 + 0.5))
            bIn.Text = tostring(math.floor(color.B * 255 + 0.5))
            if colorConfig.Callback then pcall(colorConfig.Callback, color) end
        end

        local padDrag = false
        local function padUpdate(input)
            local px = clamp(input.Position.X - pad.AbsolutePosition.X, 0, pad.AbsoluteSize.X)
            local py = clamp(input.Position.Y - pad.AbsolutePosition.Y, 0, pad.AbsoluteSize.Y)
            s = px / pad.AbsoluteSize.X
            v = 1 - (py / pad.AbsoluteSize.Y)
            updateAll()
        end
        pad.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
               or i.UserInputType == Enum.UserInputType.Touch then
                padDrag = true; padUpdate(i)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if padDrag and (i.UserInputType == Enum.UserInputType.MouseMovement
                            or i.UserInputType == Enum.UserInputType.Touch) then
                padUpdate(i)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
               or i.UserInputType == Enum.UserInputType.Touch then
                padDrag = false
            end
        end)

        local hueDrag = false
        local function hueUpdate(input)
            local py = clamp(input.Position.Y - hueBar.AbsolutePosition.Y, 0, hueBar.AbsoluteSize.Y)
            h = py / hueBar.AbsoluteSize.Y
            updateAll()
        end
        hueBar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
               or i.UserInputType == Enum.UserInputType.Touch then
                hueDrag = true; hueUpdate(i)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if hueDrag and (i.UserInputType == Enum.UserInputType.MouseMovement
                            or i.UserInputType == Enum.UserInputType.Touch) then
                hueUpdate(i)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
               or i.UserInputType == Enum.UserInputType.Touch then
                hueDrag = false
            end
        end)

        hexBox.FocusLost:Connect(function()
            local c = hexToColor(hexBox.Text)
            if c then
                h, s, v = Color3.toHSV(c)
                updateAll()
            else
                hexBox.Text = colorToHex(current)
            end
        end)

        local function applyRGB()
            local r = clamp(tonumber(rIn.Text) or 0, 0, 255)
            local g = clamp(tonumber(gIn.Text) or 0, 0, 255)
            local b = clamp(tonumber(bIn.Text) or 0, 0, 255)
            local c = Color3.fromRGB(r, g, b)
            h, s, v = Color3.toHSV(c)
            updateAll()
        end
        rIn.FocusLost:Connect(applyRGB)
        gIn.FocusLost:Connect(applyRGB)
        bIn.FocusLost:Connect(applyRGB)

        randBtn.MouseButton1Click:Connect(function()
            h = math.random() * 1.0
            s = 0.55 + math.random() * 0.45
            v = 0.65 + math.random() * 0.35
            updateAll()
        end)

        cycleBtn.MouseButton1Click:Connect(function()
            cycling = not cycling
            if cycling then
                cycleBtn.Text = "🌈 Ciclando..."
                cycleBtn.TextColor3 = P.AccentHi
            else
                cycleBtn.Text = "🌈 Ciclar"
                cycleBtn.TextColor3 = P.Text
            end
        end)

        task.spawn(function()
            while frame.Parent do
                if cycling then
                    h = (h + 0.006) % 1
                    updateAll()
                end
                task.wait(0.016)
            end
        end)

        local expanded = false
        local function setExpanded(v2)
            expanded = v2
            arrow.Text = expanded and "▲" or "▼"
            local targetH = expanded and (44 + 12 + padSize + 12 + 20 + 8 + 20 + 8 + 26 + 12) or 44
            tw(frame, 0.35, { Size = UDim2.new(1, -20, 0, targetH) }, Enum.EasingStyle.Back)
            body.Size = UDim2.new(1, 0, 0, expanded and (targetH - 44) or 0)
        end
        header.MouseButton1Click:Connect(function() setExpanded(not expanded) end)

        updateAll()
    end

    --[[ KEYBIND ]]--
    function Window:CreateKeybind(tabName, cfg)
        local tab = pages[tabName]; if not tab then return end
        cfg = cfg or {}

        local f = Instance.new("Frame", tab)
        f.Size = UDim2.new(1, -20, 0, 44)
        f.Position = UDim2.new(0, 10, 0, 0)
        f.BackgroundColor3 = P.Surface
        f.BorderSizePixel = 0
        corner(f, UDim.new(0, 8))
        local fStroke = stroke(f, P.Border, 1, 0.6)

        local title = Instance.new("TextLabel", f)
        title.Size = UDim2.new(1, -110, 1, 0)
        title.Position = UDim2.new(0, 14, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = cfg.Text or "Tecla"
        title.TextColor3 = P.Text
        title.Font = Enum.Font.GothamMedium
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left

        local kbBtn = Instance.new("TextButton", f)
        kbBtn.Size = UDim2.new(0, 90, 0, 26)
        kbBtn.Position = UDim2.new(1, -102, 0.5, -13)
        kbBtn.BackgroundColor3 = P.SurfaceHi
        kbBtn.Text = cfg.Default or "Nenhuma"
        kbBtn.TextColor3 = P.Text
        kbBtn.Font = Enum.Font.Code
        kbBtn.TextSize = 12
        kbBtn.AutoButtonColor = false
        corner(kbBtn, UDim.new(0, 6))
        local kbStroke = stroke(kbBtn, P.Border, 1, 0.5)

        local capturing = false
        local currentKey = cfg.Default

        kbBtn.MouseButton1Click:Connect(function()
            capturing = not capturing
            if capturing then
                kbBtn.Text = "Pressione..."
                kbBtn.TextColor3 = P.AccentHi
                tw(kbStroke, 0.2, { Color = P.AccentHi, Transparency = 0 })
            else
                kbBtn.Text = currentKey or "Nenhuma"
                kbBtn.TextColor3 = P.Text
                tw(kbStroke, 0.2, { Color = P.Border, Transparency = 0.5 })
            end
        end)

        UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe or not capturing then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode.Name
                kbBtn.Text = currentKey
                kbBtn.TextColor3 = P.Text
                capturing = false
                tw(kbStroke, 0.2, { Color = P.Border, Transparency = 0.5 })
                if cfg.Callback then pcall(cfg.Callback, input.KeyCode) end
            end
        end)
    end

    --[[ INPUT ]]--
    function Window:CreateInput(tabName, cfg)
        local tab = pages[tabName]; if not tab then return end
        cfg = cfg or {}

        local f = Instance.new("Frame", tab)
        f.Size = UDim2.new(1, -20, 0, 44)
        f.Position = UDim2.new(0, 10, 0, 0)
        f.BackgroundColor3 = P.Surface
        f.BorderSizePixel = 0
        corner(f, UDim.new(0, 8))
        local fStroke = stroke(f, P.Border, 1, 0.5)

        local title = Instance.new("TextLabel", f)
        title.Size = UDim2.new(1, -20, 0, 16)
        title.Position = UDim2.new(0, 12, 0, 4)
        title.BackgroundTransparency = 1
        title.Text = cfg.Text or "Input"
        title.TextColor3 = P.Text
        title.Font = Enum.Font.GothamMedium
        title.TextSize = 13
        title.TextXAlignment = Enum.TextXAlignment.Left

        local inputFrame = Instance.new("Frame", f)
        inputFrame.Size = UDim2.new(1, -24, 0, 20)
        inputFrame.Position = UDim2.new(0, 12, 0, 22)
        inputFrame.BackgroundColor3 = P.SurfaceLow
        inputFrame.BorderSizePixel = 0
        corner(inputFrame, UDim.new(0, 5))
        stroke(inputFrame, P.Border, 1, 0.5)

        local textBox = Instance.new("TextBox", inputFrame)
        textBox.Size = UDim2.new(1, -16, 1, 0)
        textBox.Position = UDim2.new(0, 8, 0, 0)
        textBox.BackgroundTransparency = 1
        textBox.Text = cfg.Default or ""
        textBox.PlaceholderText = cfg.Placeholder or "Digite..."
        textBox.PlaceholderColor3 = P.TextMute
        textBox.TextColor3 = P.Text
        textBox.Font = Enum.Font.Gotham
        textBox.TextSize = 12
        textBox.TextXAlignment = Enum.TextXAlignment.Left
        textBox.ClearTextOnFocus = false

        textBox.FocusLost:Connect(function()
            if cfg.Callback then pcall(cfg.Callback, textBox.Text) end
        end)
    end

    --[[ LABEL ]]--
    function Window:CreateLabel(tabName, text)
        local tab = pages[tabName]; if not tab then return end
        local label = Instance.new("TextLabel", tab)
        label.Size = UDim2.new(1, -20, 0, 28)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.Text = "  " .. string.upper(text or "")
        label.Font = Enum.Font.GothamBold
        label.TextSize = 15
        label.TextColor3 = P.Text
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Center

        local dot = Instance.new("Frame", label)
        dot.Size = UDim2.new(0, 6, 0, 6)
        dot.Position = UDim2.new(0, 0, 0.5, -3)
        dot.BackgroundColor3 = P.AccentHi
        dot.BorderSizePixel = 0
        corner(dot, UDim.new(1, 0))
        local dotGlow = stroke(dot, P.AccentHi, 2, 0.3)

        registerTheme(function()
            tw(dot, 0.4, { BackgroundColor3 = P.AccentHi })
        end)

        task.spawn(function()
            while dot.Parent do
                tw(dotGlow, 1.2, { Transparency = 0.9 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(1.2)
                tw(dotGlow, 1.2, { Transparency = 0.2 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(1.2)
            end
        end)
    end

    --[[ SECTION ]]--
    function Window:CreateSection(tabName, text)
        local tab = pages[tabName]; if not tab then return end
        local label = Instance.new("TextLabel", tab)
        label.Size = UDim2.new(1, -20, 0, 24)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.Text = text
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextColor3 = P.TextDim
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Center
    end

    --[[ DIVIDER ]]--
    function Window:CreateDivider(tabName)
        local tab = pages[tabName]; if not tab then return end
        local divider = Instance.new("Frame", tab)
        divider.Size = UDim2.new(1, -20, 0, 1)
        divider.Position = UDim2.new(0, 10, 0, 0)
        divider.BackgroundColor3 = P.Border
        divider.BackgroundTransparency = 0.5
        divider.BorderSizePixel = 0
    end

    --[[ PARAGRAPH ]]--
    function Window:CreateParagraph(tabName, title, content)
        local tab = pages[tabName]; if not tab then return end
        local frame = Instance.new("Frame", tab)
        frame.Size = UDim2.new(1, -20, 0, 60)
        frame.Position = UDim2.new(0, 10, 0, 0)
        frame.BackgroundColor3 = P.Surface
        frame.BorderSizePixel = 0
        corner(frame, UDim.new(0, 8))
        stroke(frame, P.Border, 1, 0.5)

        local t = Instance.new("TextLabel", frame)
        t.Size = UDim2.new(1, -20, 0, 18)
        t.Position = UDim2.new(0, 10, 0, 6)
        t.BackgroundTransparency = 1
        t.Text = title or "Paragraph"
        t.TextColor3 = P.Text
        t.Font = Enum.Font.GothamBold
        t.TextSize = 14
        t.TextXAlignment = Enum.TextXAlignment.Left

        local c = Instance.new("TextLabel", frame)
        c.Size = UDim2.new(1, -20, 0, 28)
        c.Position = UDim2.new(0, 10, 0, 26)
        c.BackgroundTransparency = 1
        c.Text = content or ""
        c.TextColor3 = P.TextMute
        c.Font = Enum.Font.Gotham
        c.TextSize = 12
        c.TextWrapped = true
        c.TextXAlignment = Enum.TextXAlignment.Left
        c.TextYAlignment = Enum.TextYAlignment.Top
    end

    --[[ PROGRESS BAR ]]--
    function Window:CreateProgressBar(tabName, cfg)
        local tab = pages[tabName]; if not tab then return end
        cfg = cfg or {}

        local f = Instance.new("Frame", tab)
        f.Size = UDim2.new(1, -20, 0, 46)
        f.Position = UDim2.new(0, 10, 0, 0)
        f.BackgroundColor3 = P.Surface
        f.BorderSizePixel = 0
        corner(f, UDim.new(0, 8))
        stroke(f, P.Border, 1, 0.6)

        local title = Instance.new("TextLabel", f)
        title.Size = UDim2.new(1, -60, 0, 16)
        title.Position = UDim2.new(0, 12, 0, 6)
        title.BackgroundTransparency = 1
        title.Text = cfg.Text or "Progresso"
        title.TextColor3 = P.Text
        title.Font = Enum.Font.GothamMedium
        title.TextSize = 13
        title.TextXAlignment = Enum.TextXAlignment.Left

        local pctLbl = Instance.new("TextLabel", f)
        pctLbl.Size = UDim2.new(0, 50, 0, 16)
        pctLbl.Position = UDim2.new(1, -62, 0, 6)
        pctLbl.BackgroundTransparency = 1
        pctLbl.Text = "0%"
        pctLbl.TextColor3 = P.AccentHi
        pctLbl.Font = Enum.Font.GothamBold
        pctLbl.TextSize = 13
        pctLbl.TextXAlignment = Enum.TextXAlignment.Right

        local bar = Instance.new("Frame", f)
        bar.Size = UDim2.new(1, -24, 0, 8)
        bar.Position = UDim2.new(0, 12, 0, 30)
        bar.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
        bar.BorderSizePixel = 0
        corner(bar, UDim.new(1, 0))

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = P.Accent
        fill.BorderSizePixel = 0
        corner(fill, UDim.new(1, 0))
        local fg = Instance.new("UIGradient", fill)
        fg.Color = ColorSequence.new(P.AccentSoft, P.AccentHi)

        registerTheme(function()
            tw(fill, 0.4, { BackgroundColor3 = P.Accent })
            tw(fg, 0.4, { Color = ColorSequence.new(P.AccentSoft, P.AccentHi) })
            tw(pctLbl, 0.4, { TextColor3 = P.AccentHi })
        end)

        local api = {}
        function api:Set(value)
            local p = clamp(value / 100, 0, 1)
            fill:TweenSize(UDim2.new(p, 0, 1, 0), "Out", "Quart", 0.4, true)
            pctLbl.Text = string.format("%d%%", math.floor(p * 100 + 0.5))
        end
        function api:SetInstant(value)
            local p = clamp(value / 100, 0, 1)
            fill.Size = UDim2.new(p, 0, 1, 0)
            pctLbl.Text = string.format("%d%%", math.floor(p * 100 + 0.5))
        end
        api:Set(0)
        return api
    end

    --=================================================================
    -- SISTEMA DE TEMAS
    --=================================================================
    function Window:CreateThemeBoxes(tabName)
        local tab = pages[tabName]; if not tab then return end

        local THEMES = {
            { name = "Neon",      accent = Color3.fromRGB(0, 255, 200) },
            { name = "Crimson",   accent = Color3.fromRGB(220, 20, 60) },
            { name = "Ocean",     accent = Color3.fromRGB(0, 150, 255) },
            { name = "Violet",    accent = Color3.fromRGB(155, 40, 255) },
            { name = "Sunset",    accent = Color3.fromRGB(255, 120, 40) },
            { name = "Toxic",     accent = Color3.fromRGB(150, 255, 40) },
            { name = "Ruby",      accent = Color3.fromRGB(255, 40, 80) },
            { name = "Emerald",   accent = Color3.fromRGB(0, 220, 130) },
            { name = "Cyberpunk", accent = Color3.fromRGB(255, 0, 200) },
            { name = "Gold",      accent = Color3.fromRGB(240, 180, 40) },
            { name = "Pastel",    accent = Color3.fromRGB(255, 180, 220) },
            { name = "Ice",       accent = Color3.fromRGB(180, 230, 255) },
            { name = "Corporate", accent = Color3.fromRGB(90, 130, 210) },
            { name = "Forest",    accent = Color3.fromRGB(60, 180, 90) },
            { name = "Mono",      accent = Color3.fromRGB(160, 160, 170) },
            { name = "Blood",     accent = Color3.fromRGB(160, 10, 10) },
            { name = "Aqua",      accent = Color3.fromRGB(0, 200, 220) },
            { name = "Lava",      accent = Color3.fromRGB(255, 80, 20) },
        }

        local container = Instance.new("Frame", tab)
        container.Size = UDim2.new(1, -20, 0, 0)
        container.Position = UDim2.new(0, 10, 0, 0)
        container.BackgroundTransparency = 1
        container.AutomaticSize = Enum.AutomaticSize.Y

        local infoBox = Instance.new("Frame", container)
        infoBox.Size = UDim2.new(1, 0, 0, 44)
        infoBox.BackgroundColor3 = P.Surface
        infoBox.BorderSizePixel = 0
        corner(infoBox, UDim.new(0, 8))
        local ibStroke = stroke(infoBox, P.Border, 1, 0.6)
        registerTheme(function() tw(ibStroke, 0.4, { Color = P.BorderTint }) end)

        local infoDot = Instance.new("Frame", infoBox)
        infoDot.Size = UDim2.new(0, 8, 0, 8)
        infoDot.Position = UDim2.new(0, 14, 0.5, -4)
        infoDot.BackgroundColor3 = P.Accent
        infoDot.BorderSizePixel = 0
        corner(infoDot, UDim.new(1, 0))
        registerTheme(function() tw(infoDot, 0.4, { BackgroundColor3 = P.Accent }) end)

        local infoLbl = Instance.new("TextLabel", infoBox)
        infoLbl.Size = UDim2.new(1, -40, 1, 0)
        infoLbl.Position = UDim2.new(0, 30, 0, 0)
        infoLbl.BackgroundTransparency = 1
        infoLbl.Text = "Clique em um tema — toda a interface se adapta."
        infoLbl.TextColor3 = P.TextMute
        infoLbl.Font = Enum.Font.Gotham
        infoLbl.TextSize = 11
        infoLbl.TextXAlignment = Enum.TextXAlignment.Left
        infoLbl.TextWrapped = true

        local grid = Instance.new("Frame", container)
        grid.Size = UDim2.new(1, 0, 0, 0)
        grid.Position = UDim2.new(0, 0, 0, 52)
        grid.BackgroundTransparency = 1
        grid.AutomaticSize = Enum.AutomaticSize.Y
        local gridLay = Instance.new("UIGridLayout", grid)
        gridLay.CellSize = UDim2.new(0, 64, 0, 48)
        gridLay.CellPadding = UDim2.new(0, 6, 0, 6)
        gridLay.SortOrder = Enum.SortOrder.LayoutOrder

        local lastSelected = nil

        local function selectTheme(t)
            applySmartTheme(t.accent)
            broadcastTheme()

            if lastSelected and lastSelected.Parent then
                tw(lastSelected, 0.3, { Size = UDim2.new(0, 64, 0, 48) }, Enum.EasingStyle.Back)
            end
            if t._ui then
                tw(t._ui, 0.3, { Size = UDim2.new(0, 68, 0, 52) }, Enum.EasingStyle.Back)
                lastSelected = t._ui
            end

            Window:Notify({
                Title = "TEMA APLICADO",
                Content = t.name .. " aplicado com sucesso!",
                Icon = "palette"
            })
        end

        for i, t in ipairs(THEMES) do
            local card = Instance.new("TextButton", grid)
            card.Size = UDim2.new(0, 64, 0, 48)
            card.BackgroundColor3 = P.Surface
            card.Text = ""
            card.AutoButtonColor = false
            corner(card, UDim.new(0, 8))
            local cardStroke = stroke(card, P.Border, 1, 0.6)

            local cg = Instance.new("UIGradient", card)
            cg.Rotation = 135
            cg.Color = ColorSequence.new(t.accent, mix(t.accent, Color3.new(0,0,0), 0.7))

            local ov = Instance.new("Frame", card)
            ov.Size = UDim2.new(1, 0, 1, 0)
            ov.BackgroundColor3 = Color3.new(0, 0, 0)
            ov.BackgroundTransparency = 0.55
            ov.BorderSizePixel = 0
            ov.ZIndex = 1
            corner(ov, UDim.new(0, 8))

            local nameLbl = Instance.new("TextLabel", card)
            nameLbl.Size = UDim2.new(1, -4, 1, 0)
            nameLbl.Position = UDim2.new(0, 2, 0, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = t.name
            nameLbl.TextColor3 = Color3.new(1, 1, 1)
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextSize = 10
            nameLbl.TextWrapped = true
            nameLbl.ZIndex = 2

            t._ui = card

            card.MouseEnter:Connect(function()
                tw(card, 0.2, { Size = UDim2.new(0, 68, 0, 52) }, Enum.EasingStyle.Back)
                tw(cardStroke, 0.2, { Color = t.accent, Transparency = 0 })
            end)
            card.MouseLeave:Connect(function()
                if lastSelected ~= card then
                    tw(card, 0.2, { Size = UDim2.new(0, 64, 0, 48) }, Enum.EasingStyle.Back)
                    tw(cardStroke, 0.2, { Color = P.Border, Transparency = 0.6 })
                end
            end)

            card.MouseButton1Click:Connect(function() selectTheme(t) end)
        end
    end

    --=================================================================
    -- NOTIFICAÇÕES
    --=================================================================
    local notifyQueue, notifying = {}, false
    local function processQueue()
        if notifying or #notifyQueue == 0 then return end
        notifying = true
        local data = table.remove(notifyQueue, 1)
        local frame = data.frame
        frame:TweenPosition(
            UDim2.new(1, -20, 1, -20 - (#notifyQueue * 110)),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quint,
            0.4,
            true
        )
        task.delay(2.2, function()
            frame:TweenPosition(
                UDim2.new(1, 320, 1, -200),
                Enum.EasingDirection.In,
                Enum.EasingStyle.Quint,
                0.35,
                true
            )
            task.wait(0.4)
            data.gui:Destroy()
            notifying = false
            processQueue()
        end)
    end

    function Window:Notify(config)
        config = config or {}
        local title = config.Title or "Notificação"
        local content = config.Content or ""
        local iconId = config.Icon or "info"

        local sg = Instance.new("ScreenGui")
        sg.Name = "NINOMAX_Notify"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        sg.DisplayOrder = 100
        pcall(function() sg.Parent = CoreGui end)
        if not sg.Parent then sg.Parent = player:WaitForChild("PlayerGui") end

        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, 320, 0, 90)
        f.Position = UDim2.new(1, 320, 1, -200)
        f.AnchorPoint = Vector2.new(1, 1)
        f.BackgroundColor3 = P.Bg
        f.BackgroundTransparency = 0.05
        f.BorderSizePixel = 0
        f.Parent = sg
        corner(f, UDim.new(0, 12))
        local nStroke = stroke(f, P.AccentHi, 1.5, 0.2)
        registerTheme(function() tw(nStroke, 0.5, { Color = P.AccentHi }) end)

        local prog = Instance.new("Frame", f)
        prog.Size = UDim2.new(1, 0, 0, 3)
        prog.Position = UDim2.new(0, 0, 1, -3)
        prog.BackgroundColor3 = P.AccentHi
        prog.BorderSizePixel = 0
        corner(prog, UDim.new(1, 0))
        tw(prog, 2.2, { Size = UDim2.new(0, 0, 0, 3) }, Enum.EasingStyle.Linear)

        local ic = Instance.new("ImageLabel")
        ic.Size = UDim2.new(0, 48, 0, 48)
        ic.Position = UDim2.new(0, 14, 0, 21)
        ic.Image = "rbxassetid://" .. tostring(iconId)
        ic.BackgroundTransparency = 1
        ic.Parent = f

        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1, -80, 0, 24)
        tl.Position = UDim2.new(0, 72, 0, 12)
        tl.Text = title
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 15
        tl.TextColor3 = P.Text
        tl.TextXAlignment = Enum.TextXAlignment.Left
        tl.BackgroundTransparency = 1
        tl.Parent = f

        local xl = Instance.new("TextLabel")
        xl.Size = UDim2.new(1, -80, 0, 36)
        xl.Position = UDim2.new(0, 72, 0, 38)
        xl.Text = content
        xl.Font = Enum.Font.Gotham
        xl.TextSize = 12
        xl.TextColor3 = P.TextMute
        xl.TextWrapped = true
        xl.TextXAlignment = Enum.TextXAlignment.Left
        xl.TextYAlignment = Enum.TextYAlignment.Top
        xl.BackgroundTransparency = 1
        xl.Parent = f

        table.insert(notifyQueue, { frame = f, gui = sg })
        processQueue()
    end

    --=================================================================
    -- HIDE / SHOW
    --=================================================================
    local isHidden = false
    local function doHide()
        if isHidden then return end
        isHidden = true
        local fs = mainFrame.AbsoluteSize
        currentSize = Vector2.new(fs.X, fs.Y)
        tw(mainFrame, 0.25, {
            Size = UDim2.new(0, currentSize.X, 0, 10),
            BackgroundTransparency = 0.4
        }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        tw(shadowImg, 0.25, { ImageTransparency = 1 })
        task.delay(0.25, function()
            mainFrame.Visible = false
            mainFrame.Size = UDim2.new(0, currentSize.X, 0, currentSize.Y)
            mainFrame.BackgroundTransparency = 0
            ballButton.Visible = true
            ballButton.Size = UDim2.new(0, 0, 0, 0)
            tw(ballButton, 0.35, { Size = UDim2.new(0, 50, 0, 50) }, Enum.EasingStyle.Back)
        end)
    end
    local function doShow()
        if not isHidden then return end
        isHidden = false
        tw(ballButton, 0.25, { Size = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.2, function()
            ballButton.Visible = false
            ballButton.Size = UDim2.new(0, 50, 0, 50)
            mainFrame.Visible = true
            mainFrame.Size = UDim2.new(0, currentSize.X, 0, 10)
            mainFrame.BackgroundTransparency = 0.4
            tw(mainFrame, 0.4, {
                Size = UDim2.new(0, currentSize.X, 0, currentSize.Y),
                BackgroundTransparency = 0
            }, Enum.EasingStyle.Back)
            tw(shadowImg, 0.4, { ImageTransparency = 0.55 })
        end)
    end

    hideButton.MouseButton1Click:Connect(doHide)
    ballButton.MouseButton1Click:Connect(doShow)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            if isHidden then doShow() else doHide() end
        end
    end)

    --=================================================================
    -- API PÚBLICA
    --=================================================================
    function Window:SetSubtitle(text)
        subtitle.Text = text
    end

    function Window:Destroy()
        screenGui:Destroy()
    end

    return Window
end

return NINOMAX
