local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()

local Window = Rayfield:CreateWindow({
	Name = "Painel de Recursos",
	LoadingTitle = "Carregando Sistema...",
	LoadingSubtitle = "By Ranox",
	ConfigurationSaving = {Enabled = false}
})

local MainTab = Window:CreateTab("💎 RECURSOS", 4483362458)
local PlayerTab = Window:CreateTab("🧍 PLAYER", 4483362458)
local ConfigTab = Window:CreateTab("⚙️ CONFIGURAÇÕES", 4483362458)

-- Variáveis de quantidade
local quantidadeCarvao, quantidadeFerro, quantidadePedra, quantidadeMadeira, quantidadeFruta, quantidadeGold = "2","1","1","4","3","2"

-- Função para criar geradores de recursos
local function criarGerador(nome,itemID,getQuantidade)
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
						local args = {itemID, pos, 0.5, tonumber(getQuantidade()) or 1}
						game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("CreateItem"):FireServer(unpack(args))
					end
					task.wait(0.2)
				end
			end)
		end
	})
end

-- Função para criar campos de quantidade
local function criarInput(nome,default,callback)
	MainTab:CreateInput({
		Name = nome,
		PlaceholderText = "Ex: "..default,
		RemoveTextAfterFocusLost = true,
		Callback = function(input)
			local valor = math.clamp(tonumber(input) or tonumber(default), 1, 10)
			callback(tostring(valor))
		end
	})
end

-- ========== SECÇÃO: GERAÇÃO DE RECURSOS ==========
MainTab:CreateLabel("─── ⛏️ GERAÇÃO DE RECURSOS ───")

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

-- ========== SECÇÃO: FUNÇÕES AVANÇADAS ==========
MainTab:CreateLabel("─── ⚔️ FUNÇÕES AVANÇADAS ───")

MainTab:CreateToggle({
	Name = "🆘 CHAMAR SOBREVIVENTES",
	CurrentValue = false,
	Callback = function(state)
		getgenv().chamarSobreviventesAtivo = state
		task.spawn(function()
			while getgenv().chamarSobreviventesAtivo do
				local args = {"Survivors"}
				game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("NextDay"):WaitForChild("NextDay"):WaitForChild("NextDay"):WaitForChild("ConsoleClick"):FireServer(unpack(args))
				task.wait(0.2)
			end
		end)
	end
})

MainTab:CreateToggle({
	Name = "💵 GANHAR MONEY",
	CurrentValue = false,
	Callback = function(state)
		getgenv().ganharMoneyAtivo = state
		task.spawn(function()
			while getgenv().ganharMoneyAtivo do
				local args = {"Money"}
				game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("NextDay"):WaitForChild("NextDay"):WaitForChild("NextDay"):WaitForChild("ConsoleClick"):FireServer(unpack(args))
				task.wait(0.5)
			end
		end)
	end
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
	end
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
	end
})

MainTab:CreateInput({
	Name = "Quantidade de skip por ciclo (máx. 100)",
	PlaceholderText = "Ex: 10",
	RemoveTextAfterFocusLost = true,
	Callback = function(input)
		local valor = math.clamp(tonumber(input) or 10, 1, 100)
		quantidadeSkip = tostring(valor)
	end
})

-- ========== SECÇÃO: CURAR TODOS (CORRIGIDA) ==========
MainTab:CreateLabel("─── 💚 CURAR TODOS (Exceto Zombies) ───")

