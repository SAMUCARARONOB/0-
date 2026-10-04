--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║  RANOX UI LIBRARY · Version 4.1.0 · COSMIC EDITION               ║
    ║  ✦ Sombra dinâmica · Resize melhorado · Restore inteligente ✦     ║
    ╚══════════════════════════════════════════════════════════════════╝
]]

local TweenService = game:GetService("TweenService")
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local player       = Players.LocalPlayer

local RANOX = {}

-- ═══════════════════════════════════════════════════════════════════
-- PALETA
-- ═══════════════════════════════════════════════════════════════════
local P = {
    Bg          = Color3.fromRGB(16, 16, 20),
    BgSolid     = Color3.fromRGB(20, 20, 25),
    Surface     = Color3.fromRGB(28, 28, 34),
    SurfaceHi   = Color3.fromRGB(40, 40, 48),
    SurfaceLow  = Color3.fromRGB(22, 22, 28),
    Border      = Color3.fromRGB(52, 52, 62),
    Accent      = Color3.fromRGB(170, 20, 20),
    AccentHi    = Color3.fromRGB(255, 60, 60),
    AccentSoft  = Color3.fromRGB(120, 15, 15),
    Text        = Color3.fromRGB(245, 245, 250),
    TextDim     = Color3.fromRGB(175, 175, 185),
    TextMute    = Color3.fromRGB(120, 120, 130),
    Success     = Color3.fromRGB(0, 220, 130),
    Warning     = Color3.fromRGB(255, 180, 50),
    Danger      = Color3.fromRGB(255, 80, 100),
}

-- ═══════════════════════════════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════════════════════════════
local function tw(inst, dur, props, style, dir)
    local t = TweenService:Create(
        inst,
        TweenInfo.new(dur or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props
    )
    t:Play()
    return t
end

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, 8)
    c.Parent = parent
    return c
end

local function addStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or P.Border
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.4
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function addPadding(parent, t, l, r, b)
    local p = Instance.new("UIPadding", parent)
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    return p
end

