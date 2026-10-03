--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║                                                                  ║
    ║                        RANOX UI LIBRARY                          ║
    ║                         Version 2.0.0                            ║
    ║                                                                  ║
    ║              ✦ Glow Up Edition · 100% API Compatible ✦           ║
    ║                                                                  ║
    ╚══════════════════════════════════════════════════════════════════╝
--]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
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

-- ═══════════════════════════════════════════════════════════════════
-- CREATE WINDOW
-- ═══════════════════════════════════════════════════════════════════
function RANOX:CreateWindow(config)
    config = config or {}
    local Window = {}

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RANOX_UI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 99e99
    screenGui.Parent = game:GetService("CoreGui")

    local mainFrame = Instance.new("TextButton")
    mainFrame.Size = UDim2.new(0, 575, 0, 375)
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
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

    -- Borda com glow (substitui sombra bugada)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Transparency = 0.25
    stroke.Color = Palette.Accent
    stroke.Name = "MainStroke"
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = mainFrame

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

    -- Linha superior animada (accent que corre)
    local topGlow = Instance.new("Frame")
    topGlow.Size = UDim2.new(0, 100, 0, 2)
    topGlow.Position = UDim2.new(0, 0, 0, 0)
    topGlow.BackgroundColor3 = Palette.AccentBright
    topGlow.BorderSizePixel = 0
    topGlow.ZIndex = 5
    topGlow.Parent = mainFrame
    Instance.new("UICorner", topGlow).CornerRadius = UDim.new(0, 3)

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

    -- Subtítulo (posicionado depois do título)
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

    -- Botão esconder (minimizar)
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
    Instance.new("UICorner", hideButton).CornerRadius = UDim.new(0, 6)
    local hideStroke = Instance.new("UIStroke")
    hideStroke.Color = Palette.Border
    hideStroke.Thickness = 1
    hideStroke.Transparency = 0.4
    hideStroke.Parent = hideButton

    hideButton.MouseEnter:Connect(function()
        fast(hideButton, { BackgroundColor3 = Palette.AccentSoft, BackgroundTransparency = 0.1 })
        fast(hideStroke, { Color = Palette.Accent })
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
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 6)

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
    Instance.new("UICorner", tabIndicator).CornerRadius = UDim.new(0, 6)
    local indStroke = Instance.new("UIStroke", tabIndicator)
    indStroke.Color = Palette.Accent
    indStroke.Thickness = 1.2
    indStroke.Transparency = 0.3

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
    ballButton.Size = UDim2.new(0.05, 0, 0.1, 0)
    ballButton.Position = UDim2.new(0.1, 0, 0.9, -150)
    ballButton.AnchorPoint = Vector2.new(0.5, 0.5)
    ballButton.BackgroundColor3 = Palette.Accent
    ballButton.Image = "rbxassetid://6337069410"
    ballButton.BackgroundTransparency = 0
    ballButton.Visible = false
    ballButton.Active = true
    ballButton.Draggable = true
    ballButton.Parent = screenGui

    local ballCorner = Instance.new("UICorner")
    ballCorner.CornerRadius = UDim.new(0.5, 0)
    ballCorner.Parent = ballButton

    local ballStroke = Instance.new("UIStroke", ballButton)
    ballStroke.Color = Palette.AccentBright
    ballStroke.Thickness = 2
    ballStroke.Transparency = 0.2

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
            if marker then
                marker.Visible = (tabName == name)
            end
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

        local uiCorner = Instance.new("UICorner", tabBtn)
        uiCorner.CornerRadius = UDim.new(0, 6)

        local uiStroke = Instance.new("UIStroke", tabBtn)
        uiStroke.Thickness = 1
        uiStroke.Color = Palette.Border
        uiStroke.Transparency = 1

        local marker = Instance.new("Frame", tabBtn)
        marker.Name = "TabMarker"
        marker.Size = UDim2.new(0, 3, 1, -10)
        marker.Position = UDim2.new(0, 0, 0, 5)
        marker.BackgroundColor3 = Palette.AccentBright
        marker.BorderSizePixel = 0
        marker.Visible = false
        Instance.new("UICorner", marker).CornerRadius = UDim.new(0, 3)

        local label = Instance.new("TextLabel", tabBtn)
        label.BackgroundTransparency = 1
        label.Text = tabName
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 12
        label.TextColor3 = Palette.TextDim
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextWrapped = false
        label.TextTruncate = Enum.TextTruncate.AtEnd
        label.ZIndex = 3

        if iconId then
            local icon = Instance.new("ImageLabel", tabBtn)
            icon.Name = "TabIcon"
            icon.Size = UDim2.new(0, 16, 0, 16)
            icon.Position = UDim2.new(0, 8, 0.5, -8)
            icon.BackgroundTransparency = 1
            icon.Image = "rbxassetid://" .. tostring(iconId)
            icon.ImageColor3 = Palette.TextMute
            icon.ZIndex = 3
            label.Position = UDim2.new(0, 30, 0, 0)
            label.Size = UDim2.new(1, -34, 1, 0)
        else
            label.Position = UDim2.new(0, 12, 0, 0)
            label.Size = UDim2.new(1, -16, 1, 0)
        end

        tabButtons[tabName] = tabBtn

        tabBtn.MouseEnter:Connect(function()
            if selectedTab ~= tabName then
                fast(tabBtn, { BackgroundTransparency = 0.6, BackgroundColor3 = Palette.SurfaceHi })
                fast(uiStroke, { Transparency = 0.7, Color = Palette.Border })
            end
        end)

        tabBtn.MouseLeave:Connect(function()
            if selectedTab ~= tabName then
                fast(tabBtn, { BackgroundTransparency = 1 })
                fast(uiStroke, { Transparency = 1 })
            end
        end)

        local tabPage = Instance.new("Frame", scrollHolder)
        tabPage.Name = tabName
        tabPage.Size = UDim2.new(1, 0, 0, 0)
        tabPage.BackgroundTransparency = 1
        tabPage.Visible = false
        tabPage.AutomaticSize = Enum.AutomaticSize.Y

        local layout = Instance.new("UIListLayout", tabPage)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)

        pages[tabName] = tabPage

        tabBtn.MouseButton1Click:Connect(function()
            -- Animação do indicador
            tabIndicator.Visible = true
            smooth(tabIndicator, {
                Position = UDim2.new(0, 5, 0, tabBtn.AbsolutePosition.Y - sidebar.AbsolutePosition.Y + sidebar.CanvasPosition.Y),
            }, 0.28)

            for name, button in pairs(tabButtons) do
                local btnStroke = button:FindFirstChildOfClass("UIStroke")
                if name == tabName then
                    fast(button, { BackgroundTransparency = 0.1, BackgroundColor3 = Palette.Surface })
                    if btnStroke then fast(btnStroke, { Transparency = 0.5 }) end
                    -- Pequeno bounce no botão ativo
                    tween(button, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, -2, 0, 35)
                    })
                    task.delay(0.15, function()
                        tween(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            Size = UDim2.new(1, -2, 0, 33)
                        })
                    end)
                    button.TabMarker.Visible = true
                else
                    fast(button, { BackgroundTransparency = 1 })
                    if btnStroke then fast(btnStroke, { Transparency = 1 }) end
                    button.TabMarker.Visible = false
                end
            end
            switchTab(tabName)
        end)

        if not selectedTab then
            task.defer(function()
                task.wait(0.1)
                tabBtn.MouseButton1Click:Fire()
            end)
        end
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE BUTTON
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateButton(tabName, text, callback)
        local tab = pages[tabName]
        if not tab then return end

        local btn = Instance.new("TextButton", tab)
        btn.Size = UDim2.new(1, -20, 0, 30)
        btn.Position = UDim2.new(0, 10, 0, 0)
        btn.Text = text
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 14
        btn.TextColor3 = Palette.Text
        btn.BackgroundColor3 = Palette.Surface
        btn.AutoButtonColor = false
        btn.ClipsDescendants = true
        btn.TextWrapped = false
        btn.TextTruncate = Enum.TextTruncate.AtEnd
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local bStroke = Instance.new("UIStroke", btn)
        bStroke.Color = Palette.Border
        bStroke.Thickness = 1
        bStroke.Transparency = 0.4

        -- Barra de accent esquerda
        local accentBar = Instance.new("Frame", btn)
        accentBar.Size = UDim2.new(0, 3, 0, 16)
        accentBar.Position = UDim2.new(0, 8, 0.5, -8)
        accentBar.BackgroundColor3 = Palette.Accent
        accentBar.BorderSizePixel = 0
        Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 2)

        btn.MouseEnter:Connect(function()
            fast(btn, { BackgroundColor3 = Palette.SurfaceHi })
            fast(bStroke, { Color = Palette.Accent, Transparency = 0.2 })
            smooth(accentBar, { Size = UDim2.new(0, 5, 0, 22) }, 0.2)
        end)

        btn.MouseLeave:Connect(function()
            fast(btn, { BackgroundColor3 = Palette.Surface })
            fast(bStroke, { Color = Palette.Border, Transparency = 0.4 })
            smooth(accentBar, { Size = UDim2.new(0, 3, 0, 16) }, 0.2)
        end)

        btn.MouseButton1Click:Connect(function()
            pcall(callback)
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
        checkboxFrame.Size = UDim2.new(1, -20, 0, 43)
        checkboxFrame.BackgroundColor3 = Palette.Surface
        checkboxFrame.BorderSizePixel = 0
        checkboxFrame.ClipsDescendants = true
        checkboxFrame.LayoutOrder = checkboxConfig.Order or 0
        Instance.new("UICorner", checkboxFrame).CornerRadius = UDim.new(0, 8)
        local cfStroke = Instance.new("UIStroke", checkboxFrame)
        cfStroke.Color = Palette.Border
        cfStroke.Thickness = 1
        cfStroke.Transparency = 0.4

        local title = Instance.new("TextLabel", checkboxFrame)
        title.Text = checkboxConfig.Text or "Checkbox"
        title.TextColor3 = Palette.Text
        title.Font = Enum.Font.GothamSemibold
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextYAlignment = Enum.TextYAlignment.Top
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1, -44, 0, 14)
        title.Position = UDim2.new(0, 10, 0, 4)

        local description = Instance.new("TextLabel", checkboxFrame)
        description.Text = checkboxConfig.Description or ""
        description.TextColor3 = Palette.TextDim
        description.Font = Enum.Font.Gotham
        description.TextSize = 12
        description.TextXAlignment = Enum.TextXAlignment.Left
        description.TextYAlignment = Enum.TextYAlignment.Top
        description.BackgroundTransparency = 1
        description.Size = UDim2.new(1, -44, 0, 12)
        description.Position = UDim2.new(0, 10, 0, 22)

        local box = Instance.new("Frame", checkboxFrame)
        box.Size = UDim2.new(0, 24, 0, 24)
        box.Position = UDim2.new(1, -34, 0.5, -12)
        box.BackgroundColor3 = Palette.SurfaceHi
        box.BorderSizePixel = 0
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
        local stroke = Instance.new("UIStroke", box)
        stroke.Color = Palette.Border
        stroke.Thickness = 1.3

        local checkmark = Instance.new("TextLabel", box)
        checkmark.Size = UDim2.new(1, -6, 1, -6)
        checkmark.Position = UDim2.new(0, 3, 0, 3)
        checkmark.Text = "✔"
        checkmark.TextColor3 = Color3.new(1, 1, 1)
        checkmark.TextScaled = true
        checkmark.BackgroundTransparency = 1
        checkmark.Visible = false

        local button = Instance.new("TextButton", checkboxFrame)
        button.Size = UDim2.new(1, 0, 1, 0)
        button.Position = UDim2.new(0, 0, 0, 0)
        button.BackgroundTransparency = 1
        button.Text = ""
        button.AutoButtonColor = false

        local toggled = false
        local running = false

        button.MouseButton1Click:Connect(function()
            toggled = not toggled
            checkmark.Visible = toggled

            if toggled then
                fast(box, { BackgroundColor3 = Palette.Accent })
                fast(stroke, { Color = Palette.AccentBright })
                -- Bounce suave
                bounce(box, { Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -35, 0.5, -13) })
                task.delay(0.18, function()
                    fast(box, { Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -34, 0.5, -12) })
                end)
                running = true
                task.spawn(function()
                    while running and toggled do
                        if checkboxConfig.Callback then
                            pcall(checkboxConfig.Callback, true)
                        end
                        task.wait()
                    end
                end)
            else
                fast(box, { BackgroundColor3 = Palette.SurfaceHi })
                fast(stroke, { Color = Palette.Border })
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
        toggleFrame.Size = UDim2.new(1, -20, 0, 45)
        toggleFrame.Position = UDim2.new(0, 10, 0, 0)
        toggleFrame.BackgroundColor3 = Palette.Surface
        toggleFrame.BackgroundTransparency = 0
        toggleFrame.ClipsDescendants = true
        toggleFrame.BorderSizePixel = 0
        Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 8)
        local tfStroke = Instance.new("UIStroke", toggleFrame)
        tfStroke.Color = Palette.Border
        tfStroke.Thickness = 1
        tfStroke.Transparency = 0.4

        local title = Instance.new("TextLabel", toggleFrame)
        title.Text = toggleConfig.Text or "Toggle"
        title.TextColor3 = Palette.Text
        title.Font = Enum.Font.GothamSemibold
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextYAlignment = Enum.TextYAlignment.Top
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1, -70, 0, 14)
        title.Position = UDim2.new(0, 12, 0, 6)

        local description = Instance.new("TextLabel", toggleFrame)
        description.Text = toggleConfig.Description or ""
        description.TextColor3 = Palette.TextDim
        description.Font = Enum.Font.Gotham
        description.TextSize = 12
        description.TextXAlignment = Enum.TextXAlignment.Left
        description.TextYAlignment = Enum.TextYAlignment.Top
        description.BackgroundTransparency = 1
        description.Size = UDim2.new(1, -70, 0, 12)
        description.Position = UDim2.new(0, 12, 0, 24)

        local switch = Instance.new("Frame", toggleFrame)
        switch.Size = UDim2.new(0, 40, 0, 22)
        switch.Position = UDim2.new(1, -50, 0.5, -11)
        switch.BackgroundColor3 = Palette.SurfaceHi
        switch.BorderSizePixel = 0
        Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)
        local swStroke = Instance.new("UIStroke", switch)
        swStroke.Color = Palette.Border
        swStroke.Thickness = 1
        swStroke.Transparency = 0.3

        local ball = Instance.new("Frame", switch)
        ball.Size = UDim2.new(0, 16, 0, 16)
        ball.Position = UDim2.new(0, 3, 0.5, -8)
        ball.BackgroundColor3 = Palette.TextDim
        ball.BorderSizePixel = 0
        Instance.new("UICorner", ball).CornerRadius = UDim.new(1, 0)

        local toggleButton = Instance.new("TextButton", switch)
        toggleButton.Size = UDim2.new(1, 0, 1, 0)
        toggleButton.Position = UDim2.new(0, 0, 0, 0)
        toggleButton.BackgroundTransparency = 1
        toggleButton.Text = ""
        toggleButton.AutoButtonColor = false

        local isOn = false

        toggleButton.MouseButton1Click:Connect(function()
            isOn = not isOn

            if isOn then
                fast(switch, { BackgroundColor3 = Palette.Accent })
                fast(swStroke, { Color = Palette.AccentBright, Transparency = 0.1 })
                tween(ball, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = UDim2.new(1, -19, 0.5, -8),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                })
            else
                fast(switch, { BackgroundColor3 = Palette.SurfaceHi })
                fast(swStroke, { Color = Palette.Border, Transparency = 0.3 })
                tween(ball, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 3, 0.5, -8),
                    BackgroundColor3 = Palette.TextDim,
                })
            end

            if toggleConfig.Callback then
                pcall(toggleConfig.Callback, isOn)
            end
        end)

        -- Hover do frame inteiro também ativa
        toggleFrame.MouseEnter:Connect(function()
            fast(tfStroke, { Color = Palette.Border, Transparency = 0.1 })
        end)
        toggleFrame.MouseLeave:Connect(function()
            fast(tfStroke, { Color = Palette.Border, Transparency = 0.4 })
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
        label.TextColor3 = Palette.Text
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Center

        local underline = Instance.new("Frame", label)
        underline.Size = UDim2.new(1, -20, 0, 1)
        underline.Position = UDim2.new(0, 10, 1, -3)
        underline.BackgroundColor3 = Palette.Accent
        underline.BackgroundTransparency = 0.5
        underline.BorderSizePixel = 0
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
        dropdownFrame.BackgroundColor3 = Palette.Surface
        dropdownFrame.BorderSizePixel = 0
        dropdownFrame.ZIndex = 2
        Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 8)
        local dfStroke = Instance.new("UIStroke", dropdownFrame)
        dfStroke.Color = Palette.Border
        dfStroke.Thickness = 1
        dfStroke.Transparency = 0.4

        local title = Instance.new("TextLabel", dropdownFrame)
        title.BackgroundTransparency = 1
        title.Text = dropdownConfig.Text or "Selecione..."
        title.TextColor3 = Palette.TextDim
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
        arrowIcon.TextColor3 = Palette.TextDim
        arrowIcon.Font = Enum.Font.GothamBold
        arrowIcon.TextSize = 16
        arrowIcon.ZIndex = 3

        local selectedLabel = Instance.new("TextLabel", dropdownFrame)
        selectedLabel.BackgroundTransparency = 1
        selectedLabel.Text = dropdownConfig.Default or "None"
        selectedLabel.TextColor3 = Palette.Text
        selectedLabel.Font = Enum.Font.GothamBold
        selectedLabel.TextSize = 14
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
        dropdownList.Position = UDim2.new(0, 10, 0, dropdownFrame.Position.Y.Offset + 45)
        dropdownList.BackgroundColor3 = Palette.Bg
        dropdownList.Visible = false
        dropdownList.ClipsDescendants = true
        dropdownList.ZIndex = 5
        Instance.new("UICorner", dropdownList).CornerRadius = UDim.new(0, 8)
        local dlStroke = Instance.new("UIStroke", dropdownList)
        dlStroke.Color = Palette.Accent
        dlStroke.Thickness = 1.2
        dlStroke.Transparency = 0.3

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
            dropdownList.Visible = true
            local targetHeight = isOpen and (#(dropdownConfig.Options or {}) * 34 + 8) or 0
            arrowIcon.Text = isOpen and "˄" or "˅"
            tween(dropdownList, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                Size = UDim2.new(1, -20, 0, targetHeight)
            })
            fast(dfStroke, { Color = isOpen and Palette.Accent or Palette.Border })
            if not isOpen then
                task.delay(0.25, function()
                    dropdownList.Visible = false
                end)
            end
        end)

        for _, option in ipairs(dropdownConfig.Options or {}) do
            local optBtn = Instance.new("TextButton", dropdownList)
            optBtn.Size = UDim2.new(1, 0, 0, 34)
            optBtn.Text = option
            optBtn.BackgroundColor3 = Palette.Surface
            optBtn.BackgroundTransparency = 0.4
            optBtn.TextColor3 = Palette.Text
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextSize = 13
            optBtn.AutoButtonColor = false
            optBtn.BorderSizePixel = 0
            optBtn.ZIndex = 6
            Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 6)

            optBtn.MouseEnter:Connect(function()
                fast(optBtn, { BackgroundColor3 = Palette.Accent, BackgroundTransparency = 0.2 })
            end)
            optBtn.MouseLeave:Connect(function()
                fast(optBtn, { BackgroundColor3 = Palette.Surface, BackgroundTransparency = 0.4 })
            end)

            optBtn.MouseButton1Click:Connect(function()
                updateSelectedLabelText(option)
                if dropdownConfig.Callback then
                    pcall(dropdownConfig.Callback, option)
                end
                isOpen = false
                arrowIcon.Text = "˅"
                tween(dropdownList, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                    Size = UDim2.new(1, -20, 0, 0)
                })
                fast(dfStroke, { Color = Palette.Border })
                task.delay(0.25, function()
                    dropdownList.Visible = false
                end)
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
        bg.Size = UDim2.new(1, 0, 0, 56)
        bg.BackgroundColor3 = Palette.Surface
        bg.BorderSizePixel = 0
        bg.ZIndex = 2
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 8)

        local border = Instance.new("UIStroke", bg)
        border.Color = Palette.Border
        border.Thickness = 1
        border.Transparency = 0.4

        local title = Instance.new("TextLabel", bg)
        title.Size = UDim2.new(1, -60, 0, 16)
        title.Position = UDim2.new(0, 10, 0, 4)
        title.Text = sliderConfig.Text or "Slider"
        title.TextColor3 = Palette.Text
        title.TextSize = 14
        title.Font = Enum.Font.GothamSemibold
        title.BackgroundTransparency = 1
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 3
        title.TextYAlignment = Enum.TextYAlignment.Center

        local desc = Instance.new("TextLabel", bg)
        desc.Size = UDim2.new(1, -20, 0, 11)
        desc.Position = UDim2.new(0, 10, 0, 22)
        desc.Text = sliderConfig.Description or ""
        desc.TextColor3 = Palette.TextDim
        desc.TextSize = 12
        desc.Font = Enum.Font.Gotham
        desc.BackgroundTransparency = 1
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.ZIndex = 3
        desc.TextYAlignment = Enum.TextYAlignment.Center

        local valueLabel = Instance.new("TextLabel", bg)
        valueLabel.Size = UDim2.new(0, 50, 0, 16)
        valueLabel.Position = UDim2.new(1, -60, 0, 4)
        valueLabel.TextColor3 = Palette.AccentBright
        valueLabel.TextSize = 14
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.BackgroundTransparency = 1
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.ZIndex = 3
        valueLabel.TextYAlignment = Enum.TextYAlignment.Center

        local bar = Instance.new("Frame", bg)
        bar.Size = UDim2.new(1, -20, 0, 6)
        bar.Position = UDim2.new(0, 10, 0, 45)
        bar.BackgroundColor3 = Palette.SurfaceHi
        bar.BorderSizePixel = 0
        bar.ZIndex = 2
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = Palette.Accent
        fill.BorderSizePixel = 0
        fill.ZIndex = 3
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local fillGradient = Instance.new("UIGradient", fill)
        fillGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Palette.Accent),
            ColorSequenceKeypoint.new(1, Palette.AccentBright),
        }

        local neonStroke = Instance.new("UIStroke", fill)
        neonStroke.Thickness = 2
        neonStroke.Transparency = 0.5
        neonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        neonStroke.Color = Palette.AccentBright

        local knob = Instance.new("Frame", bar)
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = UDim2.new(0, -8, 0.5, -8)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        knob.BorderSizePixel = 0
        knob.ZIndex = 4
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        local knobStroke = Instance.new("UIStroke", knob)
        knobStroke.Color = Palette.Accent
        knobStroke.Transparency = 0.2
        knobStroke.Thickness = 2

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
            tween(fill, TweenInfo.new(0.1, Enum.EasingStyle.Quad), { Size = UDim2.new(clamped, 0, 1, 0) })
            tween(knob, TweenInfo.new(0.1, Enum.EasingStyle.Quad), { Position = UDim2.new(clamped, -8, 0.5, -8) })
            valueLabel.Text = tostring(roundedValue)
            if sliderConfig.Callback then
                pcall(sliderConfig.Callback, roundedValue)
            end
        end

        local dragging = false
        local userInput = game:GetService("UserInputService")

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateSlider(input.Position.X)
                smooth(knobStroke, { Thickness = 3, Transparency = 0 }, 0.15)
            end
        end)

        userInput.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input.Position.X)
            end
        end)

        userInput.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                smooth(knobStroke, { Thickness = 2, Transparency = 0.2 }, 0.15)
            end
        end)

        updateSlider(bar.AbsolutePosition.X)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CREATE TEXTBOX
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
        background.Position = UDim2.new(0, 0, 0, 0)
        background.BackgroundColor3 = Palette.Surface
        background.BorderSizePixel = 0
        background.ZIndex = 1
        Instance.new("UICorner", background).CornerRadius = UDim.new(0, 6)
        local bgStroke = Instance.new("UIStroke", background)
        bgStroke.Color = Palette.Border
        bgStroke.Thickness = 1
        bgStroke.Transparency = 0.4

        local highlight = Instance.new("Frame", background)
        highlight.Size = UDim2.new(1, 0, 0, 2)
        highlight.Position = UDim2.new(0, 0, 1, -2)
        highlight.BackgroundColor3 = Palette.Accent
        highlight.BackgroundTransparency = 0.5
        highlight.BorderSizePixel = 0
        highlight.Visible = false
        highlight.ZIndex = 2
        Instance.new("UICorner", highlight).CornerRadius = UDim.new(0, 2)

        -- Animação suave do highlight
        task.spawn(function()
            local increasing = true
            local i = 0
            while highlight.Parent do
                if highlight.Visible then
                    if increasing then
                        i = math.min(1, i + 0.05)
                    else
                        i = math.max(0, i - 0.05)
                    end
                    if i >= 1 then increasing = false end
                    if i <= 0 then increasing = true end
                    highlight.BackgroundTransparency = 0.2 + (0.6 * i)
                end
                task.wait(0.03)
            end
        end)

        local placeholder = Instance.new("TextLabel", background)
        placeholder.Size = UDim2.new(1, -20, 0, 14)
        placeholder.Position = UDim2.new(0, 10, 0.5, -7)
        placeholder.BackgroundTransparency = 1
        placeholder.Text = placeholderText or "Escreva aqui"
        placeholder.TextColor3 = Palette.TextMute
        placeholder.Font = Enum.Font.Gotham
        placeholder.TextSize = 14
        placeholder.TextXAlignment = Enum.TextXAlignment.Left
        placeholder.ZIndex = 2

        local textBox = Instance.new("TextBox", background)
        textBox.Size = UDim2.new(1, -20, 1, 0)
        textBox.Position = UDim2.new(0, 10, 0, 0)
        textBox.BackgroundTransparency = 1
        textBox.Text = ""
        textBox.PlaceholderText = ""
        textBox.TextColor3 = Palette.Text
        textBox.Font = Enum.Font.Gotham
        textBox.TextSize = 14
        textBox.ClearTextOnFocus = false
        textBox.TextXAlignment = Enum.TextXAlignment.Left
        textBox.TextWrapped = false
        textBox.TextTruncate = Enum.TextTruncate.AtEnd
        textBox.ZIndex = 3

        textBox.Focused:Connect(function()
            highlight.Visible = true
            fast(bgStroke, { Color = Palette.Accent, Transparency = 0.1 })
            smooth(placeholder, { Position = UDim2.new(0, 10, 0, -8), Size = UDim2.new(1, -20, 0, 0) }, 0.2)
            task.delay(0.2, function()
                if textBox:IsFocused() then
                    placeholder.Visible = false
                end
            end)
        end)

        textBox.FocusLost:Connect(function(enterPressed)
            highlight.Visible = false
            fast(bgStroke, { Color = Palette.Border, Transparency = 0.4 })
            if textBox.Text == "" then
                placeholder.Visible = true
                smooth(placeholder, { Position = UDim2.new(0, 10, 0.5, -7), Size = UDim2.new(1, -20, 0, 14) }, 0.2)
            end
            if enterPressed and callback then
                pcall(callback, textBox.Text)
            end
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
        pickerFrame.Size = UDim2.new(1, -20, 0, 180)
        pickerFrame.Position = UDim2.new(0, 10, 0, 0)
        pickerFrame.BackgroundColor3 = Palette.Surface
        pickerFrame.ClipsDescendants = true
        pickerFrame.BorderSizePixel = 0
        Instance.new("UICorner", pickerFrame).CornerRadius = UDim.new(0, 10)
        local pfStroke = Instance.new("UIStroke", pickerFrame)
        pfStroke.Color = Palette.Border
        pfStroke.Thickness = 1
        pfStroke.Transparency = 0.4

        local toggleButton = Instance.new("TextButton", pickerFrame)
        toggleButton.Size = UDim2.new(0, 20, 0, 20)
        toggleButton.Position = UDim2.new(1, -30, 0, 5)
        toggleButton.BackgroundTransparency = 1
        toggleButton.Text = "▼"
        toggleButton.TextColor3 = Palette.TextDim
        toggleButton.Font = Enum.Font.GothamBold
        toggleButton.TextSize = 16

        local label = Instance.new("TextLabel", pickerFrame)
        label.Size = UDim2.new(1, -60, 0, 26)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = colorConfig.Text or "Escolha uma cor"
        label.TextColor3 = Palette.Text
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left

        local container = Instance.new("Frame", pickerFrame)
        container.Size = UDim2.new(1, 0, 0, 150)
        container.Position = UDim2.new(0, 0, 0, 30)
        container.BackgroundTransparency = 1
        container.Name = "Container"

        local colorDisplay = Instance.new("Frame", container)
        colorDisplay.Size = UDim2.new(1, -20, 0, 30)
        colorDisplay.Position = UDim2.new(0, 10, 0, 0)
        colorDisplay.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        Instance.new("UICorner", colorDisplay).CornerRadius = UDim.new(0, 10)
        local cdStroke = Instance.new("UIStroke", colorDisplay)
        cdStroke.Color = Palette.Accent
        cdStroke.Thickness = 1.5
        cdStroke.Transparency = 0.3

        local function createGradientBar(parent, position, height, colorType)
            local bar = Instance.new("TextButton", parent)
            bar.Size = UDim2.new(0.7, 0, 0, height)
            bar.Position = position
            bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            bar.AutoButtonColor = false
            bar.Text = ""
            bar.BorderSizePixel = 0
            Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 10)

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

        local hueSlider = createGradientBar(container, UDim2.new(0, 10, 0, 40), 20, "Hue")
        local brightnessSlider = createGradientBar(container, UDim2.new(0, 10, 0, 70), 20, "Brightness")

        local hueMarker = Instance.new("Frame", hueSlider)
        hueMarker.Size = UDim2.new(0, 6, 0, 26)
        hueMarker.AnchorPoint = Vector2.new(0.5, 0.5)
        hueMarker.Position = UDim2.new(0, 0, 0.5, 0)
        hueMarker.BackgroundColor3 = Color3.new(1, 1, 1)
        hueMarker.BorderSizePixel = 0
        Instance.new("UICorner", hueMarker).CornerRadius = UDim.new(1, 0)
        local hmStroke = Instance.new("UIStroke", hueMarker)
        hmStroke.Color = Palette.Bg
        hmStroke.Thickness = 1.5

        local brightnessMarker = Instance.new("Frame", brightnessSlider)
        brightnessMarker.Size = UDim2.new(0, 6, 0, 26)
        brightnessMarker.AnchorPoint = Vector2.new(0.5, 0.5)
        brightnessMarker.Position = UDim2.new(1, 0, 0.5, 0)
        brightnessMarker.BackgroundColor3 = Color3.new(1, 1, 1)
        brightnessMarker.BorderSizePixel = 0
        Instance.new("UICorner", brightnessMarker).CornerRadius = UDim.new(1, 0)
        local bmStroke = Instance.new("UIStroke", brightnessMarker)
        bmStroke.Color = Palette.Bg
        bmStroke.Thickness = 1.5

        local rgbBox = Instance.new("TextBox", container)
        rgbBox.Size = UDim2.new(0.25, 0, 0, 20)
        rgbBox.Position = UDim2.new(0.75, 15, 0, 40)
        rgbBox.BackgroundColor3 = Palette.Bg
        rgbBox.TextColor3 = Palette.Text
        rgbBox.Font = Enum.Font.Gotham
        rgbBox.TextSize = 12
        rgbBox.Text = "0.255.255"
        rgbBox.BorderSizePixel = 0
        Instance.new("UICorner", rgbBox).CornerRadius = UDim.new(0, 6)
        local rbStroke = Instance.new("UIStroke", rgbBox)
        rbStroke.Color = Palette.Border
        rbStroke.Thickness = 1
        rbStroke.Transparency = 0.4

        local brightnessBox = Instance.new("TextBox", container)
        brightnessBox.Size = UDim2.new(0.25, 0, 0, 20)
        brightnessBox.Position = UDim2.new(0.75, 15, 0, 70)
        brightnessBox.BackgroundColor3 = Palette.Bg
        brightnessBox.TextColor3 = Palette.Text
        brightnessBox.Font = Enum.Font.Gotham
        brightnessBox.TextSize = 12
        brightnessBox.Text = "255"
        brightnessBox.BorderSizePixel = 0
        Instance.new("UICorner", brightnessBox).CornerRadius = UDim.new(0, 6)
        local bbStroke = Instance.new("UIStroke", brightnessBox)
        bbStroke.Color = Palette.Border
        bbStroke.Thickness = 1
        bbStroke.Transparency = 0.4

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
                fast(colorDisplay, { BackgroundColor3 = adjusted })
                if colorConfig.Callback then
                    pcall(colorConfig.Callback, adjusted)
                end
            end
        end

        local UserInputService = game:GetService("UserInputService")

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
            toggleButton.Text = opened and "▼" or "▲"
            local goalSize = opened and 180 or 30
            local goalContentSize = opened and 150 or 0
            tween(pickerFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { Size = UDim2.new(1, -20, 0, goalSize) })
            tween(container, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { Size = UDim2.new(1, 0, 0, goalContentSize) })
        end)

        applyColorFromBox()

        local randomColorToggle = Instance.new("TextButton", container)
        randomColorToggle.Size = UDim2.new(1, -20, 0, 26)
        randomColorToggle.Position = UDim2.new(0, 10, 0, 100)
        randomColorToggle.BackgroundColor3 = Palette.Bg
        randomColorToggle.Text = "COR RGB ALEATÓRIA [DESATIVADO]"
        randomColorToggle.TextColor3 = Palette.Text
        randomColorToggle.Font = Enum.Font.GothamSemibold
        randomColorToggle.TextSize = 12
        randomColorToggle.AutoButtonColor = false
        randomColorToggle.BorderSizePixel = 0
        Instance.new("UICorner", randomColorToggle).CornerRadius = UDim.new(0, 6)
        local rcStroke = Instance.new("UIStroke", randomColorToggle)
        rcStroke.Color = Palette.Border
        rcStroke.Thickness = 1
        rcStroke.Transparency = 0.4

        randomColorToggle.MouseEnter:Connect(function()
            fast(rcStroke, { Color = Palette.Accent, Transparency = 0.2 })
        end)
        randomColorToggle.MouseLeave:Connect(function()
            fast(rcStroke, { Color = Palette.Border, Transparency = 0.4 })
        end)

        local randomColorEnabled = false

        task.spawn(function()
            while randomColorToggle.Parent do
                if randomColorEnabled then
                    local randomColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
                    tween(colorDisplay, TweenInfo.new(0.5), { BackgroundColor3 = randomColor })
                    if colorConfig.Callback then
                        pcall(colorConfig.Callback, randomColor)
                    end
                end
                task.wait(0.6)
            end
        end)

        randomColorToggle.MouseButton1Click:Connect(function()
            randomColorEnabled = not randomColorEnabled
            randomColorToggle.Text = randomColorEnabled and "COR RGB ALEATÓRIA [ATIVADO]" or "COR RGB ALEATÓRIA [DESATIVADO]"
            fast(rcStroke, { Color = randomColorEnabled and Palette.Success or Palette.Border })
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
        label.TextColor3 = Palette.Text
        label.TextSize = 15
        label.TextXAlignment = Enum.TextXAlignment.Left

        local switch = Instance.new("Frame", holder)
        switch.Size = UDim2.new(0, 60, 0, 26)
        switch.Position = UDim2.new(1, -65, 0.5, -13)
        switch.BackgroundColor3 = Palette.SurfaceHi
        switch.BorderSizePixel = 0
        switch.BackgroundTransparency = 0.05
        Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

        local glow = Instance.new("UIStroke", switch)
        glow.Thickness = 1.3
        glow.Color = Palette.AccentBright
        glow.Transparency = 1

        local circle = Instance.new("Frame", switch)
        circle.Size = UDim2.new(0, 22, 0, 22)
        circle.Position = UDim2.new(0, 3, 0.5, -11)
        circle.BackgroundColor3 = Palette.TextDim
        circle.BorderSizePixel = 0
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

        local stateLabel = Instance.new("TextLabel", holder)
        stateLabel.Size = UDim2.new(0, 40, 1, -10)
        stateLabel.Position = UDim2.new(1, -115, 0, 0)
        stateLabel.BackgroundTransparency = 1
        stateLabel.Font = Enum.Font.GothamBold
        stateLabel.TextSize = 13
        stateLabel.TextColor3 = Palette.Danger
        stateLabel.Text = "OFF"
        stateLabel.TextXAlignment = Enum.TextXAlignment.Right

        local underline = Instance.new("Frame", holder)
        underline.Size = UDim2.new(1, 0, 0, 1)
        underline.Position = UDim2.new(0, 0, 1, -3)
        underline.BackgroundColor3 = Palette.Border
        underline.BackgroundTransparency = 0.5
        underline.BorderSizePixel = 0

        local state = false

        local function toggleSwitch()
            state = not state
            local goalPos = state and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
            local bgColor = state and Palette.Accent or Palette.SurfaceHi
            local circleColor = state and Color3.new(1, 1, 1) or Palette.TextDim
            local textColor = state and Palette.Success or Palette.Danger
            local glowTrans = state and 0.15 or 1

            tween(circle, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = goalPos,
                BackgroundColor3 = circleColor,
            })
            fast(switch, { BackgroundColor3 = bgColor })
            fast(stateLabel, { TextColor3 = textColor })
            fast(glow, { Transparency = glowTrans })

            stateLabel.Text = state and "ON" or "OFF"

            if switchConfig.Callback then
                pcall(switchConfig.Callback, state)
            end
        end

        switch.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                toggleSwitch()
            end
        end)

        switch.MouseEnter:Connect(function()
            fast(glow, { Transparency = state and 0.1 or 0.5 })
        end)

        switch.MouseLeave:Connect(function()
            fast(glow, { Transparency = state and 0.15 or 1 })
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
        line.BackgroundColor3 = color or Palette.Border
        line.BackgroundTransparency = 0.4
        line.BorderSizePixel = 0
    end

    -- ═══════════════════════════════════════════════════════════════
    -- NOTIFY CUSTOM
    -- ═══════════════════════════════════════════════════════════════
    function Window:NotifyCustom(title, text, iconId)
        local notifyGui = Instance.new("ScreenGui")
        notifyGui.Name = "NotifyCustom"
        notifyGui.ResetOnSpawn = false
        notifyGui.IgnoreGuiInset = true
        notifyGui.DisplayOrder = 99999
        notifyGui.Parent = player:WaitForChild("PlayerGui")

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 280, 0, 85)
        frame.Position = UDim2.new(1, 320, 1, -110)
        frame.AnchorPoint = Vector2.new(1, 1)
        frame.BackgroundColor3 = Palette.Bg
        frame.BackgroundTransparency = 0.05
        frame.BorderSizePixel = 0
        frame.ZIndex = 999999
        frame.Parent = notifyGui
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

        local nStroke = Instance.new("UIStroke", frame)
        nStroke.Color = Palette.Accent
        nStroke.Thickness = 1.5
        nStroke.Transparency = 0.2

        -- Barra lateral colorida (substitui sombra)
        local sideBar = Instance.new("Frame", frame)
        sideBar.Size = UDim2.new(0, 4, 1, -20)
        sideBar.Position = UDim2.new(0, 0, 0.5, -((85-20)/2))
        sideBar.BackgroundColor3 = Palette.Accent
        sideBar.BorderSizePixel = 0
        sideBar.ZIndex = 999999
        Instance.new("UICorner", sideBar).CornerRadius = UDim.new(0, 3)

        local sideGrad = Instance.new("UIGradient", sideBar)
        sideGrad.Color = ColorSequence.new(Palette.Accent, Palette.AccentBright)
        sideGrad.Rotation = 90

        local icon = Instance.new("ImageLabel", frame)
        icon.Size = UDim2.new(0, 42, 0, 42)
        icon.Position = UDim2.new(0, 16, 0, 22)
        icon.Image = "rbxassetid://" .. tostring(iconId or 4483362458)
        icon.BackgroundTransparency = 1
        icon.ZIndex = 999999

        local titleLabel = Instance.new("TextLabel", frame)
        titleLabel.Size = UDim2.new(1, -80, 0, 22)
        titleLabel.Position = UDim2.new(0, 68, 0, 12)
        titleLabel.Text = title
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 14
        titleLabel.TextColor3 = Palette.Text
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.BackgroundTransparency = 1
        titleLabel.ZIndex = 999999

        local textLabel = Instance.new("TextLabel", frame)
        textLabel.Size = UDim2.new(1, -80, 0, 40)
        textLabel.Position = UDim2.new(0, 68, 0, 34)
        textLabel.Text = text
        textLabel.Font = Enum.Font.Gotham
        textLabel.TextSize = 12
        textLabel.TextColor3 = Palette.TextDim
        textLabel.TextWrapped = true
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextYAlignment = Enum.TextYAlignment.Top
        textLabel.BackgroundTransparency = 1
        textLabel.ZIndex = 999999

        -- Slide in
        tween(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -20, 1, -20)
        })

        task.delay(2.2, function()
            tween(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 320, 1, -110)
            })
            task.wait(0.4)
            notifyGui:Destroy()
        end)
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
        box.BackgroundColor3 = Palette.Surface
        box.BorderSizePixel = 0
        box.AutomaticSize = Enum.AutomaticSize.Y
        box.ClipsDescendants = true
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 12)
        local boxStroke = Instance.new("UIStroke", box)
        boxStroke.Color = Palette.Accent
        boxStroke.Thickness = 1.5
        boxStroke.Transparency = 0.3

        local icon = Instance.new("ImageLabel", box)
        icon.Size = UDim2.new(0, 90, 0, 90)
        icon.Position = UDim2.new(0, 10, 0, 10)
        icon.Image = "rbxassetid://" .. tostring(imageId)
        icon.BackgroundColor3 = Palette.Bg
        icon.BorderSizePixel = 0
        icon.ScaleType = Enum.ScaleType.Fit
        Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 8)
        local iconStroke = Instance.new("UIStroke", icon)
        iconStroke.Color = Palette.Accent
        iconStroke.Thickness = 1.5
        iconStroke.Transparency = 0.3

        local channelBox = Instance.new("TextBox", box)
        channelBox.Text = channelName or "SEU CANAL AQUI"
        channelBox.Size = UDim2.new(0, 90, 0, 0)
        channelBox.Position = UDim2.new(0, 10, 0, 105)
        channelBox.Font = Enum.Font.GothamBold
        channelBox.TextSize = 11
        channelBox.TextColor3 = Palette.Text
        channelBox.BackgroundColor3 = Palette.Bg
        channelBox.BorderSizePixel = 0
        channelBox.ClearTextOnFocus = false
        channelBox.AutomaticSize = Enum.AutomaticSize.Y
        channelBox.TextWrapped = true
        channelBox.TextXAlignment = Enum.TextXAlignment.Center
        channelBox.TextYAlignment = Enum.TextYAlignment.Center
        channelBox.ClipsDescendants = true
        channelBox.TextEditable = false
        Instance.new("UICorner", channelBox).CornerRadius = UDim.new(0, 6)
        local channelStroke = Instance.new("UIStroke", channelBox)
        channelStroke.Color = Palette.Accent
        channelStroke.Thickness = 1
        channelStroke.Transparency = 0.4

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
        titleLabel.TextSize = 15
        titleLabel.TextColor3 = Palette.Text
        titleLabel.BackgroundTransparency = 1
        titleLabel.Size = UDim2.new(1, 0, 0, 24)
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.TextYAlignment = Enum.TextYAlignment.Center

        local underline = Instance.new("Frame", titleLabel)
        underline.Size = UDim2.new(1, -20, 0, 1)
        underline.Position = UDim2.new(0, 10, 1, -3)
        underline.BackgroundColor3 = Palette.Accent
        underline.BackgroundTransparency = 0.5
        underline.BorderSizePixel = 0

        local buttonHolder = Instance.new("Frame", content)
        buttonHolder.Size = UDim2.new(1, 0, 0, 32)
        buttonHolder.BackgroundColor3 = Palette.AccentSoft
        buttonHolder.BorderSizePixel = 0
        buttonHolder.ClipsDescendants = true
        Instance.new("UICorner", buttonHolder).CornerRadius = UDim.new(0, 6)
        local buttonStroke = Instance.new("UIStroke", buttonHolder)
        buttonStroke.Color = Palette.Accent
        buttonStroke.Thickness = 1.2
        buttonStroke.Transparency = 0.2

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
        fillBar.Position = UDim2.new(0, 0, 0, 0)
        fillBar.BackgroundColor3 = Palette.Accent
        fillBar.BorderSizePixel = 0
        fillBar.ZIndex = 1
        local fbGrad = Instance.new("UIGradient", fillBar)
        fbGrad.Color = ColorSequence.new(Palette.Accent, Palette.AccentBright)

        local descLabel = Instance.new("TextLabel", content)
        descLabel.Text = description
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextSize = 13
        descLabel.TextColor3 = Palette.TextDim
        descLabel.BackgroundTransparency = 1
        descLabel.Size = UDim2.new(1, 0, 0, 0)
        descLabel.AutomaticSize = Enum.AutomaticSize.Y
        descLabel.TextWrapped = true
        descLabel.TextXAlignment = Enum.TextXAlignment.Left

        copyButton.MouseButton1Click:Connect(function()
            pcall(function() setclipboard(link) end)
            fillBar.Size = UDim2.new(0, 0, 1, 0)
            tween(fillBar, TweenInfo.new(0.4, Enum.EasingStyle.Sine), { Size = UDim2.new(1, 0, 1, 0) })
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

            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 12)
            local stroke = Instance.new("UIStroke", box)
            stroke.Color = Palette.Border
            stroke.Thickness = 1.2
            stroke.Transparency = 0.3

            local titleLabel = Instance.new("TextLabel", box)
            titleLabel.Text = titleText
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextSize = 15
            titleLabel.TextColor3 = Palette.Text
            titleLabel.BackgroundTransparency = 1
            titleLabel.Size = UDim2.new(1, -20, 0, 28)
            titleLabel.Position = UDim2.new(0, 10, 0, 10)
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left

            local label = Instance.new("TextLabel", box)
            label.Text = labelText
            label.Font = Enum.Font.Gotham
            label.TextSize = 12
            label.TextColor3 = Palette.TextDim
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, -20, 0, 18)
            label.Position = UDim2.new(0, 10, 0, 38)
            label.TextXAlignment = Enum.TextXAlignment.Left

            local content = Instance.new("Frame", box)
            content.BackgroundTransparency = 1
            content.Position = UDim2.new(0, 10, 0, 62)
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
                Instance.new("UICorner", square).CornerRadius = UDim.new(0, 6)

                local s = Instance.new("UIStroke", square)
                s.Color = Palette.Border
                s.Thickness = 1.2
                s.Transparency = 0.3

                local g = Instance.new("UIGradient", square)
                g.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, pair[1]),
                    ColorSequenceKeypoint.new(1, pair[2])
                }
                g.Rotation = 45

                local button = Instance.new("TextButton", square)
                button.BackgroundTransparency = 1
                button.Size = UDim2.new(1, 0, 1, 0)
                button.Text = ""
                button.AutoButtonColor = false

                button.MouseEnter:Connect(function()
                    tween(square, TweenInfo.new(0.15, Enum.EasingStyle.Back), { Size = UDim2.new(0, 40, 0, 40) })
                    fast(s, { Color = Palette.AccentBright })
                end)
                button.MouseLeave:Connect(function()
                    tween(square, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { Size = UDim2.new(0, 36, 0, 36) })
                    fast(s, { Color = Palette.Border })
                end)

                button.MouseButton1Click:Connect(function()
                    if mode == "interface" then
                        AtualizarCorInterface(pair[1], pair[1], pair[2])
                    elseif mode == "titulo" then
                        fast(title, { TextColor3 = pair[1] })
                        fast(subtitle, { TextColor3 = pair[2] })
                    end
                end)
            end

            local colorInputBox = Instance.new("TextBox", box)
            colorInputBox.Text = ""
            colorInputBox.Size = UDim2.new(1, -20, 0, 28)
            colorInputBox.BackgroundColor3 = Palette.Bg
            colorInputBox.TextColor3 = Palette.Text
            colorInputBox.TextSize = 12
            colorInputBox.PlaceholderText = "(ex: 255.0.0/0.0.0)"
            colorInputBox.PlaceholderColor3 = Palette.TextMute
            colorInputBox.ClearTextOnFocus = false
            colorInputBox.Position = UDim2.new(0, 10, 0, 0)
            colorInputBox.LayoutOrder = 999
            colorInputBox.BorderSizePixel = 0

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = colorInputBox
            local ciStroke = Instance.new("UIStroke", colorInputBox)
            ciStroke.Color = Palette.Border
            ciStroke.Thickness = 1
            ciStroke.Transparency = 0.4

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
                                    fast(title, { TextColor3 = newColor1 })
                                    fast(subtitle, { TextColor3 = newColor2 })
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
    function Window:CreateInfoBox(tabName, titleText, infoList)
        local tab = pages[tabName]
        if not tab then return end

        local box = Instance.new("Frame", tab)
        box.Size = UDim2.new(1, -20, 0, 0)
        box.Position = UDim2.new(0, 10, 0, 0)
        box.BackgroundColor3 = Palette.Surface
        box.BorderSizePixel = 0
        box.AutomaticSize = Enum.AutomaticSize.Y
        box.ClipsDescendants = true
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 12)
        local boxStroke = Instance.new("UIStroke", box)
        boxStroke.Color = Palette.Accent
        boxStroke.Thickness = 1.2
        boxStroke.Transparency = 0.3

        local titleLabel = Instance.new("TextLabel", box)
        titleLabel.Text = "  " .. string.upper(titleText or "INFORMAÇÃO")
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 15
        titleLabel.TextColor3 = Palette.Text
        titleLabel.BackgroundTransparency = 1
        titleLabel.Size = UDim2.new(1, -20, 0, 28)
        titleLabel.Position = UDim2.new(0, 10, 0, 10)
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.TextYAlignment = Enum.TextYAlignment.Center

        local underline = Instance.new("Frame", titleLabel)
        underline.Size = UDim2.new(1, -20, 0, 1)
        underline.Position = UDim2.new(0, 10, 1, -3)
        underline.BackgroundColor3 = Palette.Accent
        underline.BackgroundTransparency = 0.5
        underline.BorderSizePixel = 0

        local content = Instance.new("Frame", box)
        content.BackgroundTransparency = 1
        content.Position = UDim2.new(0, 10, 0, 45)
        content.Size = UDim2.new(1, -20, 0, 0)
        content.AutomaticSize = Enum.AutomaticSize.Y

        local layout = Instance.new("UIListLayout", content)
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 6)

        for i, text in ipairs(infoList or {}) do
            local itemFrame = Instance.new("Frame", content)
            itemFrame.BackgroundColor3 = Palette.Bg
            itemFrame.BackgroundTransparency = 0.4
            itemFrame.BorderSizePixel = 0
            itemFrame.AutomaticSize = Enum.AutomaticSize.Y
            itemFrame.Size = UDim2.new(1, 0, 0, 0)
            itemFrame.ClipsDescendants = true
            Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 6)
            local itemStroke = Instance.new("UIStroke", itemFrame)
            itemStroke.Color = Palette.Border
            itemStroke.Thickness = 1
            itemStroke.Transparency = 0.4

            local numberLabel = Instance.new("TextLabel", itemFrame)
            numberLabel.Text = tostring(i) .. "."
            numberLabel.Font = Enum.Font.GothamBold
            numberLabel.TextSize = 13
            numberLabel.TextColor3 = Palette.AccentBright
            numberLabel.BackgroundTransparency = 1
            numberLabel.Size = UDim2.new(0, 26, 1, 0)
            numberLabel.Position = UDim2.new(0, 10, 0, 0)
            numberLabel.TextXAlignment = Enum.TextXAlignment.Left
            numberLabel.TextYAlignment = Enum.TextYAlignment.Top

            local descLabel = Instance.new("TextLabel", itemFrame)
            descLabel.Text = text
            descLabel.Font = Enum.Font.Gotham
            descLabel.TextSize = 13
            descLabel.TextColor3 = Palette.TextDim
            descLabel.BackgroundTransparency = 1
            descLabel.Position = UDim2.new(0, 34, 0, 5)
            descLabel.Size = UDim2.new(1, -44, 0, 0)
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
    -- HIDE / SHOW BUTTONS
    -- ═══════════════════════════════════════════════════════════════
    local isHidden = false
    hideButton.MouseButton1Click:Connect(function()
        local targetSize = isHidden and UDim2.new(0, 575, 0, 375) or UDim2.new(0, 0, 0, 0)
        tween(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = targetSize
        })
        isHidden = not isHidden
        ballButton.Visible = isHidden
        if isHidden then
            ballButton.Size = UDim2.new(0, 0, 0, 0)
            tween(ballButton, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Size = UDim2.new(0.05, 0, 0.1, 0) })
        end
    end)

    ballButton.MouseButton1Click:Connect(function()
        tween(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 575, 0, 375)
        })
        isHidden = false
        ballButton.Visible = false
    end)

    return Window
end

return RANOX