MainTab:CreateToggle({
	Name = "💚 CURAR TODOS (Aliados, Players, Construções)",
	CurrentValue = false,
	Callback = function(state)
		getgenv().curarTodosAtivo = state
		if state then
			getgenv().curarTodosConnection = game:GetService("RunService").Heartbeat:Connect(function()
				if not getgenv().curarTodosAtivo then return end

				local player = game.Players.LocalPlayer
				local char = player.Character
				local localHum = char and char:FindFirstChildOfClass("Humanoid")

				local healGun = player.Backpack:FindFirstChild("HealGun") or (char and char:FindFirstChild("HealGun"))
				if not healGun then return end

				local healEvent = healGun:FindFirstChild("HealEvent")
				if not healEvent then return end

				local waveFolder = workspace:FindFirstChild("WaveZombies")
				local mapFolder = workspace:FindFirstChild("MapZombies")

				local healedCount = 0
				local maxPerFrame = 10  -- Limite para evitar lag (ajustável conforme necessário)

				-- 🔥 PRIORIDADE MÁXIMA: Jogador local sempre primeiro, se estiver ferido
				if localHum and localHum.Health > 0 and localHum.Health < localHum.MaxHealth then
					healEvent:FireServer(char:GetFullName())
					healedCount = 1
				end

				-- Depois cura os restantes (não zombies, só quem não está com vida cheia)
				for _, obj in ipairs(workspace:GetDescendants()) do
					if healedCount >= maxPerFrame then break end
					if obj:IsA("Humanoid") and obj.Health > 0 and obj.Health < obj.MaxHealth then
						local model = obj.Parent
						if model and model:IsA("Model") then
							-- Ignora zombies
							if (waveFolder and model:IsDescendantOf(waveFolder)) or (mapFolder and model:IsDescendantOf(mapFolder)) then
								continue
							end
							-- Ignora o personagem local (já curado)
							if model == char then continue end
							healEvent:FireServer(model:GetFullName())
							healedCount += 1
						end
					end
				end
			end)
		else
			getgenv().curarTodosAtivo = false
			if getgenv().curarTodosConnection then
				getgenv().curarTodosConnection:Disconnect()
				getgenv().curarTodosConnection = nil
			end
		end
	end
})

-- ========== SECÇÃO: KILL AURA (WaveZombies) ==========
MainTab:CreateLabel("─── 🧟 KILL AURA (WaveZombies) ───")

MainTab:CreateToggle({
	Name = "⚔️ KILL AURA (Atacar Zombies da Wave)",
	CurrentValue = false,
	Callback = function(state)
		getgenv().killAuraAtivo = state
		if state then
			getgenv().killAuraConnection = game:GetService("RunService").Heartbeat:Connect(function()
				if not getgenv().killAuraAtivo then return end

				local player = game.Players.LocalPlayer
				local machete = player.Backpack:FindFirstChild("Machete") or (player.Character and player.Character:FindFirstChild("Machete"))
				if not machete then return end

				local remote = machete:FindFirstChild("doDamage")
				if not remote then return end

				local zombiesFolder = workspace:FindFirstChild("WaveZombies")
				if not zombiesFolder then return end

				for _, obj in ipairs(zombiesFolder:GetDescendants()) do
					if obj:IsA("Humanoid") and obj.Health > 0 then
						local char = obj.Parent
						if char and char:IsA("Model") then
							local isPlayer = game.Players:GetPlayerFromCharacter(char)
							if not isPlayer then
								remote:FireServer(obj, false)
							end
						end
					end
				end
			end)
		else
			getgenv().killAuraAtivo = false
			if getgenv().killAuraConnection then
				getgenv().killAuraConnection:Disconnect()
				getgenv().killAuraConnection = nil
			end
		end
	end
})

-- ========== SECÇÃO: MAP KILL AURA (MapZombies) ==========
MainTab:CreateLabel("─── 🗺️ MAP KILL AURA (MapZombies) ───")

MainTab:CreateToggle({
	Name = "⚔️ MAP KILL AURA (Atacar Zombies do Mapa)",
	CurrentValue = false,
	Callback = function(state)
		getgenv().mapKillAuraAtivo = state
		if state then
			getgenv().mapKillAuraConnection = game:GetService("RunService").Heartbeat:Connect(function()
				if not getgenv().mapKillAuraAtivo then return end

				local player = game.Players.LocalPlayer
				local machete = player.Backpack:FindFirstChild("Machete") or (player.Character and player.Character:FindFirstChild("Machete"))
				if not machete then return end

				local remote = machete:FindFirstChild("doDamage")
				if not remote then return end

				local zombiesFolder = workspace:FindFirstChild("MapZombies")
				if not zombiesFolder then return end

				for _, obj in ipairs(zombiesFolder:GetDescendants()) do
					if obj:IsA("Humanoid") and obj.Health > 0 then
						local char = obj.Parent
						if char and char:IsA("Model") then
							local isPlayer = game.Players:GetPlayerFromCharacter(char)
							if not isPlayer then
								remote:FireServer(obj, false)
							end
						end
					end
				end
			end)
		else
			getgenv().mapKillAuraAtivo = false
			if getgenv().mapKillAuraConnection then
				getgenv().mapKillAuraConnection:Disconnect()
				getgenv().mapKillAuraConnection = nil
			end
		end
	end
})

