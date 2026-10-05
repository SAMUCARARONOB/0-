--[[
    ═══════════════════════════════════════════════════════════════════════
      APOCALYPSE ENGINE · v3.0 · PRO EDITION
      • Tornado configurável (tipo + tamanho + ambientação)
      • Climate Lock — sobrescreve clima/horário externos a cada frame
      • Visual 10x mais detalhado em todos os desastres
      • Mobile-first, single-script, zero setup
    ═══════════════════════════════════════════════════════════════════════
]]

-- ======================================================================
-- SERVICES
-- ======================================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local Debris           = game:GetService("Debris")
local SoundService     = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ======================================================================
-- CONFIG GERAL
-- ======================================================================
local CONFIG = {
    ParticleMultiplier = IS_MOBILE and 0.45 or 1,
    MaxMeteors         = IS_MOBILE and 6 or 12,
    MaxTornados        = IS_MOBILE and 1 or 3,
    SoundVolume        = 0.75,
    CameraShake        = true,
    AutoAreaRadius     = 300,
    AutoAreaHeight     = 400,
    MaxDebris          = IS_MOBILE and 10 or 25,
}

-- ======================================================================
-- HELPERS
-- ======================================================================
local function tw(i, d, p, s, dir)
    local t = TweenService:Create(i, TweenInfo.new(d, s or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), p)
    t:Play(); return t
end

local tracked = {}
local function track(inst) table.insert(tracked, inst); return inst end

local function cleanupAll()
    for _, inst in ipairs(tracked) do
        if typeof(inst) == "Instance" and inst.Parent then
            pcall(function() inst:Destroy() end)
        end
    end
    tracked = {}
end

local function randPos(radius, height)
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local c = root and Vector3.new(root.Position.X, 0, root.Position.Z) or Vector3.new(0,0,0)
    local a = math.random() * math.pi * 2
    local r = math.sqrt(math.random()) * radius
    return c + Vector3.new(math.cos(a)*r, height or 0, math.sin(a)*r)
end

-- ======================================================================
-- CLIMATE LOCK — Sobrescreve qualquer sistema externo de clima/horário
-- ======================================================================
local ClimateLock = {
    active = false,
    values = {},
    conn1 = nil,
    conn2 = nil,
    externalOverrides = 0,
}

function ClimateLock:Set(props)
    self.values = props
    self.active = true

    if not self.conn1 then
        -- Re-aplica a cada frame (60fps) — vence qualquer sistema de 0.5s
        self.conn1 = RunService.Heartbeat:Connect(function()
            if not self.active then return end
            for k, v in pairs(self.values) do
                pcall(function() Lighting[k] = v end)
            end
        end)
    end

    if not self.conn2 then
        -- Re-aplica IMEDIATAMENTE se algo externo mudar
        self.conn2 = Lighting.Changed:Connect(function(prop)
            if not self.active then return end
            if self.values[prop] ~= nil then
                pcall(function() Lighting[prop] = self.values[prop] end)
                self.externalOverrides += 1
            end
        end)
    end
end

function ClimateLock:Clear()
    self.active = false
    self.values = {}
end

-- Snapshot original
local savedLighting = nil
local function snapshotLighting()
    if savedLighting then return end
    savedLighting = {
        ClockTime = Lighting.ClockTime,
        Brightness = Lighting.Brightness,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        FogColor = Lighting.FogColor,
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
        ExposureCompensation = Lighting.ExposureCompensation,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
    }
end

local function restoreLighting()
    if not savedLighting then return end
    ClimateLock:Clear()
    for k, v in pairs(savedLighting) do
        pcall(function() Lighting[k] = v end)
    end
end

-- ======================================================================
-- SOUNDS
-- ======================================================================
local SOUNDS = {
    Thunder   = "rbxassetid://131961136",
    Explosion = "rbxassetid://9125402735",
    Wind      = "rbxassetid://131886985",
}

local function play2D(key, vol)
    local id = SOUNDS[key]; if not id then return end
    local s = Instance.new("Sound")
    s.SoundId = id; s.Volume = (vol or 1) * CONFIG.SoundVolume
    s.Parent = SoundService; s:Play()
    Debris:AddItem(s, 8)
end

local function play3D(key, pos, vol, range)
    local id = SOUNDS[key]; if not id then return end
    local a = Instance.new("Part")
    a.Anchored = true; a.CanCollide = false; a.Transparency = 1
    a.Size = Vector3.new(1,1,1); a.Position = pos; a.Parent = Workspace
    track(a)
    local s = Instance.new("Sound")
    s.SoundId = id; s.Volume = (vol or 1) * CONFIG.SoundVolume
    s.RollOffMode = Enum.RollOffMode.InverseTapered
    s.RollOffMaxDistance = range or 400
    s.RollOffMinDistance = 20
    s.Parent = a; s:Play()
    Debris:AddItem(a, 8)
end

-- ======================================================================
-- CAMERA SHAKE
-- ======================================================================
local shakeAmount, noiseTime = 0, 0
RunService.RenderStepped:Connect(function(dt)
    if not CONFIG.CameraShake then return end
    noiseTime += dt * 22
    shakeAmount = math.max(0, shakeAmount - dt * 9 * shakeAmount)
    if shakeAmount > 0.001 and camera then
        local a = shakeAmount
        camera.CFrame = camera.CFrame * CFrame.new(
            math.noise(noiseTime, 0, 0) * a,
            math.noise(0, noiseTime, 0) * a,
            math.noise(0, 0, noiseTime) * a * 0.5
        )
    end
end)
local function shake(a) shakeAmount = math.min(shakeAmount + a, 3.5) end

-- ======================================================================
-- PARTICLES
-- ======================================================================
local function burst(pos, tex, c1, c2, s1, s2, life, count, speed, lightEmission)
    local p = Instance.new("Part")
    p.Anchored = true; p.CanCollide = false; p.Transparency = 1
    p.Size = Vector3.new(1,1,1); p.Position = pos; p.Parent = Workspace
    track(p)
    local em = Instance.new("ParticleEmitter")
    em.Texture = tex or "rbxassetid://243660364"
    em.Color = ColorSequence.new(c1, c2 or c1)
    em.Size = NumberSequence.new(s1 or 1, s2 or 3)
    em.Transparency = NumberSequence.new(0.15, 1)
    em.Lifetime = NumberRange.new(life or 1, (life or 1) * 2)
    em.Speed = NumberRange.new(speed or 10, (speed or 10) * 2)
    em.SpreadAngle = Vector2.new(180, 180)
    em.Rate = 0
    em.LightEmission = lightEmission or 0.8
    em.Parent = p
    em:Emit(math.floor((count or 20) * CONFIG.ParticleMultiplier))
    Debris:AddItem(p, (life or 1) * 3)
end

local function fireBurst(pos, size, count) 
    burst(pos, nil, Color3.fromRGB(255,200,60), Color3.fromRGB(180,40,20), size*0.4, size*1.4, 1, count, size*4, 1) 
end
local function smokeBurst(pos, size, count) 
    burst(pos, nil, Color3.fromRGB(60,60,60), Color3.fromRGB(30,30,30), size*0.5, size*2, 1.5, count, size*2, 0.2) 
end
local function emberBurst(pos, size, count)
    burst(pos, nil, Color3.fromRGB(255,140,30), Color3.fromRGB(200,40,10), size*0.2, size*0.5, 0.8, count, size*3, 1)
end

-- ======================================================================
-- EXPLOSION SYSTEM
-- ======================================================================
local EXPLOSION_PRESETS = {
    SMALL  = { radius=6,  fire=25, smoke=12, ember=15, light=15, shake=0.15, shock=8 },
    MEDIUM = { radius=12, fire=50, smoke=25, ember=30, light=35, shake=0.35, shock=16 },
    LARGE  = { radius=22, fire=80, smoke=45, ember=50, light=60, shake=0.6,  shock=30 },
    MEGA   = { radius=40, fire=140, smoke=80, ember=90, light=100, shake=1.0, shock=55 },
    COSMIC = { radius=70, fire=220, smoke=140, ember=150, light=180, shake=1.6, shock=100 },
}

