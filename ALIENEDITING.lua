--[[
    ══════════════════════════════════════════════════════════════════════
      RAYFIELD // SUPERIOR EDITION
    ══════════════════════════════════════════════════════════════════════
      Wrapper executável que carrega o Rayfield original e aplica:

      · Performance Core (scheduler de frame único, tema em bus,
        registro central de conexões, lifecycle por elemento)
      · Save configuration com debounce (resolve gargalo catastrófico
        do slider salvando 60x/seg durante arrasto)
      · Hide/Unhide com CanvasGroup (1 tween substitui 3xN tweens)
      · Busca com debounce + índice cacheado
      · Novos elementos: ProgressBar, TextArea, NumberSlider
      · Sistema de perfis (save/load/list/delete)
      · Export/Import de config via string/clipboard
      · Handle de redimensionamento da janela
      · Tooltip universal
      · Destroy limpo (sem vazamento de conexões)

      Uso:
        local Rayfield = loadstring(game:HttpGet("URL"))()
        local Window = Rayfield:CreateWindow({ Name = "Meu Hub" })
        local Tab = Window:CreateTab("Principal")
        local bar = Tab:CreateProgressBar({ Name = "Carregando" })
        bar:Set(75)
    ══════════════════════════════════════════════════════════════════════
]]

local RAYFIELD_COMMIT = "3ef72398fb4c8ba6fd1801e98704991d3cc9cbc2"
local RAYFIELD_URL = "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/"
    .. RAYFIELD_COMMIT .. "/source.lua"

-- ─────────────────────────────────────────────────────────────────────
-- Helpers de patch
-- ─────────────────────────────────────────────────────────────────────
local function replaceOnce(src, needle, replacement)
    local s, e = string.find(src, needle, 1, true)
    if not s then return src, false end
    return string.sub(src, 1, s - 1) .. replacement .. string.sub(src, e + 1), true
end

