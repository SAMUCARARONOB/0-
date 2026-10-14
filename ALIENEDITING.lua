--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║  NINOMAX UI · v1.0.0 · REDZ SUPERIOR EDITION                     ║
    ║  ✦ NINO (branco) + MAX (vermelho glow)                           ║
    ║  ✦ Smart Theme · Compact Rows · Floating Dropdown · Dialog        ║
    ║  ✦ Professional ColorPicker · Save/Load · Mobile-first           ║
    ╚══════════════════════════════════════════════════════════════════╝
]]

local TweenService     = game:GetService("TweenService")
local Players          = game:GetService("Players")
local UIS              = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")
local player           = Players.LocalPlayer

local NINOMAX = {}
NINOMAX.Version = "1.0.0"
NINOMAX.Flags = {}

-- ═══════════════════════════════════════════════════════════════════
-- ICON LIBRARY (Lucide-based, mesmo do Redz)
-- ═══════════════════════════════════════════════════════════════════
NINOMAX.Icons = (function()
    return {
        ["activity"] = "rbxassetid://10709752035",
        ["alertcircle"] = "rbxassetid://10709752996",
        ["alarmclock"] = "rbxassetid://10709752630",
        ["arrowright"] = "rbxassetid://10709768347",
        ["award"] = "rbxassetid://10709769406",
        ["check"] = "rbxassetid://10709790644",
        ["checkcircle"] = "rbxassetid://10709790387",
        ["chevronright"] = "rbxassetid://10709791437",
        ["chevronup"] = "rbxassetid://10709791523",
        ["chevrondown"] = "rbxassetid://10709790948",
        ["clock"] = "rbxassetid://10709805144",
        ["close"] = "rbxassetid://10747384394",
        ["code"] = "rbxassetid://10709810463",
        ["cog"] = "rbxassetid://10709810948",
        ["copy"] = "rbxassetid://10709812159",
        ["cpu"] = "rbxassetid://10709813383",
        ["crown"] = "rbxassetid://10709818626",
        ["edit"] = "rbxassetid://10734883598",
        ["eye"] = "rbxassetid://10723346959",
        ["eyeoff"] = "rbxassetid://10723346871",
        ["fire"] = "rbxassetid://10723376114",
        ["flag"] = "rbxassetid://10723375890",
        ["flame"] = "rbxassetid://10723376114",
        ["gift"] = "rbxassetid://10723396402",
        ["globe"] = "rbxassetid://10723404337",
        ["grid"] = "rbxassetid://10723404936",
        ["heart"] = "rbxassetid://10723406885",
        ["home"] = "rbxassetid://10723407389",
        ["info"] = "rbxassetid://10723415903",
        ["key"] = "rbxassetid://10723416652",
        ["lightbulb"] = "rbxassetid://10723425852",
        ["link"] = "rbxassetid://10723426722",
        ["list"] = "rbxassetid://10723433811",
        ["lock"] = "rbxassetid://10723434711",
        ["minus"] = "rbxassetid://10734896206",
        ["palette"] = "rbxassetid://10734910430",
        ["play"] = "rbxassetid://10734923549",
        ["plus"] = "rbxassetid://10734924532",
        ["power"] = "rbxassetid://10734930466",
        ["refreshcw"] = "rbxassetid://10734933222",
        ["rocket"] = "rbxassetid://10734934585",
        ["save"] = "rbxassetid://10734941499",
        ["search"] = "rbxassetid://10734943674",
        ["settings"] = "rbxassetid://10734950309",
        ["shield"] = "rbxassetid://10734951847",
        ["skull"] = "rbxassetid://10734962068",
        ["star"] = "rbxassetid://10734966248",
        ["sword"] = "rbxassetid://10734975486",
        ["swords"] = "rbxassetid://10734975692",
        ["target"] = "rbxassetid://10734977012",
        ["trash"] = "rbxassetid://10747362393",
        ["trophy"] = "rbxassetid://10747363809",
        ["unlock"] = "rbxassetid://10747366027",
        ["user"] = "rbxassetid://10747373176",
        ["users"] = "rbxassetid://10747373426",
        ["wand"] = "rbxassetid://10747376565",
        ["wrench"] = "rbxassetid://10747383470",
        ["x"] = "rbxassetid://10747384394",
        ["zap"] = "rbxassetid://10734974297",
    }
end)()

-- ═══════════════════════════════════════════════════════════════════
-- THEMES (11 temas temáticos estilo Redz melhorado)
-- ═══════════════════════════════════════════════════════════════════
NINOMAX.Themes = {
    Crimson = {
        gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 12, 14)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(38, 16, 20)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 12, 14)),
        }),
        bg = Color3.fromRGB(22, 12, 14),
        surface = Color3.fromRGB(34, 18, 22),
        surfaceHi = Color3.fromRGB(46, 24, 28),
        stroke = Color3.fromRGB(48, 24, 30),
        accent = Color3.fromRGB(220, 30, 55),
        accentHi = Color3.fromRGB(255, 70, 90),
        accentSoft = Color3.fromRGB(90, 15, 30),
        text = Color3.fromRGB(245, 240, 240),
        textDim = Color3.fromRGB(180, 160, 165),
    },
    Neon = {
        gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 22, 22)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(14, 32, 32)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 22, 22)),
        }),
        bg = Color3.fromRGB(8, 18, 18),
        surface = Color3.fromRGB(18, 30, 30),
        surfaceHi = Color3.fromRGB(26, 42, 42),
        stroke = Color3.fromRGB(30, 52, 52),
        accent = Color3.fromRGB(0, 220, 200),
        accentHi = Color3.fromRGB(80, 255, 240),
        accentSoft = Color3.fromRGB(0, 80, 75),
        text = Color3.fromRGB(235, 250, 245),
        textDim = Color3.fromRGB(150, 190, 185),
    },
    Ocean = {
        gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 16, 28)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(14, 22, 40)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 16, 28)),
        }),
        bg = Color3.fromRGB(8, 12, 22),
        surface = Color3.fromRGB(18, 24, 40),
        surfaceHi = Color3.fromRGB(26, 34, 54),
        stroke = Color3.fromRGB(30, 42, 68),
        accent = Color3.fromRGB(30, 140, 250),
        accentHi = Color3.fromRGB(90, 180, 255),
        accentSoft = Color3.fromRGB(15, 55, 120),
        text = Color3.fromRGB(240, 245, 255),
        textDim = Color3.fromRGB(160, 180, 210),
    },
    Violet = {
        gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 12, 28)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(28, 18, 42)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 12, 28)),
        }),
        bg = Color3.fromRGB(14, 8, 22),
        surface = Color3.fromRGB(26, 16, 38),
        surfaceHi = Color3.fromRGB(38, 24, 54),
        stroke = Color3.fromRGB(46, 30, 68),
        accent = Color3.fromRGB(150, 60, 240),
        accentHi = Color3.fromRGB(200, 120, 255),
        accentSoft = Color3.fromRGB(70, 20, 120),
        text = Color3.fromRGB(245, 240, 255),
        textDim = Color3.fromRGB(180, 165, 205),
    },
    Sunset = {
        gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 16, 8)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(42, 22, 12)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 16, 8)),
        }),
        bg = Color3.fromRGB(20, 12, 8),
        surface = Color3.fromRGB(38, 22, 14),
        surfaceHi = Color3.fromRGB(52, 32, 20),
        stroke = Color3.fromRGB(62, 38, 24),
        accent = Color3.fromRGB(255, 130, 40),
        accentHi = Color3.fromRGB(255, 180, 90),
        accentSoft = Color3.fromRGB(130, 55, 15),
        text = Color3.fromRGB(255, 245, 235),
        textDim = Color3.fromRGB(210, 175, 145),
    },
    Toxic = {
        gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 24, 10)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 34, 14)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 24, 10)),
        }),
        bg = Color3.fromRGB(10, 18, 8),
        surface = Color3.fromRGB(20, 32, 16),
        surfaceHi = Color3.fromRGB(30, 46, 24),
        stroke = Color3.fromRGB(40, 60, 32),
        accent = Color3.fromRGB(140, 240, 40),
        accentHi = Color3.fromRGB(180, 255, 90),
        accentSoft = Color3.fromRGB(55, 110, 15),
        text = Color3.fromRGB(240, 250, 235),
        textDim = Color3.fromRGB(175, 205, 160),
    },
    Cyberpunk = {
        gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 8, 22)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 12, 32)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 8, 22)),
        }),
        bg = Color3.fromRGB(14, 6, 16),
        surface = Color3.fromRGB(26, 12, 28),
        surfaceHi = Color3.fromRGB(40, 18, 44),
        stroke = Color3.fromRGB(48, 22, 52),
        accent = Color3.fromRGB(255, 20, 190),
        accentHi = Color3.fromRGB(255, 90, 220),
        accentSoft = Color3.fromRGB(110, 10, 80),
        text = Color3.fromRGB(250, 240, 255),
        textDim = Color3.fromRGB(200, 160, 220),
    },
    Gold = {
        gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 20, 10)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(36, 28, 14)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 20, 10)),
        }),
        bg = Color3.fromRGB(18, 14, 6),
        surface = Color3.fromRGB(32, 26, 14),
        surfaceHi = Color3.fromRGB(46, 36, 20),
        stroke = Color3.fromRGB(58, 46, 24),
        accent = Color3.fromRGB(240, 190, 50),
        accentHi = Color3.fromRGB(255, 220, 100),
        accentSoft = Color3.fromRGB(110, 80, 20),
        text = Color3.fromRGB(255, 250, 235),
        textDim = Color3.fromRGB(200, 180, 140),
    },
    Emerald = {
        gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 24, 16)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(14, 34, 22)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 24, 16)),
        }),
        bg = Color3.fromRGB(8, 18, 12),
        surface = Color3.fromRGB(18, 32, 22),
        surfaceHi = Color3.fromRGB(26, 44, 32),
        stroke = Color3.fromRGB(34, 58, 42),
        accent = Color3.fromRGB(40, 210, 130),
        accentHi = Color3.fromRGB(90, 250, 175),
        accentSoft = Color3.fromRGB(15, 85, 55),
        text = Color3.fromRGB(235, 250, 240),
        textDim = Color3.fromRGB(155, 195, 175),
    },
    Blood = {
        gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 6, 8)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 10, 14)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 6, 8)),
        }),
        bg = Color3.fromRGB(14, 4, 6),
        surface = Color3.fromRGB(26, 10, 14),
        surfaceHi = Color3.fromRGB(40, 16, 22),
        stroke = Color3.fromRGB(50, 20, 26),
        accent = Color3.fromRGB(180, 10, 20),
        accentHi = Color3.fromRGB(230, 40, 55),
        accentSoft = Color3.fromRGB(80, 5, 12),
        text = Color3.fromRGB(250, 240, 240),
        textDim = Color3.fromRGB(195, 165, 165),
    },
    Midnight = {
        gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 16, 26)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 24, 38)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 16, 26)),
        }),
        bg = Color3.fromRGB(10, 12, 20),
        surface = Color3.fromRGB(22, 26, 40),
        surfaceHi = Color3.fromRGB(32, 38, 54),
        stroke = Color3.fromRGB(40, 48, 66),
        accent = Color3.fromRGB(90, 120, 240),
        accentHi = Color3.fromRGB(130, 160, 255),
        accentSoft = Color3.fromRGB(35, 48, 110),
        text = Color3.fromRGB(240, 242, 250),
        textDim = Color3.fromRGB(160, 170, 195),
    },
}