-- ========== SECÇÃO: DANO INFINITO ==========
MainTab:CreateLabel("─── 🎯 DANO INFINITO PARA TODOS ───")

MainTab:CreateToggle({
	Name = "🎯 DANO INFINITO (Ao sofrer dano, foca o zombie até morrer)",
	CurrentValue = false,
	Callback = function(state)
		getgenv().danoInfinitoAtivo = state
		if state then
			getgenv().danoInfinitoAttacks = {}
			getgenv().danoInfinitoHealthConns = {}

			local function isZombie(humanoid)
				local char = humanoid.Parent
				if not char or not char:IsA("Model") then return false end
				return not game.Players:GetPlayerFromCharacter(char)
			end

			local function startAttack(humanoid)
				if getgenv().danoInfinitoAttacks[humanoid] then return end

				local function getRemote()
					local player = game.Players.LocalPlayer
					local machete = player.Backpack:FindFirstChild("Machete") or (player.Character and player.Character:FindFirstChild("Machete"))
					if machete then
						return machete:FindFirstChild("doDamage")
					end
					return nil
				end

				local remote = getRemote()
				if not remote then return end

				local conn
				conn = game:GetService("RunService").Heartbeat:Connect(function()
					if not getgenv().danoInfinitoAtivo then
						conn:Disconnect()
						getgenv().danoInfinitoAttacks[humanoid] = nil
						return
					end
					if humanoid.Health <= 0 or not humanoid.Parent then
						conn:Disconnect()
						getgenv().danoInfinitoAttacks[humanoid] = nil
						return
					end
					local currentRemote = getRemote()
					if currentRemote then
						currentRemote:FireServer(humanoid, false)
					else
						conn:Disconnect()
						getgenv().danoInfinitoAttacks[humanoid] = nil
					end
				end)
				getgenv().danoInfinitoAttacks[humanoid] = conn
			end

			local function connectHumanoid(humanoid)
				if not isZombie(humanoid) then return end
				if getgenv().danoInfinitoHealthConns[humanoid] then return end

				local lastHealth = humanoid.Health
				local conn = humanoid.HealthChanged:Connect(function(newHealth)
					if not getgenv().danoInfinitoAtivo then return end
					if newHealth < lastHealth then
						startAttack(humanoid)
					end
					lastHealth = newHealth
				end)
				getgenv().danoInfinitoHealthConns[humanoid] = conn
			end

			local function scanFolder(folder)
				if not folder then return end
				for _, obj in ipairs(folder:GetDescendants()) do
					if obj:IsA("Humanoid") then
						connectHumanoid(obj)
					end
				end
			end

			scanFolder(workspace:FindFirstChild("WaveZombies"))
			scanFolder(workspace:FindFirstChild("MapZombies"))

			local waveFolder = workspace:FindFirstChild("WaveZombies")
			local mapFolder = workspace:FindFirstChild("MapZombies")

			if waveFolder then
				waveFolder.DescendantAdded:Connect(function(desc)
					if desc:IsA("Humanoid") then
						connectHumanoid(desc)
					end
				end)
			end
			if mapFolder then
				mapFolder.DescendantAdded:Connect(function(desc)
					if desc:IsA("Humanoid") then
						connectHumanoid(desc)
					end
				end)
			end
		else
			getgenv().danoInfinitoAtivo = false
			if getgenv().danoInfinitoAttacks then
				for _, conn in pairs(getgenv().danoInfinitoAttacks) do
					conn:Disconnect()
				end
				getgenv().danoInfinitoAttacks = {}
			end
			if getgenv().danoInfinitoHealthConns then
				for _, conn in pairs(getgenv().danoInfinitoHealthConns) do
					conn:Disconnect()
				end
				getgenv().danoInfinitoHealthConns = {}
			end
		end
	end
})

-- ========== ABA PLAYER ==========

-- Velocidade e pulo
local velocidade, pulo = 20, 50

PlayerTab:CreateLabel("─── 🏃 MOVIMENTO ───")

PlayerTab:CreateToggle({
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
	end
})

PlayerTab:CreateSlider({
	Name = "Definir velocidade",
	Range = {20, 255},
	Increment = 1,
	CurrentValue = 20,
	Callback = function(v) velocidade = v end
})

PlayerTab:CreateToggle({
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
	end
})

PlayerTab:CreateSlider({
	Name = "Definir força do Jump",
	Range = {50, 300},
	Increment = 1,
	CurrentValue = 50,
	Callback = function(v) pulo = v end
})