-- ═══════════════════════════════════════════════════════════════════
-- CREATE WINDOW
-- ═══════════════════════════════════════════════════════════════════
function RANOX:CreateWindow(config)
    config = config or {}
    local Window = {}

    -- Tamanho padrão + variável de tamanho ATUAL (persiste após resize)
    local DEFAULT_SIZE = Vector2.new(575, 375)
    local MIN_SIZE     = Vector2.new(400, 300)
    local MAX_SIZE     = Vector2.new(1200, 900)
    local currentSize  = DEFAULT_SIZE

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RANOX_UI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 99e99
    pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
    if not screenGui.Parent then
        screenGui.Parent = player:WaitForChild("PlayerGui")
    end

    -- ═══════════════ SOMBRA (sincronizada em tempo real)
    local shadowHolder = Instance.new("Frame", screenGui)
    shadowHolder.Name = "ShadowHolder"
    shadowHolder.BackgroundTransparency = 1
    shadowHolder.Size = UDim2.new(0, currentSize.X + 6, 0, currentSize.Y + 6)
    shadowHolder.Position = UDim2.new(0.5, 0, 0.5, 2)
    shadowHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    shadowHolder.ZIndex = 0

    local shadowImg = Instance.new("ImageLabel", shadowHolder)
    shadowImg.Size = UDim2.new(1, 0, 1, 0)
    shadowImg.BackgroundTransparency = 1
    shadowImg.Image = "rbxassetid://1316045217"
    shadowImg.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadowImg.ImageTransparency = 0.55
    shadowImg.ScaleType = Enum.ScaleType.Slice
    shadowImg.SliceCenter = Rect.new(6, 6, 122, 122)

    -- ═══════════════ MAIN FRAME
    local mainFrame = Instance.new("TextButton")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = P.Bg
    mainFrame.BackgroundTransparency = 0
    mainFrame.Text = ""
    mainFrame.AutoButtonColor = false
    mainFrame.ClipsDescendants = true
    mainFrame.Draggable = true
    mainFrame.Active = true
    mainFrame.Parent = screenGui
    addCorner(mainFrame, UDim.new(0, 12))

    local stroke = addStroke(mainFrame, P.Accent, 1.5, 0.25)
    stroke.Name = "MainStroke"

    local gradient = Instance.new("UIGradient", mainFrame)
    gradient.Name = "MainGradient"
    gradient.Rotation = 135
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, P.BgSolid),
        ColorSequenceKeypoint.new(1, P.Bg),
    }

    -- ─── GRID
    local gridHolder = Instance.new("Frame", mainFrame)
    gridHolder.Name = "GridHolder"
    gridHolder.Size = UDim2.new(1, 0, 1, 0)
    gridHolder.BackgroundTransparency = 1
    gridHolder.ClipsDescendants = true
    gridHolder.ZIndex = 0
    for i = 0, 14 do
        local l = Instance.new("Frame", gridHolder)
        l.BackgroundColor3 = P.Border
        l.BackgroundTransparency = 0.9
        l.BorderSizePixel = 0
        l.Size = UDim2.new(0, 1, 1, 0)
        l.Position = UDim2.new(0, i * 44, 0, 0)
        l.ZIndex = 0
    end
    for i = 0, 10 do
        local l = Instance.new("Frame", gridHolder)
        l.BackgroundColor3 = P.Border
        l.BackgroundTransparency = 0.9
        l.BorderSizePixel = 0
        l.Size = UDim2.new(1, 0, 0, 1)
        l.Position = UDim2.new(0, 0, 0, i * 42)
        l.ZIndex = 0
    end

    -- ─── ORBS
    local decor = Instance.new("Frame", mainFrame)
    decor.Name = "Decor"
    decor.Size = UDim2.new(1, 0, 1, 0)
    decor.BackgroundTransparency = 1
    decor.ClipsDescendants = true
    decor.ZIndex = 0

    local orb1 = Instance.new("Frame", decor)
    orb1.Size = UDim2.new(0, 260, 0, 260)
    orb1.Position = UDim2.new(-0.3, 0, -0.3, 0)
    orb1.BackgroundColor3 = P.Accent
    orb1.BackgroundTransparency = 0.88
    orb1.BorderSizePixel = 0
    orb1.ZIndex = 0
    addCorner(orb1, UDim.new(1, 0))

    local orb2 = Instance.new("Frame", decor)
    orb2.Size = UDim2.new(0, 220, 0, 220)
    orb2.Position = UDim2.new(0.9, 0, 0.8, 0)
    orb2.BackgroundColor3 = Color3.fromRGB(120, 0, 60)
    orb2.BackgroundTransparency = 0.9
    orb2.BorderSizePixel = 0
    orb2.ZIndex = 0
    addCorner(orb2, UDim.new(1, 0))

    task.spawn(function()
        local t = 0
        while mainFrame.Parent do
            t += task.wait(0.033)
            orb1.Position = UDim2.new(-0.3 + math.sin(t*0.6)*0.08, 0, -0.3 + math.cos(t*0.5)*0.08, 0)
            orb2.Position = UDim2.new(0.9 + math.cos(t*0.4)*0.06, 0, 0.8 + math.sin(t*0.7)*0.06, 0)
        end
    end)

    -- ─── GLOW LINHA
    local topGlow = Instance.new("Frame", mainFrame)
    topGlow.Size = UDim2.new(0, 120, 0, 2)
    topGlow.Position = UDim2.new(0, 0, 0, 0)
    topGlow.BackgroundColor3 = P.AccentHi
    topGlow.BorderSizePixel = 0
    topGlow.ZIndex = 6
    addCorner(topGlow, UDim.new(0, 3))

    task.spawn(function()
        while topGlow.Parent do
            topGlow.Position = UDim2.new(0, -120, 0, 0)
            tw(topGlow, 2.8, { Position = UDim2.new(1, 0, 0, 0) }, Enum.EasingStyle.Linear)
            task.wait(2.8)
        end
    end)

    local function AtualizarCorInterface(corStroke, corGradiente1, corGradiente2)
        stroke.Color = corStroke
        gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, corGradiente1),
            ColorSequenceKeypoint.new(1, corGradiente2),
        }
        topGlow.BackgroundColor3 = corGradiente2
        orb1.BackgroundColor3 = corStroke
    end

    -- ═══════════════ TÍTULO
    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, -50, 0, 26)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "RANOX Hub"
    title.TextColor3 = P.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Center
    title.ClipsDescendants = true
    title.ZIndex = 5

    local subtitle = Instance.new("TextLabel", mainFrame)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = config.Subtitle or "v1.0"
    subtitle.TextColor3 = P.TextMute
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 9
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.TextYAlignment = Enum.TextYAlignment.Center
    subtitle.Size = UDim2.new(0, 100, 0, 26)
    subtitle.ZIndex = 5

    task.defer(function()
        subtitle.Position = UDim2.new(0, 12 + title.TextBounds.X + 8, 0, 0)
    end)

    -- ═══════════════ BOTÃO DE MINIMIZAR
    local hideButton = Instance.new("TextButton", mainFrame)
    hideButton.Size = UDim2.new(0, 26, 0, 26)
    hideButton.Position = UDim2.new(1, -34, 0, 0)
    hideButton.BackgroundColor3 = P.Surface
    hideButton.BackgroundTransparency = 0.4
    hideButton.Text = "−"
    hideButton.TextColor3 = P.TextDim
    hideButton.TextSize = 16
    hideButton.Font = Enum.Font.GothamBold
    hideButton.AutoButtonColor = false
    hideButton.BorderSizePixel = 0
    hideButton.ZIndex = 5
    addCorner(hideButton, UDim.new(0, 6))
    local hideStroke = addStroke(hideButton, P.Border, 1, 0.4)

    hideButton.MouseEnter:Connect(function()
        tw(hideButton, 0.2, { BackgroundColor3 = P.AccentSoft, BackgroundTransparency = 0.1 })
        tw(hideStroke, 0.2, { Color = P.Accent })
    end)
    hideButton.MouseLeave:Connect(function()
        tw(hideButton, 0.2, { BackgroundColor3 = P.Surface, BackgroundTransparency = 0.4 })
        tw(hideStroke, 0.2, { Color = P.Border, Transparency = 0.4 })
    end)

    -- ═══════════════ LINHA
    local line = Instance.new("Frame", mainFrame)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0, 26)
    line.BackgroundColor3 = P.Accent
    line.BackgroundTransparency = 0.3
    line.BorderSizePixel = 0
    line.ZIndex = 4

    -- ═══════════════ SIDEBAR
    local sidebar = Instance.new("ScrollingFrame", mainFrame)
    sidebar.Size = UDim2.new(0.25, 0, 1, -26)
    sidebar.Position = UDim2.new(0, 0, 0, 26)
    sidebar.BackgroundColor3 = P.BgSolid
    sidebar.BackgroundTransparency = 0.3
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebar.ScrollBarThickness = 3
    sidebar.ScrollBarImageColor3 = P.Accent
    sidebar.BorderSizePixel = 0
    sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
    addCorner(sidebar, UDim.new(0, 4))

    local sidebarLayout = Instance.new("UIListLayout", sidebar)
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Padding = UDim.new(0, 3)
    addPadding(sidebar, 5, 5, 5, 0)

    local searchBox = Instance.new("TextBox", sidebar)
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(1, 0, 0, 26)
    searchBox.BackgroundColor3 = P.Surface
    searchBox.BorderSizePixel = 0
    searchBox.Text = ""
    searchBox.PlaceholderText = "🔍  Buscar..."
    searchBox.PlaceholderColor3 = P.TextMute
    searchBox.TextColor3 = P.Text
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 11
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus = false
    searchBox.LayoutOrder = -1
    addCorner(searchBox, UDim.new(0, 6))
    addStroke(searchBox, P.Border, 1, 0.5)
    addPadding(searchBox, 0, 8, 8, 0)

    local tabButtons = {}
    local pages = {}
    local selectedTab = nil

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = string.lower(searchBox.Text)
        for name, btn in pairs(tabButtons) do
            btn.Visible = (q == "") or (string.find(string.lower(name), q, 1, true) ~= nil)
        end
    end)

    -- ═══════════════ SCROLL HOLDER
    local scrollHolder = Instance.new("ScrollingFrame", mainFrame)
    scrollHolder.Position = UDim2.new(0.25, 4, 0, 31)
    scrollHolder.Size = UDim2.new(0.75, -8, 1, -36)
    scrollHolder.BackgroundTransparency = 1
    scrollHolder.BorderSizePixel = 0
    scrollHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollHolder.ScrollBarThickness = 4
    scrollHolder.ScrollBarImageColor3 = P.Accent
    scrollHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y

    -- ═══════════════ BALL BUTTON
    local ballButton = Instance.new("ImageButton")
    ballButton.Size = UDim2.new(0, 50, 0, 50)
    ballButton.Position = UDim2.new(0.1, 0, 0.9, -150)
    ballButton.AnchorPoint = Vector2.new(0.5, 0.5)
    ballButton.BackgroundColor3 = P.Accent
    ballButton.Image = "rbxassetid://6337069410"
    ballButton.BackgroundTransparency = 0
    ballButton.Visible = false
    ballButton.Active = true
    ballButton.Draggable = true
    ballButton.Parent = screenGui
    addCorner(ballButton, UDim.new(0.5, 0))
    local ballStroke = addStroke(ballButton, P.AccentHi, 2, 0.2)

    task.spawn(function()
        while ballButton.Parent do
            tw(ballStroke, 1.2, { Transparency = 0.8 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
            tw(ballStroke, 1.2, { Transparency = 0.2 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
        end
    end)

    -- ═══════════════════════════════════════════════════════════════
    -- RESIZE HANDLE (MELHORADO)
    -- ═══════════════════════════════════════════════════════════════
    local resizeHandle = Instance.new("TextButton", mainFrame)
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.new(0, 20, 0, 20)
    resizeHandle.Position = UDim2.new(1, -24, 1, -24)
    resizeHandle.AnchorPoint = Vector2.new(0, 0)
    resizeHandle.BackgroundColor3 = P.Surface
    resizeHandle.BackgroundTransparency = 0.35
    resizeHandle.Text = "◢"
    resizeHandle.TextColor3 = P.TextDim
    resizeHandle.TextSize = 14
    resizeHandle.Font = Enum.Font.GothamBold
    resizeHandle.TextXAlignment = Enum.TextXAlignment.Center
    resizeHandle.TextYAlignment = Enum.TextYAlignment.Center
    resizeHandle.AutoButtonColor = false
    resizeHandle.ZIndex = 20
    addCorner(resizeHandle, UDim.new(0, 5))

    local resizeStroke = addStroke(resizeHandle, P.Border, 1.2, 0.35)

    -- brilho interno (glow pulsante quando idle)
    local resizeGlow = Instance.new("ImageLabel", resizeHandle)
    resizeGlow.Size = UDim2.new(1, 4, 1, 4)
    resizeGlow.Position = UDim2.new(0, -2, 0, -2)
    resizeGlow.BackgroundTransparency = 1
    resizeGlow.Image = "rbxassetid://1316045217"
    resizeGlow.ImageColor3 = P.AccentHi
    resizeGlow.ImageTransparency = 1
    resizeGlow.ScaleType = Enum.ScaleType.Slice
    resizeGlow.SliceCenter = Rect.new(10, 10, 118, 118)
    resizeGlow.ZIndex = -1

    -- Hover / Leave
    local hovered = false
    resizeHandle.MouseEnter:Connect(function()
        hovered = true
        tw(resizeHandle, 0.18, {
            BackgroundColor3 = P.AccentSoft,
            BackgroundTransparency = 0.1,
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(1, -28, 1, -28),
        }, Enum.EasingStyle.Back)
        tw(resizeStroke, 0.18, { Color = P.AccentHi, Transparency = 0 })
        tw(resizeGlow, 0.18, { ImageTransparency = 0.7 })
    end)
    resizeHandle.MouseLeave:Connect(function()
        hovered = false
        tw(resizeHandle, 0.2, {
            BackgroundColor3 = P.Surface,
            BackgroundTransparency = 0.35,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(1, -24, 1, -24),
        }, Enum.EasingStyle.Back)
        tw(resizeStroke, 0.2, { Color = P.Border, Transparency = 0.35 })
        tw(resizeGlow, 0.2, { ImageTransparency = 1 })
    end)

    -- Pulso idle
    task.spawn(function()
        while resizeHandle.Parent do
            if not hovered then
                tw(resizeStroke, 1.6, { Transparency = 0.85 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(1.6)
                tw(resizeStroke, 1.6, { Transparency = 0.35 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(1.6)
            else
                task.wait(0.4)
            end
        end
    end)

    -- Lógica de resize
    do
        local dragging = false
        local startSize, startPos

        resizeHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                startSize = mainFrame.AbsoluteSize
                startPos = input.Position
                tw(resizeHandle, 0.15, { BackgroundColor3 = P.AccentHi, BackgroundTransparency = 0 })
                tw(resizeGlow, 0.15, { ImageTransparency = 0.3 })
            end
        end)

        UIS.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - startPos
                local w = math.clamp(startSize.X + delta.X, MIN_SIZE.X, MAX_SIZE.X)
                local h = math.clamp(startSize.Y + delta.Y, MIN_SIZE.Y, MAX_SIZE.Y)
                mainFrame.Size = UDim2.new(0, w, 0, h)
                currentSize = Vector2.new(w, h)
            end
        end)

        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                if dragging then
                    dragging = false
                    local finalSize = mainFrame.AbsoluteSize
                    currentSize = Vector2.new(finalSize.X, finalSize.Y)
                    tw(resizeHandle, 0.2, { BackgroundColor3 = P.Surface, BackgroundTransparency = 0.35 })
                    tw(resizeGlow, 0.2, { ImageTransparency = 1 })
                end
            end
        end)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- SYNC LOOP: sombra segue posição + tamanho do mainFrame
    -- ═══════════════════════════════════════════════════════════════
    local syncConn = RunService.RenderStepped:Connect(function()
        if not mainFrame or not mainFrame.Parent then return end

        shadowHolder.Position = UDim2.new(
            mainFrame.Position.X.Scale,
            mainFrame.Position.X.Offset,
            mainFrame.Position.Y.Scale,
            mainFrame.Position.Y.Offset + 2
        )
        shadowHolder.Size = UDim2.new(
            0, mainFrame.AbsoluteSize.X + 6,
            0, mainFrame.AbsoluteSize.Y + 6
        )
    end)

    -- ═══════════════ ANIMAÇÃO DE ENTRADA (cascata)
    task.spawn(function()
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        mainFrame.BackgroundTransparency = 1
        shadowImg.ImageTransparency = 1

        task.wait(0.05)
        mainFrame.Size = UDim2.new(0, currentSize.X - 35, 0, currentSize.Y - 20)
        tw(mainFrame, 0.55, { Size = UDim2.new(0, currentSize.X, 0, currentSize.Y) }, Enum.EasingStyle.Back)
        tw(mainFrame, 0.4, { BackgroundTransparency = 0 }, Enum.EasingStyle.Quint)
        tw(shadowImg, 0.5, { ImageTransparency = 0.55 })

        sidebar.Position = UDim2.new(0, -50, 0, 26)
        task.wait(0.15)
        tw(sidebar, 0.45, { Position = UDim2.new(0, 0, 0, 26) }, Enum.EasingStyle.Quint)

        title.Position = UDim2.new(0, -60, 0, 0)
        tw(title, 0.4, { Position = UDim2.new(0, 12, 0, 0) }, Enum.EasingStyle.Quint)
    end)

    -- ═══════════════ SWITCH TAB
    local function switchTab(name)
        for tabName, frame in pairs(pages) do
            local isActive = (tabName == name)
            frame.Visible = isActive
            if isActive then
                frame.Position = UDim2.new(0, 20, 0, 0)
                tw(frame, 0.28, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Quint)
            end
        end
        for tabName, btn in pairs(tabButtons) do
            local marker = btn:FindFirstChild("TabMarker")
            if marker then marker.Visible = (tabName == name) end
            tw(btn, 0.2, {
                BackgroundColor3 = (tabName == name) and P.SurfaceHi or P.Surface,
            })
        end
        selectedTab = name
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE TAB
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateTab(tabName, iconId)
        local tabBtn = Instance.new("TextButton", sidebar)
        tabBtn.Size = UDim2.new(1, 0, 0, 32)
        tabBtn.Text = ""
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextSize = 12
        tabBtn.TextColor3 = P.Text
        tabBtn.BackgroundColor3 = P.Surface
        tabBtn.AutoButtonColor = false
        tabBtn.ClipsDescendants = true
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        addCorner(tabBtn, UDim.new(0, 6))

        local uiStroke = addStroke(tabBtn, P.Border, 1, 0.6)

        local marker = Instance.new("Frame", tabBtn)
        marker.Name = "TabMarker"
        marker.Size = UDim2.new(0, 3, 1, -8)
        marker.Position = UDim2.new(0, 0, 0, 4)
        marker.BackgroundColor3 = P.AccentHi
        marker.BorderSizePixel = 0
        marker.Visible = false
        addCorner(marker, UDim.new(0, 4))

        local markerGlow = Instance.new("UIStroke", marker)
        markerGlow.Color = P.AccentHi
        markerGlow.Thickness = 1.5
        markerGlow.Transparency = 0.3

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

        tabBtn.MouseEnter:Connect(function()
            if selectedTab ~= tabName then
                tw(tabBtn, 0.2, { BackgroundColor3 = P.SurfaceHi })
                tw(uiStroke, 0.2, { Color = P.Border, Transparency = 0.3 })
            end
        end)

        tabBtn.MouseLeave:Connect(function()
            if selectedTab ~= tabName then
                tw(tabBtn, 0.2, { BackgroundColor3 = P.Surface })
                tw(uiStroke, 0.2, { Color = P.Border, Transparency = 0.6 })
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
        addPadding(tabPage, 4, 4, 8, 4)

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
            switchTab(tabName)
        end)

        if not selectedTab then switchTab(tabName) end
    end

    -- ═══════════════════════════════════════════════════════════════
    -- RIPPLE
    -- ═══════════════════════════════════════════════════════════════
    local function addRipple(parent)
        local ripple = Instance.new("Frame", parent)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.75
        ripple.BorderSizePixel = 0
        ripple.ZIndex = 2
        addCorner(ripple, UDim.new(1, 0))
        local t = tw(ripple, 0.5, {
            Size = UDim2.new(1.8, 0, 4, 0),
            BackgroundTransparency = 1,
        }, Enum.EasingStyle.Quad)
        t.Completed:Connect(function() ripple:Destroy() end)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE BUTTON
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateButton(tabName, text, callback)
        local tab = pages[tabName]
        if not tab then return end

        local btn = Instance.new("TextButton", tab)
        btn.Size = UDim2.new(1, -20, 0, 28)
        btn.Position = UDim2.new(0, 10, 0, 0)
        btn.Text = text
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 14
        btn.TextColor3 = P.Text
        btn.BackgroundColor3 = P.SurfaceHi
        btn.AutoButtonColor = false
        btn.ClipsDescendants = true
        btn.TextWrapped = true
        addCorner(btn, UDim.new(0, 6))
        local btnStroke = addStroke(btn, P.Border, 1, 0.5)

        local accentBar = Instance.new("Frame", btn)
        accentBar.Size = UDim2.new(0, 3, 1, 0)
        accentBar.BackgroundColor3 = P.Accent
        accentBar.BorderSizePixel = 0

        btn.MouseEnter:Connect(function()
            tw(btn, 0.2, { BackgroundColor3 = Color3.fromRGB(60, 20, 22) })
            tw(btnStroke, 0.2, { Color = P.AccentHi, Transparency = 0.2 })
            tw(accentBar, 0.2, { Size = UDim2.new(0, 5, 1, 0) })
        end)

        btn.MouseLeave:Connect(function()
            tw(btn, 0.2, { BackgroundColor3 = P.SurfaceHi })
            tw(btnStroke, 0.2, { Color = P.Border, Transparency = 0.5 })
            tw(accentBar, 0.2, { Size = UDim2.new(0, 3, 1, 0) })
        end)

        btn.MouseButton1Click:Connect(function()
            addRipple(btn)
            tw(btn, 0.1, { Size = UDim2.new(1, -22, 0, 26) })
            task.delay(0.1, function()
                tw(btn, 0.15, { Size = UDim2.new(1, -20, 0, 28) }, Enum.EasingStyle.Back)
            end)
            if callback then pcall(callback) end
        end)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE CHECKBOX
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateCheckbox(tabName, checkboxConfig)
        local tab = pages[tabName]
        if not tab then return end
        checkboxConfig = checkboxConfig or {}

        local checkboxFrame = Instance.new("Frame", tab)
        checkboxFrame.Size = UDim2.new(1, -20, 0, 46)
        checkboxFrame.BackgroundColor3 = P.Surface
        checkboxFrame.BorderSizePixel = 0
        checkboxFrame.ClipsDescendants = true
        checkboxFrame.LayoutOrder = checkboxConfig.Order or 0
        addCorner(checkboxFrame, UDim.new(0, 8))
        local cfStroke = addStroke(checkboxFrame, P.Border, 1, 0.6)

        local title = Instance.new("TextLabel", checkboxFrame)
        title.Text = checkboxConfig.Text or "Checkbox"
        title.TextColor3 = P.Text
        title.Font = Enum.Font.GothamMedium
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextYAlignment = Enum.TextYAlignment.Top
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1, -50, 0, 16)
        title.Position = UDim2.new(0, 12, 0, 5)

        local description = Instance.new("TextLabel", checkboxFrame)
        description.Text = checkboxConfig.Description or ""
        description.TextColor3 = P.TextMute
        description.Font = Enum.Font.Gotham
        description.TextSize = 11
        description.TextXAlignment = Enum.TextXAlignment.Left
        description.TextYAlignment = Enum.TextYAlignment.Top
        description.BackgroundTransparency = 1
        description.Size = UDim2.new(1, -50, 0, 14)
        description.Position = UDim2.new(0, 12, 0, 24)

        local box = Instance.new("Frame", checkboxFrame)
        box.Size = UDim2.new(0, 24, 0, 24)
        box.Position = UDim2.new(1, -38, 0.5, -12)
        box.BackgroundColor3 = P.SurfaceLow
        box.BorderSizePixel = 0
        addCorner(box, UDim.new(0, 6))
        local boxStroke = addStroke(box, P.Border, 1.3, 0.3)

        local checkmark = Instance.new("TextLabel", box)
        checkmark.Size = UDim2.new(1, -4, 1, -4)
        checkmark.Position = UDim2.new(0, 2, 0, 2)
        checkmark.Text = "✔"
        checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
        checkmark.TextScaled = true
        checkmark.BackgroundTransparency = 1
        checkmark.Visible = false

        local button = Instance.new("TextButton", checkboxFrame)
        button.Size = UDim2.new(1, 0, 1, 0)
        button.BackgroundTransparency = 1
        button.Text = ""
        button.AutoButtonColor = false

        local toggled = false
        local running = false

        button.MouseEnter:Connect(function()
            tw(boxStroke, 0.2, { Color = P.AccentHi, Transparency = 0.1 })
            tw(checkboxFrame, 0.2, { BackgroundColor3 = P.SurfaceHi })
        end)
        button.MouseLeave:Connect(function()
            if not toggled then
                tw(boxStroke, 0.2, { Color = P.Border, Transparency = 0.3 })
            end
            tw(checkboxFrame, 0.2, { BackgroundColor3 = P.Surface })
        end)

        button.MouseButton1Click:Connect(function()
            toggled = not toggled
            checkmark.Visible = toggled
            checkmark.Size = UDim2.new(0, 0, 0, 0)
            tw(checkmark, 0.2, { Size = UDim2.new(1, -4, 1, -4) }, Enum.EasingStyle.Back)

            local grow = tw(box, 0.15, {
                Size = UDim2.new(0, 28, 0, 28),
                Position = UDim2.new(1, -40, 0.5, -14),
            }, Enum.EasingStyle.Quad)
            grow.Completed:Connect(function()
                tw(box, 0.15, {
                    Size = UDim2.new(0, 24, 0, 24),
                    Position = UDim2.new(1, -38, 0.5, -12),
                }, Enum.EasingStyle.Back)
            end)

            if toggled then
                tw(box, 0.2, { BackgroundColor3 = P.Accent })
                tw(boxStroke, 0.2, { Color = P.AccentHi, Transparency = 0 })
                running = true
                task.spawn(function()
                    while running and toggled do
                        pcall(checkboxConfig.Callback)
                        task.wait()
                    end
                end)
            else
                tw(box, 0.2, { BackgroundColor3 = P.SurfaceLow })
                tw(boxStroke, 0.2, { Color = P.Border, Transparency = 0.3 })
                running = false
            end

            if checkboxConfig.Callback then
                pcall(checkboxConfig.Callback, toggled)
            end
        end)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE TOGGLE
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateToggle(tabName, toggleConfig)
        local tab = pages[tabName]
        if not tab then return end
        toggleConfig = toggleConfig or {}

        local toggleFrame = Instance.new("Frame", tab)
        toggleFrame.Size = UDim2.new(1, -20, 0, 46)
        toggleFrame.Position = UDim2.new(0, 10, 0, 0)
        toggleFrame.BackgroundColor3 = P.Surface
        toggleFrame.ClipsDescendants = true
        toggleFrame.BorderSizePixel = 0
        addCorner(toggleFrame, UDim.new(0, 8))
        local tfStroke = addStroke(toggleFrame, P.Border, 1, 0.6)

        local title = Instance.new("TextLabel", toggleFrame)
        title.Text = toggleConfig.Text or "Toggle"
        title.TextColor3 = P.Text
        title.Font = Enum.Font.GothamMedium
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextYAlignment = Enum.TextYAlignment.Top
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1, -60, 0, 16)
        title.Position = UDim2.new(0, 12, 0, 5)

        local description = Instance.new("TextLabel", toggleFrame)
        description.Text = toggleConfig.Description or ""
        description.TextColor3 = P.TextMute
        description.Font = Enum.Font.Gotham
        description.TextSize = 11
        description.TextXAlignment = Enum.TextXAlignment.Left
        description.TextYAlignment = Enum.TextYAlignment.Top
        description.BackgroundTransparency = 1
        description.Size = UDim2.new(1, -60, 0, 14)
        description.Position = UDim2.new(0, 12, 0, 24)

        local switch = Instance.new("Frame", toggleFrame)
        switch.Size = UDim2.new(0, 42, 0, 22)
        switch.Position = UDim2.new(1, -54, 0.5, -11)
        switch.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        switch.BorderSizePixel = 0
        addCorner(switch, UDim.new(1, 0))

        local ball = Instance.new("Frame", switch)
        ball.Size = UDim2.new(0, 16, 0, 16)
        ball.Position = UDim2.new(0, 3, 0.5, -8)
        ball.BackgroundColor3 = Color3.fromRGB(210, 210, 215)
        ball.BorderSizePixel = 0
        addCorner(ball, UDim.new(1, 0))

        local ballGlow = addStroke(ball, P.AccentHi, 0, 1)

        local toggleButton = Instance.new("TextButton", switch)
        toggleButton.Size = UDim2.new(1, 0, 1, 0)
        toggleButton.BackgroundTransparency = 1
        toggleButton.Text = ""
        toggleButton.AutoButtonColor = false

        local isOn = false

        toggleButton.MouseEnter:Connect(function()
            tw(tfStroke, 0.2, { Color = P.AccentHi, Transparency = 0.2 })
        end)
        toggleButton.MouseLeave:Connect(function()
            tw(tfStroke, 0.2, { Color = P.Border, Transparency = 0.6 })
        end)

        toggleButton.MouseButton1Click:Connect(function()
            isOn = not isOn
            local bgColor = isOn and P.Accent or Color3.fromRGB(50, 50, 55)
            local ballPos = isOn and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            local ballColor = isOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(210, 210, 215)

            tw(switch, 0.3, { BackgroundColor3 = bgColor }, Enum.EasingStyle.Back)
            tw(ball, 0.3, { Position = ballPos, BackgroundColor3 = ballColor }, Enum.EasingStyle.Back)
            tw(ballGlow, 0.3, { Thickness = isOn and 2 or 0, Transparency = isOn and 0.2 or 1 })

            if toggleConfig.Callback then pcall(toggleConfig.Callback, isOn) end
        end)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE LABEL
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateLabel(tabName, text)
        local tab = pages[tabName]
        if not tab then return end

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

        local accentDot = Instance.new("Frame", label)
        accentDot.Size = UDim2.new(0, 6, 0, 6)
        accentDot.Position = UDim2.new(0, 0, 0.5, -3)
        accentDot.BackgroundColor3 = P.AccentHi
        accentDot.BorderSizePixel = 0
        addCorner(accentDot, UDim.new(1, 0))

        local dotGlow = Instance.new("UIStroke", accentDot)
        dotGlow.Color = P.AccentHi
        dotGlow.Thickness = 2
        dotGlow.Transparency = 0.3

        task.spawn(function()
            while accentDot.Parent do
                tw(dotGlow, 1.2, { Transparency = 0.9 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(1.2)
                tw(dotGlow, 1.2, { Transparency = 0.2 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(1.2)
            end
        end)

        local underline = Instance.new("Frame", label)
        underline.Size = UDim2.new(1, -20, 0, 1)
        underline.Position = UDim2.new(0, 10, 1, -3)
        underline.BackgroundColor3 = P.Border
        underline.BorderSizePixel = 0
        local ug = Instance.new("UIGradient", underline)
        ug.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE DROPDOWN
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateDropdown(tabName, dropdownConfig)
        local tab = pages[tabName]
        if not tab then return end
        dropdownConfig = dropdownConfig or {}

        local dropdownFrame = Instance.new("Frame", tab)
        dropdownFrame.Size = UDim2.new(1, -20, 0, 34)
        dropdownFrame.Position = UDim2.new(0, 10, 0, 0)
        dropdownFrame.BackgroundColor3 = P.Surface
        dropdownFrame.BorderSizePixel = 0
        dropdownFrame.ZIndex = 2
        addCorner(dropdownFrame, UDim.new(0, 8))
        local dfStroke = addStroke(dropdownFrame, P.Border, 1, 0.5)

        local title = Instance.new("TextLabel", dropdownFrame)
        title.BackgroundTransparency = 1
        title.Text = dropdownConfig.Text or "Selecione..."
        title.TextColor3 = P.TextDim
        title.Font = Enum.Font.GothamSemibold
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextYAlignment = Enum.TextYAlignment.Center
        title.Size = UDim2.new(0, 200, 1, 0)
        title.Position = UDim2.new(0, 12, 0, 0)
        title.ZIndex = 3

        local arrowIcon = Instance.new("TextLabel", dropdownFrame)
        arrowIcon.Size = UDim2.new(0, 14, 0, 14)
        arrowIcon.Position = UDim2.new(1, -24, 0.5, -7)
        arrowIcon.BackgroundTransparency = 1
        arrowIcon.Text = "˅"
        arrowIcon.TextColor3 = P.TextDim
        arrowIcon.Font = Enum.Font.GothamBold
        arrowIcon.TextSize = 14
        arrowIcon.ZIndex = 3

        local selectedLabel = Instance.new("TextLabel", dropdownFrame)
        selectedLabel.BackgroundTransparency = 1
        selectedLabel.Text = dropdownConfig.Default or "None"
        selectedLabel.TextColor3 = P.Text
        selectedLabel.Font = Enum.Font.GothamBold
        selectedLabel.TextSize = 13
        selectedLabel.TextXAlignment = Enum.TextXAlignment.Right
        selectedLabel.TextYAlignment = Enum.TextYAlignment.Center
        selectedLabel.Size = UDim2.new(0, 0, 1, 0)
        selectedLabel.Position = UDim2.new(1, -arrowIcon.Size.X.Offset - 10, 0, 0)
        selectedLabel.ZIndex = 3

        local function updateSelectedLabelText(text)
            selectedLabel.Text = text
            selectedLabel.Size = UDim2.new(0, selectedLabel.TextBounds.X + 6, 1, 0)
            selectedLabel.Position = UDim2.new(1, -arrowIcon.Size.X.Offset - selectedLabel.Size.X.Offset - 14, 0, 0)
        end
        updateSelectedLabelText(selectedLabel.Text)

        local toggleButton = Instance.new("TextButton", dropdownFrame)
        toggleButton.Size = UDim2.new(1, 0, 1, 0)
        toggleButton.BackgroundTransparency = 1
        toggleButton.Text = ""
        toggleButton.ZIndex = 4

        local dropdownList = Instance.new("Frame", tab)
        dropdownList.Size = UDim2.new(1, -20, 0, 0)
        dropdownList.Position = UDim2.new(0, 10, 0, 0)
        dropdownList.BackgroundColor3 = P.SurfaceLow
        dropdownList.Visible = false
        dropdownList.ClipsDescendants = true
        dropdownList.ZIndex = 5
        addCorner(dropdownList, UDim.new(0, 8))
        addStroke(dropdownList, P.Border, 1, 0.4)

        local listLayout = Instance.new("UIListLayout", dropdownList)
        listLayout.Padding = UDim.new(0, 2)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        addPadding(dropdownList, 4, 4, 4, 4)

        local isOpen = false
        toggleButton.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            dropdownList.Visible = true
            local targetHeight = isOpen and (#(dropdownConfig.Options or {}) * 32 + 12) or 0
            arrowIcon.Text = isOpen and "˄" or "˅"
            dropdownList:TweenSize(UDim2.new(1, -20, 0, targetHeight), "Out", "Back", 0.3, true)
            tw(dfStroke, 0.25, { Color = isOpen and P.AccentHi or P.Border })
            if not isOpen then
                task.delay(0.3, function() dropdownList.Visible = false end)
            end
        end)

        for _, option in ipairs(dropdownConfig.Options or {}) do
            local optBtn = Instance.new("TextButton", dropdownList)
            optBtn.Size = UDim2.new(1, 0, 0, 32)
            optBtn.Text = option
            optBtn.BackgroundColor3 = P.SurfaceHi
            optBtn.TextColor3 = P.Text
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextSize = 13
            optBtn.AutoButtonColor = false
            optBtn.ZIndex = 6
            addCorner(optBtn, UDim.new(0, 6))

            optBtn.MouseEnter:Connect(function()
                tw(optBtn, 0.15, { BackgroundColor3 = Color3.fromRGB(60, 20, 22) })
            end)
            optBtn.MouseLeave:Connect(function()
                tw(optBtn, 0.15, { BackgroundColor3 = P.SurfaceHi })
            end)

            optBtn.MouseButton1Click:Connect(function()
                updateSelectedLabelText(option)
                if dropdownConfig.Callback then pcall(dropdownConfig.Callback, option) end
                isOpen = false
                arrowIcon.Text = "˅"
                dropdownList:TweenSize(UDim2.new(1, -20, 0, 0), "In", "Back", 0.25, true)
                task.delay(0.25, function() dropdownList.Visible = false end)
            end)
        end
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE SLIDER
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateSlider(tabName, sliderConfig)
        local tab = pages[tabName]
        if not tab then return end
        sliderConfig = sliderConfig or {}

        local sliderHolder = Instance.new("Frame", tab)
        sliderHolder.Size = UDim2.new(1, -20, 0, 0)
        sliderHolder.Position = UDim2.new(0, 10, 0, 0)
        sliderHolder.BackgroundTransparency = 1
        sliderHolder.ZIndex = 2
        sliderHolder.AutomaticSize = Enum.AutomaticSize.Y

        local layout = Instance.new("UIListLayout", sliderHolder)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        local bg = Instance.new("Frame", sliderHolder)
        bg.Size = UDim2.new(1, 0, 0, 58)
        bg.BackgroundColor3 = P.SurfaceLow
        bg.BorderSizePixel = 0
        bg.ZIndex = 2
        addCorner(bg, UDim.new(0, 8))
        addStroke(bg, P.Border, 1, 0.5)

        local title = Instance.new("TextLabel", bg)
        title.Size = UDim2.new(1, -60, 0, 16)
        title.Position = UDim2.new(0, 12, 0, 6)
        title.Text = sliderConfig.Text or "Slider"
        title.TextColor3 = P.Text
        title.TextSize = 14
        title.Font = Enum.Font.GothamMedium
        title.BackgroundTransparency = 1
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 3

        local desc = Instance.new("TextLabel", bg)
        desc.Size = UDim2.new(1, -20, 0, 11)
        desc.Position = UDim2.new(0, 12, 0, 24)
        desc.Text = sliderConfig.Description or ""
        desc.TextColor3 = P.TextMute
        desc.TextSize = 11
        desc.Font = Enum.Font.Gotham
        desc.BackgroundTransparency = 1
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.ZIndex = 3

        local valueLabel = Instance.new("TextLabel", bg)
        valueLabel.Size = UDim2.new(0, 50, 0, 16)
        valueLabel.Position = UDim2.new(1, -62, 0, 6)
        valueLabel.TextColor3 = P.AccentHi
        valueLabel.TextSize = 14
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.BackgroundTransparency = 1
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.ZIndex = 3

        local bar = Instance.new("Frame", bg)
        bar.Size = UDim2.new(1, -24, 0, 8)
        bar.Position = UDim2.new(0, 12, 0, 46)
        bar.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
        bar.BorderSizePixel = 0
        bar.ZIndex = 2
        addCorner(bar, UDim.new(1, 0))

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = P.Accent
        fill.BorderSizePixel = 0
        fill.ZIndex = 3
        addCorner(fill, UDim.new(1, 0))

        local fillGrad = Instance.new("UIGradient", fill)
        fillGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, P.AccentSoft),
            ColorSequenceKeypoint.new(1, P.AccentHi),
        }

        local neonStroke = Instance.new("UIStroke", fill)
        neonStroke.Thickness = 3
        neonStroke.Transparency = 0.3
        neonStroke.Color = P.AccentHi

        task.spawn(function()
            local state = true
            while fill.Parent do
                local goal = state and Color3.fromRGB(195, 20, 20) or Color3.fromRGB(255, 30, 30)
                tw(fill, 1.5, { BackgroundColor3 = goal }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                neonStroke.Color = goal
                state = not state
                task.wait(1.6)
            end
        end)

        local knob = Instance.new("Frame", bar)
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = UDim2.new(0, -8, 0.5, -8)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.ZIndex = 4
        addCorner(knob, UDim.new(1, 0))
        addStroke(knob, P.AccentHi, 2, 0.2)

        local min = sliderConfig.Min or 0
        local max = sliderConfig.Max or 100

        local function roundToDecimals(num, decimals)
            local mult = 10 ^ decimals
            return math.floor(num * mult + 0.5) / mult
        end

        local function updateSlider(inputX)
            local barAbsPos = bar.AbsolutePosition.X
            local barWidth = bar.AbsoluteSize.X
            local clamped = math.clamp((inputX - barAbsPos) / barWidth, 0, 1)
            local rawValue = min + (max - min) * clamped
            local roundedValue = roundToDecimals(rawValue, 2)
            fill:TweenSize(UDim2.new(clamped, 0, 1, 0), "Out", "Quad", 0.08, true)
            knob:TweenPosition(UDim2.new(clamped, -8, 0.5, -8), "Out", "Quad", 0.08, true)
            valueLabel.Text = tostring(roundedValue)
            if sliderConfig.Callback then pcall(sliderConfig.Callback, roundedValue) end
        end

        local dragging = false

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                tw(knob, 0.15, {
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(knob.Position.X.Scale, -10, 0.5, -10),
                }, Enum.EasingStyle.Back)
                updateSlider(input.Position.X)
            end
        end)

        UIS.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input.Position.X)
            end
        end)

        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                tw(knob, 0.2, { Size = UDim2.new(0, 16, 0, 16) }, Enum.EasingStyle.Back)
            end
        end)

        updateSlider(bar.AbsolutePosition.X)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE TEXT BOX
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateTextBox(tabName, placeholderText, callback)
        local tab = pages[tabName]
        if not tab then return end

        local container = Instance.new("Frame", tab)
        container.Size = UDim2.new(1, -20, 0, 40)
        container.Position = UDim2.new(0, 10, 0, 0)
        container.BackgroundTransparency = 1
        container.ClipsDescendants = true

        local background = Instance.new("Frame", container)
        background.Size = UDim2.new(1, 0, 1, 0)
        background.BackgroundColor3 = P.Surface
        background.BorderSizePixel = 0
        background.ZIndex = 1
        addCorner(background, UDim.new(0, 8))
        local bgStroke = addStroke(background, P.Border, 1, 0.5)

        local highlight = Instance.new("Frame", background)
        highlight.Size = UDim2.new(1, 0, 0, 2)
        highlight.Position = UDim2.new(0, 0, 1, -2)
        highlight.BackgroundColor3 = P.Accent
        highlight.BackgroundTransparency = 1
        highlight.BorderSizePixel = 0
        highlight.ZIndex = 2

        local placeholder = Instance.new("TextLabel", background)
        placeholder.Size = UDim2.new(1, -20, 0, 14)
        placeholder.Position = UDim2.new(0, 10, 0.5, -7)
        placeholder.BackgroundTransparency = 1
        placeholder.Text = placeholderText or "Escreva aqui"
        placeholder.TextColor3 = P.TextMute
        placeholder.Font = Enum.Font.Gotham
        placeholder.TextSize = 13
        placeholder.TextXAlignment = Enum.TextXAlignment.Left
        placeholder.ZIndex = 2

        local textBox = Instance.new("TextBox", background)
        textBox.Size = UDim2.new(1, -20, 1, 0)
        textBox.Position = UDim2.new(0, 10, 0, 0)
        textBox.BackgroundTransparency = 1
        textBox.Text = ""
        textBox.TextColor3 = P.Text
        textBox.Font = Enum.Font.Gotham
        textBox.TextSize = 13
        textBox.ClearTextOnFocus = false
        textBox.TextXAlignment = Enum.TextXAlignment.Left
        textBox.TextWrapped = false
        textBox.TextTruncate = Enum.TextTruncate.AtEnd
        textBox.ZIndex = 3

        textBox.Focused:Connect(function()
            tw(highlight, 0.25, { BackgroundTransparency = 0.3 })
            tw(bgStroke, 0.25, { Color = P.AccentHi, Transparency = 0.1 })
            placeholder.Visible = false
        end)

        textBox.FocusLost:Connect(function(enterPressed)
            tw(highlight, 0.25, { BackgroundTransparency = 1 })
            tw(bgStroke, 0.25, { Color = P.Border, Transparency = 0.5 })
            if textBox.Text == "" then
                placeholder.Visible = true
            end
            if enterPressed and callback then pcall(callback, textBox.Text) end
        end)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE COLOR PICKER
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateColorPicker(tabName, colorConfig)
        local tab = pages[tabName]
        if not tab then return end
        colorConfig = colorConfig or {}

        local pickerFrame = Instance.new("Frame", tab)
        pickerFrame.Size = UDim2.new(1, -20, 0, 190)
        pickerFrame.Position = UDim2.new(0, 10, 0, 0)
        pickerFrame.BackgroundColor3 = P.Surface
        pickerFrame.ClipsDescendants = true
        addCorner(pickerFrame, UDim.new(0, 10))
        addStroke(pickerFrame, P.Border, 1, 0.5)

        local label = Instance.new("TextLabel", pickerFrame)
        label.Size = UDim2.new(1, -60, 0, 30)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = colorConfig.Text or "Escolha uma cor"
        label.TextColor3 = P.Text
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left

        local toggleButton = Instance.new("TextButton", pickerFrame)
        toggleButton.Size = UDim2.new(0, 24, 0, 24)
        toggleButton.Position = UDim2.new(1, -32, 0, 3)
        toggleButton.BackgroundTransparency = 1
        toggleButton.Text = "▼"
        toggleButton.TextColor3 = P.Text
        toggleButton.Font = Enum.Font.GothamBold
        toggleButton.TextSize = 14

        local container = Instance.new("Frame", pickerFrame)
        container.Size = UDim2.new(1, 0, 0, 160)
        container.Position = UDim2.new(0, 0, 0, 30)
        container.BackgroundTransparency = 1

        local colorDisplay = Instance.new("Frame", container)
        colorDisplay.Size = UDim2.new(1, -24, 0, 32)
        colorDisplay.Position = UDim2.new(0, 12, 0, 4)
        colorDisplay.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        addCorner(colorDisplay, UDim.new(0, 8))
        addStroke(colorDisplay, Color3.fromRGB(255, 255, 255), 1, 0.7)

        local function createGradientBar(parent, position, colorType)
            local bar = Instance.new("TextButton", parent)
            bar.Size = UDim2.new(0.68, 0, 0, 20)
            bar.Position = position
            bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            bar.AutoButtonColor = false
            bar.Text = ""
            addCorner(bar, UDim.new(0, 10))

            local gradient = Instance.new("UIGradient", bar)
            if colorType == "Hue" then
                gradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
                })
            elseif colorType == "Brightness" then
                gradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0)),
                })
            end
            return bar
        end

        local hueSlider = createGradientBar(container, UDim2.new(0, 12, 0, 46), "Hue")
        local brightnessSlider = createGradientBar(container, UDim2.new(0, 12, 0, 76), "Brightness")

        local hueMarker = Instance.new("Frame", hueSlider)
        hueMarker.Size = UDim2.new(0, 5, 0, 24)
        hueMarker.AnchorPoint = Vector2.new(0.5, 0.5)
        hueMarker.Position = UDim2.new(0, 0, 0.5, 0)
        hueMarker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        addCorner(hueMarker, UDim.new(1, 0))
        addStroke(hueMarker, Color3.fromRGB(0, 0, 0), 1, 0.3)

        local brightnessMarker = Instance.new("Frame", brightnessSlider)
        brightnessMarker.Size = UDim2.new(0, 5, 0, 24)
        brightnessMarker.AnchorPoint = Vector2.new(0.5, 0.5)
        brightnessMarker.Position = UDim2.new(1, 0, 0.5, 0)
        brightnessMarker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        addCorner(brightnessMarker, UDim.new(1, 0))
        addStroke(brightnessMarker, Color3.fromRGB(0, 0, 0), 1, 0.3)

        local rgbBox = Instance.new("TextBox", container)
        rgbBox.Size = UDim2.new(0.26, 0, 0, 20)
        rgbBox.Position = UDim2.new(0.72, 0, 0, 46)
        rgbBox.BackgroundColor3 = P.SurfaceHi
        rgbBox.TextColor3 = P.Text
        rgbBox.Font = Enum.Font.Gotham
        rgbBox.TextSize = 11
        rgbBox.Text = "0.255.255"
        addCorner(rgbBox, UDim.new(0, 6))

        local brightnessBox = Instance.new("TextBox", container)
        brightnessBox.Size = UDim2.new(0.26, 0, 0, 20)
        brightnessBox.Position = UDim2.new(0.72, 0, 0, 76)
        brightnessBox.BackgroundColor3 = P.SurfaceHi
        brightnessBox.TextColor3 = P.Text
        brightnessBox.Font = Enum.Font.Gotham
        brightnessBox.TextSize = 11
        brightnessBox.Text = "255"
        addCorner(brightnessBox, UDim.new(0, 6))

        local function applyColorFromBox()
            local r, g, b = rgbBox.Text:match("(%d+)%.(%d+)%.(%d+)")
            local brightness = tonumber(brightnessBox.Text)
            r, g, b = tonumber(r), tonumber(g), tonumber(b)
            brightness = math.clamp(brightness or 255, 0, 255)
            if r and g and b then
                local adjusted = Color3.fromRGB(
                    math.clamp(r * brightness / 255, 0, 255),
                    math.clamp(g * brightness / 255, 0, 255),
                    math.clamp(b * brightness / 255, 0, 255)
                )
                colorDisplay.BackgroundColor3 = adjusted
                if colorConfig.Callback then pcall(colorConfig.Callback, adjusted) end
            end
        end

        local function enableDragging(slider, marker, isHue)
            local dragging = false
            local function update(input)
                local relX = math.clamp(input.Position.X - slider.AbsolutePosition.X, 0, slider.AbsoluteSize.X)
                local percent = relX / slider.AbsoluteSize.X
                marker.Position = UDim2.new(percent, 0, 0.5, 0)
                if isHue then
                    local color = Color3.fromHSV(percent, 1, 1)
                    rgbBox.Text = math.floor(color.R * 255) .. "." .. math.floor(color.G * 255) .. "." .. math.floor(color.B * 255)
                else
                    brightnessBox.Text = tostring(math.floor(255 * (1 - percent)))
                end
                applyColorFromBox()
            end
            slider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    update(input)
                end
            end)
            UIS.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                    update(input)
                end
            end)
            UIS.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
        end

        enableDragging(hueSlider, hueMarker, true)
        enableDragging(brightnessSlider, brightnessMarker, false)

        rgbBox.FocusLost:Connect(applyColorFromBox)
        brightnessBox.FocusLost:Connect(applyColorFromBox)

        local opened = true
        toggleButton.MouseButton1Click:Connect(function()
            opened = not opened
            toggleButton.Text = opened and "▼" or "▲"
            local goalSize = opened and 190 or 32
            local goalContentSize = opened and 160 or 0
            tw(pickerFrame, 0.3, { Size = UDim2.new(1, -20, 0, goalSize) }, Enum.EasingStyle.Back)
            tw(container, 0.3, { Size = UDim2.new(1, 0, 0, goalContentSize) }, Enum.EasingStyle.Back)
        end)

        applyColorFromBox()

        local randomColorToggle = Instance.new("TextButton", container)
        randomColorToggle.Size = UDim2.new(1, -24, 0, 26)
        randomColorToggle.Position = UDim2.new(0, 12, 0, 110)
        randomColorToggle.BackgroundColor3 = P.SurfaceHi
        randomColorToggle.Text = "🎲  COR RGB ALEATÓRIA [OFF]"
        randomColorToggle.TextColor3 = P.Text
        randomColorToggle.Font = Enum.Font.GothamMedium
        randomColorToggle.TextSize = 12
        addCorner(randomColorToggle, UDim.new(0, 6))
        local rcStroke = addStroke(randomColorToggle, P.Border, 1, 0.4)

        local randomColorEnabled = false

        task.spawn(function()
            while pickerFrame.Parent do
                if randomColorEnabled then
                    local rc = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
                    tw(colorDisplay, 0.5, { BackgroundColor3 = rc })
                    if colorConfig.Callback then pcall(colorConfig.Callback, rc) end
                end
                task.wait(0.6)
            end
        end)

        randomColorToggle.MouseButton1Click:Connect(function()
            randomColorEnabled = not randomColorEnabled
            randomColorToggle.Text = randomColorEnabled and "🎲  COR RGB ALEATÓRIA [ON]" or "🎲  COR RGB ALEATÓRIA [OFF]"
            tw(rcStroke, 0.25, {
                Color = randomColorEnabled and P.AccentHi or P.Border,
                Transparency = randomColorEnabled and 0 or 0.4,
            })
        end)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE SWITCH
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateSwitch(tabName, switchConfig)
        local tab = pages[tabName]
        if not tab then return end
        switchConfig = switchConfig or {}

        local holder = Instance.new("Frame", tab)
        holder.Size = UDim2.new(1, -20, 0, 55)
        holder.Position = UDim2.new(0, 10, 0, 0)
        holder.BackgroundTransparency = 1

        local label = Instance.new("TextLabel", holder)
        label.Size = UDim2.new(0.6, 0, 1, -10)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = switchConfig.Text or "Switch"
        label.Font = Enum.Font.GothamBold
        label.TextColor3 = P.Text
        label.TextSize = 15
        label.TextXAlignment = Enum.TextXAlignment.Left

        local switch = Instance.new("Frame", holder)
        switch.Size = UDim2.new(0, 60, 0, 26)
        switch.Position = UDim2.new(1, -65, 0.5, -13)
        switch.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        switch.BorderSizePixel = 0
        addCorner(switch, UDim.new(1, 0))

        local glow = addStroke(switch, P.AccentHi, 1.5, 1)

        local circle = Instance.new("Frame", switch)
        circle.Size = UDim2.new(0, 22, 0, 22)
        circle.Position = UDim2.new(0, 3, 0.5, -11)
        circle.BackgroundColor3 = Color3.fromRGB(210, 210, 215)
        circle.BorderSizePixel = 0
        addCorner(circle, UDim.new(1, 0))

        local stateLabel = Instance.new("TextLabel", holder)
        stateLabel.Size = UDim2.new(0, 40, 1, -10)
        stateLabel.Position = UDim2.new(1, -115, 0, 0)
        stateLabel.BackgroundTransparency = 1
        stateLabel.Font = Enum.Font.GothamBold
        stateLabel.TextSize = 13
        stateLabel.TextColor3 = Color3.fromRGB(255, 85, 85)
        stateLabel.Text = "OFF"
        stateLabel.TextXAlignment = Enum.TextXAlignment.Right

        local underline = Instance.new("Frame", holder)
        underline.Size = UDim2.new(1, 0, 0, 1)
        underline.Position = UDim2.new(0, 0, 1, -3)
        underline.BackgroundColor3 = P.Border
        underline.BorderSizePixel = 0

        local particle = Instance.new("ParticleEmitter", circle)
        particle.Enabled = false
        particle.LightEmission = 1
        particle.Rate = 60
        particle.Lifetime = NumberRange.new(0.4, 0.6)
        particle.Speed = NumberRange.new(2, 4)
        particle.Size = NumberSequence.new(0.3)
        particle.Rotation = NumberRange.new(0, 360)
        particle.RotSpeed = NumberRange.new(-180, 180)
        particle.Texture = "rbxassetid://296874871"
        particle.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, P.AccentHi),
        }

        local state = false

        local function toggleSwitch()
            state = not state
            local goalPos = state and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
            local bgColor = state and P.Accent or Color3.fromRGB(50, 50, 55)
            local circleColor = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(210, 210, 215)
            local textColor = state and P.Success or Color3.fromRGB(255, 85, 85)

            tw(circle, 0.3, { Position = goalPos, BackgroundColor3 = circleColor }, Enum.EasingStyle.Back)
            tw(switch, 0.3, { BackgroundColor3 = bgColor }, Enum.EasingStyle.Back)
            tw(stateLabel, 0.25, { TextColor3 = textColor })
            tw(glow, 0.3, { Transparency = state and 0 or 1 })

            stateLabel.Text = state and "ON" or "OFF"
            particle.Enabled = true
            task.delay(0.25, function() particle.Enabled = false end)

            if switchConfig.Callback then pcall(switchConfig.Callback, state) end
        end

        switch.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                toggleSwitch()
            end
        end)

        switch.MouseEnter:Connect(function()
            tw(glow, 0.2, { Transparency = state and 0 or 0.4 })
        end)
        switch.MouseLeave:Connect(function()
            tw(glow, 0.2, { Transparency = 1 })
        end)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE LINE
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateLine(tabName, color)
        local tab = pages[tabName]
        if not tab then return end

        local line = Instance.new("Frame", tab)
        line.Size = UDim2.new(1, -20, 0, 1)
        line.Position = UDim2.new(0, 10, 0, 0)
        line.BackgroundColor3 = color or P.Border
        line.BorderSizePixel = 0
        local lg = Instance.new("UIGradient", line)
        lg.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
    end

    -- ═══════════════════════════════════════════════════════════════
    -- NOTIFY CUSTOM
    -- ═══════════════════════════════════════════════════════════════
    local notifyQueue = {}
    local notifying = false

    local function processQueue()
        if notifying or #notifyQueue == 0 then return end
        notifying = true
        local data = table.remove(notifyQueue, 1)
        local frame = data.frame

        frame:TweenPosition(UDim2.new(1, -20, 1, -20 - ((#notifyQueue) * 110)),
            Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.4, true)

        task.delay(2.2, function()
            frame:TweenPosition(UDim2.new(1, 320, 1, -200),
                Enum.EasingDirection.In, Enum.EasingStyle.Quint, 0.35, true)
            task.wait(0.4)
            data.gui:Destroy()
            notifying = false
            processQueue()
        end)
    end

    function Window:NotifyCustom(title, text, iconId)
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "NotifyCustom"
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.DisplayOrder = 100
        pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
        if not screenGui.Parent then screenGui.Parent = player:WaitForChild("PlayerGui") end

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 300, 0, 100)
        frame.Position = UDim2.new(1, 320, 1, -200)
        frame.AnchorPoint = Vector2.new(1, 1)
        frame.BackgroundColor3 = P.Bg
        frame.BackgroundTransparency = 0.05
        frame.BorderSizePixel = 0
        frame.Parent = screenGui
        addCorner(frame, UDim.new(0, 12))
        addStroke(frame, P.AccentHi, 1.5, 0.2)

        local gradient = Instance.new("UIGradient", frame)
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 100)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0)),
        })
        gradient.Rotation = 45
        gradient.Transparency = NumberSequence.new(0.95)

        local progress = Instance.new("Frame", frame)
        progress.Size = UDim2.new(1, 0, 0, 3)
        progress.Position = UDim2.new(0, 0, 1, -3)
        progress.BackgroundColor3 = P.AccentHi
        progress.BorderSizePixel = 0
        addCorner(progress, UDim.new(1, 0))
        tw(progress, 2.2, { Size = UDim2.new(0, 0, 0, 3) }, Enum.EasingStyle.Linear)

        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 48, 0, 48)
        icon.Position = UDim2.new(0, 14, 0, 26)
        icon.Image = "rbxassetid://" .. tostring(iconId)
        icon.BackgroundTransparency = 1
        icon.Parent = frame

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -80, 0, 26)
        titleLabel.Position = UDim2.new(0, 72, 0, 16)
        titleLabel.Text = title
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 15
        titleLabel.TextColor3 = P.Text
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.BackgroundTransparency = 1
        titleLabel.Parent = frame

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, -80, 0, 36)
        textLabel.Position = UDim2.new(0, 72, 0, 42)
        textLabel.Text = text
        textLabel.Font = Enum.Font.Gotham
        textLabel.TextSize = 12
        textLabel.TextColor3 = P.TextMute
        textLabel.TextWrapped = true
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextYAlignment = Enum.TextYAlignment.Top
        textLabel.BackgroundTransparency = 1
        textLabel.Parent = frame

        table.insert(notifyQueue, { frame = frame, gui = screenGui })
        processQueue()
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE PROMO BOX
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreatePromoBox(tabName, title, description, imageId, link, channelName)
        local tab = pages[tabName]
        if not tab then return end

        local box = Instance.new("Frame", tab)
        box.Size = UDim2.new(1, -20, 0, 0)
        box.Position = UDim2.new(0, 10, 0, 0)
        box.BackgroundColor3 = P.Surface
        box.BorderSizePixel = 0
        box.AutomaticSize = Enum.AutomaticSize.Y
        box.ClipsDescendants = true
        addCorner(box, UDim.new(0, 12))
        addStroke(box, Color3.fromRGB(80, 10, 10), 1.5, 0.3)

        local icon = Instance.new("ImageLabel", box)
        icon.Size = UDim2.new(0, 90, 0, 90)
        icon.Position = UDim2.new(0, 10, 0, 10)
        icon.Image = "rbxassetid://" .. tostring(imageId)
        icon.BackgroundColor3 = P.SurfaceHi
        icon.BorderSizePixel = 0
        icon.ScaleType = Enum.ScaleType.Fit
        addCorner(icon, UDim.new(0, 8))
        addStroke(icon, P.Border, 1, 0.5)

        local channelBox = Instance.new("TextBox", box)
        channelBox.Text = channelName or "SEU CANAL AQUI"
        channelBox.Size = UDim2.new(0, 90, 0, 0)
        channelBox.Position = UDim2.new(0, 10, 0, 105)
        channelBox.Font = Enum.Font.GothamBold
        channelBox.TextSize = 12
        channelBox.TextColor3 = P.Text
        channelBox.BackgroundColor3 = P.SurfaceHi
        channelBox.BorderSizePixel = 0
        channelBox.ClearTextOnFocus = false
        channelBox.AutomaticSize = Enum.AutomaticSize.Y
        channelBox.TextWrapped = true
        channelBox.TextXAlignment = Enum.TextXAlignment.Center
        channelBox.TextYAlignment = Enum.TextYAlignment.Center
        channelBox.ClipsDescendants = true
        channelBox.TextEditable = false
        addCorner(channelBox, UDim.new(0, 6))
        addStroke(channelBox, P.Accent, 1.2, 0.2)

        local content = Instance.new("Frame", box)
        content.BackgroundTransparency = 1
        content.Position = UDim2.new(0, 110, 0, 10)
        content.Size = UDim2.new(1, -120, 0, 0)
        content.AutomaticSize = Enum.AutomaticSize.Y

        local layout = Instance.new("UIListLayout", content)
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 6)

        local titleLabel = Instance.new("TextLabel", content)
        titleLabel.Text = "  " .. string.upper(title or "")
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 16
        titleLabel.TextColor3 = P.Text
        titleLabel.BackgroundTransparency = 1
        titleLabel.Size = UDim2.new(1, 0, 0, 30)
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.TextYAlignment = Enum.TextYAlignment.Center

        local underline = Instance.new("Frame", titleLabel)
        underline.Size = UDim2.new(1, -20, 0, 1)
        underline.Position = UDim2.new(0, 10, 1, -3)
        underline.BackgroundColor3 = Color3.fromRGB(90, 0, 0)
        underline.BorderSizePixel = 0

        local buttonHolder = Instance.new("Frame", content)
        buttonHolder.Size = UDim2.new(1, 0, 0, 32)
        buttonHolder.BackgroundColor3 = Color3.fromRGB(70, 10, 10)
        buttonHolder.BorderSizePixel = 0
        buttonHolder.ClipsDescendants = true
        addCorner(buttonHolder, UDim.new(0, 6))
        addStroke(buttonHolder, P.Accent, 1.2, 0.2)

        local copyButton = Instance.new("TextButton", buttonHolder)
        copyButton.Text = "COPIAR LINK"
        copyButton.Font = Enum.Font.GothamBold
        copyButton.TextSize = 13
        copyButton.TextColor3 = P.Text
        copyButton.BackgroundTransparency = 1
        copyButton.Size = UDim2.new(1, 0, 1, 0)
        copyButton.ZIndex = 2

        local fillBar = Instance.new("Frame", buttonHolder)
        fillBar.Size = UDim2.new(0, 0, 1, 0)
        fillBar.BackgroundColor3 = P.AccentHi
        fillBar.BorderSizePixel = 0
        fillBar.ZIndex = 1

        local descLabel = Instance.new("TextLabel", content)
        descLabel.Text = description
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextSize = 13
        descLabel.TextColor3 = P.TextMute
        descLabel.BackgroundTransparency = 1
        descLabel.Size = UDim2.new(1, 0, 0, 0)
        descLabel.AutomaticSize = Enum.AutomaticSize.Y
        descLabel.TextWrapped = true
        descLabel.TextXAlignment = Enum.TextXAlignment.Left

        copyButton.MouseButton1Click:Connect(function()
            pcall(setclipboard, link)
            fillBar.Size = UDim2.new(0, 0, 1, 0)
            fillBar:TweenSize(UDim2.new(1, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.5, true)
        end)

        return {
            MainFrame = box,
            ChannelBox = channelBox,
            DescriptionLabel = descLabel,
            CopyButton = copyButton,
        }
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE THEME BOXES
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateThemeBoxes(tabName, mainFrameArg)
        local tab = pages[tabName]
        if not tab then return end

        local container = Instance.new("Frame", tab)
        container.Size = UDim2.new(1, -20, 0, 0)
        container.Position = UDim2.new(0, 10, 0, 0)
        container.BackgroundTransparency = 1
        container.AutomaticSize = Enum.AutomaticSize.Y

        local layout = Instance.new("UIListLayout", container)
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 10)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local colors = {
            {Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 0, 0)},
            {Color3.fromRGB(0, 0, 255), Color3.fromRGB(128, 0, 255)},
            {Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 255, 255)},
            {Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 255, 0)},
            {Color3.fromRGB(212, 175, 55), Color3.fromRGB(192, 192, 192)},
            {Color3.fromRGB(128, 0, 255), Color3.fromRGB(255, 128, 0)},
            {Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 0, 0)},
            {Color3.fromRGB(255, 105, 180), Color3.fromRGB(255, 215, 0)},
            {Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0)},
            {Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 255)},
            {Color3.fromRGB(0, 255, 128), Color3.fromRGB(0, 64, 64)},
            {Color3.fromRGB(255, 0, 255), Color3.fromRGB(128, 0, 128)},
            {Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 128, 255)},
            {Color3.fromRGB(255, 69, 0), Color3.fromRGB(255, 140, 0)},
            {Color3.fromRGB(255, 20, 147), Color3.fromRGB(148, 0, 211)},
            {Color3.fromRGB(173, 216, 230), Color3.fromRGB(25, 25, 112)},
            {Color3.fromRGB(144, 238, 144), Color3.fromRGB(0, 100, 0)},
            {Color3.fromRGB(255, 248, 220), Color3.fromRGB(139, 69, 19)},
            {Color3.fromRGB(255, 255, 224), Color3.fromRGB(0, 0, 128)},
            {Color3.fromRGB(255, 255, 255), Color3.fromRGB(140, 140, 140)},
            {Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0)},
        }

        local inicial = colors[#colors]
        AtualizarCorInterface(inicial[1], inicial[1], inicial[2])

        local function createColorBox(titleText, labelText, mode)
            local box = Instance.new("Frame")
            box.Size = UDim2.new(0.5, -15, 0, 0)
            box.BackgroundColor3 = P.Surface
            box.BorderSizePixel = 0
            box.AutomaticSize = Enum.AutomaticSize.Y
            box.ClipsDescendants = true
            box.Parent = container

            addCorner(box, UDim.new(0, 12))
            addStroke(box, Color3.fromRGB(80, 10, 10), 1.5, 0.3)

            local titleLabel = Instance.new("TextLabel", box)
            titleLabel.Text = titleText
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextSize = 15
            titleLabel.TextColor3 = P.Text
            titleLabel.BackgroundTransparency = 1
            titleLabel.Size = UDim2.new(1, -20, 0, 26)
            titleLabel.Position = UDim2.new(0, 10, 0, 10)
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left

            local label = Instance.new("TextLabel", box)
            label.Text = labelText
            label.Font = Enum.Font.Gotham
            label.TextSize = 12
            label.TextColor3 = P.TextMute
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, -20, 0, 18)
            label.Position = UDim2.new(0, 10, 0, 38)
            label.TextXAlignment = Enum.TextXAlignment.Left

            local content = Instance.new("Frame", box)
            content.BackgroundTransparency = 1
            content.Position = UDim2.new(0, 10, 0, 66)
            content.Size = UDim2.new(1, -20, 0, 0)
            content.AutomaticSize = Enum.AutomaticSize.Y

            local grid = Instance.new("UIGridLayout", content)
            grid.CellSize = UDim2.new(0, 36, 0, 36)
            grid.CellPadding = UDim2.new(0, 8, 0, 8)
            grid.FillDirectionMaxCells = 3
            grid.FillDirection = Enum.FillDirection.Horizontal
            grid.SortOrder = Enum.SortOrder.LayoutOrder

            for _, pair in ipairs(colors) do
                local square = Instance.new("Frame", content)
                square.BackgroundColor3 = pair[1]
                square.BorderSizePixel = 0
                square.Size = UDim2.new(0, 36, 0, 36)
                addCorner(square, UDim.new(0, 6))

                local s = addStroke(square, Color3.fromRGB(60, 0, 0), 1.2, 0.4)

                local g = Instance.new("UIGradient", square)
                g.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, pair[1]),
                    ColorSequenceKeypoint.new(1, pair[2]),
                }

                local button = Instance.new("TextButton", square)
                button.BackgroundTransparency = 1
                button.Size = UDim2.new(1, 0, 1, 0)
                button.Text = ""
                button.AutoButtonColor = false

                button.MouseEnter:Connect(function()
                    tw(square, 0.2, { Size = UDim2.new(0, 40, 0, 40) }, Enum.EasingStyle.Back)
                    tw(s, 0.2, { Color = P.AccentHi, Transparency = 0 })
                end)
                button.MouseLeave:Connect(function()
                    tw(square, 0.2, { Size = UDim2.new(0, 36, 0, 36) }, Enum.EasingStyle.Back)
                    tw(s, 0.2, { Color = Color3.fromRGB(60, 0, 0), Transparency = 0.4 })
                end)

                button.MouseButton1Click:Connect(function()
                    if mode == "interface" then
                        AtualizarCorInterface(pair[1], pair[1], pair[2])
                    elseif mode == "titulo" then
                        title.TextColor3 = pair[1]
                        subtitle.TextColor3 = pair[2]
                    end
                end)
            end

            local colorInputBox = Instance.new("TextBox", box)
            colorInputBox.Text = ""
            colorInputBox.Size = UDim2.new(1, -20, 0, 30)
            colorInputBox.BackgroundColor3 = P.SurfaceHi
            colorInputBox.TextColor3 = P.Text
            colorInputBox.TextSize = 12
            colorInputBox.PlaceholderText = "(ex: 255.0.0/0.0.0)"
            colorInputBox.PlaceholderColor3 = P.TextMute
            colorInputBox.ClearTextOnFocus = false
            colorInputBox.Position = UDim2.new(0, 10, 0, 0)
            colorInputBox.LayoutOrder = 999
            addCorner(colorInputBox, UDim.new(0, 6))
            addStroke(colorInputBox, P.Border, 1, 0.5)

            local layoutForInput = Instance.new("UIListLayout", box)
            layoutForInput.SortOrder = Enum.SortOrder.LayoutOrder
            layoutForInput.Padding = UDim.new(0, 10)

            colorInputBox.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    local colorText = colorInputBox.Text
                    local colorsInput = string.split(colorText, "/")
                    if #colorsInput == 2 then
                        local color1 = string.split(colorsInput[1], ".")
                        local color2 = string.split(colorsInput[2], ".")
                        if #color1 == 3 and #color2 == 3 then
                            local r1, g1, b1 = tonumber(color1[1]), tonumber(color1[2]), tonumber(color1[3])
                            local r2, g2, b2 = tonumber(color2[1]), tonumber(color2[2]), tonumber(color2[3])
                            if r1 and g1 and b1 and r2 and g2 and b2 then
                                local newColor1 = Color3.fromRGB(r1, g1, b1)
                                local newColor2 = Color3.fromRGB(r2, g2, b2)
                                if mode == "interface" then
                                    AtualizarCorInterface(newColor1, newColor1, newColor2)
                                elseif mode == "titulo" then
                                    title.TextColor3 = newColor1
                                    subtitle.TextColor3 = newColor2
                                end
                            end
                        end
                    end
                end
            end)

            return box
        end

        createColorBox("COR DA INTERFACE", "Quadrados principais", "interface")
        createColorBox("COR DO TÍTULO", "Título e versão", "titulo")

        return container
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE INFO BOX
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateInfoBox(tabName, title, infoList)
        local tab = pages[tabName]
        if not tab then return end

        local box = Instance.new("Frame", tab)
        box.Size = UDim2.new(1, -20, 0, 0)
        box.Position = UDim2.new(0, 10, 0, 0)
        box.BackgroundColor3 = P.Surface
        box.BorderSizePixel = 0
        box.AutomaticSize = Enum.AutomaticSize.Y
        box.ClipsDescendants = true
        addCorner(box, UDim.new(0, 12))
        addStroke(box, Color3.fromRGB(120, 0, 0), 1.5, 0.3)

        local titleLabel = Instance.new("TextLabel", box)
        titleLabel.Text = "  " .. string.upper(title or "INFORMAÇÃO")
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 16
        titleLabel.TextColor3 = P.Text
        titleLabel.BackgroundTransparency = 1
        titleLabel.Size = UDim2.new(1, -20, 0, 30)
        titleLabel.Position = UDim2.new(0, 10, 0, 10)
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.TextYAlignment = Enum.TextYAlignment.Center

        local underline = Instance.new("Frame", titleLabel)
        underline.Size = UDim2.new(1, -20, 0, 1)
        underline.Position = UDim2.new(0, 10, 1, -3)
        underline.BackgroundColor3 = Color3.fromRGB(90, 0, 0)
        underline.BorderSizePixel = 0

        local content = Instance.new("Frame", box)
        content.BackgroundTransparency = 1
        content.Position = UDim2.new(0, 10, 0, 50)
        content.Size = UDim2.new(1, -20, 0, 0)
        content.AutomaticSize = Enum.AutomaticSize.Y

        local layout = Instance.new("UIListLayout", content)
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 6)

        for i, text in ipairs(infoList or {}) do
            local itemFrame = Instance.new("Frame", content)
            itemFrame.BackgroundColor3 = P.SurfaceHi
            itemFrame.BorderSizePixel = 0
            itemFrame.AutomaticSize = Enum.AutomaticSize.Y
            itemFrame.Size = UDim2.new(1, 0, 0, 0)
            itemFrame.ClipsDescendants = true
            addCorner(itemFrame, UDim.new(0, 6))
            addStroke(itemFrame, Color3.fromRGB(100, 0, 0), 1, 0.5)

            local numberLabel = Instance.new("TextLabel", itemFrame)
            numberLabel.Text = tostring(i) .. "."
            numberLabel.Font = Enum.Font.GothamBold
            numberLabel.TextSize = 13
            numberLabel.TextColor3 = P.AccentHi
            numberLabel.BackgroundTransparency = 1
            numberLabel.Size = UDim2.new(0, 30, 1, 0)
            numberLabel.Position = UDim2.new(0, 10, 0, 0)
            numberLabel.TextXAlignment = Enum.TextXAlignment.Left
            numberLabel.TextYAlignment = Enum.TextYAlignment.Top

            local descLabel = Instance.new("TextLabel", itemFrame)
            descLabel.Text = text
            descLabel.Font = Enum.Font.Gotham
            descLabel.TextSize = 13
            descLabel.TextColor3 = P.Text
            descLabel.BackgroundTransparency = 1
            descLabel.Position = UDim2.new(0, 40, 0, 5)
            descLabel.Size = UDim2.new(1, -50, 0, 0)
            descLabel.AutomaticSize = Enum.AutomaticSize.Y
            descLabel.TextWrapped = true
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.TextYAlignment = Enum.TextYAlignment.Top
        end

        return {
            MainFrame = box,
            TitleLabel = titleLabel,
            ContentFrame = content,
        }
    end

    -- ═══════════════════════════════════════════════════════════════
    -- HIDE / SHOW (agora restaura o tamanho atual!)
    -- ═══════════════════════════════════════════════════════════════
    local isHidden = false

    local function doHide()
        if isHidden then return end
        isHidden = true

        -- guarda o tamanho atual ANTES de esconder
        local finalSize = mainFrame.AbsoluteSize
        currentSize = Vector2.new(finalSize.X, finalSize.Y)

        tw(mainFrame, 0.25, {
            Size = UDim2.new(0, currentSize.X, 0, 10),
            BackgroundTransparency = 0.4,
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
                BackgroundTransparency = 0,
            }, Enum.EasingStyle.Back)
            tw(shadowImg, 0.4, { ImageTransparency = 0.55 })
        end)
    end

    hideButton.MouseButton1Click:Connect(doHide)
    ballButton.MouseButton1Click:Connect(doShow)

    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            if isHidden then doShow() else doHide() end
        end
    end)

    return Window
end

return RANOX
