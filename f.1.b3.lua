local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()

local Window = Rayfield:CreateWindow({
	Name = "Painel de Recursos",
	LoadingTitle = "Carregando Sistema...",
	LoadingSubtitle = "By ChatGPT",
	ConfigurationSaving = {
		Enabled = false
	}
})

local MainTab = Window:CreateTab("💎 RECURSOS", 4483362458)
local PlayerTab = Window:CreateTab("🧍 PLAYER", 4483362458)

local quantidadeCarvao = "2"
local quantidadeFerro = "1"
local quantidadePedra = "1"
local quantidadeMadeira = "4"
local quantidadeFruta = "3"
local quantidadeGold = "2"

local function criarGerador(nome, itemID, getQuantidade)
	MainTab:CreateToggle({
		Name = nome,
		CurrentValue = false,
		Callback = function(state)
			getgenv()[itemID.."Ativo"] = state
			task.spawn(function()
				while getgenv()[itemID.."Ativo"] do
					local char = game.Players.LocalPlayer.Character
					if char and char:FindFirstChild("HumanoidRootPart") then
						local pos = char.HumanoidRootPart.CFrame
						local args = { itemID, pos, 0.5, tonumber(getQuantidade()) or 1 }
						game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("CreateItem"):FireServer(unpack(args))
					end
					task.wait(0.2)
				end
			end)
		end,
	})
end

local function criarInput(nome, default, callback)
	MainTab:CreateInput({
		Name = nome,
		PlaceholderText = "Ex: " .. default,
		RemoveTextAfterFocusLost = true,
		Callback = function(input)
			local valor = math.clamp(tonumber(input) or tonumber(default), 1, 10)
			callback(tostring(valor))
		end,
	})
end

criarGerador("🪨 RECEBER PEDRA", "stone1", function() return quantidadePedra end)
criarInput("Quantidade de pedra (máx. 10)", "1", function(v) quantidadePedra = v end)

criarGerador("🌲 RECEBER MADEIRA", "wood1", function() return quantidadeMadeira end)
criarInput("Quantidade de madeira (máx. 10)", "4", function(v) quantidadeMadeira = v end)

criarGerador("⚫ RECEBER CARVÃO", "coal1", function() return quantidadeCarvao end)
criarInput("Quantidade de carvão (máx. 10)", "2", function(v) quantidadeCarvao = v end)

criarGerador("⛓️ RECEBER FERRO", "ore1", function() return quantidadeFerro end)
criarInput("Quantidade de ferro (máx. 10)", "1", function(v) quantidadeFerro = v end)

criarGerador("🍒 RECEBER FRUTA", "berry1", function() return quantidadeFruta end)
criarInput("Quantidade de fruta (máx. 10)", "3", function(v) quantidadeFruta = v end)

criarGerador("💰 GANHAR GOLDS", "gold1", function() return quantidadeGold end)
criarInput("Quantidade de gold (máx. 10)", "2", function(v) quantidadeGold = v end)

MainTab:CreateToggle({
	Name = "🆘 CHAMAR SOBREVIVENTES",
	CurrentValue = false,
	Callback = function(state)
		getgenv().chamarSobreviventesAtivo = state
		task.spawn(function()
			while getgenv().chamarSobreviventesAtivo do
				local args = { "Survivors" }
				game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
					:WaitForChild("ScreenGui"):WaitForChild("NextDay"):WaitForChild("NextDay")
					:WaitForChild("NextDay"):WaitForChild("ConsoleClick"):FireServer(unpack(args))
				task.wait(0.2)
			end
		end)
	end,
})

MainTab:CreateToggle({
	Name = "💵 GANHAR MONEY",
	CurrentValue = false,
	Callback = function(state)
		getgenv().ganharMoneyAtivo = state
		task.spawn(function()
			while getgenv().ganharMoneyAtivo do
				local args = { "Money" }
				game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
					:WaitForChild("ScreenGui"):WaitForChild("NextDay"):WaitForChild("NextDay")
					:WaitForChild("NextDay"):WaitForChild("ConsoleClick"):FireServer(unpack(args))
				task.wait(0.5)
			end
		end)
	end,
})

