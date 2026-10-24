--[[
	FLUX UI — Framework UI para Roblox
	Mobile-first com adaptação automática para Console/PC
	
	Arquitetura:
	- FluxUI.lua (ModuleScript em ReplicatedStorage)
	- Uso: local Flux = require(...) | local UI = Flux.createWindow({...})
	
	Plataformas suportadas: Mobile, PC, Xbox, PlayStation
	Identidade: Neon minimalista com glassmorphism + spring physics
]]

--!strict
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════
-- PLATAFORMA: detecção automática
-- ═══════════════════════════════════════════════════════════════
local function detectPlatform(): string
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		return "Mobile"
	elseif UserInputService.GamepadEnabled and GuiService:IsTenFootInterface() then
		return "Console"
	elseif UserInputService.GamepadEnabled then
		return "Gamepad"
	end
	return "PC"
end

local PLATFORM = detectPlatform()
local IS_MOBILE = PLATFORM == "Mobile"
local IS_CONSOLE = PLATFORM == "Console" or PLATFORM == "Gamepad"
local HITBOX_MIN = if IS_MOBILE then 44 else 32 -- px mínimo para toque

-- ═══════════════════════════════════════════════════════════════
-- TEMA: cores, raios, sombras, tipografia
-- ═══════════════════════════════════════════════════════════════
local THEMES = {
	Obsidian = {
		bg        = Color3.fromRGB(10, 12, 18),
		surface   = Color3.fromRGB(18, 22, 32),
		surface2  = Color3.fromRGB(26, 32, 46),
		surface3  = Color3.fromRGB(34, 40, 56),
		border    = Color3.fromRGB(48, 56, 76),
		text      = Color3.fromRGB(236, 240, 248),
		dim       = Color3.fromRGB(158, 170, 192),
		mute      = Color3.fromRGB(102, 115, 140),
		accent    = Color3.fromRGB(110, 156, 255),
		accent2   = Color3.fromRGB(168, 120, 255),
		success   = Color3.fromRGB(78, 214, 142),
		warn      = Color3.fromRGB(255, 180, 78),
		danger    = Color3.fromRGB(255, 96, 122),
		grad1     = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(110, 156, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(168, 120, 255))
		},
	},
	Ember = {
		bg        = Color3.fromRGB(18, 10, 10),
		surface   = Color3.fromRGB(32, 18, 20),
		surface2  = Color3.fromRGB(44, 26, 28),
		surface3  = Color3.fromRGB(58, 36, 38),
		border    = Color3.fromRGB(78, 48, 52),
		text      = Color3.fromRGB(248, 236, 232),
		dim       = Color3.fromRGB(192, 170, 162),
		mute      = Color3.fromRGB(140, 122, 118),
		accent    = Color3.fromRGB(255, 126, 72),
		accent2   = Color3.fromRGB(255, 186, 76),
		success   = Color3.fromRGB(142, 214, 78),
		warn      = Color3.fromRGB(255, 212, 78),
		danger    = Color3.fromRGB(255, 82, 108),
		grad1     = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 126, 72)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 68, 122))
		},
	},
	Mint = {
		bg        = Color3.fromRGB(8, 16, 14),
		surface   = Color3.fromRGB(14, 28, 26),
		surface2  = Color3.fromRGB(22, 40, 36),
		surface3  = Color3.fromRGB(30, 52, 48),
		border    = Color3.fromRGB(46, 72, 68),
		text      = Color3.fromRGB(232, 248, 240),
		dim       = Color3.fromRGB(162, 192, 180),
		mute      = Color3.fromRGB(118, 140, 132),
		accent    = Color3.fromRGB(72, 214, 168),
		accent2   = Color3.fromRGB(108, 248, 218),
		success   = Color3.fromRGB(142, 214, 78),
		warn      = Color3.fromRGB(255, 212, 78),
		danger    = Color3.fromRGB(255, 96, 122),
		grad1     = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(72, 214, 168)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(108, 200, 248))
		},
	},
}

-- ═══════════════════════════════════════════════════════════════
-- SPRING: animação orgânica (melhor que TweenService para hover)
-- ═══════════════════════════════════════════════════════════════
local Spring = {}
Spring.__index = Spring

function Spring.new(initial, speed: number?, damping: number?)
	local self = setmetatable({}, Spring)
	self.Target = initial or 0
	self.Position = self.Target
	self.Velocity = if typeof(self.Target) == "number" then 0 else self.Target * 0
	self.Speed = speed or 18
	self.Damping = damping or 0.72
	self._conn = nil
	return self
end

