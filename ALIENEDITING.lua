-- ═══════════════════════════════════════════════════════════════════════
--  NINOMAX UI LIBRARY · v1.0 · ULTRA EDITION
--  Fusion of Rayfield + Redz + Lunax · Superior to all
-- ═══════════════════════════════════════════════════════════════════════

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")
local Players          = game:GetService("Players")
local Lighting         = game:GetService("Lighting")

local Player = Players.LocalPlayer

local NINOMAX = {}
NINOMAX.Version = "1.0.0"
NINOMAX.Flags = {}
NINOMAX.Options = {}
NINOMAX.Connections = {}
NINOMAX.Icons = {
    home = "rbxassetid://10709791523",
    settings = "rbxassetid://10734950309",
    user = "rbxassetid://10747373176",
    sword = "rbxassetid://10734975692",
    shield = "rbxassetid://10734951847",
    star = "rbxassetid://10734966248",
    zap = "rbxassetid://10734974297",
    code = "rbxassetid://10709810463",
    palette = "rbxassetid://10734910430",
    rocket = "rbxassetid://10734934585",
    wand = "rbxassetid://10747376565",
    wrench = "rbxassetid://10747383470",
    gift = "rbxassetid://10723396402",
    globe = "rbxassetid://10723404337",
    heart = "rbxassetid://10723406885",
    grid = "rbxassetid://10723404936",
    cpu = "rbxassetid://10709813383",
    activity = "rbxassetid://10709752035",
    alert = "rbxassetid://10709752996",
    check = "rbxassetid://10709790644",
    close = "rbxassetid://10747384394",
    minus = "rbxassetid://10734896206",
    plus = "rbxassetid://10734924532",
    search = "rbxassetid://10734943674",
    copy = "rbxassetid://10709812159",
    trash = "rbxassetid://10747362393",
    link = "rbxassetid://10723426722",
    lock = "rbxassetid://10723434711",
    unlock = "rbxassetid://10747366027",
    eye = "rbxassetid://10723346959",
    clock = "rbxassetid://10709805144",
    fire = "rbxassetid://10723376114",
    crown = "rbxassetid://10709818626",
    skull = "rbxassetid://10734962068",
    ghost = "rbxassetid://10723396107",
    bolt = "rbxassetid://10723345749",
    flash = "rbxassetid://10723376471",
    atom = "rbxassetid://10723396395",
}

-- ═══════════════════════════════════════════════════════════════════════
-- THEMES
-- ═══════════════════════════════════════════════════════════════════════
NINOMAX.Themes = {
    Default = {
        Accent     = Color3.fromRGB(220, 30, 45),
        AccentHi   = Color3.fromRGB(255, 70, 85),
        AccentSoft = Color3.fromRGB(100, 12, 20),
        AccentDeep = Color3.fromRGB(55, 6, 10),
        Bg         = Color3.fromRGB(14, 14, 18),
        BgSolid    = Color3.fromRGB(18, 18, 24),
        Surface    = Color3.fromRGB(26, 26, 34),
        SurfaceHi  = Color3.fromRGB(38, 38, 48),
        SurfaceLow = Color3.fromRGB(20, 20, 26),
        Border     = Color3.fromRGB(50, 50, 62),
        Text       = Color3.fromRGB(245, 245, 250),
        TextDim    = Color3.fromRGB(170, 170, 180),
        TextMute   = Color3.fromRGB(110, 110, 120),
        Success    = Color3.fromRGB(60, 220, 120),
        Warning    = Color3.fromRGB(255, 180, 50),
        Danger     = Color3.fromRGB(255, 80, 90),
    },
    Dark = {
        Accent     = Color3.fromRGB(90, 120, 255),
        AccentHi   = Color3.fromRGB(130, 160, 255),
        AccentSoft = Color3.fromRGB(40, 55, 130),
        AccentDeep = Color3.fromRGB(22, 30, 70),
        Bg         = Color3.fromRGB(10, 10, 14),
        BgSolid    = Color3.fromRGB(14, 14, 20),
        Surface    = Color3.fromRGB(22, 22, 30),
        SurfaceHi  = Color3.fromRGB(34, 34, 44),
        SurfaceLow = Color3.fromRGB(16, 16, 22),
        Border     = Color3.fromRGB(45, 45, 55),
        Text       = Color3.fromRGB(240, 240, 245),
        TextDim    = Color3.fromRGB(160, 160, 170),
        TextMute   = Color3.fromRGB(100, 100, 110),
        Success    = Color3.fromRGB(60, 220, 120),
        Warning    = Color3.fromRGB(255, 180, 50),
        Danger     = Color3.fromRGB(255, 80, 90),
    },
    Purple = {
        Accent     = Color3.fromRGB(160, 60, 255),
        AccentHi   = Color3.fromRGB(200, 120, 255),
        AccentSoft = Color3.fromRGB(70, 25, 120),
        AccentDeep = Color3.fromRGB(35, 10, 65),
        Bg         = Color3.fromRGB(15, 12, 20),
        BgSolid    = Color3.fromRGB(20, 16, 26),
        Surface    = Color3.fromRGB(30, 24, 40),
        SurfaceHi  = Color3.fromRGB(42, 34, 56),
        SurfaceLow = Color3.fromRGB(22, 18, 30),
        Border     = Color3.fromRGB(58, 48, 72),
        Text       = Color3.fromRGB(245, 240, 255),
        TextDim    = Color3.fromRGB(180, 170, 200),
        TextMute   = Color3.fromRGB(120, 110, 140),
        Success    = Color3.fromRGB(60, 220, 120),
        Warning    = Color3.fromRGB(255, 180, 50),
        Danger     = Color3.fromRGB(255, 80, 90),
    },
    Emerald = {
        Accent     = Color3.fromRGB(40, 200, 130),
        AccentHi   = Color3.fromRGB(80, 240, 170),
        AccentSoft = Color3.fromRGB(15, 80, 55),
        AccentDeep = Color3.fromRGB(8, 40, 28),
        Bg         = Color3.fromRGB(12, 16, 14),
        BgSolid    = Color3.fromRGB(16, 22, 20),
        Surface    = Color3.fromRGB(24, 34, 30),
        SurfaceHi  = Color3.fromRGB(34, 46, 42),
        SurfaceLow = Color3.fromRGB(18, 26, 22),
        Border     = Color3.fromRGB(45, 62, 56),
        Text       = Color3.fromRGB(240, 250, 245),
        TextDim    = Color3.fromRGB(165, 185, 175),
        TextMute   = Color3.fromRGB(105, 125, 115),
        Success    = Color3.fromRGB(60, 220, 120),
        Warning    = Color3.fromRGB(255, 180, 50),
        Danger     = Color3.fromRGB(255, 80, 90),
    },
    Sunset = {
        Accent     = Color3.fromRGB(255, 130, 40),
        AccentHi   = Color3.fromRGB(255, 170, 90),
        AccentSoft = Color3.fromRGB(130, 60, 15),
        AccentDeep = Color3.fromRGB(65, 30, 8),
        Bg         = Color3.fromRGB(18, 12, 10),
        BgSolid    = Color3.fromRGB(24, 16, 12),
        Surface    = Color3.fromRGB(36, 24, 18),
        SurfaceHi  = Color3.fromRGB(50, 34, 26),
        SurfaceLow = Color3.fromRGB(28, 18, 14),
        Border     = Color3.fromRGB(65, 45, 35),
        Text       = Color3.fromRGB(255, 245, 235),
        TextDim    = Color3.fromRGB(210, 180, 160),
        TextMute   = Color3.fromRGB(140, 115, 100),
        Success    = Color3.fromRGB(60, 220, 120),
        Warning    = Color3.fromRGB(255, 200, 60),
        Danger     = Color3.fromRGB(255, 80, 90),
    },
    Cyber = {
        Accent     = Color3.fromRGB(255, 20, 200),
        AccentHi   = Color3.fromRGB(255, 90, 230),
        AccentSoft = Color3.fromRGB(120, 10, 90),
        AccentDeep = Color3.fromRGB(60, 5, 45),
        Bg         = Color3.fromRGB(12, 10, 20),
        BgSolid    = Color3.fromRGB(16, 12, 26),
        Surface    = Color3.fromRGB(26, 18, 42),
        SurfaceHi  = Color3.fromRGB(38, 26, 60),
        SurfaceLow = Color3.fromRGB(20, 14, 32),
        Border     = Color3.fromRGB(60, 40, 90),
        Text       = Color3.fromRGB(245, 240, 255),
        TextDim    = Color3.fromRGB(180, 160, 220),
        TextMute   = Color3.fromRGB(120, 100, 160),
        Success    = Color3.fromRGB(60, 220, 120),
        Warning    = Color3.fromRGB(255, 180, 50),
        Danger     = Color3.fromRGB(255, 80, 90),
    },
}

local Current = {}
local function ApplyTheme(name)
    local t = NINOMAX.Themes[name] or NINOMAX.Themes.Default
    for k, v in pairs(t) do Current[k] = v end
    NINOMAX.CurrentTheme = name
end
ApplyTheme("Default")