MainTab:CreateToggle({
	Name = "⚡ DUPLICAR MONEY (rápido e barulhento)",
	CurrentValue = false,
	Callback = function(state)
		getgenv().dupe = state
		if state then
			if getgenv().dupeConnection then getgenv().dupeConnection:Disconnect() end
			getgenv().dupeConnection = game:GetService("RunService").Heartbeat:Connect(function()
				if getgenv().dupe then
					game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("SkipDay"):FireServer()
				end
			end)
		else
			if getgenv().dupeConnection then
				getgenv().dupeConnection:Disconnect()
				getgenv().dupeConnection = nil
			end
		end
	end,
})

local quantidadeSkip = "10"

MainTab:CreateToggle({
	Name = "⏩ SKIP DIA",
	CurrentValue = false,
	Callback = function(state)
		getgenv().skipDiaAtivo = state
		if state then
			if getgenv().skipDiaConnection then getgenv().skipDiaConnection:Disconnect() end
			getgenv().skipDiaConnection = game:GetService("RunService").Heartbeat:Connect(function()
				local vezes = math.clamp(tonumber(quantidadeSkip) or 10, 1, 100)
				for i = 1, vezes do
					game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("SkipDay"):FireServer()
				end
			end)
		else
			if getgenv().skipDiaConnection then
				getgenv().skipDiaConnection:Disconnect()
				getgenv().skipDiaConnection = nil
			end
		end
	end,
})

MainTab:CreateInput({
	Name = "Quantidade de skip por ciclo (máx. 100)",
	PlaceholderText = "Ex: 10",
	RemoveTextAfterFocusLost = true,
	Callback = function(input)
		local valor = math.clamp(tonumber(input) or 10, 1, 100)
		quantidadeSkip = tostring(valor)
	end,
})

-- ABA PLAYER --------------------------------------------------------------

local velocidade = 20
local pulo = 50

local velocidadeToggle = PlayerTab:CreateToggle({
	Name = "⚡ VELOCIDADE MODIFICADA",
	CurrentValue = false,
	Callback = function(state)
		getgenv().velocidadeAtiva = state
		task.spawn(function()
			while getgenv().velocidadeAtiva do
				local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum then hum.WalkSpeed = velocidade end
				task.wait(0.1)
			end
		end)
	end,
})

local velocidadeSlider = PlayerTab:CreateSlider({
	Name = "Definir velocidade",
	Range = {20, 255},
	Increment = 1,
	CurrentValue = 20,
	Callback = function(v)
		velocidade = v
	end,
})

local jumpToggle = PlayerTab:CreateToggle({
	Name = "🦘 JUMP MODIFICADO",
	CurrentValue = false,
	Callback = function(state)
		getgenv().jumpAtivo = state
		task.spawn(function()
			while getgenv().jumpAtivo do
				local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum then hum.JumpPower = pulo end
				task.wait(0.1)
			end
		end)
	end,
})

local jumpSlider = PlayerTab:CreateSlider({
	Name = "Definir força do Jump",
	Range = {50, 300},
	Increment = 1,
	CurrentValue = 50,
	Callback = function(v)
		pulo = v
	end,
})

PlayerTab:CreateLabel("🌈 FUNÇÕES VISUAIS")

PlayerTab:CreateToggle({
	Name = "👁️ ESP (Aura Visual dos Humanoids)",
	CurrentValue = false,
	Callback = function(state)
		getgenv().espAtivo = state
		task.spawn(function()
			while getgenv().espAtivo do
				for _, v in pairs(workspace:GetDescendants()) do
					if v:IsA("Humanoid") and v.Parent and not game.Players:FindFirstChild(v.Parent.Name) then
						if not v.Parent:FindFirstChild("ESPBox") then
							local highlight = Instance.new("Highlight")
							highlight.Name = "ESPBox"
							highlight.Adornee = v.Parent
							highlight.FillTransparency = 0.5
							local nome = string.lower(v.Parent.Name)
							if nome:find("zombie") or (v.Parent:FindFirstChild("Head") and v.Parent.Head.Color == Color3.fromRGB(0, 255, 0)) then
								highlight.FillColor = Color3.fromRGB(255, 0, 0)
							else
								highlight.FillColor = Color3.fromRGB(0, 255, 0)
							end
							highlight.Parent = v.Parent
						end
					end
				end
				task.wait(0.5)
			end
			for _, v in pairs(workspace:GetDescendants()) do
				if v:IsA("Highlight") and v.Name == "ESPBox" then v:Destroy() end
			end
		end)
	end,
})