local function spawnExplosion(pos, tier)
    local pr = EXPLOSION_PRESETS[tier or "MEDIUM"] or EXPLOSION_PRESETS.MEDIUM
    local core = Instance.new("Part")
    core.Shape = Enum.PartType.Ball
    core.Material = Enum.Material.Neon
    core.Color = Color3.fromRGB(255, 230, 150)
    core.Size = Vector3.new(2,2,2)
    core.Anchored = true; core.CanCollide = false
    core.Position = pos; core.Parent = Workspace
    track(core)
    local light = Instance.new("PointLight")
    light.Brightness = pr.light; light.Range = pr.radius*2
    light.Color = Color3.fromRGB(255,200,120); light.Parent = core
    tw(core, 0.4, { Size = Vector3.new(pr.radius*2, pr.radius*2, pr.radius*2), Transparency = 1 }, Enum.EasingStyle.Quart)
    tw(light, 0.6, { Brightness = 0, Range = 0 })
    fireBurst(pos, pr.radius, pr.fire)
    smokeBurst(pos, pr.radius*1.3, pr.smoke)
    emberBurst(pos, pr.radius, pr.ember)
    -- shockwave
    local ring = Instance.new("Part")
    ring.Shape = Enum.PartType.Cylinder
    ring.Material = Enum.Material.Neon
    ring.Color = Color3.fromRGB(255,180,90)
    ring.Size = Vector3.new(1,2,2)
    ring.Anchored = true; ring.CanCollide = false
    ring.CFrame = CFrame.new(pos) * CFrame.Angles(0,0,math.rad(90))
    ring.Parent = Workspace; track(ring)
    local t = tw(ring, 1.2, { Size = Vector3.new(1, pr.shock*2, pr.shock*2), Transparency = 1 }, Enum.EasingStyle.Quart)
    t.Completed:Connect(function() ring:Destroy() end)
    play3D("Explosion", pos, 1, pr.radius * 6)
    shake(pr.shake)
    task.delay(0.6, function() if core.Parent then core:Destroy() end end)
end

-- ======================================================================
-- METEOR SYSTEM (melhorado)
-- ======================================================================
local Meteor = { active = {} }

local METEOR_TYPES = {
    COMMON     = { color=Color3.fromRGB(80,60,50),  glow=Color3.fromRGB(255,140,40),  size=1.0, trail=1,   debris=4 },
    RARE       = { color=Color3.fromRGB(120,90,70), glow=Color3.fromRGB(255,180,60),  size=1.6, trail=1.4, debris=5 },
    GIANT      = { color=Color3.fromRGB(60,50,45),  glow=Color3.fromRGB(255,120,40),  size=3.5, trail=2.2, debris=8 },
    FIRE       = { color=Color3.fromRGB(90,30,10),  glow=Color3.fromRGB(255,80,20),   size=1.3, trail=2.6, debris=6 },
    ICE        = { color=Color3.fromRGB(140,200,255), glow=Color3.fromRGB(120,220,255), size=1.2, trail=1.4, debris=5 },
    ELECTRIC   = { color=Color3.fromRGB(80,100,200), glow=Color3.fromRGB(150,200,255), size=1.3, trail=1.5, debris=5 },
    VOID       = { color=Color3.fromRGB(20,0,40),   glow=Color3.fromRGB(180,60,255),  size=1.4, trail=1.8, debris=5 },
    PLASMA     = { color=Color3.fromRGB(180,60,200), glow=Color3.fromRGB(255,120,255), size=1.5, trail=2.0, debris=6 },
    ANCIENT    = { color=Color3.fromRGB(200,170,90), glow=Color3.fromRGB(255,220,100), size=2.0, trail=1.8, debris=7 },
    APOCALYPSE = { color=Color3.fromRGB(40,0,0),    glow=Color3.fromRGB(255,0,60),    size=5.0, trail=3.5, debris=12 },
}

local function spawnMeteor(startPos, targetPos, mtype)
    if #Meteor.active >= CONFIG.MaxMeteors then return end
    local def = METEOR_TYPES[mtype] or METEOR_TYPES.COMMON
    local baseSize = 3 * def.size * (IS_MOBILE and 0.85 or 1)

    local model = Instance.new("Model", Workspace)
    model.Name = "Meteor"
    track(model)

    -- corpo principal
    local primary = Instance.new("Part")
    primary.Shape = Enum.PartType.Ball
    primary.Material = Enum.Material.Slate
    primary.Color = def.color
    primary.Size = Vector3.new(baseSize, baseSize, baseSize)
    primary.Anchored = true
    primary.CanCollide = false
    primary.CFrame = CFrame.new(startPos)
    primary.Parent = model

    -- pedras orbitando (formato rochoso real)
    local rockCount = IS_MOBILE and math.min(3, def.debris) or def.debris
    for i = 1, rockCount do
        local b = Instance.new("Part")
        b.Shape = Enum.PartType.Ball
        b.Material = Enum.Material.Slate
        b.Color = def.color
        local bs = baseSize * (0.25 + math.random() * 0.35)
        b.Size = Vector3.new(bs, bs, bs)
        b.Anchored = true; b.CanCollide = false
        b.CFrame = primary.CFrame * CFrame.new(
            (math.random()-0.5)*baseSize*0.7,
            (math.random()-0.5)*baseSize*0.7,
            (math.random()-0.5)*baseSize*0.7
        )
        b.Parent = model
    end

    -- glow interior
    local glow = Instance.new("Part")
    glow.Shape = Enum.PartType.Ball
    glow.Material = Enum.Material.Neon
    glow.Color = def.glow
    glow.Size = Vector3.new(baseSize*0.85, baseSize*0.85, baseSize*0.85)
    glow.Anchored = true; glow.CanCollide = false
    glow.CFrame = primary.CFrame
    glow.Transparency = 0.3
    glow.Parent = model

    -- fogo
    local fire = Instance.new("ParticleEmitter")
    fire.Texture = "rbxassetid://243660364"
    fire.Color = ColorSequence.new(def.glow, def.color)
    fire.LightEmission = 1
    fire.Size = NumberSequence.new(baseSize*0.5, baseSize*1.9)
    fire.Transparency = NumberSequence.new(0.1, 1)
    fire.Lifetime = NumberRange.new(0.4, 0.9)
    fire.Speed = NumberRange.new(5, 12)
    fire.SpreadAngle = Vector2.new(180, 180)
    fire.Rate = 30 * CONFIG.ParticleMultiplier * def.trail
    fire.Parent = primary

    -- fumaça
    local smoke = Instance.new("ParticleEmitter")
    smoke.Texture = "rbxassetid://243660364"
    smoke.Color = ColorSequence.new(Color3.fromRGB(40,40,40), Color3.fromRGB(20,20,20))
    smoke.Size = NumberSequence.new(baseSize*0.6, baseSize*2.2)
    smoke.Transparency = NumberSequence.new(0.4, 1)
    smoke.Lifetime = NumberRange.new(0.8, 1.6)
    smoke.Speed = NumberRange.new(3, 8)
    smoke.SpreadAngle = Vector2.new(180, 180)
    smoke.Rate = 15 * CONFIG.ParticleMultiplier
    smoke.Parent = primary

    -- trail duplo (cor + brilho)
    local a1 = Instance.new("Attachment", primary); a1.Position = Vector3.new(0, 0, baseSize*0.4)
    local a2 = Instance.new("Attachment", primary); a2.Position = Vector3.new(0, 0, -baseSize*0.4)
    local trail = Instance.new("Trail")
    trail.Attachment0 = a1; trail.Attachment1 = a2
    trail.Lifetime = 1.2 * def.trail
    trail.MinLength = 0.1
    trail.WidthScale = NumberSequence.new(def.trail*0.8, 0)
    trail.Color = ColorSequence.new(def.glow, def.color)
    trail.Transparency = NumberSequence.new(0.1, 1)
    trail.LightEmission = 1
    trail.Parent = primary

    -- luz
    local light = Instance.new("PointLight")
    light.Color = def.glow
    light.Brightness = 4 * def.size
    light.Range = baseSize * 8
    light.Parent = primary

    local velocity = (targetPos - startPos)
    local speed = IS_MOBILE and 280 or 350
    local dir = velocity.Unit * speed

    table.insert(Meteor.active, {
        model = model, part = primary,
        velocity = dir, life = 0,
        def = def, size = baseSize,
        exploded = false,
    })
    play3D("Wind", startPos, 0.4, 400)
end