function Spring:Update(dt: number)
	dt = math.min(dt, 0.064)
	local p, v, t = self.Position, self.Velocity, self.Target

	if typeof(p) == "number" then
		local force = -self.Speed * self.Speed * (p - (t :: number))
		local damp = -2 * self.Damping * self.Speed * v
		self.Velocity = v + (force + damp) * dt
		self.Position = p + self.Velocity * dt
	elseif typeof(p) == "Vector2" then
		local force = ((t :: Vector2) - p) * (self.Speed * self.Speed)
		local damp = v * (2 * self.Damping * self.Speed)
		self.Velocity = v + (force - damp) * dt
		self.Position = p + self.Velocity * dt
	elseif typeof(p) == "UDim2" then
		local x = self:Update2D(dt, p.X.Offset, p.X.Scale, (t :: UDim2).X)
		local y = self:Update2D(dt, p.Y.Offset, p.Y.Scale, (t :: UDim2).Y)
		self.Position = UDim2.new(x.Scale, x.Offset, y.Scale, y.Offset)
	elseif typeof(p) == "Color3" then
		local r = self:Update2D(dt, p.R, 0, { Offset = (t :: Color3).R, Scale = 0 })
		local g = self:Update2D(dt, p.G, 0, { Offset = (t :: Color3).G, Scale = 0 })
		local b = self:Update2D(dt, p.B, 0, { Offset = (t :: Color3).B, Scale = 0 })
		self.Position = Color3.new(r.Offset, g.Offset, b.Offset)
	end
	return self.Position
end

function Spring:Update2D(dt: number, offset: number, scale: number, target): { Offset: number, Scale: number }
	local force = -self.Speed * self.Speed * (offset - target.Offset)
	local damp = -2 * self.Damping * self.Speed * (self.Velocity :: any)
	if typeof(self.Velocity) ~= "number" then
		self.Velocity = 0
	end
	self.Velocity = (self.Velocity :: number) + (force + damp) * dt
	return { Offset = offset + (self.Velocity :: number) * dt, Scale = scale }
end

function Spring:Set(value)
	self.Position = value
	self.Target = value
	if typeof(value) == "number" then self.Velocity = 0 else self.Velocity = value * 0 end
end

function Spring:Impulse(velocity)
	if typeof(self.Velocity) == typeof(velocity) then
		self.Velocity = self.Velocity + velocity
	end
end

function Spring:Destroy()
	if self._conn then self._conn:Disconnect() end
end

-- ═══════════════════════════════════════════════════════════════
-- CLEANER: gerenciamento de memória
-- ═══════════════════════════════════════════════════════════════
local Cleaner = {}
Cleaner.__index = Cleaner

function Cleaner.new()
	return setmetatable({ _items = {} }, Cleaner)
end

function Cleaner:Add(item): any
	if item == nil then return nil end
	table.insert(self._items, item)
	return item
end

function Cleaner:Destroy()
	for i = #self._items, 1, -1 do
		local item = self._items[i]
		local kind = typeof(item)
		if kind == "RBXScriptConnection" then
			item:Disconnect()
		elseif kind == "Instance" then
			item:Destroy()
		elseif kind == "function" then
			pcall(item)
		elseif kind == "table" and type(item.Destroy) == "function" then
			item:Destroy()
		end
	end
	table.clear(self._items)
end

-- ═══════════════════════════════════════════════════════════════
-- CONFIG: estado persistente
-- ═══════════════════════════════════════════════════════════════
local Config = {
	theme = "Obsidian",
	scale = 1.0,
	blur = true,
	fpsCap = true,
	rounded = true,
	dragEnabled = true,
	closeOnOutside = true,
	gamepadNav = true,
	sounds = true,
	reducedMotion = false,
	keybinds = {},
}

local CONFIG_KEY = "FluxUI_Config_v1"

local function saveConfig()
	local data = {
		theme = Config.theme,
		scale = Config.scale,
		blur = Config.blur,
		fpsCap = Config.fpsCap,
		rounded = Config.rounded,
		keybinds = Config.keybinds,
	}
	pcall(function()
		local HttpService = game:GetService("HttpService")
		local encoded = HttpService:JSONEncode(data)
		local store = Instance.new("StringValue")
		store.Name = CONFIG_KEY
		store.Value = encoded
		store.Parent = playerGui
	end)
end

local function loadConfig()
	local existing = playerGui:FindFirstChild(CONFIG_KEY)
	if not existing then return end
	pcall(function()
		local HttpService = game:GetService("HttpService")
		local data = HttpService:JSONDecode(existing.Value)
		if type(data) == "table" then
			for k, v in data do
				if Config[k] ~= nil then Config[k] = v end
			end
		end
	end)
end

-- ═══════════════════════════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════════════════════════
local function theme(): any
	return THEMES[Config.theme] or THEMES.Obsidian
end

local function lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

local function lerpColor(a: Color3, b: Color3, t: number): Color3
	return Color3.new(lerp(a.R, b.R, t), lerp(a.G, b.G, t), lerp(a.B, b.B, t))
end

local function round(n: number, decimals: number?): number
	local mult = 10 ^ (decimals or 0)
	return math.floor(n * mult + 0.5) / mult
end

