--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║  RANOXHUB SPY · PROFESSIONAL EDITION · v3.0                       ║
    ║  ✦ Design glass/gradient estilo NINOMAX                           ║
    ║  ✦ Abas: Events / Controls / Settings / Info                      ║
    ║  ✦ Filtro, busca, favoritos, blocklist, stats                     ║
    ║  ✦ Argument viewer inteligente com tipos                          ║
    ║  ✦ Code viewer com syntax highlight                               ║
    ║  ✦ Multi-tema · Mobile-first · Animações suaves                   ║
    ╚══════════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════════════
--  SERVIÇOS
-- ═══════════════════════════════════════════════════════════════════
local Players         = game:GetService("Players")
local CoreGui         = game:GetService("CoreGui")
local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")
local UserInputService= game:GetService("UserInputService")
local TextService     = game:GetService("TextService")
local HttpService     = game:GetService("HttpService")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ═══════════════════════════════════════════════════════════════════
--  TEMAS
-- ═══════════════════════════════════════════════════════════════════
local Themes = {
    Blood = {
        gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 8, 12)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(36, 12, 18)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 8, 12)),
        }),
        bg = Color3.fromRGB(16, 6, 10),
        surface = Color3.fromRGB(28, 12, 18),
        surfaceHi = Color3.fromRGB(40, 18, 26),
        stroke = Color3.fromRGB(52, 22, 30),
        accent = Color3.fromRGB(200, 20, 40),
        accentHi = Color3.fromRGB(255, 55, 75),
        accentSoft = Color3.fromRGB(90, 8, 20),
        text = Color3.fromRGB(250, 240, 242),
        textDim = Color3.fromRGB(190, 160, 168),
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
}

local currentTheme = "Blood"
local T = Themes.Blood

local function setTheme(name)
    if not Themes[name] then return end
    currentTheme = name
    T = Themes[name]
    if State.onTheme then
        for _, fn in ipairs(State.onTheme) do pcall(fn) end
    end
end