-- ========== SECÇÃO: FUNÇÕES VISUAIS ==========
PlayerTab:CreateLabel("─── 🌈 FUNÇÕES VISUAIS ───")

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
							local h = Instance.new("Highlight")
							h.Name = "ESPBox"
							h.Adornee = v.Parent
							h.FillTransparency = 0.5
							local nome = string.lower(v.Parent.Name)
							if nome:find("zombie") then
								h.FillColor = Color3.fromRGB(255, 0, 0)
							else
								h.FillColor = Color3.fromRGB(0, 255, 0)
							end
							h.OutlineColor = Color3.fromRGB(255, 255, 255)
							h.Parent = v.Parent
						end
					end
				end
				for _, v in pairs(workspace:GetDescendants()) do
					if v:IsA("Highlight") and v.Name == "ESPBox" and (not v.Adornee or not v.Adornee:FindFirstChildOfClass("Humanoid")) then
						v:Destroy()
					end
				end
				task.wait(3)
			end
			for _, v in pairs(workspace:GetDescendants()) do
				if v:IsA("Highlight") and v.Name == "ESPBox" then v:Destroy() end
			end
		end)
	end
})

PlayerTab:CreateToggle({
	Name = "🚫 NOCLIP",
	CurrentValue = false,
	Callback = function(state)
		getgenv().noclipAtivo = state
		game:GetService("RunService").Stepped:Connect(function()
			if getgenv().noclipAtivo then
				for _, p in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide = false end
				end
			end
		end)
	end
})

PlayerTab:CreateToggle({
	Name = "♾️ INFINITE JUMP",
	CurrentValue = false,
	Callback = function(state)
		getgenv().infJump = state
		game:GetService("UserInputService").JumpRequest:Connect(function()
			if getgenv().infJump then
				local h = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if h then h:ChangeState("Jumping") end
			end
		end)
	end
})

-- ========== ABA CONFIGURAÇÕES ==========

ConfigTab:CreateToggle({
	Name = "🔄 ANTI-AFK",
	CurrentValue = false,
	Callback = function(state)
		getgenv().antiAFKAtivo = state
		if state then
			getgenv().antiAFKCon = game:GetService("Players").LocalPlayer.Idled:Connect(function()
				game:GetService("VirtualUser"):Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
				task.wait(1)
				game:GetService("VirtualUser"):Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
			end)
		elseif getgenv().antiAFKCon then
			getgenv().antiAFKCon:Disconnect()
			getgenv().antiAFKCon = nil
		end
	end
})

ConfigTab:CreateToggle({
	Name = "🚫 ANTI-BAN",
	CurrentValue = false,
	Callback = function(state)
		getgenv().antiBanAtivo = state
		if state then
			getgenv().oldKick = getgenv().oldKick or hookfunction(game.Players.LocalPlayer.Kick, function() end)
			getgenv().oldDestroy = getgenv().oldDestroy or hookfunction(game:GetService("CoreGui").Destroy, function() end)
		else
			if getgenv().oldKick then hookfunction(game.Players.LocalPlayer.Kick, getgenv().oldKick) getgenv().oldKick = nil end
			if getgenv().oldDestroy then hookfunction(game:GetService("CoreGui").Destroy, getgenv().oldDestroy) getgenv().oldDestroy = nil end
		end
	end
})

ConfigTab:CreateToggle({
	Name = "⚡ MODO DESEMPENHO",
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
	end
})

ConfigTab:CreateLabel("🧠 OTIMIZAÇÕES EXTRAS")

ConfigTab:CreateButton({
	Name = "🧹 LIMPAR ITENS SOLTOS NO MAPA",
	Callback = function()
		local count = 0
		for _, v in pairs(workspace:GetChildren()) do
			if v:IsA("Tool") or v:IsA("Accessory") or v:IsA("Hat") then v:Destroy() count += 1 end
		end
		Rayfield:Notify({Title = "🧹 Limpeza Concluída", Content = tostring(count).." itens removidos.", Duration = 4})
	end
})

-- Notificação de carregamento
task.spawn(function()
	pcall(function()
		Rayfield:Notify({
			Title = "🚀 INTERFACE CARREGADA!",
			Content = "💎 CRIADOR OFICIAL: SAMUEL 💎\n✨ Sistema iniciado com sucesso!",
			Duration = 6,
			Image = 4483362458
		})
	end)
end)