local function create(className: string, props: {[string]: any}?): Instance
	local instance = Instance.new(className)
	if props then
		for k, v in props do
			if k == "Parent" then
				instance.Parent = v
			else
				instance[k] = v
			end
		end
	end
	return instance
end

local function applyCorner(parent: Instance, radius: number?)
	local corner = create("UICorner", {
		CornerRadius = UDim.new(0, radius or 12),
		Parent = parent
	})
	return corner
end

local function applyStroke(parent: Instance, color: Color3?, thickness: number?)
	local stroke = create("UIStroke", {
		Color = color or theme().border,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent
	})
	return stroke
end

local function applyPadding(parent: Instance, px: number?)
	local padding = create("UIPadding", {
		PaddingTop = UDim.new(0, px or 8),
		PaddingBottom = UDim.new(0, px or 8),
		PaddingLeft = UDim.new(0, px or 8),
		PaddingRight = UDim.new(0, px or 8),
		Parent = parent
	})
	return padding
end

-- ═══════════════════════════════════════════════════════════════
-- TWEEN HELPERS
-- ═══════════════════════════════════════════════════════════════
local TWEEN_FAST = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_NORMAL = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TWEEN_BOUNCE = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function tween(instance: Instance, props: {[string]: any}, info: TweenInfo?): Tween
	return TweenService:Create(instance, info or TWEEN_NORMAL, props)
end

-- ═══════════════════════════════════════════════════════════════
-- SONS: feedback tátil/sonoro
-- ═══════════════════════════════════════════════════════════════
local Sounds = {}

function Sounds.click()
	if not Config.sounds then return end
	local sound = create("Sound", {
		SoundId = "rbxassetid://5869427999",
		Volume = 0.3,
		Parent = playerGui
	})
	sound:Play()
	task.delay(0.5, function() sound:Destroy() end)
end

function Sounds.hover()
	if not Config.sounds then return end
	local sound = create("Sound", {
		SoundId = "rbxassetid://5869427999",
		Volume = 0.1,
		Parent = playerGui
	})
	sound:Play()
	task.delay(0.5, function() sound:Destroy() end)
end

function Sounds.success()
	if not Config.sounds then return end
	local sound = create("Sound", {
		SoundId = "rbxassetid://5869427999",
		Volume = 0.4,
		Parent = playerGui
	})
	sound:Play()
	task.delay(0.5, function() sound:Destroy() end)
end

-- ═══════════════════════════════════════════════════════════════
-- NOTIFICAÇÕES
-- ═══════════════════════════════════════════════════════════════
local Notifications = {}
local notificationQueue = {}
local MAX_NOTIFICATIONS = 4