NINOMAX.CurrentTheme = "Crimson"
local T = NINOMAX.Themes.Crimson

-- ═══════════════════════════════════════════════════════════════════
-- UTILS
-- ═══════════════════════════════════════════════════════════════════
local function tw(inst, dur, props, style, dir)
    local t = TweenService:Create(inst,
        TweenInfo.new(dur or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    t:Play(); return t
end

local function newCorner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = r or UDim.new(0, 6)
    c.Parent = p; return c
end

local function newStroke(p, col, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or T.stroke
    s.Thickness = th or 1
    s.Transparency = tr or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p; return s
end

local function newPad(p, t, l, r, b)
    local u = Instance.new("UIPadding", p)
    u.PaddingTop = UDim.new(0, t or 0)
    u.PaddingLeft = UDim.new(0, l or 0)
    u.PaddingRight = UDim.new(0, r or 0)
    u.PaddingBottom = UDim.new(0, b or 0)
    return u
end

local function getIcon(name)
    if not name or name == "" then return nil end
    if name:find("rbxassetid://") or name:find("rbxthumb://") then return name end
    return NINOMAX.Icons[name:lower()] or nil
end

local function isMobile()
    return UIS.TouchEnabled and not UIS.KeyboardEnabled
end

local function draggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- FLAGS + SAVE
-- ═══════════════════════════════════════════════════════════════════
function NINOMAX:GetFlag(name) return self.Flags[name] end
function NINOMAX:SetFlag(name, value)
    self.Flags[name] = value
    if self._onFlagChange then self._onFlagChange(name, value) end
end

local function saveConfig(file)
    if not file then return end
    pcall(function()
        if writefile then writefile(file, HttpService:JSONEncode(NINOMAX.Flags)) end
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

-- ═══════════════════════════════════════════════════════════════════
-- THEME BROADCASTING
-- ═══════════════════════════════════════════════════════════════════
local themeBindings = {}
local function onTheme(fn) table.insert(themeBindings, fn) end
local function broadcastTheme()
    for _, fn in ipairs(themeBindings) do pcall(fn) end
end

-- ═══════════════════════════════════════════════════════════════════
-- CREATE WINDOW
-- ═══════════════════════════════════════════════════════════════════
function NINOMAX:CreateWindow(cfg)
    cfg = cfg or {}
    local Window = {}
    local TITLE = cfg.Title or "NINOMAX"
    local SUBTITLE = cfg.Subtitle or "v" .. self.Version
    local CONFIG_FILE = cfg.ConfigFile or "ninomax_config.json"
    local SIZE = Vector2.new(580, 390)
    local MIN_SIZE = Vector2.new(440, 300)
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
    if not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end

    local uiScale = Instance.new("UIScale", gui)
    uiScale.Scale = isMobile() and 1.05 or 1

    -- ─── SOMBRA (estilo Redz, apenas por baixo)
    local shadowHolder = Instance.new("Frame", gui)
    shadowHolder.BackgroundTransparency = 1
    shadowHolder.Size = UDim2.new(0, currentSize.X + 4, 0, currentSize.Y + 4)
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
    shadowImg.SliceCenter = Rect.new(8, 8, 120, 120)

    -- ═══ MAIN FRAME
    local mainFrame = Instance.new("ImageButton")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = T.bg
    mainFrame.BackgroundTransparency = 0.03
    mainFrame.AutoButtonColor = false
    mainFrame.ClipsDescendants = true
    mainFrame.Active = true
    mainFrame.Parent = gui
    newCorner(mainFrame, UDim.new(0, 12))

    local mainStroke = newStroke(mainFrame, T.stroke, 1.4, 0.3)
    local mainGrad = Instance.new("UIGradient", mainFrame)
    mainGrad.Rotation = 45
    mainGrad.Color = T.gradient

    -- ═══ TOP BAR
    local topBar = Instance.new("Frame", mainFrame)
    topBar.Size = UDim2.new(1, 0, 0, 30)
    topBar.BackgroundTransparency = 1
    topBar.ZIndex = 5

    -- NINO white + MAX red
    local titleNino = Instance.new("TextLabel", topBar)
    titleNino.BackgroundTransparency = 1
    titleNino.Position = UDim2.new(0, 15, 0.5, -1)
    titleNino.AnchorPoint = Vector2.new(0, 0.5)
    titleNino.AutomaticSize = Enum.AutomaticSize.XY
    titleNino.Font = Enum.Font.GothamBold
    titleNino.TextSize = 14
    titleNino.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleNino.TextXAlignment = Enum.TextXAlignment.Left
    titleNino.TextYAlignment = Enum.TextYAlignment.Center
    titleNino.Text = "NINO"
    titleNino.ZIndex = 6

    local ninoGlow = Instance.new("UIStroke", titleNino)
    ninoGlow.Color = Color3.fromRGB(255, 255, 255)
    ninoGlow.Thickness = 0
    ninoGlow.Transparency = 1

    local titleMax = Instance.new("TextLabel", topBar)
    titleMax.BackgroundTransparency = 1
    titleMax.Position = UDim2.new(0, 15, 0.5, -1)
    titleMax.AnchorPoint = Vector2.new(0, 0.5)
    titleMax.AutomaticSize = Enum.AutomaticSize.XY
    titleMax.Font = Enum.Font.GothamBold
    titleMax.TextSize = 14
    titleMax.TextColor3 = T.accentHi
    titleMax.TextXAlignment = Enum.TextXAlignment.Left
    titleMax.TextYAlignment = Enum.TextYAlignment.Center
    titleMax.Text = "MAX"
    titleMax.ZIndex = 6

    task.defer(function()
        local w = titleNino.TextBounds.X
        titleMax.Position = UDim2.new(0, 15 + w + 1, 0.5, -1)
    end)

    -- MAX glow pulsante
    local maxGlow = Instance.new("UIStroke", titleMax)
    maxGlow.Color = T.accentHi
    maxGlow.Thickness = 1
    maxGlow.Transparency = 0.4

    task.spawn(function()
        while titleMax.Parent do
            tw(maxGlow, 1.4, { Transparency = 0.9 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.4)
            tw(maxGlow, 1.4, { Transparency = 0.2 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.4)
        end
    end)

    -- Subtitle editável (logo após o MAX)
    local subtitle = Instance.new("TextLabel", topBar)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 9
    subtitle.TextColor3 = T.textDim
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.TextYAlignment = Enum.TextYAlignment.Bottom
    subtitle.Text = SUBTITLE
    subtitle.ZIndex = 6
    subtitle.AutomaticSize = Enum.AutomaticSize.XY

    task.defer(function()
        local w1 = titleNino.TextBounds.X
        local w2 = titleMax.TextBounds.X
        subtitle.Position = UDim2.new(0, 15 + w1 + w2 + 8, 0.5, 3)
    end)

    -- Botões minimizar + fechar (estilo Redz, ícones pequenos)
    local btnClose = Instance.new("ImageButton", topBar)
    btnClose.Size = UDim2.new(0, 14, 0, 14)
    btnClose.Position = UDim2.new(1, -12, 0.5, 0)
    btnClose.AnchorPoint = Vector2.new(1, 0.5)
    btnClose.BackgroundTransparency = 1
    btnClose.Image = "rbxassetid://10747384394"
    btnClose.ImageColor3 = T.textDim
    btnClose.AutoButtonColor = false
    btnClose.ZIndex = 7

    local btnMin = Instance.new("ImageButton", topBar)
    btnMin.Size = UDim2.new(0, 14, 0, 14)
    btnMin.Position = UDim2.new(1, -34, 0.5, 0)
    btnMin.AnchorPoint = Vector2.new(1, 0.5)
    btnMin.BackgroundTransparency = 1
    btnMin.Image = "rbxassetid://10734896206"
    btnMin.ImageColor3 = T.textDim
    btnMin.AutoButtonColor = false
    btnMin.ZIndex = 7

    btnClose.MouseEnter:Connect(function() tw(btnClose, 0.15, { ImageColor3 = Color3.fromRGB(255, 90, 90) }) end)
    btnClose.MouseLeave:Connect(function() tw(btnClose, 0.15, { ImageColor3 = T.textDim }) end)
    btnMin.MouseEnter:Connect(function() tw(btnMin, 0.15, { ImageColor3 = T.accentHi }) end)
    btnMin.MouseLeave:Connect(function() tw(btnMin, 0.15, { ImageColor3 = T.textDim }) end)

    draggable(mainFrame, topBar)

    -- Linha separadora top bar (estilo Redz fina)
    local sepLine = Instance.new("Frame", mainFrame)
    sepLine.Size = UDim2.new(1, 0, 0, 1)
    sepLine.Position = UDim2.new(0, 0, 0, 30)
    sepLine.BackgroundColor3 = T.stroke
    sepLine.BackgroundTransparency = 0.4
    sepLine.BorderSizePixel = 0
    sepLine.ZIndex = 4

    -- ═══ SIDEBAR (tabs)
    local sidebar = Instance.new("ScrollingFrame", mainFrame)
    sidebar.Size = UDim2.new(0, 150, 1, -30)
    sidebar.Position = UDim2.new(0, 0, 0, 30)
    sidebar.BackgroundTransparency = 1
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebar.ScrollBarThickness = 2
    sidebar.ScrollBarImageColor3 = T.accent
    sidebar.ScrollBarImageTransparency = 0.4
    sidebar.BorderSizePixel = 0
    sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
    sidebar.ZIndex = 3

    local sidePad = newPad(sidebar, 8, 8, 8, 8)

    local sideLay = Instance.new("UIListLayout", sidebar)
    sideLay.SortOrder = Enum.SortOrder.LayoutOrder
    sideLay.Padding = UDim.new(0, 4)

    -- Search bar
    local searchBox = Instance.new("TextBox", sidebar)
    searchBox.Size = UDim2.new(1, 0, 0, 22)
    searchBox.BackgroundColor3 = T.surface
    searchBox.BorderSizePixel = 0
    searchBox.PlaceholderText = "🔍 Buscar..."
    searchBox.PlaceholderColor3 = T.textDim
    searchBox.TextColor3 = T.text
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 10
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus = false
    searchBox.LayoutOrder = -1
    newCorner(searchBox, UDim.new(0, 5))
    newStroke(searchBox, T.stroke, 1, 0.5)
    newPad(searchBox, 0, 6, 6, 0)

    local tabBtns, pages, selectedTab = {}, {}, nil

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = string.lower(searchBox.Text)
        for name, btn in pairs(tabBtns) do
            btn.Visible = (q == "") or (string.find(string.lower(name), q, 1, true) ~= nil)
        end
    end)

    -- ═══ CONTENT HOLDER
    local contentHolder = Instance.new("ScrollingFrame", mainFrame)
    contentHolder.Position = UDim2.new(0, 154, 0, 34)
    contentHolder.Size = UDim2.new(1, -162, 1, -42)
    contentHolder.BackgroundTransparency = 1
    contentHolder.BorderSizePixel = 0
    contentHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentHolder.ScrollBarThickness = 2
    contentHolder.ScrollBarImageColor3 = T.accent
    contentHolder.ScrollBarImageTransparency = 0.4
    contentHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentHolder.ZIndex = 2

    -- ═══ RESIZE HANDLE (estilo Redz, invisível - só a área de drag)
    local resizeHandle = Instance.new("TextButton", mainFrame)
    resizeHandle.Size = UDim2.new(0, 20, 0, 20)
    resizeHandle.Position = UDim2.new(1, -22, 1, -22)
    resizeHandle.BackgroundTransparency = 1
    resizeHandle.Text = ""
    resizeHandle.ZIndex = 20

    do
        local drag, startSize, startPos
        resizeHandle.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drag = true; startSize = mainFrame.AbsoluteSize; startPos = i.Position
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - startPos
                local w = math.clamp(startSize.X + d.X, MIN_SIZE.X, MAX_SIZE.X)
                local h = math.clamp(startSize.Y + d.Y, MIN_SIZE.Y, MAX_SIZE.Y)
                mainFrame.Size = UDim2.new(0, w, 0, h)
                currentSize = Vector2.new(w, h)
            end
        end)
        UIS.InputEnded:Connect(function(i)
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
        shadowHolder.Size = UDim2.new(0, mainFrame.AbsoluteSize.X + 4, 0, mainFrame.AbsoluteSize.Y + 4)
    end)

    -- ═══ THEME BINDING
    onTheme(function()
        T = NINOMAX.Themes[NINOMAX.CurrentTheme]
        tw(mainFrame, 0.4, { BackgroundColor3 = T.bg })
        tw(mainGrad, 0.4, { Color = T.gradient })
        tw(mainStroke, 0.4, { Color = T.stroke })
        tw(sepLine, 0.4, { BackgroundColor3 = T.stroke })
        tw(titleMax, 0.4, { TextColor3 = T.accentHi })
        tw(maxGlow, 0.4, { Color = T.accentHi })
        tw(subtitle, 0.4, { TextColor3 = T.textDim })
        tw(sidebar, 0.4, { ScrollBarImageColor3 = T.accent })
        tw(contentHolder, 0.4, { ScrollBarImageColor3 = T.accent })
    end)

    -- ═══ ENTRY ANIMATION
    task.spawn(function()
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        mainFrame.BackgroundTransparency = 1
        shadowImg.ImageTransparency = 1

        task.wait(0.05)
        mainFrame.Size = UDim2.new(0, currentSize.X - 30, 0, currentSize.Y - 18)
        tw(mainFrame, 0.5, { Size = UDim2.new(0, currentSize.X, 0, currentSize.Y) }, Enum.EasingStyle.Back)
        tw(mainFrame, 0.35, { BackgroundTransparency = 0.03 })
        tw(shadowImg, 0.45, { ImageTransparency = 0.5 })

        sidebar.Position = UDim2.new(0, -40, 0, 30)
        task.wait(0.12)
        tw(sidebar, 0.4, { Position = UDim2.new(0, 0, 0, 30) })

        titleNino.Position = UDim2.new(0, -50, 0.5, -1)
        tw(titleNino, 0.35, { Position = UDim2.new(0, 15, 0.5, -1) })
    end)

    -- ═══ HIDE/SHOW
    local isHidden = false
    local function doHide()
        if isHidden then return end
        isHidden = true
        local fs = mainFrame.AbsoluteSize
        currentSize = Vector2.new(fs.X, fs.Y)
        tw(mainFrame, 0.22, { Size = UDim2.new(0, currentSize.X, 0, 8), BackgroundTransparency = 0.5 },
            Enum.EasingStyle.Back, Enum.EasingDirection.In)
        tw(shadowImg, 0.22, { ImageTransparency = 1 })
        task.delay(0.22, function()
            mainFrame.Visible = false
            mainFrame.Size = UDim2.new(0, currentSize.X, 0, currentSize.Y)
            mainFrame.BackgroundTransparency = 0.03
        end)
    end
    local function doShow()
        if not isHidden then return end
        isHidden = false
        mainFrame.Visible = true
        mainFrame.Size = UDim2.new(0, currentSize.X, 0, 8)
        mainFrame.BackgroundTransparency = 0.5
        tw(mainFrame, 0.35, { Size = UDim2.new(0, currentSize.X, 0, currentSize.Y), BackgroundTransparency = 0.03 },
            Enum.EasingStyle.Back)
        tw(shadowImg, 0.35, { ImageTransparency = 0.5 })
    end

    btnMin.MouseButton1Click:Connect(function()
        if isHidden then doShow() else doHide() end
    end)

    UIS.InputBegan:Connect(function(input, gpe)
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
                f.Position = UDim2.new(0, 14, 0, 0)
                tw(f, 0.26, { Position = UDim2.new(0, 0, 0, 0) })
            end
        end
        for tn, btn in pairs(tabBtns) do
            local marker = btn:FindFirstChild("TabMarker")
            if marker then
                tw(marker, 0.25, {
                    Size = (tn == name) and UDim2.new(0, 3, 1, -8) or UDim2.new(0, 3, 0, 4),
                    BackgroundTransparency = (tn == name) and 0 or 1,
                }, Enum.EasingStyle.Back)
            end
        end
        selectedTab = name
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE TAB (estilo Redz — compacto, ícone esquerda, marcador fino)
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateTab(tabName, iconName)
        local icon = getIcon(iconName)

        local tabBtn = Instance.new("TextButton", sidebar)
        tabBtn.Size = UDim2.new(1, 0, 0, 24)
        tabBtn.Text = ""
        tabBtn.BackgroundColor3 = T.surface
        tabBtn.BackgroundTransparency = 1
        tabBtn.AutoButtonColor = false
        tabBtn.ClipsDescendants = true
        newCorner(tabBtn, UDim.new(0, 5))
        local tabStroke = newStroke(tabBtn, T.stroke, 1, 1)

        local marker = Instance.new("Frame", tabBtn)
        marker.Name = "TabMarker"
        marker.Size = UDim2.new(0, 3, 1, -8)
        marker.Position = UDim2.new(0, 0, 0, 4)
        marker.BackgroundColor3 = T.accentHi
        marker.BorderSizePixel = 0
        marker.BackgroundTransparency = 1
        newCorner(marker, UDim.new(0, 3))

        local iconImg
        if icon then
            iconImg = Instance.new("ImageLabel", tabBtn)
            iconImg.Size = UDim2.new(0, 13, 0, 13)
            iconImg.Position = UDim2.new(0, 8, 0.5, -6.5)
            iconImg.BackgroundTransparency = 1
            iconImg.Image = icon
            iconImg.ImageColor3 = T.textDim
            iconImg.ImageTransparency = 0.3
        end

        local label = Instance.new("TextLabel", tabBtn)
        label.BackgroundTransparency = 1
        label.Text = tabName
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 11
        label.TextColor3 = T.text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextTransparency = 0.3
        label.TextTruncate = Enum.TextTruncate.AtEnd
        label.Position = iconImg and UDim2.new(0, 26, 0, 0) or UDim2.new(0, 12, 0, 0)
        label.Size = iconImg and UDim2.new(1, -30, 1, 0) or UDim2.new(1, -12, 1, 0)

        tabBtns[tabName] = tabBtn

        onTheme(function()
            tw(tabStroke, 0.35, { Color = T.stroke })
            if selectedTab == tabName then
                tw(tabBtn, 0.35, { BackgroundColor3 = T.surfaceHi, BackgroundTransparency = 0 })
                tw(label, 0.35, { TextColor3 = T.text, TextTransparency = 0 })
                if iconImg then tw(iconImg, 0.35, { ImageColor3 = T.accentHi, ImageTransparency = 0 }) end
                tw(marker, 0.35, { BackgroundColor3 = T.accentHi })
            else
                tw(tabBtn, 0.35, { BackgroundColor3 = T.surface, BackgroundTransparency = 1 })
                tw(label, 0.35, { TextColor3 = T.text, TextTransparency = 0.3 })
                if iconImg then tw(iconImg, 0.35, { ImageColor3 = T.textDim, ImageTransparency = 0.3 }) end
            end
        end)

        tabBtn.MouseEnter:Connect(function()
            if selectedTab ~= tabName then
                tw(tabBtn, 0.18, { BackgroundColor3 = T.surfaceHi, BackgroundTransparency = 0.4 })
                tw(label, 0.18, { TextTransparency = 0.05 })
                if iconImg then tw(iconImg, 0.18, { ImageTransparency = 0.05, ImageColor3 = T.text }) end
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if selectedTab ~= tabName then
                tw(tabBtn, 0.18, { BackgroundColor3 = T.surface, BackgroundTransparency = 1 })
                tw(label, 0.18, { TextTransparency = 0.3 })
                if iconImg then tw(iconImg, 0.18, { ImageTransparency = 0.3, ImageColor3 = T.textDim }) end
            end
        end)

        local page = Instance.new("Frame", contentHolder)
        page.Name = tabName
        page.Size = UDim2.new(1, 0, 0, 1000)
        page.BackgroundTransparency = 1
        page.Visible = false
        local layout = Instance.new("UIListLayout", page)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 5)
        newPad(page, 2, 2, 8, 2)
        pages[tabName] = page

        tabBtn.MouseButton1Click:Connect(function()
            switchTab(tabName)
        end)

        if not selectedTab then switchTab(tabName) end

        local Tab = {}

        -- ═══════════════ SECTION (estilo Redz — título pequeno sem barra)
        function Tab:AddSection(name)
            local s = Instance.new("Frame", page)
            s.Size = UDim2.new(1, 0, 0, 22)
            s.BackgroundTransparency = 1

            local lbl = Instance.new("TextLabel", s)
            lbl.BackgroundTransparency = 1
            lbl.Text = string.upper(name or "SECTION")
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 10
            lbl.TextColor3 = T.text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Position = UDim2.new(0, 4, 0, 0)
            lbl.Size = UDim2.new(1, -10, 1, 0)
            lbl.TextTransparency = 0.15

            local line = Instance.new("Frame", s)
            line.Size = UDim2.new(1, -8, 0, 1)
            line.Position = UDim2.new(0, 4, 1, -3)
            line.BackgroundColor3 = T.stroke
            line.BackgroundTransparency = 0.3
            line.BorderSizePixel = 0

            onTheme(function()
                tw(lbl, 0.35, { TextColor3 = T.text })
                tw(line, 0.35, { BackgroundColor3 = T.stroke })
            end)

            return {
                Set = function(_, v) lbl.Text = string.upper(v) end,
                Destroy = function() s:Destroy() end,
            }
        end

        -- ═══════════════ Helper: cria o "row" compacto estilo Redz
        local function makeRow(title, desc, height)
            local f = Instance.new("Frame", page)
            f.Size = UDim2.new(1, 0, 0, height or 26)
            f.BackgroundColor3 = T.surface
            f.BackgroundTransparency = 0.05
            f.BorderSizePixel = 0
            f.AutomaticSize = desc and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
            newCorner(f, UDim.new(0, 5))
            local fStroke = newStroke(f, T.stroke, 1, 0.7)

            -- Holder dos labels (stack vertical)
            local labelHolder = Instance.new("Frame", f)
            labelHolder.BackgroundTransparency = 1
            labelHolder.AutomaticSize = Enum.AutomaticSize.Y
            labelHolder.Position = UDim2.new(0, 10, 0, 0)
            labelHolder.Size = UDim2.new(1, -20, 1, 0)
            local lhLay = Instance.new("UIListLayout", labelHolder)
            lhLay.SortOrder = Enum.SortOrder.LayoutOrder
            lhLay.VerticalAlignment = Enum.VerticalAlignment.Center

            local titleLbl = Instance.new("TextLabel", labelHolder)
            titleLbl.BackgroundTransparency = 1
            titleLbl.Text = title or "Row"
            titleLbl.Font = Enum.Font.GothamMedium
            titleLbl.TextSize = 11
            titleLbl.TextColor3 = T.text
            titleLbl.TextXAlignment = Enum.TextXAlignment.Left
            titleLbl.Size = UDim2.new(1, 0, 0, 12)
            titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
            titleLbl.LayoutOrder = 1

            local descLbl
            if desc and desc ~= "" then
                f.Size = UDim2.new(1, 0, 0, 32)
                descLbl = Instance.new("TextLabel", labelHolder)
                descLbl.BackgroundTransparency = 1
                descLbl.Text = desc
                descLbl.Font = Enum.Font.Gotham
                descLbl.TextSize = 9
                descLbl.TextColor3 = T.textDim
                descLbl.TextXAlignment = Enum.TextXAlignment.Left
                descLbl.Size = UDim2.new(1, 0, 0, 10)
                descLbl.TextTruncate = Enum.TextTruncate.AtEnd
                descLbl.LayoutOrder = 2
            end

            onTheme(function()
                tw(f, 0.35, { BackgroundColor3 = T.surface })
                tw(fStroke, 0.35, { Color = T.stroke })
                tw(titleLbl, 0.35, { TextColor3 = T.text })
                if descLbl then tw(descLbl, 0.35, { TextColor3 = T.textDim }) end
            end)

            return f, titleLbl, descLbl, fStroke
        end

        -- ═══════════════ LABEL
        function Tab:AddLabel(text)
            local lbl = Instance.new("TextLabel", page)
            lbl.Size = UDim2.new(1, -8, 0, 16)
            lbl.BackgroundTransparency = 1
            lbl.Text = text or ""
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 10
            lbl.TextColor3 = T.textDim
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextWrapped = true
            onTheme(function() tw(lbl, 0.35, { TextColor3 = T.textDim }) end)
            return { Set = function(_, v) lbl.Text = tostring(v) end, Destroy = function() lbl:Destroy() end }
        end

        -- ═══════════════ PARAGRAPH
        function Tab:AddParagraph(cfg)
            cfg = cfg or {}
            if type(cfg) == "string" then cfg = { Title = cfg } end
            local f, tL, dL = makeRow(cfg.Title or "Paragraph", cfg.Text or "", nil)
            return {
                SetTitle = function(_, v) tL.Text = tostring(v) end,
                SetDesc = function(_, v) dL.Text = tostring(v) end,
                Destroy = function() f:Destroy() end,
            }
        end

        -- ═══════════════ BUTTON (compacto, ícone arrow direita)
        function Tab:AddButton(cfg)
            cfg = cfg or {}
            if type(cfg) == "string" then cfg = { Title = cfg } end
            local title = cfg.Title or cfg.Name or "Button"
            local desc = cfg.Desc or cfg.Description or ""
            local cb = cfg.Callback or function() end
            local cooldown = cfg.Cooldown or 0.5

            local f, tL, dL, fS = makeRow(title, desc)
            f.Name = "Option"

            -- Icon arrow
            local arrow = Instance.new("ImageLabel", f)
            arrow.Size = UDim2.new(0, 12, 0, 12)
            arrow.Position = UDim2.new(1, -12, 0.5, -6)
            arrow.BackgroundTransparency = 1
            arrow.Image = "rbxassetid://10709791437"
            arrow.ImageColor3 = T.textDim

            local btn = Instance.new("TextButton", f)
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.ZIndex = 10

            f.MouseEnter:Connect(function()
                tw(f, 0.15, { BackgroundColor3 = T.surfaceHi, BackgroundTransparency = 0 })
                tw(fS, 0.15, { Color = T.accentHi, Transparency = 0.3 })
                tw(arrow, 0.15, { ImageColor3 = T.accentHi })
            end)
            f.MouseLeave:Connect(function()
                tw(f, 0.15, { BackgroundColor3 = T.surface, BackgroundTransparency = 0.05 })
                tw(fS, 0.15, { Color = T.stroke, Transparency = 0.7 })
                tw(arrow, 0.15, { ImageColor3 = T.textDim })
            end)

            local cooling = false
            btn.MouseButton1Click:Connect(function()
                if cooling then return end
                cooling = true
                -- flash
                local flash = Instance.new("Frame", f)
                flash.Size = UDim2.new(1, 0, 1, 0)
                flash.BackgroundColor3 = T.accentHi
                flash.BackgroundTransparency = 0.7
                flash.BorderSizePixel = 0
                flash.ZIndex = 1
                newCorner(flash, UDim.new(0, 5))
                tw(flash, 0.4, { BackgroundTransparency = 1 })
                task.delay(0.4, function() flash:Destroy() end)

                tw(f, 0.06, { Size = UDim2.new(1, -4, 0, f.Size.Y.Offset) })
                task.delay(0.06, function()
                    tw(f, 0.15, { Size = UDim2.new(1, 0, 0, f.Size.Y.Offset) }, Enum.EasingStyle.Back)
                end)

                pcall(cb)
                task.delay(cooldown, function() cooling = false end)
            end)

            return {
                Set = function(_, v) tL.Text = tostring(v) end,
                Destroy = function() f:Destroy() end,
            }
        end

        -- ═══════════════ TOGGLE (compacto, switch pequeno na direita)
        function Tab:AddToggle(cfg)
            cfg = cfg or {}
            if type(cfg) == "string" then cfg = { Title = cfg } end
            local title = cfg.Title or cfg.Name or "Toggle"
            local desc = cfg.Desc or cfg.Description or ""
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag
            local default = cfg.Default or false
            if flag and NINOMAX.Flags[flag] ~= nil then default = NINOMAX.Flags[flag] end

            local f, tL, dL, fS = makeRow(title, desc)
            f.Name = "Option"

            -- Switch compacto (32x18)
            local sw = Instance.new("Frame", f)
            sw.Size = UDim2.new(0, 32, 0, 16)
            sw.Position = UDim2.new(1, -10, 0.5, -8)
            sw.AnchorPoint = Vector2.new(1, 0)
            sw.BackgroundColor3 = T.stroke
            sw.BorderSizePixel = 0
            newCorner(sw, UDim.new(1, 0))

            local ball = Instance.new("Frame", sw)
            ball.Size = UDim2.new(0, 12, 0, 12)
            ball.Position = UDim2.new(0, 2, 0.5, -6)
            ball.AnchorPoint = Vector2.new(0, 0)
            ball.BackgroundColor3 = Color3.fromRGB(200, 200, 205)
            ball.BorderSizePixel = 0
            newCorner(ball, UDim.new(1, 0))

            local btn = Instance.new("TextButton", f)
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.ZIndex = 10

            local isOn = default
            local cooling = false

            local function apply(v, silent)
                isOn = v
                if isOn then
                    tw(sw, 0.25, { BackgroundColor3 = T.accent }, Enum.EasingStyle.Back)
                    tw(ball, 0.25, { Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Color3.new(1, 1, 1) }, Enum.EasingStyle.Back)
                else
                    tw(sw, 0.25, { BackgroundColor3 = T.stroke }, Enum.EasingStyle.Back)
                    tw(ball, 0.25, { Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Color3.fromRGB(200, 200, 205) }, Enum.EasingStyle.Back)
                end
                if not silent then
                    if flag then NINOMAX:SetFlag(flag, isOn) end
                    pcall(cb, isOn)
                end
            end

            apply(default, true)

            onTheme(function()
                if isOn then tw(sw, 0.35, { BackgroundColor3 = T.accent })
                else tw(sw, 0.35, { BackgroundColor3 = T.stroke }) end
            end)

            btn.MouseEnter:Connect(function()
                tw(f, 0.15, { BackgroundColor3 = T.surfaceHi, BackgroundTransparency = 0 })
                tw(fS, 0.15, { Color = T.accentHi, Transparency = 0.3 })
            end)
            btn.MouseLeave:Connect(function()
                tw(f, 0.15, { BackgroundColor3 = T.surface, BackgroundTransparency = 0.05 })
                tw(fS, 0.15, { Color = T.stroke, Transparency = 0.7 })
            end)

            btn.MouseButton1Click:Connect(function()
                if cooling then return end
                cooling = true
                apply(not isOn)
                task.delay(0.2, function() cooling = false end)
            end)

            return {
                Set = function(_, v) apply(v, false) end,
                Get = function() return isOn end,
                Destroy = function() f:Destroy() end,
            }
        end

        -- ═══════════════ SLIDER (compacto, fill + knob mini)
        function Tab:AddSlider(cfg)
            cfg = cfg or {}
            local title = cfg.Title or cfg.Name or "Slider"
            local desc = cfg.Desc or cfg.Description or ""
            local min = cfg.Min or 0
            local max = cfg.Max or 100
            local default = cfg.Default or min
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag
            local suffix = cfg.Suffix or ""
            if flag and NINOMAX.Flags[flag] ~= nil then default = NINOMAX.Flags[flag] end

            local holder = Instance.new("Frame", page)
            holder.Size = UDim2.new(1, 0, 0, 0)
            holder.BackgroundTransparency = 1
            holder.AutomaticSize = Enum.AutomaticSize.Y
            local lay = Instance.new("UIListLayout", holder)

            local bg = Instance.new("Frame", holder)
            bg.Size = UDim2.new(1, 0, 0, 44)
            bg.BackgroundColor3 = T.surface
            bg.BackgroundTransparency = 0.05
            bg.BorderSizePixel = 0
            newCorner(bg, UDim.new(0, 5))
            local bgS = newStroke(bg, T.stroke, 1, 0.7)

            local t = Instance.new("TextLabel", bg)
            t.Size = UDim2.new(1, -60, 0, 12)
            t.Position = UDim2.new(0, 10, 0, 6)
            t.Text = title
            t.TextColor3 = T.text
            t.TextSize = 11
            t.Font = Enum.Font.GothamMedium
            t.BackgroundTransparency = 1
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.TextTruncate = Enum.TextTruncate.AtEnd

            local vl = Instance.new("TextLabel", bg)
            vl.Size = UDim2.new(0, 50, 0, 12)
            vl.Position = UDim2.new(1, -60, 0, 6)
            vl.Text = tostring(default) .. suffix
            vl.TextColor3 = T.accentHi
            vl.TextSize = 11
            vl.Font = Enum.Font.GothamBold
            vl.BackgroundTransparency = 1
            vl.TextXAlignment = Enum.TextXAlignment.Right

            local bar = Instance.new("Frame", bg)
            bar.Size = UDim2.new(1, -20, 0, 6)
            bar.Position = UDim2.new(0, 10, 0, 30)
            bar.BackgroundColor3 = T.stroke
            bar.BorderSizePixel = 0
            newCorner(bar, UDim.new(1, 0))

            local fill = Instance.new("Frame", bar)
            fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = T.accent
            fill.BorderSizePixel = 0
            newCorner(fill, UDim.new(1, 0))
            local fg = Instance.new("UIGradient", fill)
            fg.Color = ColorSequence.new(T.accentSoft, T.accentHi)

            local knob = Instance.new("Frame", bar)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Size = UDim2.new(0, 10, 0, 10)
            knob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
            knob.BorderSizePixel = 0
            newCorner(knob, UDim.new(1, 0))

            onTheme(function()
                tw(bg, 0.35, { BackgroundColor3 = T.surface })
                tw(bgS, 0.35, { Color = T.stroke })
                tw(t, 0.35, { TextColor3 = T.text })
                tw(fill, 0.35, { BackgroundColor3 = T.accent })
                tw(fg, 0.35, { Color = ColorSequence.new(T.accentSoft, T.accentHi) })
                tw(vl, 0.35, { TextColor3 = T.accentHi })
                tw(bar, 0.35, { BackgroundColor3 = T.stroke })
            end)

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
                    tw(knob, 0.12, { Size = UDim2.new(0, 13, 0, 13) }, Enum.EasingStyle.Back)
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
                    tw(knob, 0.15, { Size = UDim2.new(0, 10, 0, 10) }, Enum.EasingStyle.Back)
                end
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

        -- ═══════════════ DROPDOWN (flutuante estilo Redz)
        function Tab:AddDropdown(cfg)
            cfg = cfg or {}
            local title = cfg.Title or cfg.Name or "Dropdown"
            local desc = cfg.Desc or cfg.Description or ""
            local options = cfg.Options or {}
            local default = cfg.Default
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag
            if flag and NINOMAX.Flags[flag] ~= nil then default = NINOMAX.Flags[flag] end

            local f, tL, dL, fS = makeRow(title, desc)
            f.Name = "Option"

            -- Valor selecionado (à direita)
            local sel = Instance.new("TextLabel", f)
            sel.BackgroundTransparency = 1
            sel.Text = tostring(default or "Selecionar")
            sel.TextColor3 = T.accentHi
            sel.Font = Enum.Font.GothamBold
            sel.TextSize = 10
            sel.TextXAlignment = Enum.TextXAlignment.Right
            sel.TextTruncate = Enum.TextTruncate.AtEnd
            sel.Position = UDim2.new(1, -32, 0, 0)
            sel.Size = UDim2.new(0.5, -30, 1, 0)

            -- Arrow
            local arrow = Instance.new("ImageLabel", f)
            arrow.Size = UDim2.new(0, 11, 0, 11)
            arrow.Position = UDim2.new(1, -12, 0.5, -5.5)
            arrow.BackgroundTransparency = 1
            arrow.Image = "rbxassetid://10709790948"
            arrow.ImageColor3 = T.textDim

            local btn = Instance.new("TextButton", f)
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.ZIndex = 10

            -- Overlay de clique fora
            local overlay = Instance.new("TextButton", gui)
            overlay.Size = UDim2.new(1, 0, 1, 0)
            overlay.BackgroundTransparency = 1
            overlay.Text = ""
            overlay.Visible = false
            overlay.ZIndex = 500

            -- Dropdown list flutuante
            local list = Instance.new("Frame", gui)
            list.Size = UDim2.new(0, 180, 0, 0)
            list.BackgroundColor3 = T.surface
            list.BorderSizePixel = 0
            list.Visible = false
            list.ClipsDescendants = true
            list.ZIndex = 999
            newCorner(list, UDim.new(0, 6))
            local listStroke = newStroke(list, T.stroke, 1, 0.4)

            local scroll = Instance.new("ScrollingFrame", list)
            scroll.Size = UDim2.new(1, 0, 1, 0)
            scroll.BackgroundTransparency = 1
            scroll.BorderSizePixel = 0
            scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            scroll.ScrollBarThickness = 2
            scroll.ScrollBarImageColor3 = T.accent

            local listLay = Instance.new("UIListLayout", scroll)
            listLay.Padding = UDim.new(0, 2)
            listLay.SortOrder = Enum.SortOrder.LayoutOrder
            newPad(scroll, 4, 4, 4, 4)

            local selected = default
            local optBtns = {}

            local function updateLabel()
                sel.Text = tostring(selected or "Selecionar")
            end

            local function closeList()
                list.Visible = false
                overlay.Visible = false
                tw(arrow, 0.2, { Rotation = 0 })
            end

            for i, opt in ipairs(options) do
                local o = Instance.new("TextButton", scroll)
                o.Size = UDim2.new(1, 0, 0, 22)
                o.BackgroundColor3 = T.surfaceHi
                o.BackgroundTransparency = 1
                o.Text = ""
                o.AutoButtonColor = false
                o.LayoutOrder = i
                o.ZIndex = 1000
                newCorner(o, UDim.new(0, 4))

                local dot = Instance.new("Frame", o)
                dot.Size = UDim2.new(0, 5, 0, 5)
                dot.Position = UDim2.new(0, 6, 0.5, -2.5)
                dot.BackgroundColor3 = T.accentHi
                dot.BorderSizePixel = 0
                dot.Visible = (selected == opt)
                newCorner(dot, UDim.new(1, 0))

                local ol = Instance.new("TextLabel", o)
                ol.BackgroundTransparency = 1
                ol.Text = tostring(opt)
                ol.TextColor3 = T.text
                ol.TextTransparency = (selected == opt) and 0 or 0.35
                ol.Font = Enum.Font.GothamMedium
                ol.TextSize = 10
                ol.TextXAlignment = Enum.TextXAlignment.Left
                ol.Position = UDim2.new(0, 18, 0, 0)
                ol.Size = UDim2.new(1, -22, 1, 0)
                ol.TextTruncate = Enum.TextTruncate.AtEnd

                o.MouseEnter:Connect(function()
                    tw(o, 0.12, { BackgroundColor3 = T.surfaceHi, BackgroundTransparency = 0 })
                    tw(ol, 0.12, { TextTransparency = 0 })
                end)
                o.MouseLeave:Connect(function()
                    tw(o, 0.12, { BackgroundTransparency = 1 })
                    if selected ~= opt then tw(ol, 0.12, { TextTransparency = 0.35 }) end
                end)
                o.MouseButton1Click:Connect(function()
                    for k, v in pairs(optBtns) do
                        v.dot.Visible = false
                        tw(v.label, 0.2, { TextTransparency = 0.35 })
                    end
                    dot.Visible = true
                    tw(ol, 0.2, { TextTransparency = 0 })
                    selected = opt
                    updateLabel()
                    if flag then NINOMAX:SetFlag(flag, selected) end
                    pcall(cb, opt)
                    closeList()
                end)

                optBtns[opt] = { btn = o, dot = dot, label = ol }
            end

            local function openList()
                list.Visible = true
                overlay.Visible = true
                -- posiciona em baixo do botão
                local ap = f.AbsolutePosition
                local av = f.AbsoluteSize
                list.Position = UDim2.new(0, ap.X, 0, ap.Y + av.Y + 4)
                local targetH = math.min(#options * 26 + 12, 220)
                list.Size = UDim2.new(0, 180, 0, 0)
                tw(list, 0.25, { Size = UDim2.new(0, 180, 0, targetH) }, Enum.EasingStyle.Back)
                tw(arrow, 0.2, { Rotation = 180 })
            end

            btn.MouseButton1Click:Connect(function()
                if list.Visible then closeList() else openList() end
            end)

            overlay.MouseButton1Click:Connect(closeList)

            f.MouseEnter:Connect(function()
                tw(f, 0.15, { BackgroundColor3 = T.surfaceHi, BackgroundTransparency = 0 })
                tw(fS, 0.15, { Color = T.accentHi, Transparency = 0.3 })
            end)
            f.MouseLeave:Connect(function()
                tw(f, 0.15, { BackgroundColor3 = T.surface, BackgroundTransparency = 0.05 })
                tw(fS, 0.15, { Color = T.stroke, Transparency = 0.7 })
            end)

            onTheme(function()
                tw(list, 0.35, { BackgroundColor3 = T.surface })
                tw(listStroke, 0.35, { Color = T.stroke })
                for _, v in pairs(optBtns) do
                    tw(v.dot, 0.35, { BackgroundColor3 = T.accentHi })
                    tw(v.label, 0.35, { TextColor3 = T.text })
                end
                tw(sel, 0.35, { TextColor3 = T.accentHi })
            end)

            return {
                Set = function(_, v)
                    selected = v
                    for k, v2 in pairs(optBtns) do
                        v2.dot.Visible = (k == v)
                        tw(v2.label, 0.2, { TextTransparency = (k == v) and 0 or 0.35 })
                    end
                    updateLabel()
                    if flag then NINOMAX:SetFlag(flag, v) end
                    pcall(cb, v)
                end,
                Destroy = function() f:Destroy(); list:Destroy(); overlay:Destroy() end,
            }
        end

        -- ═══════════════ TEXT BOX (compacto)
        function Tab:AddTextBox(cfg)
            cfg = cfg or {}
            if type(cfg) == "string" then cfg = { Title = cfg } end
            local title = cfg.Title or cfg.Name or "Input"
            local placeholder = cfg.Placeholder or cfg.PlaceholderText or "Escreva..."
            local default = cfg.Default or ""
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag
            if flag and NINOMAX.Flags[flag] ~= nil then default = NINOMAX.Flags[flag] end

            local f, tL, dL, fS = makeRow(title, "")
            f.Size = UDim2.new(1, 0, 0, 26)

            local box = Instance.new("TextBox", f)
            box.Size = UDim2.new(0.5, -20, 0, 20)
            box.Position = UDim2.new(1, -12, 0.5, -10)
            box.AnchorPoint = Vector2.new(1, 0)
            box.BackgroundColor3 = T.surfaceHi
            box.BorderSizePixel = 0
            box.Text = default
            box.PlaceholderText = placeholder
            box.PlaceholderColor3 = T.textDim
            box.TextColor3 = T.text
            box.Font = Enum.Font.GothamMedium
            box.TextSize = 10
            box.ClearTextOnFocus = false
            box.TextXAlignment = Enum.TextXAlignment.Left
            box.TextTruncate = Enum.TextTruncate.AtEnd
            box.ZIndex = 10
            newCorner(box, UDim.new(0, 4))
            local boxS = newStroke(box, T.stroke, 1, 0.4)
            newPad(box, 0, 6, 6, 0)

            onTheme(function()
                tw(box, 0.35, { BackgroundColor3 = T.surfaceHi, TextColor3 = T.text, PlaceholderColor3 = T.textDim })
                tw(boxS, 0.35, { Color = T.stroke })
            end)

            box.Focused:Connect(function()
                tw(boxS, 0.2, { Color = T.accentHi, Transparency = 0 })
            end)
            box.FocusLost:Connect(function(enter)
                tw(boxS, 0.2, { Color = T.stroke, Transparency = 0.4 })
                if enter then
                    if flag then NINOMAX:SetFlag(flag, box.Text) end
                    pcall(cb, box.Text)
                end
            end)

            return {
                Set = function(_, v) box.Text = tostring(v) end,
                Get = function() return box.Text end,
                Destroy = function() f:Destroy() end,
            }
        end

        -- ═══════════════ KEYBIND
        function Tab:AddKeybind(cfg)
            cfg = cfg or {}
            local title = cfg.Title or cfg.Name or "Keybind"
            local default = cfg.Default or "Nenhuma"
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag
            if flag and NINOMAX.Flags[flag] ~= nil then default = NINOMAX.Flags[flag] end

            local f, tL, dL, fS = makeRow(title, "")
            f.Size = UDim2.new(1, 0, 0, 26)

            local kbBtn = Instance.new("TextButton", f)
            kbBtn.Size = UDim2.new(0, 80, 0, 18)
            kbBtn.Position = UDim2.new(1, -10, 0.5, -9)
            kbBtn.AnchorPoint = Vector2.new(1, 0)
            kbBtn.BackgroundColor3 = T.surfaceHi
            kbBtn.Text = default
            kbBtn.TextColor3 = T.text
            kbBtn.Font = Enum.Font.Code
            kbBtn.TextSize = 10
            kbBtn.AutoButtonColor = false
            newCorner(kbBtn, UDim.new(0, 4))
            local kbS = newStroke(kbBtn, T.stroke, 1, 0.4)

            local capturing = false
            local currentKey = default

            kbBtn.MouseButton1Click:Connect(function()
                capturing = not capturing
                kbBtn.Text = capturing and "Pressione..." or currentKey
                kbBtn.TextColor3 = capturing and T.accentHi or T.text
                tw(kbS, 0.2, { Color = capturing and T.accentHi or T.stroke })
            end)

            UIS.InputBegan:Connect(function(input, gpe)
                if gpe or not capturing then return end
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode.Name
                    kbBtn.Text = currentKey
                    kbBtn.TextColor3 = T.text
                    capturing = false
                    tw(kbS, 0.2, { Color = T.stroke })
                    if flag then NINOMAX:SetFlag(flag, currentKey) end
                    pcall(cb, input.KeyCode)
                end
            end)

            onTheme(function()
                tw(kbBtn, 0.35, { BackgroundColor3 = T.surfaceHi, TextColor3 = T.text })
                tw(kbS, 0.35, { Color = T.stroke })
            end)

            return {
                Set = function(_, v) currentKey = v; kbBtn.Text = v end,
                Destroy = function() f:Destroy() end,
            }
        end

        -- ═══════════════ COLOR PICKER (compacto + expansion)
        function Tab:AddColorPicker(cfg)
            cfg = cfg or {}
            local title = cfg.Title or cfg.Name or "Cor"
            local default = cfg.Default or Color3.fromRGB(220, 30, 55)
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag

            local current = default
            local h, s, v = Color3.toHSV(current)

            local frame = Instance.new("Frame", page)
            frame.Size = UDim2.new(1, 0, 0, 26)
            frame.BackgroundColor3 = T.surface
            frame.BackgroundTransparency = 0.05
            frame.ClipsDescendants = true
            frame.BorderSizePixel = 0
            newCorner(frame, UDim.new(0, 5))
            local fS = newStroke(frame, T.stroke, 1, 0.7)

            local header = Instance.new("TextButton", frame)
            header.Size = UDim2.new(1, 0, 0, 26)
            header.BackgroundTransparency = 1
            header.Text = ""

            local lbl = Instance.new("TextLabel", header)
            lbl.BackgroundTransparency = 1
            lbl.Text = title
            lbl.TextColor3 = T.text
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.Size = UDim2.new(1, -60, 1, 0)

            local previewDot = Instance.new("Frame", header)
            previewDot.Size = UDim2.new(0, 14, 0, 14)
            previewDot.Position = UDim2.new(1, -32, 0.5, -7)
            previewDot.BackgroundColor3 = current
            previewDot.BorderSizePixel = 0
            newCorner(previewDot, UDim.new(0, 4))
            newStroke(previewDot, Color3.new(1,1,1), 1, 0.6)

            local arrow = Instance.new("TextLabel", header)
            arrow.BackgroundTransparency = 1
            arrow.Text = "▼"
            arrow.TextColor3 = T.textDim
            arrow.Font = Enum.Font.GothamBold
            arrow.TextSize = 10
            arrow.Position = UDim2.new(1, -14, 0.5, -6)
            arrow.Size = UDim2.new(0, 12, 0, 12)

            -- Body
            local body = Instance.new("Frame", frame)
            body.Size = UDim2.new(1, 0, 0, 0)
            body.Position = UDim2.new(0, 0, 0, 26)
            body.BackgroundTransparency = 1
            body.ClipsDescendants = true

            local padSize = 110
            local pad = Instance.new("Frame", body)
            pad.Size = UDim2.new(0, padSize, 0, padSize)
            pad.Position = UDim2.new(0, 10, 0, 10)
            pad.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            pad.BorderSizePixel = 0
            newCorner(pad, UDim.new(0, 6))
            pad.ClipsDescendants = true
            newStroke(pad, T.stroke, 1, 0.5)

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
            padMarker.Size = UDim2.new(0, 10, 0, 10)
            padMarker.AnchorPoint = Vector2.new(0.5, 0.5)
            padMarker.BackgroundColor3 = Color3.new(1, 1, 1)
            padMarker.BorderSizePixel = 0
            newCorner(padMarker, UDim.new(1, 0))
            newStroke(padMarker, Color3.new(0, 0, 0), 1.5, 0.2)
            padMarker.ZIndex = 5

            local hueBar = Instance.new("Frame", body)
            hueBar.Size = UDim2.new(0, 16, 0, padSize)
            hueBar.Position = UDim2.new(0, 10 + padSize + 10, 0, 10)
            hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
            hueBar.BorderSizePixel = 0
            newCorner(hueBar, UDim.new(0, 5))
            newStroke(hueBar, T.stroke, 1, 0.5)
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
            hueMarker.Size = UDim2.new(1, 4, 0, 4)
            hueMarker.AnchorPoint = Vector2.new(0.5, 0.5)
            hueMarker.Position = UDim2.new(0.5, 0, 0, 0)
            hueMarker.BackgroundColor3 = Color3.new(1, 1, 1)
            hueMarker.BorderSizePixel = 0
            newCorner(hueMarker, UDim.new(1, 0))
            newStroke(hueMarker, Color3.new(0, 0, 0), 1, 0.3)

            local infoCol = Instance.new("Frame", body)
            infoCol.Size = UDim2.new(0, 90, 0, padSize)
            infoCol.Position = UDim2.new(1, -100, 0, 10)
            infoCol.BackgroundTransparency = 1

            local hexLbl = Instance.new("TextLabel", infoCol)
            hexLbl.BackgroundTransparency = 1
            hexLbl.Text = "HEX"
            hexLbl.TextColor3 = T.textDim
            hexLbl.Font = Enum.Font.GothamBold
            hexLbl.TextSize = 9
            hexLbl.Position = UDim2.new(0, 0, 0, 0)
            hexLbl.Size = UDim2.new(1, 0, 0, 12)
            hexLbl.TextXAlignment = Enum.TextXAlignment.Left

            local hexBox = Instance.new("TextBox", infoCol)
            hexBox.Size = UDim2.new(1, 0, 0, 22)
            hexBox.Position = UDim2.new(0, 0, 0, 14)
            hexBox.BackgroundColor3 = T.surfaceHi
            hexBox.TextColor3 = T.text
            hexBox.Font = Enum.Font.Code
            hexBox.TextSize = 11
            hexBox.Text = string.format("#%02X%02X%02X",
                math.floor(current.R * 255 + 0.5), math.floor(current.G * 255 + 0.5), math.floor(current.B * 255 + 0.5))
            hexBox.ClearTextOnFocus = false
            newCorner(hexBox, UDim.new(0, 4))
            newStroke(hexBox, T.stroke, 1, 0.5)

            local function updateAll()
                local color = Color3.fromHSV(h, s, v)
                current = color
                pad.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                padMarker.Position = UDim2.new(s, 0, 1 - v, 0)
                hueMarker.Position = UDim2.new(0.5, 0, h, 0)
                previewDot.BackgroundColor3 = color
                hexBox.Text = string.format("#%02X%02X%02X",
                    math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
                if flag then NINOMAX:SetFlag(flag, {math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)}) end
                pcall(cb, color)
            end

            local padDrag = false
            pad.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    padDrag = true
                    local px = math.clamp(i.Position.X - pad.AbsolutePosition.X, 0, pad.AbsoluteSize.X)
                    local py = math.clamp(i.Position.Y - pad.AbsolutePosition.Y, 0, pad.AbsoluteSize.Y)
                    s = px / pad.AbsoluteSize.X
                    v = 1 - (py / pad.AbsoluteSize.Y)
                    updateAll()
                end
            end)
            UIS.InputChanged:Connect(function(i)
                if padDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    local px = math.clamp(i.Position.X - pad.AbsolutePosition.X, 0, pad.AbsoluteSize.X)
                    local py = math.clamp(i.Position.Y - pad.AbsolutePosition.Y, 0, pad.AbsoluteSize.Y)
                    s = px / pad.AbsoluteSize.X
                    v = 1 - (py / pad.AbsoluteSize.Y)
                    updateAll()
                end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    padDrag = false
                end
            end)

            local hueDrag = false
            hueBar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    hueDrag = true
                    local py = math.clamp(i.Position.Y - hueBar.AbsolutePosition.Y, 0, hueBar.AbsoluteSize.Y)
                    h = py / hueBar.AbsoluteSize.Y
                    updateAll()
                end
            end)
            UIS.InputChanged:Connect(function(i)
                if hueDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    local py = math.clamp(i.Position.Y - hueBar.AbsolutePosition.Y, 0, hueBar.AbsoluteSize.Y)
                    h = py / hueBar.AbsoluteSize.Y
                    updateAll()
                end
            end)
            UIS.InputEnded:Connect(function(i)
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
                    math.floor(current.R * 255 + 0.5), math.floor(current.G * 255 + 0.5), math.floor(current.B * 255 + 0.5))
            end)

            local expanded = false
            local function setExpanded(v2)
                expanded = v2
                arrow.Text = expanded and "▲" or "▼"
                local targetH = expanded and (26 + 10 + padSize + 10) or 26
                tw(frame, 0.3, { Size = UDim2.new(1, 0, 0, targetH) }, Enum.EasingStyle.Back)
                body.Size = UDim2.new(1, 0, 0, expanded and (targetH - 26) or 0)
            end
            header.MouseButton1Click:Connect(function() setExpanded(not expanded) end)

            onTheme(function()
                tw(frame, 0.35, { BackgroundColor3 = T.surface })
                tw(fS, 0.35, { Color = T.stroke })
                tw(lbl, 0.35, { TextColor3 = T.text })
                tw(hexBox, 0.35, { BackgroundColor3 = T.surfaceHi, TextColor3 = T.text })
                tw(hexLbl, 0.35, { TextColor3 = T.textDim })
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

        -- ═══════════════ PROGRESS BAR
        function Tab:AddProgressBar(cfg)
            cfg = cfg or {}
            local title = cfg.Title or cfg.Name or "Progresso"

            local f = Instance.new("Frame", page)
            f.Size = UDim2.new(1, 0, 0, 36)
            f.BackgroundColor3 = T.surface
            f.BackgroundTransparency = 0.05
            f.BorderSizePixel = 0
            newCorner(f, UDim.new(0, 5))
            newStroke(f, T.stroke, 1, 0.7)

            local t = Instance.new("TextLabel", f)
            t.Size = UDim2.new(1, -60, 0, 12)
            t.Position = UDim2.new(0, 10, 0, 5)
            t.BackgroundTransparency = 1
            t.Text = title
            t.TextColor3 = T.text
            t.Font = Enum.Font.GothamMedium
            t.TextSize = 11
            t.TextXAlignment = Enum.TextXAlignment.Left

            local pct = Instance.new("TextLabel", f)
            pct.Size = UDim2.new(0, 40, 0, 12)
            pct.Position = UDim2.new(1, -50, 0, 5)
            pct.BackgroundTransparency = 1
            pct.Text = "0%"
            pct.TextColor3 = T.accentHi
            pct.Font = Enum.Font.GothamBold
            pct.TextSize = 11
            pct.TextXAlignment = Enum.TextXAlignment.Right

            local bar = Instance.new("Frame", f)
            bar.Size = UDim2.new(1, -20, 0, 6)
            bar.Position = UDim2.new(0, 10, 0, 24)
            bar.BackgroundColor3 = T.stroke
            bar.BorderSizePixel = 0
            newCorner(bar, UDim.new(1, 0))

            local fill = Instance.new("Frame", bar)
            fill.Size = UDim2.new(0, 0, 1, 0)
            fill.BackgroundColor3 = T.accent
            fill.BorderSizePixel = 0
            newCorner(fill, UDim.new(1, 0))
            local fg = Instance.new("UIGradient", fill)
            fg.Color = ColorSequence.new(T.accentSoft, T.accentHi)

            onTheme(function()
                tw(f, 0.35, { BackgroundColor3 = T.surface })
                tw(t, 0.35, { TextColor3 = T.text })
                tw(pct, 0.35, { TextColor3 = T.accentHi })
                tw(bar, 0.35, { BackgroundColor3 = T.stroke })
                tw(fill, 0.35, { BackgroundColor3 = T.accent })
                tw(fg, 0.35, { Color = ColorSequence.new(T.accentSoft, T.accentHi) })
            end)

            return {
                Set = function(_, value)
                    local p = math.clamp(value / 100, 0, 1)
                    fill:TweenSize(UDim2.new(p, 0, 1, 0), "Out", "Quart", 0.35, true)
                    pct.Text = string.format("%d%%", math.floor(p * 100 + 0.5))
                end,
                Destroy = function() f:Destroy() end,
            }
        end

        -- ═══════════════ LINE
        function Tab:AddLine(color)
            local l = Instance.new("Frame", page)
            l.Size = UDim2.new(1, -8, 0, 1)
            l.BackgroundColor3 = color or T.stroke
            l.BackgroundTransparency = 0.4
            l.BorderSizePixel = 0
            local g = Instance.new("UIGradient", l)
            g.Transparency = NumberSequence.new(1, 0, 1)
            onTheme(function() tw(l, 0.35, { BackgroundColor3 = color or T.stroke }) end)
            return { Destroy = function() l:Destroy() end }
        end

        return Tab
    end

    -- ═══════════════════════════════════════════════════════════════
    -- WINDOW METHODS
    -- ═══════════════════════════════════════════════════════════════
    function Window:SetTheme(name)
        if NINOMAX.Themes[name] then
            NINOMAX.CurrentTheme = name
            T = NINOMAX.Themes[name]
            broadcastTheme()
        end
    end

    function Window:GetTheme() return NINOMAX.CurrentTheme end

    function Window:SetSubtitle(text)
        subtitle.Text = tostring(text)
        task.defer(function()
            local w1 = titleNino.TextBounds.X
            local w2 = titleMax.TextBounds.X
            subtitle.Position = UDim2.new(0, 15 + w1 + w2 + 8, 0.5, 3)
        end)
    end

    function Window:SetTitle(text)
        text = tostring(text)
        local mid = math.floor(#text / 2)
        titleNino.Text = text:sub(1, mid)
        titleMax.Text = text:sub(mid + 1)
        task.defer(function()
            local w1 = titleNino.TextBounds.X
            titleMax.Position = UDim2.new(0, 15 + w1 + 1, 0.5, -1)
        end)
    end

    -- ═══════════════ NOTIFY
    local notifyQueue, notifying = {}, false

    function Window:Notify(cfg)
        cfg = cfg or {}
        local title = cfg.Title or "Aviso"
        local text = cfg.Text or cfg.Description or ""
        local duration = cfg.Duration or 3
        local type_ = cfg.Type or "info"

        local sg = Instance.new("ScreenGui")
        sg.Name = "NINOMAX_Notify"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        sg.DisplayOrder = 100000
        pcall(function() sg.Parent = CoreGui end)
        if not sg.Parent then sg.Parent = player:WaitForChild("PlayerGui") end

        local frame = Instance.new("Frame", sg)
        frame.Size = UDim2.new(0, 280, 0, 60)
        frame.Position = UDim2.new(1, 320, 1, -20)
        frame.AnchorPoint = Vector2.new(1, 1)
        frame.BackgroundColor3 = T.bg
        frame.BackgroundTransparency = 0.05
        frame.BorderSizePixel = 0
        newCorner(frame, UDim.new(0, 8))
        newStroke(frame, T.accentHi, 1.2, 0.3)

        local grad = Instance.new("UIGradient", frame)
        grad.Rotation = 45
        grad.Color = T.gradient

        -- barra lateral colorida
        local accentColor = ({
            info = T.accent,
            success = Color3.fromRGB(60, 220, 120),
            warning = Color3.fromRGB(255, 180, 50),
            danger = Color3.fromRGB(255, 80, 90),
        })[type_] or T.accent

        local side = Instance.new("Frame", frame)
        side.Size = UDim2.new(0, 3, 1, -16)
        side.Position = UDim2.new(0, 8, 0, 8)
        side.BackgroundColor3 = accentColor
        side.BorderSizePixel = 0
        newCorner(side, UDim.new(0, 2))

        local prog = Instance.new("Frame", frame)
        prog.Size = UDim2.new(1, 0, 0, 2)
        prog.Position = UDim2.new(0, 0, 1, -2)
        prog.BackgroundColor3 = accentColor
        prog.BorderSizePixel = 0
        newCorner(prog, UDim.new(1, 0))

        local tl = Instance.new("TextLabel", frame)
        tl.BackgroundTransparency = 1
        tl.Text = title
        tl.TextColor3 = T.text
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 12
        tl.TextXAlignment = Enum.TextXAlignment.Left
        tl.Position = UDim2.new(0, 20, 0, 8)
        tl.Size = UDim2.new(1, -28, 0, 16)

        local xl = Instance.new("TextLabel", frame)
        xl.BackgroundTransparency = 1
        xl.Text = text
        xl.TextColor3 = T.textDim
        xl.Font = Enum.Font.Gotham
        xl.TextSize = 10
        xl.TextWrapped = true
        xl.TextXAlignment = Enum.TextXAlignment.Left
        xl.TextYAlignment = Enum.TextYAlignment.Top
        xl.Position = UDim2.new(0, 20, 0, 26)
        xl.Size = UDim2.new(1, -28, 0, 28)

        table.insert(notifyQueue, { frame = frame, gui = sg, duration = duration, prog = prog })

        if not notifying then
            notifying = true
            task.spawn(function()
                while #notifyQueue > 0 do
                    local data = table.remove(notifyQueue, 1)
                    local f = data.frame
                    f:TweenPosition(UDim2.new(1, -20, 1, -20 - (#notifyQueue * 70)), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.35, true)
                    tw(data.prog, data.duration, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
                    task.delay(data.duration, function()
                        f:TweenPosition(UDim2.new(1, 320, 1, -20), Enum.EasingDirection.In, Enum.EasingStyle.Quint, 0.3, true)
                        task.wait(0.35)
                        data.gui:Destroy()
                    end)
                    task.wait(data.duration + 0.35)
                end
                notifying = false
            end)
        end
    end

    -- ═══════════════ DIALOG (estilo Redz, sem transparência excessiva)
    function Window:Dialog(cfg)
        cfg = cfg or {}
        local title = cfg.Title or "Dialog"
        local text = cfg.Text or ""
        local options = cfg.Options or cfg.Buttons or { { "OK", function() end } }

        local overlay = Instance.new("Frame", gui)
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.new(0, 0, 0)
        overlay.BackgroundTransparency = 0.55
        overlay.BorderSizePixel = 0
        overlay.ZIndex = 100

        local dlg = Instance.new("Frame", overlay)
        dlg.Size = UDim2.new(0, 0, 0, 0)
        dlg.Position = UDim2.new(0.5, 0, 0.5, 0)
        dlg.AnchorPoint = Vector2.new(0.5, 0.5)
        dlg.BackgroundColor3 = T.bg
        dlg.BorderSizePixel = 0
        dlg.ZIndex = 101
        newCorner(dlg, UDim.new(0, 8))
        newStroke(dlg, T.stroke, 1.2, 0.3)

        local grad = Instance.new("UIGradient", dlg)
        grad.Rotation = 45
        grad.Color = T.gradient

        local tl = Instance.new("TextLabel", dlg)
        tl.BackgroundTransparency = 1
        tl.Text = title
        tl.TextColor3 = T.text
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 13
        tl.TextXAlignment = Enum.TextXAlignment.Left
        tl.Position = UDim2.new(0, 14, 0, 12)
        tl.Size = UDim2.new(1, -28, 0, 16)

        local xl = Instance.new("TextLabel", dlg)
        xl.BackgroundTransparency = 1
        xl.Text = text
        xl.TextColor3 = T.textDim
        xl.Font = Enum.Font.Gotham
        xl.TextSize = 10
        xl.TextWrapped = true
        xl.TextXAlignment = Enum.TextXAlignment.Left
        xl.TextYAlignment = Enum.TextYAlignment.Top
        xl.Position = UDim2.new(0, 14, 0, 32)
        xl.Size = UDim2.new(1, -28, 0, 40)

        local btnHolder = Instance.new("Frame", dlg)
        btnHolder.Size = UDim2.new(1, -28, 0, 26)
        btnHolder.Position = UDim2.new(0, 14, 1, -36)
        btnHolder.BackgroundTransparency = 1
        local bhl = Instance.new("UIListLayout", btnHolder)
        bhl.FillDirection = Enum.FillDirection.Horizontal
        bhl.Padding = UDim.new(0, 6)
        bhl.HorizontalAlignment = Enum.HorizontalAlignment.Right

        local function close()
            tw(dlg, 0.2, { Size = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            tw(overlay, 0.2, { BackgroundTransparency = 1 })
            task.delay(0.25, function() overlay:Destroy() end)
        end

        local Dialog = { Close = close }

        for _, btnData in ipairs(options) do
            local name = btnData[1]
            local cb = btnData[2] or function() end
            local b = Instance.new("TextButton", btnHolder)
            b.Size = UDim2.new(0, 80, 1, 0)
            b.BackgroundColor3 = T.surfaceHi
            b.Text = name
            b.TextColor3 = T.text
            b.Font = Enum.Font.GothamBold
            b.TextSize = 10
            b.AutoButtonColor = false
            newCorner(b, UDim.new(0, 5))
            newStroke(b, T.stroke, 1, 0.4)
            b.MouseEnter:Connect(function() tw(b, 0.15, { BackgroundColor3 = mix(T.surfaceHi, T.accent, 0.35) }) end)
            b.MouseLeave:Connect(function() tw(b, 0.15, { BackgroundColor3 = T.surfaceHi }) end)
            b.MouseButton1Click:Connect(function()
                close()
                task.delay(0.25, function() pcall(cb) end)
            end)
        end

        tw(dlg, 0.3, { Size = UDim2.new(0, 300, 0, 150) }, Enum.EasingStyle.Back)
        return Dialog
    end

    -- Close button
    btnClose.MouseButton1Click:Connect(function()
        Window:Dialog({
            Title = "Fechar NINOMAX?",
            Text = "Deseja realmente fechar?",
            Options = {
                { "Fechar", function()
                    tw(mainFrame, 0.25, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                    tw(shadowImg, 0.25, { ImageTransparency = 1 })
                    task.delay(0.3, function() gui:Destroy() end)
                end },
                { "Cancelar", function() end },
            }
        })
    end)

    -- Helper para mistura (usado no Dialog)
    local function mix(a, b, t)
        return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t)
    end

    return Window
end

return NINOMAX
