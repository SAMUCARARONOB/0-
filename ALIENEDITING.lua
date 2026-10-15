--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║  NINOMAX UI · v1.2.0 · FLAT + TAB API                            ║
    ║  ✦ Dupla API: Window:CreateX e Tab:AddX                          ║
    ║  ✦ Slider turbo · Dropdown premium · TextBox avançado            ║
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
NINOMAX.Version = "1.2.0"
NINOMAX.Flags = {}

NINOMAX.Icons = {
    activity="rbxassetid://10709752035", alertcircle="rbxassetid://10709752996",
    arrowright="rbxassetid://10709768347", award="rbxassetid://10709769406",
    check="rbxassetid://10709790644", checkcircle="rbxassetid://10709790387",
    chevronright="rbxassetid://10709791437", chevronup="rbxassetid://10709791523",
    chevrondown="rbxassetid://10709790948", clock="rbxassetid://10709805144",
    close="rbxassetid://10747384394", code="rbxassetid://10709810463",
    cog="rbxassetid://10709810948", copy="rbxassetid://10709812159",
    cpu="rbxassetid://10709813383", crown="rbxassetid://10709818626",
    edit="rbxassetid://10734883598", eye="rbxassetid://10723346959",
    eyeoff="rbxassetid://10723346871", fire="rbxassetid://10723376114",
    flag="rbxassetid://10723375890", flame="rbxassetid://10723376114",
    gift="rbxassetid://10723396402", globe="rbxassetid://10723404337",
    grid="rbxassetid://10723404936", heart="rbxassetid://10723406885",
    home="rbxassetid://10723407389", info="rbxassetid://10723415903",
    key="rbxassetid://10723416652", lightbulb="rbxassetid://10723425852",
    link="rbxassetid://10723426722", list="rbxassetid://10723433811",
    lock="rbxassetid://10723434711", minus="rbxassetid://10734896206",
    palette="rbxassetid://10734910430", play="rbxassetid://10734923549",
    plus="rbxassetid://10734924532", power="rbxassetid://10734930466",
    refreshcw="rbxassetid://10734933222", rocket="rbxassetid://10734934585",
    save="rbxassetid://10734941499", search="rbxassetid://10734943674",
    settings="rbxassetid://10734950309", shield="rbxassetid://10734951847",
    skull="rbxassetid://10734962068", star="rbxassetid://10734966248",
    sword="rbxassetid://10734975486", swords="rbxassetid://10734975692",
    target="rbxassetid://10734977012", trash="rbxassetid://10747362393",
    trophy="rbxassetid://10747363809", unlock="rbxassetid://10747366027",
    user="rbxassetid://10747373176", users="rbxassetid://10747373426",
    wand="rbxassetid://10747376565", wrench="rbxassetid://10747383470",
    x="rbxassetid://10747384394", zap="rbxassetid://10734974297",
    ball="rbxassetid://6337069410",
}

NINOMAX.Themes = {
    Crimson={gradient=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(28,12,14)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(38,16,20)),ColorSequenceKeypoint.new(1,Color3.fromRGB(28,12,14))}),bg=Color3.fromRGB(22,12,14),surface=Color3.fromRGB(34,18,22),surfaceHi=Color3.fromRGB(46,24,28),stroke=Color3.fromRGB(48,24,30),accent=Color3.fromRGB(220,30,55),accentHi=Color3.fromRGB(255,70,90),accentSoft=Color3.fromRGB(90,15,30),text=Color3.fromRGB(245,240,240),textDim=Color3.fromRGB(180,160,165)},
    Neon={gradient=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(10,22,22)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(14,32,32)),ColorSequenceKeypoint.new(1,Color3.fromRGB(10,22,22))}),bg=Color3.fromRGB(8,18,18),surface=Color3.fromRGB(18,30,30),surfaceHi=Color3.fromRGB(26,42,42),stroke=Color3.fromRGB(30,52,52),accent=Color3.fromRGB(0,220,200),accentHi=Color3.fromRGB(80,255,240),accentSoft=Color3.fromRGB(0,80,75),text=Color3.fromRGB(235,250,245),textDim=Color3.fromRGB(150,190,185)},
    Ocean={gradient=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(10,16,28)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(14,22,40)),ColorSequenceKeypoint.new(1,Color3.fromRGB(10,16,28))}),bg=Color3.fromRGB(8,12,22),surface=Color3.fromRGB(18,24,40),surfaceHi=Color3.fromRGB(26,34,54),stroke=Color3.fromRGB(30,42,68),accent=Color3.fromRGB(30,140,250),accentHi=Color3.fromRGB(90,180,255),accentSoft=Color3.fromRGB(15,55,120),text=Color3.fromRGB(240,245,255),textDim=Color3.fromRGB(160,180,210)},
    Violet={gradient=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(20,12,28)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(28,18,42)),ColorSequenceKeypoint.new(1,Color3.fromRGB(20,12,28))}),bg=Color3.fromRGB(14,8,22),surface=Color3.fromRGB(26,16,38),surfaceHi=Color3.fromRGB(38,24,54),stroke=Color3.fromRGB(46,30,68),accent=Color3.fromRGB(150,60,240),accentHi=Color3.fromRGB(200,120,255),accentSoft=Color3.fromRGB(70,20,120),text=Color3.fromRGB(245,240,255),textDim=Color3.fromRGB(180,165,205)},
    Sunset={gradient=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(28,16,8)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(42,22,12)),ColorSequenceKeypoint.new(1,Color3.fromRGB(28,16,8))}),bg=Color3.fromRGB(20,12,8),surface=Color3.fromRGB(38,22,14),surfaceHi=Color3.fromRGB(52,32,20),stroke=Color3.fromRGB(62,38,24),accent=Color3.fromRGB(255,130,40),accentHi=Color3.fromRGB(255,180,90),accentSoft=Color3.fromRGB(130,55,15),text=Color3.fromRGB(255,245,235),textDim=Color3.fromRGB(210,175,145)},
    Toxic={gradient=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(12,24,10)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(18,34,14)),ColorSequenceKeypoint.new(1,Color3.fromRGB(12,24,10))}),bg=Color3.fromRGB(10,18,8),surface=Color3.fromRGB(20,32,16),surfaceHi=Color3.fromRGB(30,46,24),stroke=Color3.fromRGB(40,60,32),accent=Color3.fromRGB(140,240,40),accentHi=Color3.fromRGB(180,255,90),accentSoft=Color3.fromRGB(55,110,15),text=Color3.fromRGB(240,250,235),textDim=Color3.fromRGB(175,205,160)},
    Cyberpunk={gradient=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(20,8,22)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(30,12,32)),ColorSequenceKeypoint.new(1,Color3.fromRGB(20,8,22))}),bg=Color3.fromRGB(14,6,16),surface=Color3.fromRGB(26,12,28),surfaceHi=Color3.fromRGB(40,18,44),stroke=Color3.fromRGB(48,22,52),accent=Color3.fromRGB(255,20,190),accentHi=Color3.fromRGB(255,90,220),accentSoft=Color3.fromRGB(110,10,80),text=Color3.fromRGB(250,240,255),textDim=Color3.fromRGB(200,160,220)},
    Gold={gradient=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(24,20,10)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(36,28,14)),ColorSequenceKeypoint.new(1,Color3.fromRGB(24,20,10))}),bg=Color3.fromRGB(18,14,6),surface=Color3.fromRGB(32,26,14),surfaceHi=Color3.fromRGB(46,36,20),stroke=Color3.fromRGB(58,46,24),accent=Color3.fromRGB(240,190,50),accentHi=Color3.fromRGB(255,220,100),accentSoft=Color3.fromRGB(110,80,20),text=Color3.fromRGB(255,250,235),textDim=Color3.fromRGB(200,180,140)},
    Emerald={gradient=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(10,24,16)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(14,34,22)),ColorSequenceKeypoint.new(1,Color3.fromRGB(10,24,16))}),bg=Color3.fromRGB(8,18,12),surface=Color3.fromRGB(18,32,22),surfaceHi=Color3.fromRGB(26,44,32),stroke=Color3.fromRGB(34,58,42),accent=Color3.fromRGB(40,210,130),accentHi=Color3.fromRGB(90,250,175),accentSoft=Color3.fromRGB(15,85,55),text=Color3.fromRGB(235,250,240),textDim=Color3.fromRGB(155,195,175)},
    Blood={gradient=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(20,6,8)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(30,10,14)),ColorSequenceKeypoint.new(1,Color3.fromRGB(20,6,8))}),bg=Color3.fromRGB(14,4,6),surface=Color3.fromRGB(26,10,14),surfaceHi=Color3.fromRGB(40,16,22),stroke=Color3.fromRGB(50,20,26),accent=Color3.fromRGB(180,10,20),accentHi=Color3.fromRGB(230,40,55),accentSoft=Color3.fromRGB(80,5,12),text=Color3.fromRGB(250,240,240),textDim=Color3.fromRGB(195,165,165)},
    Midnight={gradient=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(14,16,26)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(20,24,38)),ColorSequenceKeypoint.new(1,Color3.fromRGB(14,16,26))}),bg=Color3.fromRGB(10,12,20),surface=Color3.fromRGB(22,26,40),surfaceHi=Color3.fromRGB(32,38,54),stroke=Color3.fromRGB(40,48,66),accent=Color3.fromRGB(90,120,240),accentHi=Color3.fromRGB(130,160,255),accentSoft=Color3.fromRGB(35,48,110),text=Color3.fromRGB(240,242,250),textDim=Color3.fromRGB(160,170,195)},
}