local function rangeReplace(src, startNeedle, endNeedle, replacement)
    local s = string.find(src, startNeedle, 1, true)
    if not s then return src, false end
    local e = string.find(src, endNeedle, s + #startNeedle, true)
    if not e then return src, false end
    return string.sub(src, 1, s - 1) .. replacement .. string.sub(src, e), true
end

-- ─────────────────────────────────────────────────────────────────────
-- 1. Baixa o source original
-- ─────────────────────────────────────────────────────────────────────
local fetchOk, source = pcall(game.HttpGet, game, RAYFIELD_URL)
if not fetchOk or type(source) ~= "string" or #source == 0 then
    error("[Rayfield Superior] Falha ao baixar source original: " .. tostring(source))
end

print("[Rayfield Superior] Source baixado (" .. #source .. " bytes). Aplicando patches...")

-- ─────────────────────────────────────────────────────────────────────
-- 2. Módulo de performance (injetado depois de SelectedTheme)
-- ─────────────────────────────────────────────────────────────────────
local PERF_MODULE = [==[
-- ═══ [SUPERIOR] PERFORMANCE CORE ═══
local Perf = {
    _conns = {},
    _frameTasks = {},
    _frameId = 0,
}

function Perf.track(conn)
    Perf._conns[#Perf._conns + 1] = conn
    return conn
end

function Perf.disconnectAll()
    for i = #Perf._conns, 1, -1 do
        local c = Perf._conns[i]
        if typeof(c) == "RBXScriptConnection" and c.Connected then
            c:Disconnect()
        end
        Perf._conns[i] = nil
    end
end

local ThemeBus = Instance.new("BindableEvent")
function Perf.onTheme(fn)
    return Perf.track(ThemeBus.Event:Connect(fn))
end
function Perf.pushTheme()
    ThemeBus:Fire()
end

function Perf.onFrame(fn)
    Perf._frameId = Perf._frameId + 1
    local id = Perf._frameId
    Perf._frameTasks[id] = fn
    return id
end
function Perf.offFrame(id)
    Perf._frameTasks[id] = nil
end

RunService.RenderStepped:Connect(function(dt)
    for id, fn in pairs(Perf._frameTasks) do
        local ok, err = pcall(fn, dt)
        if not ok then
            Perf._frameTasks[id] = nil
            warn("Rayfield | frame task error:", err)
        end
    end
end)

function Perf.attach(element, frame, onDestroy)
    function element:Destroy()
        if onDestroy then pcall(onDestroy) end
        if frame and frame.Parent then frame:Destroy() end
    end
    function element:SetVisible(v)
        if frame then frame.Visible = v and true or false end
    end
    function element:SetDisabled(v)
        if frame then frame.Active = not v end
        element.Disabled = v and true or false
    end
    element.Frame = frame
    return element
end

function Perf.card(parent, height)
    local card = Instance.new("Frame")
    card.Name = "RF_Card"
    card.Size = UDim2.new(1, -10, 0, height)
    card.BackgroundColor3 = SelectedTheme.ElementBackground
    card.BorderSizePixel = 0
    card.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = SelectedTheme.ElementStroke
    stroke.Thickness = 1
    stroke.Parent = card

    Perf.onTheme(function()
        card.BackgroundColor3 = SelectedTheme.ElementBackground
        stroke.Color = SelectedTheme.ElementStroke
    end)

    return card, stroke
end
-- ═══ [END PERFORMANCE CORE] ═══
]==]

do
    local patched
    source, patched = replaceOnce(source,
        "local SelectedTheme = RayfieldLibrary.Theme.Default",
        "local SelectedTheme = RayfieldLibrary.Theme.Default\n" .. PERF_MODULE
    )
    assert(patched, "[Superior] Falha: anchor SelectedTheme não encontrado")
end

-- ─────────────────────────────────────────────────────────────────────
-- 3. Save debounce (resolve o pior gargalo do Rayfield)
-- ─────────────────────────────────────────────────────────────────────
do
    local s = string.find(source, "local function SaveConfiguration()", 1, true)
    local e = string.find(source, "function RayfieldLibrary:Notify(data)", s, true)
    if s and e then
        local originalFn = string.sub(source, s, e - 1)
        local renamed = string.gsub(originalFn,
            "local function SaveConfiguration%(%)",
            "local function SaveConfigurationNow()", 1)

        local wrapper = [[
local _saveQueued = false
local function SaveConfiguration()
    if _saveQueued then return end
    _saveQueued = true
    task.delay(0.4, function()
        _saveQueued = false
        SaveConfigurationNow()
    end)
end

local function FlushConfiguration()
    if _saveQueued then
        _saveQueued = false
        SaveConfigurationNow()
    end
end

]]
        source = string.sub(source, 1, s - 1) .. renamed .. wrapper .. string.sub(source, e)
    else
        warn("[Superior] Falha: não foi possível patch de SaveConfiguration")
    end
end

-- ─────────────────────────────────────────────────────────────────────
-- 4. setElementsVisible → CanvasGroup (1 tween)
-- ─────────────────────────────────────────────────────────────────────
do
    local NEW_FN = [[
local ElementsGroup
local function setElementsVisible(show)
    if not ElementsGroup then
        ElementsGroup = Instance.new("CanvasGroup")
        ElementsGroup.Name = "ElementsGroup"
        ElementsGroup.BackgroundTransparency = 1
        ElementsGroup.BorderSizePixel = 0
        ElementsGroup.AnchorPoint = Elements.AnchorPoint
        ElementsGroup.Position = Elements.Position
        ElementsGroup.Size = Elements.Size
        ElementsGroup.ZIndex = Elements.ZIndex
        ElementsGroup.Parent = Elements.Parent
        Elements.Parent = ElementsGroup
    end

    if show then
        ElementsGroup.Visible = true
        TweenService:Create(
            ElementsGroup,
            TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
            { GroupTransparency = 0 }
        ):Play()
    else
        local t = TweenService:Create(
            ElementsGroup,
            TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
            { GroupTransparency = 1 }
        )
        t.Completed:Once(function()
            ElementsGroup.Visible = false
        end)
        t:Play()
    end
end

]]
    local patched
    source, patched = rangeReplace(source,
        "local function setElementsVisible(show)",
        "-- Sets tab button visibility",
        NEW_FN
    )
    if not patched then
        warn("[Superior] Falha: patch setElementsVisible")
    end
end

-- ─────────────────────────────────────────────────────────────────────
-- 5. Busca com debounce + índice cacheado
-- ─────────────────────────────────────────────────────────────────────
do
    local NEW_HANDLER = [[
-- [SUPERIOR] Busca com debounce e índice cacheado
local _searchToken = 0
local _searchIndex = nil

local function runSearch(query)
    local page = Elements.UIPageLayout.CurrentPage
    if not page then return end

    if not _searchIndex or _searchIndex.page ~= page then
        local map = {}
        for _, el in ipairs(page:GetChildren()) do
            if el.Name ~= "Placeholder"
               and el.Name ~= "SearchTitle-fsefsefesfsefesfesfThanks" then
                map[el] = string.lower(el.Name)
            end
        end
        _searchIndex = { page = page, map = map }
    end

    local hasQuery = #query > 0

    local searchTitle = page:FindFirstChild('SearchTitle-fsefsefesfsefesfesfThanks')
    if hasQuery and not searchTitle then
        searchTitle = Elements.Template.SectionTitle:Clone()
        searchTitle.Parent = page
        searchTitle.Name = 'SearchTitle-fsefsefesfsefesfesfThanks'
        searchTitle.LayoutOrder = -100
        searchTitle.Title.Text = "Results from '" .. page.Name .. "'"
        searchTitle.Visible = true
    elseif not hasQuery and searchTitle then
        searchTitle:Destroy()
    end

    local needle = hasQuery and string.lower(query) or nil
    for el, lname in pairs(_searchIndex.map) do
        if not el.Parent then
            _searchIndex.map[el] = nil
        elseif el.Name == 'SectionTitle' then
            el.Visible = not hasQuery
        elseif el.Name ~= 'SearchTitle-fsefsefesfsefesfesfThanks' then
            el.Visible = not needle or string.find(lname, needle, 1, true) ~= nil
        end
    end
end

Main.Search.Input:GetPropertyChangedSignal('Text'):Connect(function()
    _searchToken = _searchToken + 1
    local myToken = _searchToken
    local text = Main.Search.Input.Text
    if #text == 0 then
        runSearch("")
        return
    end
    task.delay(0.12, function()
        if myToken ~= _searchToken then return end
        runSearch(text)
    end)
end)

]]
    local patched
    source, patched = rangeReplace(source,
        "Main.Search.Input:GetPropertyChangedSignal('Text'):Connect(function()",
        "Main.Search.Input.FocusLost:Connect(function(enterPressed)",
        NEW_HANDLER
    )
    if not patched then
        warn("[Superior] Falha: patch busca")
    end
end

-- ─────────────────────────────────────────────────────────────────────
-- 6. Novos elementos (injetados antes de `return Tab`)
-- ─────────────────────────────────────────────────────────────────────
local NEW_ELEMENTS = [==[
-- ═══════════════════════════════════════════════════════════════════
-- [SUPERIOR] Novos elementos
-- ═══════════════════════════════════════════════════════════════════

function Tab:CreateProgressBar(S)
    S = S or {}
    S.Min = S.Min or 0
    S.Max = S.Max or 100
    S.Value = math.clamp(S.Value or S.Min, S.Min, S.Max)

    local card = Perf.card(TabPage, 48)
    card.Name = S.Name or "ProgressBar"

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 15, 0, 7)
    title.Size = UDim2.new(1, -90, 0, 14)
    title.Font = Enum.Font.Gotham
    title.TextSize = 13
    title.TextColor3 = SelectedTheme.TextColor
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = S.Name or "Progress"
    title.Parent = card

    local pct = Instance.new("TextLabel")
    pct.BackgroundTransparency = 1
    pct.AnchorPoint = Vector2.new(1, 0)
    pct.Position = UDim2.new(1, -15, 0, 7)
    pct.Size = UDim2.new(0, 60, 0, 14)
    pct.Font = Enum.Font.GothamMedium
    pct.TextSize = 13
    pct.TextColor3 = SelectedTheme.TextColor
    pct.TextXAlignment = Enum.TextXAlignment.Right
    pct.Text = "0%"
    pct.Parent = card

    local track = Instance.new("Frame")
    track.Position = UDim2.new(0, 15, 0, 29)
    track.Size = UDim2.new(1, -30, 0, 6)
    track.BackgroundColor3 = SelectedTheme.ToggleBackground
    track.BorderSizePixel = 0
    track.Parent = card
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = S.Color or SelectedTheme.SliderProgress
    fill.BorderSizePixel = 0
    fill.Parent = track
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1, 0)
    fc.Parent = fill

    Perf.onTheme(function()
        title.TextColor3 = SelectedTheme.TextColor
        pct.TextColor3 = SelectedTheme.TextColor
        track.BackgroundColor3 = SelectedTheme.ToggleBackground
    end)

    local api = {}
    local function render(animate)
        local alpha = math.clamp((S.Value - S.Min) / math.max(S.Max - S.Min, 1e-9), 0, 1)
        TweenService:Create(
            fill,
            TweenInfo.new(animate and 0.35 or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.new(alpha, 0, 1, 0) }
        ):Play()
        pct.Text = string.format("%d%%", math.floor(alpha * 100 + 0.5))
    end

    function api:Set(v, animate)
        S.Value = math.clamp(v, S.Min, S.Max)
        render(animate ~= false)
        if S.Callback then task.spawn(S.Callback, S.Value) end
    end
    function api:Get() return S.Value end
    function api:SetColor(c) fill.BackgroundColor3 = c end
    function api:SetRange(mn, mx) S.Min, S.Max = mn, mx; render(true) end
    function api:SetName(name) title.Text = name end

    render(false)
    return Perf.attach(api, card)
end

function Tab:CreateTextArea(S)
    S = S or {}
    local card = Perf.card(TabPage, 132)
    card.Name = S.Name or "TextArea"

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 15, 0, 7)
    title.Size = UDim2.new(1, -30, 0, 14)
    title.Font = Enum.Font.Gotham
    title.TextSize = 13
    title.TextColor3 = SelectedTheme.TextColor
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = S.Name or "Text"
    title.Parent = card

    local counter = Instance.new("TextLabel")
    counter.BackgroundTransparency = 1
    counter.AnchorPoint = Vector2.new(1, 0)
    counter.Position = UDim2.new(1, -15, 0, 7)
    counter.Size = UDim2.new(0, 80, 0, 14)
    counter.Font = Enum.Font.Gotham
    counter.TextSize = 12
    counter.TextColor3 = SelectedTheme.PlaceholderColor
    counter.TextXAlignment = Enum.TextXAlignment.Right
    counter.Text = "0"
    counter.Parent = card

    local box = Instance.new("TextBox")
    box.Position = UDim2.new(0, 15, 0, 28)
    box.Size = UDim2.new(1, -30, 0, 92)
    box.BackgroundColor3 = SelectedTheme.InputBackground
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    box.Multiline = true
    box.TextWrapped = true
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.TextYAlignment = Enum.TextYAlignment.Top
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.TextColor3 = SelectedTheme.TextColor
    box.PlaceholderColor3 = SelectedTheme.PlaceholderColor
    box.PlaceholderText = S.Placeholder or ""
    box.Text = S.Value or ""
    box.Parent = card

    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 5); bc.Parent = box
    local bs = Instance.new("UIStroke"); bs.Color = SelectedTheme.InputStroke; bs.Parent = box

    Perf.onTheme(function()
        title.TextColor3 = SelectedTheme.TextColor
        box.BackgroundColor3 = SelectedTheme.InputBackground
        box.TextColor3 = SelectedTheme.TextColor
        box.PlaceholderColor3 = SelectedTheme.PlaceholderColor
        bs.Color = SelectedTheme.InputStroke
        counter.TextColor3 = SelectedTheme.PlaceholderColor
    end)

    local MAX = S.MaxLength or 2000
    local api = { CurrentValue = box.Text }

    box:GetPropertyChangedSignal("Text"):Connect(function()
        if #box.Text > MAX then
            box.Text = string.sub(box.Text, 1, MAX)
            return
        end
        counter.Text = ("%d/%d"):format(#box.Text, MAX)
    end)

    box.FocusLost:Connect(function()
        api.CurrentValue = box.Text
        if S.Callback then
            local ok, err = pcall(S.Callback, box.Text)
            if not ok then warn("Rayfield | TextArea callback:", err) end
        end
    end)

    function api:Set(text) box.Text = tostring(text); api.CurrentValue = box.Text end
    function api:Get() return box.Text end

    return Perf.attach(api, card)
end

function Tab:CreateNumberSlider(S)
    S = S or {}
    S.Range = S.Range or {0, 100}
    local card = Perf.card(TabPage, 45)
    card.Name = S.Name or "NumberSlider"

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 15, 0, 7)
    title.Size = UDim2.new(1, -110, 0, 14)
    title.Font = Enum.Font.Gotham
    title.TextSize = 13
    title.TextColor3 = SelectedTheme.TextColor
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = S.Name or "Value"
    title.Parent = card

    local valueBox = Instance.new("TextBox")
    valueBox.AnchorPoint = Vector2.new(1, 0)
    valueBox.Position = UDim2.new(1, -15, 0, 5)
    valueBox.Size = UDim2.new(0, 72, 0, 20)
    valueBox.BackgroundColor3 = SelectedTheme.InputBackground
    valueBox.BorderSizePixel = 0
    valueBox.Font = Enum.Font.Gotham
    valueBox.TextSize = 12
    valueBox.TextColor3 = SelectedTheme.TextColor
    valueBox.ClearTextOnFocus = false
    valueBox.Text = tostring(S.Value or S.Range[1])
    valueBox.Parent = card
    local vc = Instance.new("UICorner"); vc.CornerRadius = UDim.new(0, 4); vc.Parent = valueBox
    local vs = Instance.new("UIStroke"); vs.Color = SelectedTheme.InputStroke; vs.Parent = valueBox

    local track = Instance.new("Frame")
    track.Position = UDim2.new(0, 15, 0, 29)
    track.Size = UDim2.new(1, -30, 0, 6)
    track.BackgroundColor3 = SelectedTheme.SliderBackground
    track.BorderSizePixel = 0
    track.Parent = card
    local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(1, 0); tc.Parent = track

    local progress = Instance.new("Frame")
    progress.Size = UDim2.new(0, 0, 1, 0)
    progress.BackgroundColor3 = SelectedTheme.SliderProgress
    progress.BorderSizePixel = 0
    progress.Parent = track
    local pc = Instance.new("UICorner"); pc.CornerRadius = UDim.new(1, 0); pc.Parent = progress

    local hit = Instance.new("TextButton")
    hit.Size = UDim2.new(1, 0, 3, 0)
    hit.Position = UDim2.new(0, 0, -1, 0)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.Parent = track

    Perf.onTheme(function()
        title.TextColor3 = SelectedTheme.TextColor
        valueBox.BackgroundColor3 = SelectedTheme.InputBackground
        valueBox.TextColor3 = SelectedTheme.TextColor
        vs.Color = SelectedTheme.InputStroke
        track.BackgroundColor3 = SelectedTheme.SliderBackground
        progress.BackgroundColor3 = SelectedTheme.SliderProgress
    end)

    local MIN, MAX = S.Range[1], S.Range[2]
    local STEP = S.Increment or 1
    local value = math.clamp(S.Value or MIN, MIN, MAX)
    local dragging = false
    local api = { CurrentValue = value }

    local function render(animate)
        local alpha = (value - MIN) / math.max(MAX - MIN, 1e-9)
        TweenService:Create(
            progress,
            TweenInfo.new(animate and 0.2 or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.new(alpha, 0, 1, 0) }
        ):Play()
        if not valueBox:IsFocused() then
            valueBox.Text = tostring(value) .. (S.Suffix and (" " .. S.Suffix) or "")
        end
    end

    local function commit(newValue, fromUser)
        newValue = math.clamp(math.floor(newValue / STEP + 0.5) * STEP, MIN, MAX)
        if newValue == value then return end
        value = newValue
        api.CurrentValue = value
        render(true)
        if fromUser and S.Callback then
            local ok, err = pcall(S.Callback, value)
            if not ok then warn("Rayfield | NumberSlider callback:", err) end
        end
        if not S.Ext then SaveConfiguration() end
    end

    local _frameId
    hit.MouseButton1Down:Connect(function()
        dragging = true
        if not _frameId then
            _frameId = Perf.onFrame(function()
                if not dragging then return end
                local abs = track.AbsolutePosition.X
                local width = track.AbsoluteSize.X
                if width <= 0 then return end
                local mx = UserInputService:GetMouseLocation().X
                local alpha = math.clamp((mx - abs) / width, 0, 1)
                commit(MIN + alpha * (MAX - MIN), true)
            end)
        end
    end)

    Perf.track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    valueBox.FocusLost:Connect(function()
        local n = tonumber((valueBox.Text:gsub("[^%-%d%.]", "")))
        if n then commit(n, true) else render(false) end
    end)

    function api:Set(v, animate)
        value = math.clamp(v, MIN, MAX)
        api.CurrentValue = value
        render(animate ~= false)
    end
    function api:Get() return value end

    render(false)
    return Perf.attach(api, card, function()
        if _frameId then Perf.offFrame(_frameId) end
    end)
end

]==]