local function createNotification(title: string, message: string, kind: string?, duration: number?)
	kind = kind or "info"
	duration = duration or 4

	local t = theme()
	local colors = {
		info = t.accent,
		success = t.success,
		warn = t.warn,
		danger = t.danger,
	}
	local color = colors[kind] or t.accent

	local container = create("Frame", {
		Size = UDim2.new(0, 320, 0, 64),
		BackgroundColor3 = t.surface,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Position = UDim2.new(1, 20, 0, 0),
		AnchorPoint = Vector2.new(0, 0),
		ZIndex = 100,
	})
	applyCorner(container, 12)
	applyStroke(container, t.border, 1)

	local accent = create("Frame", {
		Size = UDim2.new(0, 4, 1, -16),
		Position = UDim2.new(0, 8, 0, 8),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Parent = container
	})
	applyCorner(accent, 2)

	local iconFrame = create("Frame", {
		Size = UDim2.new(0, 32, 0, 32),
		Position = UDim2.new(0, 18, 0.5, -16),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = container
	})

	local icons = {
		info = "i",
		success = "✓",
		warn = "!",
		danger = "✕",
	}
	local icon = create("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = icons[kind] or "i",
		TextColor3 = color,
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		Parent = iconFrame
	})

	local titleLabel = create("TextLabel", {
		Size = UDim2.new(1, -64, 0, 18),
		Position = UDim2.new(0, 58, 0, 14),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = t.text,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = container
	})

	local messageLabel = create("TextLabel", {
		Size = UDim2.new(1, -64, 0, 14),
		Position = UDim2.new(0, 58, 0, 34),
		BackgroundTransparency = 1,
		Text = message,
		TextColor3 = t.dim,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Parent = container
	})

	local closeButton = create("TextButton", {
		Size = UDim2.new(0, 24, 0, 24),
		Position = UDim2.new(1, -32, 0, 8),
		BackgroundTransparency = 1,
		Text = "✕",
		TextColor3 = t.mute,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		Parent = container
	})

	table.insert(notificationQueue, container)
	while #notificationQueue > MAX_NOTIFICATIONS do
		local oldest = table.remove(notificationQueue, 1)
		if oldest then oldest:Destroy() end
	end

	local yPos = 20 + (#notificationQueue - 1) * 76
	container.Position = UDim2.new(1, 20, 0, yPos)
	container.Parent = Notifications.container

	tween(container, { Position = UDim2.new(1, -20, 0, yPos) }, TWEEN_BOUNCE):Play()

	local function dismiss()
		tween(container, {
			Position = UDim2.new(1, 20, 0, yPos),
			BackgroundTransparency = 1
		}, TWEEN_FAST):Play()
		task.delay(0.2, function()
			local idx = table.find(notificationQueue, container)
			if idx then table.remove(notificationQueue, idx) end
			container:Destroy()
			Notifications.reposition()
		end)
	end

	closeButton.MouseButton1Click:Connect(dismiss)

	task.delay(duration, function()
		if container.Parent then dismiss() end
	end)

	return container
end

function Notifications.reposition()
	for i, notif in notificationQueue do
		local yPos = 20 + (i - 1) * 76
		tween(notif, { Position = UDim2.new(1, -20, 0, yPos) }, TWEEN_NORMAL):Play()
	end
end

function Notifications.notify(title: string, message: string, kind: string?, duration: number?)
	createNotification(title, message, kind, duration)
end

-- ═══════════════════════════════════════════════════════════════
-- ELEMENTO BASE
-- ═══════════════════════════════════════════════════════════════
local Element = {}
Element.__index = Element

function Element.new(instance: Instance, cleaner: any?)
	local self = setmetatable({}, Element)
	self.instance = instance
	self.cleaner = cleaner or Cleaner.new()
	self.springs = {}
	self.connections = {}
	return self
end

function Element:BindSpring(name: string, initial: any, speed: number?, damping: number?): any
	if self.springs[name] then return self.springs[name] end
	local spring = Spring.new(initial, speed, damping)
	self.springs[name] = spring
	return spring
end

function Element:Destroy()
	for _, spring in self.springs do
		spring:Destroy()
	end
	self.cleaner:Destroy()
end

-- ═══════════════════════════════════════════════════════════════
-- BOTÃO
-- ═══════════════════════════════════════════════════════════════
local Button = {}
Button.__index = Button
setmetatable(Button, { __index = Element })

function Button.new(parent: Instance, props: {[string]: any}): any
	local self = setmetatable(Element.new(nil), Button)
	local t = theme()

	local button = create("TextButton", {
		Size = props.Size or UDim2.new(1, 0, 0, HITBOX_MIN),
		BackgroundColor3 = props.BackgroundColor3 or t.surface2,
		BackgroundTransparency = props.BackgroundTransparency or 0,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Parent = parent
	})
	self.instance = button
	self.cleaner:Add(button)

	applyCorner(button, props.CornerRadius or 10)
	applyStroke(button, t.border, 1)
	applyPadding(button, props.Padding or 12)

	local layout = create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10),
		Parent = button
	})

	if props.Icon then
		local icon = create("ImageLabel", {
			Size = UDim2.new(0, 20, 0, 20),
			BackgroundTransparency = 1,
			Image = props.Icon,
			ImageColor3 = props.IconColor or t.accent,
			LayoutOrder = 1,
			Parent = button
		})
	end

	local label = create("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = props.Text or "Button",
		TextColor3 = props.TextColor or t.text,
		TextSize = props.TextSize or 14,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 2,
		Parent = button
	})

	local hoverSpring = self:BindSpring("hover", 0, 22, 0.78)
	local pressSpring = self:BindSpring("press", 0, 28, 0.82)

	local function update()
		local hover = hoverSpring.Position
		local press = pressSpring.Position
		button.BackgroundTransparency = lerp(0, -0.12, hover) + press * 0.08
		button.BackgroundColor3 = lerpColor(
			t.surface2,
			t.surface3,
			hover
		)
		button.Size = if press > 0.5 then UDim2.new(1, 0, 0, HITBOX_MIN - 2) else UDim2.new(1, 0, 0, HITBOX_MIN)
	end

	button.MouseEnter:Connect(function()
		hoverSpring.Target = 1
		Sounds.hover()
	end)
	button.MouseLeave:Connect(function()
		hoverSpring.Target = 0
	end)
	button.MouseButton1Down:Connect(function()
		pressSpring.Target = 1
		Sounds.click()
	end)
	button.MouseButton1Up:Connect(function()
		pressSpring.Target = 0
	end)

	self.cleaner:Add(RunService.RenderStepped:Connect(function(dt)
		hoverSpring:Update(dt)
		pressSpring:Update(dt)
		update()
	end))

	if props.Callback then
		button.MouseButton1Click:Connect(function()
			local ok, err = pcall(props.Callback)
			if not ok then warn("[FluxUI] Button callback error:", err) end
		end)
	end

	return self
end

-- ═══════════════════════════════════════════════════════════════
-- TOGGLE
-- ═══════════════════════════════════════════════════════════════
local Toggle = {}
Toggle.__index = Toggle
setmetatable(Toggle, { __index = Element })