NINOMAX.CurrentTheme = "Crimson"
local T = NINOMAX.Themes.Crimson

local function luminance(c) return 0.2126*c.R + 0.7152*c.G + 0.0722*c.B end
local function contrastText(bg) return luminance(bg) > 0.55 and Color3.fromRGB(20,20,25) or Color3.fromRGB(245,245,250) end
local function mix(a, b, t) return Color3.new(a.R+(b.R-a.R)*t, a.G+(b.G-a.G)*t, a.B+(b.B-a.B)*t) end

local function hexToColor(hex)
    hex = tostring(hex):gsub("#", ""):gsub("%s", "")
    if #hex == 3 then hex = hex:sub(1,1):rep(2)..hex:sub(2,2):rep(2)..hex:sub(3,3):rep(2) end
    if #hex ~= 6 then return nil end
    local r = tonumber(hex:sub(1,2), 16); local g = tonumber(hex:sub(3,4), 16); local b = tonumber(hex:sub(5,6), 16)
    if not r or not g or not b then return nil end
    return Color3.fromRGB(r, g, b)
end
local function colorToHex(c) return string.format("#%02X%02X%02X", math.floor(c.R*255+0.5), math.floor(c.G*255+0.5), math.floor(c.B*255+0.5)) end

local function tw(inst, dur, props, style, dir)
    local t = TweenService:Create(inst, TweenInfo.new(dur or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    t:Play(); return t
end
local function newCorner(p, r) local c = Instance.new("UICorner"); c.CornerRadius = r or UDim.new(0, 6); c.Parent = p; return c end
local function newStroke(p, col, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or T.stroke; s.Thickness = th or 1; s.Transparency = tr or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = p; return s
end
local function newPad(p, t, l, r, b)
    local u = Instance.new("UIPadding", p)
    u.PaddingTop = UDim.new(0, t or 0); u.PaddingLeft = UDim.new(0, l or 0)
    u.PaddingRight = UDim.new(0, r or 0); u.PaddingBottom = UDim.new(0, b or 0); return u
end
local function getIcon(name)
    if not name or name == "" then return nil end
    if name:find("rbxassetid://") or name:find("rbxthumb://") then return name end
    if type(name) == "number" then return "rbxassetid://" .. tostring(name) end
    return NINOMAX.Icons[name:lower()] or nil
end
local function isMobile() return UIS.TouchEnabled and not UIS.KeyboardEnabled end
local function draggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

function NINOMAX:GetFlag(name) return self.Flags[name] end
function NINOMAX:SetFlag(name, value)
    self.Flags[name] = value
    if self._onFlagChange then self._onFlagChange(name, value) end
end
local function saveConfig(file)
    if not file then return end
    pcall(function() if writefile then writefile(file, HttpService:JSONEncode(NINOMAX.Flags)) end end)
end
local function loadConfig(file)
    if not file then return end
    pcall(function()
        if readfile and isfile and isfile(file) then
            local data = HttpService:JSONDecode(readfile(file))
            if type(data) == "table" then for k, v in pairs(data) do NINOMAX.Flags[k] = v end end
        end
    end)
end

local themeBindings = {}
local function onTheme(fn) table.insert(themeBindings, fn) end
local function broadcastTheme() for _, fn in ipairs(themeBindings) do pcall(fn) end end

-- ═══════════════════════════════════════════════════════════════════
-- CREATE WINDOW
-- ═══════════════════════════════════════════════════════════════════
function NINOMAX:CreateWindow(cfg)
    cfg = cfg or {}
    local Window = {}
    local SUBTITLE_TEXT = cfg.Subtitle or "v" .. self.Version
    local CONFIG_FILE = cfg.ConfigFile or "ninomax_config.json"
    local SIZE = Vector2.new(580, 400)
    local MIN_SIZE = Vector2.new(440, 300)
    local MAX_SIZE = Vector2.new(1200, 900)
    local currentSize = SIZE

    loadConfig(CONFIG_FILE)
    self._onFlagChange = function() saveConfig(CONFIG_FILE) end

    local gui = Instance.new("ScreenGui")
    gui.Name = "NINOMAX_UI"; gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 99e99
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end

    local uiScale = Instance.new("UIScale", gui)
    uiScale.Scale = isMobile() and 1.05 or 1

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

    local topBar = Instance.new("Frame", mainFrame)
    topBar.Size = UDim2.new(1, 0, 0, 30)
    topBar.BackgroundTransparency = 1
    topBar.ZIndex = 5

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
    ninoGlow.Color = Color3.fromRGB(255, 255, 255); ninoGlow.Thickness = 0; ninoGlow.Transparency = 1
    task.spawn(function()
        while titleNino.Parent do
            tw(ninoGlow, 2, { Transparency = 0.7, Thickness = 2 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(2)
            tw(ninoGlow, 2, { Transparency = 1, Thickness = 0 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(2)
        end
    end)

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

    local maxGlow = Instance.new("UIStroke", titleMax)
    maxGlow.Color = T.accentHi; maxGlow.Thickness = 1; maxGlow.Transparency = 0.4
    task.spawn(function()
        while titleMax.Parent do
            tw(maxGlow, 1.4, { Transparency = 0.9 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.4)
            tw(maxGlow, 1.4, { Transparency = 0.2 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.4)
        end
    end)

    local subtitle = Instance.new("TextLabel", topBar)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 9
    subtitle.TextColor3 = T.textDim
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.TextYAlignment = Enum.TextYAlignment.Bottom
    subtitle.Text = SUBTITLE_TEXT
    subtitle.ZIndex = 6
    subtitle.AutomaticSize = Enum.AutomaticSize.XY

    task.defer(function()
        local w1 = titleNino.TextBounds.X
        local w2 = titleMax.TextBounds.X
        subtitle.Position = UDim2.new(0, 15 + w1 + w2 + 8, 0.5, 3)
    end)

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

    local sepLine = Instance.new("Frame", mainFrame)
    sepLine.Size = UDim2.new(1, 0, 0, 1)
    sepLine.Position = UDim2.new(0, 0, 0, 30)
    sepLine.BackgroundColor3 = T.stroke
    sepLine.BackgroundTransparency = 0.4
    sepLine.BorderSizePixel = 0
    sepLine.ZIndex = 4

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
    newPad(sidebar, 8, 8, 8, 8)

    local sideLay = Instance.new("UIListLayout", sidebar)
    sideLay.SortOrder = Enum.SortOrder.LayoutOrder
    sideLay.Padding = UDim.new(0, 4)

    -- SEARCH BOX (vazia por padrão!)
    local searchBox = Instance.new("TextBox", sidebar)
    searchBox.Size = UDim2.new(1, 0, 0, 22)
    searchBox.BackgroundColor3 = T.surface
    searchBox.BorderSizePixel = 0
    searchBox.Text = ""  -- ← Garantido vazio
    searchBox.PlaceholderText = "Buscar..."
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
    local tabsByName = {}  -- Registry para API flat

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = string.lower(searchBox.Text)
        for name, btn in pairs(tabBtns) do
            btn.Visible = (q == "") or (string.find(string.lower(name), q, 1, true) ~= nil)
        end
    end)

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

    local resizeHandle = Instance.new("TextButton", mainFrame)
    resizeHandle.Size = UDim2.new(0, 18, 0, 18)
    resizeHandle.Position = UDim2.new(1, -22, 1, -22)
    resizeHandle.BackgroundColor3 = T.surface
    resizeHandle.BackgroundTransparency = 0.35
    resizeHandle.Text = "◢"
    resizeHandle.TextColor3 = T.textDim
    resizeHandle.TextSize = 13
    resizeHandle.Font = Enum.Font.GothamBold
    resizeHandle.AutoButtonColor = false
    resizeHandle.ZIndex = 20
    newCorner(resizeHandle, UDim.new(0, 5))
    local resizeStroke = newStroke(resizeHandle, T.stroke, 1.2, 0.35)

    local hoveredResize = false
    resizeHandle.MouseEnter:Connect(function()
        hoveredResize = true
        tw(resizeHandle, 0.18, { BackgroundColor3 = T.accentSoft, BackgroundTransparency = 0.1, Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(1, -26, 1, -26) }, Enum.EasingStyle.Back)
        tw(resizeStroke, 0.18, { Color = T.accentHi, Transparency = 0 })
    end)
    resizeHandle.MouseLeave:Connect(function()
        hoveredResize = false
        tw(resizeHandle, 0.2, { BackgroundColor3 = T.surface, BackgroundTransparency = 0.35, Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -22, 1, -22) }, Enum.EasingStyle.Back)
        tw(resizeStroke, 0.2, { Color = T.stroke, Transparency = 0.35 })
    end)
    task.spawn(function()
        while resizeHandle.Parent do
            if not hoveredResize then
                tw(resizeStroke, 1.6, { Transparency = 0.85 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(1.6)
                tw(resizeStroke, 1.6, { Transparency = 0.35 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(1.6)
            else task.wait(0.4) end
        end
    end)

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
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
        end)
    end

    local ballButton = Instance.new("ImageButton")
    ballButton.Size = UDim2.new(0, 50, 0, 50)
    ballButton.Position = UDim2.new(0.1, 0, 0.9, -150)
    ballButton.AnchorPoint = Vector2.new(0.5, 0.5)
    ballButton.BackgroundColor3 = T.accent
    ballButton.Image = NINOMAX.Icons.ball
    ballButton.Visible = false
    ballButton.Draggable = true
    ballButton.Parent = gui
    newCorner(ballButton, UDim.new(0.5, 0))
    local ballStroke = newStroke(ballButton, T.accentHi, 2, 0.2)

    task.spawn(function()
        while ballButton.Parent do
            tw(ballStroke, 1.2, { Transparency = 0.8 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
            tw(ballStroke, 1.2, { Transparency = 0.2 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not mainFrame.Parent then return end
        shadowHolder.Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset + 2)
        shadowHolder.Size = UDim2.new(0, mainFrame.AbsoluteSize.X + 4, 0, mainFrame.AbsoluteSize.Y + 4)
    end)

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
        tw(ballButton, 0.4, { BackgroundColor3 = T.accent })
        tw(ballStroke, 0.4, { Color = T.accentHi })
        tw(searchBox, 0.4, { BackgroundColor3 = T.surface, TextColor3 = T.text, PlaceholderColor3 = T.textDim })
    end)

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

    local isHidden = false
    local function doHide()
        if isHidden then return end
        isHidden = true
        local fs = mainFrame.AbsoluteSize
        currentSize = Vector2.new(fs.X, fs.Y)
        tw(mainFrame, 0.22, { Size = UDim2.new(0, currentSize.X, 0, 8), BackgroundTransparency = 0.5 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        tw(shadowImg, 0.22, { ImageTransparency = 1 })
        task.delay(0.22, function()
            mainFrame.Visible = false
            mainFrame.Size = UDim2.new(0, currentSize.X, 0, currentSize.Y)
            mainFrame.BackgroundTransparency = 0.03
            ballButton.Visible = true
            ballButton.Size = UDim2.new(0, 0, 0, 0)
            tw(ballButton, 0.3, { Size = UDim2.new(0, 50, 0, 50) }, Enum.EasingStyle.Back)
        end)
    end
    local function doShow()
        if not isHidden then return end
        isHidden = false
        tw(ballButton, 0.22, { Size = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.2, function()
            ballButton.Visible = false
            ballButton.Size = UDim2.new(0, 50, 0, 50)
            mainFrame.Visible = true
            mainFrame.Size = UDim2.new(0, currentSize.X, 0, 8)
            mainFrame.BackgroundTransparency = 0.5
            tw(mainFrame, 0.35, { Size = UDim2.new(0, currentSize.X, 0, currentSize.Y), BackgroundTransparency = 0.03 }, Enum.EasingStyle.Back)
            tw(shadowImg, 0.35, { ImageTransparency = 0.5 })
        end)
    end

    btnMin.MouseButton1Click:Connect(function() if isHidden then doShow() else doHide() end end)
    ballButton.MouseButton1Click:Connect(doShow)
    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            if isHidden then doShow() else doHide() end
        end
    end)

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
    -- CREATE TAB
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

        tabBtn.MouseButton1Click:Connect(function() switchTab(tabName) end)
        if not selectedTab then switchTab(tabName) end

        local Tab = {}

        local function makeRow(title, desc, customHeight)
            local f = Instance.new("Frame", page)
            f.Size = UDim2.new(1, 0, 0, customHeight or 26)
            f.BackgroundColor3 = T.surface
            f.BackgroundTransparency = 0.05
            f.BorderSizePixel = 0
            newCorner(f, UDim.new(0, 5))
            local fStroke = newStroke(f, T.stroke, 1, 0.7)

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
                f.Size = UDim2.new(1, 0, 0, customHeight or 32)
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
            return { Set = function(_, v) lbl.Text = string.upper(v) end, Destroy = function() s:Destroy() end }
        end

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

        -- ═══ BUTTON ═══
        function Tab:AddButton(cfg)
            cfg = cfg or {}
            if type(cfg) == "string" then cfg = { Title = cfg } end
            local title = cfg.Title or cfg.Name or cfg.Text or "Button"
            local desc = cfg.Desc or cfg.Description or ""
            local cb = cfg.Callback or function() end
            local cooldown = cfg.Cooldown or 0.5

            local f, tL, dL, fS = makeRow(title, desc)
            f.Name = "Option"
            f.ClipsDescendants = true

            local arrow = Instance.new("ImageLabel", f)
            arrow.Size = UDim2.new(0, 12, 0, 12)
            arrow.Position = UDim2.new(1, -12, 0.5, -6)
            arrow.BackgroundTransparency = 1
            arrow.Image = "rbxassetid://10709791437"
            arrow.ImageColor3 = T.textDim
            arrow.ZIndex = 2

            local shine = Instance.new("Frame", f)
            shine.Size = UDim2.new(0, 50, 1, 0)
            shine.Position = UDim2.new(-0.3, 0, 0, 0)
            shine.BackgroundColor3 = Color3.new(1, 1, 1)
            shine.BackgroundTransparency = 0.88
            shine.BorderSizePixel = 0
            shine.ZIndex = 3
            local sG = Instance.new("UIGradient", shine)
            sG.Transparency = NumberSequence.new(1, 0, 1)

            local btn = Instance.new("TextButton", f)
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.ZIndex = 10

            f.MouseEnter:Connect(function()
                tw(f, 0.15, { BackgroundColor3 = T.surfaceHi, BackgroundTransparency = 0 })
                tw(fS, 0.15, { Color = T.accentHi, Transparency = 0.3 })
                tw(arrow, 0.15, { ImageColor3 = T.accentHi })
                shine.Position = UDim2.new(-0.3, 0, 0, 0)
                tw(shine, 0.7, { Position = UDim2.new(1.2, 0, 0, 0) }, Enum.EasingStyle.Quart)
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
                local mx = UIS:GetMouseLocation().X - f.AbsolutePosition.X
                local my = UIS:GetMouseLocation().Y - f.AbsolutePosition.Y
                local ripple = Instance.new("Frame", f)
                ripple.AnchorPoint = Vector2.new(0.5, 0.5)
                ripple.Position = UDim2.new(0, mx, 0, my)
                ripple.Size = UDim2.new(0, 0, 0, 0)
                ripple.BackgroundColor3 = Color3.new(1, 1, 1)
                ripple.BackgroundTransparency = 0.7
                ripple.BorderSizePixel = 0
                ripple.ZIndex = 4
                newCorner(ripple, UDim.new(1, 0))
                local rt = tw(ripple, 0.5, { Size = UDim2.new(0, f.AbsoluteSize.X * 2, 0, f.AbsoluteSize.X * 2), BackgroundTransparency = 1 }, Enum.EasingStyle.Quart)
                rt.Completed:Connect(function() ripple:Destroy() end)

                local flash = Instance.new("Frame", f)
                flash.Size = UDim2.new(1, 0, 1, 0)
                flash.BackgroundColor3 = T.accentHi
                flash.BackgroundTransparency = 0.75
                flash.BorderSizePixel = 0
                flash.ZIndex = 1
                newCorner(flash, UDim.new(0, 5))
                tw(flash, 0.4, { BackgroundTransparency = 1 })
                task.delay(0.4, function() flash:Destroy() end)

                tw(f, 0.06, { Size = UDim2.new(1, -4, 0, f.Size.Y.Offset) })
                task.delay(0.06, function() tw(f, 0.15, { Size = UDim2.new(1, 0, 0, f.Size.Y.Offset) }, Enum.EasingStyle.Back) end)

                pcall(cb)
                task.delay(cooldown, function() cooling = false end)
            end)

            return { Set = function(_, v) tL.Text = tostring(v) end, Destroy = function() f:Destroy() end }
        end

        -- ═══ TOGGLE ═══
        function Tab:AddToggle(cfg)
            cfg = cfg or {}
            if type(cfg) == "string" then cfg = { Title = cfg } end
            local title = cfg.Title or cfg.Name or cfg.Text or "Toggle"
            local desc = cfg.Desc or cfg.Description or ""
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag
            local default = cfg.Default or false
            if flag and NINOMAX.Flags[flag] ~= nil then default = NINOMAX.Flags[flag] end

            local f, tL, dL, fS = makeRow(title, desc)
            f.Name = "Option"

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

            return { Set = function(_, v) apply(v, false) end, Get = function() return isOn end, Destroy = function() f:Destroy() end }
        end

        -- ═══ CHECKBOX ═══
        function Tab:AddCheckbox(cfg)
            cfg = cfg or {}
            if type(cfg) == "string" then cfg = { Title = cfg } end
            local title = cfg.Title or cfg.Name or cfg.Text or "Checkbox"
            local desc = cfg.Desc or cfg.Description or ""
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag
            local default = cfg.Default or false
            if flag and NINOMAX.Flags[flag] ~= nil then default = NINOMAX.Flags[flag] end

            local f, tL, dL, fS = makeRow(title, desc)
            f.Name = "Option"

            local box = Instance.new("Frame", f)
            box.Size = UDim2.new(0, 16, 0, 16)
            box.Position = UDim2.new(1, -10, 0.5, -8)
            box.AnchorPoint = Vector2.new(1, 0)
            box.BackgroundColor3 = T.stroke
            box.BorderSizePixel = 0
            newCorner(box, UDim.new(0, 4))
            local boxStroke = newStroke(box, T.stroke, 1.2, 0.4)

            local chk = Instance.new("TextLabel", box)
            chk.Size = UDim2.new(1, -2, 1, -2)
            chk.Position = UDim2.new(0, 1, 0, 1)
            chk.Text = "✔"
            chk.TextColor3 = Color3.new(1, 1, 1)
            chk.TextScaled = true
            chk.BackgroundTransparency = 1
            chk.Visible = default

            local btn = Instance.new("TextButton", f)
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.ZIndex = 10

            local toggled = default
            local function apply(v, silent)
                toggled = v
                chk.Visible = v
                if v then
                    tw(box, 0.2, { BackgroundColor3 = T.accent }, Enum.EasingStyle.Back)
                    tw(boxStroke, 0.2, { Color = T.accentHi, Transparency = 0 })
                    tw(box, 0.1, { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -11, 0.5, -9) })
                    task.delay(0.1, function() tw(box, 0.15, { Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -10, 0.5, -8) }, Enum.EasingStyle.Back) end)
                else
                    tw(box, 0.2, { BackgroundColor3 = T.stroke }, Enum.EasingStyle.Back)
                    tw(boxStroke, 0.2, { Color = T.stroke, Transparency = 0.4 })
                end
                if not silent then
                    if flag then NINOMAX:SetFlag(flag, toggled) end
                    pcall(cb, toggled)
                end
            end
            apply(default, true)

            onTheme(function()
                if toggled then
                    tw(box, 0.35, { BackgroundColor3 = T.accent })
                    tw(boxStroke, 0.35, { Color = T.accentHi })
                else
                    tw(box, 0.35, { BackgroundColor3 = T.stroke })
                    tw(boxStroke, 0.35, { Color = T.stroke })
                end
            end)

            btn.MouseEnter:Connect(function()
                tw(f, 0.15, { BackgroundColor3 = T.surfaceHi, BackgroundTransparency = 0 })
                tw(fS, 0.15, { Color = T.accentHi, Transparency = 0.3 })
                tw(boxStroke, 0.15, { Color = T.accentHi, Transparency = 0.1 })
            end)
            btn.MouseLeave:Connect(function()
                tw(f, 0.15, { BackgroundColor3 = T.surface, BackgroundTransparency = 0.05 })
                tw(fS, 0.15, { Color = T.stroke, Transparency = 0.7 })
                if not toggled then tw(boxStroke, 0.15, { Color = T.stroke, Transparency = 0.4 }) end
            end)

            btn.MouseButton1Click:Connect(function() apply(not toggled) end)

            return { Set = function(_, v) apply(v, false) end, Get = function() return toggled end, Destroy = function() f:Destroy() end }
        end

        -- ═══ SWITCH ═══
        function Tab:AddSwitch(cfg)
            cfg = cfg or {}
            if type(cfg) == "string" then cfg = { Title = cfg } end
            local title = cfg.Title or cfg.Name or cfg.Text or "Switch"
            local desc = cfg.Desc or cfg.Description or ""
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag
            local default = cfg.Default or cfg.State or false
            if flag and NINOMAX.Flags[flag] ~= nil then default = NINOMAX.Flags[flag] end

            local f, tL, dL, fS = makeRow(title, desc)
            f.Name = "Option"

            local sw = Instance.new("Frame", f)
            sw.Size = UDim2.new(0, 40, 0, 18)
            sw.Position = UDim2.new(1, -10, 0.5, -9)
            sw.AnchorPoint = Vector2.new(1, 0)
            sw.BackgroundColor3 = T.stroke
            sw.BorderSizePixel = 0
            newCorner(sw, UDim.new(1, 0))
            local glow = newStroke(sw, T.accentHi, 1.5, 1)

            local circle = Instance.new("Frame", sw)
            circle.Size = UDim2.new(0, 14, 0, 14)
            circle.Position = UDim2.new(0, 2, 0.5, -7)
            circle.AnchorPoint = Vector2.new(0, 0)
            circle.BackgroundColor3 = Color3.fromRGB(210, 210, 215)
            circle.BorderSizePixel = 0
            newCorner(circle, UDim.new(1, 0))

            local btn = Instance.new("TextButton", f)
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.ZIndex = 10

            local state = default
            local function apply(v, silent)
                state = v
                if v then
                    tw(circle, 0.25, { Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Color3.new(1, 1, 1) }, Enum.EasingStyle.Back)
                    tw(sw, 0.25, { BackgroundColor3 = T.accent }, Enum.EasingStyle.Back)
                    tw(glow, 0.25, { Transparency = 0 })
                else
                    tw(circle, 0.25, { Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(210, 210, 215) }, Enum.EasingStyle.Back)
                    tw(sw, 0.25, { BackgroundColor3 = T.stroke }, Enum.EasingStyle.Back)
                    tw(glow, 0.25, { Transparency = 1 })
                end
                if not silent then
                    if flag then NINOMAX:SetFlag(flag, state) end
                    pcall(cb, state)
                end
            end
            apply(default, true)

            onTheme(function()
                if state then
                    tw(sw, 0.35, { BackgroundColor3 = T.accent })
                    tw(glow, 0.35, { Color = T.accentHi })
                else
                    tw(sw, 0.35, { BackgroundColor3 = T.stroke })
                end
            end)

            btn.MouseEnter:Connect(function()
                tw(f, 0.15, { BackgroundColor3 = T.surfaceHi, BackgroundTransparency = 0 })
                tw(fS, 0.15, { Color = T.accentHi, Transparency = 0.3 })
            end)
            btn.MouseLeave:Connect(function()
                tw(f, 0.15, { BackgroundColor3 = T.surface, BackgroundTransparency = 0.05 })
                tw(fS, 0.15, { Color = T.stroke, Transparency = 0.7 })
            end)

            btn.MouseButton1Click:Connect(function() apply(not state) end)

            return { Set = function(_, v) apply(v, false) end, Get = function() return state end, Destroy = function() f:Destroy() end }
        end

        -- ═══ SLIDER TURBO ═══
        function Tab:AddSlider(cfg)
            cfg = cfg or {}
            local title = cfg.Title or cfg.Name or cfg.Text or "Slider"
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

            local bg = Instance.new("Frame", holder)
            bg.Size = UDim2.new(1, 0, 0, 50)
            bg.BackgroundColor3 = T.surface
            bg.BackgroundTransparency = 0.05
            bg.BorderSizePixel = 0
            newCorner(bg, UDim.new(0, 5))
            local bgS = newStroke(bg, T.stroke, 1, 0.7)

            local t = Instance.new("TextLabel", bg)
            t.Size = UDim2.new(1, -70, 0, 12)
            t.Position = UDim2.new(0, 10, 0, 6)
            t.Text = title
            t.TextColor3 = T.text
            t.TextSize = 11
            t.Font = Enum.Font.GothamMedium
            t.BackgroundTransparency = 1
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.TextTruncate = Enum.TextTruncate.AtEnd

            -- Value pill (estilo badge)
            local valPill = Instance.new("Frame", bg)
            valPill.Size = UDim2.new(0, 50, 0, 16)
            valPill.Position = UDim2.new(1, -58, 0, 4)
            valPill.BackgroundColor3 = T.accentSoft
            valPill.BorderSizePixel = 0
            newCorner(valPill, UDim.new(0, 4))

            local vl = Instance.new("TextLabel", valPill)
            vl.Size = UDim2.new(1, -4, 1, 0)
            vl.Position = UDim2.new(0, 2, 0, 0)
            vl.Text = tostring(default) .. suffix
            vl.TextColor3 = T.text
            vl.TextSize = 10
            vl.Font = Enum.Font.GothamBold
            vl.BackgroundTransparency = 1
            vl.TextXAlignment = Enum.TextXAlignment.Center
            vl.TextScaled = false

            -- Marcadores min/max
            local minLbl = Instance.new("TextLabel", bg)
            minLbl.Size = UDim2.new(0, 20, 0, 8)
            minLbl.Position = UDim2.new(0, 10, 0, 36)
            minLbl.Text = tostring(min)
            minLbl.TextColor3 = T.textDim
            minLbl.TextSize = 8
            minLbl.Font = Enum.Font.Gotham
            minLbl.BackgroundTransparency = 1
            minLbl.TextXAlignment = Enum.TextXAlignment.Left

            local maxLbl = Instance.new("TextLabel", bg)
            maxLbl.Size = UDim2.new(0, 20, 0, 8)
            maxLbl.Position = UDim2.new(1, -30, 0, 36)
            maxLbl.Text = tostring(max)
            maxLbl.TextColor3 = T.textDim
            maxLbl.TextSize = 8
            maxLbl.Font = Enum.Font.Gotham
            maxLbl.BackgroundTransparency = 1
            maxLbl.TextXAlignment = Enum.TextXAlignment.Right

            local bar = Instance.new("Frame", bg)
            bar.Size = UDim2.new(1, -20, 0, 6)
            bar.Position = UDim2.new(0, 10, 0, 24)
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

            -- Glow pulsante no fill
            local fillGlow = newStroke(fill, T.accentHi, 2, 0.6)

            local knob = Instance.new("Frame", bar)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Size = UDim2.new(0, 10, 0, 10)
            knob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
            knob.BorderSizePixel = 0
            knob.ZIndex = 4
            newCorner(knob, UDim.new(1, 0))
            local knobGlow = newStroke(knob, T.accentHi, 2, 0.2)

            -- Pulse background animation
            task.spawn(function()
                while bg.Parent do
                    tw(fillGlow, 1.6, { Transparency = 0.9 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                    task.wait(1.6)
                    tw(fillGlow, 1.6, { Transparency = 0.4 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                    task.wait(1.6)
                end
            end)

            onTheme(function()
                tw(bg, 0.35, { BackgroundColor3 = T.surface })
                tw(bgS, 0.35, { Color = T.stroke })
                tw(t, 0.35, { TextColor3 = T.text })
                tw(fill, 0.35, { BackgroundColor3 = T.accent })
                tw(fg, 0.35, { Color = ColorSequence.new(T.accentSoft, T.accentHi) })
                tw(valPill, 0.35, { BackgroundColor3 = T.accentSoft })
                tw(vl, 0.35, { TextColor3 = T.text })
                tw(bar, 0.35, { BackgroundColor3 = T.stroke })
                tw(knobGlow, 0.35, { Color = T.accentHi })
                tw(fillGlow, 0.35, { Color = T.accentHi })
            end)

            local function update(x, isDragging)
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
                    tw(knob, 0.12, { Size = UDim2.new(0, 14, 0, 14) }, Enum.EasingStyle.Back)
                    tw(valPill, 0.12, { Size = UDim2.new(0, 58, 0, 18), Position = UDim2.new(1, -62, 0, 3) }, Enum.EasingStyle.Back)
                    update(i.Position.X, true)
                end
            end)
            UIS.InputChanged:Connect(function(i)
                if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    update(i.Position.X, true)
                end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    if drag then
                        drag = false
                        tw(knob, 0.15, { Size = UDim2.new(0, 10, 0, 10) }, Enum.EasingStyle.Back)
                        tw(valPill, 0.15, { Size = UDim2.new(0, 50, 0, 16), Position = UDim2.new(1, -58, 0, 4) }, Enum.EasingStyle.Back)
                    end
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

        -- ═══ DROPDOWN PREMIUM ═══
        function Tab:AddDropdown(cfg)
            cfg = cfg or {}
            local title = cfg.Title or cfg.Name or cfg.Text or "Dropdown"
            local desc = cfg.Desc or cfg.Description or ""
            local options = cfg.Options or {}
            local default = cfg.Default
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag
            if flag and NINOMAX.Flags[flag] ~= nil then default = NINOMAX.Flags[flag] end

            local f, tL, dL, fS = makeRow(title, desc)
            f.Name = "Option"

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

            local overlay = Instance.new("TextButton", gui)
            overlay.Size = UDim2.new(1, 0, 1, 0)
            overlay.BackgroundTransparency = 1
            overlay.Text = ""
            overlay.Visible = false
            overlay.ZIndex = 500

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
            local optIndex = {}

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

                -- Hover slide effect
                o.MouseEnter:Connect(function()
                    tw(o, 0.15, { BackgroundColor3 = T.surfaceHi, BackgroundTransparency = 0 }, Enum.EasingStyle.Quint)
                    tw(ol, 0.15, { TextTransparency = 0, Position = UDim2.new(0, 22, 0, 0) }, Enum.EasingStyle.Back)
                    tw(dot, 0.15, { Position = UDim2.new(0, 6, 0.5, -2.5), BackgroundColor3 = T.accentHi, BackgroundTransparency = 0 }, Enum.EasingStyle.Back)
                end)
                o.MouseLeave:Connect(function()
                    tw(o, 0.15, { BackgroundTransparency = 1 })
                    if selected ~= opt then
                        tw(ol, 0.15, { TextTransparency = 0.35, Position = UDim2.new(0, 18, 0, 0) })
                        tw(dot, 0.15, { BackgroundTransparency = 1 })
                    else
                        tw(ol, 0.15, { Position = UDim2.new(0, 18, 0, 0) })
                    end
                end)
                o.MouseButton1Click:Connect(function()
                    for k, v in pairs(optBtns) do
                        v.dot.Visible = false
                        tw(v.dot, 0.2, { BackgroundTransparency = 1 })
                        tw(v.label, 0.2, { TextTransparency = 0.35, Position = UDim2.new(0, 18, 0, 0) })
                    end
                    dot.Visible = true
                    tw(dot, 0.2, { BackgroundTransparency = 0 })
                    tw(ol, 0.2, { TextTransparency = 0 })
                    selected = opt
                    updateLabel()
                    if flag then NINOMAX:SetFlag(flag, selected) end
                    pcall(cb, opt)
                    closeList()
                end)

                optBtns[opt] = { btn = o, dot = dot, label = ol, index = i }
                optIndex[i] = opt
            end

            local function openList()
                list.Visible = true
                overlay.Visible = true
                local ap = f.AbsolutePosition
                local av = f.AbsoluteSize
                list.Position = UDim2.new(0, ap.X, 0, ap.Y + av.Y + 4)
                local targetH = math.min(#options * 26 + 12, 220)
                list.Size = UDim2.new(0, 180, 0, 0)

                -- Stagger reveal
                for _, v in pairs(optBtns) do
                    v.btn.BackgroundTransparency = 1
                    v.label.TextTransparency = 1
                end

                tw(list, 0.25, { Size = UDim2.new(0, 180, 0, targetH) }, Enum.EasingStyle.Back)

                local idx = 0
                for _, v in pairs(optBtns) do
                    idx += 1
                    task.delay(idx * 0.02, function()
                        if v.btn.Parent then
                            v.label.TextTransparency = (selected == v.btn.Text and 0) or 0.35
                            if selected == optIndex[v.index] then
                                v.dot.Visible = true
                                tw(v.dot, 0.2, { BackgroundTransparency = 0 })
                            end
                        end
                    end)
                end
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

        -- ═══ TEXTBOX AVANÇADO ═══
        function Tab:AddTextBox(cfg)
            cfg = cfg or {}
            if type(cfg) == "string" then cfg = { Title = cfg } end
            local title = cfg.Title or cfg.Name or ""
            local placeholder = cfg.Placeholder or cfg.PlaceholderText or "Digite aqui..."
            local default = cfg.Default or ""
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag
            if flag and NINOMAX.Flags[flag] ~= nil then default = NINOMAX.Flags[flag] end

            local f = Instance.new("Frame", page)
            f.Size = UDim2.new(1, 0, 0, 38)
            f.BackgroundColor3 = T.surface
            f.BackgroundTransparency = 0.05
            f.BorderSizePixel = 0
            newCorner(f, UDim.new(0, 5))
            local fS = newStroke(f, T.stroke, 1, 0.7)

            -- Label flutuante pequena (só aparece quando focado)
            local floatLabel
            if title ~= "" then
                floatLabel = Instance.new("TextLabel", f)
                floatLabel.BackgroundTransparency = 1
                floatLabel.Text = title
                floatLabel.Font = Enum.Font.GothamBold
                floatLabel.TextSize = 9
                floatLabel.TextColor3 = T.accentHi
                floatLabel.Position = UDim2.new(0, 10, 0, 2)
                floatLabel.Size = UDim2.new(1, -40, 0, 10)
                floatLabel.TextXAlignment = Enum.TextXAlignment.Left
                floatLabel.TextTransparency = 1
                floatLabel.ZIndex = 12
            end

            local box = Instance.new("TextBox", f)
            box.Size = UDim2.new(1, -50, 0, 22)
            box.Position = UDim2.new(0, 10, 0.5, -11 + (title ~= "" and 4 or 0))
            box.BackgroundTransparency = 1
            box.Text = default
            box.PlaceholderText = placeholder
            box.PlaceholderColor3 = T.textDim
            box.TextColor3 = T.text
            box.Font = Enum.Font.Gotham
            box.TextSize = 10
            box.ClearTextOnFocus = false
            box.TextXAlignment = Enum.TextXAlignment.Left
            box.TextTruncate = Enum.TextTruncate.AtEnd
            box.ZIndex = 11

            -- Ícone de edit
            local icon = Instance.new("ImageLabel", f)
            icon.Size = UDim2.new(0, 12, 0, 12)
            icon.Position = UDim2.new(1, -40, 0.5, -6)
            icon.BackgroundTransparency = 1
            icon.Image = "rbxassetid://10734883598"
            icon.ImageColor3 = T.textDim
            icon.ZIndex = 12

            -- Botão limpar
            local clearBtn = Instance.new("TextButton", f)
            clearBtn.Size = UDim2.new(0, 16, 0, 16)
            clearBtn.Position = UDim2.new(1, -20, 0.5, -8)
            clearBtn.BackgroundTransparency = 1
            clearBtn.Text = "✕"
            clearBtn.TextColor3 = T.textDim
            clearBtn.Font = Enum.Font.GothamBold
            clearBtn.TextSize = 10
            clearBtn.AutoButtonColor = false
            clearBtn.Visible = (default ~= "")
            clearBtn.ZIndex = 13

            -- Barra highlight inferior
            local hl = Instance.new("Frame", f)
            hl.Size = UDim2.new(0, 0, 0, 2)
            hl.Position = UDim2.new(0.5, 0, 1, -2)
            hl.AnchorPoint = Vector2.new(0.5, 1)
            hl.BackgroundColor3 = T.accentHi
            hl.BorderSizePixel = 0
            newCorner(hl, UDim.new(1, 0))
            hl.ZIndex = 10

            onTheme(function()
                tw(f, 0.35, { BackgroundColor3 = T.surface })
                tw(fS, 0.35, { Color = T.stroke })
                tw(box, 0.35, { TextColor3 = T.text, PlaceholderColor3 = T.textDim })
                tw(icon, 0.35, { ImageColor3 = T.textDim })
                tw(clearBtn, 0.35, { TextColor3 = T.textDim })
                tw(hl, 0.35, { BackgroundColor3 = T.accentHi })
                if floatLabel then tw(floatLabel, 0.35, { TextColor3 = T.accentHi }) end
            end)

            box:GetPropertyChangedSignal("Text"):Connect(function()
                clearBtn.Visible = (box.Text ~= "")
            end)

            clearBtn.MouseEnter:Connect(function()
                tw(clearBtn, 0.15, { TextColor3 = Color3.fromRGB(255, 90, 90), Rotation = 90 }, Enum.EasingStyle.Back)
            end)
            clearBtn.MouseLeave:Connect(function()
                tw(clearBtn, 0.15, { TextColor3 = T.textDim, Rotation = 0 })
            end)
            clearBtn.MouseButton1Click:Connect(function()
                box.Text = ""
                if flag then NINOMAX:SetFlag(flag, "") end
                pcall(cb, "")
                tw(clearBtn, 0.1, { Size = UDim2.new(0, 12, 0, 12) })
                task.delay(0.1, function() tw(clearBtn, 0.15, { Size = UDim2.new(0, 16, 0, 16) }, Enum.EasingStyle.Back) end)
            end)

            box.Focused:Connect(function()
                tw(fS, 0.2, { Color = T.accentHi, Transparency = 0 })
                tw(icon, 0.2, { ImageColor3 = T.accentHi, Rotation = 15 }, Enum.EasingStyle.Back)
                tw(hl, 0.25, { Size = UDim2.new(1, -20, 0, 2) })
                if floatLabel then
                    tw(floatLabel, 0.2, { TextTransparency = 0 })
                    tw(box, 0.2, { Position = UDim2.new(0, 10, 0.5, -11 + 6) })
                end
            end)
            box.FocusLost:Connect(function(enter)
                tw(fS, 0.2, { Color = T.stroke, Transparency = 0.7 })
                tw(icon, 0.2, { ImageColor3 = T.textDim, Rotation = 0 })
                tw(hl, 0.25, { Size = UDim2.new(0, 0, 0, 2) })
                if floatLabel and box.Text == "" then
                    tw(floatLabel, 0.2, { TextTransparency = 1 })
                    tw(box, 0.2, { Position = UDim2.new(0, 10, 0.5, -11 + (title ~= "" and 4 or 0)) })
                end
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

        -- ═══ KEYBIND ═══
        function Tab:AddKeybind(cfg)
            cfg = cfg or {}
            local title = cfg.Title or cfg.Name or cfg.Text or "Keybind"
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

        -- ═══ COLOR PICKER ═══
        function Tab:AddColorPicker(cfg)
            cfg = cfg or {}
            local title = cfg.Title or cfg.Name or cfg.Text or "Cor"
            local default = cfg.Default or Color3.fromRGB(220, 30, 55)
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag
            if flag and NINOMAX.Flags[flag] ~= nil then
                pcall(function() default = Color3.fromRGB(unpack(NINOMAX.Flags[flag])) end)
            end

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
            hexBox.Text = colorToHex(current)
            hexBox.ClearTextOnFocus = false
            newCorner(hexBox, UDim.new(0, 4))
            newStroke(hexBox, T.stroke, 1, 0.5)

            local rgbHolder = Instance.new("Frame", infoCol)
            rgbHolder.Size = UDim2.new(1, 0, 0, 20)
            rgbHolder.Position = UDim2.new(0, 0, 0, 42)
            rgbHolder.BackgroundTransparency = 1
            local rgbLay = Instance.new("UIListLayout", rgbHolder)
            rgbLay.FillDirection = Enum.FillDirection.Horizontal
            rgbLay.Padding = UDim.new(0, 3)

            local function makeRGB(col)
                local ff = Instance.new("Frame", rgbHolder)
                ff.Size = UDim2.new(0, 28, 1, 0)
                ff.BackgroundColor3 = T.surfaceHi
                ff.BorderSizePixel = 0
                newCorner(ff, UDim.new(0, 4))
                newStroke(ff, T.stroke, 1, 0.5)
                local tb = Instance.new("TextBox", ff)
                tb.Size = UDim2.new(1, 0, 1, 0)
                tb.BackgroundTransparency = 1
                tb.Text = tostring(math.floor(col * 255 + 0.5))
                tb.TextColor3 = T.text
                tb.Font = Enum.Font.Code
                tb.TextSize = 9
                tb.ClearTextOnFocus = false
                return tb
            end
            local rIn = makeRGB(current.R)
            local gIn = makeRGB(current.G)
            local bIn = makeRGB(current.B)

            local presetsRow = Instance.new("Frame", body)
            presetsRow.Size = UDim2.new(1, -20, 0, 18)
            presetsRow.Position = UDim2.new(0, 10, 0, 10 + padSize + 8)
            presetsRow.BackgroundTransparency = 1
            local presetsLay = Instance.new("UIListLayout", presetsRow)
            presetsLay.FillDirection = Enum.FillDirection.Horizontal
            presetsLay.Padding = UDim.new(0, 4)

            local presetColors = {
                Color3.fromRGB(255, 60, 60), Color3.fromRGB(255, 140, 50),
                Color3.fromRGB(255, 220, 60), Color3.fromRGB(120, 220, 90),
                Color3.fromRGB(60, 200, 220), Color3.fromRGB(80, 120, 255),
                Color3.fromRGB(160, 90, 255), Color3.fromRGB(255, 90, 200),
                Color3.fromRGB(255, 255, 255), Color3.fromRGB(80, 80, 90),
            }

            local cycling = false
            local cycleBtn

            local function stopCycle()
                if cycling and cycleBtn then
                    cycling = false
                    cycleBtn.Text = "🌈 Ciclar"
                    cycleBtn.TextColor3 = T.text
                end
            end

            for _, pc in ipairs(presetColors) do
                local sw2 = Instance.new("TextButton", presetsRow)
                sw2.Size = UDim2.new(0, 16, 0, 16)
                sw2.BackgroundColor3 = pc
                sw2.Text = ""
                sw2.AutoButtonColor = false
                newCorner(sw2, UDim.new(1, 0))
                newStroke(sw2, Color3.new(0, 0, 0), 1, 0.6)
                sw2.MouseButton1Click:Connect(function()
                    local nh, ns, nv = Color3.toHSV(pc)
                    h, s, v = nh, ns, nv
                    stopCycle()
                    updateAll()
                end)
            end

            local actionRow = Instance.new("Frame", body)
            actionRow.Size = UDim2.new(1, -20, 0, 22)
            actionRow.Position = UDim2.new(0, 10, 0, 10 + padSize + 30)
            actionRow.BackgroundTransparency = 1

            local function styleActionBtn(b)
                b.BackgroundColor3 = T.surfaceHi
                b.TextColor3 = T.text
                b.Font = Enum.Font.GothamMedium
                b.TextSize = 10
                b.AutoButtonColor = false
                newCorner(b, UDim.new(0, 4))
                newStroke(b, T.stroke, 1, 0.5)
                b.MouseEnter:Connect(function() tw(b, 0.15, { BackgroundColor3 = mix(T.surfaceHi, T.accent, 0.35) }) end)
                b.MouseLeave:Connect(function() tw(b, 0.15, { BackgroundColor3 = T.surfaceHi }) end)
            end

            local randBtn = Instance.new("TextButton", actionRow)
            randBtn.Size = UDim2.new(0.5, -2, 1, 0)
            randBtn.Position = UDim2.new(0, 0, 0, 0)
            randBtn.Text = "🎲 Aleatório"
            styleActionBtn(randBtn)

            cycleBtn = Instance.new("TextButton", actionRow)
            cycleBtn.Size = UDim2.new(0.5, -2, 1, 0)
            cycleBtn.Position = UDim2.new(0.5, 2, 0, 0)
            cycleBtn.Text = "🌈 Ciclar"
            styleActionBtn(cycleBtn)

            local updating = false
            function updateAll()
                if updating then return end
                updating = true
                local color = Color3.fromHSV(h, s, v)
                current = color
                pad.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                padMarker.Position = UDim2.new(s, 0, 1 - v, 0)
                hueMarker.Position = UDim2.new(0.5, 0, h, 0)
                previewDot.BackgroundColor3 = color
                hexBox.Text = colorToHex(color)
                rIn.Text = tostring(math.floor(color.R * 255 + 0.5))
                gIn.Text = tostring(math.floor(color.G * 255 + 0.5))
                bIn.Text = tostring(math.floor(color.B * 255 + 0.5))
                if flag then NINOMAX:SetFlag(flag, {math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)}) end
                pcall(cb, color)
                updating = false
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
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then padDrag = false end
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
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then hueDrag = false end
            end)

            hexBox.FocusLost:Connect(function()
                local c = hexToColor(hexBox.Text)
                if c then h, s, v = Color3.toHSV(c); updateAll(); return end
                hexBox.Text = colorToHex(current)
            end)

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

            randBtn.MouseButton1Click:Connect(function()
                h = math.random()
                s = 0.55 + math.random() * 0.45
                v = 0.65 + math.random() * 0.35
                stopCycle()
                updateAll()
            end)

            cycleBtn.MouseButton1Click:Connect(function()
                cycling = not cycling
                if cycling then
                    cycleBtn.Text = "🌈 ON"
                    cycleBtn.TextColor3 = T.accentHi
                else
                    cycleBtn.Text = "🌈 Ciclar"
                    cycleBtn.TextColor3 = T.text
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
                local targetH = expanded and (26 + 10 + padSize + 10 + 18 + 8 + 22 + 10) or 26
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
                Set = function(_, c) h, s, v = Color3.toHSV(c); updateAll() end,
                Get = function() return current end,
                Destroy = function() frame:Destroy() end,
            }
        end

        -- ═══ PROGRESS BAR ═══
        function Tab:AddProgressBar(cfg)
            cfg = cfg or {}
            local title = cfg.Title or cfg.Name or cfg.Text or "Progresso"

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

        -- ═══ THEME BOXES ═══
        function Tab:AddThemeBoxes()
            local THEMES = {
                { name = "Neon",      accent = Color3.fromRGB(0, 255, 200) },
                { name = "Crimson",   accent = Color3.fromRGB(220, 20, 60) },
                { name = "Ocean",     accent = Color3.fromRGB(0, 150, 255) },
                { name = "Violet",    accent = Color3.fromRGB(155, 40, 255) },
                { name = "Sunset",    accent = Color3.fromRGB(255, 120, 40) },
                { name = "Toxic",     accent = Color3.fromRGB(150, 255, 40) },
                { name = "Cyberpunk", accent = Color3.fromRGB(255, 0, 200) },
                { name = "Gold",      accent = Color3.fromRGB(240, 180, 40) },
                { name = "Emerald",   accent = Color3.fromRGB(0, 220, 130) },
                { name = "Blood",     accent = Color3.fromRGB(160, 10, 10) },
                { name = "Midnight",  accent = Color3.fromRGB(90, 120, 240) },
            }

            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(1, 0, 0, 0)
            container.BackgroundTransparency = 1
            container.AutomaticSize = Enum.AutomaticSize.Y

            local grid = Instance.new("Frame", container)
            grid.Size = UDim2.new(1, 0, 0, 0)
            grid.BackgroundTransparency = 1
            grid.AutomaticSize = Enum.AutomaticSize.Y
            local gridLay = Instance.new("UIGridLayout", grid)
            gridLay.CellSize = UDim2.new(0, 62, 0, 26)
            gridLay.CellPadding = UDim2.new(0, 5, 0, 5)
            gridLay.SortOrder = Enum.SortOrder.LayoutOrder

            local lastSelected = nil
            for _, t in ipairs(THEMES) do
                local card = Instance.new("TextButton", grid)
                card.Size = UDim2.new(0, 62, 0, 26)
                card.BackgroundColor3 = T.surface
                card.Text = ""
                card.AutoButtonColor = false
                newCorner(card, UDim.new(0, 5))
                local cs = newStroke(card, T.stroke, 1, 0.6)

                local cg = Instance.new("UIGradient", card)
                cg.Rotation = 135
                cg.Color = ColorSequence.new(t.accent, mix(t.accent, Color3.new(0,0,0), 0.7))

                local ov = Instance.new("Frame", card)
                ov.Size = UDim2.new(1, 0, 1, 0)
                ov.BackgroundColor3 = Color3.new(0, 0, 0)
                ov.BackgroundTransparency = 0.55
                ov.BorderSizePixel = 0
                ov.ZIndex = 1
                newCorner(ov, UDim.new(0, 5))

                local nameLbl = Instance.new("TextLabel", card)
                nameLbl.Size = UDim2.new(1, -4, 1, 0)
                nameLbl.Position = UDim2.new(0, 2, 0, 0)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Text = t.name
                nameLbl.TextColor3 = Color3.new(1, 1, 1)
                nameLbl.Font = Enum.Font.GothamBold
                nameLbl.TextSize = 9
                nameLbl.TextWrapped = true
                nameLbl.ZIndex = 2

                card.MouseEnter:Connect(function()
                    tw(card, 0.2, { Size = UDim2.new(0, 66, 0, 28) }, Enum.EasingStyle.Back)
                    tw(cs, 0.2, { Color = t.accent, Transparency = 0 })
                end)
                card.MouseLeave:Connect(function()
                    if lastSelected ~= card then
                        tw(card, 0.2, { Size = UDim2.new(0, 62, 0, 26) }, Enum.EasingStyle.Back)
                        tw(cs, 0.2, { Color = T.stroke, Transparency = 0.6 })
                    end
                end)

                card.MouseButton1Click:Connect(function()
                    if NINOMAX.Themes[t.name] then
                        NINOMAX.CurrentTheme = t.name
                        T = NINOMAX.Themes[t.name]
                        broadcastTheme()
                    end
                    if lastSelected and lastSelected.Parent then
                        tw(lastSelected, 0.3, { Size = UDim2.new(0, 62, 0, 26) }, Enum.EasingStyle.Back)
                    end
                    tw(card, 0.3, { Size = UDim2.new(0, 66, 0, 28) }, Enum.EasingStyle.Back)
                    lastSelected = card
                    Window:Notify({ Title = "TEMA APLICADO", Text = t.name, Type = "success", Duration = 2 })
                end)
            end

            return container
        end

        -- ═══ INFO BOX ═══
        function Tab:AddInfoBox(title, infoList)
            local box = Instance.new("Frame", page)
            box.Size = UDim2.new(1, 0, 0, 0)
            box.BackgroundColor3 = T.surface
            box.BackgroundTransparency = 0.05
            box.BorderSizePixel = 0
            box.AutomaticSize = Enum.AutomaticSize.Y
            box.ClipsDescendants = true
            newCorner(box, UDim.new(0, 6))
            local bx = newStroke(box, T.accentSoft, 1.2, 0.4)

            local tl = Instance.new("TextLabel", box)
            tl.Text = "  " .. string.upper(title or "INFORMAÇÃO")
            tl.Font = Enum.Font.GothamBold
            tl.TextSize = 11
            tl.TextColor3 = T.text
            tl.BackgroundTransparency = 1
            tl.Size = UDim2.new(1, -20, 0, 20)
            tl.Position = UDim2.new(0, 10, 0, 6)
            tl.TextXAlignment = Enum.TextXAlignment.Left

            local content = Instance.new("Frame", box)
            content.BackgroundTransparency = 1
            content.Position = UDim2.new(0, 10, 0, 30)
            content.Size = UDim2.new(1, -20, 0, 0)
            content.AutomaticSize = Enum.AutomaticSize.Y
            local lay = Instance.new("UIListLayout", content)
            lay.Padding = UDim.new(0, 4)

            for i, text in ipairs(infoList or {}) do
                local item = Instance.new("Frame", content)
                item.BackgroundColor3 = T.surfaceHi
                item.BackgroundTransparency = 0.3
                item.BorderSizePixel = 0
                item.AutomaticSize = Enum.AutomaticSize.Y
                item.Size = UDim2.new(1, 0, 0, 0)
                item.ClipsDescendants = true
                newCorner(item, UDim.new(0, 4))
                newStroke(item, T.stroke, 1, 0.6)

                local num = Instance.new("TextLabel", item)
                num.Text = tostring(i) .. "."
                num.Font = Enum.Font.GothamBold
                num.TextSize = 10
                num.TextColor3 = T.accentHi
                num.BackgroundTransparency = 1
                num.Size = UDim2.new(0, 22, 1, 0)
                num.Position = UDim2.new(0, 6, 0, 0)
                num.TextXAlignment = Enum.TextXAlignment.Left
                num.TextYAlignment = Enum.TextYAlignment.Top

                local dl = Instance.new("TextLabel", item)
                dl.Text = text
                dl.Font = Enum.Font.Gotham
                dl.TextSize = 10
                dl.TextColor3 = T.text
                dl.BackgroundTransparency = 1
                dl.Position = UDim2.new(0, 28, 0, 4)
                dl.Size = UDim2.new(1, -34, 0, 0)
                dl.AutomaticSize = Enum.AutomaticSize.Y
                dl.TextWrapped = true
                dl.TextXAlignment = Enum.TextXAlignment.Left
                dl.TextYAlignment = Enum.TextYAlignment.Top
            end

            newPad(box, 0, 0, 0, 10)

            onTheme(function()
                tw(box, 0.35, { BackgroundColor3 = T.surface })
                tw(bx, 0.35, { Color = T.accentSoft })
                tw(tl, 0.35, { TextColor3 = T.text })
            end)

            return { MainFrame = box, TitleLabel = tl, ContentFrame = content }
        end

        -- ═══ PROMO BOX ═══
        function Tab:AddPromoBox(title, description, imageId, link, channelName)
            local box = Instance.new("Frame", page)
            box.Size = UDim2.new(1, 0, 0, 90)
            box.BackgroundColor3 = T.surface
            box.BackgroundTransparency = 0.05
            box.BorderSizePixel = 0
            box.ClipsDescendants = true
            newCorner(box, UDim.new(0, 6))
            local bx = newStroke(box, T.accentSoft, 1.2, 0.4)

            local ic = Instance.new("ImageLabel", box)
            ic.Size = UDim2.new(0, 60, 0, 60)
            ic.Position = UDim2.new(0, 10, 0, 10)
            ic.Image = "rbxassetid://" .. tostring(imageId)
            ic.BackgroundColor3 = T.surfaceHi
            ic.BorderSizePixel = 0
            ic.ScaleType = Enum.ScaleType.Fit
            newCorner(ic, UDim.new(0, 6))
            newStroke(ic, T.stroke, 1, 0.5)

            local ttl = Instance.new("TextLabel", box)
            ttl.Text = string.upper(title or "CANAL")
            ttl.Font = Enum.Font.GothamBold
            ttl.TextSize = 12
            ttl.TextColor3 = T.text
            ttl.BackgroundTransparency = 1
            ttl.Position = UDim2.new(0, 80, 0, 8)
            ttl.Size = UDim2.new(1, -90, 0, 16)
            ttl.TextXAlignment = Enum.TextXAlignment.Left

            local dl = Instance.new("TextLabel", box)
            dl.Text = description or ""
            dl.Font = Enum.Font.Gotham
            dl.TextSize = 9
            dl.TextColor3 = T.textDim
            dl.BackgroundTransparency = 1
            dl.Position = UDim2.new(0, 80, 0, 24)
            dl.Size = UDim2.new(1, -90, 0, 22)
            dl.TextWrapped = true
            dl.TextXAlignment = Enum.TextXAlignment.Left
            dl.TextYAlignment = Enum.TextYAlignment.Top

            local chBox = Instance.new("TextBox", box)
            chBox.Size = UDim2.new(1, -90, 0, 20)
            chBox.Position = UDim2.new(0, 80, 0, 56)
            chBox.BackgroundColor3 = T.surfaceHi
            chBox.Text = (channelName or "CANAL")
            chBox.TextColor3 = T.text
            chBox.Font = Enum.Font.GothamBold
            chBox.TextSize = 9
            chBox.TextEditable = false
            chBox.ClearTextOnFocus = false
            newCorner(chBox, UDim.new(0, 4))
            newStroke(chBox, T.accent, 1, 0.4)

            local copyBtn = Instance.new("TextButton", box)
            copyBtn.Size = UDim2.new(0, 80, 0, 20)
            copyBtn.Position = UDim2.new(1, -90, 0, 56)
            copyBtn.BackgroundColor3 = T.accentSoft
            copyBtn.Text = "COPIAR LINK"
            copyBtn.TextColor3 = T.text
            copyBtn.Font = Enum.Font.GothamBold
            copyBtn.TextSize = 9
            copyBtn.AutoButtonColor = false
            newCorner(copyBtn, UDim.new(0, 4))
            newStroke(copyBtn, T.accent, 1, 0.3)

            local fb = Instance.new("Frame", copyBtn)
            fb.Size = UDim2.new(0, 0, 1, 0)
            fb.BackgroundColor3 = T.accentHi
            fb.BorderSizePixel = 0
            fb.ZIndex = 1

            copyBtn.MouseButton1Click:Connect(function()
                pcall(function() if setclipboard then setclipboard(link) end end)
                fb.Size = UDim2.new(0, 0, 1, 0)
                fb:TweenSize(UDim2.new(1, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.4, true)
                Window:Notify({ Title = "COPIADO!", Text = "Link copiado", Type = "success", Duration = 2 })
            end)

            onTheme(function()
                tw(box, 0.35, { BackgroundColor3 = T.surface })
                tw(bx, 0.35, { Color = T.accentSoft })
                tw(ttl, 0.35, { TextColor3 = T.text })
                tw(dl, 0.35, { TextColor3 = T.textDim })
                tw(chBox, 0.35, { BackgroundColor3 = T.surfaceHi, TextColor3 = T.text })
                tw(copyBtn, 0.35, { BackgroundColor3 = T.accentSoft, TextColor3 = T.text })
            end)

            return {
                MainFrame = box,
                ChannelBox = chBox,
                DescriptionLabel = dl,
                CopyButton = copyBtn,
            }
        end

        tabsByName[tabName] = Tab
        return Tab
    end

    -- ═══════════════════════════════════════════════════════════════
    -- FLAT API (compatibilidade com estrutura antiga)
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateButton(tabName, text, callback, options)
        local tab = tabsByName[tabName]; if not tab then return end
        return tab:AddButton({ Title = text, Callback = callback })
    end

    function Window:CreateToggle(tabName, cfg)
        local tab = tabsByName[tabName]; if not tab then return end
        return tab:AddToggle(cfg)
    end

    function Window:CreateCheckbox(tabName, cfg)
        local tab = tabsByName[tabName]; if not tab then return end
        return tab:AddCheckbox(cfg)
    end

    function Window:CreateSwitch(tabName, cfg)
        local tab = tabsByName[tabName]; if not tab then return end
        return tab:AddSwitch(cfg)
    end

    function Window:CreateSlider(tabName, cfg)
        local tab = tabsByName[tabName]; if not tab then return end
        return tab:AddSlider(cfg)
    end

    function Window:CreateDropdown(tabName, cfg)
        local tab = tabsByName[tabName]; if not tab then return end
        return tab:AddDropdown(cfg)
    end

    function Window:CreateTextBox(tabName, placeholder, callback, options)
        local tab = tabsByName[tabName]; if not tab then return end
        local cfg = { Placeholder = placeholder, Callback = callback }
        if type(placeholder) == "table" then cfg = placeholder end
        if options then
            for k, v in pairs(options) do cfg[k] = v end
        end
        return tab:AddTextBox(cfg)
    end

    function Window:CreateKeybind(tabName, cfg)
        local tab = tabsByName[tabName]; if not tab then return end
        return tab:AddKeybind(cfg)
    end

    function Window:CreateColorPicker(tabName, cfg)
        local tab = tabsByName[tabName]; if not tab then return end
        return tab:AddColorPicker(cfg)
    end

    function Window:CreateLabel(tabName, text)
        local tab = tabsByName[tabName]; if not tab then return end
        return tab:AddLabel(text)
    end

    function Window:CreateLine(tabName, color)
        local tab = tabsByName[tabName]; if not tab then return end
        return tab:AddLine(color)
    end

    function Window:CreateSection(tabName, name)
        local tab = tabsByName[tabName]; if not tab then return end
        return tab:AddSection(name)
    end

    function Window:CreateParagraph(tabName, cfg)
        local tab = tabsByName[tabName]; if not tab then return end
        return tab:AddParagraph(cfg)
    end

    function Window:CreateInfoBox(tabName, title, infoList)
        local tab = tabsByName[tabName]; if not tab then return end
        return tab:AddInfoBox(title, infoList)
    end

    function Window:CreatePromoBox(tabName, title, description, imageId, link, channelName)
        local tab = tabsByName[tabName]; if not tab then return end
        return tab:AddPromoBox(title, description, imageId, link, channelName)
    end

    function Window:CreateThemeBoxes(tabName)
        local tab = tabsByName[tabName]; if not tab then return end
        return tab:AddThemeBoxes()
    end

    function Window:CreateProgressBar(tabName, cfg)
        local tab = tabsByName[tabName]; if not tab then return end
        return tab:AddProgressBar(cfg)
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

    local notifyQueue, notifying = {}, false

    function Window:Notify(cfg)
        if type(cfg) == "string" then
            local t = cfg
            cfg = { Title = t, Text = select(1, ...) or "" }
        end
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

    -- Compat com RANOX antigo: NotifyCustom(title, text, iconId)
    function Window:NotifyCustom(title, text, iconId)
        local type_ = "info"
        local t = string.upper(tostring(title or ""))
        if t:find("ATIV") or t:find("SUCESS") or t:find("OK") or t:find("ON") then type_ = "success" end
        if t:find("DESATIV") or t:find("OFF") or t:find("ERROR") then type_ = "danger" end
        if t:find("AVISO") or t:find("WARN") then type_ = "warning" end
        self:Notify({ Title = title, Text = text, Type = type_, Duration = 3 })
    end

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

    return Window
end

return NINOMAX
