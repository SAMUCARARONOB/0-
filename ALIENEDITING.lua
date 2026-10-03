--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║  RANOX UI LIBRARY · Version 3.0.0                                ║
    ║  ✦ Alien Edition · 100% API Compatible ✦                         ║
    ║  ✦ Animações de entrada · Glow · Partículas · Sons · Ripple ✦    ║
    ╚══════════════════════════════════════════════════════════════════╝
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local RANOX = {}

-- ═══════════════════════════════════════════════════════════════════
-- PALETA GLOBAL (cores centralizadas)
-- ═══════════════════════════════════════════════════════════════════
local Palette = {
    Accent       = Color3.fromRGB(170, 20, 20),
    AccentBright = Color3.fromRGB(255, 60, 60),
    AccentSoft   = Color3.fromRGB(90, 15, 15),
    Bg           = Color3.fromRGB(15, 15, 18),
    Surface      = Color3.fromRGB(24, 24, 28),
    SurfaceHi    = Color3.fromRGB(34, 34, 40),
    Border       = Color3.fromRGB(50, 50, 60),
    Text         = Color3.fromRGB(245, 245, 250),
    TextDim      = Color3.fromRGB(170, 170, 180),
    TextMute     = Color3.fromRGB(110, 110, 120),
    Success      = Color3.fromRGB(0, 220, 130),
    Danger       = Color3.fromRGB(255, 70, 100),
}

-- ═══════════════════════════════════════════════════════════════════
-- HELPERS DE ANIMAÇÃO
-- ═══════════════════════════════════════════════════════════════════
local function tween(inst, info, props)
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end