function Toggle.new(parent: Instance, props: {[string]: any}): any
	local self = setmetatable(Element.new(nil), Toggle)
	local t = theme()

	local container = create("TextButton", {
		Size = props.Size or UDim2.new(1, 0, 0, HITBOX_MIN),
		BackgroundColor3 = t.surface2,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Parent = parent
	})
	self.instance = container
	self.cleaner:Add(container)

	applyCorner(container, 10)
	applyStroke(container, t.border, 1)

	local label = create("TextLabel", {
		Size = UDim2.new(1, -68, 1, 0),
		Position = UDim2.new(0, 14, 0, 0),
		BackgroundTransparency = 1,
		Text = props.Text or "Toggle",
		TextColor3 = t.text,
		TextSize = 14,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = container
	})

	local track = create("Frame", {
		Size = UDim2.new(0, 44, 0, 24),
		Position = UDim2.new(1, -58, 0.5, -12),
		BackgroundColor3 = t.surface3,
		BorderSizePixel = 0,
		Parent = container
	})
	applyCorner(track, 12)

	local thumb = create("Frame", {
		Size = UDim2.new(0, 20, 0, 20),
		Position = UDim2.new(0, 2, 0.5, -10),
		BackgroundColor3 = t.dim,
		BorderSizePixel = 0,
		Parent = track
	})
	applyCorner(thumb, 10)

	local state = props.Default or false
	local thumbSpring = self:BindSpring("thumb", state and 20 or 0, 24, 0.72)
	local colorSpring = self:BindSpring("color", state and 1 or 0, 22, 0.76)

	local function update()
		thumb.Position = UDim2.new(0, 2 + thumbSpring.Position, 0.5, -10)
		track.BackgroundColor3 = lerpColor(t.surface3, t.accent, colorSpring.Position)
		thumb.BackgroundColor3 = lerpColor(t.dim, t.bg, colorSpring.Position)
	end

	local function toggle()
		state = not state
		thumbSpring.Target = state and 20 or 0
		colorSpring.Target = state and 1 or 0
		Sounds.click()
		if props.Callback then
			local ok, err = pcall(props.Callback, state)
			if not ok then warn("[FluxUI] Toggle callback error:", err) end
		end
	end

	container.MouseButton1Click:Connect(toggle)

	self.cleaner:Add(RunService.RenderStepped:Connect(function(dt)
		thumbSpring:Update(dt)
		colorSpring:Update(dt)
		update()
	end))

	function self:Set(state_: boolean)
		state = state_
		thumbSpring.Target = state and 20 or 0
		colorSpring.Target = state and 1 or 0
	end

	function self:Get(): boolean
		return state
	end

	return self
end

-- ═══════════════════════════════════════════════════════════════
-- SLIDER
-- ═══════════════════════════════════════════════════════════════
local Slider = {}
Slider.__index = Slider
setmetatable(Slider, { __index = Element })

function Slider.new(parent: Instance, props: {[string]: any}): any
	local self = setmetatable(Element.new(nil), Slider)
	local t = theme()

	local min = props.Min or 0
	local max = props.Max or 100
	local step = props.Step or 1
	local value = props.Default or min

	local container = create("Frame", {
		Size = props.Size or UDim2.new(1, 0, 0, HITBOX_MIN + 20),
		BackgroundColor3 = t.surface2,
		BorderSizePixel = 0,
		Parent = parent
	})
	self.instance = container
	self.cleaner:Add(container)

	applyCorner(container, 10)
	applyStroke(container, t.border, 1)
	applyPadding(container, 14)

	local label = create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = props.Text or "Slider",
		TextColor3 = t.text,
		TextSize = 14,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = container
	})

	local valueLabel = create("TextLabel", {
		Size = UDim2.new(0, 60, 0, 18),
		Position = UDim2.new(1, -60, 0, 0),
		BackgroundTransparency = 1,
		Text = tostring(round(value, props.Decimals or 0)),
		TextColor3 = t.accent,
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = container
	})

	local track = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 6),
		Position = UDim2.new(0, 0, 1, -10),
		BackgroundColor3 = t.surface3,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Parent = container
	})
	applyCorner(track, 3)

	local fill = create("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = t.accent,
		BorderSizePixel = 0,
		Parent = track
	})
	applyCorner(fill, 3)

	local thumb = create("Frame", {
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(0, -8, 0.5, -8),
		BackgroundColor3 = t.text,
		BorderSizePixel = 0,
		Parent = track
	})
	applyCorner(thumb, 8)
	applyStroke(thumb, t.accent, 2)

	local dragging = false
	local fillSpring = self:BindSpring("fill", 0, 26, 0.74)

	local function updateVisual()
		local ratio = (value - min) / (max - min)
		fillSpring.Target = ratio
		fill.Size = UDim2.new(fillSpring.Position, 0, 1, 0)
		thumb.Position = UDim2.new(fillSpring.Position, -8, 0.5, -8)
		valueLabel.Text = tostring(round(value, props.Decimals or 0))
	end

	local function updateFromInput(input: InputObject | number)
		local x = if typeof(input) == "number" then input else input.Position.X
		local trackPos = track.AbsolutePosition.X
		local trackSize = track.AbsoluteSize.X
		local ratio = math.clamp((x - trackPos) / trackSize, 0, 1)
		local raw = min + ratio * (max - min)
		value = math.clamp(math.floor(raw / step + 0.5) * step, min, max)
		updateVisual()
		if props.Callback then
			local ok, err = pcall(props.Callback, value)
			if not ok then warn("[FluxUI] Slider callback error:", err) end
		end
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			updateFromInput(input)
		end
	end)

	self.cleaner:Add(UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateFromInput(input)
		end
	end))

	self.cleaner:Add(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))

	self.cleaner:Add(RunService.RenderStepped:Connect(function(dt)
		fillSpring:Update(dt)
		updateVisual()
	end))

	function self:Set(val: number)
		value = math.clamp(val, min, max)
		updateVisual()
	end

	function self:Get(): number
		return value
	end

	updateVisual()
	return self
