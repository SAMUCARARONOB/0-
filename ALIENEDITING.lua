--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║  RANOX UI · v5.0.0 · PROFESSIONAL EDITION                        ║
    ║  ✦ Smart Theme Engine · Professional ColorPicker · ThemeBoxes ✦  ║
    ║  ✦ Enhanced Button · Smart Toggle · Keybind · ProgressBar ✦      ║
    ╚══════════════════════════════════════════════════════════════════╝
]]

local TweenService = game:GetService("TweenService")
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local player       = Players.LocalPlayer

local RANOX = {}

-- ═══════════════════════════════════════════════════════════════════
-- COLOR MATH HELPERS
-- ═══════════════════════════════════════════════════════════════════
local function clamp01(v) return math.clamp(v, 0, 1) end

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

local function luminance(c)
    return 0.2126 * c.R + 0.7152 * c.G + 0.0722 * c.B
end

local function contrastText(bg)
    return luminance(bg) > 0.55 and Color3.fromRGB(20, 20, 25) or Color3.fromRGB(245, 245, 250)
end

local function mix(a, b, t)
    return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t)
end

-- ═══════════════════════════════════════════════════════════════════
-- THEME ENGINE — palette que reage a qualquer cor escolhida
-- ═══════════════════════════════════════════════════════════════════
local Base = {
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

local P = {} -- paleta viva (mutável)
for k, v in pairs(Base) do P[k] = v end

local function applySmartTheme(accent)
    local h, s, v = Color3.toHSV(accent)
    if s < 0.35 then s = 0.35 end
    if v < 0.40 then v = 0.40 end
    local cleanAccent = Color3.fromHSV(h, s, v)

    P.Accent       = cleanAccent
    P.AccentHi     = Color3.fromHSV(h, math.min(1, s * 1.15), math.min(1, v * 1.35))
    P.AccentSoft   = Color3.fromHSV(h, s, math.max(0.18, v * 0.45))
    P.AccentDeep   = Color3.fromHSV(h, s, math.max(0.10, v * 0.22))
    P.Glow         = Color3.fromHSV(h, math.max(0.55, s * 0.75), 1)
    P.TextOnAccent = contrastText(cleanAccent)
    P.BorderTint   = mix(Base.Border, cleanAccent, 0.35)
    P.SurfaceTint  = mix(Base.Surface, cleanAccent, 0.08)
end

applySmartTheme(Color3.fromRGB(170, 20, 20))

-- ═══════════════════════════════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════════════════════════════
local function tw(inst, dur, props, style, dir)
    local t = TweenService:Create(
        inst, TweenInfo.new(dur or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
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

    local DEFAULT_SIZE = Vector2.new(575, 375)
    local MIN_SIZE     = Vector2.new(400, 300)
    local MAX_SIZE     = Vector2.new(1200, 900)
    local currentSize  = DEFAULT_SIZE

    -- Registro de callbacks de tema (chamados a cada mudança de cor)
    local themeCallbacks = {}
    local function registerTheme(fn) table.insert(themeCallbacks, fn) end
    local function broadcastTheme()
        for _, fn in ipairs(themeCallbacks) do pcall(fn) end
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RANOX_UI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 99e99
    pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
    if not screenGui.Parent then screenGui.Parent = player:WaitForChild("PlayerGui") end

    -- ─── SOMBRA
    local shadowHolder = Instance.new("Frame", screenGui)
    shadowHolder.BackgroundTransparency = 1
    shadowHolder.Size = UDim2.new(0, currentSize.X + 6, 0, currentSize.Y + 6)
    shadowHolder.Position = UDim2.new(0.5, 0, 0.5, 2)
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

    -- ─── MAIN
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
    addCorner(mainFrame, UDim.new(0, 12))

    local mainStroke = addStroke(mainFrame, P.Accent, 1.5, 0.25)
    local mainGrad = Instance.new("UIGradient", mainFrame)
    mainGrad.Rotation = 135
    mainGrad.Color = ColorSequence.new(P.BgSolid, P.Bg)

    -- Grid decorativo
    local gridHolder = Instance.new("Frame", mainFrame)
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
    end
    for i = 0, 10 do
        local l = Instance.new("Frame", gridHolder)
        l.BackgroundColor3 = P.Border
        l.BackgroundTransparency = 0.9
        l.BorderSizePixel = 0
        l.Size = UDim2.new(1, 0, 0, 1)
        l.Position = UDim2.new(0, 0, 0, i * 42)
    end

    -- Orbs
    local decor = Instance.new("Frame", mainFrame)
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
    addCorner(orb1, UDim.new(1, 0))
    local orb2 = Instance.new("Frame", decor)
    orb2.Size = UDim2.new(0, 220, 0, 220)
    orb2.Position = UDim2.new(0.9, 0, 0.8, 0)
    orb2.BackgroundColor3 = P.AccentSoft
    orb2.BackgroundTransparency = 0.9
    orb2.BorderSizePixel = 0
    addCorner(orb2, UDim.new(1, 0))

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

    -- Bind global ao tema
    registerTheme(function()
        tw(mainStroke, 0.5, { Color = P.Accent })
        tw(topGlow, 0.5, { BackgroundColor3 = P.AccentHi })
        tw(orb1, 0.6, { BackgroundColor3 = P.Accent })
        tw(orb2, 0.6, { BackgroundColor3 = P.AccentSoft })
        for _, c in ipairs(gridHolder:GetChildren()) do
            if c:IsA("Frame") then tw(c, 0.5, { BackgroundColor3 = P.BorderTint }) end
        end
    end)

    -- Título
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

    -- Botão minimizar
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
        tw(hideButton, 0.2, { BackgroundColor3 = P.AccentSoft })
        tw(hideStroke, 0.2, { Color = P.Accent })
    end)
    hideButton.MouseLeave:Connect(function()
        tw(hideButton, 0.2, { BackgroundColor3 = P.Surface, BackgroundTransparency = 0.4 })
        tw(hideStroke, 0.2, { Color = P.Border, Transparency = 0.4 })
    end)

    local line = Instance.new("Frame", mainFrame)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0, 26)
    line.BackgroundColor3 = P.Accent
    line.BackgroundTransparency = 0.3
    line.BorderSizePixel = 0
    line.ZIndex = 4
    registerTheme(function() tw(line, 0.5, { BackgroundColor3 = P.Accent }) end)

    -- Sidebar
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
    registerTheme(function() tw(sidebar, 0.5, { ScrollBarImageColor3 = P.Accent }) end)

    -- Search
    local searchBox = Instance.new("TextBox", sidebar)
    searchBox.Size = UDim2.new(1, 0, 0, 26)
    searchBox.BackgroundColor3 = P.Surface
    searchBox.BorderSizePixel = 0
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

    local tabButtons, pages, selectedTab = {}, {}, nil

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = string.lower(searchBox.Text)
        for name, btn in pairs(tabButtons) do
            btn.Visible = (q == "") or (string.find(string.lower(name), q, 1, true) ~= nil)
        end
    end)

    local scrollHolder = Instance.new("ScrollingFrame", mainFrame)
    scrollHolder.Position = UDim2.new(0.25, 4, 0, 31)
    scrollHolder.Size = UDim2.new(0.75, -8, 1, -36)
    scrollHolder.BackgroundTransparency = 1
    scrollHolder.BorderSizePixel = 0
    scrollHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollHolder.ScrollBarThickness = 4
    scrollHolder.ScrollBarImageColor3 = P.Accent
    scrollHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    registerTheme(function() tw(scrollHolder, 0.5, { ScrollBarImageColor3 = P.Accent }) end)

    -- Ball (para restaurar)
    local ballButton = Instance.new("ImageButton")
    ballButton.Size = UDim2.new(0, 50, 0, 50)
    ballButton.Position = UDim2.new(0.1, 0, 0.9, -150)
    ballButton.AnchorPoint = Vector2.new(0.5, 0.5)
    ballButton.BackgroundColor3 = P.Accent
    ballButton.Image = "rbxassetid://6337069410"
    ballButton.Visible = false
    ballButton.Draggable = true
    ballButton.Parent = screenGui
    addCorner(ballButton, UDim.new(0.5, 0))
    local ballStroke = addStroke(ballButton, P.AccentHi, 2, 0.2)
    registerTheme(function()
        tw(ballButton, 0.5, { BackgroundColor3 = P.Accent })
        tw(ballStroke, 0.5, { Color = P.AccentHi })
    end)
    task.spawn(function()
        while ballButton.Parent do
            tw(ballStroke, 1.2, { Transparency = 0.8 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
            tw(ballStroke, 1.2, { Transparency = 0.2 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
        end
    end)

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
    addCorner(resizeHandle, UDim.new(0, 5))
    local resizeStroke = addStroke(resizeHandle, P.Border, 1.2, 0.35)

    local hoveredResize = false
    resizeHandle.MouseEnter:Connect(function()
        hoveredResize = true
        tw(resizeHandle, 0.18, { BackgroundColor3 = P.AccentSoft, BackgroundTransparency = 0.1, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -28, 1, -28) }, Enum.EasingStyle.Back)
        tw(resizeStroke, 0.18, { Color = P.AccentHi, Transparency = 0 })
    end)
    resizeHandle.MouseLeave:Connect(function()
        hoveredResize = false
        tw(resizeHandle, 0.2, { BackgroundColor3 = P.Surface, BackgroundTransparency = 0.35, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -24, 1, -24) }, Enum.EasingStyle.Back)
        tw(resizeStroke, 0.2, { Color = P.Border, Transparency = 0.35 })
    end)
    task.spawn(function()
        while resizeHandle.Parent do
            if not hoveredResize then
                tw(resizeStroke, 1.6, { Transparency = 0.85 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(1.6)
                tw(resizeStroke, 1.6, { Transparency = 0.35 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(1.6)
            else
                task.wait(0.4)
            end
        end
    end)

    do
        local dragging, startSize, startPos
        resizeHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; startSize = mainFrame.AbsoluteSize; startPos = input.Position
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - startPos
                local w = math.clamp(startSize.X + delta.X, MIN_SIZE.X, MAX_SIZE.X)
                local h = math.clamp(startSize.Y + delta.Y, MIN_SIZE.Y, MAX_SIZE.Y)
                mainFrame.Size = UDim2.new(0, w, 0, h)
                currentSize = Vector2.new(w, h)
            end
        end)
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if dragging then
                    dragging = false
                    local fs = mainFrame.AbsoluteSize
                    currentSize = Vector2.new(fs.X, fs.Y)
                end
            end
        end)
    end

    -- Sync sombra
    RunService.RenderStepped:Connect(function()
        if not mainFrame or not mainFrame.Parent then return end
        shadowHolder.Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset + 2)
        shadowHolder.Size = UDim2.new(0, mainFrame.AbsoluteSize.X + 6, 0, mainFrame.AbsoluteSize.Y + 6)
    end)

    -- Entrada
    task.spawn(function()
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        mainFrame.BackgroundTransparency = 1
        shadowImg.ImageTransparency = 1
        task.wait(0.05)
        mainFrame.Size = UDim2.new(0, currentSize.X - 35, 0, currentSize.Y - 20)
        tw(mainFrame, 0.55, { Size = UDim2.new(0, currentSize.X, 0, currentSize.Y) }, Enum.EasingStyle.Back)
        tw(mainFrame, 0.4, { BackgroundTransparency = 0 })
        tw(shadowImg, 0.5, { ImageTransparency = 0.55 })
        sidebar.Position = UDim2.new(0, -50, 0, 26)
        task.wait(0.15)
        tw(sidebar, 0.45, { Position = UDim2.new(0, 0, 0, 26) })
        title.Position = UDim2.new(0, -60, 0, 0)
        tw(title, 0.4, { Position = UDim2.new(0, 12, 0, 0) })
    end)

    local function switchTab(name)
        for tn, f in pairs(pages) do
            local active = (tn == name)
            f.Visible = active
            if active then
                f.Position = UDim2.new(0, 20, 0, 0)
                tw(f, 0.28, { Position = UDim2.new(0, 0, 0, 0) })
            end
        end
        for tn, btn in pairs(tabButtons) do
            local m = btn:FindFirstChild("TabMarker")
            if m then m.Visible = (tn == name) end
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
        tabBtn.BackgroundColor3 = P.Surface
        tabBtn.AutoButtonColor = false
        tabBtn.ClipsDescendants = true
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
        addPadding(tabPage, 4, 4, 8, 4)
        pages[tabName] = tabPage

        tabBtn.MouseButton1Click:Connect(function()
            for name, button in pairs(tabButtons) do
                if name == tabName then
                    tw(button, 0.15, { BackgroundColor3 = P.SurfaceHi })
                    tw(button, 0.12, { Size = UDim2.new(1, 0, 0, 36) })
                    task.delay(0.12, function() tw(button, 0.15, { Size = UDim2.new(1, 0, 0, 32) }, Enum.EasingStyle.Back) end)
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
    -- ENHANCED BUTTON
    -- ═══════════════════════════════════════════════════════════════
    local function makeRipple(parent, x, y)
        local r = Instance.new("Frame", parent)
        r.AnchorPoint = Vector2.new(0.5, 0.5)
        r.Position = UDim2.new(0, x or parent.AbsoluteSize.X/2, 0, y or parent.AbsoluteSize.Y/2)
        r.Size = UDim2.new(0, 0, 0, 0)
        r.BackgroundColor3 = Color3.new(1, 1, 1)
        r.BackgroundTransparency = 0.6
        r.BorderSizePixel = 0
        r.ZIndex = 2
        addCorner(r, UDim.new(1, 0))
        local t = tw(r, 0.6, { Size = UDim2.new(0, parent.AbsoluteSize.X * 2.5, 0, parent.AbsoluteSize.X * 2.5), BackgroundTransparency = 1 }, Enum.EasingStyle.Quart)
        t.Completed:Connect(function() r:Destroy() end)
    end

    function Window:CreateButton(tabName, text, callback, options)
        options = options or {}
        local tab = pages[tabName]; if not tab then return end

        local btn = Instance.new("TextButton", tab)
        btn.Size = UDim2.new(1, -20, 0, 32)
        btn.Position = UDim2.new(0, 10, 0, 0)
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.ClipsDescendants = true
        addCorner(btn, UDim.new(0, 7))
        btn.BackgroundColor3 = P.SurfaceHi

        -- gradiente de fundo
        local bgGrad = Instance.new("UIGradient", btn)
        bgGrad.Rotation = 90
        bgGrad.Color = ColorSequence.new(P.SurfaceHi, mix(P.SurfaceHi, P.Accent, 0.08))
        bgGrad.Transparency = NumberSequence.new(0)

        local btnStroke = addStroke(btn, P.Border, 1, 0.5)

        -- barra lateral
        local accentBar = Instance.new("Frame", btn)
        accentBar.Size = UDim2.new(0, 3, 1, 0)
        accentBar.BackgroundColor3 = P.Accent
        accentBar.BorderSizePixel = 0

        -- brilho interno à esquerda
        local innerGlow = Instance.new("Frame", btn)
        innerGlow.Size = UDim2.new(0, 8, 1, 0)
        innerGlow.BackgroundColor3 = P.Accent
        innerGlow.BackgroundTransparency = 0.75
        innerGlow.BorderSizePixel = 0
        innerGlow.ZIndex = 0

        -- ícone opcional
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

        -- Shine sweep
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
            -- shine sweep
            shine.Position = UDim2.new(-0.3, 0, 0, 0)
            tw(shine, 0.7, { Position = UDim2.new(1.2, 0, 0, 0) }, Enum.EasingStyle.Quart)
        end)

        btn.MouseLeave:Connect(function()
            tw(btn, 0.2, { BackgroundColor3 = P.SurfaceHi })
            tw(btnStroke, 0.2, { Color = P.Border, Transparency = 0.5 })
            tw(accentBar, 0.2, { Size = UDim2.new(0, 3, 1, 0) })
        end)

        btn.MouseButton1Down:Connect(function()
            local mx = UIS:GetMouseLocation().X - btn.AbsolutePosition.X
            local my = UIS:GetMouseLocation().Y - btn.AbsolutePosition.Y
            makeRipple(btn, mx, my)
        end)

        btn.MouseButton1Click:Connect(function()
            if cooling then return end
            cooling = true
            -- success flash
            local flash = Instance.new("Frame", btn)
            flash.Size = UDim2.new(1, 0, 1, 0)
            flash.BackgroundColor3 = P.Success
            flash.BackgroundTransparency = 0.7
            flash.BorderSizePixel = 0
            flash.ZIndex = 1
            addCorner(flash, UDim.new(0, 7))
            tw(flash, 0.5, { BackgroundTransparency = 1 })
            task.delay(0.5, function() flash:Destroy() end)

            tw(btn, 0.08, { Size = UDim2.new(1, -22, 0, 30) })
            task.delay(0.08, function() tw(btn, 0.15, { Size = UDim2.new(1, -20, 0, 32) }, Enum.EasingStyle.Back) end)

            if callback then pcall(callback) end

            task.delay(cooldown, function() cooling = false end)
        end)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CHECKBOX
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateCheckbox(tabName, cfg)
        local tab = pages[tabName]; if not tab then return end
        cfg = cfg or {}

        local f = Instance.new("Frame", tab)
        f.Size = UDim2.new(1, -20, 0, 46)
        f.BackgroundColor3 = P.Surface
        f.BorderSizePixel = 0
        f.ClipsDescendants = true
        addCorner(f, UDim.new(0, 8))
        local cfStroke = addStroke(f, P.Border, 1, 0.6)

        local title = Instance.new("TextLabel", f)
        title.Text = cfg.Text or "Checkbox"
        title.TextColor3 = P.Text
        title.Font = Enum.Font.GothamMedium
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextYAlignment = Enum.TextYAlignment.Top
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1, -50, 0, 16)
        title.Position = UDim2.new(0, 12, 0, 5)

        local desc = Instance.new("TextLabel", f)
        desc.Text = cfg.Description or ""
        desc.TextColor3 = P.TextMute
        desc.Font = Enum.Font.Gotham
        desc.TextSize = 11
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.TextYAlignment = Enum.TextYAlignment.Top
        desc.BackgroundTransparency = 1
        desc.Size = UDim2.new(1, -50, 0, 14)
        desc.Position = UDim2.new(0, 12, 0, 24)

        local box = Instance.new("Frame", f)
        box.Size = UDim2.new(0, 24, 0, 24)
        box.Position = UDim2.new(1, -38, 0.5, -12)
        box.BackgroundColor3 = P.SurfaceLow
        box.BorderSizePixel = 0
        addCorner(box, UDim.new(0, 6))
        local boxStroke = addStroke(box, P.Border, 1.3, 0.3)

        local chk = Instance.new("TextLabel", box)
        chk.Size = UDim2.new(1, -4, 1, -4)
        chk.Position = UDim2.new(0, 2, 0, 2)
        chk.Text = "✔"
        chk.TextColor3 = Color3.new(1, 1, 1)
        chk.TextScaled = true
        chk.BackgroundTransparency = 1
        chk.Visible = false

        local button = Instance.new("TextButton", f)
        button.Size = UDim2.new(1, 0, 1, 0)
        button.BackgroundTransparency = 1
        button.Text = ""

        local toggled, running = false, false
        registerTheme(function()
            if toggled then
                tw(box, 0.4, { BackgroundColor3 = P.Accent })
                tw(boxStroke, 0.4, { Color = P.AccentHi, Transparency = 0 })
            end
        end)

        button.MouseEnter:Connect(function()
            tw(boxStroke, 0.2, { Color = P.AccentHi, Transparency = 0.1 })
            tw(f, 0.2, { BackgroundColor3 = P.SurfaceHi })
        end)
        button.MouseLeave:Connect(function()
            if not toggled then tw(boxStroke, 0.2, { Color = P.Border, Transparency = 0.3 }) end
            tw(f, 0.2, { BackgroundColor3 = P.Surface })
        end)

        button.MouseButton1Click:Connect(function()
            toggled = not toggled
            chk.Visible = toggled
            chk.Size = UDim2.new(0, 0, 0, 0)
            tw(chk, 0.2, { Size = UDim2.new(1, -4, 1, -4) }, Enum.EasingStyle.Back)

            local grow = tw(box, 0.15, { Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -40, 0.5, -14) })
            grow.Completed:Connect(function()
                tw(box, 0.15, { Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -38, 0.5, -12) }, Enum.EasingStyle.Back)
            end)

            if toggled then
                tw(box, 0.2, { BackgroundColor3 = P.Accent })
                tw(boxStroke, 0.2, { Color = P.AccentHi, Transparency = 0 })
                running = true
                task.spawn(function()
                    while running and toggled do
                        pcall(cfg.Callback)
                        task.wait()
                    end
                end)
            else
                tw(box, 0.2, { BackgroundColor3 = P.SurfaceLow })
                tw(boxStroke, 0.2, { Color = P.Border, Transparency = 0.3 })
                running = false
            end
            if cfg.Callback then pcall(cfg.Callback, toggled) end
        end)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- SMART TOGGLE
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateToggle(tabName, cfg)
        local tab = pages[tabName]; if not tab then return end
        cfg = cfg or {}

        local f = Instance.new("Frame", tab)
        f.Size = UDim2.new(1, -20, 0, 46)
        f.BackgroundColor3 = P.Surface
        f.ClipsDescendants = true
        f.BorderSizePixel = 0
        addCorner(f, UDim.new(0, 8))
        local fStroke = addStroke(f, P.Border, 1, 0.6)

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
        addCorner(sw, UDim.new(1, 0))

        local swStroke = addStroke(sw, P.Border, 1, 0.5)

        local ball = Instance.new("Frame", sw)
        ball.Size = UDim2.new(0, 18, 0, 18)
        ball.Position = UDim2.new(0, 3, 0.5, -9)
        ball.BackgroundColor3 = Color3.fromRGB(210, 210, 215)
        ball.BorderSizePixel = 0
        addCorner(ball, UDim.new(1, 0))
        local ballStroke = addStroke(ball, P.Border, 1, 0.4)

        -- glow orb interno (aparece quando ON)
        local glowFrame = Instance.new("Frame", sw)
        glowFrame.Size = UDim2.new(1, 0, 1, 0)
        glowFrame.BackgroundColor3 = P.Accent
        glowFrame.BackgroundTransparency = 1
        glowFrame.BorderSizePixel = 0
        addCorner(glowFrame, UDim.new(1, 0))
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

        -- Pulsar quando ON
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

        -- Função de mudança de estado (com cooldown)
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

            -- Success mini flash
            if isOn then
                local flash = Instance.new("Frame", sw)
                flash.Size = UDim2.new(1, 0, 1, 0)
                flash.BackgroundColor3 = Color3.new(1, 1, 1)
                flash.BackgroundTransparency = 0.6
                flash.BorderSizePixel = 0
                flash.ZIndex = 5
                addCorner(flash, UDim.new(1, 0))
                tw(flash, 0.4, { BackgroundTransparency = 1 })
                task.delay(0.4, function() flash:Destroy() end)
            end

            if cfg.Callback then pcall(cfg.Callback, isOn) end
            task.delay(cooldown, function() cooling = false end)
        end

        btn.MouseButton1Click:Connect(function()
            setState(not isOn)
        end)

        -- Drag-to-toggle
        do
            local dragStart, dragging
            btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragStart = input.Position.X
                    dragging = false
                end
            end)
            UIS.InputChanged:Connect(function(input)
                if dragStart and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    if math.abs(input.Position.X - dragStart) > 20 then
                        dragging = true
                        dragStart = nil
                    end
                end
            end)
            UIS.InputEnded:Connect(function(input)
                if dragStart then dragStart = nil end
                if dragging then dragging = false end
            end)
        end

        return {
            Set = function(_, v) setState(v, true) end,
            Get = function() return isOn end,
        }
    end

    -- ═══════════════════════════════════════════════════════════════
    -- LABEL
    -- ═══════════════════════════════════════════════════════════════
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
        addCorner(dot, UDim.new(1, 0))
        local dotGlow = addStroke(dot, P.AccentHi, 2, 0.3)

        registerTheme(function() tw(dot, 0.4, { BackgroundColor3 = P.AccentHi }) end)

        task.spawn(function()
            while dot.Parent do
                tw(dotGlow, 1.2, { Transparency = 0.9 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(1.2)
                tw(dotGlow, 1.2, { Transparency = 0.2 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(1.2)
            end
        end)

        local ul = Instance.new("Frame", label)
        ul.Size = UDim2.new(1, -20, 0, 1)
        ul.Position = UDim2.new(0, 10, 1, -3)
        ul.BackgroundColor3 = P.Border
        ul.BorderSizePixel = 0
        local ug = Instance.new("UIGradient", ul)
        ug.Transparency = NumberSequence.new(0, 1)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- DROPDOWN
    -- ═══════════════════════════════════════════════════════════════
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
    addCorner(f, UDim.new(0, 8))
    local fStroke = addStroke(f, P.Border, 1, 0.5)

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

    -- Lista
    local list = Instance.new("Frame", tab)
    list.Size = UDim2.new(1, -20, 0, 0)
    list.Position = UDim2.new(0, 10, 0, 0)
    list.BackgroundColor3 = P.SurfaceLow
    list.Visible = false
    list.ClipsDescendants = true
    list.ZIndex = 5
    addCorner(list, UDim.new(0, 8))
    addStroke(list, P.Border, 1, 0.4)

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
        addCorner(searchField, UDim.new(0, 5))
        addStroke(searchField, P.Border, 1, 0.5)
        addPadding(searchField, 0, 8, 8, 0)
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
    addPadding(scrollOpt, 2, 4, 4, 6)

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
        addCorner(o, UDim.new(0, 5))
        local oStroke = addStroke(o, P.Border, 1, 0.6)

        local dot = Instance.new("Frame", o)
        dot.Size = UDim2.new(0, 6, 0, 6)
        dot.Position = UDim2.new(0, 10, 0.5, -3)
        dot.BackgroundColor3 = P.Accent
        dot.BorderSizePixel = 0
        dot.Visible = (currentlySelected == opt)
        addCorner(dot, UDim.new(1, 0))

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
            if hasSearch and searchField then
                searchField.Text = ""
            end
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
    -- ═══════════════════════════════════════════════════════════════
    -- SLIDER
    -- ═══════════════════════════════════════════════════════════════
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
    addCorner(bg, UDim.new(0, 8))
    addStroke(bg, P.Border, 1, 0.5)

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
    addCorner(bar, UDim.new(1, 0))

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = P.Accent
    fill.BorderSizePixel = 0
    addCorner(fill, UDim.new(1, 0))
    local fg = Instance.new("UIGradient", fill)
    fg.Color = ColorSequence.new(P.AccentSoft, P.AccentHi)

    local fillStroke = Instance.new("UIStroke", fill)
    fillStroke.Thickness = 2
    fillStroke.Transparency = 0.4
    fillStroke.Color = P.AccentHi

    -- KNOB: usa AnchorPoint central para nunca desalinhar
    local knob = Instance.new("Frame", bar)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 4
    addCorner(knob, UDim.new(1, 0))
    local knobStroke = addStroke(knob, P.AccentHi, 2, 0.2)

    -- Glow externo no knob
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

    -- Registro completo de tema (agora o slider muda junto!)
    registerTheme(function()
        tw(fill, 0.4, { BackgroundColor3 = P.Accent })
        tw(fg, 0.4, { Color = ColorSequence.new(P.AccentSoft, P.AccentHi) })
        tw(fillStroke, 0.4, { Color = P.AccentHi })
        tw(knobStroke, 0.4, { Color = P.AccentHi })
        tw(knobGlow, 0.4, { ImageColor3 = P.AccentHi })
        tw(vl, 0.4, { TextColor3 = P.AccentHi })
    end)

    local min, max = cfg.Min or 0, cfg.Max or 100
    local function round(v, dd) local m = 10^dd; return math.floor(v*m+0.5)/m end

    -- ⚠️ CORREÇÃO CHAVE: uso direto (sem TweenService) durante o drag.
    -- Assim o knob acompanha SEMPRE, mesmo em movimentos rápidos.
    local function update(x)
        local bp = bar.AbsolutePosition.X
        local bw = bar.AbsoluteSize.X
        if bw <= 0 then return end
        local c = math.clamp((x - bp) / bw, 0, 1)
        local val = round(min + (max - min) * c, 2)
        fill.Size = UDim2.new(c, 0, 1, 0)
        knob.Position = UDim2.new(c, 0, 0.5, 0)
        vl.Text = tostring(val)
        if cfg.Callback then pcall(cfg.Callback, val) end
    end

    local drag = false

    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            tw(knob, 0.15, { Size = UDim2.new(0, 20, 0, 20) }, Enum.EasingStyle.Back)
            tw(knobGlow, 0.15, { ImageTransparency = 0.25 })
            update(i.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
            tw(knob, 0.2, { Size = UDim2.new(0, 16, 0, 16) }, Enum.EasingStyle.Back)
            tw(knobGlow, 0.2, { ImageTransparency = 0.6 })
        end
    end)

    update(bar.AbsolutePosition.X)
    end
    -- ═══════════════════════════════════════════════════════════════
    -- TEXT BOX
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateTextBox(tabName, placeholder, callback, options)
    options = options or {}
    local tab = pages[tabName]; if not tab then return end

    local c = Instance.new("Frame", tab)
    c.Size = UDim2.new(1, -20, 0, 44)
    c.Position = UDim2.new(0, 10, 0, 0)
    c.BackgroundTransparency = 1
    c.ClipsDescendants = true

    -- Glow externo
    local glow = Instance.new("ImageLabel", c)
    glow.Size = UDim2.new(1, 12, 1, 12)
    glow.Position = UDim2.new(0, -6, 0, -6)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://1316045217"
    glow.ImageColor3 = P.AccentHi
    glow.ImageTransparency = 1
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(10, 10, 118, 118)
    glow.ZIndex = 0

    local bg = Instance.new("Frame", c)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = P.Surface
    bg.BorderSizePixel = 0
    bg.ZIndex = 1
    addCorner(bg, UDim.new(0, 8))
    local bgs = addStroke(bg, P.Border, 1, 0.5)

    -- Barra neon inferior
    local hl = Instance.new("Frame", bg)
    hl.Size = UDim2.new(1, 0, 0, 2)
    hl.Position = UDim2.new(0, 0, 1, -2)
    hl.BackgroundColor3 = P.Accent
    hl.BackgroundTransparency = 1
    hl.BorderSizePixel = 0
    hl.ZIndex = 2
    addCorner(hl, UDim.new(1, 0))

    -- Ícone opcional
    local icon = nil
    if options.Icon then
        icon = Instance.new("ImageLabel", bg)
        icon.Size = UDim2.new(0, 16, 0, 16)
        icon.Position = UDim2.new(0, 12, 0.5, -8)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://" .. tostring(options.Icon)
        icon.ImageColor3 = P.TextMute
        icon.ZIndex = 3
    end

    local txtLeft = icon and 36 or 12
    local txtRight = 30

    local ph = Instance.new("TextLabel", bg)
    ph.Size = UDim2.new(1, -(txtLeft + txtRight), 0, 14)
    ph.Position = UDim2.new(0, txtLeft, 0.5, -7)
    ph.BackgroundTransparency = 1
    ph.Text = placeholder or "Escreva..."
    ph.TextColor3 = P.TextMute
    ph.Font = Enum.Font.Gotham
    ph.TextSize = 13
    ph.TextXAlignment = Enum.TextXAlignment.Left
    ph.TextTruncate = Enum.TextTruncate.AtEnd
    ph.ZIndex = 2

    local tb = Instance.new("TextBox", bg)
    tb.Size = UDim2.new(1, -(txtLeft + txtRight), 1, 0)
    tb.Position = UDim2.new(0, txtLeft, 0, 0)
    tb.BackgroundTransparency = 1
    tb.Text = options.Default or ""
    tb.TextColor3 = P.Text
    tb.Font = Enum.Font.Gotham
    tb.TextSize = 13
    tb.ClearTextOnFocus = false
    tb.TextXAlignment = Enum.TextXAlignment.Left
    tb.TextTruncate = Enum.TextTruncate.AtEnd
    tb.PlaceholderText = ""
    tb.ZIndex = 3

    -- Botão limpar
    local clearBtn = Instance.new("TextButton", bg)
    clearBtn.Size = UDim2.new(0, 18, 0, 18)
    clearBtn.Position = UDim2.new(1, -24, 0.5, -9)
    clearBtn.BackgroundTransparency = 1
    clearBtn.Text = "✕"
    clearBtn.TextColor3 = P.TextMute
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = 12
    clearBtn.AutoButtonColor = false
    clearBtn.Visible = false
    clearBtn.ZIndex = 4

    clearBtn.MouseEnter:Connect(function() tw(clearBtn, 0.15, { TextColor3 = P.Danger }) end)
    clearBtn.MouseLeave:Connect(function() tw(clearBtn, 0.15, { TextColor3 = P.TextMute }) end)
    clearBtn.MouseButton1Click:Connect(function()
        tb.Text = ""
        clearBtn.Visible = false
        ph.Visible = true
        if callback then pcall(callback, "") end
    end)

    local function refreshClear() clearBtn.Visible = (tb.Text ~= "") end
    tb:GetPropertyChangedSignal("Text"):Connect(refreshClear)
    refreshClear()

    tb.Focused:Connect(function()
        if tb.Text == "" then
            tw(ph, 0.2, { TextTransparency = 1 })
            task.delay(0.2, function()
                if tb:IsFocused() then ph.Visible = false end
            end)
        end
        tw(glow, 0.25, { ImageTransparency = 0.4 })
        tw(hl, 0.25, { BackgroundTransparency = 0.2 })
        tw(bgs, 0.25, { Color = P.AccentHi, Transparency = 0.1 })
        tw(bg, 0.25, { BackgroundColor3 = mix(P.Surface, P.Accent, 0.08) })
        if icon then tw(icon, 0.25, { ImageColor3 = P.AccentHi }) end
    end)

    tb.FocusLost:Connect(function(enter)
        if tb.Text == "" then
            ph.Visible = true
            ph.TextTransparency = 1
            tw(ph, 0.2, { TextTransparency = 0 })
        end
        tw(glow, 0.3, { ImageTransparency = 1 })
        tw(hl, 0.3, { BackgroundTransparency = 1 })
        tw(bgs, 0.25, { Color = P.Border, Transparency = 0.5 })
        tw(bg, 0.25, { BackgroundColor3 = P.Surface })
        if icon then tw(icon, 0.25, { ImageColor3 = P.TextMute }) end
        if enter and callback then pcall(callback, tb.Text) end
    end)

    registerTheme(function()
        tw(glow, 0.4, { ImageColor3 = P.AccentHi })
        tw(hl, 0.4, { BackgroundColor3 = P.Accent })
    end)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- PROFESSIONAL COLOR PICKER
    -- ═══════════════════════════════════════════════════════════════
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
    addCorner(frame, UDim.new(0, 10))
    local fStroke = addStroke(frame, P.Border, 1, 0.5)

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
    addCorner(previewDot, UDim.new(0, 6))
    addStroke(previewDot, Color3.new(1,1,1), 1.5, 0.4)

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

    -- SV PAD
    local padSize = 150
    local pad = Instance.new("Frame", body)
    pad.Size = UDim2.new(0, padSize, 0, padSize)
    pad.Position = UDim2.new(0, 14, 0, 12)
    pad.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    pad.BorderSizePixel = 0
    addCorner(pad, UDim.new(0, 8))
    pad.ClipsDescendants = true
    addStroke(pad, P.Border, 1, 0.4)

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
    addCorner(padMarker, UDim.new(1, 0))
    addStroke(padMarker, Color3.new(0, 0, 0), 2, 0.2)
    padMarker.ZIndex = 5

    -- HUE
    local hueBar = Instance.new("Frame", body)
    hueBar.Size = UDim2.new(0, 20, 0, padSize)
    hueBar.Position = UDim2.new(0, 14 + padSize + 12, 0, 12)
    hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
    hueBar.BorderSizePixel = 0
    addCorner(hueBar, UDim.new(0, 6))
    addStroke(hueBar, P.Border, 1, 0.4)
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
    addCorner(hueMarker, UDim.new(1, 0))
    addStroke(hueMarker, Color3.new(0, 0, 0), 2, 0.3)

    -- PREVIEW COLUMN
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
    addCorner(preview, UDim.new(0, 6))
    addStroke(preview, Color3.new(1,1,1), 1, 0.6)

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
    addCorner(hexBox, UDim.new(0, 5))
    addStroke(hexBox, P.Border, 1, 0.5)

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
        addCorner(ff, UDim.new(0, 5))
        addStroke(ff, P.Border, 1, 0.5)
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

    -- PRESETS
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
        addCorner(sw2, UDim.new(1, 0))
        addStroke(sw2, Color3.new(0, 0, 0), 1, 0.6)
        sw2.MouseButton1Click:Connect(function()
            local nh, ns, nv = Color3.toHSV(pc)
            h, s, v = nh, ns, nv
            -- desliga ciclo se estava ligado
            if cycling then
                cycling = false
                cycleBtn.Text = "🌈 Ciclar"
                cycleBtn.TextColor3 = P.Text
            end
            updateAll()
        end)
    end

    -- RECENTES
    local recentRow = Instance.new("Frame", body)
    recentRow.Size = UDim2.new(1, -28, 0, 20)
    recentRow.Position = UDim2.new(0, 14, 0, 12 + padSize + 40)
    recentRow.BackgroundTransparency = 1
    local recentLay = Instance.new("UIListLayout", recentRow)
    recentLay.FillDirection = Enum.FillDirection.Horizontal
    recentLay.Padding = UDim.new(0, 4)

    local function refreshRecents()
        for _, ch in ipairs(recentRow:GetChildren()) do
            if ch:IsA("Frame") then ch:Destroy() end
        end
        for _, rc in ipairs(recentColors) do
            local sw3 = Instance.new("Frame", recentRow)
            sw3.Size = UDim2.new(0, 20, 0, 20)
            sw3.BackgroundColor3 = rc
            addCorner(sw3, UDim.new(1, 0))
            addStroke(sw3, Color3.new(0, 0, 0), 1, 0.6)
        end
    end

    -- ==========================================================
    -- LINHA DE AÇÃO: 2 BOTÕES LADO A LADO (aleatório + ciclar)
    -- ==========================================================
    local actionRow = Instance.new("Frame", body)
    actionRow.Size = UDim2.new(1, -28, 0, 26)
    actionRow.Position = UDim2.new(0, 14, 0, 12 + padSize + 68)
    actionRow.BackgroundTransparency = 1

    local function styleActionBtn(b)
        b.BackgroundColor3 = P.SurfaceHi
        b.TextColor3 = P.Text
        b.Font = Enum.Font.GothamMedium
        b.TextSize = 12
        b.AutoButtonColor = false
        addCorner(b, UDim.new(0, 6))
        addStroke(b, P.Border, 1, 0.5)
        b.MouseEnter:Connect(function() tw(b, 0.15, { BackgroundColor3 = mix(P.SurfaceHi, P.Accent, 0.35) }) end)
        b.MouseLeave:Connect(function() tw(b, 0.15, { BackgroundColor3 = P.SurfaceHi }) end)
    end

    -- Botão Aleatório (metade esquerda)
    local randBtn = Instance.new("TextButton", actionRow)
    randBtn.Size = UDim2.new(0.5, -3, 1, 0)
    randBtn.Position = UDim2.new(0, 0, 0, 0)
    randBtn.Text = "🎲 Aleatório"
    styleActionBtn(randBtn)

    -- Botão Ciclar RGB (metade direita) — TOGGLE
    local cycleBtn = Instance.new("TextButton", actionRow)
    cycleBtn.Size = UDim2.new(0.5, -3, 1, 0)
    cycleBtn.Position = UDim2.new(0.5, 3, 0, 0)
    cycleBtn.Text = "🌈 Ciclar"
    styleActionBtn(cycleBtn)
    local cycleStroke = cycleBtn:FindFirstChildOfClass("UIStroke")

    local cycling = false

    -- Função central de update
    local updating = false
    local function updateAll()
        if updating then return end
        updating = true
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
        updating = false
    end

    -- Drag no pad
    local padDrag = false
    local function padUpdate(input)
        local px = math.clamp(input.Position.X - pad.AbsolutePosition.X, 0, pad.AbsoluteSize.X)
        local py = math.clamp(input.Position.Y - pad.AbsolutePosition.Y, 0, pad.AbsoluteSize.Y)
        s = px / pad.AbsoluteSize.X
        v = 1 - (py / pad.AbsoluteSize.Y)
        updateAll()
    end
    pad.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            padDrag = true; padUpdate(i)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if padDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            padUpdate(i)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            padDrag = false
        end
    end)

    -- Drag no hue
    local hueDrag = false
    local function hueUpdate(input)
        local py = math.clamp(input.Position.Y - hueBar.AbsolutePosition.Y, 0, hueBar.AbsoluteSize.Y)
        h = py / hueBar.AbsoluteSize.Y
        updateAll()
    end
    hueBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            hueDrag = true; hueUpdate(i)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if hueDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            hueUpdate(i)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            hueDrag = false
        end
    end)

    -- HEX
    hexBox.FocusLost:Connect(function(enter)
        local c = hexToColor(hexBox.Text)
        if c then
            h, s, v = Color3.toHSV(c)
            updateAll()
            if enter then
                table.insert(recentColors, 1, c)
                if #recentColors > 8 then table.remove(recentColors) end
                refreshRecents()
            end
        else
            hexBox.Text = colorToHex(current)
        end
    end)

    -- RGB inputs
    local function applyRGB()
        local r = math.clamp(tonumber(rIn.Text) or 0, 0, 255)
        local g = math.clamp(tonumber(gIn.Text) or 0, 0, 255)
        local b = math.clamp(tonumber(bIn.Text) or 0, 0, 255)
        local c = Color3.fromRGB(r, g, b)
        h, s, v = Color3.toHSV(c)
        updateAll()
    end
    rIn.FocusLost:Connect(applyRGB)
    gIn.FocusLost:Connect(applyRGB)
    bIn.FocusLost:Connect(applyRGB)

    -- Ações
    randBtn.MouseButton1Click:Connect(function()
        h = math.random() * 1.0
        s = 0.55 + math.random() * 0.45
        v = 0.65 + math.random() * 0.35
        updateAll()
    end)

    -- TOGGLE: Ciclar RGB (variação suave do hue)
    cycleBtn.MouseButton1Click:Connect(function()
        cycling = not cycling
        if cycling then
            cycleBtn.Text = "🌈 Ciclando..."
            cycleBtn.TextColor3 = P.AccentHi
            tw(cycleStroke, 0.2, { Color = P.AccentHi, Transparency = 0 })
        else
            cycleBtn.Text = "🌈 Ciclar"
            cycleBtn.TextColor3 = P.Text
            tw(cycleStroke, 0.2, { Color = P.Border, Transparency = 0.5 })
        end
    end)

    -- Loop do ciclo (0.005 por frame ≈ 0.3 ciclos por segundo)
    task.spawn(function()
        while frame.Parent do
            if cycling then
                h = (h + 0.006) % 1
                updateAll()
            end
            task.wait(0.016)
        end
    end)

    -- Expand/collapse
    local expanded = false
    local function setExpanded(v2)
        expanded = v2
        arrow.Text = expanded and "▲" or "▼"
        local targetH = expanded and (44 + 12 + padSize + 12 + 20 + 8 + 20 + 8 + 26 + 12) or 44
        tw(frame, 0.35, { Size = UDim2.new(1, -20, 0, targetH) }, Enum.EasingStyle.Back)
        body.Size = UDim2.new(1, 0, 0, expanded and (targetH - 44) or 0)
    end
    header.MouseButton1Click:Connect(function() setExpanded(not expanded) end)

    refreshRecents()
    updateAll()
    end
    -- ═══════════════════════════════════════════════════════════════
    -- SWITCH
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateSwitch(tabName, cfg)
        local tab = pages[tabName]; if not tab then return end
        cfg = cfg or {}

        local holder = Instance.new("Frame", tab)
        holder.Size = UDim2.new(1, -20, 0, 55)
        holder.Position = UDim2.new(0, 10, 0, 0)
        holder.BackgroundTransparency = 1

        local label = Instance.new("TextLabel", holder)
        label.Size = UDim2.new(0.6, 0, 1, -10)
        label.BackgroundTransparency = 1
        label.Text = cfg.Text or "Switch"
        label.Font = Enum.Font.GothamBold
        label.TextColor3 = P.Text
        label.TextSize = 15
        label.TextXAlignment = Enum.TextXAlignment.Left

        local sw = Instance.new("Frame", holder)
        sw.Size = UDim2.new(0, 60, 0, 26)
        sw.Position = UDim2.new(1, -65, 0.5, -13)
        sw.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        sw.BorderSizePixel = 0
        addCorner(sw, UDim.new(1, 0))
        local glow = addStroke(sw, P.AccentHi, 1.5, 1)

        local circle = Instance.new("Frame", sw)
        circle.Size = UDim2.new(0, 22, 0, 22)
        circle.Position = UDim2.new(0, 3, 0.5, -11)
        circle.BackgroundColor3 = Color3.fromRGB(210, 210, 215)
        circle.BorderSizePixel = 0
        addCorner(circle, UDim.new(1, 0))

        local stLbl = Instance.new("TextLabel", holder)
        stLbl.Size = UDim2.new(0, 40, 1, -10)
        stLbl.Position = UDim2.new(1, -115, 0, 0)
        stLbl.BackgroundTransparency = 1
        stLbl.Font = Enum.Font.GothamBold
        stLbl.TextSize = 13
        stLbl.TextColor3 = Color3.fromRGB(255, 85, 85)
        stLbl.Text = "OFF"
        stLbl.TextXAlignment = Enum.TextXAlignment.Right

        local ul = Instance.new("Frame", holder)
        ul.Size = UDim2.new(1, 0, 0, 1)
        ul.Position = UDim2.new(0, 0, 1, -3)
        ul.BackgroundColor3 = P.Border
        ul.BorderSizePixel = 0

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
        particle.Color = ColorSequence.new(Color3.new(1,1,1), P.AccentHi)

        local state = false
        registerTheme(function()
            if state then
                tw(sw, 0.4, { BackgroundColor3 = P.Accent })
                tw(glow, 0.4, { Color = P.AccentHi })
            end
        end)

        local function toggle()
            state = not state
            local gp = state and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
            local bg = state and P.Accent or Color3.fromRGB(50, 50, 55)
            local cc = state and Color3.new(1, 1, 1) or Color3.fromRGB(210, 210, 215)
            local tc = state and P.Success or Color3.fromRGB(255, 85, 85)
            tw(circle, 0.3, { Position = gp, BackgroundColor3 = cc }, Enum.EasingStyle.Back)
            tw(sw, 0.3, { BackgroundColor3 = bg }, Enum.EasingStyle.Back)
            tw(stLbl, 0.25, { TextColor3 = tc })
            tw(glow, 0.3, { Transparency = state and 0 or 1 })
            stLbl.Text = state and "ON" or "OFF"
            particle.Enabled = true
            task.delay(0.25, function() particle.Enabled = false end)
            if cfg.Callback then pcall(cfg.Callback, state) end
        end

        sw.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                toggle()
            end
        end)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- LINE
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateLine(tabName, color)
        local tab = pages[tabName]; if not tab then return end
        local l = Instance.new("Frame", tab)
        l.Size = UDim2.new(1, -20, 0, 1)
        l.Position = UDim2.new(0, 10, 0, 0)
        l.BackgroundColor3 = color or P.Border
        l.BorderSizePixel = 0
        local g = Instance.new("UIGradient", l)
        g.Transparency = NumberSequence.new(1, 0, 1)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- KEYBIND (NOVO)
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateKeybind(tabName, cfg)
        local tab = pages[tabName]; if not tab then return end
        cfg = cfg or {}

        local f = Instance.new("Frame", tab)
        f.Size = UDim2.new(1, -20, 0, 44)
        f.Position = UDim2.new(0, 10, 0, 0)
        f.BackgroundColor3 = P.Surface
        f.BorderSizePixel = 0
        addCorner(f, UDim.new(0, 8))
        local fStroke = addStroke(f, P.Border, 1, 0.6)

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
        addCorner(kbBtn, UDim.new(0, 6))
        local kbStroke = addStroke(kbBtn, P.Border, 1, 0.5)

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

        UIS.InputBegan:Connect(function(input, gpe)
            if gpe or not capturing then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode.Name
                kbBtn.Text = currentKey
                kbBtn.TextColor3 = P.Text
                capturing = false
                tw(kbStroke, 0.2, { Color = P.Border, Transparency = 0.5 })
                if cfg.Callback then pcall(cfg.Callback, input.KeyCode) end
                return
            end
        end)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- PROGRESS BAR (NOVO)
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateProgressBar(tabName, cfg)
        local tab = pages[tabName]; if not tab then return end
        cfg = cfg or {}

        local f = Instance.new("Frame", tab)
        f.Size = UDim2.new(1, -20, 0, 46)
        f.Position = UDim2.new(0, 10, 0, 0)
        f.BackgroundColor3 = P.Surface
        f.BorderSizePixel = 0
        addCorner(f, UDim.new(0, 8))
        addStroke(f, P.Border, 1, 0.6)

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
        addCorner(bar, UDim.new(1, 0))

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = P.Accent
        fill.BorderSizePixel = 0
        addCorner(fill, UDim.new(1, 0))
        local fg = Instance.new("UIGradient", fill)
        fg.Color = ColorSequence.new(P.AccentSoft, P.AccentHi)

        registerTheme(function()
            tw(fill, 0.4, { BackgroundColor3 = P.Accent })
            tw(fg, 0.4, { Color = ColorSequence.new(P.AccentSoft, P.AccentHi) })
            tw(pctLbl, 0.4, { TextColor3 = P.AccentHi })
        end)

        local api = {}
        function api:Set(value)
            local p = math.clamp(value / 100, 0, 1)
            fill:TweenSize(UDim2.new(p, 0, 1, 0), "Out", "Quart", 0.4, true)
            pctLbl.Text = string.format("%d%%", math.floor(p * 100 + 0.5))
        end
        function api:SetInstant(value)
            local p = math.clamp(value / 100, 0, 1)
            fill.Size = UDim2.new(p, 0, 1, 0)
            pctLbl.Text = string.format("%d%%", math.floor(p * 100 + 0.5))
        end
        api:Set(0)
        return api
    end

    -- ═══════════════════════════════════════════════════════════════
    -- NOTIFY CUSTOM
    -- ═══════════════════════════════════════════════════════════════
    local notifyQueue, notifying = {}, false
    local function processQueue()
        if notifying or #notifyQueue == 0 then return end
        notifying = true
        local data = table.remove(notifyQueue, 1)
        local frame = data.frame
        frame:TweenPosition(UDim2.new(1, -20, 1, -20 - (#notifyQueue * 110)), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.4, true)
        task.delay(2.2, function()
            frame:TweenPosition(UDim2.new(1, 320, 1, -200), Enum.EasingDirection.In, Enum.EasingStyle.Quint, 0.35, true)
            task.wait(0.4)
            data.gui:Destroy()
            notifying = false
            processQueue()
        end)
    end

    function Window:NotifyCustom(title, text, iconId)
        local sg = Instance.new("ScreenGui")
        sg.Name = "NotifyCustom"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        sg.DisplayOrder = 100
        pcall(function() sg.Parent = game:GetService("CoreGui") end)
        if not sg.Parent then sg.Parent = player:WaitForChild("PlayerGui") end

        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, 300, 0, 100)
        f.Position = UDim2.new(1, 320, 1, -200)
        f.AnchorPoint = Vector2.new(1, 1)
        f.BackgroundColor3 = P.Bg
        f.BackgroundTransparency = 0.05
        f.BorderSizePixel = 0
        f.Parent = sg
        addCorner(f, UDim.new(0, 12))
        local nStroke = addStroke(f, P.AccentHi, 1.5, 0.2)
        registerTheme(function() tw(nStroke, 0.5, { Color = P.AccentHi }) end)

        local grad = Instance.new("UIGradient", f)
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, P.Accent),
            ColorSequenceKeypoint.new(0.5, P.AccentHi),
            ColorSequenceKeypoint.new(1, P.Accent),
        })
        grad.Rotation = 45
        grad.Transparency = NumberSequence.new(0.95)

        local prog = Instance.new("Frame", f)
        prog.Size = UDim2.new(1, 0, 0, 3)
        prog.Position = UDim2.new(0, 0, 1, -3)
        prog.BackgroundColor3 = P.AccentHi
        prog.BorderSizePixel = 0
        addCorner(prog, UDim.new(1, 0))
        tw(prog, 2.2, { Size = UDim2.new(0, 0, 0, 3) }, Enum.EasingStyle.Linear)

        local ic = Instance.new("ImageLabel")
        ic.Size = UDim2.new(0, 48, 0, 48)
        ic.Position = UDim2.new(0, 14, 0, 26)
        ic.Image = "rbxassetid://" .. tostring(iconId)
        ic.BackgroundTransparency = 1
        ic.Parent = f

        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1, -80, 0, 26)
        tl.Position = UDim2.new(0, 72, 0, 16)
        tl.Text = title
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 15
        tl.TextColor3 = P.Text
        tl.TextXAlignment = Enum.TextXAlignment.Left
        tl.BackgroundTransparency = 1
        tl.Parent = f

        local xl = Instance.new("TextLabel")
        xl.Size = UDim2.new(1, -80, 0, 36)
        xl.Position = UDim2.new(0, 72, 0, 42)
        xl.Text = text
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

    -- ═══════════════════════════════════════════════════════════════
    -- PROMO BOX
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreatePromoBox(tabName, title, description, imageId, link, channelName)
        local tab = pages[tabName]; if not tab then return end
        local box = Instance.new("Frame", tab)
        box.Size = UDim2.new(1, -20, 0, 0)
        box.Position = UDim2.new(0, 10, 0, 0)
        box.BackgroundColor3 = P.Surface
        box.BorderSizePixel = 0
        box.AutomaticSize = Enum.AutomaticSize.Y
        box.ClipsDescendants = true
        addCorner(box, UDim.new(0, 12))
        local bx = addStroke(box, P.AccentSoft, 1.5, 0.3)

        local ic = Instance.new("ImageLabel", box)
        ic.Size = UDim2.new(0, 90, 0, 90)
        ic.Position = UDim2.new(0, 10, 0, 10)
        ic.Image = "rbxassetid://" .. tostring(imageId)
        ic.BackgroundColor3 = P.SurfaceHi
        ic.BorderSizePixel = 0
        ic.ScaleType = Enum.ScaleType.Fit
        addCorner(ic, UDim.new(0, 8))
        addStroke(ic, P.Border, 1, 0.5)

        local chBox = Instance.new("TextBox", box)
        chBox.Text = channelName or "SEU CANAL"
        chBox.Size = UDim2.new(0, 90, 0, 0)
        chBox.Position = UDim2.new(0, 10, 0, 105)
        chBox.Font = Enum.Font.GothamBold
        chBox.TextSize = 12
        chBox.TextColor3 = P.Text
        chBox.BackgroundColor3 = P.SurfaceHi
        chBox.BorderSizePixel = 0
        chBox.ClearTextOnFocus = false
        chBox.AutomaticSize = Enum.AutomaticSize.Y
        chBox.TextWrapped = true
        chBox.TextXAlignment = Enum.TextXAlignment.Center
        chBox.TextYAlignment = Enum.TextYAlignment.Center
        chBox.ClipsDescendants = true
        chBox.TextEditable = false
        addCorner(chBox, UDim.new(0, 6))
        addStroke(chBox, P.Accent, 1.2, 0.2)

        local content = Instance.new("Frame", box)
        content.BackgroundTransparency = 1
        content.Position = UDim2.new(0, 110, 0, 10)
        content.Size = UDim2.new(1, -120, 0, 0)
        content.AutomaticSize = Enum.AutomaticSize.Y
        local lay = Instance.new("UIListLayout", content)
        lay.Padding = UDim.new(0, 6)

        local ttl = Instance.new("TextLabel", content)
        ttl.Text = "  " .. string.upper(title or "")
        ttl.Font = Enum.Font.GothamBold
        ttl.TextSize = 16
        ttl.TextColor3 = P.Text
        ttl.BackgroundTransparency = 1
        ttl.Size = UDim2.new(1, 0, 0, 30)
        ttl.TextXAlignment = Enum.TextXAlignment.Left

        local bh = Instance.new("Frame", content)
        bh.Size = UDim2.new(1, 0, 0, 32)
        bh.BackgroundColor3 = P.AccentSoft
        bh.BorderSizePixel = 0
        bh.ClipsDescendants = true
        addCorner(bh, UDim.new(0, 6))
        addStroke(bh, P.Accent, 1.2, 0.2)

        local cp = Instance.new("TextButton", bh)
        cp.Text = "COPIAR LINK"
        cp.Font = Enum.Font.GothamBold
        cp.TextSize = 13
        cp.TextColor3 = P.Text
        cp.BackgroundTransparency = 1
        cp.Size = UDim2.new(1, 0, 1, 0)
        cp.ZIndex = 2

        local fb = Instance.new("Frame", bh)
        fb.Size = UDim2.new(0, 0, 1, 0)
        fb.BackgroundColor3 = P.AccentHi
        fb.BorderSizePixel = 0
        fb.ZIndex = 1

        local dl = Instance.new("TextLabel", content)
        dl.Text = description
        dl.Font = Enum.Font.Gotham
        dl.TextSize = 13
        dl.TextColor3 = P.TextMute
        dl.BackgroundTransparency = 1
        dl.Size = UDim2.new(1, 0, 0, 0)
        dl.AutomaticSize = Enum.AutomaticSize.Y
        dl.TextWrapped = true
        dl.TextXAlignment = Enum.TextXAlignment.Left

        cp.MouseButton1Click:Connect(function()
            pcall(setclipboard, link)
            fb.Size = UDim2.new(0, 0, 1, 0)
            fb:TweenSize(UDim2.new(1, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.5, true)
        end)

        return { MainFrame = box, ChannelBox = chBox, DescriptionLabel = dl, CopyButton = cp }
    end

    -- ═══════════════════════════════════════════════════════════════
    -- PROFESSIONAL THEME BOXES
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateThemeBoxes(tabName, mainFrameArg)
        local tab = pages[tabName]; if not tab then return end

        -- paletas categorizadas
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
        addCorner(infoBox, UDim.new(0, 8))
        local ibStroke = addStroke(infoBox, P.Border, 1, 0.6)
        registerTheme(function() tw(ibStroke, 0.4, { Color = P.BorderTint }) end)

        local infoDot = Instance.new("Frame", infoBox)
        infoDot.Size = UDim2.new(0, 8, 0, 8)
        infoDot.Position = UDim2.new(0, 14, 0.5, -4)
        infoDot.BackgroundColor3 = P.Accent
        infoDot.BorderSizePixel = 0
        addCorner(infoDot, UDim.new(1, 0))
        registerTheme(function() tw(infoDot, 0.4, { BackgroundColor3 = P.Accent }) end)

        local infoLbl = Instance.new("TextLabel", infoBox)
        infoLbl.Size = UDim2.new(1, -40, 1, 0)
        infoLbl.Position = UDim2.new(0, 30, 0, 0)
        infoLbl.BackgroundTransparency = 1
        infoLbl.Text = "Clique em um tema — toda a interface se adapta com contraste automático."
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
        gridLay.CellSize = UDim2.new(0, 62, 0, 46)
        gridLay.CellPadding = UDim2.new(0, 6, 0, 6)
        gridLay.SortOrder = Enum.SortOrder.LayoutOrder

        local lastSelected = nil

        local function selectTheme(t)
            applySmartTheme(t.accent)
            broadcastTheme()

            -- animação de "pop" no botão selecionado
            if lastSelected and lastSelected.Parent then
                tw(lastSelected, 0.3, { Size = UDim2.new(0, 62, 0, 46) }, Enum.EasingStyle.Back)
            end
            if t._ui then
                tw(t._ui, 0.3, { Size = UDim2.new(0, 66, 0, 50) }, Enum.EasingStyle.Back)
                t._ui.Position = UDim2.new(0, -2, 0, -2)
                lastSelected = t._ui
            end

            Window:NotifyCustom("TEMA APLICADO", t.name .. " aplicado com sucesso!", "4483362458")
        end

        for i, t in ipairs(THEMES) do
            local card = Instance.new("TextButton", grid)
            card.Size = UDim2.new(0, 62, 0, 46)
            card.BackgroundColor3 = P.Surface
            card.Text = ""
            card.AutoButtonColor = false
            addCorner(card, UDim.new(0, 8))
            local cardStroke = addStroke(card, P.Border, 1, 0.6)

            -- gradient com a cor do tema
            local cg = Instance.new("UIGradient", card)
            cg.Rotation = 135
            cg.Color = ColorSequence.new(t.accent, mix(t.accent, Color3.new(0,0,0), 0.7))

            -- overlay escuro para melhorar contraste do texto
            local ov = Instance.new("Frame", card)
            ov.Size = UDim2.new(1, 0, 1, 0)
            ov.BackgroundColor3 = Color3.new(0, 0, 0)
            ov.BackgroundTransparency = 0.55
            ov.BorderSizePixel = 0
            ov.ZIndex = 1
            addCorner(ov, UDim.new(0, 8))

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
                tw(card, 0.2, { Size = UDim2.new(0, 66, 0, 50) }, Enum.EasingStyle.Back)
                tw(cardStroke, 0.2, { Color = t.accent, Transparency = 0 })
            end)
            card.MouseLeave:Connect(function()
                if lastSelected ~= card then
                    tw(card, 0.2, { Size = UDim2.new(0, 62, 0, 46) }, Enum.EasingStyle.Back)
                    tw(cardStroke, 0.2, { Color = P.Border, Transparency = 0.6 })
                end
            end)

            card.MouseButton1Click:Connect(function() selectTheme(t) end)
        end

        -- aplica o último tema (Mono) inicialmente só se quiser
        applySmartTheme(Base and Color3.fromRGB(170, 20, 20) or Color3.fromRGB(170, 20, 20))

        return container
    end

    -- ═══════════════════════════════════════════════════════════════
    -- INFO BOX
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateInfoBox(tabName, title, infoList)
        local tab = pages[tabName]; if not tab then return end
        local box = Instance.new("Frame", tab)
        box.Size = UDim2.new(1, -20, 0, 0)
        box.Position = UDim2.new(0, 10, 0, 0)
        box.BackgroundColor3 = P.Surface
        box.BorderSizePixel = 0
        box.AutomaticSize = Enum.AutomaticSize.Y
        box.ClipsDescendants = true
        addCorner(box, UDim.new(0, 12))
        local bx = addStroke(box, P.AccentSoft, 1.5, 0.3)
        registerTheme(function() tw(bx, 0.4, { Color = P.AccentSoft }) end)

        local tl = Instance.new("TextLabel", box)
        tl.Text = "  " .. string.upper(title or "INFORMAÇÃO")
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 16
        tl.TextColor3 = P.Text
        tl.BackgroundTransparency = 1
        tl.Size = UDim2.new(1, -20, 0, 30)
        tl.Position = UDim2.new(0, 10, 0, 10)
        tl.TextXAlignment = Enum.TextXAlignment.Left

        local content = Instance.new("Frame", box)
        content.BackgroundTransparency = 1
        content.Position = UDim2.new(0, 10, 0, 50)
        content.Size = UDim2.new(1, -20, 0, 0)
        content.AutomaticSize = Enum.AutomaticSize.Y
        local lay = Instance.new("UIListLayout", content)
        lay.Padding = UDim.new(0, 6)

        for i, text in ipairs(infoList or {}) do
            local item = Instance.new("Frame", content)
            item.BackgroundColor3 = P.SurfaceHi
            item.BorderSizePixel = 0
            item.AutomaticSize = Enum.AutomaticSize.Y
            item.Size = UDim2.new(1, 0, 0, 0)
            item.ClipsDescendants = true
            addCorner(item, UDim.new(0, 6))
            addStroke(item, P.Border, 1, 0.5)

            local num = Instance.new("TextLabel", item)
            num.Text = tostring(i) .. "."
            num.Font = Enum.Font.GothamBold
            num.TextSize = 13
            num.TextColor3 = P.AccentHi
            num.BackgroundTransparency = 1
            num.Size = UDim2.new(0, 30, 1, 0)
            num.Position = UDim2.new(0, 10, 0, 0)
            num.TextXAlignment = Enum.TextXAlignment.Left
            num.TextYAlignment = Enum.TextYAlignment.Top

            local dl = Instance.new("TextLabel", item)
            dl.Text = text
            dl.Font = Enum.Font.Gotham
            dl.TextSize = 13
            dl.TextColor3 = P.Text
            dl.BackgroundTransparency = 1
            dl.Position = UDim2.new(0, 40, 0, 5)
            dl.Size = UDim2.new(1, -50, 0, 0)
            dl.AutomaticSize = Enum.AutomaticSize.Y
            dl.TextWrapped = true
            dl.TextXAlignment = Enum.TextXAlignment.Left
            dl.TextYAlignment = Enum.TextYAlignment.Top
        end

        return { MainFrame = box, TitleLabel = tl, ContentFrame = content }
    end

    -- ═══════════════════════════════════════════════════════════════
    -- HIDE / SHOW
    -- ═══════════════════════════════════════════════════════════════
    local isHidden = false
    local function doHide()
        if isHidden then return end
        isHidden = true
        local fs = mainFrame.AbsoluteSize
        currentSize = Vector2.new(fs.X, fs.Y)
        tw(mainFrame, 0.25, { Size = UDim2.new(0, currentSize.X, 0, 10), BackgroundTransparency = 0.4 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
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
            tw(mainFrame, 0.4, { Size = UDim2.new(0, currentSize.X, 0, currentSize.Y), BackgroundTransparency = 0 }, Enum.EasingStyle.Back)
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