PlayerTab:CreateToggle({
	Name = "🚫 NOCLIP",
	CurrentValue = false,
	Callback = function(state)
		getgenv().noclipAtivo = state
		game:GetService("RunService").Stepped:Connect(function()
			if getgenv().noclipAtivo then
				for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
			end
		end)
	end,
})

PlayerTab:CreateToggle({
	Name = "♾️ INFINITE JUMP",
	CurrentValue = false,
	Callback = function(state)
		getgenv().infJump = state
		local uis = game:GetService("UserInputService")
		uis.JumpRequest:Connect(function()
			if getgenv().infJump then
				local humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if humanoid then humanoid:ChangeState("Jumping") end
			end
		end)
	end,
}) local ConfigTab = Window:CreateTab("⚙️ CONFIGURAÇÕES", 4483362458)

ConfigTab:CreateToggle({
	Name = "🔄 ANTI-AFK (Evita ser kickado por inatividade)",
	CurrentValue = false,
	Callback = function(state)
		getgenv().antiAFKAtivo = state
		if state then
			getgenv().antiAFKCon = game:GetService("Players").LocalPlayer.Idled:Connect(function()
				game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
				task.wait(1)
				game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
			end)
		else
			if getgenv().antiAFKCon then
				getgenv().antiAFKCon:Disconnect()
				getgenv().antiAFKCon = nil
			end
		end
	end,
})

ConfigTab:CreateToggle({
	Name = "🚫 ANTI-BAN (Bloqueia tentativas simples de Kick)",
	CurrentValue = false,
	Callback = function(state)
		getgenv().antiBanAtivo = state
		if state then
			getgenv().oldKick = getgenv().oldKick or hookfunction(game.Players.LocalPlayer.Kick, function() end)
			getgenv().oldDestroy = getgenv().oldDestroy or hookfunction(game:GetService("CoreGui").Destroy, function() end)
		else
			if getgenv().oldKick then
				hookfunction(game.Players.LocalPlayer.Kick, getgenv().oldKick)
				getgenv().oldKick = nil
			end
			if getgenv().oldDestroy then
				hookfunction(game:GetService("CoreGui").Destroy, getgenv().oldDestroy)
				getgenv().oldDestroy = nil
			end
		end
	end,
})

ConfigTab:CreateToggle({
	Name = "⚡ MODO DESEMPENHO (Otimizar FPS)",
	CurrentValue = false,
	Callback = function(state)
		getgenv().modoDesempenho = state
		if state then
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
			for _, v in pairs(workspace:GetDescendants()) do
				if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic v.Reflectance = 0 end
				if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
				if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then v.Enabled = false end
			end
			game.Lighting.GlobalShadows = false
			game.Lighting.FogEnd = 9e9
			game.Lighting.Brightness = 1
		else
			settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
			for _, v in pairs(workspace:GetDescendants()) do
				if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 0 end
				if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then v.Enabled = true end
			end
			game.Lighting.GlobalShadows = true
			game.Lighting.FogEnd = 1000
			game.Lighting.Brightness = 2
		end
	end,
})

ConfigTab:CreateLabel("🧠 OTIMIZAÇÕES EXTRAS")

ConfigTab:CreateButton({
	Name = "🧹 LIMPAR ITENS SOLTOS NO MAPA",
	Callback = function()
		local count = 0
		for _, v in pairs(workspace:GetChildren()) do
			if v:IsA("Tool") or v:IsA("Accessory") or v:IsA("Hat") then
				v:Destroy()
				count += 1
			end
		end
		Rayfield:Notify({
			Title = "🧹 Limpeza Concluída",
			Content = tostring(count).." itens removidos do mapa.",
			Duration = 4
		})
	end,
})