end

-- ═══════════════════════════════════════════════════════════════
-- DROPDOWN
-- ═══════════════════════════════════════════════════════════════
local Dropdown = {}
Dropdown.__index = Dropdown
setmetatable(Dropdown, { __index = Element })

function Dropdown.new(parent: Instance, props: {[string]: any}): any
	local self = setmetatable(Element.new(nil), Dropdown)
	local t = theme()

	local options = props.Options or {}
	local selected = props.Default or (options[1] and options[1].Text) or ""
	local isOpen = false

	local container = create("Frame", {
		Size = props.Size or UDim2.new(1, 0, 0, HITBOX_MIN),
		BackgroundColor3 = t.surface2,
		BorderSizePixel = 0,
		Parent = parent
	})
	self.instance = container
	self.cleaner:Add(container)

	applyCorner(container, 10)
	applyStroke(container, t.border, 1)

	local button = create("TextButton", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = container
	})

	local label = create("TextLabel", {
		Size = UDim2.new(1, -40, 1, 0),
		Position = UDim2.new(0, 14, 0, 0),
		BackgroundTransparency = 1,
		Text = props.Text or "Dropdown",
		TextColor3 = t.text,
		TextSize = 14,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = button
	})

	local valueLabel = create("TextLabel", {
		Size = UDim2.new(0, 140, 1, 0),
		Position = UDim2.new(1, -180, 0, 0),
		BackgroundTransparency = 1,
		Text = selected,
		TextColor3 = t.accent,
		TextSize = 13,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = button
	})

	local arrow = create("TextLabel", {
		Size = UDim2.new(0, 20, 1, 0),
		Position = UDim2.new(1, -30, 0, 0),
		BackgroundTransparency = 1,
		Text = "▼",
		TextColor3 = t.dim,
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		Parent = button
	})

	local dropdown = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(0, 0, 1, 4),
		BackgroundColor3 = t.surface2,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 50,
		Parent = container
	})
	applyCorner(dropdown, 10)
	applyStroke(dropdown, t.border, 1)

	local list = create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = t.accent,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = dropdown
	})

	local listLayout = create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = list
	})

	local dropdownSpring = self:BindSpring("dropdown", 0, 24, 0.78)
	local arrowSpring = self:BindSpring("arrow", 0, 22, 0.76)

	local function update()
		dropdown.Size = UDim2.new(1, 0, 0, dropdownSpring.Position)
		arrow.Rotation = arrowSpring.Position * 180
	end

	local function toggle()
		isOpen = not isOpen
		dropdown.Visible = isOpen
		dropdownSpring.Target = isOpen and (#options * 36) or 0
		arrowSpring.Target = isOpen and 1 or 0
		if isOpen then Sounds.click() end
	end

	local function select(option: any)
		selected = option.Text
		valueLabel.Text = selected
		toggle()
		if props.Callback then
			local ok, err = pcall(props.Callback, option)
			if not ok then warn("[FluxUI] Dropdown callback error:", err) end
		end
	end

	for i, option in options do
		local optButton = create("TextButton", {
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = t.surface3,
			BackgroundTransparency = 0.4,
			BorderSizePixel = 0,
			Text = option.Text,
			TextColor3 = t.text,
			TextSize = 13,
			Font = Enum.Font.Gotham,
			AutoButtonColor = false,
			LayoutOrder = i,
			Parent = list
		})
		applyCorner(optButton, 8)
		applyPadding(optButton, 12)

		optButton.MouseEnter:Connect(function()
			tween(optButton, { BackgroundTransparency = 0, BackgroundColor3 = t.accent }, TWEEN_FAST):Play()
		end)
		optButton.MouseLeave:Connect(function()
			tween(optButton, { BackgroundTransparency = 0.4, BackgroundColor3 = t.surface3 }, TWEEN_FAST):Play()
		end)
		optButton.MouseButton1Click:Connect(function()
			select(option)
		end)
	end

	button.MouseButton1Click:Connect(toggle)

	self.cleaner:Add(RunService.RenderStepped:Connect(function(dt)
		dropdownSpring:Update(dt)
		arrowSpring:Update(dt)
		update()
	end))

	function self:Get(): string
		return selected
	end

	return self
end

-- ═══════════════════════════════════════════════════════════════
-- TAB
-- ═══════════════════════════════════════════════════════════════
local Tab = {}
Tab.__index = Tab

function Tab.new(window: any, props: {[string]: any}): any
	local self = setmetatable({}, Tab)
	self.window = window
	self.name = props.Name or "Tab"
	self.icon = props.Icon
	self.content = create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = theme().accent,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = window.contentContainer
	})

	local listLayout = create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = self.content
	})

	local padding = create("UIPadding", {
		PaddingTop = UDim.new(0, 14),
		PaddingBottom = UDim.new(0, 14),
		PaddingLeft = UDim.new(0, 14),
		PaddingRight = UDim.new(0, 14),
		Parent = self.content
	})

	self.elements = {}
	return self