local function meteorImpact(m)
    local pos = m.part.Position
    local size = m.size
    local tier = "SMALL"
    if size > 12 then tier = "COSMIC"
    elseif size > 8 then tier = "MEGA"
    elseif size > 5 then tier = "LARGE"
    elseif size > 3 then tier = "MEDIUM" end
    spawnExplosion(pos, tier)

    if m.def.size >= 1.3 then
        local crater = Instance.new("Part")
        crater.Shape = Enum.PartType.Cylinder
        crater.Material = Enum.Material.Slate
        crater.Color = Color3.fromRGB(30,20,15)
        crater.Size = Vector3.new(1, size*4, size*4)
        crater.Anchored = true; crater.CanCollide = false
        crater.CFrame = CFrame.new(pos + Vector3.new(0,-0.5,0)) * CFrame.Angles(0,0,math.rad(90))
        crater.Transparency = 0.2; crater.Parent = Workspace
        track(crater)
        tw(crater, 5, { Transparency = 1 })
        Debris:AddItem(crater, 6)
    end

    local fragCount = math.clamp(math.floor(size * CONFIG.ParticleMultiplier), 2, IS_MOBILE and 8 or 15)
    for i = 1, fragCount do
        local f = Instance.new("Part")
        f.Material = Enum.Material.Slate
        f.Color = m.def.color
        f.Size = Vector3.new(0.5,0.5,0.5)
        f.CanCollide = false
        f.Position = pos + Vector3.new((math.random()-0.5)*4, math.random()*3, (math.random()-0.5)*4)
        f.Parent = Workspace; track(f)
        local tp = f.Position + Vector3.new((math.random()-0.5)*size*2, 5+math.random()*size, (math.random()-0.5)*size*2)
        tw(f, 1, { Position = tp, Transparency = 1, Orientation = Vector3.new(math.random()*360, math.random()*360, math.random()*360) }, Enum.EasingStyle.Quart)
        Debris:AddItem(f, 1.5)
    end
    m.model:Destroy()
end

local function updateMeteors(dt)
    for i = #Meteor.active, 1, -1 do
        local m = Meteor.active[i]
        if not m.part or not m.part.Parent then
            table.remove(Meteor.active, i)
        else
            m.life += dt
            local np = m.part.Position + m.velocity * dt
            m.part.CFrame = CFrame.new(np) * CFrame.Angles(m.life*2, m.life*1.5, m.life*2.3)
            if not m.exploded and (np.Y <= 3 or m.life > 6) then
                m.exploded = true
                meteorImpact(m)
                table.remove(Meteor.active, i)
            end
        end
    end
end

-- ======================================================================
-- LIGHTNING SYSTEM (melhorado)
-- ======================================================================
local LIGHTNING_STYLES = {
    NORMAL = { color=Color3.fromRGB(180,200,255), width=1.5, segments=10, branches=2, flash=6 },
    CHAIN  = { color=Color3.fromRGB(150,220,255), width=1.2, segments=14, branches=4, flash=7 },
    STORM  = { color=Color3.fromRGB(220,230,255), width=2.5, segments=16, branches=5, flash=9 },
    MEGA   = { color=Color3.fromRGB(255,240,200), width=3.5, segments=22, branches=8, flash=14 },
    VOID   = { color=Color3.fromRGB(200,100,255), width=2.2, segments=16, branches=4, flash=8 },
}