local function fast(inst, props)
    return tween(inst, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
end

local function smooth(inst, props, dur)
    return tween(inst, TweenInfo.new(dur or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
end

local function bounce(inst, props)
    return tween(inst, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), props)
end

local function addCorner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = radius or UDim.new(0, 6)
    return c
end

local function addStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or Palette.Border
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.4
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function playSound(id, vol)
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://" .. tostring(id)
    s.Volume = vol or 0.25
    s.Parent = game:GetService("SoundService")
    s:Play()
    game:GetService("Debris"):AddItem(s, 2)
end

local SOUNDS = {
    Hover  = 6895084505,
    Click  = 6895083992,
    Toggle = 6895083749,
}

-- ═══════════════════════════════════════════════════════════════════
-- CREATE WINDOW
-- ═══════════════════════════════════════════════════════════════════
function RANOX:CreateWindow(config)
    config = config or {}
    local Window = {}

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RANOX_UI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 99e99
    pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
    if not screenGui.Parent then screenGui.Parent = player:WaitForChild("PlayerGui") end

    -- Blur ambiente
    local ambientBlur = Instance.new("BlurEffect")
    ambientBlur.Size = 0
    ambientBlur.Parent = game.Lighting
    tween(ambientBlur, TweenInfo.new(0.6, Enum.EasingStyle.Quint), { Size = 8 })

    -- Main Frame
    local mainFrame = Instance.new("TextButton")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 0, 0, 0) -- entrada animada
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Palette.Bg
    mainFrame.BackgroundTransparency = 0.03
    mainFrame.Text = ""
    mainFrame.AutoButtonColor = false
    mainFrame.ClipsDescendants = true
    mainFrame.Draggable = true
    mainFrame.Active = true
    mainFrame.Parent = screenGui
    addCorner(mainFrame, UDim.new(0, 12))

    local stroke = addStroke(mainFrame, Palette.Accent, 1.5, 0.25)
    stroke.Name = "MainStroke"

    local gradient = Instance.new("UIGradient")
    gradient.Name = "MainGradient"
    gradient.Rotation = 135
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.9),
        NumberSequenceKeypoint.new(0.5, 1),
        NumberSequenceKeypoint.new(1, 0.85),
    })
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Palette.AccentSoft),
        ColorSequenceKeypoint.new(1, Palette.Bg),
    }
    gradient.Parent = mainFrame

    -- Glow orbs decorativos animados
    local decorHolder = Instance.new("Frame", mainFrame)
    decorHolder.Name = "Decor"
    decorHolder.Size = UDim2.new(1, 0, 1, 0)
    decorHolder.BackgroundTransparency = 1
    decorHolder.ClipsDescendants = true
    decorHolder.ZIndex = 0

    local orb1 = Instance.new("Frame", decorHolder)
    orb1.Size = UDim2.new(0, 260, 0, 260)
    orb1.Position = UDim2.new(-0.3, 0, -0.3, 0)
    orb1.BackgroundColor3 = Palette.Accent
    orb1.BackgroundTransparency = 0.82
    orb1.BorderSizePixel = 0
    orb1.ZIndex = 0
    addCorner(orb1, UDim.new(1, 0))

    local orb2 = Instance.new("Frame", decorHolder)
    orb2.Size = UDim2.new(0, 220, 0, 220)
    orb2.Position = UDim2.new(0.85, 0, 0.75, 0)
    orb2.BackgroundColor3 = Color3.fromRGB(120, 0, 60)
    orb2.BackgroundTransparency = 0.85
    orb2.BorderSizePixel = 0
    orb2.ZIndex = 0
    addCorner(orb2, UDim.new(1, 0))

    task.spawn(function()
        local t = 0
        while mainFrame.Parent do
            t += task.wait(0.03)
            orb1.Position = UDim2.new(-0.3 + math.sin(t*0.6)*0.08, 0, -0.3 + math.cos(t*0.5)*0.08, 0)
            orb2.Position = UDim2.new(0.85 + math.cos(t*0.4)*0.06, 0, 0.75 + math.sin(t*0.7)*0.06, 0)
        end
    end)

    -- Linha superior animada (accent que corre)
    local topGlow = Instance.new("Frame")
    topGlow.Size = UDim2.new(0, 100, 0, 2)
    topGlow.Position = UDim2.new(0, 0, 0, 0)
    topGlow.BackgroundColor3 = Palette.AccentBright
    topGlow.BorderSizePixel = 0
    topGlow.ZIndex = 5
    topGlow.Parent = mainFrame
    addCorner(topGlow, UDim.new(0, 3))

    task.spawn(function()
        while topGlow.Parent do
            topGlow.Position = UDim2.new(0, -100, 0, 0)
            tween(topGlow, TweenInfo.new(2.5, Enum.EasingStyle.Linear), {
                Position = UDim2.new(1, 0, 0, 0)
            })
            task.wait(2.5)
        end
    end)

    local function AtualizarCorInterface(corStroke, corGradiente1, corGradiente2)
        stroke.Color = corStroke
        gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, corGradiente1),
            ColorSequenceKeypoint.new(1, corGradiente2)
        }
        topGlow.BackgroundColor3 = corGradiente2
        orb1.BackgroundColor3 = corStroke
    end

    -- Título
    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, -50, 0, 25)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "RANOX Hub"
    title.TextColor3 = Palette.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Center
    title.ClipsDescendants = true
    title.ZIndex = 5

    -- Subtítulo
    local subtitle = Instance.new("TextLabel", mainFrame)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = config.Subtitle or "v1.0"
    subtitle.TextColor3 = Palette.TextMute
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 9
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.TextYAlignment = Enum.TextYAlignment.Center
    subtitle.Size = UDim2.new(0, 100, 0, 25)
    subtitle.ZIndex = 5

    task.defer(function()
        local textWidth = title.TextBounds.X
        subtitle.Position = UDim2.new(0, 10 + textWidth + 8, 0, 0)
    end)

    -- Botão minimizar
    local hideButton = Instance.new("TextButton", mainFrame)
    hideButton.Size = UDim2.new(0, 25, 0, 25)
    hideButton.Position = UDim2.new(1, -30, 0, 0)
    hideButton.BackgroundColor3 = Palette.Surface
    hideButton.BackgroundTransparency = 0.4
    hideButton.Text = "−"
    hideButton.TextColor3 = Palette.TextDim
    hideButton.TextSize = 16
    hideButton.Font = Enum.Font.GothamBold
    hideButton.AutoButtonColor = false
    hideButton.BorderSizePixel = 0
    hideButton.ZIndex = 5
    addCorner(hideButton, UDim.new(0, 6))

    local hideStroke = addStroke(hideButton, Palette.Border, 1, 0.4)

    hideButton.MouseEnter:Connect(function()
        fast(hideButton, { BackgroundColor3 = Palette.AccentSoft, BackgroundTransparency = 0.1 })
        fast(hideStroke, { Color = Palette.Accent })
        playSound(SOUNDS.Hover, 0.1)
    end)
    hideButton.MouseLeave:Connect(function()
        fast(hideButton, { BackgroundColor3 = Palette.Surface, BackgroundTransparency = 0.4 })
        fast(hideStroke, { Color = Palette.Border, Transparency = 0.4 })
    end)

    -- Linha divisória
    local line = Instance.new("Frame", mainFrame)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0, 25)
    line.BackgroundColor3 = Palette.Accent
    line.BackgroundTransparency = 0.4
    line.BorderSizePixel = 0
    line.ZIndex = 4

    -- Sidebar (tabs)
    local sidebar = Instance.new("ScrollingFrame", mainFrame)
    sidebar.Size = UDim2.new(0.25, 0, 1, -25)
    sidebar.Position = UDim2.new(0, 0, 0, 25)
    sidebar.BackgroundColor3 = Palette.Bg
    sidebar.BackgroundTransparency = 0.4
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebar.ScrollBarThickness = 3
    sidebar.ScrollBarImageColor3 = Palette.Accent
    sidebar.BorderSizePixel = 0
    sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
    addCorner(sidebar, UDim.new(0, 6))

    local sidebarLayout = Instance.new("UIListLayout", sidebar)
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Padding = UDim.new(0, 3)

    local sidebarPad = Instance.new("UIPadding", sidebar)
    sidebarPad.PaddingTop = UDim.new(0, 5)
    sidebarPad.PaddingLeft = UDim.new(0, 5)
    sidebarPad.PaddingRight = UDim.new(0, 5)

    local tabButtons = {}
    local pages = {}
    local selectedTab = nil

    -- Indicador deslizante da tab ativa
    local tabIndicator = Instance.new("Frame", sidebar)
    tabIndicator.Name = "TabIndicator"
    tabIndicator.Size = UDim2.new(1, -10, 0, 33)
    tabIndicator.Position = UDim2.new(0, 5, 0, 5)
    tabIndicator.BackgroundColor3 = Palette.Surface
    tabIndicator.BackgroundTransparency = 0.2
    tabIndicator.BorderSizePixel = 0
    tabIndicator.ZIndex = 1
    tabIndicator.Visible = false
    addCorner(tabIndicator, UDim.new(0, 6))

    local indStroke = addStroke(tabIndicator, Palette.Accent, 1.2, 0.3)

    -- Scroll Holder (conteúdo)
    local scrollHolder = Instance.new("ScrollingFrame", mainFrame)
    scrollHolder.Position = UDim2.new(0.25, 4, 0, 30)
    scrollHolder.Size = UDim2.new(0.75, -8, 1, -35)
    scrollHolder.BackgroundTransparency = 1
    scrollHolder.BorderSizePixel = 0
    scrollHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollHolder.ScrollBarThickness = 4
    scrollHolder.ScrollBarImageColor3 = Palette.Accent
    scrollHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y

    -- Floating Ball (para restaurar)
    local ballButton = Instance.new("ImageButton")
    ballButton.Size = UDim2.new(0, 50, 0, 50)
    ballButton.Position = UDim2.new(0.1, 0, 0.9, -150)
    ballButton.AnchorPoint = Vector2.new(0.5, 0.5)
    ballButton.BackgroundColor3 = Palette.Accent
    ballButton.Image = "rbxassetid://6337069410"
    ballButton.BackgroundTransparency = 0
    ballButton.Visible = false
    ballButton.Active = true
    ballButton.Draggable = true
    ballButton.Parent = screenGui
    addCorner(ballButton, UDim.new(0.5, 0))

    local ballStroke = addStroke(ballButton, Palette.AccentBright, 2, 0.2)

    task.spawn(function()
        while ballButton.Parent do
            tween(ballStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0.8 })
            task.wait(1.2)
            tween(ballStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0.2 })
            task.wait(1.2)
        end
    end)

    -- Entry animation
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.BackgroundTransparency = 1
    task.spawn(function()
        task.wait(0.05)
        smooth(mainFrame, { Size = UDim2.new(0, 575, 0, 375) }, 0.5)
        smooth(mainFrame, { BackgroundTransparency = 0.03 }, 0.35)
    end)

    local function switchTab(name)
        for tabName, frame in pairs(pages) do
            frame.Visible = (tabName == name)
        end
        for tabName, btn in pairs(tabButtons) do
            local marker = btn:FindFirstChild("TabMarker")
            local label = btn:FindFirstChildOfClass("TextLabel")
            local icon = btn:FindFirstChild("TabIcon")
            if marker then marker.Visible = (tabName == name) end
            if label then
                fast(label, { TextColor3 = (tabName == name) and Palette.Text or Palette.TextDim })
            end
            if icon then
                fast(icon, { ImageColor3 = (tabName == name) and Palette.AccentBright or Palette.TextMute })
            end
        end
        selectedTab = name
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE TAB
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateTab(tabName, iconId)
        local tabBtn = Instance.new("TextButton", sidebar)
        tabBtn.Size = UDim2.new(1, -2, 0, 33)
        tabBtn.Text = ""
        tabBtn.Font = Enum.Font.Gotham
        tabBtn.TextSize = 12
        tabBtn.TextColor3 = Palette.TextDim
        tabBtn.BackgroundColor3 = Palette.Surface
        tabBtn.BackgroundTransparency = 1
        tabBtn.AutoButtonColor = false
        tabBtn.ClipsDescendants = true
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        tabBtn.ZIndex = 2
        addCorner(tabBtn, UDim.new(0, 6))

        local uiStroke = addStroke(tabBtn, Palette.Border, 1, 1)

        local marker = Instance.new("Frame", tabBtn)
        marker.Name = "TabMarker"
        marker.Size = UDim2.new(0, 3, 1, -10)
        marker.Position = UDim2.new(0, 0, 0, 5)
        marker.BackgroundColor3 = Palette.AccentBright
        marker.BorderSizePixel = 0
        marker.Visible = false
        addCorner(marker, UDim.new(0, 3))

        local label = Instance.new("TextLabel", tabBtn)
        label.BackgroundTransparency = 1
        label.Text = tabName
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 12
        label.TextColor3 = Palette.TextDim
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextWrapped = true

        if iconId then
            local icon = Instance.new("ImageLabel", tabBtn)
            icon.Name = "TabIcon"
            icon.Size = UDim2.new(0, 16, 0, 16)
            icon.Position = UDim2.new(0, 6, 0.5, -8)
            icon.BackgroundTransparency = 1
            icon.Image = "rbxassetid://" .. tostring(iconId)
            icon.ImageColor3 = Palette.TextMute
            label.Position = UDim2.new(0, 26, 0, 0)
            label.Size = UDim2.new(1, -28, 1, 0)
        else
            label.Position = UDim2.new(0, 10, 0, 0)
            label.Size = UDim2.new(1, -10, 1, 0)
        end

        tabButtons[tabName] = tabBtn

        tabBtn.MouseEnter:Connect(function()
            if selectedTab ~= tabName then
                fast(tabBtn, { BackgroundColor3 = Palette.SurfaceHi, BackgroundTransparency = 0.5 })
                playSound(SOUNDS.Hover, 0.08)
            end
        end)

        tabBtn.MouseLeave:Connect(function()
            if selectedTab ~= tabName then
                fast(tabBtn, { BackgroundColor3 = Palette.Surface, BackgroundTransparency = 1 })
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

        local pad = Instance.new("UIPadding", tabPage)
        pad.PaddingTop = UDim.new(0, 4)
        pad.PaddingLeft = UDim.new(0, 4)
        pad.PaddingRight = UDim.new(0, 8)

        pages[tabName] = tabPage

        tabBtn.MouseButton1Click:Connect(function()
            playSound(SOUNDS.Click, 0.25)
            switchTab(tabName)
        end)

        if not selectedTab then
            switchTab(tabName)
        end
    end

    -- ═══════════════════════════════════════════════════════════════
    -- RIPPLE HELPER
    -- ═══════════════════════════════════════════════════════════════
    local function addRipple(parent)
        local ripple = Instance.new("Frame", parent)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.7
        ripple.BorderSizePixel = 0
        ripple.ZIndex = 2
        addCorner(ripple, UDim.new(1, 0))
        local t1 = tween(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1.8, 0, 4, 0),
            BackgroundTransparency = 1
        })
        t1.Completed:Connect(function() ripple:Destroy() end)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE BUTTON
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateButton(tabName, text, callback)
        local tab = pages[tabName]; if not tab then return end

        local btn = Instance.new("TextButton", tab)
        btn.Size = UDim2.new(1, -20, 0, 34)
        btn.Position = UDim2.new(0, 10, 0, 0)
        btn.Text = text
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 14
        btn.TextColor3 = Palette.Text
        btn.BackgroundColor3 = Palette.SurfaceHi
        btn.AutoButtonColor = false
        btn.ClipsDescendants = true
        btn.TextWrapped = true
        addCorner(btn, UDim.new(0, 8))
        local stroke = addStroke(btn, Palette.Border, 1, 0.5)

        local accentBar = Instance.new("Frame", btn)
        accentBar.Size = UDim2.new(0, 3, 1, 0)
        accentBar.Position = UDim2.new(0, 0, 0, 0)
        accentBar.BackgroundColor3 = Palette.Accent
        accentBar.BorderSizePixel = 0

        btn.MouseEnter:Connect(function()
            tween(btn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(55, 20, 22) })
            tween(stroke, TweenInfo.new(0.2), { Color = Palette.AccentBright, Transparency = 0.2 })
            tween(accentBar, TweenInfo.new(0.2), { Size = UDim2.new(0, 5, 1, 0) })
            playSound(SOUNDS.Hover, 0.1)
        end)

        btn.MouseLeave:Connect(function()
            tween(btn, TweenInfo.new(0.2), { BackgroundColor3 = Palette.SurfaceHi })
            tween(stroke, TweenInfo.new(0.2), { Color = Palette.Border, Transparency = 0.5 })
            tween(accentBar, TweenInfo.new(0.2), { Size = UDim2.new(0, 3, 1, 0) })
        end)

        btn.MouseButton1Click:Connect(function()
            playSound(SOUNDS.Click, 0.3)
            addRipple(btn)
            tween(btn, TweenInfo.new(0.1), { Size = UDim2.new(1, -22, 0, 32) })
            task.delay(0.1, function()
                tween(btn, TweenInfo.new(0.15, Enum.EasingStyle.Back), { Size = UDim2.new(1, -20, 0, 34) })
            end)
            if callback then pcall(callback) end
        end)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE CHECKBOX
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateCheckbox(tabName, checkboxConfig)
        local tab = pages[tabName]; if not tab then return end
        checkboxConfig = checkboxConfig or {}

        local checkboxFrame = Instance.new("Frame", tab)
        checkboxFrame.Size = UDim2.new(1, -20, 0, 46)
        checkboxFrame.BackgroundColor3 = Palette.Surface
        checkboxFrame.BorderSizePixel = 0
        checkboxFrame.ClipsDescendants = true
        checkboxFrame.LayoutOrder = checkboxConfig.Order or 0
        addCorner(checkboxFrame, UDim.new(0, 8))
        local cfStroke = addStroke(checkboxFrame, Palette.Border, 1, 0.7)

        local title = Instance.new("TextLabel", checkboxFrame)
        title.Text = checkboxConfig.Text or "Checkbox"
        title.TextColor3 = Palette.Text
        title.Font = Enum.Font.GothamMedium
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextYAlignment = Enum.TextYAlignment.Top
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1, -50, 0, 16)
        title.Position = UDim2.new(0, 12, 0, 5)

        local description = Instance.new("TextLabel", checkboxFrame)
        description.Text = checkboxConfig.Description or ""
        description.TextColor3 = Palette.TextMuted
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
        box.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
        box.BorderSizePixel = 0
        addCorner(box, UDim.new(0, 6))
        local boxStroke = addStroke(box, Palette.Border, 1.3, 0.3)

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

        local function tweenBoxColor(toColor)
            tween(box, TweenInfo.new(0.2), { BackgroundColor3 = toColor })
        end

        button.MouseEnter:Connect(function()
            tween(boxStroke, TweenInfo.new(0.2), { Color = Palette.AccentBright, Transparency = 0.1 })
            tween(checkboxFrame, TweenInfo.new(0.2), { BackgroundColor3 = Palette.SurfaceHi })
        end)
        button.MouseLeave:Connect(function()
            if not toggled then
                tween(boxStroke, TweenInfo.new(0.2), { Color = Palette.Border, Transparency = 0.3 })
            end
            tween(checkboxFrame, TweenInfo.new(0.2), { BackgroundColor3 = Palette.Surface })
        end)

        button.MouseButton1Click:Connect(function()
            toggled = not toggled
            checkmark.Visible = toggled
            playSound(SOUNDS.Toggle, 0.25)

            local grow = tween(box, TweenInfo.new(0.15), { Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -40, 0.5, -14) })
            grow.Completed:Connect(function()
                tween(box, TweenInfo.new(0.15, Enum.EasingStyle.Back), { Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -38, 0.5, -12) })
            end)

            if toggled then
                tweenBoxColor(Palette.Accent)
                tween(boxStroke, TweenInfo.new(0.2), { Color = Palette.AccentBright, Transparency = 0 })
                running = true
                task.spawn(function()
                    while running and toggled do
                        pcall(checkboxConfig.Callback)
                        task.wait()
                    end
                end)
            else
                tweenBoxColor(Color3.fromRGB(28, 28, 32))
                tween(boxStroke, TweenInfo.new(0.2), { Color = Palette.Border, Transparency = 0.3 })
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
        local tab = pages[tabName]; if not tab then return end
        toggleConfig = toggleConfig or {}

        local toggleFrame = Instance.new("Frame", tab)
        toggleFrame.Size = UDim2.new(1, -20, 0, 46)
        toggleFrame.Position = UDim2.new(0, 10, 0, 0)
        toggleFrame.BackgroundColor3 = Palette.Surface
        toggleFrame.ClipsDescendants = true
        toggleFrame.BorderSizePixel = 0
        addCorner(toggleFrame, UDim.new(0, 8))
        local tfStroke = addStroke(toggleFrame, Palette.Border, 1, 0.7)

        local title = Instance.new("TextLabel", toggleFrame)
        title.Text = toggleConfig.Text or "Toggle"
        title.TextColor3 = Palette.Text
        title.Font = Enum.Font.GothamMedium
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextYAlignment = Enum.TextYAlignment.Top
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1, -60, 0, 16)
        title.Position = UDim2.new(0, 12, 0, 5)

        local description = Instance.new("TextLabel", toggleFrame)
        description.Text = toggleConfig.Description or "Descrição"
        description.TextColor3 = Palette.TextMuted
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
        switch.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        switch.BorderSizePixel = 0
        addCorner(switch, UDim.new(1, 0))

        local ball = Instance.new("Frame", switch)
        ball.Size = UDim2.new(0, 16, 0, 16)
        ball.Position = UDim2.new(0, 3, 0.5, -8)
        ball.BackgroundColor3 = Color3.fromRGB(200, 200, 205)
        ball.BorderSizePixel = 0
        addCorner(ball, UDim.new(1, 0))

        local toggleButton = Instance.new("TextButton", switch)
        toggleButton.Size = UDim2.new(1, 0, 1, 0)
        toggleButton.BackgroundTransparency = 1
        toggleButton.Text = ""
        toggleButton.AutoButtonColor = false

        local isOn = false

        toggleButton.MouseEnter:Connect(function()
            tween(tfStroke, TweenInfo.new(0.2), { Color = Palette.AccentBright, Transparency = 0.2 })
        end)
        toggleButton.MouseLeave:Connect(function()
            tween(tfStroke, TweenInfo.new(0.2), { Color = Palette.Border, Transparency = 0.7 })
        end)

        toggleButton.MouseButton1Click:Connect(function()
            isOn = not isOn
            playSound(SOUNDS.Toggle, 0.25)
            local bgColor = isOn and Palette.Accent or Color3.fromRGB(40, 40, 45)
            local ballPos = isOn and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            local ballColor = isOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 205)

            tween(switch, TweenInfo.new(0.3, Enum.EasingStyle.Back), { BackgroundColor3 = bgColor })
            tween(ball, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Position = ballPos, BackgroundColor3 = ballColor })

            if toggleConfig.Callback then pcall(toggleConfig.Callback, isOn) end
        end)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE LABEL
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateLabel(tabName, text)
        local tab = pages[tabName]; if not tab then return end

        local label = Instance.new("TextLabel", tab)
        label.Size = UDim2.new(1, -20, 0, 30)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.Text = "  " .. string.upper(text or "")
        label.Font = Enum.Font.GothamBold
        label.TextSize = 15
        label.TextColor3 = Palette.Text
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Center

        local accentDot = Instance.new("Frame", label)
        accentDot.Size = UDim2.new(0, 6, 0, 6)
        accentDot.Position = UDim2.new(0, 0, 0.5, -3)
        accentDot.BackgroundColor3 = Palette.AccentBright
        accentDot.BorderSizePixel = 0
        addCorner(accentDot, UDim.new(1, 0))

        local dotGlow = addStroke(accentDot, Palette.AccentBright, 2, 0.3)

        task.spawn(function()
            while accentDot.Parent do
                tween(dotGlow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0.9 })
                task.wait(1.2)
                tween(dotGlow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0.2 })
                task.wait(1.2)
            end
        end)

        local underline = Instance.new("Frame", label)
        underline.Size = UDim2.new(1, -20, 0, 1)
        underline.Position = UDim2.new(0, 10, 1, -3)
        underline.BackgroundColor3 = Palette.Outline
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
        local tab = pages[tabName]; if not tab then return end
        dropdownConfig = dropdownConfig or {}

        local dropdownFrame = Instance.new("Frame", tab)
        dropdownFrame.Size = UDim2.new(1, -20, 0, 36)
        dropdownFrame.Position = UDim2.new(0, 10, 0, 0)
        dropdownFrame.BackgroundColor3 = Palette.Surface
        dropdownFrame.BorderSizePixel = 0
        dropdownFrame.ZIndex = 2
        addCorner(dropdownFrame, UDim.new(0, 8))
        local dfStroke = addStroke(dropdownFrame, Palette.Border, 1, 0.5)

        local title = Instance.new("TextLabel", dropdownFrame)
        title.BackgroundTransparency = 1
        title.Text = dropdownConfig.Text or "Selecione..."
        title.TextColor3 = Palette.TextDim
        title.Font = Enum.Font.GothamSemibold
        title.TextSize = 13
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
        arrowIcon.TextColor3 = Palette.TextDim
        arrowIcon.Font = Enum.Font.GothamBold
        arrowIcon.TextSize = 14
        arrowIcon.ZIndex = 3

        local selectedLabel = Instance.new("TextLabel", dropdownFrame)
        selectedLabel.BackgroundTransparency = 1
        selectedLabel.Text = dropdownConfig.Default or "None"
        selectedLabel.TextColor3 = Palette.Text
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
        dropdownList.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
        dropdownList.Visible = false
        dropdownList.ClipsDescendants = true
        dropdownList.ZIndex = 5
        addCorner(dropdownList, UDim.new(0, 8))
        addStroke(dropdownList, Palette.Border, 1, 0.4)

        local listLayout = Instance.new("UIListLayout", dropdownList)
        listLayout.Padding = UDim.new(0, 2)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local listPad = Instance.new("UIPadding", dropdownList)
        listPad.PaddingTop = UDim.new(0, 4)
        listPad.PaddingLeft = UDim.new(0, 4)
        listPad.PaddingRight = UDim.new(0, 4)

        local isOpen = false
        toggleButton.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            playSound(SOUNDS.Click, 0.25)
            dropdownList.Visible = true
            local targetHeight = isOpen and (#(dropdownConfig.Options or {}) * 32 + 12) or 0
            arrowIcon.Text = isOpen and "˄" or "˅"
            dropdownList:TweenSize(UDim2.new(1, -20, 0, targetHeight), "Out", "Back", 0.35, true)
            tween(dfStroke, TweenInfo.new(0.25), { Color = isOpen and Palette.AccentBright or Palette.Border })
            if not isOpen then
                task.delay(0.35, function() dropdownList.Visible = false end)
            end
        end)

        for _, option in ipairs(dropdownConfig.Options or {}) do
            local optBtn = Instance.new("TextButton", dropdownList)
            optBtn.Size = UDim2.new(1, 0, 0, 32)
            optBtn.Text = option
            optBtn.BackgroundColor3 = Palette.SurfaceHi
            optBtn.TextColor3 = Palette.Text
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextSize = 13
            optBtn.AutoButtonColor = false
            optBtn.ZIndex = 6
            addCorner(optBtn, UDim.new(0, 6))

            optBtn.MouseEnter:Connect(function()
                tween(optBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(60, 20, 22) })
            end)
            optBtn.MouseLeave:Connect(function()
                tween(optBtn, TweenInfo.new(0.15), { BackgroundColor3 = Palette.SurfaceHi })
            end)

            optBtn.MouseButton1Click:Connect(function()
                updateSelectedLabelText(option)
                playSound(SOUNDS.Click, 0.3)
                if dropdownConfig.Callback then pcall(dropdownConfig.Callback, option) end
                isOpen = false
                arrowIcon.Text = "˅"
                dropdownList:TweenSize(UDim2.new(1, -20, 0, 0), "In", "Back", 0.3, true)
                task.delay(0.3, function() dropdownList.Visible = false end)
            end)
        end
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE SLIDER
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateSlider(tabName, sliderConfig)
        local tab = pages[tabName]; if not tab then return end
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
        bg.Size = UDim2.new(1, 0, 0, 60)
        bg.BackgroundColor3 = Palette.Surface
        bg.BorderSizePixel = 0
        bg.ZIndex = 2
        addCorner(bg, UDim.new(0, 8))
        local bgStroke = addStroke(bg, Palette.Border, 1, 0.6)

        local title = Instance.new("TextLabel", bg)
        title.Size = UDim2.new(1, -60, 0, 16)
        title.Position = UDim2.new(0, 12, 0, 6)
        title.Text = sliderConfig.Text or "Slider"
        title.TextColor3 = Palette.Text
        title.TextSize = 14
        title.Font = Enum.Font.GothamMedium
        title.BackgroundTransparency = 1
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 3
        title.TextYAlignment = Enum.TextYAlignment.Center

        local desc = Instance.new("TextLabel", bg)
        desc.Size = UDim2.new(1, -20, 0, 11)
        desc.Position = UDim2.new(0, 12, 0, 24)
        desc.Text = sliderConfig.Description or ""
        desc.TextColor3 = Palette.TextMuted
        desc.TextSize = 11
        desc.Font = Enum.Font.Gotham
        desc.BackgroundTransparency = 1
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.ZIndex = 3
        desc.TextYAlignment = Enum.TextYAlignment.Center

        local valueLabel = Instance.new("TextLabel", bg)
        valueLabel.Size = UDim2.new(0, 50, 0, 16)
        valueLabel.Position = UDim2.new(1, -62, 0, 6)
        valueLabel.TextColor3 = Palette.AccentBright
        valueLabel.TextSize = 14
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.BackgroundTransparency = 1
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.ZIndex = 3
        valueLabel.TextYAlignment = Enum.TextYAlignment.Center

        local bar = Instance.new("Frame", bg)
        bar.Size = UDim2.new(1, -24, 0, 8)
        bar.Position = UDim2.new(0, 12, 0, 46)
        bar.BackgroundColor3 = Color3.fromRGB(40, 40, 44)
        bar.BorderSizePixel = 0
        bar.ZIndex = 2
        addCorner(bar, UDim.new(1, 0))

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = Palette.Accent
        fill.BorderSizePixel = 0
        fill.ZIndex = 3
        addCorner(fill, UDim.new(1, 0))

        local fillGrad = Instance.new("UIGradient", fill)
        fillGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Palette.AccentSoft),
            ColorSequenceKeypoint.new(1, Palette.AccentBright),
        }

        local neonStroke = Instance.new("UIStroke", fill)
        neonStroke.Thickness = 3
        neonStroke.Transparency = 0.3
        neonStroke.Color = Palette.AccentBright

        task.spawn(function()
            local state = true
            while fill.Parent do
                local goal = state and Color3.fromRGB(195, 20, 20) or Color3.fromRGB(255, 30, 30)
                tween(fill, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundColor3 = goal })
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
        local knobShadow = addStroke(knob, Palette.AccentBright, 2, 0.2)

        local min = sliderConfig.Min or 0
        local max = sliderConfig.Max or 100
        local value = sliderConfig.Default or min

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
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                tween(knob, TweenInfo.new(0.15, Enum.EasingStyle.Back), { Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(knob.Position.X.Scale, -10, 0.5, -10) })
                updateSlider(input.Position.X)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input.Position.X)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                tween(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back), { Size = UDim2.new(0, 16, 0, 16) })
            end
        end)

        updateSlider(bar.AbsolutePosition.X)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE TEXT BOX
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateTextBox(tabName, placeholderText, callback)
        local tab = pages[tabName]; if not tab then return end

        local container = Instance.new("Frame", tab)
        container.Size = UDim2.new(1, -20, 0, 40)
        container.Position = UDim2.new(0, 10, 0, 0)
        container.BackgroundTransparency = 1
        container.ClipsDescendants = true

        local background = Instance.new("Frame", container)
        background.Size = UDim2.new(1, 0, 1, 0)
        background.BackgroundColor3 = Palette.Surface
        background.BorderSizePixel = 0
        background.ZIndex = 1
        addCorner(background, UDim.new(0, 8))
        local bgStroke = addStroke(background, Palette.Border, 1, 0.5)

        local highlight = Instance.new("Frame", background)
        highlight.Size = UDim2.new(1, 0, 0, 2)
        highlight.Position = UDim2.new(0, 0, 1, -2)
        highlight.BackgroundColor3 = Palette.Accent
        highlight.BackgroundTransparency = 1
        highlight.BorderSizePixel = 0
        highlight.ZIndex = 2

        local placeholder = Instance.new("TextLabel", background)
        placeholder.Size = UDim2.new(1, -20, 0, 14)
        placeholder.Position = UDim2.new(0, 10, 0.5, -7)
        placeholder.BackgroundTransparency = 1
        placeholder.Text = placeholderText or "Escreva aqui"
        placeholder.TextColor3 = Palette.TextMuted
        placeholder.Font = Enum.Font.Gotham
        placeholder.TextSize = 13
        placeholder.TextXAlignment = Enum.TextXAlignment.Left
        placeholder.ZIndex = 2

        local textBox = Instance.new("TextBox", background)
        textBox.Size = UDim2.new(1, -20, 1, 0)
        textBox.Position = UDim2.new(0, 10, 0, 0)
        textBox.BackgroundTransparency = 1
        textBox.Text = ""
        textBox.TextColor3 = Palette.Text
        textBox.Font = Enum.Font.Gotham
        textBox.TextSize = 13
        textBox.ClearTextOnFocus = false
        textBox.TextXAlignment = Enum.TextXAlignment.Left
        textBox.TextWrapped = false
        textBox.TextTruncate = Enum.TextTruncate.AtEnd
        textBox.ZIndex = 3

        textBox.Focused:Connect(function()
            tween(highlight, TweenInfo.new(0.25), { BackgroundTransparency = 0.3 })
            tween(bgStroke, TweenInfo.new(0.25), { Color = Palette.AccentBright, Transparency = 0.1 })
            placeholder.Visible = false
        end)

        textBox.FocusLost:Connect(function(enterPressed)
            tween(highlight, TweenInfo.new(0.25), { BackgroundTransparency = 1 })
            tween(bgStroke, TweenInfo.new(0.25), { Color = Palette.Border, Transparency = 0.5 })
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
        local tab = pages[tabName]; if not tab then return end
        colorConfig = colorConfig or {}

        local pickerFrame = Instance.new("Frame", tab)
        pickerFrame.Size = UDim2.new(1, -20, 0, 190)
        pickerFrame.Position = UDim2.new(0, 10, 0, 0)
        pickerFrame.BackgroundColor3 = Palette.Surface
        pickerFrame.ClipsDescendants = true
        addCorner(pickerFrame, UDim.new(0, 10))
        local pfStroke = addStroke(pickerFrame, Palette.Border, 1, 0.5)

        local label = Instance.new("TextLabel", pickerFrame)
        label.Size = UDim2.new(1, -60, 0, 30)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = colorConfig.Text or "Escolha uma cor"
        label.TextColor3 = Palette.Text
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left

        local toggleButton = Instance.new("TextButton", pickerFrame)
        toggleButton.Size = UDim2.new(0, 24, 0, 24)
        toggleButton.Position = UDim2.new(1, -32, 0, 3)
        toggleButton.BackgroundTransparency = 1
        toggleButton.Text = "▼"
        toggleButton.TextColor3 = Palette.Text
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
        local cdStroke = addStroke(colorDisplay, Color3.fromRGB(255,255,255), 1, 0.7)

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
                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0))
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
        addStroke(hueMarker, Color3.fromRGB(0,0,0), 1, 0.3)

        local brightnessMarker = Instance.new("Frame", brightnessSlider)
        brightnessMarker.Size = UDim2.new(0, 5, 0, 24)
        brightnessMarker.AnchorPoint = Vector2.new(0.5, 0.5)
        brightnessMarker.Position = UDim2.new(1, 0, 0.5, 0)
        brightnessMarker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        addCorner(brightnessMarker, UDim.new(1, 0))
        addStroke(brightnessMarker, Color3.fromRGB(0,0,0), 1, 0.3)

        local rgbBox = Instance.new("TextBox", container)
        rgbBox.Size = UDim2.new(0.26, 0, 0, 20)
        rgbBox.Position = UDim2.new(0.72, 0, 0, 46)
        rgbBox.BackgroundColor3 = Palette.SurfaceHi
        rgbBox.TextColor3 = Palette.Text
        rgbBox.Font = Enum.Font.Gotham
        rgbBox.TextSize = 11
        rgbBox.Text = "0.255.255"
        addCorner(rgbBox, UDim.new(0, 6))

        local brightnessBox = Instance.new("TextBox", container)
        brightnessBox.Size = UDim2.new(0.26, 0, 0, 20)
        brightnessBox.Position = UDim2.new(0.72, 0, 0, 76)
        brightnessBox.BackgroundColor3 = Palette.SurfaceHi
        brightnessBox.TextColor3 = Palette.Text
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
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    update(input)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    update(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
            playSound(SOUNDS.Click, 0.25)
            toggleButton.Text = opened and "▼" or "▲"
            local goalSize = opened and 190 or 32
            local goalContentSize = opened and 160 or 0
            tween(pickerFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Size = UDim2.new(1, -20, 0, goalSize) })
            tween(container, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Size = UDim2.new(1, 0, 0, goalContentSize) })
        end)

        applyColorFromBox()

        local randomColorToggle = Instance.new("TextButton", container)
        randomColorToggle.Size = UDim2.new(1, -24, 0, 26)
        randomColorToggle.Position = UDim2.new(0, 12, 0, 110)
        randomColorToggle.BackgroundColor3 = Palette.SurfaceHi
        randomColorToggle.Text = "🎲  COR RGB ALEATÓRIA [OFF]"
        randomColorToggle.TextColor3 = Palette.Text
        randomColorToggle.Font = Enum.Font.GothamMedium
        randomColorToggle.TextSize = 12
        addCorner(randomColorToggle, UDim.new(0, 6))
        local rcStroke = addStroke(randomColorToggle, Palette.Border, 1, 0.4)

        local randomColorEnabled = false

        task.spawn(function()
            while pickerFrame.Parent do
                if randomColorEnabled then
                    local rc = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
                    tween(colorDisplay, TweenInfo.new(0.5), { BackgroundColor3 = rc })
                    if colorConfig.Callback then pcall(colorConfig.Callback, rc) end
                end
                task.wait(0.6)
            end
        end)

        randomColorToggle.MouseButton1Click:Connect(function()
            randomColorEnabled = not randomColorEnabled
            randomColorToggle.Text = randomColorEnabled and "🎲  COR RGB ALEATÓRIA [ON]" or "🎲  COR RGB ALEATÓRIA [OFF]"
            tween(rcStroke, TweenInfo.new(0.25), {
                Color = randomColorEnabled and Palette.AccentBright or Palette.Border,
                Transparency = randomColorEnabled and 0 or 0.4
            })
        end)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE SWITCH
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateSwitch(tabName, switchConfig)
        local tab = pages[tabName]; if not tab then return end
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
        label.TextColor3 = Palette.Text
        label.TextSize = 15
        label.TextXAlignment = Enum.TextXAlignment.Left

        local switch = Instance.new("Frame", holder)
        switch.Size = UDim2.new(0, 60, 0, 26)
        switch.Position = UDim2.new(1, -65, 0.5, -13)
        switch.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        switch.BorderSizePixel = 0
        addCorner(switch, UDim.new(1, 0))

        local glow = addStroke(switch, Palette.AccentBright, 1.5, 1)

        local circle = Instance.new("Frame", switch)
        circle.Size = UDim2.new(0, 22, 0, 22)
        circle.Position = UDim2.new(0, 3, 0.5, -11)
        circle.BackgroundColor3 = Color3.fromRGB(200, 200, 205)
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
        underline.BackgroundColor3 = Palette.Border
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
            ColorSequenceKeypoint.new(1, Palette.AccentBright)
        }

        local state = false

        local function toggleSwitch()
            state = not state
            playSound(SOUNDS.Toggle, 0.3)
            local goalPos = state and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
            local bgColor = state and Palette.Accent or Color3.fromRGB(50, 50, 55)
            local circleColor = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 205)
            local textColor = state and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 85, 85)

            tween(circle, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Position = goalPos, BackgroundColor3 = circleColor })
            tween(switch, TweenInfo.new(0.3, Enum.EasingStyle.Back), { BackgroundColor3 = bgColor })
            tween(stateLabel, TweenInfo.new(0.25), { TextColor3 = textColor })
            tween(glow, TweenInfo.new(0.3), { Transparency = state and 0 or 1 })

            stateLabel.Text = state and "ON" or "OFF"
            particle.Enabled = true
            task.delay(0.25, function() particle.Enabled = false end)

            if switchConfig.Callback then pcall(switchConfig.Callback, state) end
        end

        switch.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                toggleSwitch()
            end
        end)

        switch.MouseEnter:Connect(function()
            tween(glow, TweenInfo.new(0.2), { Transparency = state and 0 or 0.4 })
        end)
        switch.MouseLeave:Connect(function()
            tween(glow, TweenInfo.new(0.2), { Transparency = 1 })
        end)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE LINE
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateLine(tabName, color)
        local tab = pages[tabName]; if not tab then return end
        local line = Instance.new("Frame", tab)
        line.Size = UDim2.new(1, -20, 0, 1)
        line.Position = UDim2.new(0, 10, 0, 0)
        line.BackgroundColor3 = color or Palette.Border
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
        if notifying then return end
        if #notifyQueue == 0 then return end
        notifying = true
        local data = table.remove(notifyQueue, 1)
        local frame = data.frame

        frame:TweenPosition(UDim2.new(1, -20, 1, -20 - (data.offset or 0)), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.4, true)

        task.delay(2.2, function()
            frame:TweenPosition(UDim2.new(1, 320, 1, -200 - (data.offset or 0)), Enum.EasingDirection.In, Enum.EasingStyle.Quint, 0.35, true)
            task.wait(0.4)
            data.gui:Destroy()
            if data.blur then
                tween(data.blur, TweenInfo.new(0.3), { Size = 0 })
                task.delay(0.3, function() data.blur:Destroy() end)
            end
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

        local blur = Instance.new("BlurEffect")
        blur.Size = 0
        blur.Parent = game.Lighting
        tween(blur, TweenInfo.new(0.4), { Size = 5 })

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 300, 0, 100)
        frame.Position = UDim2.new(1, 320, 1, -200)
        frame.AnchorPoint = Vector2.new(1, 1)
        frame.BackgroundColor3 = Palette.Bg
        frame.BackgroundTransparency = 0.05
        frame.BorderSizePixel = 0
        frame.Parent = screenGui
        addCorner(frame, UDim.new(0, 12))

        local fStroke = addStroke(frame, Palette.AccentBright, 1.5, 0.2)

        local gradient = Instance.new("UIGradient", frame)
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 100)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
        })
        gradient.Rotation = 45
        gradient.Transparency = NumberSequence.new(0.95)

        local progress = Instance.new("Frame", frame)
        progress.Size = UDim2.new(1, 0, 0, 3)
        progress.Position = UDim2.new(0, 0, 1, -3)
        progress.BackgroundColor3 = Palette.AccentBright
        progress.BorderSizePixel = 0
        addCorner(progress, UDim.new(1, 0))
        tween(progress, TweenInfo.new(2.2, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 3) })

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
        titleLabel.TextColor3 = Palette.Text
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.BackgroundTransparency = 1
        titleLabel.Parent = frame

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, -80, 0, 36)
        textLabel.Position = UDim2.new(0, 72, 0, 42)
        textLabel.Text = text
        textLabel.Font = Enum.Font.Gotham
        textLabel.TextSize = 12
        textLabel.TextColor3 = Palette.TextMuted
        textLabel.TextWrapped = true
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextYAlignment = Enum.TextYAlignment.Top
        textLabel.BackgroundTransparency = 1
        textLabel.Parent = frame

        table.insert(notifyQueue, { frame = frame, gui = screenGui, blur = blur })
        processQueue()
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE PROMO BOX
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreatePromoBox(tabName, title, description, imageId, link, channelName)
        local tab = pages[tabName]; if not tab then return end

        local box = Instance.new("Frame", tab)
        box.Size = UDim2.new(1, -20, 0, 0)
        box.Position = UDim2.new(0, 10, 0, 0)
        box.BackgroundColor3 = Palette.Surface
        box.BorderSizePixel = 0
        box.AutomaticSize = Enum.AutomaticSize.Y
        box.ClipsDescendants = true
        addCorner(box, UDim.new(0, 12))
        local boxStroke = addStroke(box, Color3.fromRGB(80, 10, 10), 1.5, 0.3)

        local icon = Instance.new("ImageLabel", box)
        icon.Size = UDim2.new(0, 90, 0, 90)
        icon.Position = UDim2.new(0, 10, 0, 10)
        icon.Image = "rbxassetid://" .. tostring(imageId)
        icon.BackgroundColor3 = Palette.SurfaceHi
        icon.BorderSizePixel = 0
        icon.ScaleType = Enum.ScaleType.Fit
        addCorner(icon, UDim.new(0, 8))
        addStroke(icon, Palette.Border, 1, 0.5)

        local channelBox = Instance.new("TextBox", box)
        channelBox.Text = channelName or "SEU CANAL AQUI"
        channelBox.Size = UDim2.new(0, 90, 0, 0)
        channelBox.Position = UDim2.new(0, 10, 0, 105)
        channelBox.Font = Enum.Font.GothamBold
        channelBox.TextSize = 12
        channelBox.TextColor3 = Palette.Text
        channelBox.BackgroundColor3 = Palette.SurfaceHi
        channelBox.BorderSizePixel = 0
        channelBox.ClearTextOnFocus = false
        channelBox.AutomaticSize = Enum.AutomaticSize.Y
        channelBox.TextWrapped = true
        channelBox.TextXAlignment = Enum.TextXAlignment.Center
        channelBox.TextYAlignment = Enum.TextYAlignment.Center
        channelBox.ClipsDescendants = true
        channelBox.TextEditable = false
        addCorner(channelBox, UDim.new(0, 6))
        addStroke(channelBox, Palette.Accent, 1.2, 0.2)

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
        titleLabel.TextColor3 = Palette.Text
        titleLabel.BackgroundTransparency = 1
        titleLabel.Size = UDim2.new(1, 0, 0, 30)
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.TextYAlignment = Enum.TextYAlignment.Center

        local buttonHolder = Instance.new("Frame", content)
        buttonHolder.Size = UDim2.new(1, 0, 0, 32)
        buttonHolder.BackgroundColor3 = Color3.fromRGB(70, 10, 10)
        buttonHolder.BorderSizePixel = 0
        buttonHolder.ClipsDescendants = true
        addCorner(buttonHolder, UDim.new(0, 6))
        addStroke(buttonHolder, Palette.Accent, 1.2, 0.2)

        local copyButton = Instance.new("TextButton", buttonHolder)
        copyButton.Text = "COPIAR LINK"
        copyButton.Font = Enum.Font.GothamBold
        copyButton.TextSize = 13
        copyButton.TextColor3 = Palette.Text
        copyButton.BackgroundTransparency = 1
        copyButton.Size = UDim2.new(1, 0, 1, 0)
        copyButton.ZIndex = 2

        local fillBar = Instance.new("Frame", buttonHolder)
        fillBar.Size = UDim2.new(0, 0, 1, 0)
        fillBar.BackgroundColor3 = Palette.AccentBright
        fillBar.BorderSizePixel = 0
        fillBar.ZIndex = 1

        local descLabel = Instance.new("TextLabel", content)
        descLabel.Text = description
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextSize = 13
        descLabel.TextColor3 = Palette.TextMuted
        descLabel.BackgroundTransparency = 1
        descLabel.Size = UDim2.new(1, 0, 0, 0)
        descLabel.AutomaticSize = Enum.AutomaticSize.Y
        descLabel.TextWrapped = true
        descLabel.TextXAlignment = Enum.TextXAlignment.Left

        copyButton.MouseButton1Click:Connect(function()
            pcall(setclipboard, link)
            playSound(SOUNDS.Click, 0.3)
            fillBar.Size = UDim2.new(0, 0, 1, 0)
            fillBar:TweenSize(UDim2.new(1, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.5, true)
        end)

        return {
            MainFrame = box,
            ChannelBox = channelBox,
            DescriptionLabel = descLabel,
            CopyButton = copyButton
        }
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE THEME BOXES
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateThemeBoxes(tabName)
        local tab = pages[tabName]; if not tab then return end

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
            {Color3.fromRGB(255,255,0), Color3.fromRGB(0,0,0)},
            {Color3.fromRGB(0,0,255), Color3.fromRGB(128,0,255)},
            {Color3.fromRGB(0,255,0), Color3.fromRGB(0,255,255)},
            {Color3.fromRGB(255,0,0), Color3.fromRGB(255,255,0)},
            {Color3.fromRGB(212,175,55), Color3.fromRGB(192,192,192)},
            {Color3.fromRGB(128,0,255), Color3.fromRGB(255,128,0)},
            {Color3.fromRGB(0,0,255), Color3.fromRGB(255,0,0)},
            {Color3.fromRGB(255,105,180), Color3.fromRGB(255,215,0)},
            {Color3.fromRGB(255,255,255), Color3.fromRGB(0,0,0)},
            {Color3.fromRGB(255,255,0), Color3.fromRGB(0,255,255)},
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
            {Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0)}
        }

        local inicial = colors[#colors]
        AtualizarCorInterface(inicial[1], inicial[1], inicial[2])

        local function createColorBox(titleText, labelText, mode)
            local box = Instance.new("Frame")
            box.Size = UDim2.new(0.5, -15, 0, 0)
            box.BackgroundColor3 = Palette.Surface
            box.BorderSizePixel = 0
            box.AutomaticSize = Enum.AutomaticSize.Y
            box.ClipsDescendants = true
            box.Parent = container

            addCorner(box, UDim.new(0, 12))
            local stroke = addStroke(box, Color3.fromRGB(80, 10, 10), 1.5, 0.3)

            local titleLabel = Instance.new("TextLabel", box)
            titleLabel.Text = titleText
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextSize = 15
            titleLabel.TextColor3 = Palette.Text
            titleLabel.BackgroundTransparency = 1
            titleLabel.Size = UDim2.new(1, -20, 0, 26)
            titleLabel.Position = UDim2.new(0, 10, 0, 10)
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left

            local label = Instance.new("TextLabel", box)
            label.Text = labelText
            label.Font = Enum.Font.Gotham
            label.TextSize = 12
            label.TextColor3 = Palette.TextMuted
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
                    ColorSequenceKeypoint.new(1, pair[2])
                }

                local button = Instance.new("TextButton", square)
                button.BackgroundTransparency = 1
                button.Size = UDim2.new(1, 0, 1, 0)
                button.Text = ""
                button.AutoButtonColor = false

                button.MouseEnter:Connect(function()
                    tween(square, TweenInfo.new(0.2, Enum.EasingStyle.Back), { Size = UDim2.new(0, 40, 0, 40) })
                    tween(s, TweenInfo.new(0.2), { Color = Palette.AccentBright, Transparency = 0 })
                end)
                button.MouseLeave:Connect(function()
                    tween(square, TweenInfo.new(0.2, Enum.EasingStyle.Back), { Size = UDim2.new(0, 36, 0, 36) })
                    tween(s, TweenInfo.new(0.2), { Color = Color3.fromRGB(60, 0, 0), Transparency = 0.4 })
                end)

                button.MouseButton1Click:Connect(function()
                    playSound(SOUNDS.Click, 0.25)
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
            colorInputBox.BackgroundColor3 = Palette.SurfaceHi
            colorInputBox.TextColor3 = Palette.Text
            colorInputBox.TextSize = 12
            colorInputBox.PlaceholderText = "(ex: 255.0.0/0.0.0)"
            colorInputBox.PlaceholderColor3 = Palette.TextMuted
            colorInputBox.ClearTextOnFocus = false
            colorInputBox.Position = UDim2.new(0, 10, 0, 0)
            colorInputBox.LayoutOrder = 999
            addCorner(colorInputBox, UDim.new(0, 6))
            addStroke(colorInputBox, Palette.Border, 1, 0.5)

            local layoutForInput = Instance.new("UIListLayout", box)
            layoutForInput.SortOrder = Enum.SortOrder.LayoutOrder
            layoutForInput.Padding = UDim.new(0, 10)

            colorInputBox.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    local colorText = colorInputBox.Text
                    local colorsInput = string.split(colorText, "/")
                    if #colorsInput == 2 then
                        local c1 = string.split(colorsInput[1], ".")
                        local c2 = string.split(colorsInput[2], ".")
                        if #c1 == 3 and #c2 == 3 then
                            local r1, g1, b1 = tonumber(c1[1]), tonumber(c1[2]), tonumber(c1[3])
                            local r2, g2, b2 = tonumber(c2[1]), tonumber(c2[2]), tonumber(c2[3])
                            if r1 and g1 and b1 and r2 and g2 and b2 then
                                local nc1 = Color3.fromRGB(r1, g1, b1)
                                local nc2 = Color3.fromRGB(r2, g2, b2)
                                if mode == "interface" then
                                    AtualizarCorInterface(nc1, nc1, nc2)
                                elseif mode == "titulo" then
                                    title.TextColor3 = nc1
                                    subtitle.TextColor3 = nc2
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
        local tab = pages[tabName]; if not tab then return end

        local box = Instance.new("Frame", tab)
        box.Size = UDim2.new(1, -20, 0, 0)
        box.Position = UDim2.new(0, 10, 0, 0)
        box.BackgroundColor3 = Palette.Surface
        box.BorderSizePixel = 0
        box.AutomaticSize = Enum.AutomaticSize.Y
        box.ClipsDescendants = true
        addCorner(box, UDim.new(0, 12))
        addStroke(box, Color3.fromRGB(120, 0, 0), 1.5, 0.3)

        local titleLabel = Instance.new("TextLabel", box)
        titleLabel.Text = "  " .. string.upper(title or "INFORMAÇÃO")
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 16
        titleLabel.TextColor3 = Palette.Text
        titleLabel.BackgroundTransparency = 1
        titleLabel.Size = UDim2.new(1, -20, 0, 30)
        titleLabel.Position = UDim2.new(0, 10, 0, 10)
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.TextYAlignment = Enum.TextYAlignment.Center

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
            itemFrame.BackgroundColor3 = Palette.SurfaceHi
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
            numberLabel.TextColor3 = Palette.AccentBright
            numberLabel.BackgroundTransparency = 1
            numberLabel.Size = UDim2.new(0, 30, 1, 0)
            numberLabel.Position = UDim2.new(0, 10, 0, 0)
            numberLabel.TextXAlignment = Enum.TextXAlignment.Left
            numberLabel.TextYAlignment = Enum.TextYAlignment.Top

            local descLabel = Instance.new("TextLabel", itemFrame)
            descLabel.Text = text
            descLabel.Font = Enum.Font.Gotham
            descLabel.TextSize = 13
            descLabel.TextColor3 = Palette.Text
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
            ContentFrame = content
        }
    end

    -- ═══════════════════════════════════════════════════════════════
    -- HIDE / SHOW
    -- ═══════════════════════════════════════════════════════════════
    local isHidden = false

    hideButton.MouseButton1Click:Connect(function()
        playSound(SOUNDS.Click, 0.3)
        if not isHidden then
            tween(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 575, 0, 10),
                BackgroundTransparency = 0.4
            })
            task.delay(0.25, function()
                mainFrame.Visible = false
                mainFrame.Size = UDim2.new(0, 575, 0, 375)
                mainFrame.BackgroundTransparency = 0.03
                ballButton.Visible = true
                ballButton.Size = UDim2.new(0, 0, 0, 0)
                bounce(ballButton, { Size = UDim2.new(0, 50, 0, 50) })
                tween(ambientBlur, TweenInfo.new(0.4), { Size = 0 })
            end)
        end
        isHidden = true
    end)

    ballButton.MouseButton1Click:Connect(function()
        playSound(SOUNDS.Click, 0.3)
        tween(ballButton, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Size = UDim2.new(0, 0, 0, 0) })
        task.delay(0.2, function()
            ballButton.Visible = false
            ballButton.Size = UDim2.new(0, 50, 0, 50)
            mainFrame.Visible = true
            mainFrame.Size = UDim2.new(0, 575, 0, 10)
            mainFrame.BackgroundTransparency = 0.5
            bounce(mainFrame, {
                Size = UDim2.new(0, 575, 0, 375),
                BackgroundTransparency = 0.03
            })
            tween(ambientBlur, TweenInfo.new(0.5), { Size = 8 })
        end)
        isHidden = false
    end)

    return Window
end

return RANOX