end

function Tab:AddButton(props: {[string]: any}): any
	local button = Button.new(self.content, props)
	table.insert(self.elements, button)
	return button
end

function Tab:AddToggle(props: {[string]: any}): any
	local toggle = Toggle.new(self.content, props)
	table.insert(self.elements, toggle)
	return toggle
end

function Tab:AddSlider(props: {[string]: any}): any
	local slider = Slider.new(self.content, props)
	table.insert(self.elements, slider)
	return slider
end

function Tab:AddDropdown(props: {[string]: any}): any
	local dropdown = Dropdown.new(self.content, props)
	table.insert(self.elements, dropdown)
	return dropdown
end

function Tab:AddSection(props: {[string]: any}): any
	local t = theme()
	local section = create("Frame", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		Parent = self.content
	})

	local label = create("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = props.Text or "Section",
		TextColor3 = t.accent,
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = section
	})

	local line = create("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = t.border,
		BorderSizePixel = 0,
		Parent = section
	})

	return section
end

function Tab:Show()
	self.content.Visible = true
end

function Tab:Hide()
	self.content.Visible = false
end

-- ═══════════════════════════════════════════════════════════════
-- WINDOW
-- ═══════════════════════════════════════════════════════════════
local Window = {}
Window.__index = Window

function Window.new(props: {[string]: any}): any
	local self = setmetatable({}, Window)
	local t = theme()
	self.cleaner = Cleaner.new()

	local screenGui = create("ScreenGui", {
		Name = "FluxUI_" .. tostring(os.time()),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
		Parent = CoreGui
	})
	self.cleaner:Add(screenGui)
	self.gui = screenGui

	local window = create("Frame", {
		Size = props.Size or UDim2.new(0, 540, 0, 420),
		Position = props.Position or UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = t.bg,
		BackgroundTransparency = 0.06,
		BorderSizePixel = 0,
		Parent = screenGui
	})
	self.window = window
	applyCorner(window, 16)
	applyStroke(window, t.border, 1.5)

	if Config.blur then
		local blur = create("ImageLabel", {
			Size = UDim2.new(1, 20, 1, 20),
			Position = UDim2.new(0, -10, 0, -10),
			Image = "rbxassetid://5554236805",
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(23, 23, 277, 277),
			ImageColor3 = t.bg,
			ImageTransparency = 0.72,
			ZIndex = -1,
			Parent = window
		})
	end

	-- HEADER
	local header = create("Frame", {
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundColor3 = t.surface,
		BorderSizePixel = 0,
		Parent = window
	})
	applyCorner(header, 16)

	local title = create("TextLabel", {
		Size = UDim2.new(1, -120, 1, 0),
		Position = UDim2.new(0, 18, 0, 0),
		BackgroundTransparency = 1,
		Text = props.Title or "Flux UI",
		TextColor3 = t.text,
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header
	})

	local closeButton = create("TextButton", {
		Size = UDim2.new(0, 32, 0, 32),
		Position = UDim2.new(1, -42, 0.5, -16),
		BackgroundColor3 = t.danger,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Text = "✕",
		TextColor3 = t.text,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		Parent = header
	})
	applyCorner(closeButton, 8)

	local settingsButton = create("TextButton", {
		Size = UDim2.new(0, 32, 0, 32),
		Position = UDim2.new(1, -82, 0.5, -16),
		BackgroundColor3 = t.surface2,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Text = "⚙",
		TextColor3 = t.text,
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		Parent = header
	})
	applyCorner(settingsButton, 8)

	-- TABS
	local tabContainer = create("Frame", {
		Size = UDim2.new(0, 180, 1, -48),
		Position = UDim2.new(0, 0, 0, 48),
		BackgroundColor3 = t.surface,
		BorderSizePixel = 0,
		Parent = window
	})
	applyCorner(tabContainer, 16)

	local tabList = create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = tabContainer
	})

	local tabListLayout = create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
		Parent = tabList
	})

	local tabPadding = create("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		Parent = tabList
	})

	-- CONTENT
	self.contentContainer = create("Frame", {
		Size = UDim2.new(1, -180, 1, -48),
		Position = UDim2.new(0, 180, 0, 48),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = window
	})

	self.tabs = {}
	self.currentTab = nil

	local function switchTab(tab: any)
		if self.currentTab then self.currentTab:Hide() end
		tab:Show()
		self.currentTab = tab
		for _, t2 in self.tabs do
			if t2.button then
				t2.button.BackgroundColor3 = if t2 == tab then theme().accent else theme().surface2
				t2.button.BackgroundTransparency = if t2 == tab then 0 else 0.4
			end
		end
	end

	function self:AddTab(tabProps: {[string]: any}): any
		local tab = Tab.new(self, tabProps)
		table.insert(self.tabs, tab)

		local tabButton = create("TextButton", {
			Size = UDim2.new(1, 0, 0, HITBOX_MIN),
			BackgroundColor3 = t.surface2,
			BackgroundTransparency = 0.4,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			Parent = tabList
		})
		tab.button = tabButton
		applyCorner(tabButton, 10)

		local tabLabel = create("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "  " .. tabProps.Name,
			TextColor3 = t.text,
			TextSize = 14,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = tabButton
		})

		tabButton.MouseButton1Click:Connect(function()
			switchTab(tab)
			Sounds.click()
		end)

		tabButton.MouseEnter:Connect(function()
			if tab ~= self.currentTab then
				tween(tabButton, { BackgroundTransparency = 0.2 }, TWEEN_FAST):Play()
			end
		end)
		tabButton.MouseLeave:Connect(function()
			if tab ~= self.currentTab then
				tween(tabButton, { BackgroundTransparency = 0.4 }, TWEEN_FAST):Play()
			end
		end)

		if #self.tabs == 1 then switchTab(tab) end
		return tab
	end

	-- DRAG
	if Config.dragEnabled then
		local dragging = false
		local dragStart, startPos

		header.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = window.Position
			end
		end)

		self.cleaner:Add(UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - dragStart
				window.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end))

		self.cleaner:Add(UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end))
	end

	-- CLOSE
	closeButton.MouseButton1Click:Connect(function()
		Sounds.click()
		self:Destroy()
	end)

	-- SETTINGS (simplificado)
	settingsButton.MouseButton1Click:Connect(function()
		Sounds.click()
		Notifications.notify("Configurações", "Menu de configurações em desenvolvimento", "info")
	end)

	-- RESPONSIVO: ajusta para mobile/console
	if IS_MOBILE then
		window.Size = UDim2.new(0.95, 0, 0.85, 0)
		window.Position = UDim2.new(0.5, 0, 0.5, 0)
		tabContainer.Size = UDim2.new(1, 0, 0, 60)
		tabContainer.Position = UDim2.new(0, 0, 1, -60)
		tabList.ScrollingDirection = Enum.ScrollingDirection.X
		tabListLayout.FillDirection = Enum.FillDirection.Horizontal
		self.contentContainer.Size = UDim2.new(1, 0, 1, -108)
		self.contentContainer.Position = UDim2.new(0, 0, 0, 48)
	elseif IS_CONSOLE then
		window.Size = UDim2.new(0.8, 0, 0.8, 0)
	end

	return self
end

function Window:Destroy()
	self.cleaner:Destroy()
end

-- ═══════════════════════════════════════════════════════════════
-- API PÚBLICA
-- ═══════════════════════════════════════════════════════════════
local FluxUI = {}

function FluxUI.createWindow(props: {[string]: any}?): any
	props = props or {}
	loadConfig()
	return Window.new(props)
end

function FluxUI.setTheme(themeName: string)
	if THEMES[themeName] then
		Config.theme = themeName
		saveConfig()
	end
end

function FluxUI.setConfig(key: string, value: any)
	if Config[key] ~= nil then
		Config[key] = value
		saveConfig()
	end
end

function FluxUI.notify(title: string, message: string, kind: string?, duration: number?)
	Notifications.notify(title, message, kind, duration)
end

function FluxUI.getPlatform(): string
	return PLATFORM
end

function FluxUI.getThemes(): {string}
	local names = {}
	for name in THEMES do table.insert(names, name) end
	return names
end

-- Inicialização do container de notificações
task.spawn(function()
	local container = create("Frame", {
		Size = UDim2.new(0, 340, 1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Parent = create("ScreenGui", {
			Name = "FluxUI_Notifications",
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			Parent = CoreGui
		})
	})
	Notifications.container = container
end)

return FluxUI