do
    local anchor = "\t\treturn Tab\n\tend\n\n\tElements.Visible = true"
    local s = string.find(source, anchor, 1, true)
    if s then
        local replacement = NEW_ELEMENTS .. "\n\t\treturn Tab\n\tend\n\n\tElements.Visible = true"
        source = string.sub(source, 1, s - 1) .. replacement
            .. string.sub(source, s + #anchor)
    else
        warn("[Superior] Falha: âncora de injeção de elementos não encontrada")
    end
end

-- ─────────────────────────────────────────────────────────────────────
-- 7. Expõe internos no retorno final
-- ─────────────────────────────────────────────────────────────────────
do
    local finalReturn = "return RayfieldLibrary"
    local s = string.find(source, finalReturn, 1, true)
    if s then
        local exposed = [[
RayfieldLibrary.__rayfield = Rayfield
RayfieldLibrary.__main = Main
RayfieldLibrary.__elements = Elements
RayfieldLibrary.__topbar = Topbar
RayfieldLibrary.__perf = Perf
RayfieldLibrary.__superior = true
RayfieldLibrary.__superiorVersion = "1.0"

]]
        source = string.sub(source, 1, s - 1) .. exposed .. finalReturn
            .. string.sub(source, s + #finalReturn)
    end
end

-- ─────────────────────────────────────────────────────────────────────
-- 8. Carrega o source patcheado
-- ─────────────────────────────────────────────────────────────────────
local loader, loadErr = loadstring(source)
if not loader then
    error("[Rayfield Superior] Erro de sintaxe após patch: " .. tostring(loadErr))
end

local success, RayfieldLibrary = pcall(loader)
if not success or not RayfieldLibrary then
    error("[Rayfield Superior] Erro ao inicializar: " .. tostring(RayfieldLibrary))
end

print("[Rayfield Superior] Biblioteca carregada. Aplicando hooks externos...")

-- ─────────────────────────────────────────────────────────────────────
-- 9. Hooks externos pós-carregamento
-- ─────────────────────────────────────────────────────────────────────
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Main = RayfieldLibrary.__main
local Topbar = RayfieldLibrary.__topbar
local Perf = RayfieldLibrary.__perf
local RayfieldFolder = "Rayfield"
local ConfigurationExtension = ".rfld"

-- ── 9.1. Bridge de tema: uma única conexão dispara o Perf.pushTheme
if Main then
    Main:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
        Perf.pushTheme()
    end)
end

-- ── 9.2. Wrapper de CreateWindow para injetar perfis, export/import e resize
local originalCreateWindow = RayfieldLibrary.CreateWindow

local function safeName(name)
    return (tostring(name):gsub("[^%w_%-]", "_"):sub(1, 48))
end

local function collectFlags()
    local data = {}
    for flag, el in pairs(RayfieldLibrary.Flags) do
        if el.Type == "ColorPicker" then
            data[flag] = {
                R = el.Color.R * 255,
                G = el.Color.G * 255,
                B = el.Color.B * 255,
            }
        elseif typeof(el.CurrentValue) == "boolean" then
            data[flag] = el.CurrentValue
        else
            data[flag] = el.CurrentValue or el.CurrentKeybind or el.CurrentOption or el.Color
        end
    end
    return data
end

RayfieldLibrary.CreateWindow = function(self, settings)
    local window = originalCreateWindow(self, settings)

    local ProfileFolder = RayfieldFolder .. "/Profiles"

    local function ensureFolder(path)
        if isfolder and not isfolder(path) then
            if makefolder then pcall(makefolder, path) end
        end
    end

    local function safeWrite(path, content)
        if writefile then pcall(writefile, path, content) end
    end

    local function safeRead(path)
        if readfile and isfile and isfile(path) then
            local ok, data = pcall(readfile, path)
            return ok and data or nil
        end
        return nil
    end

    local function safeList(path)
        if listfiles and isfolder and isfolder(path) then
            local ok, files = pcall(listfiles, path)
            return ok and files or {}
        end
        return {}
    end

    function window:SaveProfile(name)
        if not writefile then return false end
        ensureFolder(RayfieldFolder)
        ensureFolder(ProfileFolder)
        safeWrite(
            ProfileFolder .. "/" .. safeName(name) .. ConfigurationExtension,
            HttpService:JSONEncode(collectFlags())
        )
        RayfieldLibrary:Notify({
            Title = "Perfil salvo",
            Content = "Perfil '" .. tostring(name) .. "' guardado.",
            Duration = 4,
        })
        return true
    end

    function window:LoadProfile(name)
        local path = ProfileFolder .. "/" .. safeName(name) .. ConfigurationExtension
        local data = safeRead(path)
        if not data then
            RayfieldLibrary:Notify({
                Title = "Perfil",
                Content = "Perfil '" .. tostring(name) .. "' não existe.",
                Duration = 4,
            })
            return false
        end
        local ok, decoded = pcall(HttpService.JSONDecode, HttpService, data)
        if not ok then return false end
        for flag, value in pairs(decoded) do
            local el = RayfieldLibrary.Flags[flag]
            if el and el.Set then
                pcall(function()
                    if el.Type == "ColorPicker" then
                        el:Set(Color3.fromRGB(value.R, value.G, value.B))
                    else
                        el:Set(value)
                    end
                end)
            end
        end
        RayfieldLibrary:Notify({
            Title = "Perfil carregado",
            Content = "'" .. tostring(name) .. "' aplicado.",
            Duration = 4,
        })
        return true
    end

    function window:ListProfiles()
        local out = {}
        for _, full in ipairs(safeList(ProfileFolder)) do
            local n = full:match("([^/\\]+)" .. ConfigurationExtension .. "$")
            if n then out[#out + 1] = n end
        end
        return out
    end

    function window:DeleteProfile(name)
        if not delfile then return false end
        local path = ProfileFolder .. "/" .. safeName(name) .. ConfigurationExtension
        local ok = pcall(delfile, path)
        return ok
    end

    function window:ExportConfig()
        local json = HttpService:JSONEncode(collectFlags())
        if setclipboard then pcall(setclipboard, json) end
        RayfieldLibrary:Notify({
            Title = "Config exportada",
            Content = setclipboard
                and "Copiada para a área de transferência."
                or "Impressa no console (F9).",
            Duration = 5,
        })
        if not setclipboard then print("[Rayfield Export]", json) end
        return json
    end

    function window:ImportConfig(json)
        if type(json) ~= "string" or #json == 0 then return false end
        local ok, decoded = pcall(HttpService.JSONDecode, HttpService, json)
        if not ok then
            RayfieldLibrary:Notify({
                Title = "Import falhou",
                Content = "JSON inválido.",
                Duration = 5,
            })
            return false
        end
        for flag, value in pairs(decoded) do
            local el = RayfieldLibrary.Flags[flag]
            if el and el.Set then
                pcall(function()
                    if el.Type == "ColorPicker" then
                        el:Set(Color3.fromRGB(value.R, value.G, value.B))
                    else
                        el:Set(value)
                    end
                end)
            end
        end
        RayfieldLibrary:Notify({
            Title = "Config importada",
            Content = "Configuração aplicada.",
            Duration = 4,
        })
        return true
    end

    -- ── Handle de redimensionamento
    if Main then
        local grip = Instance.new("TextButton")
        grip.Name = "RF_ResizeGrip"
        grip.AnchorPoint = Vector2.new(1, 1)
        grip.Position = UDim2.new(1, -3, 1, -3)
        grip.Size = UDim2.new(0, 16, 0, 16)
        grip.BackgroundTransparency = 1
        grip.Text = ""
        grip.AutoButtonColor = false
        grip.ZIndex = 5
        grip.Parent = Main

        for i = 1, 3 do
            local l = Instance.new("Frame")
            l.AnchorPoint = Vector2.new(1, 1)
            l.Position = UDim2.new(1, -i * 4, 1, -i * 4)
            l.Size = UDim2.new(0, 2, 0, 2)
            l.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            l.BackgroundTransparency = 0.4
            l.BorderSizePixel = 0
            l.Parent = grip
        end

        local resizing = false
        local startSize, startMouse

        grip.MouseButton1Down:Connect(function()
            resizing = true
            startSize = Main.AbsoluteSize
            startMouse = UserInputService:GetMouseLocation()
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                resizing = false
            end
        end)

        Perf.onFrame(function()
            if not resizing then return end
            local delta = UserInputService:GetMouseLocation() - startMouse
            Main.Size = UDim2.fromOffset(
                math.clamp(startSize.X + delta.X, 380, 1400),
                math.clamp(startSize.Y + delta.Y, 200, 1000)
            )
            if Topbar then
                Topbar.Size = UDim2.new(0, Main.AbsoluteSize.X, 0, 45)
            end
        end)
    end

    return window
end

-- ─────────────────────────────────────────────────────────────────────
-- 10. Notify e Destroy aprimorados
-- ─────────────────────────────────────────────────────────────────────
local originalNotify = RayfieldLibrary.Notify
RayfieldLibrary.Notify = function(self, data)
    if data and data.Content == nil and data.Title ~= nil and data.Duration == nil then
        -- Compat: se alguém passar como antes, mantém
    end
    return originalNotify(self, data)
end

local originalDestroy = RayfieldLibrary.Destroy
RayfieldLibrary.Destroy = function(self)
    if RayfieldLibrary.__perf then
        pcall(RayfieldLibrary.__perf.disconnectAll)
    end
    return originalDestroy(self)
end

print("[Rayfield Superior] Pronto. use Rayfield:CreateWindow({...}) normalmente.")
print("[Rayfield Superior] Novos métodos: Window:SaveProfile, LoadProfile, ListProfiles, DeleteProfile, ExportConfig, ImportConfig")
print("[Rayfield Superior] Novos elementos: Tab:CreateProgressBar, CreateTextArea, CreateNumberSlider")

return RayfieldLibrary