-- ═══════════════════════════════════════════════════════════════════
--  UTILS
-- ═══════════════════════════════════════════════════════════════════
local function tw(inst, dur, props, style, dir)
    local t = TweenService:Create(inst, TweenInfo.new(dur or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    t:Play(); return t
end

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = r or UDim.new(0, 6); c.Parent = p; return c
end

local function stroke(p, col, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or T.stroke; s.Thickness = th or 1
    s.Transparency = tr or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p; return s
end

local function pad(p, t, l, r, b)
    local u = Instance.new("UIPadding", p)
    u.PaddingTop = UDim.new(0, t or 0); u.PaddingLeft = UDim.new(0, l or 0)
    u.PaddingRight = UDim.new(0, r or 0); u.PaddingBottom = UDim.new(0, b or 0)
    return u
end

local function draggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function formatType(v)
    local t = typeof(v)
    if t == "string" then return ("%q"):format(v) end
    if t == "number" or t == "boolean" or t == "nil" then return tostring(v) end
    if t == "Vector3" then return ("Vector3.new(%.2f, %.2f, %.2f)"):format(v.X, v.Y, v.Z) end
    if t == "Vector2" then return ("Vector2.new(%.2f, %.2f)"):format(v.X, v.Y) end
    if t == "CFrame" then
        local p = v.Position
        return ("CFrame.new(%.2f, %.2f, %.2f)"):format(p.X, p.Y, p.Z)
    end
    if t == "Color3" then return ("Color3.new(%.2f, %.2f, %.2f)"):format(v.R, v.G, v.B) end
    if t == "Instance" then return ("game:GetService(\"%s\"):FindFirstChild(\"%s\", true)"):format(
        (function() local p = v.Parent; while p and p.Parent do p = p.Parent end; return p and p.Name or "Workspace" end)(),
        v.Name
    ) end
    if t == "EnumItem" then return ("Enum.%s.%s"):format(v.EnumType.Name, v.Name) end
    if t == "table" then
        local parts = {}
        for k, val in pairs(v) do
            table.insert(parts, ("[%s]=%s"):format(formatType(k), formatType(val)))
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    end
    return tostring(v)
end

-- ═══════════════════════════════════════════════════════════════════
--  ESTADO GLOBAL
-- ═══════════════════════════════════════════════════════════════════
local State = {
    onTheme = {},
    buffer = {},
    eventEntries = {},
    eventOrder = {},
    selectedRemote = nil,
    selectedArgs = nil,
    selectedCode = nil,
    isSpamming = false,
    spamConnection = nil,
    spamCount = 1,
    autoBlockEnabled = false,
    blockedEvents = {},
    favoriteEvents = {},
    filterMode = "Todos",
    searchQuery = "",
    isMinimized = false,
    totalCaptured = 0,
    paused = false,
    internalCallFlag = false,
    maxEvents = 999,
    notificationsEnabled = false,
}

local buffer = State.buffer

-- ═══════════════════════════════════════════════════════════════════
--  SYNTAX HIGHLIGHT (compactado + otimizado)
-- ═══════════════════════════════════════════════════════════════════
local Highlight = {}
local parentFrame, scrollingFrame, textFrame, lineNumbersFrame
local tableContents = {}
local line, largestX = 0, 0
local lineSpace, font, textSize = 15, Enum.Font.Code, 13

local HIGHLIGHT_COLORS = {
    bg        = Color3.fromRGB(15, 10, 16),
    operator  = Color3.fromRGB(187, 85, 255),
    func      = Color3.fromRGB(97, 175, 239),
    string_   = Color3.fromRGB(152, 195, 121),
    number    = Color3.fromRGB(209, 154, 102),
    boolean   = Color3.fromRGB(209, 154, 102),
    object    = Color3.fromRGB(229, 192, 123),
    default   = Color3.fromRGB(224, 108, 117),
    comment   = Color3.fromRGB(148, 148, 148),
    lineNum   = Color3.fromRGB(100, 100, 110),
    generic   = Color3.fromRGB(240, 240, 240),
}

local PATTERNS = {
    operators = {"^(function)[^%w_]", "^(local)[^%w_]", "^(if)[^%w_]", "^(for)[^%w_]", "^(while)[^%w_]", "^(then)[^%w_]", "^(do)[^%w_]", "^(else)[^%w_]", "^(elseif)[^%w_]", "^(return)[^%w_]", "^(end)[^%w_]", "^(continue)[^%w_]", "^(and)[^%w_]", "^(not)[^%w_]", "^(or)[^%w_]", "[^%w_](or)[^%w_]", "[^%w_](and)[^%w_]", "[^%w_](not)[^%w_]", "[^%w_](function)[^%w_]", "[^%w_](local)[^%w_]", "[^%w_](if)[^%w_]", "[^%w_](for)[^%w_]", "[^%w_](while)[^%w_]", "[^%w_](then)[^%w_]", "[^%w_](do)[^%w_]", "[^%w_](else)[^%w_]", "[^%w_](elseif)[^%w_]", "[^%w_](return)[^%w_]", "[^%w_](end)[^%w_]"},
    strings   = {{"\"", "\""}, {"'", "'"}, {"%[%[", "%]%]", true}},
    comments  = {"%-%-%[%[[^%]%]]+%]?%]", "(%-%-[^\n]+)"},
    functions = {"[^%w_]([%a_][%a%d_]*)%s*%(", "^([%a_][%a%d_]*)%s*%(", "[:%.%(%[%p]([%a_][%a%d_]*)%s*%("},
    numbers   = {"[^%w_](%d+[eE]?%d*)", "[^%w_](%.%d+[eE]?%d*)", "[^%w_](%d+%.%d+[eE]?%d*)", "^(%d+[eE]?%d*)", "^(%.%d+[eE]?%d*)", "^(%d+%.%d+[eE]?%d*)"},
    booleans  = {"[^%w_](true)", "^(true)", "[^%w_](false)", "^(false)", "[^%w_](nil)", "^(nil)"},
    objects   = {"[^%w_:]([%a_][%a%d_]*):", "^([%a_][%a%d_]*):"},
    other     = {"[^_%s%w=>~<%-%+%*]", ">", "~", "<", "%-", "%+", "=", "%*"},
}
local offLimits = {}

local function isOffLimits(i) for _, v in ipairs(offLimits) do if i >= v[1] and i <= v[2] then return true end end return false end

local function gfind(str, pat)
    return coroutine.wrap(function()
        local s = 0
        while true do
            local a, b = str:find(pat, s)
            if a and b ~= #str then s = b + 1; coroutine.yield(a, b) else return end
        end
    end)
end

local function autoEscape(s)
    s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;")
    return s
end

local function highlightPattern(arr, color)
    local str = Highlight:getRaw()
    for _, pat in ipairs(arr) do
        for s, e in gfind(str, pat) do
            if not isOffLimits(s) and not isOffLimits(e) then
                for i = s, e do
                    if tableContents[i] then tableContents[i].Color = color end
                end
            end
        end
    end
end

local function renderComments()
    local str = Highlight:getRaw()
    for _, pat in ipairs(PATTERNS.comments) do
        for s, e in gfind(str, pat) do
            if not isOffLimits(s) then
                table.insert(offLimits, {s, e})
                for i = s, e do if tableContents[i] then tableContents[i].Color = HIGHLIGHT_COLORS.comment end end
            end
        end
    end
end

local function renderStrings()
    local sType, sEnd, iSlash, sStart, offIdx, skip = nil, nil, nil, nil, 0, false
    for i, ch in ipairs(tableContents) do
        if sType then
            ch.Color = HIGHLIGHT_COLORS.string_
            local p = ""
            for k = sStart, i do p = p .. tableContents[k].Char end
            if ch.Char:match(sEnd) and not not iSlash or (p:match("(\\*)" .. sEnd .. "$") and #p:match("(\\*)" .. sEnd .. "$") % 2 == 0) then
                skip = true; sType = nil; sEnd = nil; iSlash = nil
                offLimits[offIdx][2] = i
            end
        end
        if not skip then
            for _, v in ipairs(PATTERNS.strings) do
                if ch.Char:match(v[1]) and not isOffLimits(i) then
                    sType = v[1]; sEnd = v[2]; iSlash = v[3]; ch.Color = HIGHLIGHT_COLORS.string_
                    sStart = i; offIdx = #offLimits + 1
                    offLimits[offIdx] = {sStart, math.huge}
                end
            end
        end
        skip = false
    end
end

function Highlight:render()
    offLimits = {}
    textFrame:ClearAllChildren(); lineNumbersFrame:ClearAllChildren()
    highlightPattern(PATTERNS.functions, HIGHLIGHT_COLORS.func)
    highlightPattern(PATTERNS.numbers, HIGHLIGHT_COLORS.number)
    highlightPattern(PATTERNS.operators, HIGHLIGHT_COLORS.operator)
    highlightPattern(PATTERNS.objects, HIGHLIGHT_COLORS.object)
    highlightPattern(PATTERNS.booleans, HIGHLIGHT_COLORS.boolean)
    highlightPattern(PATTERNS.other, HIGHLIGHT_COLORS.generic)
    renderComments(); renderStrings()

    local lastColor, lineStr, rawStr, numLine = nil, "", "", 1
    largestX = 0
    for i = 1, #tableContents + 1 do
        local ch = tableContents[i]
        if i == #tableContents + 1 or ch.Char == "\n" then
            lineStr = lineStr .. (lastColor and "</font>" or "")
            local lbl = Instance.new("TextLabel")
            local x = TextService:GetTextSize(rawStr, textSize, font, Vector2.new(math.huge, math.huge)).X + 60
            if x > largestX then largestX = x end
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextYAlignment = Enum.TextYAlignment.Top
            lbl.Position = UDim2.new(0, 0, 0, numLine * lineSpace - lineSpace / 2)
            lbl.Size = UDim2.new(0, x, 0, textSize)
            lbl.RichText = true
            lbl.Font = font; lbl.TextSize = textSize
            lbl.BackgroundTransparency = 1
            lbl.Text = lineStr
            lbl.TextColor3 = HIGHLIGHT_COLORS.default
            lbl.Parent = textFrame
            if i ~= #tableContents + 1 then
                local ln = Instance.new("TextLabel")
                ln.Text = numLine; ln.Font = font; ln.TextSize = textSize
                ln.Size = UDim2.new(1, 0, 0, lineSpace)
                ln.TextXAlignment = Enum.TextXAlignment.Right
                ln.TextColor3 = HIGHLIGHT_COLORS.lineNum
                ln.Position = UDim2.new(0, 0, 0, numLine * lineSpace - lineSpace / 2)
                ln.BackgroundTransparency = 1; ln.Parent = lineNumbersFrame
            end
            lineStr = ""; rawStr = ""; lastColor = nil; numLine = numLine + 1
        elseif ch.Char == " " then
            lineStr = lineStr .. ch.Char; rawStr = rawStr .. ch.Char
        elseif ch.Char == "\t" then
            lineStr = lineStr .. string.rep(" ", 4); rawStr = rawStr .. ch.Char
        else
            if ch.Color == lastColor then
                lineStr = lineStr .. autoEscape(ch.Char)
            else
                lineStr = lineStr .. string.format('%s<font color="rgb(%d,%d,%d)">',
                    lastColor and "</font>" or "",
                    math.floor(ch.Color.R*255), math.floor(ch.Color.G*255), math.floor(ch.Color.B*255))
                lineStr = lineStr .. autoEscape(ch.Char)
                lastColor = ch.Color
            end
            rawStr = rawStr .. ch.Char
        end
    end
    line = numLine
    scrollingFrame.CanvasSize = UDim2.new(0, largestX, 0, line * lineSpace)
end

function Highlight:init(fr)
    if typeof(fr) ~= "Instance" or not fr:IsA("Frame") then error("Highlight:init espera Frame") end
    fr:ClearAllChildren()
    parentFrame = fr
    scrollingFrame = Instance.new("ScrollingFrame")
    textFrame = Instance.new("Frame")
    lineNumbersFrame = Instance.new("Frame")

    scrollingFrame.Name = "HIGHLIGHT_IDE"
    scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollingFrame.BackgroundColor3 = HIGHLIGHT_COLORS.bg
    scrollingFrame.BorderSizePixel = 0
    scrollingFrame.ScrollBarThickness = 4
    scrollingFrame.ScrollBarImageColor3 = T.accent

    textFrame.Size = UDim2.new(1, -50, 1, 0)
    textFrame.Position = UDim2.new(0, 45, 0, 0)
    textFrame.BackgroundTransparency = 1

    lineNumbersFrame.Size = UDim2.new(0, 35, 1, 0)
    lineNumbersFrame.BackgroundTransparency = 1

    textFrame.Parent = scrollingFrame
    lineNumbersFrame.Parent = scrollingFrame
    scrollingFrame.Parent = parentFrame

    fr:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    end)
    Highlight:render()
end

function Highlight:setRaw(raw)
    raw = raw .. "\n"
    tableContents = {}
    for i = 1, #raw do
        table.insert(tableContents, { Char = raw:sub(i, i), Color = HIGHLIGHT_COLORS.default })
    end
    Highlight:render()
end

function Highlight:getRaw()
    local r = ""
    for _, c in ipairs(tableContents) do r = r .. c.Char end
    return r
end

local function newHighlight(fr)
    local obj = setmetatable({}, { __index = Highlight })
    Highlight.__index = Highlight
    obj:init(fr)
    return obj
end

-- ═══════════════════════════════════════════════════════════════════
--  SCREEN GUI
-- ═══════════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RANOX_SPY_PRO"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

local uiScale = Instance.new("UIScale", ScreenGui)
uiScale.Scale = isMobile and 0.95 or 1

-- ═══ MAIN FRAME ═══
local MAIN_W, MAIN_H = 680, 480
local MainFrame = Instance.new("ImageButton")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, MAIN_W, 0, MAIN_H)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = T.bg
MainFrame.BackgroundTransparency = 0.03
MainFrame.AutoButtonColor = false
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui
corner(MainFrame, UDim.new(0, 14))

local mainStroke = stroke(MainFrame, T.stroke, 1.4, 0.3)
local mainGrad = Instance.new("UIGradient", MainFrame)
mainGrad.Rotation = 45
mainGrad.Color = T.gradient

-- ═══ TOP BAR ═══
local topBar = Instance.new("Frame", MainFrame)
topBar.Size = UDim2.new(1, 0, 0, 36)
topBar.BackgroundTransparency = 1
topBar.ZIndex = 5

-- Logo badge
local logoBadge = Instance.new("Frame", topBar)
logoBadge.Size = UDim2.new(0, 22, 0, 22)
logoBadge.Position = UDim2.new(0, 12, 0.5, -11)
logoBadge.BackgroundColor3 = T.accent
logoBadge.BorderSizePixel = 0
corner(logoBadge, UDim.new(0, 6))
local logoText = Instance.new("TextLabel", logoBadge)
logoText.Size = UDim2.new(1, 0, 1, 0)
logoText.BackgroundTransparency = 1
logoText.Text = "⚡"
logoText.TextSize = 14
logoText.TextColor3 = Color3.new(1, 1, 1)
logoText.Font = Enum.Font.GothamBold

-- Title (NINO/MAX style)
local titleNino = Instance.new("TextLabel", topBar)
titleNino.BackgroundTransparency = 1
titleNino.Position = UDim2.new(0, 42, 0.5, -8)
titleNino.Size = UDim2.new(0, 100, 0, 16)
titleNino.Font = Enum.Font.GothamBold
titleNino.TextSize = 14
titleNino.TextColor3 = Color3.fromRGB(255, 255, 255)
titleNino.TextXAlignment = Enum.TextXAlignment.Left
titleNino.Text = "RANOX"
titleNino.ZIndex = 6

local titleMax = Instance.new("TextLabel", topBar)
titleMax.BackgroundTransparency = 1
titleMax.Position = UDim2.new(0, 105, 0.5, -8)
titleMax.Size = UDim2.new(0, 100, 0, 16)
titleMax.Font = Enum.Font.GothamBold
titleMax.TextSize = 14
titleMax.TextColor3 = T.accentHi
titleMax.TextXAlignment = Enum.TextXAlignment.Left
titleMax.Text = "SPY"
titleMax.ZIndex = 6

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
subtitle.Position = UDim2.new(0, 142, 0.5, -3)
subtitle.Size = UDim2.new(0, 100, 0, 14)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 9
subtitle.TextColor3 = T.textDim
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Text = "PRO · v3.0"

-- Botões (min/close)
local btnMin = Instance.new("ImageButton", topBar)
btnMin.Size = UDim2.new(0, 20, 0, 20)
btnMin.Position = UDim2.new(1, -56, 0.5, -10)
btnMin.BackgroundTransparency = 1
btnMin.Image = "rbxassetid://10734896206"
btnMin.ImageColor3 = T.textDim
btnMin.AutoButtonColor = false

local btnClose = Instance.new("ImageButton", topBar)
btnClose.Size = UDim2.new(0, 20, 0, 20)
btnClose.Position = UDim2.new(1, -30, 0.5, -10)
btnClose.BackgroundTransparency = 1
btnClose.Image = "rbxassetid://10747384394"
btnClose.ImageColor3 = T.textDim
btnClose.AutoButtonColor = false

btnClose.MouseEnter:Connect(function() tw(btnClose, 0.15, { ImageColor3 = Color3.fromRGB(255, 90, 90) }) end)
btnClose.MouseLeave:Connect(function() tw(btnClose, 0.15, { ImageColor3 = T.textDim }) end)
btnMin.MouseEnter:Connect(function() tw(btnMin, 0.15, { ImageColor3 = T.accentHi }) end)
btnMin.MouseLeave:Connect(function() tw(btnMin, 0.15, { ImageColor3 = T.textDim }) end)

draggable(MainFrame, topBar)

-- Separador
local sep = Instance.new("Frame", MainFrame)
sep.Size = UDim2.new(1, 0, 0, 1)
sep.Position = UDim2.new(0, 0, 0, 36)
sep.BackgroundColor3 = T.stroke
sep.BackgroundTransparency = 0.4
sep.BorderSizePixel = 0

-- ═══ SIDEBAR (tabs) ═══
local sidebar = Instance.new("Frame", MainFrame)
sidebar.Size = UDim2.new(0, 130, 1, -37)
sidebar.Position = UDim2.new(0, 0, 0, 37)
sidebar.BackgroundTransparency = 0.6
sidebar.BackgroundColor3 = T.surface
sidebar.BorderSizePixel = 0
pad(sidebar, 8, 6, 6, 8)

local sideLay = Instance.new("UIListLayout", sidebar)
sideLay.SortOrder = Enum.SortOrder.LayoutOrder
sideLay.Padding = UDim.new(0, 4)

local tabs, pages = {}, {}
local currentTab = nil

local function switchTab(name)
    for tn, f in pairs(pages) do f.Visible = (tn == name) end
    for tn, b in pairs(tabs) do
        local m = b:FindFirstChild("Marker")
        if m then
            tw(m, 0.25, {
                Size = (tn == name) and UDim2.new(0, 3, 1, -8) or UDim2.new(0, 3, 0, 4),
                BackgroundTransparency = (tn == name) and 0 or 1,
            }, Enum.EasingStyle.Back)
        end
        local lbl = b:FindFirstChild("Lbl")
        if lbl then
            tw(lbl, 0.2, { TextTransparency = (tn == name) and 0 or 0.4 })
        end
        tw(b, 0.2, {
            BackgroundColor3 = (tn == name) and T.surfaceHi or T.surface,
            BackgroundTransparency = (tn == name) and 0 or 1,
        })
    end
    currentTab = name
end

local function createTabBtn(name, icon, layoutOrder)
    local b = Instance.new("TextButton", sidebar)
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = T.surface
    b.BackgroundTransparency = 1
    b.Text = ""
    b.AutoButtonColor = false
    b.ClipsDescendants = true
    b.LayoutOrder = layoutOrder or 0
    corner(b, UDim.new(0, 6))
    stroke(b, T.stroke, 1, 1)

    local marker = Instance.new("Frame", b)
    marker.Name = "Marker"
    marker.Size = UDim2.new(0, 3, 0, 4)
    marker.Position = UDim2.new(0, 0, 0.5, -2)
    marker.BackgroundColor3 = T.accentHi
    marker.BorderSizePixel = 0
    marker.BackgroundTransparency = 1
    corner(marker, UDim.new(0, 3))

    local iconLbl = Instance.new("ImageLabel", b)
    iconLbl.Size = UDim2.new(0, 14, 0, 14)
    iconLbl.Position = UDim2.new(0, 10, 0.5, -7)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Image = icon
    iconLbl.ImageColor3 = T.textDim
    iconLbl.ImageTransparency = 0.3

    local lbl = Instance.new("TextLabel", b)
    lbl.Name = "Lbl"
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 11
    lbl.TextColor3 = T.text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTransparency = 0.4
    lbl.Position = UDim2.new(0, 32, 0, 0)
    lbl.Size = UDim2.new(1, -36, 1, 0)

    tabs[name] = b
    b.MouseEnter:Connect(function()
        if currentTab ~= name then
            tw(b, 0.15, { BackgroundColor3 = T.surfaceHi, BackgroundTransparency = 0.5 })
        end
    end)
    b.MouseLeave:Connect(function()
        if currentTab ~= name then
            tw(b, 0.15, { BackgroundTransparency = 1 })
        end
    end)
    b.MouseButton1Click:Connect(function() switchTab(name) end)
end

-- ═══ PÁGINAS CONTAINER ═══
local pageHolder = Instance.new("Frame", MainFrame)
pageHolder.Size = UDim2.new(1, -140, 1, -47)
pageHolder.Position = UDim2.new(0, 134, 0, 42)
pageHolder.BackgroundTransparency = 1

local function createPage(name)
    local p = Instance.new("Frame", pageHolder)
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = false
    pages[name] = p
    return p
end

-- ═══════════════════════════════════════════════════════════════════
--  ▸ ABA: EVENTS
-- ═══════════════════════════════════════════════════════════════════
createTabBtn("Events", "rbxassetid://10723433811", 1)
local EventsPage = createPage("Events")

-- Barra de busca + stats
local searchBar = Instance.new("Frame", EventsPage)
searchBar.Size = UDim2.new(1, 0, 0, 30)
searchBar.BackgroundColor3 = T.surface
searchBar.BackgroundTransparency = 0.05
searchBar.BorderSizePixel = 0
corner(searchBar, UDim.new(0, 6))
stroke(searchBar, T.stroke, 1, 0.6)

local searchIcon = Instance.new("ImageLabel", searchBar)
searchIcon.Size = UDim2.new(0, 14, 0, 14)
searchIcon.Position = UDim2.new(0, 8, 0.5, -7)
searchIcon.BackgroundTransparency = 1
searchIcon.Image = "rbxassetid://10734943674"
searchIcon.ImageColor3 = T.textDim

local searchBox = Instance.new("TextBox", searchBar)
searchBox.Size = UDim2.new(1, -90, 1, 0)
searchBox.Position = UDim2.new(0, 28, 0, 0)
searchBox.BackgroundTransparency = 1
searchBox.Text = ""
searchBox.PlaceholderText = "Buscar evento por nome..."
searchBox.PlaceholderColor3 = T.textDim
searchBox.TextColor3 = T.text
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 11
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false

local statsLbl = Instance.new("TextLabel", searchBar)
statsLbl.Size = UDim2.new(0, 60, 1, 0)
statsLbl.Position = UDim2.new(1, -62, 0, 0)
statsLbl.BackgroundTransparency = 1
statsLbl.Text = "0 ev."
statsLbl.Font = Enum.Font.GothamBold
statsLbl.TextSize = 10
statsLbl.TextColor3 = T.accentHi
statsLbl.TextXAlignment = Enum.TextXAlignment.Right

-- Filtros (chips)
local filterBar = Instance.new("Frame", EventsPage)
filterBar.Size = UDim2.new(1, 0, 0, 24)
filterBar.Position = UDim2.new(0, 0, 0, 34)
filterBar.BackgroundTransparency = 1
local filterLay = Instance.new("UIListLayout", filterBar)
filterLay.FillDirection = Enum.FillDirection.Horizontal
filterLay.Padding = UDim.new(0, 4)

local filterChips = {}
local function createFilterChip(name)
    local c = Instance.new("TextButton", filterBar)
    c.Size = UDim2.new(0, 60, 1, 0)
    c.BackgroundColor3 = T.surface
    c.Text = name
    c.Font = Enum.Font.GothamMedium
    c.TextSize = 10
    c.TextColor3 = T.text
    c.AutoButtonColor = false
    corner(c, UDim.new(0, 4))
    stroke(c, T.stroke, 1, 0.5)
    filterChips[name] = c

    c.MouseButton1Click:Connect(function()
        State.filterMode = name
        for n, chip in pairs(filterChips) do
            if n == name then
                tw(chip, 0.2, { BackgroundColor3 = T.accent, TextColor3 = Color3.new(1, 1, 1) })
            else
                tw(chip, 0.2, { BackgroundColor3 = T.surface, TextColor3 = T.text })
            end
        end
        for _, entry in pairs(State.eventEntries) do
            applyFilter(entry)
        end
    end)
end
createFilterChip("Todos"); createFilterChip("Event"); createFilterChip("Func"); createFilterChip("Favoritos")
filterChips["Todos"].BackgroundColor3 = T.accent
filterChips["Todos"].TextColor3 = Color3.new(1, 1, 1)

-- Divisão: Lista (esquerda) + Code Viewer (direita)
local splitFrame = Instance.new("Frame", EventsPage)
splitFrame.Size = UDim2.new(1, 0, 1, -66)
splitFrame.Position = UDim2.new(0, 0, 0, 62)
splitFrame.BackgroundTransparency = 1

-- LISTA
local listPanel = Instance.new("Frame", splitFrame)
listPanel.Size = UDim2.new(0.42, -3, 1, 0)
listPanel.Position = UDim2.new(0, 0, 0, 0)
listPanel.BackgroundColor3 = T.surface
listPanel.BackgroundTransparency = 0.05
listPanel.BorderSizePixel = 0
corner(listPanel, UDim.new(0, 8))
stroke(listPanel, T.stroke, 1, 0.6)

local listHeader = Instance.new("Frame", listPanel)
listHeader.Size = UDim2.new(1, 0, 0, 24)
listHeader.BackgroundColor3 = T.surfaceHi
listHeader.BackgroundTransparency = 0.3
listHeader.BorderSizePixel = 0
corner(listHeader, UDim.new(0, 8))
local lhLbl = Instance.new("TextLabel", listHeader)
lhLbl.Size = UDim2.new(1, -10, 1, 0)
lhLbl.Position = UDim2.new(0, 8, 0, 0)
lhLbl.BackgroundTransparency = 1
lhLbl.Text = "EVENTOS CAPTURADOS"
lhLbl.TextColor3 = T.accentHi
lhLbl.Font = Enum.Font.GothamBold
lhLbl.TextSize = 10
lhLbl.TextXAlignment = Enum.TextXAlignment.Left

local EventsList = Instance.new("ScrollingFrame", listPanel)
EventsList.Size = UDim2.new(1, -8, 1, -32)
EventsList.Position = UDim2.new(0, 4, 0, 28)
EventsList.BackgroundTransparency = 1
EventsList.CanvasSize = UDim2.new(0, 0, 0, 0)
EventsList.ScrollBarThickness = 3
EventsList.ScrollBarImageColor3 = T.accent
EventsList.ScrollBarImageTransparency = 0.4
EventsList.AutomaticCanvasSize = Enum.AutomaticSize.Y
EventsList.BorderSizePixel = 0

local EventsLay = Instance.new("UIListLayout", EventsList)
EventsLay.SortOrder = Enum.SortOrder.LayoutOrder
EventsLay.Padding = UDim.new(0, 3)

-- CODE VIEWER
local codePanel = Instance.new("Frame", splitFrame)
codePanel.Size = UDim2.new(0.58, -3, 1, 0)
codePanel.Position = UDim2.new(0.42, 3, 0, 0)
codePanel.BackgroundColor3 = T.surface
codePanel.BackgroundTransparency = 0.05
codePanel.BorderSizePixel = 0
corner(codePanel, UDim.new(0, 8))
stroke(codePanel, T.stroke, 1, 0.6)

local codeHeader = Instance.new("Frame", codePanel)
codeHeader.Size = UDim2.new(1, 0, 0, 24)
codeHeader.BackgroundColor3 = T.surfaceHi
codeHeader.BackgroundTransparency = 0.3
codeHeader.BorderSizePixel = 0
corner(codeHeader, UDim.new(0, 8))

local chLbl = Instance.new("TextLabel", codeHeader)
chLbl.Size = UDim2.new(1, -10, 1, 0)
chLbl.Position = UDim2.new(0, 8, 0, 0)
chLbl.BackgroundTransparency = 1
chLbl.Text = "CODE VIEWER"
chLbl.TextColor3 = T.accentHi
chLbl.Font = Enum.Font.GothamBold
chLbl.TextSize = 10
chLbl.TextXAlignment = Enum.TextXAlignment.Left

local codeDisplay = Instance.new("Frame", codePanel)
codeDisplay.Size = UDim2.new(1, -8, 1, -60)
codeDisplay.Position = UDim2.new(0, 4, 0, 28)
codeDisplay.BackgroundColor3 = Color3.fromRGB(15, 10, 16)
codeDisplay.BorderSizePixel = 0
corner(codeDisplay, UDim.new(0, 5))

local highlighter = newHighlight(codeDisplay)
highlighter:setRaw("-- Selecione um evento à esquerda para visualizar")

-- BOTÕES (barra inferior do code)
local btnBar = Instance.new("Frame", codePanel)
btnBar.Size = UDim2.new(1, -8, 0, 26)
btnBar.Position = UDim2.new(0, 4, 1, -30)
btnBar.BackgroundTransparency = 1
local btnLay = Instance.new("UIListLayout", btnBar)
btnLay.FillDirection = Enum.FillDirection.Horizontal
btnLay.Padding = UDim.new(0, 3)

local function createBarBtn(text, color, cb, width)
    local b = Instance.new("TextButton", btnBar)
    b.Size = UDim2.new(width or 0.2, -2, 1, 0)
    b.BackgroundColor3 = color or T.surfaceHi
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    b.TextColor3 = T.text
    b.AutoButtonColor = false
    corner(b, UDim.new(0, 4))
    stroke(b, T.stroke, 1, 0.5)
    b.MouseEnter:Connect(function() tw(b, 0.15, { BackgroundColor3 = T.accentHi }) end)
    b.MouseLeave:Connect(function() tw(b, 0.15, { BackgroundColor3 = color or T.surfaceHi }) end)
    b.MouseButton1Click:Connect(cb)
    return b
end

-- ═══════════════════════════════════════════════════════════════════
--  ▸ ABA: CONTROLS
-- ═══════════════════════════════════════════════════════════════════
createTabBtn("Controls", "rbxassetid://10734950309", 2)
local ControlsPage = createPage("Controls")

local ctrlLay = Instance.new("UIListLayout", ControlsPage)
ctrlLay.SortOrder = Enum.SortOrder.LayoutOrder
ctrlLay.Padding = UDim.new(0, 8)

local function sectionHeader(title, text, order)
    local fr = Instance.new("Frame", ControlsPage)
    fr.Size = UDim2.new(1, 0, 0, 22)
    fr.BackgroundTransparency = 1
    fr.LayoutOrder = order
    local l = Instance.new("TextLabel", fr)
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = title
    l.TextColor3 = T.accentHi
    l.Font = Enum.Font.GothamBold
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    return fr, l
end

local function makeCard(order, h)
    local card = Instance.new("Frame", ControlsPage)
    card.Size = UDim2.new(1, 0, 0, h or 48)
    card.BackgroundColor3 = T.surface
    card.BackgroundTransparency = 0.05
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    corner(card, UDim.new(0, 6))
    stroke(card, T.stroke, 1, 0.6)
    return card
end

-- Painel de spam
sectionHeader("SPAM CONTROL", "", 1)
local spamCard = makeCard(2, 90)

local spamTitle = Instance.new("TextLabel", spamCard)
spamTitle.Position = UDim2.new(0, 10, 0, 6)
spamTitle.Size = UDim2.new(1, -20, 0, 14)
spamTitle.BackgroundTransparency = 1
spamTitle.Text = "Execução automática (Heartbeat)"
spamTitle.Font = Enum.Font.GothamMedium
spamTitle.TextSize = 11
spamTitle.TextColor3 = T.text
spamTitle.TextXAlignment = Enum.TextXAlignment.Left

local spamSub = Instance.new("TextLabel", spamCard)
spamSub.Position = UDim2.new(0, 10, 0, 22)
spamSub.Size = UDim2.new(1, -20, 0, 12)
spamSub.BackgroundTransparency = 1
spamSub.Text = "Executa o evento selecionado N vezes por frame"
spamSub.Font = Enum.Font.Gotham
spamSub.TextSize = 9
spamSub.TextColor3 = T.textDim
spamSub.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle spam
local spamBtn = Instance.new("TextButton", spamCard)
spamBtn.Size = UDim2.new(0, 100, 0, 28)
spamBtn.Position = UDim2.new(0, 10, 0, 50)
spamBtn.BackgroundColor3 = T.surfaceHi
spamBtn.Text = "OFF"
spamBtn.TextColor3 = T.text
spamBtn.Font = Enum.Font.GothamBold
spamBtn.TextSize = 11
spamBtn.AutoButtonColor = false
corner(spamBtn, UDim.new(0, 5))
stroke(spamBtn, T.stroke, 1, 0.4)

-- Count box
local countBox = Instance.new("TextBox", spamCard)
countBox.Size = UDim2.new(0, 60, 0, 28)
countBox.Position = UDim2.new(0, 118, 0, 50)
countBox.BackgroundColor3 = T.surfaceHi
countBox.Text = "1"
countBox.PlaceholderText = "1-100"
countBox.TextColor3 = T.text
countBox.Font = Enum.Font.GothamBold
countBox.TextSize = 12
countBox.ClearTextOnFocus = false
countBox.BorderSizePixel = 0
corner(countBox, UDim.new(0, 5))
stroke(countBox, T.stroke, 1, 0.4)

-- Presets
local presets = {5, 25, 50, 100}
local presetX = 185
for _, n in ipairs(presets) do
    local p = Instance.new("TextButton", spamCard)
    p.Size = UDim2.new(0, 35, 0, 28)
    p.Position = UDim2.new(0, presetX, 0, 50)
    p.BackgroundColor3 = T.surfaceHi
    p.Text = tostring(n)
    p.TextColor3 = T.text
    p.Font = Enum.Font.GothamBold
    p.TextSize = 10
    p.AutoButtonColor = false
    corner(p, UDim.new(0, 5))
    stroke(p, T.stroke, 1, 0.4)
    p.MouseButton1Click:Connect(function()
        countBox.Text = tostring(n)
        spamCount = n
    end)
    p.MouseEnter:Connect(function() tw(p, 0.15, { BackgroundColor3 = T.accentHi }) end)
    p.MouseLeave:Connect(function() tw(p, 0.15, { BackgroundColor3 = T.surfaceHi }) end)
    presetX = presetX + 40
end

-- Status
local spamStatus = Instance.new("TextLabel", spamCard)
spamStatus.Size = UDim2.new(0, 120, 0, 28)
spamStatus.Position = UDim2.new(1, -130, 0, 50)
spamStatus.BackgroundTransparency = 1
spamStatus.Text = "🛑 Parado"
spamStatus.Font = Enum.Font.GothamBold
spamStatus.TextSize = 10
spamStatus.TextColor3 = T.textDim
spamStatus.TextXAlignment = Enum.TextXAlignment.Right

-- AutoBlock
sectionHeader("AUTO BLOCK", "", 3)
local abCard = makeCard(4, 60)

local abTitle = Instance.new("TextLabel", abCard)
abTitle.Position = UDim2.new(0, 10, 0, 6)
abTitle.Size = UDim2.new(1, -20, 0, 14)
abTitle.BackgroundTransparency = 1
abTitle.Text = "Bloquear duplicatas automaticamente"
abTitle.Font = Enum.Font.GothamMedium
abTitle.TextSize = 11
abTitle.TextColor3 = T.text
abTitle.TextXAlignment = Enum.TextXAlignment.Left

local abSub = Instance.new("TextLabel", abCard)
abSub.Position = UDim2.new(0, 10, 0, 22)
abSub.Size = UDim2.new(1, -130, 0, 12)
abSub.BackgroundTransparency = 1
abSub.Text = "Ignora eventos com mesmo código"
abSub.Font = Enum.Font.Gotham
abSub.TextSize = 9
abSub.TextColor3 = T.textDim
abSub.TextXAlignment = Enum.TextXAlignment.Left

local abBtn = Instance.new("TextButton", abCard)
abBtn.Size = UDim2.new(0, 110, 0, 28)
abBtn.Position = UDim2.new(1, -120, 0.5, -14)
abBtn.BackgroundColor3 = T.surfaceHi
abBtn.Text = "OFF"
abBtn.TextColor3 = T.text
abBtn.Font = Enum.Font.GothamBold
abBtn.TextSize = 11
abBtn.AutoButtonColor = false
corner(abBtn, UDim.new(0, 5))
stroke(abBtn, T.stroke, 1, 0.4)

-- Pause Capture
sectionHeader("CAPTURE", "", 5)
local capCard = makeCard(6, 60)

local capTitle = Instance.new("TextLabel", capCard)
capTitle.Position = UDim2.new(0, 10, 0, 6)
capTitle.Size = UDim2.new(1, -20, 0, 14)
capTitle.BackgroundTransparency = 1
capTitle.Text = "Pausar captura de eventos"
capTitle.Font = Enum.Font.GothamMedium
capTitle.TextSize = 11
capTitle.TextColor3 = T.text
capTitle.TextXAlignment = Enum.TextXAlignment.Left

local capSub = Instance.new("TextLabel", capCard)
capSub.Position = UDim2.new(0, 10, 0, 22)
capSub.Size = UDim2.new(1, -130, 0, 12)
capSub.BackgroundTransparency = 1
capSub.Text = "Congela o hook temporariamente"
capSub.Font = Enum.Font.Gotham
capSub.TextSize = 9
capSub.TextColor3 = T.textDim
capSub.TextXAlignment = Enum.TextXAlignment.Left

local capBtn = Instance.new("TextButton", capCard)
capBtn.Size = UDim2.new(0, 110, 0, 28)
capBtn.Position = UDim2.new(1, -120, 0.5, -14)
capBtn.BackgroundColor3 = T.surfaceHi
capBtn.Text = "CAPTURANDO"
capBtn.TextColor3 = T.text
capBtn.Font = Enum.Font.GothamBold
capBtn.TextSize = 11
capBtn.AutoButtonColor = false
corner(capBtn, UDim.new(0, 5))
stroke(capBtn, T.stroke, 1, 0.4)
capBtn.BackgroundColor3 = T.accent

-- Clear All
sectionHeader("AÇÕES RÁPIDAS", "", 7)
local actCard = makeCard(8, 50)
local actLay = Instance.new("UIListLayout", actCard)
actLay.FillDirection = Enum.FillDirection.Horizontal
actLay.Padding = UDim.new(0, 6)
pad(actCard, 10, 10, 10, 10)

local function actionBtn(text, cb)
    local b = Instance.new("TextButton", actCard)
    b.Size = UDim2.new(0, 130, 1, 0)
    b.BackgroundColor3 = T.surfaceHi
    b.Text = text
    b.TextColor3 = T.text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.AutoButtonColor = false
    corner(b, UDim.new(0, 5))
    stroke(b, T.stroke, 1, 0.4)
    b.MouseEnter:Connect(function() tw(b, 0.15, { BackgroundColor3 = T.accentHi }) end)
    b.MouseLeave:Connect(function() tw(b, 0.15, { BackgroundColor3 = T.surfaceHi }) end)
    b.MouseButton1Click:Connect(cb)
    return b
end

-- ═══════════════════════════════════════════════════════════════════
--  ▸ ABA: SETTINGS
-- ═══════════════════════════════════════════════════════════════════
createTabBtn("Settings", "rbxassetid://10734950309", 3)
local SettingsPage = createPage("Settings")
local setLay = Instance.new("UIListLayout", SettingsPage)
setLay.SortOrder = Enum.SortOrder.LayoutOrder
setLay.Padding = UDim.new(0, 8)

local function settingsHeader(text, order)
    local h = Instance.new("Frame", SettingsPage)
    h.Size = UDim2.new(1, 0, 0, 22)
    h.BackgroundTransparency = 1
    h.LayoutOrder = order
    local l = Instance.new("TextLabel", h)
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = T.accentHi
    l.Font = Enum.Font.GothamBold
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
end

local function settingsCard(order, h)
    local c = Instance.new("Frame", SettingsPage)
    c.Size = UDim2.new(1, 0, 0, h or 48)
    c.BackgroundColor3 = T.surface
    c.BackgroundTransparency = 0.05
    c.BorderSizePixel = 0
    c.LayoutOrder = order
    corner(c, UDim.new(0, 6))
    stroke(c, T.stroke, 1, 0.6)
    return c
end

-- Temas
settingsHeader("TEMA DA INTERFACE", 1)
local themeCard = settingsCard(2, 80)
local themeGrid = Instance.new("Frame", themeCard)
themeGrid.Size = UDim2.new(1, -20, 1, -10)
themeGrid.Position = UDim2.new(0, 10, 0, 5)
themeGrid.BackgroundTransparency = 1
local themeGridLay = Instance.new("UIGridLayout", themeGrid)
themeGridLay.CellSize = UDim2.new(0, 62, 0, 30)
themeGridLay.CellPadding = UDim2.new(0, 5, 0, 5)
themeGridLay.SortOrder = Enum.SortOrder.LayoutOrder

local themeNames = {"Blood", "Cyberpunk", "Ocean", "Emerald", "Midnight", "Toxic"}
for _, tn in ipairs(themeNames) do
    local th = Themes[tn]
    local card = Instance.new("TextButton", themeGrid)
    card.BackgroundColor3 = th.accent
    card.Text = ""
    card.AutoButtonColor = false
    corner(card, UDim.new(0, 5))

    local cg = Instance.new("UIGradient", card)
    cg.Color = ColorSequence.new(th.accent, th.accentSoft)
    cg.Rotation = 135

    local ov = Instance.new("Frame", card)
    ov.Size = UDim2.new(1, 0, 1, 0)
    ov.BackgroundColor3 = Color3.new(0, 0, 0)
    ov.BackgroundTransparency = 0.55
    ov.BorderSizePixel = 0
    corner(ov, UDim.new(0, 5))

    local n = Instance.new("TextLabel", card)
    n.Size = UDim2.new(1, -4, 1, 0)
    n.Position = UDim2.new(0, 2, 0, 0)
    n.BackgroundTransparency = 1
    n.Text = tn
    n.TextColor3 = Color3.new(1, 1, 1)
    n.Font = Enum.Font.GothamBold
    n.TextSize = 9
    n.TextWrapped = true
    n.ZIndex = 2

    card.MouseButton1Click:Connect(function() setTheme(tn) end)
end

-- Reaplicar tema
table.insert(State.onTheme, function()
    tw(MainFrame, 0.4, { BackgroundColor3 = T.bg })
    tw(mainGrad, 0.4, { Color = T.gradient })
    tw(mainStroke, 0.4, { Color = T.stroke })
    tw(sep, 0.4, { BackgroundColor3 = T.stroke })
    tw(titleMax, 0.4, { TextColor3 = T.accentHi })
    tw(maxGlow, 0.4, { Color = T.accentHi })
    tw(logoBadge, 0.4, { BackgroundColor3 = T.accent })
    tw(sidebar, 0.4, { BackgroundColor3 = T.surface })
    tw(listPanel, 0.4, { BackgroundColor3 = T.surface })
    tw(listHeader, 0.4, { BackgroundColor3 = T.surfaceHi })
    tw(codePanel, 0.4, { BackgroundColor3 = T.surface })
    tw(codeHeader, 0.4, { BackgroundColor3 = T.surfaceHi })
    tw(EventsList, 0.4, { ScrollBarImageColor3 = T.accent })
end)

-- Max Events slider
settingsHeader("QUANTIDADE MÁXIMA DE EVENTOS", 3)
local maxCard = settingsCard(4, 60)
local maxLbl = Instance.new("TextLabel", maxCard)
maxLbl.Position = UDim2.new(0, 10, 0, 6)
maxLbl.Size = UDim2.new(1, -100, 0, 14)
maxLbl.BackgroundTransparency = 1
maxLbl.Text = "Limite de eventos na lista"
maxLbl.Font = Enum.Font.GothamMedium
maxLbl.TextSize = 11
maxLbl.TextColor3 = T.text
maxLbl.TextXAlignment = Enum.TextXAlignment.Left

local maxVal = Instance.new("TextLabel", maxCard)
maxVal.Position = UDim2.new(1, -70, 0, 6)
maxVal.Size = UDim2.new(0, 60, 0, 14)
maxVal.BackgroundTransparency = 1
maxVal.Text = "999"
maxVal.Font = Enum.Font.GothamBold
maxVal.TextSize = 11
maxVal.TextColor3 = T.accentHi
maxVal.TextXAlignment = Enum.TextXAlignment.Right

local maxBar = Instance.new("Frame", maxCard)
maxBar.Size = UDim2.new(1, -20, 0, 6)
maxBar.Position = UDim2.new(0, 10, 0, 34)
maxBar.BackgroundColor3 = T.stroke
maxBar.BorderSizePixel = 0
corner(maxBar, UDim.new(1, 0))

local maxFill = Instance.new("Frame", maxBar)
maxFill.Size = UDim2.new(0.5, 0, 1, 0)
maxFill.BackgroundColor3 = T.accent
maxFill.BorderSizePixel = 0
corner(maxFill, UDim.new(1, 0))

local maxDrag = false
maxBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        maxDrag = true
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if maxDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local c = math.clamp((i.Position.X - maxBar.AbsolutePosition.X) / maxBar.AbsoluteSize.X, 0, 1)
        maxFill.Size = UDim2.new(c, 0, 1, 0)
        State.maxEvents = math.floor(50 + c * 1950)
        maxVal.Text = tostring(State.maxEvents)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        maxDrag = false
    end
end)

-- Stats
settingsHeader("ESTATÍSTICAS", 5)
local statsCard = settingsCard(6, 90)
local statsLay = Instance.new("UIListLayout", statsCard)
statsLay.Padding = UDim.new(0, 4)
pad(statsCard, 10, 10, 10, 10)

local function statRow(label, value)
    local row = Instance.new("Frame", statsCard)
    row.Size = UDim2.new(1, 0, 0, 18)
    row.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", row)
    l.Size = UDim2.new(0.6, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.Font = Enum.Font.Gotham
    l.TextSize = 10
    l.TextColor3 = T.textDim
    l.TextXAlignment = Enum.TextXAlignment.Left
    local v = Instance.new("TextLabel", row)
    v.Size = UDim2.new(0.4, 0, 1, 0)
    v.Position = UDim2.new(0.6, 0, 0, 0)
    v.BackgroundTransparency = 1
    v.Text = tostring(value)
    v.Font = Enum.Font.GothamBold
    v.TextSize = 10
    v.TextColor3 = T.accentHi
    v.TextXAlignment = Enum.TextXAlignment.Right
    return v
end
local totalStat = statRow("Total capturado", 0)
local uniqueStat = statRow("Eventos únicos", 0)
local blockedStat = statRow("Bloqueados", 0)

-- ═══════════════════════════════════════════════════════════════════
--  ▸ ABA: INFO
-- ═══════════════════════════════════════════════════════════════════
createTabBtn("Info", "rbxassetid://10723415903", 4)
local InfoPage = createPage("Info")

local infoCard = Instance.new("Frame", InfoPage)
infoCard.Size = UDim2.new(1, 0, 0, 140)
infoCard.BackgroundColor3 = T.surface
infoCard.BackgroundTransparency = 0.05
infoCard.BorderSizePixel = 0
corner(infoCard, UDim.new(0, 8))
stroke(infoCard, T.accentSoft, 1.2, 0.4)

local infoTitle = Instance.new("TextLabel", infoCard)
infoTitle.Position = UDim2.new(0, 12, 0, 10)
infoTitle.Size = UDim2.new(1, -24, 0, 20)
infoTitle.BackgroundTransparency = 1
infoTitle.Text = "RANOXHUB SPY · PROFESSIONAL"
infoTitle.TextColor3 = T.accentHi
infoTitle.Font = Enum.Font.GothamBold
infoTitle.TextSize = 14
infoTitle.TextXAlignment = Enum.TextXAlignment.Left

local infoText = Instance.new("TextLabel", infoCard)
infoText.Position = UDim2.new(0, 12, 0, 36)
infoText.Size = UDim2.new(1, -24, 0, 90)
infoText.BackgroundTransparency = 1
infoText.Text = "Uma ferramenta de análise de RemoteEvents/RemoteFunctions para Roblox.\n\n• Hook seguro em __namecall\n• Syntax highlighting profissional\n• Filtros, busca e favoritos\n• Presets de spam (1-100)\n• Multi-tema · 6 paletas\n• Design responsivo mobile\n\nDesenvolvido por RANOX team."
infoText.TextColor3 = T.text
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 10
infoText.TextWrapped = true
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top

-- ═══════════════════════════════════════════════════════════════════
--  CAPTURA E PROCESSAMENTO DE EVENTOS
-- ═══════════════════════════════════════════════════════════════════
local function buildScript(remote, args)
    local method = remote:IsA("RemoteEvent") and "FireServer" or "InvokeServer"
    local parts = {}
    for _, a in ipairs(args) do table.insert(parts, formatType(a)) end
    return ("game.%s:%s(%s)"):format(remote:GetFullName(), method, table.concat(parts, ", "))
end

local function eventMatchesFilter(entry, mode)
    if mode == "Todos" then return true end
    if mode == "Event" then return entry.remote:IsA("RemoteEvent") end
    if mode == "Func" then return entry.remote:IsA("RemoteFunction") end
    if mode == "Favoritos" then return State.favoriteEvents[entry.code] == true end
    return true
end

function applyFilter(entry)
    local matchFilter = eventMatchesFilter(entry, State.filterMode)
    local matchSearch = State.searchQuery == "" or string.find(string.lower(entry.remote.Name), State.searchQuery, 1, true)
    entry.frame.Visible = matchFilter and matchSearch
end

local function addOrUpdateEvent(remote, args)
    if State.paused then return end
    local code = buildScript(remote, args)

    if State.autoBlockEnabled and State.eventEntries[code] then return end

    if State.eventEntries[code] then
        local entry = State.eventEntries[code]
        entry.count += 1
        entry.countLabel.Text = "x" .. entry.count
        for i, c in ipairs(State.eventOrder) do
            if c == code then table.remove(State.eventOrder, i); break end
        end
        table.insert(State.eventOrder, code)
        entry.frame.LayoutOrder = -#State.eventOrder
        return
    end

    local index = #State.eventOrder + 1
    local isRemote = remote:IsA("RemoteEvent")

    local frame = Instance.new("Frame", EventsList)
    frame.Size = UDim2.new(1, -4, 0, 44)
    frame.BackgroundColor3 = index % 2 == 0 and T.surface or T.surfaceHi
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.LayoutOrder = -index
    corner(frame, UDim.new(0, 5))

    local fStroke = stroke(frame, T.stroke, 1, 0.6)

    local icon = Instance.new("ImageLabel", frame)
    icon.Size = UDim2.new(0, 16, 0, 16)
    icon.Position = UDim2.new(0, 6, 0, 6)
    icon.BackgroundTransparency = 1
    icon.Image = isRemote and "rbxassetid://10723426722" or "rbxassetid://10709791437"
    icon.ImageColor3 = isRemote and T.accentHi or Color3.fromRGB(255, 200, 80)

    local nameLbl = Instance.new("TextLabel", frame)
    nameLbl.Size = UDim2.new(1, -60, 0, 14)
    nameLbl.Position = UDim2.new(0, 28, 0, 6)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = remote.Name
    nameLbl.TextColor3 = T.text
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 11
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd

    local infoLbl = Instance.new("TextLabel", frame)
    infoLbl.Size = UDim2.new(1, -60, 0, 12)
    infoLbl.Position = UDim2.new(0, 28, 0, 22)
    infoLbl.BackgroundTransparency = 1
    infoLbl.Text = (isRemote and "Event" or "Function") .. " · " .. #args .. " arg(s)"
    infoLbl.TextColor3 = T.textDim
    infoLbl.Font = Enum.Font.Gotham
    infoLbl.TextSize = 9
    infoLbl.TextXAlignment = Enum.TextXAlignment.Left

    local countLbl = Instance.new("TextLabel", frame)
    countLbl.Size = UDim2.new(0, 40, 0, 14)
    countLbl.Position = UDim2.new(1, -46, 0, 6)
    countLbl.BackgroundTransparency = 1
    countLbl.Text = "x1"
    countLbl.TextColor3 = T.accentHi
    countLbl.Font = Enum.Font.GothamBold
    countLbl.TextSize = 10
    countLbl.TextXAlignment = Enum.TextXAlignment.Right

    -- Favorito (estrela)
    local favBtn = Instance.new("TextButton", frame)
    favBtn.Size = UDim2.new(0, 20, 0, 20)
    favBtn.Position = UDim2.new(1, -28, 0, 22)
    favBtn.BackgroundTransparency = 1
    favBtn.Text = "☆"
    favBtn.TextColor3 = T.textDim
    favBtn.TextSize = 14
    favBtn.Font = Enum.Font.GothamBold
    favBtn.ZIndex = 2

    local entry = {
        frame = frame, remote = remote, args = args, count = 1, code = code,
        countLabel = countLbl, nameLabel = nameLbl, infoLabel = infoLbl, favBtn = favBtn,
    }

    favBtn.MouseButton1Click:Connect(function()
        if State.favoriteEvents[code] then
            State.favoriteEvents[code] = nil
            favBtn.Text = "☆"; favBtn.TextColor3 = T.textDim
        else
            State.favoriteEvents[code] = true
            favBtn.Text = "★"; favBtn.TextColor3 = Color3.fromRGB(255, 210, 50)
        end
        applyFilter(entry)
    end)

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            State.selectedRemote = remote
            State.selectedArgs = args
            State.selectedCode = code
            highlighter:setRaw(code)
            tw(frame, 0.1, { BackgroundColor3 = T.accentSoft })
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            tw(frame, 0.25, { BackgroundColor3 = index % 2 == 0 and T.surface or T.surfaceHi })
        end
    end)

    State.eventEntries[code] = entry
    table.insert(State.eventOrder, code)
    applyFilter(entry)

    State.totalCaptured += 1
    totalStat.Text = tostring(State.totalCaptured)
    uniqueStat.Text = tostring(#State.eventOrder)
    statsLbl.Text = #State.eventOrder .. " ev."

    if #State.eventOrder > State.maxEvents then
        local oldCode = State.eventOrder[1]
        local old = State.eventEntries[oldCode]
        if old and old.frame then old.frame:Destroy() end
        State.eventEntries[oldCode] = nil
        table.remove(State.eventOrder, 1)
    end
end

-- ═══════════════════════════════════════════════════════════════════
--  SPAM / EXECUTE
-- ═══════════════════════════════════════════════════════════════════
local function executeOnce()
    if not State.selectedRemote or not State.selectedArgs then return end
    State.internalCallFlag = true
    pcall(function()
        if State.selectedRemote:IsA("RemoteEvent") then
            State.selectedRemote:FireServer(table.unpack(State.selectedArgs))
        elseif State.selectedRemote:IsA("RemoteFunction") then
            State.selectedRemote:InvokeServer(table.unpack(State.selectedArgs))
        end
    end)
    State.internalCallFlag = false
end

local function spamHeartbeat()
    if not State.isSpamming or not State.selectedRemote then
        if State.spamConnection then State.spamConnection:Disconnect(); State.spamConnection = nil end
        return
    end
    State.internalCallFlag = true
    for _ = 1, State.spamCount do
        if State.selectedRemote:IsA("RemoteEvent") then
            pcall(function() State.selectedRemote:FireServer(table.unpack(State.selectedArgs)) end)
        elseif State.selectedRemote:IsA("RemoteFunction") then
            pcall(function() State.selectedRemote:InvokeServer(table.unpack(State.selectedArgs)) end)
        end
    end
    State.internalCallFlag = false
end

local function toggleSpam()
    if not State.selectedRemote then
        spamStatus.Text = "❌ Sem evento"
        spamStatus.TextColor3 = Color3.fromRGB(255, 90, 90)
        return
    end
    State.isSpamming = not State.isSpamming

    if State.isSpamming then
        local n = tonumber(countBox.Text) or 1
        if n > 100 then n = 100 end
        if n < 1 then n = 1 end
        State.spamCount = math.floor(n)
        countBox.Text = tostring(State.spamCount)

        spamBtn.Text = "ON"
        tw(spamBtn, 0.2, { BackgroundColor3 = T.accent })
        spamStatus.Text = "⚡ Spam x" .. State.spamCount
        spamStatus.TextColor3 = T.accentHi

        if State.spamConnection then State.spamConnection:Disconnect() end
        State.spamConnection = RunService.Heartbeat:Connect(spamHeartbeat)
    else
        spamBtn.Text = "OFF"
        tw(spamBtn, 0.2, { BackgroundColor3 = T.surfaceHi })
        spamStatus.Text = "🛑 Parado"
        spamStatus.TextColor3 = T.textDim
        if State.spamConnection then State.spamConnection:Disconnect(); State.spamConnection = nil end
    end
end
spamBtn.MouseButton1Click:Connect(toggleSpam)

countBox.FocusLost:Connect(function()
    local n = tonumber(countBox.Text) or 1
    if n > 100 then n = 100 end
    if n < 1 then n = 1 end
    countBox.Text = tostring(math.floor(n))
    State.spamCount = math.floor(n)
end)

abBtn.MouseButton1Click:Connect(function()
    State.autoBlockEnabled = not State.autoBlockEnabled
    abBtn.Text = State.autoBlockEnabled and "ON" or "OFF"
    tw(abBtn, 0.2, { BackgroundColor3 = State.autoBlockEnabled and T.accent or T.surfaceHi })
end)

capBtn.MouseButton1Click:Connect(function()
    State.paused = not State.paused
    if State.paused then
        capBtn.Text = "PAUSADO"
        capBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 40)
    else
        capBtn.Text = "CAPTURANDO"
        capBtn.BackgroundColor3 = T.accent
    end
end)

-- ═══════════════════════════════════════════════════════════════════
--  BOTÕES BAR
-- ═══════════════════════════════════════════════════════════════════
createBarBtn("📋 Copiar", T.surfaceHi, function()
    if State.selectedCode then
        pcall(function() setclipboard(State.selectedCode) end)
        spamStatus.Text = "✅ Copiado!"
        spamStatus.TextColor3 = T.accentHi
        task.delay(1.5, function()
            spamStatus.Text = State.isSpamming and ("⚡ Spam x" .. State.spamCount) or "🛑 Parado"
            spamStatus.TextColor3 = State.isSpamming and T.accentHi or T.textDim
        end)
    end
end, 0.2)

createBarBtn("▶ Exec", T.surfaceHi, executeOnce, 0.2)

createBarBtn("💾 Salvar", T.surfaceHi, function()
    if State.selectedCode then
        pcall(function()
            if writefile then
                writefile("ranox_spy_" .. tick() .. ".lua", State.selectedCode)
            end
        end)
    end
end, 0.2)

createBarBtn("🔓 Decompilar", T.surfaceHi, function()
    if not State.selectedRemote then return end
    local scriptObj = State.selectedRemote:FindFirstAncestorOfClass("LuaSourceContainer")
    if scriptObj and decompile then
        local bc = getscriptbytecode(scriptObj)
        if bc then
            local ok, res = pcall(decompile, bc)
            highlighter:setRaw(ok and res or "-- Erro: " .. tostring(res))
        else
            highlighter:setRaw("-- Sem bytecode disponível")
        end
    else
        highlighter:setRaw("-- Script não encontrado ou decompiler indisponível")
    end
end, 0.2)

createBarBtn("🧹 Limpar", T.surfaceHi, function()
    for _, entry in pairs(State.eventEntries) do
        if entry.frame then entry.frame:Destroy() end
    end
    State.eventEntries = {}; State.eventOrder = {}
    State.totalCaptured = 0; State.selectedCode = nil
    highlighter:setRaw("-- Selecione um evento")
    totalStat.Text = "0"; uniqueStat.Text = "0"
    statsLbl.Text = "0 ev."
end, 0.2)

-- ═══════════════════════════════════════════════════════════════════
--  AÇÕES RÁPIDAS
-- ═══════════════════════════════════════════════════════════════════
actionBtn("Limpar Eventos", function()
    for _, entry in pairs(State.eventEntries) do
        if entry.frame then entry.frame:Destroy() end
    end
    State.eventEntries = {}; State.eventOrder = {}
    State.totalCaptured = 0; State.selectedCode = nil
    highlighter:setRaw("-- Selecione um evento")
    totalStat.Text = "0"; uniqueStat.Text = "0"; statsLbl.Text = "0 ev."
end)

actionBtn("Desfavoritar Todos", function()
    State.favoriteEvents = {}
    for _, entry in pairs(State.eventEntries) do
        if entry.favBtn then
            entry.favBtn.Text = "☆"
            entry.favBtn.TextColor3 = T.textDim
        end
    end
end)

actionBtn("Reset Hook", function()
    State.eventEntries = {}; State.eventOrder = {}
    for _, entry in pairs(State.eventEntries) do
        if entry.frame then entry.frame:Destroy() end
    end
    highlighter:setRaw("-- Resetado. Capturando novos eventos...")
end)

-- ═══════════════════════════════════════════════════════════════════
--  MINIMIZAR / FECHAR / BALL BUTTON
-- ═══════════════════════════════════════════════════════════════════
local originalSize = MainFrame.Size
local ballBtn = Instance.new("ImageButton", ScreenGui)
ballBtn.Size = UDim2.new(0, 55, 0, 55)
ballBtn.Position = UDim2.new(0, 20, 0.9, -80)
ballBtn.AnchorPoint = Vector2.new(0, 1)
ballBtn.BackgroundColor3 = T.accent
ballBtn.BorderSizePixel = 0
ballBtn.Visible = false
corner(ballBtn, UDim.new(1, 0))
local ballStroke = stroke(ballBtn, T.accentHi, 2, 0.2)

local ballIcon = Instance.new("ImageLabel", ballBtn)
ballIcon.Size = UDim2.new(0.6, 0, 0.6, 0)
ballIcon.Position = UDim2.new(0.2, 0, 0.2, 0)
ballIcon.BackgroundTransparency = 1
ballIcon.Image = "rbxassetid://10723415903"
ballIcon.ImageColor3 = Color3.new(1, 1, 1)

task.spawn(function()
    while ballBtn.Parent do
        tw(ballStroke, 1.2, { Transparency = 0.8 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(1.2)
        tw(ballStroke, 1.2, { Transparency = 0.2 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(1.2)
    end
end)

local function doHide()
    if State.isMinimized then return end
    State.isMinimized = true
    tw(MainFrame, 0.25, { Size = UDim2.new(0, 220, 0, 36) }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    task.delay(0.2, function()
        for _, v in pairs(MainFrame:GetChildren()) do
            if v ~= topBar and v:IsA("GuiObject") then v.Visible = false end
        end
    end)
end

local function doShow()
    if not State.isMinimized then return end
    State.isMinimized = false
    for _, v in pairs(MainFrame:GetChildren()) do
        if v:IsA("GuiObject") then v.Visible = true end
    end
    tw(MainFrame, 0.3, { Size = originalSize }, Enum.EasingStyle.Back)
end

btnMin.MouseButton1Click:Connect(function()
    if State.isMinimized then doShow() else doHide() end
end)

btnClose.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ballBtn.Visible = true
end)

-- Arrastar ball
local ballDrag, ballStart, ballPos = false, nil, nil
ballBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        ballDrag = true; ballStart = i.Position; ballPos = ballBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if ballDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - ballStart
        local nx = math.clamp(ballPos.X.Offset + d.X, 0, ScreenGui.AbsoluteSize.X - 55)
        local ny = math.clamp(ballPos.Y.Offset + d.Y, 0, ScreenGui.AbsoluteSize.Y - 55)
        ballBtn.Position = UDim2.new(0, nx, 0, ny)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        ballDrag = false
    end
end)

ballBtn.MouseButton1Click:Connect(function()
    if not ballDrag then
        ballBtn.Visible = false
        MainFrame.Visible = true
    end
end)

-- ═══════════════════════════════════════════════════════════════════
--  HOOK (seguro)
-- ═══════════════════════════════════════════════════════════════════
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = { ... }
    local results = { oldNamecall(self, ...) }
    if not State.internalCallFlag and not State.paused then
        task.spawn(function()
            pcall(function()
                if (method == "FireServer" or method == "InvokeServer")
                    and typeof(self) == "Instance"
                    and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
                    table.insert(buffer, { remote = self, args = args })
                end
            end)
        end)
    end
    return table.unpack(results)
end)

task.spawn(function()
    while true do
        if #buffer > 0 then
            local data = table.remove(buffer, 1)
            addOrUpdateEvent(data.remote, data.args)
        end
        task.wait(0.05)
    end
end)

-- ═══════════════════════════════════════════════════════════════════
--  BUSCA
-- ═══════════════════════════════════════════════════════════════════
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    State.searchQuery = string.lower(searchBox.Text)
    for _, entry in pairs(State.eventEntries) do applyFilter(entry) end
end)

-- ═══════════════════════════════════════════════════════════════════
--  ENTRY ANIMATION
-- ═══════════════════════════════════════════════════════════════════
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.BackgroundTransparency = 1
task.wait(0.05)
MainFrame.Size = UDim2.new(0, MAIN_W - 30, 0, MAIN_H - 20)
tw(MainFrame, 0.5, { Size = UDim2.new(0, MAIN_W, 0, MAIN_H) }, Enum.EasingStyle.Back)
tw(MainFrame, 0.35, { BackgroundTransparency = 0.03 })

-- ═══════════════════════════════════════════════════════════════════
--  ABRIR ABA INICIAL
-- ═══════════════════════════════════════════════════════════════════
switchTab("Events")