local function strikeLightning(startPos, endPos, style)
    style = style or "NORMAL"
    local def = LIGHTNING_STYLES[style] or LIGHTNING_STYLES.NORMAL
    local folder = Instance.new("Folder", Workspace)
    folder.Name = "Lightning"
    track(folder)

    -- flash principal
    local fp = Instance.new("Part", folder)
    fp.Anchored = true; fp.CanCollide = false; fp.Transparency = 1
    fp.Size = Vector3.new(1,1,1); fp.Position = (startPos+endPos)/2
    local fl = Instance.new("PointLight")
    fl.Color = def.color; fl.Brightness = def.flash; fl.Range = 300
    fl.Parent = fp
    tw(fl, 0.3, { Brightness = 0 })

    -- pontos do raio
    local points = { startPos }
    local dir = endPos - startPos
    local segs = IS_MOBILE and math.floor(def.segments*0.7) or def.segments
    for i = 1, segs - 1 do
        local t = i / segs
        local bp = startPos + dir * t
        local off = Vector3.new((math.random()-0.5)*14, (math.random()-0.5)*14, (math.random()-0.5)*14)
        table.insert(points, bp + off)
    end
    table.insert(points, endPos)

    local function drawBolt(pts, w)
        for i = 1, #pts-1 do
            local a, b = pts[i], pts[i+1]
            local mid = (a+b)/2
            local len = (b-a).Magnitude
            local beam = Instance.new("Part", folder)
            beam.Anchored = true; beam.CanCollide = false
            beam.Material = Enum.Material.Neon
            beam.Color = def.color
            beam.Size = Vector3.new(w, w, len)
            beam.CFrame = CFrame.new(mid, b)
            tw(beam, 0.25, { Transparency = 1 })
        end
    end

    drawBolt(points, def.width)

    -- ramificações recursivas
    local function makeBranch(from, depth, angleScale)
        if depth <= 0 then return end
        local endP = from + Vector3.new(
            (math.random()-0.5)*30*angleScale,
            -(math.random()*20 + 5),
            (math.random()-0.5)*30*angleScale
        )
        local bp = { from }
        local steps = 3
        for j = 1, steps do
            local t = j/(steps+1)
            table.insert(bp, from + (endP-from)*t + Vector3.new((math.random()-0.5)*8, (math.random()-0.5)*8, (math.random()-0.5)*8))
        end
        table.insert(bp, endP)
        drawBolt(bp, def.width * 0.5)
        if math.random() < 0.5 then
            makeBranch(bp[math.random(2, #bp-1)], depth-1, angleScale*0.7)
        end
    end

    local brCount = IS_MOBILE and math.min(def.branches, 2) or def.branches
    for i = 1, brCount do
        local idx = math.random(2, #points-1)
        makeBranch(points[idx], 1, 1)
    end

    play3D("Thunder", endPos, 0.9, 700)
    Debris:AddItem(folder, 1.5)
    shake(0.1)
end

-- ======================================================================
-- TORNADO SYSTEM (com configuração completa)
-- ======================================================================
local Tornado = { active = {} }

-- Config atual do tornado
local TornadoConfig = {
    type = "STORM",         -- DUST | STORM | ELECTRIC | FIRE | VOID | APOCALYPSE
    size = "MEDIUM",        -- P | SMALL | MEDIUM | LARGE | GIANT | ULTRA
    ambience = "AUTO",      -- NONE | STORM | FOG | CHAOS | APOC | AUTO
}

local TORNADO_TYPES = {
    DUST       = { outer=Color3.fromRGB(160,130,100), inner=Color3.fromRGB(200,170,140), glow=Color3.fromRGB(255,200,140), light=Color3.fromRGB(255,200,120), rate=30,  debrisC=Color3.fromRGB(130,100,80),  emberC=Color3.fromRGB(200,150,90),  lightning=0,    sound="Wind" },
    STORM      = { outer=Color3.fromRGB(70,80,100),   inner=Color3.fromRGB(120,130,160), glow=Color3.fromRGB(180,200,240), light=Color3.fromRGB(150,180,240), rate=45,  debrisC=Color3.fromRGB(60,70,90),    emberC=Color3.fromRGB(150,180,220), lightning=0.15, sound="Wind" },
    ELECTRIC   = { outer=Color3.fromRGB(60,100,180),  inner=Color3.fromRGB(120,170,240), glow=Color3.fromRGB(180,220,255), light=Color3.fromRGB(140,200,255), rate=50,  debrisC=Color3.fromRGB(70,110,180),  emberC=Color3.fromRGB(180,220,255), lightning=0.5,  sound="Wind" },
    FIRE       = { outer=Color3.fromRGB(180,60,20),   inner=Color3.fromRGB(255,140,40),  glow=Color3.fromRGB(255,180,60),  light=Color3.fromRGB(255,120,40),  rate=55,  debrisC=Color3.fromRGB(120,40,10),   emberC=Color3.fromRGB(255,140,30),  lightning=0,    sound="Wind" },
    VOID       = { outer=Color3.fromRGB(30,10,50),    inner=Color3.fromRGB(100,40,180),  glow=Color3.fromRGB(180,80,255),  light=Color3.fromRGB(180,80,255),  rate=50,  debrisC=Color3.fromRGB(40,10,60),    emberC=Color3.fromRGB(180,80,255),  lightning=0.3,  sound="Wind" },
    APOCALYPSE = { outer=Color3.fromRGB(40,0,20),     inner=Color3.fromRGB(200,20,60),   glow=Color3.fromRGB(255,40,100),  light=Color3.fromRGB(255,40,100),  rate=80,  debrisC=Color3.fromRGB(60,0,20),     emberC=Color3.fromRGB(255,60,100),  lightning=0.7,  sound="Wind" },
}

local TORNADO_SIZES = {
    P       = { base=6,  segments=5,  particleMul=0.6, debrisMul=0.5, lightRange=40 },
    SMALL   = { base=10, segments=6,  particleMul=0.85, debrisMul=0.8, lightRange=70 },
    MEDIUM  = { base=15, segments=8,  particleMul=1.2, debrisMul=1.2, lightRange=100 },
    LARGE   = { base=22, segments=10, particleMul=1.7, debrisMul=1.7, lightRange=140 },
    GIANT   = { base=32, segments=12, particleMul=2.4, debrisMul=2.4, lightRange=200 },
    ULTRA   = { base=50, segments=15, particleMul=3.5, debrisMul=3.5, lightRange=300 },
}

-- Aplica ambientação (climate lock)
local function applyTornadoAmbience(amb)
    if amb == "NONE" then return end
    local presets = {
        STORM = { ClockTime=18, Brightness=1.2, Ambient=Color3.fromRGB(40,40,55), OutdoorAmbient=Color3.fromRGB(60,60,80), FogStart=100, FogEnd=350, FogColor=Color3.fromRGB(50,55,70), ExposureCompensation=0 },
        FOG   = { ClockTime=15, Brightness=1.8, Ambient=Color3.fromRGB(90,90,100), OutdoorAmbient=Color3.fromRGB(120,120,130), FogStart=20, FogEnd=180, FogColor=Color3.fromRGB(150,150,160), ExposureCompensation=-0.2 },
        CHAOS = { ClockTime=20, Brightness=0.7, Ambient=Color3.fromRGB(60,20,20), OutdoorAmbient=Color3.fromRGB(90,30,30), FogStart=50, FogEnd=250, FogColor=Color3.fromRGB(70,25,25), ExposureCompensation=-0.3 },
        APOC  = { ClockTime=0,  Brightness=0.4, Ambient=Color3.fromRGB(30,0,40), OutdoorAmbient=Color3.fromRGB(60,0,80), FogStart=30, FogEnd=180, FogColor=Color3.fromRGB(40,0,60), ExposureCompensation=-0.4 },
    }
    if amb == "AUTO" then
        -- escolhe baseado no tipo
        local map = {
            DUST = "CHAOS", STORM = "STORM", ELECTRIC = "STORM",
            FIRE = "CHAOS", VOID = "APOC", APOCALYPSE = "APOC",
        }
        amb = map[TornadoConfig.type] or "STORM"
    end
    local p = presets[amb]
    if p then
        snapshotLighting()
        ClimateLock:Set(p)
    end
end

-- Spawna tornado com base na configuração atual
local function spawnTornado(pos, forcedType, forcedSize)
    if #Tornado.active >= CONFIG.MaxTornados then return end
    local ttype = forcedType or TornadoConfig.type
    local tsize = forcedSize or TornadoConfig.size
    local def = TORNADO_TYPES[ttype] or TORNADO_TYPES.STORM
    local sz = TORNADO_SIZES[tsize] or TORNADO_SIZES.MEDIUM
    local baseSize = sz.base * (IS_MOBILE and 0.85 or 1)

    local model = Instance.new("Model", Workspace)
    model.Name = "Tornado"
    track(model)

    -- CONE EXTERNO (funil visual principal) — várias camadas
    local outerSegs = {}
    local segCount = IS_MOBILE and math.min(sz.segments, 8) or sz.segments
    for i = 1, segCount do
        local radius = (i / segCount) * baseSize
        -- cilindro externo (cor base)
        local s = Instance.new("Part")
        s.Shape = Enum.PartType.Cylinder
        s.Material = Enum.Material.SmoothPlastic
        s.Color = def.outer
        s.Transparency = 0.65 - (i/segCount)*0.25
        s.Size = Vector3.new(8, radius*2, radius*2)
        s.Anchored = true; s.CanCollide = false
        s.CFrame = CFrame.new(pos + Vector3.new(0, i*8-4, 0)) * CFrame.Angles(0, 0, math.rad(90))
        s.Parent = model
        table.insert(outerSegs, s)

        -- cilindro interno (glow)
        local inner = Instance.new("Part")
        inner.Shape = Enum.PartType.Cylinder
        inner.Material = Enum.Material.Neon
        inner.Color = def.inner
        inner.Transparency = 0.55
        inner.Size = Vector3.new(7, radius*1.4, radius*1.4)
        inner.Anchored = true; inner.CanCollide = false
        inner.CFrame = s.CFrame
        inner.Parent = model
        table.insert(outerSegs, inner)
    end

    -- BASE DE DETRITOS (anel de pedras girando)
    local debrisRing = Instance.new("Part")
    debrisRing.Anchored = true; debrisRing.CanCollide = false; debrisRing.Transparency = 1
    debrisRing.Size = Vector3.new(1,1,1)
    debrisRing.Position = pos
    debrisRing.Parent = model

    local debrisParts = {}
    local dCount = math.clamp(math.floor(8 * sz.debrisMul * CONFIG.ParticleMultiplier), 3, CONFIG.MaxDebris)
    for i = 1, dCount do
        local d = Instance.new("Part")
        d.Material = Enum.Material.Slate
        d.Color = def.debrisC
        d.Size = Vector3.new(
            math.random(1,3)*0.8,
            math.random(1,3)*0.8,
            math.random(1,3)*0.8
        )
        d.Anchored = true; d.CanCollide = false
        d.Parent = model
        table.insert(debrisParts, { part = d, angle = math.random()*math.pi*2, radius = baseSize*0.4 + math.random()*baseSize*0.3, height = math.random()*20, speed = 3 + math.random()*2 })
    end

    -- PARTICLES (funil)
    local emitter = Instance.new("Part", model)
    emitter.Anchored = true; emitter.CanCollide = false; emitter.Transparency = 1
    emitter.Size = Vector3.new(2,2,2); emitter.Position = pos

    local p = Instance.new("ParticleEmitter")
    p.Texture = "rbxassetid://243660364"
    p.Color = ColorSequence.new(def.outer, def.inner)
    p.Size = NumberSequence.new(baseSize*0.25, baseSize*0.9)
    p.Transparency = NumberSequence.new(0.3, 1)
    p.Lifetime = NumberRange.new(1.2, 2.2)
    p.Speed = NumberRange.new(10, 24)
    p.SpreadAngle = Vector2.new(180, 180)
    p.Rate = def.rate * sz.particleMul * CONFIG.ParticleMultiplier
    p.LightEmission = 0.6
    p.Parent = emitter

    -- EMBERS (partículas quentes/luminescentes subindo)
    local embers = Instance.new("ParticleEmitter")
    embers.Texture = "rbxassetid://243660364"
    embers.Color = ColorSequence.new(def.emberC, def.glow)
    embers.Size = NumberSequence.new(baseSize*0.08, baseSize*0.25)
    embers.Transparency = NumberSequence.new(0, 1)
    embers.Lifetime = NumberRange.new(0.8, 1.6)
    embers.Speed = NumberRange.new(15, 30)
    embers.SpreadAngle = Vector2.new(180, 180)
    embers.Rate = def.rate * 0.4 * sz.particleMul * CONFIG.ParticleMultiplier
    embers.LightEmission = 1
    embers.Parent = emitter

    -- LUZ
    local light = Instance.new("PointLight")
    light.Color = def.light
    light.Brightness = 3 + baseSize*0.1
    light.Range = sz.lightRange
    light.Parent = emitter

    -- SOM 3D
    play3D(def.sound, pos, 0.7, baseSize * 12)

    -- LOOP DE RAIOS INTERNOS
    local lightningTask = nil
    if def.lightning > 0 then
        lightningTask = task.spawn(function()
            while model.Parent do
                task.wait(math.random(15, 40)/10)
                if math.random() < def.lightning and model.Parent then
                    local s = pos + Vector3.new(0, baseSize*2, 0)
                    local e = pos + Vector3.new((math.random()-0.5)*baseSize, 0, (math.random()-0.5)*baseSize)
                    strikeLightning(s, e, "CHAIN")
                end
            end
        end)
    end

    -- AMBIENTAÇÃO (climate lock)
    local appliedAmbience = TornadoConfig.ambience
    if appliedAmbience ~= "NONE" then
        applyTornadoAmbience(appliedAmbience)
    end

    table.insert(Tornado.active, {
        model = model, position = pos, baseSize = baseSize,
        segments = outerSegs, emitter = emitter,
        debris = debrisParts,
        def = def, sz = sz,
        angle = 0, dir = Vector3.new(math.random()-0.5, 0, math.random()-0.5).Unit,
        life = 0, maxLife = 30,
        lightningTask = lightningTask,
        appliedAmbience = appliedAmbience,
    })
end

local function updateTornados(dt)
    for i = #Tornado.active, 1, -1 do
        local t = Tornado.active[i]
        if not t.model or not t.model.Parent then
            table.remove(Tornado.active, i)
        else
            t.life += dt
            t.angle += dt * 5
            t.position += t.dir * 15 * dt
            if math.random() < 0.02 then
                t.dir = (t.dir + Vector3.new(math.random()-0.5, 0, math.random()-0.5)*0.4).Unit
            end

            -- pulsação suave
            local pulse = 1 + math.sin(t.life * 3) * 0.08

            for idx, s in ipairs(t.segments) do
                if s.Parent then
                    local layerIdx = math.ceil(idx / 2)
                    local isInner = (idx % 2 == 0)
                    local radius = (layerIdx / (t.sz.segments)) * t.baseSize * pulse
                    local h = isInner and 7 or 8
                    local r = isInner and radius*1.4 or radius*2
                    s.Size = Vector3.new(h, r, r)
                    s.CFrame = CFrame.new(t.position + Vector3.new(0, layerIdx*8-4, 0)) * CFrame.Angles(0, 0, math.rad(90)) * CFrame.Angles(0, t.angle * (isInner and 1.3 or 1), 0)
                end
            end

            -- detritos orbitando
            for _, d in ipairs(t.debris) do
                if d.part.Parent then
                    d.angle += dt * d.speed
                    local y = d.height + math.sin(t.life + d.angle) * 2
                    local px = t.position.X + math.cos(d.angle) * d.radius
                    local pz = t.position.Z + math.sin(d.angle) * d.radius
                    local py = t.position.Y + y
                    d.part.Position = Vector3.new(px, py, pz)
                    d.part.CFrame = CFrame.new(Vector3.new(px, py, pz)) * CFrame.Angles(d.angle*2, d.angle*1.5, d.angle)
                end
            end

            if t.emitter and t.emitter.Parent then
                t.emitter.Position = t.position + Vector3.new(0, t.baseSize*0.5, 0)
            end

            if t.life > t.maxLife then
                if t.lightningTask then pcall(function() task.cancel(t.lightningTask) end) end
                t.model:Destroy()
                table.remove(Tornado.active, i)
            end
        end
    end
end

local function clearTornados()
    for _, t in ipairs(Tornado.active) do
        if t.lightningTask then pcall(function() task.cancel(t.lightningTask) end) end
        if t.model then t.model:Destroy() end
    end
    Tornado.active = {}
    -- remove a ambientação se nenhuma outra fonte está ativa
    if not State.Rain and not State.Earthquake and not State.SkyStorm and not State.SkyChaos and not State.SkyApoc then
        ClimateLock:Clear()
    end
end

-- ======================================================================
-- RAIN
-- ======================================================================
local Weather = { rain = nil, splash = nil, active = false, intensity = 1 }

local function startRain(intensity)
    Weather.active = true
    Weather.intensity = intensity or 1
    if not Weather.rain then
        local att = Instance.new("Part")
        att.Anchored = true; att.CanCollide = false; att.Transparency = 1
        att.Size = Vector3.new(1,1,1)
        att.Position = randPos(0, 50)
        att.Parent = Workspace
        track(att)
        local p = Instance.new("ParticleEmitter")
        p.Texture = "rbxassetid://241876404"
        p.Color = ColorSequence.new(Color3.fromRGB(180,200,220))
        p.Size = NumberSequence.new(1.2, 1.6)
        p.Transparency = NumberSequence.new(0.4, 0.9)
        p.Lifetime = NumberRange.new(1.5, 2.5)
        p.Speed = NumberRange.new(80, 120)
        p.SpreadAngle = Vector2.new(4, 4)
        p.Rate = (IS_MOBILE and 250 or 500) * CONFIG.ParticleMultiplier * Weather.intensity
        p.Parent = att
        Weather.rain = p
        task.spawn(function()
            while Weather.active and Weather.rain and Weather.rain.Parent do
                task.wait(1)
                if Weather.rain and Weather.rain.Parent then
                    Weather.rain.Parent.Position = randPos(0, 50)
                end
            end
        end)
    else
        Weather.rain.Rate = (IS_MOBILE and 250 or 500) * CONFIG.ParticleMultiplier * Weather.intensity
    end
end

local function stopRain()
    Weather.active = false
    if Weather.rain and Weather.rain.Parent then
        Weather.rain.Enabled = false
        Debris:AddItem(Weather.rain.Parent, 2)
    end
    Weather.rain = nil
end

-- ======================================================================
-- EARTHQUAKE
-- ======================================================================
local Quake = { active = false, timeLeft = 0, intensity = 1 }

local function startQuake(intensity, duration)
    Quake.active = true
    Quake.intensity = intensity or 1
    Quake.timeLeft = duration or 6
    play2D("Explosion", 0.7)
    task.spawn(function()
        while Quake.active do
            local pos = randPos(CONFIG.AutoAreaRadius, 1)
            smokeBurst(pos, 3, 5)
            shake(0.05 * Quake.intensity)
            task.wait(math.random(2,5)/10)
        end
    end)
end

local function updateQuake(dt)
    if not Quake.active then return end
    Quake.timeLeft -= dt
    if Quake.timeLeft <= 0 then Quake.active = false end
end

-- ======================================================================
-- SKY PRESETS (aplicados via ClimateLock)
-- ======================================================================
local SKY_PRESETS = {
    STORM = { ClockTime=18, Brightness=1, Ambient=Color3.fromRGB(40,40,55), OutdoorAmbient=Color3.fromRGB(60,60,80), FogStart=100, FogEnd=400, FogColor=Color3.fromRGB(50,55,70), ExposureCompensation=0 },
    CHAOS = { ClockTime=20, Brightness=0.6, Ambient=Color3.fromRGB(60,20,20), OutdoorAmbient=Color3.fromRGB(90,30,30), FogStart=60, FogEnd=250, FogColor=Color3.fromRGB(70,25,25), ExposureCompensation=-0.3 },
    APOC  = { ClockTime=0,  Brightness=0.3, Ambient=Color3.fromRGB(30,0,40), OutdoorAmbient=Color3.fromRGB(60,0,80), FogStart=40, FogEnd=150, FogColor=Color3.fromRGB(40,0,60), ExposureCompensation=-0.5 },
}

local function applySkyPreset(name)
    local p = SKY_PRESETS[name]
    if not p then return end
    snapshotLighting()
    ClimateLock:Set(p)
end

-- ======================================================================
-- STATE
-- ======================================================================
local State = {
    MeteorRain    = false,
    GiantMeteors  = false,
    Lightning     = false,
    MegaLightning = false,
    Tornado       = false,
    Rain          = false,
    Earthquake    = false,
    Volcano       = false,
    SkyStorm      = false,
    SkyChaos      = false,
    SkyApoc       = false,
}

local spawnLoops = {}
local function startLoop(key, intervalFn, fn)
    if spawnLoops[key] then return end
    spawnLoops[key] = task.spawn(function()
        while State[key] do
            pcall(fn)
            task.wait(intervalFn())
        end
    end)
end
local function stopLoop(key)
    if spawnLoops[key] then
        pcall(function() task.cancel(spawnLoops[key]) end)
        spawnLoops[key] = nil
    end
end

-- ======================================================================
-- SETTERS
-- ======================================================================
local function setMeteorRain(v)
    State.MeteorRain = v
    if v then
        startLoop("MeteorRain", function() return math.random(8,20)/10 end, function()
            spawnMeteor(randPos(CONFIG.AutoAreaRadius, CONFIG.AutoAreaHeight), randPos(CONFIG.AutoAreaRadius*0.8, 0), "COMMON")
        end)
    else stopLoop("MeteorRain") end
end

local function setGiantMeteors(v)
    State.GiantMeteors = v
    if v then
        startLoop("GiantMeteors", function() return math.random(18,35)/10 end, function()
            local types = {"GIANT","FIRE","ICE","ELECTRIC","VOID","PLASMA","APOCALYPSE"}
            spawnMeteor(randPos(CONFIG.AutoAreaRadius, CONFIG.AutoAreaHeight), randPos(CONFIG.AutoAreaRadius*0.8, 0), types[math.random(1,#types)])
        end)
    else stopLoop("GiantMeteors") end
end

local function setLightning(v)
    State.Lightning = v
    if v then
        startLoop("Lightning", function() return math.random(12,30)/10 end, function()
            strikeLightning(randPos(CONFIG.AutoAreaRadius, CONFIG.AutoAreaHeight), randPos(CONFIG.AutoAreaRadius, 0), "NORMAL")
        end)
    else stopLoop("Lightning") end
end

local function setMegaLightning(v)
    State.MegaLightning = v
    if v then
        startLoop("MegaLightning", function() return math.random(18,35)/10 end, function()
            local styles = {"MEGA","VOID","CHAIN","STORM"}
            strikeLightning(randPos(CONFIG.AutoAreaRadius, CONFIG.AutoAreaHeight), randPos(CONFIG.AutoAreaRadius, 0), styles[math.random(1,#styles)])
        end)
    else stopLoop("MegaLightning") end
end

local function setTornado(v)
    State.Tornado = v
    if v then
        if #Tornado.active == 0 then
            spawnTornado(randPos(CONFIG.AutoAreaRadius*0.6, 0))
        end
        startLoop("Tornado", function() return 2 end, function()
            if #Tornado.active == 0 then
                spawnTornado(randPos(CONFIG.AutoAreaRadius*0.6, 0))
            end
        end)
    else
        stopLoop("Tornado")
        clearTornados()
    end
end

local function setRain(v)
    State.Rain = v
    if v then startRain(1) else stopRain() end
end

local function setEarthquake(v)
    State.Earthquake = v
    if v then startQuake(1.2, 999)
    else Quake.active = false end
end

local volcanoActive = false
local function setVolcano(v)
    State.Volcano = v
    if v and not volcanoActive then
        volcanoActive = true
        local pos = randPos(CONFIG.AutoAreaRadius*0.6, 0)
        local model = Instance.new("Model", Workspace)
        model.Name = "Volcano"
        track(model)
        for i = 1, 6 do
            local c = Instance.new("Part")
            c.Shape = Enum.PartType.Cylinder
            c.Material = Enum.Material.Slate
            c.Color = Color3.fromRGB(40,25,20)
            local r = 40 - i*5
            c.Size = Vector3.new(12, r*2, r*2)
            c.Anchored = true; c.CanCollide = false
            c.CFrame = CFrame.new(pos + Vector3.new(0, i*12, 0)) * CFrame.Angles(0, 0, math.rad(90))
            c.Parent = model
        end
        local lava = Instance.new("Part")
        lava.Shape = Enum.PartType.Cylinder
        lava.Material = Enum.Material.Neon
        lava.Color = Color3.fromRGB(255,80,20)
        lava.Size = Vector3.new(2, 20, 20)
        lava.Anchored = true; lava.CanCollide = false
        lava.CFrame = CFrame.new(pos + Vector3.new(0, 74, 0)) * CFrame.Angles(0, 0, math.rad(90))
        lava.Parent = model
        local ll = Instance.new("PointLight")
        ll.Color = Color3.fromRGB(255,100,30); ll.Brightness = 8; ll.Range = 250
        ll.Parent = lava
        local lp = Instance.new("ParticleEmitter")
        lp.Texture = "rbxassetid://243660364"
        lp.Color = ColorSequence.new(Color3.fromRGB(255,200,50), Color3.fromRGB(255,60,20))
        lp.LightEmission = 1
        lp.Size = NumberSequence.new(2,6)
        lp.Transparency = NumberSequence.new(0.2,1)
        lp.Lifetime = NumberRange.new(1.5,2.5)
        lp.Speed = NumberRange.new(40,80)
        lp.SpreadAngle = Vector2.new(60,60)
        lp.Rate = 45 * CONFIG.ParticleMultiplier
        lp.Parent = lava
        play3D("Explosion", pos, 1, 500)
        shake(0.5)
        startLoop("Volcano", function() return math.random(8,18)/10 end, function()
            if volcanoActive and lava.Parent then
                local bp = pos + Vector3.new(0, 80, 0) + Vector3.new((math.random()-0.5)*20, (math.random()-0.5)*10, (math.random()-0.5)*20)
                spawnExplosion(bp, "LARGE")
            end
        end)
    elseif not v then
        volcanoActive = false
        stopLoop("Volcano")
        for _, c in ipairs(Workspace:GetChildren()) do
            if c:IsA("Model") and c.Name == "Volcano" then
                Debris:AddItem(c, 3)
            end
        end
    end
end

local function setSkyStorm(v)
    State.SkyStorm = v
    if v then applySkyPreset("STORM")
    else if not State.SkyChaos and not State.SkyApoc then ClimateLock:Clear() end end
end
local function setSkyChaos(v)
    State.SkyChaos = v
    if v then applySkyPreset("CHAOS")
    else if not State.SkyStorm and not State.SkyApoc then ClimateLock:Clear() end end
end
local function setSkyApoc(v)
    State.SkyApoc = v
    if v then applySkyPreset("APOC")
    else if not State.SkyStorm and not State.SkyChaos then ClimateLock:Clear() end end
end

-- ======================================================================
-- MAIN LOOP
-- ======================================================================
RunService.Heartbeat:Connect(function(dt)
    updateMeteors(dt)
    updateTornados(dt)
    updateQuake(dt)
end)

-- ======================================================================
-- UI
-- ======================================================================
local ui = Instance.new("ScreenGui")
ui.Name = "ApocalypseEngine"
ui.ResetOnSpawn = false
ui.IgnoreGuiInset = true
ui.DisplayOrder = 100
pcall(function() ui.Parent = game:GetService("CoreGui") end)
if not ui.Parent then ui.Parent = player:WaitForChild("PlayerGui") end

-- Botão flutuante
local floatBtn = Instance.new("TextButton", ui)
floatBtn.Size = UDim2.new(0, 60, 0, 60)
floatBtn.Position = UDim2.new(0, 20, 0.5, -30)
floatBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
floatBtn.Text = "🌋"
floatBtn.TextSize = 28
floatBtn.Font = Enum.Font.GothamBold
floatBtn.AutoButtonColor = false
floatBtn.Draggable = true
floatBtn.BorderSizePixel = 0
local fc = Instance.new("UICorner", floatBtn); fc.CornerRadius = UDim.new(1, 0)
local fs = Instance.new("UIStroke", floatBtn)
fs.Color = Color3.fromRGB(255, 80, 80); fs.Thickness = 2; fs.Transparency = 0.2

-- Painel principal
local panel = Instance.new("Frame", ui)
panel.Size = UDim2.new(0, 340, 0, 520)
panel.Position = UDim2.new(0.5, -170, 0.5, -260)
panel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Draggable = true
panel.Active = true
local pc = Instance.new("UICorner", panel); pc.CornerRadius = UDim.new(0, 14)
local ps = Instance.new("UIStroke", panel)
ps.Color = Color3.fromRGB(180, 20, 20); ps.Thickness = 1.5; ps.Transparency = 0.3

-- Header
local header = Instance.new("Frame", panel)
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundTransparency = 1

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -70, 0, 26)
title.Position = UDim2.new(0, 14, 0, 6)
title.BackgroundTransparency = 1
title.Text = "🌋 APOCALYPSE PRO"
title.TextColor3 = Color3.fromRGB(255, 200, 100)
title.Font = Enum.Font.GothamBlack
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local subTitle = Instance.new("TextLabel", header)
subTitle.Size = UDim2.new(1, -70, 0, 14)
subTitle.Position = UDim2.new(0, 14, 0, 28)
subTitle.BackgroundTransparency = 1
subTitle.Text = "Clique nos toggles · Toque ⚙ para configurar"
subTitle.TextColor3 = Color3.fromRGB(140, 140, 150)
subTitle.Font = Enum.Font.Gotham
subTitle.TextSize = 10
subTitle.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -48, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false
local cc = Instance.new("UICorner", closeBtn); cc.CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(function() panel.Visible = false end)

local line = Instance.new("Frame", panel)
line.Size = UDim2.new(1, 0, 0, 1)
line.Position = UDim2.new(0, 0, 0, 50)
line.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
line.BorderSizePixel = 0

-- HUD compacto no topo do painel
local hud = Instance.new("Frame", panel)
hud.Size = UDim2.new(1, -16, 0, 44)
hud.Position = UDim2.new(0, 8, 0, 58)
hud.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
hud.BorderSizePixel = 0
local hcn = Instance.new("UICorner", hud); hcn.CornerRadius = UDim.new(0, 8)
local hst = Instance.new("UIStroke", hud); hst.Color = Color3.fromRGB(60,60,70); hst.Thickness = 1; hst.Transparency = 0.5

local hudLabel = Instance.new("TextLabel", hud)
hudLabel.Size = UDim2.new(1, -20, 1, 0)
hudLabel.Position = UDim2.new(0, 10, 0, 0)
hudLabel.BackgroundTransparency = 1
hudLabel.Text = "Status: IDLE · Lock: OFF · Meteoros: 0 · Tornados: 0 · FPS: 60"
hudLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
hudLabel.Font = Enum.Font.Code
hudLabel.TextSize = 10
hudLabel.TextXAlignment = Enum.TextXAlignment.Left
hudLabel.TextWrapped = true

-- Scroll
local scroll = Instance.new("ScrollingFrame", panel)
scroll.Size = UDim2.new(1, -16, 1, -176)
scroll.Position = UDim2.new(0, 8, 0, 108)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(180, 20, 20)

local list = Instance.new("UIListLayout", scroll)
list.Padding = UDim.new(0, 6)
list.SortOrder = Enum.SortOrder.LayoutOrder

-- Footer
local footer = Instance.new("Frame", panel)
footer.Size = UDim2.new(1, -16, 0, 52)
footer.Position = UDim2.new(0, 8, 1, -60)
footer.BackgroundTransparency = 1

local stopAll = Instance.new("TextButton", footer)
stopAll.Size = UDim2.new(1, 0, 1, 0)
stopAll.BackgroundColor3 = Color3.fromRGB(140, 20, 20)
stopAll.Text = "🛑  DESLIGAR TUDO"
stopAll.TextColor3 = Color3.fromRGB(255, 240, 240)
stopAll.Font = Enum.Font.GothamBold
stopAll.TextSize = 15
stopAll.BorderSizePixel = 0
stopAll.AutoButtonColor = false
local sac = Instance.new("UICorner", stopAll); sac.CornerRadius = UDim.new(0, 10)
local sas = Instance.new("UIStroke", stopAll)
sas.Color = Color3.fromRGB(255, 80, 80); sas.Thickness = 1.5; sas.Transparency = 0.3

-- ======================================================================
-- Cria toggle row
-- ======================================================================
local function makeToggle(text, icon, initial, callback, expandable)
    local row = Instance.new("Frame", scroll)
    row.Size = UDim2.new(1, 0, 0, 52)
    row.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    row.BorderSizePixel = 0
    row.ClipsDescendants = true
    local rcn = Instance.new("UICorner", row); rcn.CornerRadius = UDim.new(0, 10)
    local rst = Instance.new("UIStroke", row); rst.Color = Color3.fromRGB(60, 60, 70); rst.Thickness = 1; rst.Transparency = 0.5

    -- Ícone
    local iconLbl = Instance.new("TextLabel", row)
    iconLbl.Size = UDim2.new(0, 30, 0, 52)
    iconLbl.Position = UDim2.new(0, 8, 0, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = icon
    iconLbl.TextSize = 18
    iconLbl.Font = Enum.Font.GothamBold

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -160, 0, 52)
    lbl.Position = UDim2.new(0, 44, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(235, 235, 240)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Switch
    local switch = Instance.new("Frame", row)
    switch.Size = UDim2.new(0, 50, 0, 26)
    switch.Position = UDim2.new(1, -62, 0.5, -13)
    switch.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    switch.BorderSizePixel = 0
    local scn = Instance.new("UICorner", switch); scn.CornerRadius = UDim.new(1, 0)

    local ball = Instance.new("Frame", switch)
    ball.Size = UDim2.new(0, 20, 0, 20)
    ball.Position = UDim2.new(0, 3, 0.5, -10)
    ball.BackgroundColor3 = Color3.fromRGB(200, 200, 205)
    ball.BorderSizePixel = 0
    local bcn = Instance.new("UICorner", ball); bcn.CornerRadius = UDim.new(1, 0)

    -- Botão de config (⚙)
    local cfgBtn = nil
    if expandable then
        cfgBtn = Instance.new("TextButton", row)
        cfgBtn.Size = UDim2.new(0, 26, 0, 26)
        cfgBtn.Position = UDim2.new(1, -94, 0.5, -13)
        cfgBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
        cfgBtn.Text = "⚙"
        cfgBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
        cfgBtn.Font = Enum.Font.GothamBold
        cfgBtn.TextSize = 14
        cfgBtn.BorderSizePixel = 0
        cfgBtn.AutoButtonColor = false
        local ccn = Instance.new("UICorner", cfgBtn); ccn.CornerRadius = UDim.new(0, 6)
    end

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1, expandable and -110 or -68, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    local isOn = false
    local function setState(v)
        isOn = v
        local bg = isOn and Color3.fromRGB(180, 30, 30) or Color3.fromRGB(50, 50, 55)
        local bp = isOn and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        local bc = isOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 205)
        tw(switch, 0.3, { BackgroundColor3 = bg }, Enum.EasingStyle.Back)
        tw(ball, 0.3, { Position = bp, BackgroundColor3 = bc }, Enum.EasingStyle.Back)
        tw(rst, 0.2, { Color = isOn and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(60, 60, 70), Transparency = isOn and 0.1 or 0.5 })
        pcall(callback, isOn)
    end

    btn.MouseButton1Click:Connect(function() setState(not isOn) end)

    if initial then setState(true) end

    return {
        Set = function(_, v) setState(v) end,
        Get = function() return isOn end,
        Row = row,
        ConfigBtn = cfgBtn,
    }
end

-- ======================================================================
-- Cria mini-selector (para o painel de config do tornado)
-- ======================================================================
local function makeSelector(parent, label, options, currentValue, onSelect)
    local wrap = Instance.new("Frame", parent)
    wrap.Size = UDim2.new(1, 0, 0, 54)
    wrap.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", wrap)
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local container = Instance.new("Frame", wrap)
    container.Size = UDim2.new(1, 0, 0, 30)
    container.Position = UDim2.new(0, 0, 0, 20)
    container.BackgroundTransparency = 1
    local ll = Instance.new("UIListLayout", container)
    ll.FillDirection = Enum.FillDirection.Horizontal
    ll.Padding = UDim.new(0, 4)

    local buttons = {}
    for _, opt in ipairs(options) do
        local b = Instance.new("TextButton", container)
        b.BackgroundColor3 = (opt == currentValue) and Color3.fromRGB(180, 30, 30) or Color3.fromRGB(45, 45, 52)
        b.Text = opt
        b.TextColor3 = (opt == currentValue) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 210)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 10
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        local cs = Instance.new("UICorner", b); cs.CornerRadius = UDim.new(0, 5)
        local ss = Instance.new("UIStroke", b); ss.Color = Color3.fromRGB(60, 60, 70); ss.Thickness = 1; ss.Transparency = 0.5

        -- tamanho dinâmico
        local textW = math.max(40, #opt * 7 + 14)
        b.Size = UDim2.new(0, textW, 1, 0)

        buttons[opt] = { btn = b, stroke = ss }

        b.MouseButton1Click:Connect(function()
            for k, v in pairs(buttons) do
                local sel = (k == opt)
                v.btn.BackgroundColor3 = sel and Color3.fromRGB(180, 30, 30) or Color3.fromRGB(45, 45, 52)
                v.btn.TextColor3 = sel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 210)
            end
            onSelect(opt)
        end)
    end

    return wrap
end

-- ======================================================================
-- Painel de configuração do tornado
-- ======================================================================
local tornadoConfigPanel = Instance.new("Frame", ui)
tornadoConfigPanel.Size = UDim2.new(0, 340, 0, 320)
tornadoConfigPanel.Position = UDim2.new(0.5, -170, 0.5, -160)
tornadoConfigPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
tornadoConfigPanel.BorderSizePixel = 0
tornadoConfigPanel.Visible = false
tornadoConfigPanel.Draggable = true
tornadoConfigPanel.Active = true
local tcpc = Instance.new("UICorner", tornadoConfigPanel); tcpc.CornerRadius = UDim.new(0, 14)
local tcps = Instance.new("UIStroke", tornadoConfigPanel)
tcps.Color = Color3.fromRGB(100, 150, 255); tcps.Thickness = 1.5; tcps.Transparency = 0.3

local tcHeader = Instance.new("Frame", tornadoConfigPanel)
tcHeader.Size = UDim2.new(1, 0, 0, 44)
tcHeader.BackgroundTransparency = 1

local tcTitle = Instance.new("TextLabel", tcHeader)
tcTitle.Size = UDim2.new(1, -60, 1, 0)
tcTitle.Position = UDim2.new(0, 14, 0, 0)
tcTitle.BackgroundTransparency = 1
tcTitle.Text = "🌪️  CONFIGURAR TORNADO"
tcTitle.TextColor3 = Color3.fromRGB(150, 200, 255)
tcTitle.Font = Enum.Font.GothamBlack
tcTitle.TextSize = 14
tcTitle.TextXAlignment = Enum.TextXAlignment.Left

local tcClose = Instance.new("TextButton", tcHeader)
tcClose.Size = UDim2.new(0, 32, 0, 32)
tcClose.Position = UDim2.new(1, -40, 0, 6)
tcClose.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
tcClose.Text = "✕"
tcClose.TextColor3 = Color3.fromRGB(255, 200, 200)
tcClose.Font = Enum.Font.GothamBold
tcClose.TextSize = 14
tcClose.BorderSizePixel = 0
tcClose.AutoButtonColor = false
local tccc = Instance.new("UICorner", tcClose); tccc.CornerRadius = UDim.new(0, 6)
tcClose.MouseButton1Click:Connect(function() tornadoConfigPanel.Visible = false end)

local tcLine = Instance.new("Frame", tornadoConfigPanel)
tcLine.Size = UDim2.new(1, 0, 0, 1)
tcLine.Position = UDim2.new(0, 0, 0, 44)
tcLine.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
tcLine.BorderSizePixel = 0

local tcBody = Instance.new("Frame", tornadoConfigPanel)
tcBody.Size = UDim2.new(1, -20, 1, -100)
tcBody.Position = UDim2.new(0, 10, 0, 54)
tcBody.BackgroundTransparency = 1
local tcBodyList = Instance.new("UIListLayout", tcBody)
tcBodyList.Padding = UDim.new(0, 8)
tcBodyList.SortOrder = Enum.SortOrder.LayoutOrder

-- Selector: TIPO
makeSelector(tcBody, "TIPO DE TORNADO",
    {"DUST","STORM","ELECTRIC","FIRE","VOID","APOCALYPSE"},
    TornadoConfig.type,
    function(v) TornadoConfig.type = v end)

-- Selector: TAMANHO
makeSelector(tcBody, "TAMANHO",
    {"P","SMALL","MEDIUM","LARGE","GIANT","ULTRA"},
    TornadoConfig.size,
    function(v) TornadoConfig.size = v end)

-- Selector: AMBIENTAÇÃO
makeSelector(tcBody, "EFEITO NO MAPA (CLIMA)",
    {"NONE","STORM","FOG","CHAOS","APOC","AUTO"},
    TornadoConfig.ambience,
    function(v) TornadoConfig.ambience = v end)

-- Info extra
local tcInfo = Instance.new("TextLabel", tornadoConfigPanel)
tcInfo.Size = UDim2.new(1, -20, 0, 40)
tcInfo.Position = UDim2.new(0, 10, 1, -48)
tcInfo.BackgroundTransparency = 1
tcInfo.Text = "💡 A ambientação trava o clima do mapa e vence\nqualquer sistema externo de 0.5s automaticamente."
tcInfo.TextColor3 = Color3.fromRGB(150, 150, 160)
tcInfo.Font = Enum.Font.Gotham
tcInfo.TextSize = 10
tcInfo.TextXAlignment = Enum.TextXAlignment.Left
tcInfo.TextYAlignment = Enum.TextYAlignment.Top
tcInfo.TextWrapped = true

-- Botão aplicar
local tcApply = Instance.new("TextButton", tornadoConfigPanel)
tcApply.Size = UDim2.new(1, -20, 0, 30)
tcApply.Position = UDim2.new(0, 10, 1, -88)
tcApply.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
tcApply.Text = "✅  APLICAR E SPAWNAR"
tcApply.TextColor3 = Color3.fromRGB(255, 255, 255)
tcApply.Font = Enum.Font.GothamBold
tcApply.TextSize = 13
tcApply.BorderSizePixel = 0
tcApply.AutoButtonColor = false
local tcc = Instance.new("UICorner", tcApply); tcc.CornerRadius = UDim.new(0, 8)
tcApply.MouseButton1Click:Connect(function()
    clearTornados()
    task.wait(0.15)
    spawnTornado(randPos(CONFIG.AutoAreaRadius*0.6, 0))
    tornadoConfigPanel.Visible = false
end)

-- ======================================================================
-- TOGGLES
-- ======================================================================
local tMeteorRain = makeToggle("Chuva de Meteoros", "☄️", false, setMeteorRain)
local tGiantMeteors = makeToggle("Meteoros Gigantes", "🔥", false, setGiantMeteors)
local tLightning = makeToggle("Raios", "⚡", false, setLightning)
local tMegaLightning = makeToggle("Raios Gigantes", "🌩️", false, setMegaLightning)
local tTornado = makeToggle("Tornado", "🌪️", false, setTornado, true)  -- expandable
local tRain = makeToggle("Chuva", "🌧️", false, setRain)
local tEarthquake = makeToggle("Terremoto", "🌍", false, setEarthquake)
local tVolcano = makeToggle("Vulcão", "🌋", false, setVolcano)
local tSkyStorm = makeToggle("Céu de Tempestade", "☁️", false, setSkyStorm)
local tSkyChaos = makeToggle("Céu de Caos", "🔴", false, setSkyChaos)
local tSkyApoc = makeToggle("Céu Apocalíptico", "💀", false, setSkyApoc)

-- Config button do tornado
tTornado.ConfigBtn.MouseButton1Click:Connect(function()
    tornadoConfigPanel.Visible = not tornadoConfigPanel.Visible
    if tornadoConfigPanel.Visible then
        tornadoConfigPanel.Size = UDim2.new(0, 0, 0, 0)
        tw(tornadoConfigPanel, 0.3, { Size = UDim2.new(0, 340, 0, 320) }, Enum.EasingStyle.Back)
    end
end)

-- ======================================================================
-- STOP ALL
-- ======================================================================
stopAll.MouseButton1Click:Connect(function()
    tMeteorRain:Set(false); tGiantMeteors:Set(false)
    tLightning:Set(false); tMegaLightning:Set(false)
    tTornado:Set(false); tRain:Set(false)
    tEarthquake:Set(false); tVolcano:Set(false)
    tSkyStorm:Set(false); tSkyChaos:Set(false); tSkyApoc:Set(false)

    cleanupAll()
    Tornado.active = {}
    Meteor.active = {}
    restoreLighting()
    stopRain()
    Quake.active = false
    volcanoActive = false
    for k in pairs(spawnLoops) do stopLoop(k) end

    stopAll.Text = "✅  LIMPO!"
    task.delay(1.2, function() stopAll.Text = "🛑  DESLIGAR TUDO" end)
end)

-- ======================================================================
-- HUD UPDATER
-- ======================================================================
task.spawn(function()
    local fpsCounter, lastT = 0, tick()
    local fps = 60
    while ui.Parent do
        task.wait(0.25)
        local now = tick()
        fps = 0.85 * fps + 0.15 * (1 / math.max(0.001, now - lastT))
        lastT = now

        local status = "IDLE"
        if #Meteor.active > 0 or #Tornado.active > 0 or Weather.active or Quake.active then status = "ATIVO" end
        if ClimateLock.active then status = status .. " (LOCK)" end

        hudLabel.Text = string.format(
            "Status: %s  ·  Lock:%s  ·  ☄️%d  🌪️%d  ·  FPS:%d",
            status, ClimateLock.active and "ON" or "OFF",
            #Meteor.active, #Tornado.active, math.floor(fps)
        )
    end
end)

-- ======================================================================
-- ANIMAÇÃO botão flutuante
-- ======================================================================
task.spawn(function()
    while floatBtn.Parent do
        tw(fs, 1.5, { Transparency = 0.7 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(1.5)
        tw(fs, 1.5, { Transparency = 0.2 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(1.5)
    end
end)

floatBtn.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
    if panel.Visible then
        panel.Size = UDim2.new(0, 0, 0, 0)
        tw(panel, 0.35, { Size = UDim2.new(0, 340, 0, 520) }, Enum.EasingStyle.Back)
    end
end)

floatBtn.MouseEnter:Connect(function()
    tw(floatBtn, 0.2, { Size = UDim2.new(0, 68, 0, 68), Position = UDim2.new(0, 16, 0.5, -34) }, Enum.EasingStyle.Back)
end)
floatBtn.MouseLeave:Connect(function()
    tw(floatBtn, 0.2, { Size = UDim2.new(0, 60, 0, 60), Position = UDim2.new(0, 20, 0.5, -30) }, Enum.EasingStyle.Back)
end)

-- ======================================================================
-- Limpa ao sair
-- ======================================================================
player.CharacterRemoving:Connect(function()
    Quake.active = false
end)

print("╔════════════════════════════════════════════════════╗")
print("║  🌋 APOCALYPSE ENGINE v3.0 · PRO EDITION           ║")
print("║  • Tornado configurável (tipo/tamanho/ambientação) ║")
print("║  • Climate Lock vence qualquer sistema externo     ║")
print("║  • Toque 🌋 para abrir · ⚙ no tornado p/ config   ║")
print("╚════════════════════════════════════════════════════╝")