-- ═══════════════════════════════════════════════════════════════════════
-- UTILS
-- ═══════════════════════════════════════════════════════════════════════
local function tw(inst, dur, props, style, dir)
    local t = TweenService:Create(inst,
        TweenInfo.new(dur or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    t:Play(); return t
end

local function newCorner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = r or UDim.new(0, 8)
    c.Parent = p; return c
end

local function newStroke(p, col, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or Current.Border
    s.Thickness = th or 1
    s.Transparency = tr or 0.4
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p; return s
end

local function newPad(p, t, r, b, l)
    local u = Instance.new("UIPadding", p)
    u.PaddingTop = UDim.new(0, t or 0)
    u.PaddingRight = UDim.new(0, r or 0)
    u.PaddingBottom = UDim.new(0, b or 0)
    u.PaddingLeft = UDim.new(0, l or 0)
    return u
end

local function mix(a, b, t)
    return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t)
end

local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function makeDraggable(frame, handle)
    handle = handle or frame
    local drag, sp, sfp
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; sp = i.Position; sfp = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - sp
            frame.Position = UDim2.new(sfp.X.Scale, sfp.X.Offset + d.X, sfp.Y.Scale, sfp.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

local function getIcon(name)
    if not name then return "" end
    if name:find("rbxassetid://") or name:find("rbxthumb://") then return name end
    return NINOMAX.Icons[name] or NINOMAX.Icons.home
end

-- ═══════════════════════════════════════════════════════════════════════
-- FLAGS + SAVE
-- ═══════════════════════════════════════════════════════════════════════
function NINOMAX:GetFlag(name)
    return self.Flags[name]
end

function NINOMAX:SetFlag(name, value)
    self.Flags[name] = value
    if self._onFlagChange then self._onFlagChange(name, value) end
end

local function saveConfig(file)
    if not file then return end
    pcall(function()
        if writefile then
            writefile(file, HttpService:JSONEncode(NINOMAX.Flags))
        end
    end)
end

local function loadConfig(file)
    if not file then return end
    pcall(function()
        if readfile and isfile and isfile(file) then
            local data = HttpService:JSONDecode(readfile(file))
            if type(data) == "table" then
                for k, v in pairs(data) do NINOMAX.Flags[k] = v end
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- THEME BINDING (todos os elementos registram aqui)
-- ═══════════════════════════════════════════════════════════════════════
local themeBindings = {}
local function onTheme(fn)
    table.insert(themeBindings, fn)
end

local function broadcastTheme()
    for _, fn in ipairs(themeBindings) do pcall(fn) end
end

-- ═══════════════════════════════════════════════════════════════════════
-- CREATE WINDOW
-- ═══════════════════════════════════════════════════════════════════════
function NINOMAX:CreateWindow(cfg)
    cfg = cfg or {}
    local Window = {}
    local TITLE_TEXT = cfg.Title or "NINOMAX"
    local SUBTITLE_TEXT = cfg.Subtitle or "v" .. self.Version
    local CONFIG_FILE = cfg.ConfigFile or "ninomax_config.json"
    local SIZE = Vector2.new(580, 400)
    local MIN_SIZE = Vector2.new(420, 300)
    local MAX_SIZE = Vector2.new(1200, 900)
    local currentSize = SIZE

    loadConfig(CONFIG_FILE)
    self._onFlagChange = function() saveConfig(CONFIG_FILE) end

    local gui = Instance.new("ScreenGui")
    gui.Name = "NINOMAX_UI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 99e99
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = Player:WaitForChild("PlayerGui") end

    -- UIScale para mobile
    local uiScale = Instance.new("UIScale", gui)
    uiScale.Scale = isMobile() and 1.1 or 1

    -- ═══ SHADOW HOLDER
    local shadowHolder = Instance.new("Frame", gui)
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
    shadowImg.ImageTransparency = 0.5
    shadowImg.ScaleType = Enum.ScaleType.Slice
    shadowImg.SliceCenter = Rect.new(10, 10, 118, 118)

    -- ═══ MAIN FRAME
    local mainFrame = Instance.new("TextButton")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Current.Bg
    mainFrame.Text = ""
    mainFrame.AutoButtonColor = false
    mainFrame.ClipsDescendants = true
    mainFrame.Active = true
    mainFrame.Parent = gui
    newCorner(mainFrame, UDim.new(0, 12))

    local mainStroke = newStroke(mainFrame, Current.Accent, 1.5, 0.3)
    local mainGrad = Instance.new("UIGradient", mainFrame)
    mainGrad.Rotation = 135
    mainGrad.Color = ColorSequence.new(Current.BgSolid, Current.Bg)

    -- Grid decorativo
    local gridHolder = Instance.new("Frame", mainFrame)
    gridHolder.Size = UDim2.new(1, 0, 1, 0)
    gridHolder.BackgroundTransparency = 1
    gridHolder.ClipsDescendants = true
    gridHolder.ZIndex = 0
    for i = 0, 14 do
        local l = Instance.new("Frame", gridHolder)
        l.BackgroundColor3 = Current.Border
        l.BackgroundTransparency = 0.92
        l.BorderSizePixel = 0
        l.Size = UDim2.new(0, 1, 1, 0)
        l.Position = UDim2.new(0, i * 44, 0, 0)
    end
    for i = 0, 10 do
        local l = Instance.new("Frame", gridHolder)
        l.BackgroundColor3 = Current.Border
        l.BackgroundTransparency = 0.92
        l.BorderSizePixel = 0
        l.Size = UDim2.new(1, 0, 0, 1)
        l.Position = UDim2.new(0, 0, 0, i * 42)
    end

    -- Orbs decorativos animados
    local decor = Instance.new("Frame", mainFrame)
    decor.Size = UDim2.new(1, 0, 1, 0)
    decor.BackgroundTransparency = 1
    decor.ClipsDescendants = true
    decor.ZIndex = 0

    local orb1 = Instance.new("Frame", decor)
    orb1.Size = UDim2.new(0, 280, 0, 280)
    orb1.Position = UDim2.new(-0.3, 0, -0.3, 0)
    orb1.BackgroundColor3 = Current.Accent
    orb1.BackgroundTransparency = 0.88
    orb1.BorderSizePixel = 0
    newCorner(orb1, UDim.new(1, 0))

    local orb2 = Instance.new("Frame", decor)
    orb2.Size = UDim2.new(0, 240, 0, 240)
    orb2.Position = UDim2.new(0.9, 0, 0.8, 0)
    orb2.BackgroundColor3 = Current.AccentSoft
    orb2.BackgroundTransparency = 0.9
    orb2.BorderSizePixel = 0
    newCorner(orb2, UDim.new(1, 0))

    task.spawn(function()
        local t = 0
        while mainFrame.Parent do
            t += task.wait(0.033)
            orb1.Position = UDim2.new(-0.3 + math.sin(t * 0.6) * 0.08, 0, -0.3 + math.cos(t * 0.5) * 0.08, 0)
            orb2.Position = UDim2.new(0.9 + math.cos(t * 0.4) * 0.06, 0, 0.8 + math.sin(t * 0.7) * 0.06, 0)
        end
    end)

    -- Linha de glow correndo no topo
    local topGlow = Instance.new("Frame", mainFrame)
    topGlow.Size = UDim2.new(0, 130, 0, 2)
    topGlow.Position = UDim2.new(0, 0, 0, 0)
    topGlow.BackgroundColor3 = Current.AccentHi
    topGlow.BorderSizePixel = 0
    topGlow.ZIndex = 6
    newCorner(topGlow, UDim.new(0, 3))

    task.spawn(function()
        while topGlow.Parent do
            topGlow.Position = UDim2.new(0, -130, 0, 0)
            tw(topGlow, 2.8, { Position = UDim2.new(1, 0, 0, 0) }, Enum.EasingStyle.Linear)
            task.wait(2.8)
        end
    end)

    -- ═══ TITLE BAR (NINOMAX com NINO branco + MAX vermelho)
    local titleBar = Instance.new("Frame", mainFrame)
    titleBar.Size = UDim2.new(1, 0, 0, 34)
    titleBar.BackgroundTransparency = 1
    titleBar.ZIndex = 5

    -- Título NINOMAX com 2 cores (usa dois TextLabels sobrepostos)
    local titleNino = Instance.new("TextLabel", titleBar)
    titleNino.BackgroundTransparency = 1
    titleNino.Position = UDim2.new(0, 14, 0, 2)
    titleNino.Size = UDim2.new(0, 200, 1, 0)
    titleNino.Font = Enum.Font.GothamBlack
    titleNino.TextSize = 18
    titleNino.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleNino.TextXAlignment = Enum.TextXAlignment.Left
    titleNino.TextYAlignment = Enum.TextYAlignment.Center
    titleNino.Text = "NINO"
    titleNino.ZIndex = 6

    -- Glow atrás do NINO
    local ninoGlow = Instance.new("UIStroke", titleNino)
    ninoGlow.Color = Color3.fromRGB(255, 255, 255)
    ninoGlow.Thickness = 0
    ninoGlow.Transparency = 1

    task.spawn(function()
        while titleNino.Parent do
            tw(ninoGlow, 2, { Transparency = 0.7, Thickness = 2 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(2)
            tw(ninoGlow, 2, { Transparency = 1, Thickness = 0 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(2)
        end
    end)

    -- MAX na cor vermelha (posicionado após NINO)
    local titleMax = Instance.new("TextLabel", titleBar)
    titleMax.BackgroundTransparency = 1
    titleMax.Position = UDim2.new(0, 14, 0, 2)
    titleMax.Size = UDim2.new(0, 200, 1, 0)
    titleMax.Font = Enum.Font.GothamBlack
    titleMax.TextSize = 18
    titleMax.TextColor3 = Current.AccentHi
    titleMax.TextXAlignment = Enum.TextXAlignment.Left
    titleMax.TextYAlignment = Enum.TextYAlignment.Center
    titleMax.Text = ""
    titleMax.ZIndex = 6

    task.defer(function()
        local w = titleNino.TextBounds.X
        titleMax.Text = string.rep(" ", math.floor(w / (titleMax.TextSize * 0.5))) .. "MAX"
        titleMax.Position = UDim2.new(0, 14 + w, 0, 2)
    end)

    -- Glow vermelho atrás do MAX
    local maxGlow = Instance.new("UIStroke", titleMax)
    maxGlow.Color = Current.AccentHi
    maxGlow.Thickness = 1
    maxGlow.Transparency = 0.5

    task.spawn(function()
        while titleMax.Parent do
            tw(maxGlow, 1.4, { Transparency = 0.9 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.4)
            tw(maxGlow, 1.4, { Transparency = 0.3 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.4)
        end
    end)

    -- Subtitle editável
    local subtitle = Instance.new("TextLabel", titleBar)
    subtitle.BackgroundTransparency = 1
    subtitle.Position = UDim2.new(0, 14, 0, 20)
    subtitle.Size = UDim2.new(0, 200, 0, 10)
    subtitle.Font = Enum.Font.GothamMedium
    subtitle.TextSize = 9
    subtitle.TextColor3 = Current.TextMute
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Text = SUBTITLE_TEXT
    subtitle.ZIndex = 6

    task.defer(function()
        local w1 = titleNino.TextBounds.X
        local w2 = titleMax.TextBounds.X
        subtitle.Position = UDim2.new(0, 14 + w1 + w2 + 8, 0, 20)
    end)

    -- Botão fechar
    local closeBtn = Instance.new("TextButton", titleBar)
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -32, 0, 5)
    closeBtn.BackgroundColor3 = Current.Surface
    closeBtn.BackgroundTransparency = 0.5
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Current.TextDim
    closeBtn.TextSize = 13
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.AutoButtonColor = false
    closeBtn.BorderSizePixel = 0
    closeBtn.ZIndex = 7
    newCorner(closeBtn, UDim.new(0, 6))
    local closeStroke = newStroke(closeBtn, Current.Border, 1, 0.4)

    closeBtn.MouseEnter:Connect(function()
        tw(closeBtn, 0.2, { BackgroundColor3 = Current.Danger, BackgroundTransparency = 0.1 })
        tw(closeStroke, 0.2, { Color = Current.Danger, Transparency = 0 })
    end)
    closeBtn.MouseLeave:Connect(function()
        tw(closeBtn, 0.2, { BackgroundColor3 = Current.Surface, BackgroundTransparency = 0.5 })
        tw(closeStroke, 0.2, { Color = Current.Border, Transparency = 0.4 })
    end)

    -- Botão minimizar
    local minBtn = Instance.new("TextButton", titleBar)
    minBtn.Size = UDim2.new(0, 24, 0, 24)
    minBtn.Position = UDim2.new(1, -60, 0, 5)
    minBtn.BackgroundColor3 = Current.Surface
    minBtn.BackgroundTransparency = 0.5
    minBtn.Text = "−"
    minBtn.TextColor3 = Current.TextDim
    minBtn.TextSize = 16
    minBtn.Font = Enum.Font.GothamBold
    minBtn.AutoButtonColor = false
    minBtn.BorderSizePixel = 0
    minBtn.ZIndex = 7
    newCorner(minBtn, UDim.new(0, 6))
    local minStroke = newStroke(minBtn, Current.Border, 1, 0.4)

    minBtn.MouseEnter:Connect(function()
        tw(minBtn, 0.2, { BackgroundColor3 = Current.AccentSoft, BackgroundTransparency = 0.1 })
        tw(minStroke, 0.2, { Color = Current.Accent, Transparency = 0 })
    end)
    minBtn.MouseLeave:Connect(function()
        tw(minBtn, 0.2, { BackgroundColor3 = Current.Surface, BackgroundTransparency = 0.5 })
        tw(minStroke, 0.2, { Color = Current.Border, Transparency = 0.4 })
    end)

    makeDraggable(mainFrame, titleBar)

    -- Linha separadora
    local sepLine = Instance.new("Frame", mainFrame)
    sepLine.Size = UDim2.new(1, 0, 0, 1)
    sepLine.Position = UDim2.new(0, 0, 0, 34)
    sepLine.BackgroundColor3 = Current.Accent
    sepLine.BackgroundTransparency = 0.4
    sepLine.BorderSizePixel = 0
    sepLine.ZIndex = 4

    -- ═══ SIDEBAR
    local sidebar = Instance.new("ScrollingFrame", mainFrame)
    sidebar.Size = UDim2.new(0.26, 0, 1, -34)
    sidebar.Position = UDim2.new(0, 0, 0, 34)
    sidebar.BackgroundColor3 = Current.BgSolid
    sidebar.BackgroundTransparency = 0.3
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebar.ScrollBarThickness = 3
    sidebar.ScrollBarImageColor3 = Current.Accent
    sidebar.BorderSizePixel = 0
    sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
    sidebar.ZIndex = 2
    newCorner(sidebar, UDim.new(0, 4))

    local sideLayout = Instance.new("UIListLayout", sidebar)
    sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sideLayout.Padding = UDim.new(0, 3)
    newPad(sidebar, 5, 5, 5, 5)

    -- Search bar
    local searchBox = Instance.new("TextBox", sidebar)
    searchBox.Size = UDim2.new(1, 0, 0, 26)
    searchBox.BackgroundColor3 = Current.Surface
    searchBox.BorderSizePixel = 0
    searchBox.PlaceholderText = "🔍  Buscar tab..."
    searchBox.PlaceholderColor3 = Current.TextMute
    searchBox.TextColor3 = Current.Text
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 11
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus = false
    searchBox.LayoutOrder = -1
    newCorner(searchBox, UDim.new(0, 6))
    local searchStroke = newStroke(searchBox, Current.Border, 1, 0.5)
    newPad(searchBox, 0, 8, 0, 8)

    local tabBtns, pages, selectedTab = {}, {}, nil

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = string.lower(searchBox.Text)
        for name, btn in pairs(tabBtns) do
            btn.Visible = (q == "") or (string.find(string.lower(name), q, 1, true) ~= nil)
        end
    end)

    -- ═══ CONTENT HOLDER
    local contentHolder = Instance.new("ScrollingFrame", mainFrame)
    contentHolder.Position = UDim2.new(0.26, 4, 0, 38)
    contentHolder.Size = UDim2.new(0.74, -8, 1, -42)
    contentHolder.BackgroundTransparency = 1
    contentHolder.BorderSizePixel = 0
    contentHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentHolder.ScrollBarThickness = 4
    contentHolder.ScrollBarImageColor3 = Current.Accent
    contentHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentHolder.ZIndex = 2

    -- ═══ RESIZE HANDLE
    local resizeHandle = Instance.new("TextButton", mainFrame)
    resizeHandle.Size = UDim2.new(0, 18, 0, 18)
    resizeHandle.Position = UDim2.new(1, -22, 1, -22)
    resizeHandle.BackgroundColor3 = Current.Surface
    resizeHandle.BackgroundTransparency = 0.35
    resizeHandle.Text = "◢"
    resizeHandle.TextColor3 = Current.TextDim
    resizeHandle.TextSize = 13
    resizeHandle.Font = Enum.Font.GothamBold
    resizeHandle.AutoButtonColor = false
    resizeHandle.ZIndex = 20
    newCorner(resizeHandle, UDim.new(0, 5))
    local resizeStroke = newStroke(resizeHandle, Current.Border, 1.2, 0.35)

    do
        local drag, startSize, startPos
        resizeHandle.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drag = true; startSize = mainFrame.AbsoluteSize; startPos = i.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - startPos
                local w = math.clamp(startSize.X + d.X, MIN_SIZE.X, MAX_SIZE.X)
                local h = math.clamp(startSize.Y + d.Y, MIN_SIZE.Y, MAX_SIZE.Y)
                mainFrame.Size = UDim2.new(0, w, 0, h)
                currentSize = Vector2.new(w, h)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drag = false
            end
        end)
    end

    -- Sync sombra
    RunService.RenderStepped:Connect(function()
        if not mainFrame.Parent then return end
        shadowHolder.Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset,
                                           mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset + 2)
        shadowHolder.Size = UDim2.new(0, mainFrame.AbsoluteSize.X + 6, 0, mainFrame.AbsoluteSize.Y + 6)
    end)

    -- ═══ THEME BINDINGS
    onTheme(function()
        tw(mainFrame, 0.4, { BackgroundColor3 = Current.Bg })
        tw(mainStroke, 0.4, { Color = Current.Accent })
        tw(mainGrad, 0.4, { Color = ColorSequence.new(Current.BgSolid, Current.Bg) })
        tw(topGlow, 0.4, { BackgroundColor3 = Current.AccentHi })
        tw(orb1, 0.5, { BackgroundColor3 = Current.Accent })
        tw(orb2, 0.5, { BackgroundColor3 = Current.AccentSoft })
        tw(sepLine, 0.4, { BackgroundColor3 = Current.Accent })
        tw(sidebar, 0.4, { BackgroundColor3 = Current.BgSolid, ScrollBarImageColor3 = Current.Accent })
        tw(contentHolder, 0.4, { ScrollBarImageColor3 = Current.Accent })
        tw(titleMax, 0.4, { TextColor3 = Current.AccentHi })
        tw(maxGlow, 0.4, { Color = Current.AccentHi })
        tw(subtitle, 0.4, { TextColor3 = Current.TextMute })
        for _, c in ipairs(gridHolder:GetChildren()) do
            if c:IsA("Frame") then tw(c, 0.4, { BackgroundColor3 = Current.Border }) end
        end
    end)

    -- ═══ ENTRY ANIMATION (cascade)
    task.spawn(function()
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        mainFrame.BackgroundTransparency = 1
        shadowImg.ImageTransparency = 1

        task.wait(0.05)
        mainFrame.Size = UDim2.new(0, currentSize.X - 40, 0, currentSize.Y - 24)
        tw(mainFrame, 0.55, { Size = UDim2.new(0, currentSize.X, 0, currentSize.Y) }, Enum.EasingStyle.Back)
        tw(mainFrame, 0.4, { BackgroundTransparency = 0 })
        tw(shadowImg, 0.5, { ImageTransparency = 0.5 })

        sidebar.Position = UDim2.new(0, -60, 0, 34)
        task.wait(0.15)
        tw(sidebar, 0.45, { Position = UDim2.new(0, 0, 0, 34) })

        titleBar.Position = UDim2.new(0, -50, 0, 0)
        tw(titleBar, 0.4, { Position = UDim2.new(0, 0, 0, 0) })

        task.wait(0.1)
        contentHolder.Position = UDim2.new(0.26, 20, 0, 38)
        tw(contentHolder, 0.4, { Position = UDim2.new(0.26, 4, 0, 38) })
    end)

    -- ═══ HIDE / SHOW
    local isHidden = false
    local function doHide()
        if isHidden then return end
        isHidden = true
        local fs = mainFrame.AbsoluteSize
        currentSize = Vector2.new(fs.X, fs.Y)
        tw(mainFrame, 0.25, { Size = UDim2.new(0, currentSize.X, 0, 10), BackgroundTransparency = 0.4 },
            Enum.EasingStyle.Back, Enum.EasingDirection.In)
        tw(shadowImg, 0.25, { ImageTransparency = 1 })
        task.delay(0.25, function()
            mainFrame.Visible = false
            mainFrame.Size = UDim2.new(0, currentSize.X, 0, currentSize.Y)
            mainFrame.BackgroundTransparency = 0
        end)
    end
    local function doShow()
        if not isHidden then return end
        isHidden = false
        mainFrame.Visible = true
        mainFrame.Size = UDim2.new(0, currentSize.X, 0, 10)
        mainFrame.BackgroundTransparency = 0.4
        tw(mainFrame, 0.4, { Size = UDim2.new(0, currentSize.X, 0, currentSize.Y), BackgroundTransparency = 0 },
            Enum.EasingStyle.Back)
        tw(shadowImg, 0.4, { ImageTransparency = 0.5 })
    end

    closeBtn.MouseButton1Click:Connect(function()
        Window:Dialog({
            Title = "Fechar NINOMAX?",
            Text = "Deseja realmente fechar a interface?",
            Buttons = {
                { "Confirmar", function()
                    tw(mainFrame, 0.3, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                    tw(shadowImg, 0.3, { ImageTransparency = 1 })
                    task.delay(0.35, function() gui:Destroy() end)
                end },
                { "Cancelar", function() end },
            }
        })
    end)
    minBtn.MouseButton1Click:Connect(function()
        if isHidden then doShow() else doHide() end
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            if isHidden then doShow() else doHide() end
        end
    end)

    -- ═══ TAB SWITCH
    local function switchTab(name)
        for tn, f in pairs(pages) do
            local active = (tn == name)
            f.Visible = active
            if active then
                f.Position = UDim2.new(0, 20, 0, 0)
                tw(f, 0.28, { Position = UDim2.new(0, 0, 0, 0) })
            end
        end
        for tn, btn in pairs(tabBtns) do
            local marker = btn:FindFirstChild("TabMarker")
            if marker then marker.Visible = (tn == name) end
            tw(btn, 0.2, { BackgroundColor3 = (tn == name) and Current.SurfaceHi or Current.Surface })
        end
        selectedTab = name
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE TAB
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateTab(tabName, iconName)
        local tabBtn = Instance.new("TextButton", sidebar)
        tabBtn.Size = UDim2.new(1, 0, 0, 32)
        tabBtn.Text = ""
        tabBtn.BackgroundColor3 = Current.Surface
        tabBtn.AutoButtonColor = false
        tabBtn.ClipsDescendants = true
        newCorner(tabBtn, UDim.new(0, 6))
        local tabStroke = newStroke(tabBtn, Current.Border, 1, 0.6)

        local marker = Instance.new("Frame", tabBtn)
        marker.Name = "TabMarker"
        marker.Size = UDim2.new(0, 3, 1, -8)
        marker.Position = UDim2.new(0, 0, 0, 4)
        marker.BackgroundColor3 = Current.AccentHi
        marker.BorderSizePixel = 0
        marker.Visible = false
        newCorner(marker, UDim.new(0, 4))

        local iconImg
        if iconName then
            iconImg = Instance.new("ImageLabel", tabBtn)
            iconImg.Size = UDim2.new(0, 14, 0, 14)
            iconImg.Position = UDim2.new(0, 8, 0.5, -7)
            iconImg.BackgroundTransparency = 1
            iconImg.Image = getIcon(iconName)
            iconImg.ImageColor3 = Current.TextMute
        end

        local label = Instance.new("TextLabel", tabBtn)
        label.BackgroundTransparency = 1
        label.Text = tabName
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 12
        label.TextColor3 = Current.Text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Position = iconImg and UDim2.new(0, 28, 0, 0) or UDim2.new(0, 12, 0, 0)
        label.Size = iconImg and UDim2.new(1, -30, 1, 0) or UDim2.new(1, -12, 1, 0)
        label.TextTruncate = Enum.TextTruncate.AtEnd

        tabBtns[tabName] = tabBtn

        onTheme(function()
            if selectedTab == tabName then
                tw(tabBtn, 0.35, { BackgroundColor3 = Current.SurfaceHi })
            else
                tw(tabBtn, 0.35, { BackgroundColor3 = Current.Surface })
            end
            tw(tabStroke, 0.35, { Color = Current.Border })
            tw(marker, 0.35, { BackgroundColor3 = Current.AccentHi })
            tw(label, 0.35, { TextColor3 = Current.Text })
            if iconImg then tw(iconImg, 0.35, { ImageColor3 = Current.TextMute }) end
        end)

        tabBtn.MouseEnter:Connect(function()
            if selectedTab ~= tabName then
                tw(tabBtn, 0.2, { BackgroundColor3 = Current.SurfaceHi })
                if iconImg then tw(iconImg, 0.2, { ImageColor3 = Current.Text }) end
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if selectedTab ~= tabName then
                tw(tabBtn, 0.2, { BackgroundColor3 = Current.Surface })
                if iconImg then tw(iconImg, 0.2, { ImageColor3 = Current.TextMute }) end
            end
        end)

        local page = Instance.new("Frame", contentHolder)
        page.Name = tabName
        page.Size = UDim2.new(1, 0, 0, 1000)
        page.BackgroundTransparency = 1
        page.Visible = false
        local layout = Instance.new("UIListLayout", page)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)
        newPad(page, 4, 8, 8, 4)
        pages[tabName] = page

        tabBtn.MouseButton1Click:Connect(function()
            for n, b in pairs(tabBtns) do
                if n == tabName then
                    tw(b, 0.15, { BackgroundColor3 = Current.SurfaceHi })
                    tw(b, 0.12, { Size = UDim2.new(1, 0, 0, 36) })
                    task.delay(0.12, function() tw(b, 0.15, { Size = UDim2.new(1, 0, 0, 32) }, Enum.EasingStyle.Back) end)
                    b.TabMarker.Visible = true
                else
                    tw(b, 0.2, { BackgroundColor3 = Current.Surface })
                    b.TabMarker.Visible = false
                end
            end
            switchTab(tabName)
        end)

        if not selectedTab then switchTab(tabName) end

        local Tab = {}

        -- ═══════════════ RIPPLE HELPER
        local function addRipple(parent, x, y)
            local r = Instance.new("Frame", parent)
            r.AnchorPoint = Vector2.new(0.5, 0.5)
            r.Position = UDim2.new(0, x or parent.AbsoluteSize.X/2, 0, y or parent.AbsoluteSize.Y/2)
            r.Size = UDim2.new(0, 0, 0, 0)
            r.BackgroundColor3 = Color3.new(1, 1, 1)
            r.BackgroundTransparency = 0.75
            r.BorderSizePixel = 0
            r.ZIndex = 2
            newCorner(r, UDim.new(1, 0))
            local t = tw(r, 0.55, { Size = UDim2.new(0, parent.AbsoluteSize.X * 2.5, 0, parent.AbsoluteSize.X * 2.5), BackgroundTransparency = 1 }, Enum.EasingStyle.Quart)
            t.Completed:Connect(function() r:Destroy() end)
        end

        -- ═══════════════ CREATE SECTION
        function Tab:CreateSection(title)
            local section = Instance.new("Frame", page)
            section.Size = UDim2.new(1, -20, 0, 26)
            section.Position = UDim2.new(0, 10, 0, 0)
            section.BackgroundTransparency = 1

            local dot = Instance.new("Frame", section)
            dot.Size = UDim2.new(0, 6, 0, 6)
            dot.Position = UDim2.new(0, 2, 0.5, -3)
            dot.BackgroundColor3 = Current.AccentHi
            dot.BorderSizePixel = 0
            newCorner(dot, UDim.new(1, 0))
            local dotGlow = newStroke(dot, Current.AccentHi, 2, 0.3)

            local lbl = Instance.new("TextLabel", section)
            lbl.BackgroundTransparency = 1
            lbl.Text = string.upper(title or "SECTION")
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 13
            lbl.TextColor3 = Current.Text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Position = UDim2.new(0, 16, 0, 0)
            lbl.Size = UDim2.new(1, -20, 1, 0)

            local underline = Instance.new("Frame", section)
            underline.Size = UDim2.new(1, -20, 0, 1)
            underline.Position = UDim2.new(0, 10, 1, -3)
            underline.BackgroundColor3 = Current.Border
            underline.BorderSizePixel = 0
            local ug = Instance.new("UIGradient", underline)
            ug.Transparency = NumberSequence.new(0, 1)

            task.spawn(function()
                while dot.Parent do
                    tw(dotGlow, 1.2, { Transparency = 0.9 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                    task.wait(1.2)
                    tw(dotGlow, 1.2, { Transparency = 0.2 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                    task.wait(1.2)
                end
            end)

            onTheme(function()
                tw(dot, 0.35, { BackgroundColor3 = Current.AccentHi })
                tw(lbl, 0.35, { TextColor3 = Current.Text })
                tw(underline, 0.35, { BackgroundColor3 = Current.Border })
            end)

            return {
                Set = function(_, newText) lbl.Text = string.upper(newText) end,
                Destroy = function() section:Destroy() end,
            }
        end

        -- ═══════════════ CREATE LABEL
        function Tab:CreateLabel(text)
            local lbl = Instance.new("TextLabel", page)
            lbl.Size = UDim2.new(1, -20, 0, 20)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = text or ""
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 12
            lbl.TextColor3 = Current.TextDim
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextWrapped = true
            onTheme(function() tw(lbl, 0.35, { TextColor3 = Current.TextDim }) end)
            return {
                Set = function(_, v) lbl.Text = tostring(v) end,
                Destroy = function() lbl:Destroy() end,
            }
        end

        -- ═══════════════ CREATE PARAGRAPH
        function Tab:CreateParagraph(cfg)
            cfg = cfg or {}
            local box = Instance.new("Frame", page)
            box.Size = UDim2.new(1, -20, 0, 54)
            box.Position = UDim2.new(0, 10, 0, 0)
            box.BackgroundColor3 = Current.Surface
            box.BorderSizePixel = 0
            newCorner(box, UDim.new(0, 8))
            local bs = newStroke(box, Current.Border, 1, 0.5)

            local title = Instance.new("TextLabel", box)
            title.BackgroundTransparency = 1
            title.Text = cfg.Title or "Paragraph"
            title.Font = Enum.Font.GothamBold
            title.TextSize = 13
            title.TextColor3 = Current.Text
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.Position = UDim2.new(0, 12, 0, 6)
            title.Size = UDim2.new(1, -20, 0, 16)

            local txt = Instance.new("TextLabel", box)
            txt.BackgroundTransparency = 1
            txt.Text = cfg.Text or ""
            txt.Font = Enum.Font.Gotham
            txt.TextSize = 11
            txt.TextColor3 = Current.TextMute
            txt.TextXAlignment = Enum.TextXAlignment.Left
            txt.TextYAlignment = Enum.TextYAlignment.Top
            txt.TextWrapped = true
            txt.Position = UDim2.new(0, 12, 0, 24)
            txt.Size = UDim2.new(1, -20, 1, -30)

            onTheme(function()
                tw(box, 0.35, { BackgroundColor3 = Current.Surface })
                tw(bs, 0.35, { Color = Current.Border })
                tw(title, 0.35, { TextColor3 = Current.Text })
                tw(txt, 0.35, { TextColor3 = Current.TextMute })
            end)

            return {
                SetTitle = function(_, v) title.Text = tostring(v) end,
                SetDesc = function(_, v) txt.Text = tostring(v) end,
                Destroy = function() box:Destroy() end,
            }
        end

        -- ═══════════════ CREATE BUTTON
        function Tab:CreateButton(cfg)
            cfg = cfg or {}
            if type(cfg) == "string" then cfg = { Title = cfg } end
            local label = cfg.Title or cfg.Name or "Button"
            local desc = cfg.Description or cfg.Desc or ""
            local cb = cfg.Callback or function() end
            local cooldown = cfg.Cooldown or 0.6

            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(1, -20, 0, desc ~= "" and 46 or 34)
            btn.Position = UDim2.new(0, 10, 0, 0)
            btn.Text = ""
            btn.AutoButtonColor = false
            btn.ClipsDescendants = true
            btn.BackgroundColor3 = Current.SurfaceHi
            newCorner(btn, UDim.new(0, 7))
            local bs = newStroke(btn, Current.Border, 1, 0.5)

            local bgGrad = Instance.new("UIGradient", btn)
            bgGrad.Rotation = 90
            bgGrad.Color = ColorSequence.new(Current.SurfaceHi, mix(Current.SurfaceHi, Current.Accent, 0.08))

            local accentBar = Instance.new("Frame", btn)
            accentBar.Size = UDim2.new(0, 3, 1, 0)
            accentBar.BackgroundColor3 = Current.Accent
            accentBar.BorderSizePixel = 0

            local txtLbl = Instance.new("TextLabel", btn)
            txtLbl.BackgroundTransparency = 1
            txtLbl.Text = label
            txtLbl.Font = Enum.Font.GothamMedium
            txtLbl.TextSize = 14
            txtLbl.TextColor3 = Current.Text
            txtLbl.TextXAlignment = Enum.TextXAlignment.Left
            txtLbl.Position = UDim2.new(0, 14, 0, desc ~= "" and 6 or 0)
            txtLbl.Size = UDim2.new(1, -20, 0, desc ~= "" and 16 or 34)
            txtLbl.TextTruncate = Enum.TextTruncate.AtEnd

            local descLbl
            if desc ~= "" then
                descLbl = Instance.new("TextLabel", btn)
                descLbl.BackgroundTransparency = 1
                descLbl.Text = desc
                descLbl.Font = Enum.Font.Gotham
                descLbl.TextSize = 11
                descLbl.TextColor3 = Current.TextMute
                descLbl.TextXAlignment = Enum.TextXAlignment.Left
                descLbl.Position = UDim2.new(0, 14, 0, 24)
                descLbl.Size = UDim2.new(1, -20, 0, 14)
            end

            -- Shine
            local shine = Instance.new("Frame", btn)
            shine.Size = UDim2.new(0, 60, 1, 0)
            shine.Position = UDim2.new(-0.3, 0, 0, 0)
            shine.BackgroundColor3 = Color3.new(1, 1, 1)
            shine.BackgroundTransparency = 0.88
            shine.BorderSizePixel = 0
            shine.ZIndex = 4
            local sg = Instance.new("UIGradient", shine)
            sg.Transparency = NumberSequence.new(1, 0, 1)

            onTheme(function()
                tw(btn, 0.35, { BackgroundColor3 = Current.SurfaceHi })
                tw(bs, 0.35, { Color = Current.Border })
                tw(accentBar, 0.35, { BackgroundColor3 = Current.Accent })
                tw(bgGrad, 0.35, { Color = ColorSequence.new(Current.SurfaceHi, mix(Current.SurfaceHi, Current.Accent, 0.08)) })
                tw(txtLbl, 0.35, { TextColor3 = Current.Text })
                if descLbl then tw(descLbl, 0.35, { TextColor3 = Current.TextMute }) end
            end)

            local cooling = false

            btn.MouseEnter:Connect(function()
                tw(btn, 0.2, { BackgroundColor3 = mix(Current.SurfaceHi, Current.Accent, 0.18) })
                tw(bs, 0.2, { Color = Current.AccentHi, Transparency = 0.15 })
                tw(accentBar, 0.2, { Size = UDim2.new(0, 6, 1, 0) })
                shine.Position = UDim2.new(-0.3, 0, 0, 0)
                tw(shine, 0.7, { Position = UDim2.new(1.2, 0, 0, 0) }, Enum.EasingStyle.Quart)
            end)
            btn.MouseLeave:Connect(function()
                tw(btn, 0.2, { BackgroundColor3 = Current.SurfaceHi })
                tw(bs, 0.2, { Color = Current.Border, Transparency = 0.5 })
                tw(accentBar, 0.2, { Size = UDim2.new(0, 3, 1, 0) })
            end)
            btn.MouseButton1Down:Connect(function()
                local mx = UserInputService:GetMouseLocation().X - btn.AbsolutePosition.X
                local my = UserInputService:GetMouseLocation().Y - btn.AbsolutePosition.Y
                addRipple(btn, mx, my)
            end)
            btn.MouseButton1Click:Connect(function()
                if cooling then return end
                cooling = true
                -- flash
                local flash = Instance.new("Frame", btn)
                flash.Size = UDim2.new(1, 0, 1, 0)
                flash.BackgroundColor3 = Current.Success
                flash.BackgroundTransparency = 0.7
                flash.BorderSizePixel = 0
                flash.ZIndex = 1
                newCorner(flash, UDim.new(0, 7))
                tw(flash, 0.5, { BackgroundTransparency = 1 })
                task.delay(0.5, function() flash:Destroy() end)

                tw(btn, 0.08, { Size = UDim2.new(1, -22, 0, btn.Size.Y.Offset - 2) })
                task.delay(0.08, function()
                    tw(btn, 0.15, { Size = UDim2.new(1, -20, 0, btn.Size.Y.Offset) }, Enum.EasingStyle.Back)
                end)

                pcall(cb)
                task.delay(cooldown, function() cooling = false end)
            end)

            return {
                Set = function(_, v) txtLbl.Text = tostring(v) end,
                Destroy = function() btn:Destroy() end,
            }
        end

        -- ═══════════════ CREATE TOGGLE
        function Tab:CreateToggle(cfg)
            cfg = cfg or {}
            if type(cfg) == "string" then cfg = { Title = cfg } end
            local label = cfg.Title or cfg.Name or "Toggle"
            local desc = cfg.Description or cfg.Desc or ""
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag
            local default = cfg.Default or false
            if flag and NINOMAX.Flags[flag] ~= nil then default = NINOMAX.Flags[flag] end

            local f = Instance.new("Frame", page)
            f.Size = UDim2.new(1, -20, 0, desc ~= "" and 50 or 40)
            f.Position = UDim2.new(0, 10, 0, 0)
            f.BackgroundColor3 = Current.Surface
            f.BorderSizePixel = 0
            f.ClipsDescendants = true
            newCorner(f, UDim.new(0, 8))
            local fs = newStroke(f, Current.Border, 1, 0.6)

            local title = Instance.new("TextLabel", f)
            title.BackgroundTransparency = 1
            title.Text = label
            title.Font = Enum.Font.GothamMedium
            title.TextSize = 14
            title.TextColor3 = Current.Text
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.Position = UDim2.new(0, 12, 0, desc ~= "" and 5 or 0)
            title.Size = UDim2.new(1, -70, 0, desc ~= "" and 16 or 40)
            title.TextYAlignment = desc ~= "" and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center

            local descLbl
            if desc ~= "" then
                descLbl = Instance.new("TextLabel", f)
                descLbl.BackgroundTransparency = 1
                descLbl.Text = desc
                descLbl.Font = Enum.Font.Gotham
                descLbl.TextSize = 11
                descLbl.TextColor3 = Current.TextMute
                descLbl.TextXAlignment = Enum.TextXAlignment.Left
                descLbl.Position = UDim2.new(0, 12, 0, 24)
                descLbl.Size = UDim2.new(1, -70, 0, 14)
            end

            local sw = Instance.new("Frame", f)
            sw.Size = UDim2.new(0, 44, 0, 24)
            sw.Position = UDim2.new(1, -56, 0.5, -12)
            sw.BackgroundColor3 = Current.SurfaceLow
            sw.BorderSizePixel = 0
            newCorner(sw, UDim.new(1, 0))
            local swStroke = newStroke(sw, Current.Border, 1, 0.5)

            local ball = Instance.new("Frame", sw)
            ball.Size = UDim2.new(0, 18, 0, 18)
            ball.Position = UDim2.new(0, 3, 0.5, -9)
            ball.BackgroundColor3 = Color3.fromRGB(210, 210, 215)
            ball.BorderSizePixel = 0
            newCorner(ball, UDim.new(1, 0))
            local ballStroke = newStroke(ball, Current.Border, 1, 0.4)

            local glowFrame = Instance.new("Frame", sw)
            glowFrame.Size = UDim2.new(1, 0, 1, 0)
            glowFrame.BackgroundColor3 = Current.Accent
            glowFrame.BackgroundTransparency = 1
            glowFrame.BorderSizePixel = 0
            newCorner(glowFrame, UDim.new(1, 0))
            glowFrame.ZIndex = 0

            local btn = Instance.new("TextButton", f)
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.ZIndex = 5

            local isOn = default
            local cooling = false

            local function applyState(v, silent)
                isOn = v
                local bg = isOn and Current.Accent or Current.SurfaceLow
                local bp = isOn and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
                local bc = isOn and Color3.new(1, 1, 1) or Color3.fromRGB(210, 210, 215)
                tw(sw, 0.3, { BackgroundColor3 = bg }, Enum.EasingStyle.Back)
                tw(ball, 0.32, { Position = bp, BackgroundColor3 = bc }, Enum.EasingStyle.Back)
                tw(glowFrame, 0.3, { BackgroundTransparency = isOn and 0.7 or 1 })
                if not silent then
                    if flag then NINOMAX:SetFlag(flag, isOn) end
                    pcall(cb, isOn)
                end
            end

            applyState(default, true)

            onTheme(function()
                tw(f, 0.35, { BackgroundColor3 = Current.Surface })
                tw(fs, 0.35, { Color = Current.Border })
                tw(title, 0.35, { TextColor3 = Current.Text })
                if descLbl then tw(descLbl, 0.35, { TextColor3 = Current.TextMute }) end
                if isOn then
                    tw(sw, 0.35, { BackgroundColor3 = Current.Accent })
                    tw(glowFrame, 0.35, { BackgroundColor3 = Current.Accent })
                else
                    tw(sw, 0.35, { BackgroundColor3 = Current.SurfaceLow })
                end
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
                tw(fs, 0.2, { Color = Current.AccentHi, Transparency = 0.25 })
            end)
            btn.MouseLeave:Connect(function()
                tw(fs, 0.2, { Color = Current.Border, Transparency = 0.6 })
            end)

            btn.MouseButton1Click:Connect(function()
                if cooling then return end
                cooling = true
                applyState(not isOn)
                -- flash
                if isOn then
                    local flash = Instance.new("Frame", sw)
                    flash.Size = UDim2.new(1, 0, 1, 0)
                    flash.BackgroundColor3 = Color3.new(1, 1, 1)
                    flash.BackgroundTransparency = 0.6
                    flash.BorderSizePixel = 0
                    flash.ZIndex = 5
                    newCorner(flash, UDim.new(1, 0))
                    tw(flash, 0.4, { BackgroundTransparency = 1 })
                    task.delay(0.4, function() flash:Destroy() end)
                end
                task.delay(0.3, function() cooling = false end)
            end)

            return {
                Set = function(_, v)
                    applyState(v, false)
                end,
                Get = function() return isOn end,
                Destroy = function() f:Destroy() end,
            }
        end

        -- ═══════════════ CREATE SLIDER
        function Tab:CreateSlider(cfg)
            cfg = cfg or {}
            local label = cfg.Title or cfg.Name or "Slider"
            local desc = cfg.Description or cfg.Desc or ""
            local min = cfg.Min or 0
            local max = cfg.Max or 100
            local default = cfg.Default or min
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag
            local suffix = cfg.Suffix or ""
            if flag and NINOMAX.Flags[flag] ~= nil then default = NINOMAX.Flags[flag] end

            local holder = Instance.new("Frame", page)
            holder.Size = UDim2.new(1, -20, 0, 0)
            holder.Position = UDim2.new(0, 10, 0, 0)
            holder.BackgroundTransparency = 1
            holder.AutomaticSize = Enum.AutomaticSize.Y
            local lay = Instance.new("UIListLayout", holder)

            local bg = Instance.new("Frame", holder)
            bg.Size = UDim2.new(1, 0, 0, 58)
            bg.BackgroundColor3 = Current.SurfaceLow
            bg.BorderSizePixel = 0
            newCorner(bg, UDim.new(0, 8))
            local bs = newStroke(bg, Current.Border, 1, 0.5)

            local t = Instance.new("TextLabel", bg)
            t.Size = UDim2.new(1, -60, 0, 16)
            t.Position = UDim2.new(0, 12, 0, 6)
            t.Text = label
            t.TextColor3 = Current.Text
            t.TextSize = 14
            t.Font = Enum.Font.GothamMedium
            t.BackgroundTransparency = 1
            t.TextXAlignment = Enum.TextXAlignment.Left

            local d
            if desc ~= "" then
                d = Instance.new("TextLabel", bg)
                d.Size = UDim2.new(1, -20, 0, 11)
                d.Position = UDim2.new(0, 12, 0, 24)
                d.Text = desc
                d.TextColor3 = Current.TextMute
                d.TextSize = 11
                d.Font = Enum.Font.Gotham
                d.BackgroundTransparency = 1
                d.TextXAlignment = Enum.TextXAlignment.Left
            end

            local vl = Instance.new("TextLabel", bg)
            vl.Size = UDim2.new(0, 60, 0, 16)
            vl.Position = UDim2.new(1, -72, 0, 6)
            vl.TextColor3 = Current.AccentHi
            vl.TextSize = 14
            vl.Font = Enum.Font.GothamBold
            vl.BackgroundTransparency = 1
            vl.TextXAlignment = Enum.TextXAlignment.Right

            local bar = Instance.new("Frame", bg)
            bar.Size = UDim2.new(1, -24, 0, 8)
            bar.Position = UDim2.new(0, 12, 0, 46)
            bar.BackgroundColor3 = Current.Surface
            bar.BorderSizePixel = 0
            newCorner(bar, UDim.new(1, 0))

            local fill = Instance.new("Frame", bar)
            fill.Size = UDim2.new(0, 0, 1, 0)
            fill.BackgroundColor3 = Current.Accent
            fill.BorderSizePixel = 0
            newCorner(fill, UDim.new(1, 0))
            local fg = Instance.new("UIGradient", fill)
            fg.Color = ColorSequence.new(Current.AccentSoft, Current.AccentHi)

            local fillStroke = Instance.new("UIStroke", fill)
            fillStroke.Thickness = 2
            fillStroke.Transparency = 0.4
            fillStroke.Color = Current.AccentHi

            local knob = Instance.new("Frame", bar)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Size = UDim2.new(0, 16, 0, 16)
            knob.Position = UDim2.new(0, 0, 0.5, 0)
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
            knob.BorderSizePixel = 0
            knob.ZIndex = 4
            newCorner(knob, UDim.new(1, 0))
            local knobStroke = newStroke(knob, Current.AccentHi, 2, 0.2)

            local knobGlow = Instance.new("ImageLabel", knob)
            knobGlow.Size = UDim2.new(1, 14, 1, 14)
            knobGlow.Position = UDim2.new(0, -7, 0, -7)
            knobGlow.BackgroundTransparency = 1
            knobGlow.Image = "rbxassetid://1316045217"
            knobGlow.ImageColor3 = Current.AccentHi
            knobGlow.ImageTransparency = 0.6
            knobGlow.ScaleType = Enum.ScaleType.Slice
            knobGlow.SliceCenter = Rect.new(10, 10, 118, 118)
            knobGlow.ZIndex = 3

            local function update(x)
                local bp = bar.AbsolutePosition.X
                local bw = bar.AbsoluteSize.X
                if bw <= 0 then return end
                local c = math.clamp((x - bp) / bw, 0, 1)
                local val = min + (max - min) * c
                if max - min > 20 then val = math.floor(val + 0.5) end
                fill.Size = UDim2.new(c, 0, 1, 0)
                knob.Position = UDim2.new(c, 0, 0.5, 0)
                vl.Text = tostring(val) .. suffix
                if flag then NINOMAX:SetFlag(flag, val) end
                pcall(cb, val)
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
            UserInputService.InputChanged:Connect(function(i)
                if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    update(i.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    drag = false
                    tw(knob, 0.2, { Size = UDim2.new(0, 16, 0, 16) }, Enum.EasingStyle.Back)
                    tw(knobGlow, 0.2, { ImageTransparency = 0.6 })
                end
            end)

            -- init
            task.defer(function()
                local bp = bar.AbsolutePosition.X
                local bw = bar.AbsoluteSize.X
                if bw > 0 then
                    local init = (default - min) / (max - min)
                    fill.Size = UDim2.new(init, 0, 1, 0)
                    knob.Position = UDim2.new(init, 0, 0.5, 0)
                    vl.Text = tostring(default) .. suffix
                end
            end)

            onTheme(function()
                tw(bg, 0.35, { BackgroundColor3 = Current.SurfaceLow })
                tw(bs, 0.35, { Color = Current.Border })
                tw(t, 0.35, { TextColor3 = Current.Text })
                if d then tw(d, 0.35, { TextColor3 = Current.TextMute }) end
                tw(fill, 0.35, { BackgroundColor3 = Current.Accent })
                tw(fg, 0.35, { Color = ColorSequence.new(Current.AccentSoft, Current.AccentHi) })
                tw(fillStroke, 0.35, { Color = Current.AccentHi })
                tw(knobStroke, 0.35, { Color = Current.AccentHi })
                tw(knobGlow, 0.35, { ImageColor3 = Current.AccentHi })
                tw(vl, 0.35, { TextColor3 = Current.AccentHi })
                tw(bar, 0.35, { BackgroundColor3 = Current.Surface })
            end)

            return {
                Set = function(_, v)
                    local c = math.clamp((v - min) / (max - min), 0, 1)
                    fill.Size = UDim2.new(c, 0, 1, 0)
                    knob.Position = UDim2.new(c, 0, 0.5, 0)
                    vl.Text = tostring(v) .. suffix
                    if flag then NINOMAX:SetFlag(flag, v) end
                    pcall(cb, v)
                end,
                Destroy = function() holder:Destroy() end,
            }
        end

        -- ═══════════════ CREATE DROPDOWN
        function Tab:CreateDropdown(cfg)
            cfg = cfg or {}
            local label = cfg.Title or cfg.Name or "Dropdown"
            local options = cfg.Options or {}
            local default = cfg.Default
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag
            local isMulti = cfg.Multi or cfg.MultiSelect or false
            if flag and NINOMAX.Flags[flag] ~= nil then default = NINOMAX.Flags[flag] end

            local f = Instance.new("Frame", page)
            f.Size = UDim2.new(1, -20, 0, 38)
            f.Position = UDim2.new(0, 10, 0, 0)
            f.BackgroundColor3 = Current.Surface
            f.BorderSizePixel = 0
            f.ZIndex = 5
            newCorner(f, UDim.new(0, 8))
            local fs = newStroke(f, Current.Border, 1, 0.5)

            local icon = Instance.new("TextLabel", f)
            icon.BackgroundTransparency = 1
            icon.Text = "☰"
            icon.TextColor3 = Current.TextMute
            icon.Font = Enum.Font.GothamBold
            icon.TextSize = 14
            icon.Position = UDim2.new(0, 10, 0.5, -8)
            icon.Size = UDim2.new(0, 16, 0, 16)

            local title = Instance.new("TextLabel", f)
            title.BackgroundTransparency = 1
            title.Text = label
            title.TextColor3 = Current.TextDim
            title.Font = Enum.Font.GothamSemibold
            title.TextSize = 14
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.Position = UDim2.new(0, 32, 0, 0)
            title.Size = UDim2.new(0.4, 0, 1, 0)

            local arrow = Instance.new("TextLabel", f)
            arrow.BackgroundTransparency = 1
            arrow.Text = "˅"
            arrow.TextColor3 = Current.TextDim
            arrow.Font = Enum.Font.GothamBold
            arrow.TextSize = 14
            arrow.Position = UDim2.new(1, -22, 0.5, -7)
            arrow.Size = UDim2.new(0, 14, 0, 14)

            local sel = Instance.new("TextLabel", f)
            sel.BackgroundTransparency = 1
            sel.Text = isMulti and "0 selecionados" or tostring(default or "Selecione")
            sel.TextColor3 = Current.Text
            sel.Font = Enum.Font.GothamBold
            sel.TextSize = 13
            sel.TextXAlignment = Enum.TextXAlignment.Right
            sel.TextTruncate = Enum.TextTruncate.AtEnd
            sel.Position = UDim2.new(0.5, 0, 0, 0)
            sel.Size = UDim2.new(0.45, -34, 1, 0)

            local btn = Instance.new("TextButton", f)
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.ZIndex = 10

            -- Dropdown list
            local list = Instance.new("Frame", page)
            list.Size = UDim2.new(1, -20, 0, 0)
            list.Position = UDim2.new(0, 10, 0, 0)
            list.BackgroundColor3 = Current.SurfaceLow
            list.Visible = false
            list.ClipsDescendants = true
            list.ZIndex = 20
            newCorner(list, UDim.new(0, 8))
            newStroke(list, Current.Border, 1, 0.4)

            local listScroll = Instance.new("ScrollingFrame", list)
            listScroll.Size = UDim2.new(1, 0, 1, 0)
            listScroll.BackgroundTransparency = 1
            listScroll.BorderSizePixel = 0
            listScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            listScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            listScroll.ScrollBarThickness = 3
            listScroll.ScrollBarImageColor3 = Current.Accent

            local listLayout = Instance.new("UIListLayout", listScroll)
            listLayout.Padding = UDim.new(0, 3)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            newPad(listScroll, 4, 4, 4, 4)

            local selected = isMulti and {} or default
            if isMulti and type(default) == "table" then
                for _, v in ipairs(default) do selected[v] = true end
            end

            local optionButtons = {}

            local function updateSelLabel()
                if isMulti then
                    local count = 0
                    for _ in pairs(selected) do count += 1 end
                    sel.Text = count .. " selecionados"
                else
                    sel.Text = tostring(selected or "Selecione")
                end
            end

            local function closeDropdown()
                arrow.Text = "˅"
                list:TweenSize(UDim2.new(1, -20, 0, 0), "In", "Back", 0.22, true)
                tw(fs, 0.25, { Color = Current.Border, Transparency = 0.5 })
                tw(icon, 0.25, { TextColor3 = Current.TextMute })
                task.delay(0.25, function() list.Visible = false end)
            end

            for i, opt in ipairs(options) do
                local o = Instance.new("TextButton", listScroll)
                o.Size = UDim2.new(1, 0, 0, 30)
                o.Text = ""
                o.BackgroundColor3 = Current.SurfaceHi
                o.AutoButtonColor = false
                o.ZIndex = 21
                o.LayoutOrder = i
                newCorner(o, UDim.new(0, 5))
                local os = newStroke(o, Current.Border, 1, 0.6)

                local dot = Instance.new("Frame", o)
                dot.Size = UDim2.new(0, 6, 0, 6)
                dot.Position = UDim2.new(0, 10, 0.5, -3)
                dot.BackgroundColor3 = Current.Accent
                dot.BorderSizePixel = 0
                dot.Visible = (not isMulti and selected == opt)
                newCorner(dot, UDim.new(1, 0))

                local lbl = Instance.new("TextLabel", o)
                lbl.BackgroundTransparency = 1
                lbl.Text = opt
                lbl.TextColor3 = Current.Text
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 13
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Position = UDim2.new(0, 24, 0, 0)
                lbl.Size = UDim2.new(1, -40, 1, 0)
                lbl.TextTruncate = Enum.TextTruncate.AtEnd

                local chk = Instance.new("TextLabel", o)
                chk.BackgroundTransparency = 1
                chk.Text = "✔"
                chk.TextColor3 = Current.AccentHi
                chk.Font = Enum.Font.GothamBold
                chk.TextSize = 14
                chk.Position = UDim2.new(1, -24, 0, 0)
                chk.Size = UDim2.new(0, 20, 1, 0)
                chk.Visible = (not isMulti and selected == opt) or (isMulti and selected[opt])

                optionButtons[opt] = { frame = o, dot = dot, chk = chk, stroke = os, label = lbl }

                o.MouseEnter:Connect(function()
                    tw(o, 0.15, { BackgroundColor3 = mix(Current.SurfaceHi, Current.Accent, 0.35) })
                end)
                o.MouseLeave:Connect(function()
                    tw(o, 0.15, { BackgroundColor3 = Current.SurfaceHi })
                end)
                o.MouseButton1Click:Connect(function()
                    if isMulti then
                        selected[opt] = not selected[opt]
                        chk.Visible = selected[opt]
                        dot.Visible = selected[opt]
                    else
                        for _, v in pairs(optionButtons) do
                            v.dot.Visible = false
                            v.chk.Visible = false
                        end
                        dot.Visible = true
                        chk.Visible = true
                        selected = opt
                    end
                    updateSelLabel()
                    if flag then NINOMAX:SetFlag(flag, selected) end
                    pcall(cb, isMulti and selected or opt)
                    if not isMulti then closeDropdown() end
                end)
            end

            btn.MouseButton1Click:Connect(function()
                list.Visible = true
                local isOpen = list.Size.Y.Offset == 0
                arrow.Text = isOpen and "˄" or "˅"
                local targetH = isOpen and math.min(#options * 34 + 12, 240) or 0
                list:TweenSize(UDim2.new(1, -20, 0, targetH), "Out", "Back", 0.28, true)
                tw(fs, 0.25, { Color = isOpen and Current.AccentHi or Current.Border, Transparency = isOpen and 0 or 0.5 })
                tw(icon, 0.25, { TextColor3 = isOpen and Current.AccentHi or Current.TextMute })
                if not isOpen then
                    task.delay(0.25, function() list.Visible = false end)
                end
            end)

            onTheme(function()
                tw(f, 0.35, { BackgroundColor3 = Current.Surface })
                tw(fs, 0.35, { Color = Current.Border })
                tw(title, 0.35, { TextColor3 = Current.TextDim })
                tw(sel, 0.35, { TextColor3 = Current.Text })
                tw(list, 0.35, { BackgroundColor3 = Current.SurfaceLow })
                for _, v in pairs(optionButtons) do
                    tw(v.frame, 0.35, { BackgroundColor3 = Current.SurfaceHi })
                    tw(v.dot, 0.35, { BackgroundColor3 = Current.Accent })
                    tw(v.chk, 0.35, { TextColor3 = Current.AccentHi })
                    tw(v.label, 0.35, { TextColor3 = Current.Text })
                end
            end)

            updateSelLabel()

            return {
                Set = function(_, v)
                    if isMulti and type(v) == "table" then
                        selected = {}
                        for _, o in ipairs(v) do selected[o] = true end
                        for name, btn in pairs(optionButtons) do
                            btn.dot.Visible = selected[name] or false
                            btn.chk.Visible = selected[name] or false
                        end
                    else
                        selected = v
                        for name, btn in pairs(optionButtons) do
                            btn.dot.Visible = (name == v)
                            btn.chk.Visible = (name == v)
                        end
                    end
                    updateSelLabel()
                    if flag then NINOMAX:SetFlag(flag, selected) end
                    pcall(cb, v)
                end,
                Add = function(_, newOpts)
                    -- simplificado
                end,
                Clear = function()
                    for _, v in pairs(optionButtons) do v.frame:Destroy() end
                    optionButtons = {}
                end,
                Destroy = function() f:Destroy(); list:Destroy() end,
            }
        end

        -- ═══════════════ CREATE TEXT BOX
        function Tab:CreateTextBox(cfg)
            cfg = cfg or {}
            if type(cfg) == "string" then cfg = { Title = cfg } end
            local label = cfg.Title or cfg.Name or "Input"
            local placeholder = cfg.Placeholder or cfg.PlaceholderText or "Escreva..."
            local default = cfg.Default or ""
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag
            if flag and NINOMAX.Flags[flag] ~= nil then default = NINOMAX.Flags[flag] end

            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(1, -20, 0, 42)
            container.Position = UDim2.new(0, 10, 0, 0)
            container.BackgroundTransparency = 1
            container.ClipsDescendants = true

            local glow = Instance.new("ImageLabel", container)
            glow.Size = UDim2.new(1, 12, 1, 12)
            glow.Position = UDim2.new(0, -6, 0, -6)
            glow.BackgroundTransparency = 1
            glow.Image = "rbxassetid://1316045217"
            glow.ImageColor3 = Current.AccentHi
            glow.ImageTransparency = 1
            glow.ScaleType = Enum.ScaleType.Slice
            glow.SliceCenter = Rect.new(10, 10, 118, 118)
            glow.ZIndex = 0

            local bg = Instance.new("Frame", container)
            bg.Size = UDim2.new(1, 0, 1, 0)
            bg.BackgroundColor3 = Current.Surface
            bg.BorderSizePixel = 0
            bg.ZIndex = 1
            newCorner(bg, UDim.new(0, 8))
            local bgs = newStroke(bg, Current.Border, 1, 0.5)

            local hl = Instance.new("Frame", bg)
            hl.Size = UDim2.new(1, 0, 0, 2)
            hl.Position = UDim2.new(0, 0, 1, -2)
            hl.BackgroundColor3 = Current.Accent
            hl.BackgroundTransparency = 1
            hl.BorderSizePixel = 0
            hl.ZIndex = 2
            newCorner(hl, UDim.new(1, 0))

            local ph = Instance.new("TextLabel", bg)
            ph.Size = UDim2.new(1, -50, 0, 14)
            ph.Position = UDim2.new(0, 12, 0.5, -7)
            ph.BackgroundTransparency = 1
            ph.Text = placeholder
            ph.TextColor3 = Current.TextMute
            ph.Font = Enum.Font.Gotham
            ph.TextSize = 13
            ph.TextXAlignment = Enum.TextXAlignment.Left
            ph.TextTruncate = Enum.TextTruncate.AtEnd
            ph.Visible = (default == "")
            ph.ZIndex = 2

            local tb = Instance.new("TextBox", bg)
            tb.Size = UDim2.new(1, -42, 1, 0)
            tb.Position = UDim2.new(0, 12, 0, 0)
            tb.BackgroundTransparency = 1
            tb.Text = default
            tb.TextColor3 = Current.Text
            tb.Font = Enum.Font.Gotham
            tb.TextSize = 13
            tb.ClearTextOnFocus = false
            tb.TextXAlignment = Enum.TextXAlignment.Left
            tb.TextTruncate = Enum.TextTruncate.AtEnd
            tb.PlaceholderText = ""
            tb.ZIndex = 3

            local clearBtn = Instance.new("TextButton", bg)
            clearBtn.Size = UDim2.new(0, 18, 0, 18)
            clearBtn.Position = UDim2.new(1, -24, 0.5, -9)
            clearBtn.BackgroundTransparency = 1
            clearBtn.Text = "✕"
            clearBtn.TextColor3 = Current.TextMute
            clearBtn.Font = Enum.Font.GothamBold
            clearBtn.TextSize = 12
            clearBtn.AutoButtonColor = false
            clearBtn.Visible = (default ~= "")
            clearBtn.ZIndex = 4

            clearBtn.MouseEnter:Connect(function() tw(clearBtn, 0.15, { TextColor3 = Current.Danger }) end)
            clearBtn.MouseLeave:Connect(function() tw(clearBtn, 0.15, { TextColor3 = Current.TextMute }) end)
            clearBtn.MouseButton1Click:Connect(function()
                tb.Text = ""
                clearBtn.Visible = false
                ph.Visible = true
                if flag then NINOMAX:SetFlag(flag, "") end
                pcall(cb, "")
            end)

            tb:GetPropertyChangedSignal("Text"):Connect(function()
                clearBtn.Visible = (tb.Text ~= "")
            end)

            tb.Focused:Connect(function()
                if tb.Text == "" then tw(ph, 0.2, { TextTransparency = 1 }) end
                tw(glow, 0.25, { ImageTransparency = 0.4 })
                tw(hl, 0.25, { BackgroundTransparency = 0.2 })
                tw(bgs, 0.25, { Color = Current.AccentHi, Transparency = 0.1 })
            end)
            tb.FocusLost:Connect(function(enter)
                if tb.Text == "" then
                    ph.Visible = true
                    ph.TextTransparency = 0
                end
                tw(glow, 0.3, { ImageTransparency = 1 })
                tw(hl, 0.3, { BackgroundTransparency = 1 })
                tw(bgs, 0.25, { Color = Current.Border, Transparency = 0.5 })
                if enter then
                    if flag then NINOMAX:SetFlag(flag, tb.Text) end
                    pcall(cb, tb.Text)
                end
            end)

            onTheme(function()
                tw(glow, 0.35, { ImageColor3 = Current.AccentHi })
                tw(hl, 0.35, { BackgroundColor3 = Current.Accent })
                tw(bg, 0.35, { BackgroundColor3 = Current.Surface })
                tw(bgs, 0.35, { Color = Current.Border })
                tw(tb, 0.35, { TextColor3 = Current.Text })
                tw(ph, 0.35, { TextColor3 = Current.TextMute })
            end)

            return {
                Set = function(_, v) tb.Text = tostring(v) end,
                Get = function() return tb.Text end,
                Destroy = function() container:Destroy() end,
            }
        end

        -- ═══════════════ CREATE KEYBIND
        function Tab:CreateKeybind(cfg)
            cfg = cfg or {}
            local label = cfg.Title or cfg.Name or "Keybind"
            local default = cfg.Default or "Nenhuma"
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag
            if flag and NINOMAX.Flags[flag] ~= nil then default = NINOMAX.Flags[flag] end

            local f = Instance.new("Frame", page)
            f.Size = UDim2.new(1, -20, 0, 44)
            f.Position = UDim2.new(0, 10, 0, 0)
            f.BackgroundColor3 = Current.Surface
            f.BorderSizePixel = 0
            newCorner(f, UDim.new(0, 8))
            local fs = newStroke(f, Current.Border, 1, 0.6)

            local title = Instance.new("TextLabel", f)
            title.BackgroundTransparency = 1
            title.Text = label
            title.TextColor3 = Current.Text
            title.Font = Enum.Font.GothamMedium
            title.TextSize = 14
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.Position = UDim2.new(0, 14, 0, 0)
            title.Size = UDim2.new(1, -110, 1, 0)

            local kbBtn = Instance.new("TextButton", f)
            kbBtn.Size = UDim2.new(0, 90, 0, 26)
            kbBtn.Position = UDim2.new(1, -102, 0.5, -13)
            kbBtn.BackgroundColor3 = Current.SurfaceHi
            kbBtn.Text = default
            kbBtn.TextColor3 = Current.Text
            kbBtn.Font = Enum.Font.Code
            kbBtn.TextSize = 12
            kbBtn.AutoButtonColor = false
            newCorner(kbBtn, UDim.new(0, 6))
            local kbStroke = newStroke(kbBtn, Current.Border, 1, 0.5)

            local capturing = false
            local currentKey = default

            kbBtn.MouseButton1Click:Connect(function()
                capturing = not capturing
                if capturing then
                    kbBtn.Text = "Pressione..."
                    kbBtn.TextColor3 = Current.AccentHi
                    tw(kbStroke, 0.2, { Color = Current.AccentHi, Transparency = 0 })
                else
                    kbBtn.Text = currentKey
                    kbBtn.TextColor3 = Current.Text
                    tw(kbStroke, 0.2, { Color = Current.Border, Transparency = 0.5 })
                end
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if gpe or not capturing then return end
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode.Name
                    kbBtn.Text = currentKey
                    kbBtn.TextColor3 = Current.Text
                    capturing = false
                    tw(kbStroke, 0.2, { Color = Current.Border, Transparency = 0.5 })
                    if flag then NINOMAX:SetFlag(flag, currentKey) end
                    pcall(cb, input.KeyCode)
                end
            end)

            onTheme(function()
                tw(f, 0.35, { BackgroundColor3 = Current.Surface })
                tw(fs, 0.35, { Color = Current.Border })
                tw(title, 0.35, { TextColor3 = Current.Text })
                tw(kbBtn, 0.35, { BackgroundColor3 = Current.SurfaceHi })
                tw(kbStroke, 0.35, { Color = Current.Border })
            end)

            return {
                Set = function(_, v) currentKey = v; kbBtn.Text = v end,
                Get = function() return currentKey end,
                Destroy = function() f:Destroy() end,
            }
        end

        -- ═══════════════ CREATE COLOR PICKER
        function Tab:CreateColorPicker(cfg)
            cfg = cfg or {}
            local label = cfg.Title or cfg.Name or "Cor"
            local default = cfg.Default or Color3.fromRGB(255, 60, 60)
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag
            if flag and NINOMAX.Flags[flag] ~= nil then
                pcall(function() default = Color3.fromRGB(unpack(NINOMAX.Flags[flag])) end)
            end

            local current = default
            local h, s, v = Color3.toHSV(current)

            local frame = Instance.new("Frame", page)
            frame.Size = UDim2.new(1, -20, 0, 44)
            frame.Position = UDim2.new(0, 10, 0, 0)
            frame.BackgroundColor3 = Current.Surface
            frame.ClipsDescendants = true
            frame.BorderSizePixel = 0
            newCorner(frame, UDim.new(0, 10))
            local fs = newStroke(frame, Current.Border, 1, 0.5)

            local header = Instance.new("TextButton", frame)
            header.Size = UDim2.new(1, 0, 0, 44)
            header.BackgroundTransparency = 1
            header.Text = ""

            local lbl = Instance.new("TextLabel", header)
            lbl.BackgroundTransparency = 1
            lbl.Text = label
            lbl.TextColor3 = Current.Text
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Position = UDim2.new(0, 14, 0, 0)
            lbl.Size = UDim2.new(1, -80, 1, 0)

            local previewDot = Instance.new("Frame", header)
            previewDot.Size = UDim2.new(0, 22, 0, 22)
            previewDot.Position = UDim2.new(1, -60, 0.5, -11)
            previewDot.BackgroundColor3 = current
            previewDot.BorderSizePixel = 0
            newCorner(previewDot, UDim.new(0, 6))
            newStroke(previewDot, Color3.new(1,1,1), 1.5, 0.4)

            local arrow = Instance.new("TextLabel", header)
            arrow.BackgroundTransparency = 1
            arrow.Text = "▼"
            arrow.TextColor3 = Current.Text
            arrow.Font = Enum.Font.GothamBold
            arrow.TextSize = 12
            arrow.Position = UDim2.new(1, -30, 0.5, -10)
            arrow.Size = UDim2.new(0, 20, 0, 20)

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
            newCorner(pad, UDim.new(0, 8))
            pad.ClipsDescendants = true
            newStroke(pad, Current.Border, 1, 0.4)

            local satOv = Instance.new("Frame", pad)
            satOv.Size = UDim2.new(1, 0, 1, 0)
            satOv.BackgroundColor3 = Color3.new(1, 1, 1)
            satOv.BorderSizePixel = 0
            local satGrad = Instance.new("UIGradient", satOv)
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
            newCorner(padMarker, UDim.new(1, 0))
            newStroke(padMarker, Color3.new(0, 0, 0), 2, 0.2)
            padMarker.ZIndex = 5

            local hueBar = Instance.new("Frame", body)
            hueBar.Size = UDim2.new(0, 20, 0, padSize)
            hueBar.Position = UDim2.new(0, 14 + padSize + 12, 0, 12)
            hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
            hueBar.BorderSizePixel = 0
            newCorner(hueBar, UDim.new(0, 6))
            newStroke(hueBar, Current.Border, 1, 0.4)
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
            newCorner(hueMarker, UDim.new(1, 0))
            newStroke(hueMarker, Color3.new(0, 0, 0), 2, 0.3)

            local previewCol = Instance.new("Frame", body)
            previewCol.Size = UDim2.new(0, 110, 0, padSize)
            previewCol.Position = UDim2.new(1, -124, 0, 12)
            previewCol.BackgroundTransparency = 1

            local hexLbl = Instance.new("TextLabel", previewCol)
            hexLbl.BackgroundTransparency = 1
            hexLbl.Text = "HEX"
            hexLbl.TextColor3 = Current.TextMute
            hexLbl.Font = Enum.Font.GothamBold
            hexLbl.TextSize = 10
            hexLbl.TextXAlignment = Enum.TextXAlignment.Left
            hexLbl.Position = UDim2.new(0, 0, 0, 0)
            hexLbl.Size = UDim2.new(1, 0, 0, 14)

            local hexBox = Instance.new("TextBox", previewCol)
            hexBox.Size = UDim2.new(1, 0, 0, 26)
            hexBox.Position = UDim2.new(0, 0, 0, 16)
            hexBox.BackgroundColor3 = Current.SurfaceHi
            hexBox.TextColor3 = Current.Text
            hexBox.Font = Enum.Font.Code
            hexBox.TextSize = 13
            hexBox.Text = string.format("#%02X%02X%02X",
                math.floor(current.R*255+0.5), math.floor(current.G*255+0.5), math.floor(current.B*255+0.5))
            hexBox.ClearTextOnFocus = false
            newCorner(hexBox, UDim.new(0, 5))
            newStroke(hexBox, Current.Border, 1, 0.5)

            local function updateAll()
                local color = Color3.fromHSV(h, s, v)
                current = color
                pad.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                padMarker.Position = UDim2.new(s, 0, 1 - v, 0)
                hueMarker.Position = UDim2.new(0.5, 0, h, 0)
                previewDot.BackgroundColor3 = color
                hexBox.Text = string.format("#%02X%02X%02X",
                    math.floor(color.R*255+0.5), math.floor(color.G*255+0.5), math.floor(color.B*255+0.5))
                if flag then NINOMAX:SetFlag(flag, {math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)}) end
                pcall(cb, color)
            end

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
            UserInputService.InputChanged:Connect(function(i)
                if padDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    padUpdate(i)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    padDrag = false
                end
            end)

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
            UserInputService.InputChanged:Connect(function(i)
                if hueDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    hueUpdate(i)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    hueDrag = false
                end
            end)

            hexBox.FocusLost:Connect(function()
                local hex = hexBox.Text:gsub("#", "")
                if #hex == 6 then
                    local r = tonumber(hex:sub(1,2), 16)
                    local g = tonumber(hex:sub(3,4), 16)
                    local b = tonumber(hex:sub(5,6), 16)
                    if r and g and b then
                        local c = Color3.fromRGB(r, g, b)
                        h, s, v = Color3.toHSV(c)
                        updateAll()
                        return
                    end
                end
                hexBox.Text = string.format("#%02X%02X%02X",
                    math.floor(current.R*255+0.5), math.floor(current.G*255+0.5), math.floor(current.B*255+0.5))
            end)

            local expanded = false
            local function setExpanded(v2)
                expanded = v2
                arrow.Text = expanded and "▲" or "▼"
                local targetH = expanded and (44 + 12 + padSize + 12) or 44
                tw(frame, 0.35, { Size = UDim2.new(1, -20, 0, targetH) }, Enum.EasingStyle.Back)
                body.Size = UDim2.new(1, 0, 0, expanded and (targetH - 44) or 0)
            end
            header.MouseButton1Click:Connect(function() setExpanded(not expanded) end)

            onTheme(function()
                tw(frame, 0.35, { BackgroundColor3 = Current.Surface })
                tw(fs, 0.35, { Color = Current.Border })
                tw(lbl, 0.35, { TextColor3 = Current.Text })
                tw(hexBox, 0.35, { BackgroundColor3 = Current.SurfaceHi, TextColor3 = Current.Text })
                tw(hexLbl, 0.35, { TextColor3 = Current.TextMute })
            end)

            updateAll()

            return {
                Set = function(_, c)
                    h, s, v = Color3.toHSV(c)
                    updateAll()
                end,
                Get = function() return current end,
                Destroy = function() frame:Destroy() end,
            }
        end

        -- ═══════════════ CREATE PROGRESS BAR
        function Tab:CreateProgressBar(cfg)
            cfg = cfg or {}
            local label = cfg.Title or cfg.Name or "Progresso"

            local f = Instance.new("Frame", page)
            f.Size = UDim2.new(1, -20, 0, 46)
            f.Position = UDim2.new(0, 10, 0, 0)
            f.BackgroundColor3 = Current.Surface
            f.BorderSizePixel = 0
            newCorner(f, UDim.new(0, 8))
            newStroke(f, Current.Border, 1, 0.6)

            local title = Instance.new("TextLabel", f)
            title.Size = UDim2.new(1, -60, 0, 16)
            title.Position = UDim2.new(0, 12, 0, 6)
            title.BackgroundTransparency = 1
            title.Text = label
            title.TextColor3 = Current.Text
            title.Font = Enum.Font.GothamMedium
            title.TextSize = 13
            title.TextXAlignment = Enum.TextXAlignment.Left

            local pctLbl = Instance.new("TextLabel", f)
            pctLbl.Size = UDim2.new(0, 50, 0, 16)
            pctLbl.Position = UDim2.new(1, -62, 0, 6)
            pctLbl.BackgroundTransparency = 1
            pctLbl.Text = "0%"
            pctLbl.TextColor3 = Current.AccentHi
            pctLbl.Font = Enum.Font.GothamBold
            pctLbl.TextSize = 13
            pctLbl.TextXAlignment = Enum.TextXAlignment.Right

            local bar = Instance.new("Frame", f)
            bar.Size = UDim2.new(1, -24, 0, 8)
            bar.Position = UDim2.new(0, 12, 0, 30)
            bar.BackgroundColor3 = Current.SurfaceLow
            bar.BorderSizePixel = 0
            newCorner(bar, UDim.new(1, 0))

            local fill = Instance.new("Frame", bar)
            fill.Size = UDim2.new(0, 0, 1, 0)
            fill.BackgroundColor3 = Current.Accent
            fill.BorderSizePixel = 0
            newCorner(fill, UDim.new(1, 0))
            local fg = Instance.new("UIGradient", fill)
            fg.Color = ColorSequence.new(Current.AccentSoft, Current.AccentHi)

            onTheme(function()
                tw(f, 0.35, { BackgroundColor3 = Current.Surface })
                tw(title, 0.35, { TextColor3 = Current.Text })
                tw(fill, 0.35, { BackgroundColor3 = Current.Accent })
                tw(fg, 0.35, { Color = ColorSequence.new(Current.AccentSoft, Current.AccentHi) })
                tw(pctLbl, 0.35, { TextColor3 = Current.AccentHi })
                tw(bar, 0.35, { BackgroundColor3 = Current.SurfaceLow })
            end)

            return {
                Set = function(_, value)
                    local p = math.clamp(value / 100, 0, 1)
                    fill:TweenSize(UDim2.new(p, 0, 1, 0), "Out", "Quart", 0.4, true)
                    pctLbl.Text = string.format("%d%%", math.floor(p * 100 + 0.5))
                end,
                Destroy = function() f:Destroy() end,
            }
        end

        -- ═══════════════ CREATE DISCORD INVITE
        function Tab:CreateDiscordInvite(cfg)
            cfg = cfg or {}
            local title = cfg.Title or "Servidor Discord"
            local desc = cfg.Description or "Entre no servidor!"
            local logo = cfg.Logo or "rbxassetid://10723407389"
            local invite = cfg.Invite or "https://discord.gg/exemplo"

            local box = Instance.new("Frame", page)
            box.Size = UDim2.new(1, -20, 0, 90)
            box.Position = UDim2.new(0, 10, 0, 0)
            box.BackgroundColor3 = Current.Surface
            box.BorderSizePixel = 0
            newCorner(box, UDim.new(0, 10))
            newStroke(box, Current.Border, 1, 0.5)

            local ic = Instance.new("ImageLabel", box)
            ic.Size = UDim2.new(0, 50, 0, 50)
            ic.Position = UDim2.new(0, 12, 0, 12)
            ic.Image = logo
            ic.BackgroundColor3 = Current.SurfaceHi
            ic.BorderSizePixel = 0
            ic.ScaleType = Enum.ScaleType.Fit
            newCorner(ic, UDim.new(0, 8))
            newStroke(ic, Current.Border, 1, 0.4)

            local tl = Instance.new("TextLabel", box)
            tl.BackgroundTransparency = 1
            tl.Text = title
            tl.TextColor3 = Current.Text
            tl.Font = Enum.Font.GothamBold
            tl.TextSize = 14
            tl.TextXAlignment = Enum.TextXAlignment.Left
            tl.Position = UDim2.new(0, 72, 0, 12)
            tl.Size = UDim2.new(1, -84, 0, 18)

            local dl = Instance.new("TextLabel", box)
            dl.BackgroundTransparency = 1
            dl.Text = desc
            dl.TextColor3 = Current.TextMute
            dl.Font = Enum.Font.Gotham
            dl.TextSize = 11
            dl.TextXAlignment = Enum.TextXAlignment.Left
            dl.TextWrapped = true
            dl.Position = UDim2.new(0, 72, 0, 32)
            dl.Size = UDim2.new(1, -84, 0, 30)

            local btn = Instance.new("TextButton", box)
            btn.Size = UDim2.new(1, -24, 0, 24)
            btn.Position = UDim2.new(0, 12, 1, -32)
            btn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
            btn.Text = "🔗  COPIAR CONVITE"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 12
            btn.AutoButtonColor = false
            newCorner(btn, UDim.new(0, 6))

            btn.MouseButton1Click:Connect(function()
                pcall(function()
                    if setclipboard then setclipboard(invite) end
                end)
                btn.Text = "✓  COPIADO!"
                task.delay(2, function() btn.Text = "🔗  COPIAR CONVITE" end)
            end)

            return {
                Destroy = function() box:Destroy() end,
            }
        end

        return Tab
    end

    -- ═══════════════════════════════════════════════════════════════
    -- WINDOW METHODS
    -- ═══════════════════════════════════════════════════════════════
    function Window:SetTheme(name)
        if NINOMAX.Themes[name] then
            ApplyTheme(name)
            broadcastTheme()
        end
    end

    function Window:GetTheme() return NINOMAX.CurrentTheme end

    function Window:SetSubtitle(text)
        subtitle.Text = tostring(text)
        task.defer(function()
            local w1 = titleNino.TextBounds.X
            local w2 = titleMax.TextBounds.X
            subtitle.Position = UDim2.new(0, 14 + w1 + w2 + 8, 0, 20)
        end)
    end

    function Window:SetTitle(text)
        text = tostring(text)
        titleNino.Text = text:sub(1, math.floor(#text * 0.5))
        titleMax.Text = text:sub(math.floor(#text * 0.5) + 1)
    end

    -- ═══════════════ NOTIFY SYSTEM
    local notifyQueue = {}
    local notifying = false

    function Window:Notify(cfg)
        cfg = cfg or {}
        local title = cfg.Title or "Aviso"
        local text = cfg.Text or cfg.Description or ""
        local duration = cfg.Duration or 3
        local icon = cfg.Icon
        local type_ = cfg.Type or "info"

        local sg = Instance.new("ScreenGui")
        sg.Name = "NINOMAX_Notify"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        sg.DisplayOrder = 100000
        pcall(function() sg.Parent = CoreGui end)
        if not sg.Parent then sg.Parent = Player:WaitForChild("PlayerGui") end

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 300, 0, 90)
        frame.Position = UDim2.new(1, 320, 1, -20)
        frame.AnchorPoint = Vector2.new(1, 1)
        frame.BackgroundColor3 = Current.Bg
        frame.BackgroundTransparency = 0.05
        frame.BorderSizePixel = 0
        frame.Parent = sg
        newCorner(frame, UDim.new(0, 12))
        newStroke(frame, Current.AccentHi, 1.5, 0.2)

        local accentColor = ({
            info = Current.Accent,
            success = Current.Success,
            warning = Current.Warning,
            danger = Current.Danger,
        })[type_] or Current.Accent

        local sideBar = Instance.new("Frame", frame)
        sideBar.Size = UDim2.new(0, 4, 1, -16)
        sideBar.Position = UDim2.new(0, 8, 0, 8)
        sideBar.BackgroundColor3 = accentColor
        sideBar.BorderSizePixel = 0
        newCorner(sideBar, UDim.new(0, 3))

        local prog = Instance.new("Frame", frame)
        prog.Size = UDim2.new(1, 0, 0, 3)
        prog.Position = UDim2.new(0, 0, 1, -3)
        prog.BackgroundColor3 = accentColor
        prog.BorderSizePixel = 0
        newCorner(prog, UDim.new(1, 0))

        local tl = Instance.new("TextLabel", frame)
        tl.BackgroundTransparency = 1
        tl.Text = title
        tl.TextColor3 = Current.Text
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 14
        tl.TextXAlignment = Enum.TextXAlignment.Left
        tl.Position = UDim2.new(0, 22, 0, 12)
        tl.Size = UDim2.new(1, -30, 0, 20)

        local xl = Instance.new("TextLabel", frame)
        xl.BackgroundTransparency = 1
        xl.Text = text
        xl.TextColor3 = Current.TextMute
        xl.Font = Enum.Font.Gotham
        xl.TextSize = 12
        xl.TextWrapped = true
        xl.TextXAlignment = Enum.TextXAlignment.Left
        xl.TextYAlignment = Enum.TextYAlignment.Top
        xl.Position = UDim2.new(0, 22, 0, 34)
        xl.Size = UDim2.new(1, -30, 0, 44)

        table.insert(notifyQueue, { frame = frame, gui = sg, duration = duration })
        if not notifying then
            notifying = true
            task.spawn(function()
                while #notifyQueue > 0 do
                    local data = table.remove(notifyQueue, 1)
                    local f = data.frame
                    f:TweenPosition(UDim2.new(1, -20, 1, -20 - (#notifyQueue * 100)), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.4, true)
                    tw(prog, data.duration, { Size = UDim2.new(0, 0, 0, 3) }, Enum.EasingStyle.Linear)
                    task.delay(data.duration, function()
                        f:TweenPosition(UDim2.new(1, 320, 1, -20), Enum.EasingDirection.In, Enum.EasingStyle.Quint, 0.35, true)
                        task.wait(0.4)
                        data.gui:Destroy()
                    end)
                    task.wait(data.duration + 0.4)
                end
                notifying = false
            end)
        end
    end

    -- ═══════════════ DIALOG SYSTEM
    function Window:Dialog(cfg)
        cfg = cfg or {}
        local title = cfg.Title or "Dialog"
        local text = cfg.Text or ""
        local buttons = cfg.Buttons or { { "OK", function() end } }

        local overlay = Instance.new("Frame", gui)
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.new(0, 0, 0)
        overlay.BackgroundTransparency = 0.5
        overlay.BorderSizePixel = 0
        overlay.ZIndex = 100

        local dlg = Instance.new("Frame", overlay)
        dlg.Size = UDim2.new(0, 320, 0, 170)
        dlg.Position = UDim2.new(0.5, 0, 0.5, 0)
        dlg.AnchorPoint = Vector2.new(0.5, 0.5)
        dlg.BackgroundColor3 = Current.Bg
        dlg.BorderSizePixel = 0
        dlg.ZIndex = 101
        newCorner(dlg, UDim.new(0, 12))
        newStroke(dlg, Current.Accent, 1.5, 0.2)

        local tl = Instance.new("TextLabel", dlg)
        tl.BackgroundTransparency = 1
        tl.Text = title
        tl.TextColor3 = Current.Text
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 15
        tl.TextXAlignment = Enum.TextXAlignment.Left
        tl.Position = UDim2.new(0, 16, 0, 14)
        tl.Size = UDim2.new(1, -32, 0, 22)

        local xl = Instance.new("TextLabel", dlg)
        xl.BackgroundTransparency = 1
        xl.Text = text
        xl.TextColor3 = Current.TextMute
        xl.Font = Enum.Font.Gotham
        xl.TextSize = 12
        xl.TextWrapped = true
        xl.TextXAlignment = Enum.TextXAlignment.Left
        xl.TextYAlignment = Enum.TextYAlignment.Top
        xl.Position = UDim2.new(0, 16, 0, 42)
        xl.Size = UDim2.new(1, -32, 0, 60)

        local btnHolder = Instance.new("Frame", dlg)
        btnHolder.Size = UDim2.new(1, -32, 0, 30)
        btnHolder.Position = UDim2.new(0, 16, 1, -46)
        btnHolder.BackgroundTransparency = 1
        local bhl = Instance.new("UIListLayout", btnHolder)
        bhl.FillDirection = Enum.FillDirection.Horizontal
        bhl.Padding = UDim.new(0, 8)
        bhl.HorizontalAlignment = Enum.HorizontalAlignment.Right

        local function close()
            tw(dlg, 0.2, { Size = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            tw(overlay, 0.2, { BackgroundTransparency = 1 })
            task.delay(0.25, function() overlay:Destroy() end)
        end

        for _, btnData in ipairs(buttons) do
            local name = btnData[1]
            local cb = btnData[2] or function() end
            local b = Instance.new("TextButton", btnHolder)
            b.Size = UDim2.new(0, 90, 1, 0)
            b.BackgroundColor3 = Current.SurfaceHi
            b.Text = name
            b.TextColor3 = Current.Text
            b.Font = Enum.Font.GothamBold
            b.TextSize = 12
            b.AutoButtonColor = false
            newCorner(b, UDim.new(0, 7))
            newStroke(b, Current.Border, 1, 0.4)
            b.MouseEnter:Connect(function() tw(b, 0.15, { BackgroundColor3 = mix(Current.SurfaceHi, Current.Accent, 0.35) }) end)
            b.MouseLeave:Connect(function() tw(b, 0.15, { BackgroundColor3 = Current.SurfaceHi }) end)
            b.MouseButton1Click:Connect(function()
                close()
                task.delay(0.25, function() pcall(cb) end)
            end)
        end
    end

    return Window
end

-- ═══════════════════════════════════════════════════════════════════════
-- EXPORT
-- ═══════════════════════════════════════════════════════════════════════
return NINOMAX
