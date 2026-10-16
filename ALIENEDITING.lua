--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║  NINOMAX UI · v3.0.0 · ALIEN EDITION                                ║
    ║  ✦ API 100% retrocompatível com v1.3.0 (todos os Create* funcionam) ║
    ║  ✦ Maid/Signal · Tabs lazy · Debounce save · Tema interpolado       ║
    ║  ✦ Command Palette · Tooltips · Watermark · Stats · Console         ║
    ║  ✦ Grupos colapsáveis · Perfis · Sons · Ripple · Glitch · Partículas║
    ╚══════════════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════════════════
--  1 · SERVIÇOS / AMBIENTE
-- ═══════════════════════════════════════════════════════════════════════
local cloneref = cloneref or function(x) return x end
local function Svc(name)
    local ok, s = pcall(game.GetService, game, name)
    if ok and s then return cloneref(s) end
    return nil
end

local TweenService     = Svc("TweenService")
local Players          = Svc("Players")
local UIS              = Svc("UserInputService")
local RunService       = Svc("RunService")
local HttpService      = Svc("HttpService")
local CoreGui          = Svc("CoreGui")
local Workspace        = Svc("Workspace")
local player           = Players and Players.LocalPlayer
local genv             = (type(getgenv) == "function" and getgenv()) or _G

-- Executar de novo destrói a instância anterior
if type(genv.__NINOMAX) == "table" and type(genv.__NINOMAX.Unload) == "function" then
    pcall(genv.__NINOMAX.Unload, genv.__NINOMAX)
end

local NINOMAX = {
    Version      = "3.0.0",
    Flags        = {},
    Icons        = {},
    Themes       = {},
    Windows      = {},
    CurrentTheme = "Crimson",
    Scale        = 1,
    Settings     = {
        Animations   = true,
        Sounds       = false,
        Particles    = true,
        Tooltips     = true,
        Watermark    = true,
        NotifyPos    = "BottomRight",
        SoundVolume  = 0.5,
    },
}

-- ═══════════════════════════════════════════════════════════════════════
--  2 · UTILITÁRIOS CORE
-- ═══════════════════════════════════════════════════════════════════════
local U = {}

function U.Safe(fn, ...)
    if type(fn) ~= "function" then return false end
    local ok, err = pcall(fn, ...)
    if not ok then warn("[NINOMAX] " .. tostring(err)) end
    return ok
end

function U.Signal()
    local s = { _h = {} }
    function s:Connect(fn)
        local c = { fn = fn, on = true }
        table.insert(self._h, c)
        return { Disconnect = function() c.on = false end }
    end
    function s:Fire(...)
        for _, c in ipairs(self._h) do
            if c.on then task.spawn(c.fn, ...) end
        end
    end
    return s
end

function U.Maid()
    local m = { _t = {} }
    function m:Give(x) table.insert(self._t, x); return x end
    function m:Clean()
        local list = self._t
        self._t = {}
        for _, x in ipairs(list) do
            local ty = typeof(x)
            if ty == "RBXScriptConnection" then pcall(function() x:Disconnect() end)
            elseif ty == "Instance" then pcall(function() x:Destroy() end)
            elseif type(x) == "function" then pcall(x)
            elseif type(x) == "table" then
                if x.Disconnect then pcall(function() x:Disconnect() end)
                elseif x.Destroy then pcall(function() x:Destroy() end) end
            end
        end
    end
    return m
end

function U.Trim(s) return (tostring(s):gsub("^%s+", ""):gsub("%s+$", "")) end

-- Cores
function U.Mix(a, b, t)
    return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t)
end
function U.Lum(c) return 0.2126 * c.R + 0.7152 * c.G + 0.0722 * c.B end
function U.ToHex(c)
    return string.format("#%02X%02X%02X",
        math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end
function U.FromHex(hex)
    if type(hex) ~= "string" then return nil end
    hex = hex:gsub("#", ""):gsub("%s", "")
    if #hex == 3 then hex = hex:sub(1,1):rep(2)..hex:sub(2,2):rep(2)..hex:sub(3,3):rep(2) end
    if #hex ~= 6 then return nil end
    local r, g, b = tonumber(hex:sub(1,2), 16), tonumber(hex:sub(3,4), 16), tonumber(hex:sub(5,6), 16)
    if not r or not g or not b then return nil end
    return Color3.fromRGB(r, g, b)
end
function U.ContrastText(bg) return U.Lum(bg) > 0.55 and Color3.fromRGB(20,20,25) or Color3.fromRGB(245,245,250) end

-- JSON / FS
function U.JEnc(t) local ok, r = pcall(HttpService.JSONEncode, HttpService, t); return ok and r or nil end
function U.JDec(s) local ok, r = pcall(HttpService.JSONDecode, HttpService, s); return ok and r or nil end

local FS = { Ok = type(writefile) == "function" and type(readfile) == "function" }
function FS.Exists(p) local ok, r = pcall(isfile, p); return ok and r == true end
function FS.Mk(p) local ok, r = pcall(isfolder, p); if not (ok and r) then pcall(makefolder, p) end end
function FS.Read(p) local ok, r = pcall(readfile, p); return ok and type(r) == "string" and r or nil end
function FS.Write(p, d) pcall(writefile, p, d) end
function FS.Del(p) pcall(delfile, p) end

local clipFn = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
function U.Clip(text) if clipFn then return (pcall(clipFn, tostring(text))) end return false end

function U.IsPress(i)
    local t = i.UserInputType
    return t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch
end
function U.IsMove(i)
    local t = i.UserInputType
    return t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch
end
function U.IsMobile() return UIS.TouchEnabled and not UIS.KeyboardEnabled end

-- ── Tween cache ────────────────────────────────────────────────────────
local infoCache = {}
function U.Tw(inst, props, dur, style, dir)
    if not NINOMAX.Settings.Animations or (dur ~= nil and dur <= 0) then
        for k, v in pairs(props) do inst[k] = v end
        return nil
    end
    dur = dur or 0.22
    style = style or Enum.EasingStyle.Quint
    dir = dir or Enum.EasingDirection.Out
    local key = tostring(dur) .. style.Name .. dir.Name
    local info = infoCache[key]
    if not info then info = TweenInfo.new(dur, style, dir); infoCache[key] = info end
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end

-- ── Interpolação manual (para UIGradient, ColorSequence, etc.) ─────────
function U.LerpColorSequence(a, b, t)
    local function sample(seq, x)
        return seq:Evaluate(x)
    end
    local keys = {}
    local n = math.max(#a.Keypoints, #b.Keypoints)
    for i = 1, n do
        local ka = a.Keypoints[math.min(i, #a.Keypoints)]
        local kb = b.Keypoints[math.min(i, #b.Keypoints)]
        table.insert(keys, ColorSequenceKeypoint.new(
            ka.Time + (kb.Time - ka.Time) * t,
            U.Mix(ka.Value, kb.Value, t)
        ))
    end
    return ColorSequence.new(keys)
end

function U.AnimateGradient(gradient, from, to, dur)
    if not NINOMAX.Settings.Animations then gradient.Color = to; return end
    local start = os.clock()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local a = math.clamp((os.clock() - start) / dur, 0, 1)
        local eased = 1 - (1 - a) ^ 3
        pcall(function()
            gradient.Color = U.LerpColorSequence(from, to, eased)
        end)
        if a >= 1 then conn:Disconnect() end
    end)
    return conn
end

-- ── Som ────────────────────────────────────────────────────────────────
local SOUND_IDS = {
    click  = "rbxassetid://6895079853",
    toggle = "rbxassetid://6895083003",
    open   = "rbxassetid://6895083003",
    close  = "rbxassetid://6895083003",
    hover  = "rbxassetid://6895083003",
    error  = "rbxassetid://6895083003",
    success= "rbxassetid://6895083003",
}
function U.PlaySound(name)
    if not NINOMAX.Settings.Sounds then return end
    if not player then return end
    local id = SOUND_IDS[name]
    if not id then return end
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = id
        s.Volume = NINOMAX.Settings.SoundVolume
        s.Parent = player:WaitForChild("PlayerGui")
        s:Play()
        task.delay(1, function() s:Destroy() end)
    end)
end

-- ── Mount seguro ───────────────────────────────────────────────────────
function U.Mount(gui)
    local ok = false
    if type(gethui) == "function" then
        local s, h = pcall(gethui)
        if s and h then ok = pcall(function() gui.Parent = h end) and gui.Parent ~= nil end
    end
    if not ok and type(syn) == "table" and syn.protect_gui then
        pcall(syn.protect_gui, gui)
        ok = pcall(function() gui.Parent = CoreGui end) and gui.Parent ~= nil
    end
    if not ok then ok = pcall(function() gui.Parent = CoreGui end) and gui.Parent ~= nil end
    if not ok and player then gui.Parent = player:WaitForChild("PlayerGui") end
end

-- ── Screen inset (0 se IgnoreGuiInset, senão offset do topo) ───────────
function U.GetInset()
    local cam = Workspace and Workspace.CurrentCamera
    if cam and cam.ViewportSize.Y > 0 then
        -- Detecta o inset do topo (barra do Roblox)
        if UIS.TouchEnabled and not UIS.KeyboardEnabled then
            return 0  -- mobile geralmente sem inset significativo
        end
        return 36
    end
    return 0
end

-- ═══════════════════════════════════════════════════════════════════════
--  3 · ÍCONES (Lucide · set completo)
-- ═══════════════════════════════════════════════════════════════════════
do
    local data = [[
activity=10709752035 alertcircle=10709752996 alerttriangle=10709753149 archive=10709762233
arrowdown=10709767827 arrowleft=10709768114 arrowright=10709768347 arrowup=10709768939
award=10709769406 banknote=10709770178 barchart=10709773755 battery=10709774640
bell=10709775704 belloff=10709775320 bluetooth=10709776655 bomb=10709781460
book=10709781824 bookmark=10709782154 bot=10709782230 box=10709782497
briefcase=10709782662 brush=10709782758 bug=10709782845 building=10709783051
calculator=10709783311 calendar=10709789505 camera=10709789686 car=10709789810
check=10709790644 checkcircle=10709790387 chevrondown=10709790948 chevronleft=10709791281
chevronright=10709791437 chevronup=10709791523 circle=10709798174 clipboard=10709799288
clock=10709805144 cloud=10709806740 code=10709810463 cog=10709810948
coins=10709811110 command=10709811365 compass=10709811445 component=10709811595
copy=10709812159 cpu=10709813383 cross=10709818399 crosshair=10709818534
crown=10709818626 database=10709818996 delete=10709819059 diamond=10709819149
dices=10723343321 disc=10723343537 dollarsign=10723343958 download=10723344270
droplet=10723344432 edit=10734883598 eraser=10723346158 expand=10723346553
externallink=10723346684 eye=10723346959 eyeoff=10723346871 factory=10723347051
feather=10723354671 file=10723374641 filetext=10723367380 film=10723374981
filter=10723375128 fingerprint=10723375250 flag=10723375890 flame=10723376114
flashlight=10723376471 flower=10747830374 focus=10723377537 folder=10723387563
folderopen=10723386277 gamepad=10723395457 gauge=10723395708 gem=10723396000
ghost=10723396107 gift=10723396402 glasses=10723397895 globe=10723404337
graduationcap=10723404691 grid=10723404936 hammer=10723405360 hand=10723405649
harddrive=10723405749 hash=10723405975 headphones=10723406165 heart=10723406885
helpcircle=10723406988 hexagon=10723407092 highlighter=10723407192 history=10723407335
home=10723407389 hourglass=10723407498 image=10723415040 inbox=10723415335
infinity=10723415766 info=10723415903 inspect=10723416057 joystick=10723416527
key=10723416652 keyboard=10723416765 lamp=10723417513 landmark=10723417608
languages=10723417703 laptop=10723423881 layers=10723424505 layout=10723425376
layoutdashboard=10723424646 layoutgrid=10723424838 leaf=10723425539 library=10723425615
lifebuoy=10723425685 lightbulb=10723425852 linechart=10723426393 link=10723426722
list=10723433811 loader=10723434070 locate=10723434557 lock=10723434711
login=10723434830 logout=10723434906 magnet=10723435069 mail=10734885430
map=10734886202 mappin=10734886004 maximize=10734886735 medal=10734887072
megaphone=10734887454 menu=10734887784 messagecircle=10734888000 messagesquare=10734888228
mic=10734888864 microscope=10734889106 minimize=10734895698 minus=10734896206
monitor=10734896881 moon=10734897102 morehorizontal=10734897250 morevertical=10734897387
mountain=10734897956 mouse=10734898592 mousepointer=10734898476 move=10734900011
music=10734905958 navigation=10734906744 network=10734906975 newspaper=10734907168
octagon=10734907361 option=10734907649 package=10734909540 paintbucket=10734909847
paintbrush=10734910187 palette=10734910430 paperclip=10734910927 partypopper=10734918735
pause=10734919336 pencil=10734919691 percent=10734919919 phone=10734921524
piechart=10734921727 pin=10734922324 pipette=10734922497 plane=10734922971
play=10734923549 plus=10734924532 pointer=10734929723 power=10734930466
printer=10734930632 puzzle=10734930886 quote=10734931234 radio=10734931596
recycle=10734932295 redo=10734932822 refreshccw=10734933056 refreshcw=10734933222
repeat=10734933966 reply=10734934252 rewind=10734934347 rocket=10734934585
rotateccw=10734940376 rotatecw=10734940654 ruler=10734941018 save=10734941499
scale=10734941912 scan=10734942565 scissors=10734942778 scroll=10734943448
search=10734943674 send=10734943902 server=10734949856 settings=10734950309
share=10734950813 shield=10734951847 shieldalert=10734951173 shieldcheck=10734951367
shieldoff=10734951684 shirt=10734952036 shoppingbag=10734952273 shoppingcart=10734952479
shovel=10734952773 shuffle=10734953451 sidebar=10734954301 signal=10734961133
siren=10734961284 skipback=10734961526 skipforward=10734961809 skull=10734962068
slash=10734962600 sliders=10734963400 smartphone=10734963940 smile=10734964441
snowflake=10734964600 speaker=10734965419 sprout=10734965572 square=10734965702
star=10734966248 sun=10734974297 sunrise=10734974522 sunset=10734974689
sword=10734975486 swords=10734975692 table=10734976230 tablet=10734976394
tag=10734976528 target=10734977012 tent=10734981750 terminal=10734982144
thermometer=10734983134 thumbsdown=10734983359 thumbsup=10734983629 ticket=10734983868
timer=10734984606 toggleleft=10734984834 toggleright=10734985040 tornado=10734985247
train=10747362105 trash=10747362393 trash2=10747362241 treedeciduous=10747362534
treepine=10747362748 trendingdown=10747363205 trendingup=10747363465 triangle=10747363621
trophy=10747363809 truck=10747364031 tv=10747364593 type=10747364761
umbrella=10747364971 undo=10747365484 unlink=10747365771 unlock=10747366027
upload=10747366434 usb=10747366606 user=10747373176 usercheck=10747371901
userminus=10747372346 userplus=10747372702 userx=10747372992 users=10747373426
utensils=10747373821 verified=10747374131 video=10747374938 view=10747375132
volume=10747376008 volume2=10747375679 volumex=10747375880 wallet=10747376205
wan=10747376565 wand2=10747376349 watch=10747376722 waves=10747376931
wifi=10747382504 wifioff=10747382268 wind=10747382750 wrench=10747383470
x=10747384394 xcircle=10747383819 zoomin=10747384552 zoomout=10747384679
]]
    for name, id in data:gmatch("(%w+)=(%d+)") do
        NINOMAX.Icons[name] = "rbxassetid://" .. id
    end
    -- Aliases
    NINOMAX.Icons.close = NINOMAX.Icons.x
    NINOMAX.Icons.fire  = NINOMAX.Icons.flame
    NINOMAX.Icons.zap   = "rbxassetid://10734974297"
    NINOMAX.Icons.ball  = "rbxassetid://6337069410"
end

function U.Icon(name)
    if name == nil or name == false or name == "" or name == 0 then return nil end
    if type(name) == "number" then return "rbxassetid://" .. tostring(math.floor(name)) end
    if type(name) ~= "string" then return nil end
    if name:find("rbxassetid://", 1, true) or name:find("rbxthumb://", 1, true) or name:find("rbxasset://", 1, true) then
        return name
    end
    if name:find("^%d+$") then return "rbxassetid://" .. name end
    local key = name:lower():gsub("lucide", ""):gsub("[^%w]", "")
    if NINOMAX.Icons[key] then return NINOMAX.Icons[key] end
    if #key >= 4 then
        for n, asset in pairs(NINOMAX.Icons) do
            if n:find(key, 1, true) then return asset end
        end
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════════════
--  4 · TEMAS
-- ═══════════════════════════════════════════════════════════════════════
local function makeTheme(bg, surface, surfaceHi, stroke, accent, accentHi, accentSoft, text, textDim, grad1, grad2)
    return {
        gradient  = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   grad1 or U.Mix(bg, Color3.new(0,0,0), 0.3)),
            ColorSequenceKeypoint.new(0.5, grad2 or U.Mix(bg, accent, 0.08)),
            ColorSequenceKeypoint.new(1,   grad1 or U.Mix(bg, Color3.new(0,0,0), 0.3)),
        }),
        bg = bg, surface = surface, surfaceHi = surfaceHi, stroke = stroke,
        accent = accent, accentHi = accentHi, accentSoft = accentSoft,
        text = text or Color3.fromRGB(245,240,240),
        textDim = textDim or Color3.fromRGB(180,170,175),
        success = Color3.fromRGB(0,220,130),
        danger  = Color3.fromRGB(255,80,90),
    }
end

NINOMAX.Themes = {
    Crimson = makeTheme(
        Color3.fromRGB(22,12,14), Color3.fromRGB(34,18,22), Color3.fromRGB(46,24,28),
        Color3.fromRGB(48,24,30), Color3.fromRGB(220,30,55), Color3.fromRGB(255,70,90),
        Color3.fromRGB(90,15,30)),
    Neon = makeTheme(
        Color3.fromRGB(8,18,18), Color3.fromRGB(18,30,30), Color3.fromRGB(26,42,42),
        Color3.fromRGB(30,52,52), Color3.fromRGB(0,220,200), Color3.fromRGB(80,255,240),
        Color3.fromRGB(0,80,75)),
    Ocean = makeTheme(
        Color3.fromRGB(8,12,22), Color3.fromRGB(18,24,40), Color3.fromRGB(26,34,54),
        Color3.fromRGB(30,42,68), Color3.fromRGB(30,140,250), Color3.fromRGB(90,180,255),
        Color3.fromRGB(15,55,120)),
    Violet = makeTheme(
        Color3.fromRGB(14,8,22), Color3.fromRGB(26,16,38), Color3.fromRGB(38,24,54),
        Color3.fromRGB(46,30,68), Color3.fromRGB(150,60,240), Color3.fromRGB(200,120,255),
        Color3.fromRGB(70,20,120)),
    Sunset = makeTheme(
        Color3.fromRGB(20,12,8), Color3.fromRGB(38,22,14), Color3.fromRGB(52,32,20),
        Color3.fromRGB(62,38,24), Color3.fromRGB(255,130,40), Color3.fromRGB(255,180,90),
        Color3.fromRGB(130,55,15)),
    Toxic = makeTheme(
        Color3.fromRGB(10,18,8), Color3.fromRGB(20,32,16), Color3.fromRGB(30,46,24),
        Color3.fromRGB(40,60,32), Color3.fromRGB(140,240,40), Color3.fromRGB(180,255,90),
        Color3.fromRGB(55,110,15)),
    Cyberpunk = makeTheme(
        Color3.fromRGB(14,6,16), Color3.fromRGB(26,12,28), Color3.fromRGB(40,18,44),
        Color3.fromRGB(48,22,52), Color3.fromRGB(255,20,190), Color3.fromRGB(255,90,220),
        Color3.fromRGB(110,10,80)),
    Gold = makeTheme(
        Color3.fromRGB(18,14,6), Color3.fromRGB(32,26,14), Color3.fromRGB(46,36,20),
        Color3.fromRGB(58,46,24), Color3.fromRGB(240,190,50), Color3.fromRGB(255,220,100),
        Color3.fromRGB(110,80,20)),
    Emerald = makeTheme(
        Color3.fromRGB(8,18,12), Color3.fromRGB(18,32,22), Color3.fromRGB(26,44,32),
        Color3.fromRGB(34,58,42), Color3.fromRGB(40,210,130), Color3.fromRGB(90,250,175),
        Color3.fromRGB(15,85,55)),
    Blood = makeTheme(
        Color3.fromRGB(14,4,6), Color3.fromRGB(26,10,14), Color3.fromRGB(40,16,22),
        Color3.fromRGB(50,20,26), Color3.fromRGB(180,10,20), Color3.fromRGB(230,40,55),
        Color3.fromRGB(80,5,12)),
    Midnight = makeTheme(
        Color3.fromRGB(10,12,20), Color3.fromRGB(22,26,40), Color3.fromRGB(32,38,54),
        Color3.fromRGB(40,48,66), Color3.fromRGB(90,120,240), Color3.fromRGB(130,160,255),
        Color3.fromRGB(35,48,110)),
    Ice = makeTheme(
        Color3.fromRGB(12,18,24), Color3.fromRGB(22,32,42), Color3.fromRGB(32,46,60),
        Color3.fromRGB(44,62,80), Color3.fromRGB(120,210,255), Color3.fromRGB(180,235,255),
        Color3.fromRGB(40,110,150)),
}

-- Gera tema procedural a partir de um accent
function NINOMAX.GenerateTheme(accent)
    local dark = Color3.fromRGB(12, 12, 14)
    local surface = U.Mix(dark, accent, 0.08)
    local surfaceHi = U.Mix(dark, accent, 0.14)
    local stroke = U.Mix(dark, accent, 0.22)
    local accentHi = U.Mix(accent, Color3.new(1,1,1), 0.35)
    local accentSoft = U.Mix(dark, accent, 0.45)
    return makeTheme(dark, surface, surfaceHi, stroke, accent, accentHi, accentSoft)
end

-- ═══════════════════════════════════════════════════════════════════════
--  5 · EVENTOS GLOBAIS / THEME BUS
-- ═══════════════════════════════════════════════════════════════════════
NINOMAX.Events = {
    ThemeChanged = U.Signal(),
    FlagChanged  = U.Signal(),
    TabChanged   = U.Signal(),
    Unloaded     = U.Signal(),
}

local themeBindings = {}
local function onTheme(fn) table.insert(themeBindings, fn) end
local function broadcastTheme(newT)
    for _, fn in ipairs(themeBindings) do pcall(fn, newT) end
    NINOMAX.Events.ThemeChanged:Fire(newT)
end

-- ═══════════════════════════════════════════════════════════════════════
--  6 · TOOLTIP GLOBAL (segue o mouse)
-- ═══════════════════════════════════════════════════════════════════════
local Tooltip = { _active = nil, _maid = U.Maid() }
do
    local sg = Instance.new("ScreenGui")
    sg.Name = "NINOMAX_Tooltip"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999999
    U.Mount(sg)

    local box = Instance.new("Frame", sg)
    box.BackgroundColor3 = Color3.fromRGB(20,20,24)
    box.BorderSizePixel = 0
    box.Size = UDim2.new(0, 0, 0, 0)
    box.Visible = false
    box.ZIndex = 100
    box.AutomaticSize = Enum.AutomaticSize.XY
    local bc = Instance.new("UICorner", box); bc.CornerRadius = UDim.new(0, 6)
    local bs = Instance.new("UIStroke", box); bs.Color = Color3.fromRGB(60,60,70); bs.Thickness = 1; bs.Transparency = 0.4
    local pad = Instance.new("UIPadding", box)
    pad.PaddingTop = UDim.new(0, 6); pad.PaddingBottom = UDim.new(0, 6)
    pad.PaddingLeft = UDim.new(0, 10); pad.PaddingRight = UDim.new(0, 10)

    local lbl = Instance.new("TextLabel", box)
    lbl.BackgroundTransparency = 1
    lbl.AutomaticSize = Enum.AutomaticSize.XY
    lbl.Text = ""
    lbl.TextColor3 = Color3.fromRGB(230,230,240)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.Size = UDim2.new(0, 0, 0, 14)

    UIS.InputChanged:Connect(function(input)
        if not Tooltip._active then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local vp = Workspace.CurrentCamera.ViewportSize
            local x = math.min(input.Position.X + 14, vp.X - 20)
            local y = math.min(input.Position.Y + 14, vp.Y - 20)
            box.Position = UDim2.new(0, x, 0, y)
        end
    end)

    function Tooltip.Show(text)
        if not NINOMAX.Settings.Tooltips then return end
        if Tooltip._active == text and box.Visible then return end
        Tooltip._active = text
        lbl.Text = tostring(text)
        box.Visible = true
        box.BackgroundTransparency = 1
        lbl.TextTransparency = 1
        U.Tw(box, { BackgroundTransparency = 0.05 }, 0.15)
        U.Tw(lbl, { TextTransparency = 0 }, 0.15)
    end
    function Tooltip.Hide()
        if not Tooltip._active then return end
        Tooltip._active = nil
        U.Tw(box, { BackgroundTransparency = 1 }, 0.12)
        U.Tw(lbl, { TextTransparency = 1 }, 0.12)
        task.delay(0.14, function() if not Tooltip._active then box.Visible = false end end)
    end
end

-- Aplica tooltip + sound a um GuiObject
local function attachTooltip(inst, text, soundName)
    if not text then return end
    inst.MouseEnter:Connect(function()
        Tooltip.Show(text)
        if soundName then U.PlaySound(soundName) end
    end)
    inst.MouseLeave:Connect(function() Tooltip.Hide() end)
end

-- ═══════════════════════════════════════════════════════════════════════
--  7 · WATERMARK (FPS / ping / memória / hora)
-- ═══════════════════════════════════════════════════════════════════════
local Watermark = { enabled = false }
do
    local sg = Instance.new("ScreenGui")
    sg.Name = "NINOMAX_Watermark"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 99998
    U.Mount(sg)

    local box = Instance.new("Frame", sg)
    box.BackgroundColor3 = Color3.fromRGB(15,15,20)
    box.BackgroundTransparency = 0.15
    box.BorderSizePixel = 0
    box.Size = UDim2.new(0, 220, 0, 26)
    box.Position = UDim2.new(0, 12, 0, 12)
    box.Visible = false
    local bc = Instance.new("UICorner", box); bc.CornerRadius = UDim.new(0, 6)
    local bs = Instance.new("UIStroke", box); bs.Color = Color3.fromRGB(220,30,55); bs.Thickness = 1; bs.Transparency = 0.3
    local pad = Instance.new("UIPadding", box)
    pad.PaddingLeft = UDim.new(0, 10); pad.PaddingRight = UDim.new(0, 10)

    local lbl = Instance.new("TextLabel", box)
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.Text = "NINOMAX · FPS 60 · 30ms · 200MB"
    lbl.TextColor3 = Color3.fromRGB(230,230,240)
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local frames, lastClock = 0, os.clock()
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        if os.clock() - lastClock >= 1 then
            local fps = math.floor(frames / (os.clock() - lastClock) + 0.5)
            frames = 0; lastClock = os.clock()
            local ping = 0
            pcall(function()
                ping = math.floor(player:GetNetworkPing() * 1000 + 0.5)
            end)
            local mem = math.floor(gcinfo())
            local t = os.date("%H:%M")
            lbl.Text = string.format("NINOMAX · %d FPS · %dms · %dMB · %s", fps, ping, mem, t)
        end
    end)

    function Watermark.SetEnabled(v)
        Watermark.enabled = v
        box.Visible = v
    end
    Watermark.SetEnabled(NINOMAX.Settings.Watermark)
end

-- ═══════════════════════════════════════════════════════════════════════
--  8 · UTILITÁRIOS VISUAIS
-- ═══════════════════════════════════════════════════════════════════════
local function newCorner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = r or UDim.new(0, 6); c.Parent = p; return c
end
local function newStroke(p, col, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or Color3.fromRGB(60,60,70); s.Thickness = th or 1
    s.Transparency = tr or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p; return s
end
local function newPad(p, t, l, r, b)
    local u = Instance.new("UIPadding", p)
    u.PaddingTop = UDim.new(0, t or 0); u.PaddingLeft = UDim.new(0, l or 0)
    u.PaddingRight = UDim.new(0, r or 0); u.PaddingBottom = UDim.new(0, b or 0)
    return u
end

-- Arrasto com inércia (melhor que o `draggable` original)
local function draggableSmooth(frame, handle, clampFn)
    handle = handle or frame
    local dragging, moved = false, false
    local startPtr, sx, sy, gx, gy, cx, cy
    local conn
    local function stop() if conn then conn:Disconnect(); conn = nil end end
    local function step(dt)
        local a = 1 - math.exp(-dt * 24)
        cx = cx + (gx - cx) * a
        cy = cy + (gy - cy) * a
        local p = frame.Position
        if not dragging and math.abs(gx - cx) < 0.4 and math.abs(gy - cy) < 0.4 then
            frame.Position = UDim2.new(p.X.Scale, gx, p.Y.Scale, gy)
            stop()
        else
            frame.Position = UDim2.new(p.X.Scale, cx, p.Y.Scale, cy)
        end
    end
    handle.InputBegan:Connect(function(input)
        if not U.IsPress(input) then return end
        dragging, moved = true, false
        startPtr = input.Position
        local p = frame.Position
        sx, sy = p.X.Offset, p.Y.Offset
        gx, gy = sx, sy
        if conn then cx, cy = sx, sy end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if not U.IsMove(input) then return end
        local d = input.Position - startPtr
        if math.abs(d.X) + math.abs(d.Y) > 4 then moved = true end
        local nx, ny = sx + d.X, sy + d.Y
        if clampFn then nx, ny = clampFn(nx, ny) end
        gx, gy = nx, ny
        if not conn then
            local p = frame.Position
            cx, cy = p.X.Offset, p.Y.Offset
            conn = RunService.RenderStepped:Connect(step)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if not U.IsPress(input) then return end
        dragging = false
    end)
    return function() return moved end
end

-- Ripple corrigido (usa AbsolutePosition + insets)
local function attachRipple(parent, button)
    button = button or parent
    button.MouseButton1Down:Connect(function()
        U.PlaySound("click")
        local ap = parent.AbsolutePosition
        local as = parent.AbsoluteSize
        local mouse = UIS:GetMouseLocation()
        -- Corrige inset do topo se IgnoreGuiInset
        local inset = 0
        local sg = parent:FindFirstAncestorWhichIsA("ScreenGui")
        if sg and sg.IgnoreGuiInset then inset = 36 end
        local mx = math.clamp(mouse.X - ap.X, 0, as.X)
        local my = math.clamp(mouse.Y - ap.Y - inset, 0, as.Y)

        local ripple = Instance.new("Frame", parent)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Position = UDim2.new(0, mx, 0, my)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.BackgroundColor3 = Color3.new(1, 1, 1)
        ripple.BackgroundTransparency = 0.65
        ripple.BorderSizePixel = 0
        ripple.ZIndex = 4
        newCorner(ripple, UDim.new(1, 0))
        local d = math.max(as.X, as.Y) * 2
        local t = U.Tw(ripple, { Size = UDim2.new(0, d, 0, d), BackgroundTransparency = 1 }, 0.55, Enum.EasingStyle.Quart)
        if t then t.Completed:Connect(function() ripple:Destroy() end)
        else task.delay(0.5, function() ripple:Destroy() end) end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
--  9 · CONFIG / PERFIS (com debounce)
-- ═══════════════════════════════════════════════════════════════════════
local Config = { file = "ninomax_config.json", lastSave = 0 }
function NINOMAX:GetFlag(name) return self.Flags[name] end
function NINOMAX:SetFlag(name, value)
    self.Flags[name] = value
    -- Debounce: salva no máximo 1x a cada 0.8s
    if os.clock() - Config.lastSave > 0.8 then
        Config.lastSave = os.clock()
        U.Safe(function() FS.Write(Config.file, U.JEnc(NINOMAX.Flags)) end)
    end
    self.Events.FlagChanged:Fire(name, value)
end
function NINOMAX:SaveConfig(file)
    U.Safe(function() FS.Write(file or Config.file, U.JEnc(NINOMAX.Flags)) end)
end
function NINOMAX:LoadConfig(file)
    file = file or Config.file
    local data = FS.Read(file)
    if not data then return false end
    local t = U.JDec(data)
    if type(t) ~= "table" then return false end
    for k, v in pairs(t) do self.Flags[k] = v end
    return true
end

-- Perfis
function NINOMAX:SaveProfile(name)
    name = U.Safe and (tostring(name):gsub("[^%w%-_ ]", "")) or name
    local path = "ninomax_profiles/" .. name .. ".json"
    FS.Mk("ninomax_profiles")
    U.Safe(function() FS.Write(path, U.JEnc(NINOMAX.Flags)) end)
end
function NINOMAX:LoadProfile(name)
    local path = "ninomax_profiles/" .. name .. ".json"
    local data = FS.Read(path)
    if not data then return false end
    local t = U.JDec(data)
    if type(t) ~= "table" then return false end
    for k, v in pairs(t) do self.Flags[k] = v end
    return true
end

-- ═══════════════════════════════════════════════════════════════════════
-- 10 · CREATE WINDOW
-- ═══════════════════════════════════════════════════════════════════════
function NINOMAX:CreateWindow(cfg)
    cfg = cfg or {}
    Config.file = cfg.ConfigFile or "ninomax_config.json"
    local SUBTITLE = cfg.Subtitle or "v" .. self.Version
    local MIN_SIZE = Vector2.new(460, 320)
    local MAX_SIZE = Vector2.new(1300, 950)
    local currentSize = Vector2.new(620, 420)
    local maid = U.Maid()

    NINOMAX:LoadConfig()

    local T = NINOMAX.Themes[NINOMAX.CurrentTheme]

    local gui = Instance.new("ScreenGui")
    gui.Name = "NINOMAX_UI_v3"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 99999
    U.Mount(gui)
    if not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end

    local uiScale = Instance.new("UIScale", gui)
    uiScale.Scale = U.IsMobile() and 1.05 or 1

    -- Sombra (atrás do mainFrame)
    local shadowHolder = Instance.new("Frame", gui)
    shadowHolder.BackgroundTransparency = 1
    shadowHolder.Size = UDim2.new(0, currentSize.X + 4, 0, currentSize.Y + 4)
    shadowHolder.Position = UDim2.new(0.5, 0, 0.5, 2)
    shadowHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    shadowHolder.ZIndex = 0
    maid:Give(shadowHolder)
    local shadowImg = Instance.new("ImageLabel", shadowHolder)
    shadowImg.Size = UDim2.new(1, 0, 1, 0)
    shadowImg.BackgroundTransparency = 1
    shadowImg.Image = "rbxassetid://1316045217"
    shadowImg.ImageColor3 = Color3.new(0, 0, 0)
    shadowImg.ImageTransparency = 0.55
    shadowImg.ScaleType = Enum.ScaleType.Slice
    shadowImg.SliceCenter = Rect.new(8, 8, 120, 120)

    -- MainFrame
    local mainFrame = Instance.new("Frame", gui)
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = T.bg
    mainFrame.BackgroundTransparency = 0.03
    mainFrame.ClipsDescendants = true
    mainFrame.BorderSizePixel = 0
    maid:Give(mainFrame)
    newCorner(mainFrame, UDim.new(0, 12))
    local mainStroke = newStroke(mainFrame, T.stroke, 1.4, 0.3)
    local mainGrad = Instance.new("UIGradient", mainFrame)
    mainGrad.Rotation = 45
    mainGrad.Color = T.gradient

    -- Partículas de fundo (dentro do mainFrame, bem transparentes)
    local particles = Instance.new("Frame", mainFrame)
    particles.Name = "Particles"
    particles.Size = UDim2.new(1, 0, 1, 0)
    particles.BackgroundTransparency = 1
    particles.ZIndex = 0
    particles.ClipsDescendants = true
    local particleData = {}
    if NINOMAX.Settings.Particles then
        for i = 1, 14 do
            local p = Instance.new("Frame", particles)
            p.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
            p.Position = UDim2.new(math.random(), 0, math.random(), 0)
            p.BackgroundColor3 = T.accentHi
            p.BackgroundTransparency = 0.75
            p.BorderSizePixel = 0
            newCorner(p, UDim.new(1, 0))
            table.insert(particleData, {
                inst = p,
                vx = (math.random() - 0.5) * 0.02,
                vy = -math.random() * 0.01 - 0.005,
                alpha = math.random() * math.pi * 2,
            })
        end
    end

    -- TopBar
    local topBar = Instance.new("Frame", mainFrame)
    topBar.Size = UDim2.new(1, 0, 0, 34)
    topBar.BackgroundTransparency = 1
    topBar.ZIndex = 5

    -- Título "NINO MAX" com glitch
    local titleWrap = Instance.new("Frame", topBar)
    titleWrap.BackgroundTransparency = 1
    titleWrap.Position = UDim2.new(0, 15, 0.5, -1)
    titleWrap.AnchorPoint = Vector2.new(0, 0.5)
    titleWrap.AutomaticSize = Enum.AutomaticSize.XY
    titleWrap.ZIndex = 6

    local titleLay = Instance.new("UIListLayout", titleWrap)
    titleLay.FillDirection = Enum.FillDirection.Horizontal
    titleLay.VerticalAlignment = Enum.VerticalAlignment.Center
    titleLay.SortOrder = Enum.SortOrder.LayoutOrder

    local titleNino = Instance.new("TextLabel", titleWrap)
    titleNino.BackgroundTransparency = 1
    titleNino.AutomaticSize = Enum.AutomaticSize.XY
    titleNino.Font = Enum.Font.GothamBold
    titleNino.TextSize = 14
    titleNino.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleNino.Text = "NINO"
    titleNino.LayoutOrder = 1

    local titleMax = Instance.new("TextLabel", titleWrap)
    titleMax.BackgroundTransparency = 1
    titleMax.AutomaticSize = Enum.AutomaticSize.XY
    titleMax.Font = Enum.Font.GothamBold
    titleMax.TextSize = 14
    titleMax.TextColor3 = T.accentHi
    titleMax.Text = "MAX"
    titleMax.LayoutOrder = 2
    local maxGlow = newStroke(titleMax, T.accentHi, 1, 0.4)

    local subtitle = Instance.new("TextLabel", topBar)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 9
    subtitle.TextColor3 = T.textDim
    subtitle.Text = SUBTITLE
    subtitle.ZIndex = 6
    subtitle.AutomaticSize = Enum.AutomaticSize.XY
    subtitle.AnchorPoint = Vector2.new(0, 0.5)
    task.defer(function()
        local w = titleWrap.AbsoluteSize.X
        subtitle.Position = UDim2.new(0, 15 + w + 8, 0.5, 2)
    end)

    -- Glow pulsante no "MAX"
    task.spawn(function()
        while titleMax.Parent do
            U.Tw(maxGlow, { Transparency = 0.9 }, 1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.4)
            U.Tw(maxGlow, { Transparency = 0.2 }, 1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.4)
        end
    end)

    -- Glitch ocasional no título (só quando não está sendo animado)
    task.spawn(function()
        while titleNino.Parent do
            task.wait(math.random(8, 20))
            local ox = titleNino.Position
            for _ = 1, 3 do
                titleNino.Position = UDim2.new(ox.X.Scale, ox.X.Offset + math.random(-2, 2), ox.Y.Scale, ox.Y.Offset + math.random(-1, 1))
                titleNino.TextColor3 = Color3.fromRGB(255, math.random(50, 120), math.random(50, 120))
                task.wait(0.04)
            end
            titleNino.Position = ox
            titleNino.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)

    -- Botões close/min
    local btnClose = Instance.new("ImageButton", topBar)
    btnClose.Size = UDim2.new(0, 14, 0, 14)
    btnClose.Position = UDim2.new(1, -12, 0.5, 0)
    btnClose.AnchorPoint = Vector2.new(1, 0.5)
    btnClose.BackgroundTransparency = 1
    btnClose.Image = NINOMAX.Icons.x
    btnClose.ImageColor3 = T.textDim
    btnClose.ZIndex = 7

    local btnMin = Instance.new("ImageButton", topBar)
    btnMin.Size = UDim2.new(0, 14, 0, 14)
    btnMin.Position = UDim2.new(1, -34, 0.5, 0)
    btnMin.AnchorPoint = Vector2.new(1, 0.5)
    btnMin.BackgroundTransparency = 1
    btnMin.Image = NINOMAX.Icons.minus
    btnMin.ImageColor3 = T.textDim
    btnMin.ZIndex = 7

    btnClose.MouseEnter:Connect(function() U.Tw(btnClose, { ImageColor3 = Color3.fromRGB(255, 90, 90) }, 0.15) end)
    btnClose.MouseLeave:Connect(function() U.Tw(btnClose, { ImageColor3 = T.textDim }, 0.15) end)
    btnMin.MouseEnter:Connect(function() U.Tw(btnMin, { ImageColor3 = T.accentHi }, 0.15) end)
    btnMin.MouseLeave:Connect(function() U.Tw(btnMin, { ImageColor3 = T.textDim }, 0.15) end)

    -- Arrasto com clamp (mantém dentro da tela)
    local function clampPos(x, y)
        local vp = Workspace.CurrentCamera.ViewportSize
        local sx = mainFrame.AbsoluteSize.X
        local sy = mainFrame.AbsoluteSize.Y
        x = math.clamp(x, -sx / 2 + 60, vp.X - sx / 2 - 60)
        y = math.clamp(y, -sy / 2 + 20, vp.Y - sy / 2 - 20)
        return x, y
    end
    draggableSmooth(mainFrame, topBar, clampPos)

    -- Separador
    local sepLine = Instance.new("Frame", mainFrame)
    sepLine.Size = UDim2.new(1, 0, 0, 1)
    sepLine.Position = UDim2.new(0, 0, 0, 34)
    sepLine.BackgroundColor3 = T.stroke
    sepLine.BackgroundTransparency = 0.4
    sepLine.BorderSizePixel = 0
    sepLine.ZIndex = 4

    -- Sidebar
    local sidebarWrap = Instance.new("Frame", mainFrame)
    sidebarWrap.Size = UDim2.new(0, 160, 1, -34)
    sidebarWrap.Position = UDim2.new(0, 0, 0, 34)
    sidebarWrap.BackgroundTransparency = 1
    sidebarWrap.ZIndex = 3

    local sidebar = Instance.new("ScrollingFrame", sidebarWrap)
    sidebar.Size = UDim2.new(1, 0, 1, 0)
    sidebar.BackgroundTransparency = 1
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebar.ScrollBarThickness = 2
    sidebar.ScrollBarImageColor3 = T.accent
    sidebar.ScrollBarImageTransparency = 0.4
    sidebar.BorderSizePixel = 0
    sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
    newPad(sidebar, 8, 8, 8, 8)

    local sideLay = Instance.new("UIListLayout", sidebar)
    sideLay.SortOrder = Enum.SortOrder.LayoutOrder
    sideLay.Padding = UDim.new(0, 4)

    -- Search box
    local searchBox = Instance.new("TextBox", sidebar)
    searchBox.Size = UDim2.new(1, 0, 0, 24)
    searchBox.BackgroundColor3 = T.surface
    searchBox.BorderSizePixel = 0
    searchBox.PlaceholderText = "🔍 Buscar..."
    searchBox.PlaceholderColor3 = T.textDim
    searchBox.TextColor3 = T.text
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 10
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus = false
    searchBox.LayoutOrder = -2
    newCorner(searchBox, UDim.new(0, 6))
    newStroke(searchBox, T.stroke, 1, 0.5)
    newPad(searchBox, 0, 8, 8, 0)

    -- Indicador pílula
    local pill = Instance.new("Frame", sidebarWrap)
    pill.Size = UDim2.new(0, 3, 0, 20)
    pill.Position = UDim2.new(0, 4, 0, 0)
    pill.BackgroundColor3 = T.accentHi
    pill.BorderSizePixel = 0
    pill.ZIndex = 20
    newCorner(pill, UDim.new(1, 0))

    -- Content
    local contentHolder = Instance.new("ScrollingFrame", mainFrame)
    contentHolder.Position = UDim2.new(0, 164, 0, 38)
    contentHolder.Size = UDim2.new(1, -172, 1, -46)
    contentHolder.BackgroundTransparency = 1
    contentHolder.BorderSizePixel = 0
    contentHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentHolder.ScrollBarThickness = 2
    contentHolder.ScrollBarImageColor3 = T.accent
    contentHolder.ScrollBarImageTransparency = 0.4
    contentHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentHolder.ZIndex = 2

    -- Resize
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

    do
        local drag, startSize, startPos
        resizeHandle.InputBegan:Connect(function(i)
            if U.IsPress(i) then drag = true; startSize = mainFrame.AbsoluteSize; startPos = i.Position end
        end)
        maid:Give(UIS.InputChanged:Connect(function(i)
            if drag and U.IsMove(i) then
                local d = i.Position - startPos
                local w = math.clamp(startSize.X + d.X, MIN_SIZE.X, MAX_SIZE.X)
                local h = math.clamp(startSize.Y + d.Y, MIN_SIZE.Y, MAX_SIZE.Y)
                mainFrame.Size = UDim2.new(0, w, 0, h)
                currentSize = Vector2.new(w, h)
            end
        end))
        maid:Give(UIS.InputEnded:Connect(function(i) if U.IsPress(i) then drag = false end end))
    end

    -- Ball button (flutuante)
    local ballButton = Instance.new("ImageButton", gui)
    ballButton.Size = UDim2.new(0, 50, 0, 50)
    ballButton.Position = UDim2.new(0.1, 0, 0.9, -150)
    ballButton.AnchorPoint = Vector2.new(0.5, 0.5)
    ballButton.BackgroundColor3 = T.accent
    ballButton.Image = NINOMAX.Icons.ball
    ballButton.Visible = false
    ballButton.Draggable = true
    newCorner(ballButton, UDim.new(0.5, 0))
    local ballStroke = newStroke(ballButton, T.accentHi, 2, 0.2)
    attachRipple(ballButton, ballButton)

    task.spawn(function()
        while ballButton.Parent do
            U.Tw(ballStroke, { Transparency = 0.8 }, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
            U.Tw(ballStroke, { Transparency = 0.2 }, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
        end
    end)

    -- Sombra segue mainFrame
    maid:Give(RunService.RenderStepped:Connect(function(dt)
        if not mainFrame.Parent then return end
        shadowHolder.Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset + 2)
        shadowHolder.Size = UDim2.new(0, mainFrame.AbsoluteSize.X + 4, 0, mainFrame.AbsoluteSize.Y + 4)

        -- Partículas
        if NINOMAX.Settings.Particles then
            for _, p in ipairs(particleData) do
                local pos = p.inst.Position
                local nx = pos.X.Scale + p.vx * dt
                local ny = pos.Y.Scale + p.vy * dt
                if ny < -0.05 then ny = 1.05; nx = math.random() end
                if nx < -0.05 then nx = 1.05 end
                if nx > 1.05 then nx = -0.05 end
                p.inst.Position = UDim2.new(nx, 0, ny, 0)
            end
        end
    end))

    -- ── Theme binding ─────────────────────────────────────────────────
    onTheme(function(newT)
        T = newT
        U.Tw(mainFrame, { BackgroundColor3 = T.bg }, 0.4)
        U.AnimateGradient(mainGrad, mainGrad.Color, T.gradient, 0.4)
        U.Tw(mainStroke, { Color = T.stroke }, 0.4)
        U.Tw(sepLine, { BackgroundColor3 = T.stroke }, 0.4)
        U.Tw(titleMax, { TextColor3 = T.accentHi }, 0.4)
        U.Tw(maxGlow, { Color = T.accentHi }, 0.4)
        U.Tw(subtitle, { TextColor3 = T.textDim }, 0.4)
        U.Tw(sidebar, { ScrollBarImageColor3 = T.accent }, 0.4)
        U.Tw(contentHolder, { ScrollBarImageColor3 = T.accent }, 0.4)
        U.Tw(ballButton, { BackgroundColor3 = T.accent }, 0.4)
        U.Tw(ballStroke, { Color = T.accentHi }, 0.4)
        U.Tw(pill, { BackgroundColor3 = T.accentHi }, 0.4)
        for _, p in ipairs(particleData) do U.Tw(p.inst, { BackgroundColor3 = T.accentHi }, 0.4) end
    end)

    -- ── Animação de entrada ───────────────────────────────────────────
    task.spawn(function()
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        mainFrame.BackgroundTransparency = 1
        shadowImg.ImageTransparency = 1
        task.wait(0.05)
        mainFrame.Size = UDim2.new(0, currentSize.X - 30, 0, currentSize.Y - 18)
        U.Tw(mainFrame, { Size = UDim2.new(0, currentSize.X, 0, currentSize.Y) }, 0.5, Enum.EasingStyle.Back)
        U.Tw(mainFrame, { BackgroundTransparency = 0.03 }, 0.35)
        U.Tw(shadowImg, { ImageTransparency = 0.55 }, 0.45)
        sidebarWrap.Position = UDim2.new(0, -40, 0, 34)
        task.wait(0.12)
        U.Tw(sidebarWrap, { Position = UDim2.new(0, 0, 0, 34) }, 0.4)
    end)

    -- ── Esconder/mostrar ──────────────────────────────────────────────
    local isHidden = false
    local function doHide()
        if isHidden then return end
        isHidden = true
        local fs = mainFrame.AbsoluteSize
        currentSize = Vector2.new(fs.X, fs.Y)
        U.Tw(mainFrame, { Size = UDim2.new(0, currentSize.X, 0, 8), BackgroundTransparency = 0.5 }, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        U.Tw(shadowImg, { ImageTransparency = 1 }, 0.22)
        task.delay(0.22, function()
            mainFrame.Visible = false
            mainFrame.Size = UDim2.new(0, currentSize.X, 0, currentSize.Y)
            mainFrame.BackgroundTransparency = 0.03
            ballButton.Visible = true
            ballButton.Size = UDim2.new(0, 0, 0, 0)
            U.Tw(ballButton, { Size = UDim2.new(0, 50, 0, 50) }, 0.3, Enum.EasingStyle.Back)
        end)
    end
    local function doShow()
        if not isHidden then return end
        isHidden = false
        U.Tw(ballButton, { Size = UDim2.new(0, 0, 0, 0) }, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.2, function()
            ballButton.Visible = false
            ballButton.Size = UDim2.new(0, 50, 0, 50)
            mainFrame.Visible = true
            mainFrame.Size = UDim2.new(0, currentSize.X, 0, 8)
            mainFrame.BackgroundTransparency = 0.5
            U.Tw(mainFrame, { Size = UDim2.new(0, currentSize.X, 0, currentSize.Y), BackgroundTransparency = 0.03 }, 0.35, Enum.EasingStyle.Back)
            U.Tw(shadowImg, { ImageTransparency = 0.55 }, 0.35)
        end)
    end

    btnMin.MouseButton1Click:Connect(function() if isHidden then doShow() else doHide() end end)
    ballButton.MouseButton1Click:Connect(doShow)
    maid:Give(UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            if isHidden then doShow() else doHide() end
        end
    end))

    -- ── Sistema de tabs (LAZY) ────────────────────────────────────────
    local tabBtns, pages, tabBuilders, selectedTab = {}, {}, {}, nil
    local windowTabs = {}
    local tabOrder = {}

    -- Move a pill pro botão da tab
    local function movePill(btn)
        if not btn or not btn.Parent then return end
        local targetY = btn.AbsolutePosition.Y - sidebar.AbsolutePosition.Y + sidebar.CanvasPosition.Y
        local targetH = btn.AbsoluteSize.Y
        U.Tw(pill, {
            Position = UDim2.new(0, 4, 0, targetY),
            Size = UDim2.new(0, 3, 0, targetH - 4),
        }, 0.3, Enum.EasingStyle.Back)
    end

    local function switchTab(name)
        for tn, f in pairs(pages) do
            if tn ~= name then
                f.Visible = false
            end
        end
        -- Lazy build
        if tabBuilders[name] and not pages[name] then
            local page = tabBuilders[name]()
            pages[name] = page
        end
        local f = pages[name]
        if f then
            f.Visible = true
            f.Position = UDim2.new(0, 14, 0, 0)
            U.Tw(f, { Position = UDim2.new(0, 0, 0, 0) }, 0.26)
            -- Cascata
            local children = f:GetChildren()
            for i, ch in ipairs(children) do
                if ch:IsA("GuiObject") and ch.Name ~= "UIListLayout" and ch.Name ~= "UIPadding" then
                    ch.BackgroundTransparency = 1
                    local targetTr = 0.05
                    task.delay(i * 0.02, function()
                        U.Tw(ch, { BackgroundTransparency = targetTr }, 0.2)
                    end)
                end
            end
        end
        for tn, btn in pairs(tabBtns) do
            local active = (tn == name)
            local marker = btn:FindFirstChild("TabMarker")
            if marker then
                U.Tw(marker, {
                    BackgroundTransparency = active and 0 or 1,
                    Size = active and UDim2.new(0, 3, 1, -8) or UDim2.new(0, 3, 0, 4),
                }, 0.25, Enum.EasingStyle.Back)
            end
            local lbl = btn:FindFirstChild("Label")
            if lbl then U.Tw(lbl, { TextTransparency = active and 0 or 0.3 }, 0.2) end
        end
        selectedTab = name
        if tabBtns[name] then movePill(tabBtns[name]) end
        NINOMAX.Events.TabChanged:Fire(name)
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = string.lower(searchBox.Text)
        for name, btn in pairs(tabBtns) do
            btn.Visible = (q == "") or (string.find(string.lower(name), q, 1, true) ~= nil)
        end
    end)

    -- ── NOTIFY ────────────────────────────────────────────────────────
    local notifyQueue, notifying = {}, false
    local function notifySg()
        local existing = gui:FindFirstChild("NotifyHolder")
        if existing then return existing end
        local holder = Instance.new("Folder", gui)
        holder.Name = "NotifyHolder"
        return holder
    end

    function NINOMAX:Notify(cfg) -- fallback global
        cfg = cfg or {}
        cfg._global = true
        return NINOMAX:_pushNotify(cfg)
    end

    function NINOMAX:_pushNotify(cfg)
        local title = cfg.Title or "Aviso"
        local text = cfg.Text or cfg.Description or ""
        local duration = cfg.Duration or 3
        local type_ = cfg.Type or "info"

        local holder = notifySg()
        local frame = Instance.new("Frame", holder)
        frame.Size = UDim2.new(0, 300, 0, 0)
        frame.Position = UDim2.new(1, 320, 1, -20)
        frame.AnchorPoint = Vector2.new(1, 1)
        frame.BackgroundColor3 = T.bg
        frame.BackgroundTransparency = 0.05
        frame.BorderSizePixel = 0
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.ClipsDescendants = true
        newCorner(frame, UDim.new(0, 8))
        local fStroke = newStroke(frame, T.accentHi, 1.2, 0.3)
        local grad = Instance.new("UIGradient", frame)
        grad.Rotation = 45
        grad.Color = T.gradient

        local accentColor = ({
            info = T.accent, success = Color3.fromRGB(60,220,120),
            warning = Color3.fromRGB(255,180,50), danger = Color3.fromRGB(255,80,90),
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
        prog.ZIndex = 5

        local pad = Instance.new("UIPadding", frame)
        pad.PaddingTop = UDim.new(0, 10)
        pad.PaddingBottom = UDim.new(0, 10)
        pad.PaddingLeft = UDim.new(0, 20)
        pad.PaddingRight = UDim.new(0, 14)

        local lay = Instance.new("UIListLayout", frame)
        lay.SortOrder = Enum.SortOrder.LayoutOrder
        lay.Padding = UDim.new(0, 4)

        local tl = Instance.new("TextLabel", frame)
        tl.BackgroundTransparency = 1
        tl.Text = title
        tl.TextColor3 = T.text
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 12
        tl.TextXAlignment = Enum.TextXAlignment.Left
        tl.Size = UDim2.new(1, 0, 0, 16)
        tl.LayoutOrder = 1

        local xl = Instance.new("TextLabel", frame)
        xl.BackgroundTransparency = 1
        xl.Text = text
        xl.TextColor3 = T.textDim
        xl.Font = Enum.Font.Gotham
        xl.TextSize = 10
        xl.TextWrapped = true
        xl.TextXAlignment = Enum.TextXAlignment.Left
        xl.TextYAlignment = Enum.TextYAlignment.Top
        xl.AutomaticSize = Enum.AutomaticSize.Y
        xl.Size = UDim2.new(1, 0, 0, 0)
        xl.LayoutOrder = 2

        table.insert(notifyQueue, { frame = frame, duration = duration, prog = prog })

        if not notifying then
            notifying = true
            task.spawn(function()
                while #notifyQueue > 0 do
                    local data = table.remove(notifyQueue, 1)
                    local f = data.frame
                    f.Position = UDim2.new(1, 320, 1, -20)
                    local targetY = -20 - (#notifyQueue * 10)
                    U.Tw(f, { Position = UDim2.new(1, -20, 1, targetY) }, 0.4, Enum.EasingStyle.Back)
                    U.Tw(data.prog, { Size = UDim2.new(0, 0, 0, 2) }, data.duration, Enum.EasingStyle.Linear)
                    task.delay(data.duration, function()
                        U.Tw(f, { Position = UDim2.new(1, 320, 1, targetY) }, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
                        task.wait(0.35)
                        f:Destroy()
                    end)
                    task.wait(data.duration + 0.3)
                end
                notifying = false
            end)
        end
    end

    -- Notify do Window delega pro global
    function Window:Notify(cfg) return NINOMAX:_pushNotify(cfg) end

    -- ── Dialog ────────────────────────────────────────────────────────
    function Window:Dialog(cfg)
        cfg = cfg or {}
        local title = cfg.Title or "Dialog"
        local text = cfg.Text or ""
        local options = cfg.Options or cfg.Buttons or { { "OK", function() end } }

        local overlay = Instance.new("Frame", gui)
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.new(0, 0, 0)
        overlay.BackgroundTransparency = 1
        overlay.BorderSizePixel = 0
        overlay.ZIndex = 100
        U.Tw(overlay, { BackgroundTransparency = 0.55 }, 0.2)

        local dlg = Instance.new("Frame", overlay)
        dlg.Size = UDim2.new(0, 0, 0, 0)
        dlg.Position = UDim2.new(0.5, 0, 0.5, 0)
        dlg.AnchorPoint = Vector2.new(0.5, 0.5)
        dlg.BackgroundColor3 = T.bg
        dlg.BorderSizePixel = 0
        dlg.ZIndex = 101
        newCorner(dlg, UDim.new(0, 10))
        newStroke(dlg, T.stroke, 1.2, 0.3)

        local grad = Instance.new("UIGradient", dlg)
        grad.Rotation = 45
        grad.Color = T.gradient

        local pad = Instance.new("UIPadding", dlg)
        pad.PaddingTop = UDim.new(0, 14)
        pad.PaddingBottom = UDim.new(0, 14)
        pad.PaddingLeft = UDim.new(0, 16)
        pad.PaddingRight = UDim.new(0, 16)

        local lay = Instance.new("UIListLayout", dlg)
        lay.SortOrder = Enum.SortOrder.LayoutOrder
        lay.Padding = UDim.new(0, 8)

        local tl = Instance.new("TextLabel", dlg)
        tl.BackgroundTransparency = 1
        tl.Text = title
        tl.TextColor3 = T.text
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 13
        tl.TextXAlignment = Enum.TextXAlignment.Left
        tl.Size = UDim2.new(1, 0, 0, 16)
        tl.LayoutOrder = 1

        local xl = Instance.new("TextLabel", dlg)
        xl.BackgroundTransparency = 1
        xl.Text = text
        xl.TextColor3 = T.textDim
        xl.Font = Enum.Font.Gotham
        xl.TextSize = 10
        xl.TextWrapped = true
        xl.TextXAlignment = Enum.TextXAlignment.Left
        xl.TextYAlignment = Enum.TextYAlignment.Top
        xl.AutomaticSize = Enum.AutomaticSize.Y
        xl.Size = UDim2.new(1, 0, 0, 0)
        xl.LayoutOrder = 2

        local btnHolder = Instance.new("Frame", dlg)
        btnHolder.Size = UDim2.new(1, 0, 0, 26)
        btnHolder.BackgroundTransparency = 1
        btnHolder.LayoutOrder = 3
        local bhl = Instance.new("UIListLayout", btnHolder)
        bhl.FillDirection = Enum.FillDirection.Horizontal
        bhl.Padding = UDim.new(0, 6)
        bhl.HorizontalAlignment = Enum.HorizontalAlignment.Right

        local function close()
            U.Tw(dlg, { Size = UDim2.new(0, 0, 0, 0) }, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            U.Tw(overlay, { BackgroundTransparency = 1 }, 0.2)
            task.delay(0.25, function() overlay:Destroy() end)
        end

        for _, bd in ipairs(options) do
            local name = bd[1]
            local cb = bd[2] or function() end
            local b = Instance.new("TextButton", btnHolder)
            b.Size = UDim2.new(0, 90, 1, 0)
            b.BackgroundColor3 = T.surfaceHi
            b.Text = name
            b.TextColor3 = T.text
            b.Font = Enum.Font.GothamBold
            b.TextSize = 10
            b.AutoButtonColor = false
            newCorner(b, UDim.new(0, 6))
            newStroke(b, T.stroke, 1, 0.4)
            attachRipple(b, b)
            b.MouseEnter:Connect(function() U.Tw(b, { BackgroundColor3 = U.Mix(T.surfaceHi, T.accent, 0.35) }, 0.15) end)
            b.MouseLeave:Connect(function() U.Tw(b, { BackgroundColor3 = T.surfaceHi }, 0.15) end)
            b.MouseButton1Click:Connect(function()
                close()
                task.delay(0.25, function() pcall(cb) end)
            end)
        end

        dlg.Size = UDim2.new(0, 320, 0, 0)
        U.Tw(dlg, { Size = UDim2.new(0, 320, 0, dlg.AbsoluteSize.Y + 10) }, 0.35, Enum.EasingStyle.Back)
        return { Close = close }
    end

    -- ── CREATE TAB ────────────────────────────────────────────────────
    function Window:CreateTab(tabName, iconName)
        local icon = U.Icon(iconName)
        table.insert(tabOrder, tabName)

        local tabBtn = Instance.new("TextButton", sidebar)
        tabBtn.Name = tabName
        tabBtn.Size = UDim2.new(1, 0, 0, 26)
        tabBtn.Text = ""
        tabBtn.BackgroundColor3 = T.surface
        tabBtn.BackgroundTransparency = 1
        tabBtn.AutoButtonColor = false
        tabBtn.ClipsDescendants = true
        newCorner(tabBtn, UDim.new(0, 6))
        local tabStroke = newStroke(tabBtn, T.stroke, 1, 1)
        attachRipple(tabBtn, tabBtn)

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
            iconImg.Size = UDim2.new(0, 14, 0, 14)
            iconImg.Position = UDim2.new(0, 8, 0.5, -7)
            iconImg.BackgroundTransparency = 1
            iconImg.Image = icon
            iconImg.ImageColor3 = T.textDim
            iconImg.ImageTransparency = 0.3
        end

        local label = Instance.new("TextLabel", tabBtn)
        label.Name = "Label"
        label.BackgroundTransparency = 1
        label.Text = tabName
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 11
        label.TextColor3 = T.text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextTransparency = 0.3
        label.TextTruncate = Enum.TextTruncate.AtEnd
        label.Position = iconImg and UDim2.new(0, 28, 0, 0) or UDim2.new(0, 12, 0, 0)
        label.Size = iconImg and UDim2.new(1, -32, 1, 0) or UDim2.new(1, -12, 1, 0)

        tabBtns[tabName] = tabBtn

        onTheme(function()
            U.Tw(tabStroke, { Color = T.stroke }, 0.35)
            if selectedTab == tabName then
                U.Tw(tabBtn, { BackgroundColor3 = T.surfaceHi, BackgroundTransparency = 0 }, 0.35)
                U.Tw(label, { TextColor3 = T.text, TextTransparency = 0 }, 0.35)
                if iconImg then U.Tw(iconImg, { ImageColor3 = T.accentHi, ImageTransparency = 0 }, 0.35) end
                U.Tw(marker, { BackgroundColor3 = T.accentHi }, 0.35)
            else
                U.Tw(tabBtn, { BackgroundColor3 = T.surface, BackgroundTransparency = 1 }, 0.35)
                U.Tw(label, { TextColor3 = T.text, TextTransparency = 0.3 }, 0.35)
                if iconImg then U.Tw(iconImg, { ImageColor3 = T.textDim, ImageTransparency = 0.3 }, 0.35) end
            end
        end)

        tabBtn.MouseEnter:Connect(function()
            if selectedTab ~= tabName then
                U.Tw(tabBtn, { BackgroundColor3 = T.surfaceHi, BackgroundTransparency = 0.4 }, 0.18)
                U.Tw(label, { TextTransparency = 0.05 }, 0.18)
                if iconImg then U.Tw(iconImg, { ImageTransparency = 0.05, ImageColor3 = T.text }, 0.18) end
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if selectedTab ~= tabName then
                U.Tw(tabBtn, { BackgroundColor3 = T.surface, BackgroundTransparency = 1 }, 0.18)
                U.Tw(label, { TextTransparency = 0.3 }, 0.18)
                if iconImg then U.Tw(iconImg, { ImageTransparency = 0.3, ImageColor3 = T.textDim }, 0.18) end
            end
        end)

        tabBtn.MouseButton1Click:Connect(function() switchTab(tabName) end)

        -- Lazy builder
        local Tab = {}
        local built = false
        local function getPage()
            if not pages[tabName] then
                local page = Instance.new("Frame", contentHolder)
                page.Name = tabName
                page.Size = UDim2.new(1, 0, 0, 1000)
                page.BackgroundTransparency = 1
                page.Visible = false
                local layout = Instance.new("UIListLayout", page)
                layout.SortOrder = Enum.SortOrder.LayoutOrder
                layout.Padding = UDim.new(0, 6)
                newPad(page, 4, 4, 12, 4)
                pages[tabName] = page
            end
            return pages[tabName]
        end

        local function makeRow(title, desc, customHeight)
            local page = getPage()
            local f = Instance.new("Frame", page)
            f.Size = UDim2.new(1, 0, 0, customHeight or 28)
            f.BackgroundColor3 = T.surface
            f.BackgroundTransparency = 0.05
            f.BorderSizePixel = 0
            newCorner(f, UDim.new(0, 6))
            local fStroke = newStroke(f, T.stroke, 1, 0.7)
            attachRipple(f, f)

            local titleLbl = Instance.new("TextLabel", f)
            titleLbl.BackgroundTransparency = 1
            titleLbl.Text = title or "Row"
            titleLbl.Font = Enum.Font.GothamMedium
            titleLbl.TextSize = 11
            titleLbl.TextColor3 = T.text
            titleLbl.TextXAlignment = Enum.TextXAlignment.Left
            titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
            titleLbl.Size = UDim2.new(1, -120, 0, desc and desc ~= "" and 12 or 16)
            titleLbl.Position = UDim2.new(0, 12, 0, desc and desc ~= "" and 5 or 6)

            local descLbl
            if desc and desc ~= "" then
                f.Size = UDim2.new(1, 0, 0, customHeight or 32)
                descLbl = Instance.new("TextLabel", f)
                descLbl.BackgroundTransparency = 1
                descLbl.Text = desc
                descLbl.Font = Enum.Font.Gotham
                descLbl.TextSize = 9
                descLbl.TextColor3 = T.textDim
                descLbl.TextXAlignment = Enum.TextXAlignment.Left
                descLbl.TextTruncate = Enum.TextTruncate.AtEnd
                descLbl.Size = UDim2.new(1, -120, 0, 10)
                descLbl.Position = UDim2.new(0, 12, 0, 18)
            end

            onTheme(function()
                U.Tw(f, { BackgroundColor3 = T.surface }, 0.35)
                U.Tw(fStroke, { Color = T.stroke }, 0.35)
                U.Tw(titleLbl, { TextColor3 = T.text }, 0.35)
                if descLbl then U.Tw(descLbl, { TextColor3 = T.textDim }, 0.35) end
            end)

            return f, titleLbl, descLbl, fStroke
        end

        -- ADD SECTION
        function Tab:AddSection(name)
            local page = getPage()
            local s = Instance.new("Frame", page)
            s.Size = UDim2.new(1, 0, 0, 24)
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
                U.Tw(lbl, { TextColor3 = T.text }, 0.35)
                U.Tw(line, { BackgroundColor3 = T.stroke }, 0.35)
            end)
            return { Set = function(_, v) lbl.Text = string.upper(v) end, Destroy = function() s:Destroy() end }
        end

        -- ADD LABEL
        function Tab:AddLabel(text)
            local page = getPage()
            local lbl = Instance.new("TextLabel", page)
            lbl.Size = UDim2.new(1, -8, 0, 16)
            lbl.BackgroundTransparency = 1
            lbl.Text = text or ""
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 10
            lbl.TextColor3 = T.textDim
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextWrapped = true
            onTheme(function() U.Tw(lbl, { TextColor3 = T.textDim }, 0.35) end)
            return { Set = function(_, v) lbl.Text = tostring(v) end, Destroy = function() lbl:Destroy() end }
        end

        -- ADD PARAGRAPH
        function Tab:AddParagraph(cfg)
            cfg = cfg or {}
            if type(cfg) == "string" then cfg = { Title = cfg } end
            local f, tL, dL = makeRow(cfg.Title or "Paragraph", cfg.Text or "", 40)
            return {
                SetTitle = function(_, v) tL.Text = tostring(v) end,
                SetDesc  = function(_, v) dL.Text = tostring(v) end,
                Destroy  = function() f:Destroy() end,
            }
        end

        -- ADD LINE
        function Tab:AddLine(color)
            local page = getPage()
            local l = Instance.new("Frame", page)
            l.Size = UDim2.new(1, -8, 0, 1)
            l.BackgroundColor3 = color or T.stroke
            l.BackgroundTransparency = 0.4
            l.BorderSizePixel = 0
            local g = Instance.new("UIGradient", l)
            g.Transparency = NumberSequence.new(1, 0, 1)
            onTheme(function() U.Tw(l, { BackgroundColor3 = color or T.stroke }, 0.35) end)
            return { Destroy = function() l:Destroy() end }
        end

        -- ADD BUTTON
        function Tab:AddButton(cfg)
            cfg = cfg or {}
            if type(cfg) == "string" then cfg = { Title = cfg } end
            local title = cfg.Title or cfg.Name or "Button"
            local desc = cfg.Desc or cfg.Description or ""
            local cb = cfg.Callback or function() end
            local cooldown = cfg.Cooldown or 0.5

            local f, tL, dL, fS = makeRow(title, desc)
            f.ClipsDescendants = true

            local arrow = Instance.new("ImageLabel", f)
            arrow.Size = UDim2.new(0, 12, 0, 12)
            arrow.Position = UDim2.new(1, -12, 0.5, -6)
            arrow.BackgroundTransparency = 1
            arrow.Image = NINOMAX.Icons.chevronright
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
                U.Tw(f, { BackgroundColor3 = T.surfaceHi, BackgroundTransparency = 0 }, 0.15)
                U.Tw(fS, { Color = T.accentHi, Transparency = 0.3 }, 0.15)
                U.Tw(arrow, { ImageColor3 = T.accentHi }, 0.15)
                shine.Position = UDim2.new(-0.3, 0, 0, 0)
                U.Tw(shine, { Position = UDim2.new(1.2, 0, 0, 0) }, 0.7, Enum.EasingStyle.Quart)
            end)
            f.MouseLeave:Connect(function()
                U.Tw(f, { BackgroundColor3 = T.surface, BackgroundTransparency = 0.05 }, 0.15)
                U.Tw(fS, { Color = T.stroke, Transparency = 0.7 }, 0.15)
                U.Tw(arrow, { ImageColor3 = T.textDim }, 0.15)
            end)

            local cooling = false
            btn.MouseButton1Click:Connect(function()
                if cooling then return end
                cooling = true
                U.PlaySound("click")
                U.Tw(f, { Size = UDim2.new(1, -4, 0, f.Size.Y.Offset) }, 0.06)
                task.delay(0.06, function()
                    U.Tw(f, { Size = UDim2.new(1, 0, 0, f.Size.Y.Offset) }, 0.15, Enum.EasingStyle.Back)
                end)
                pcall(cb)
                task.delay(cooldown, function() cooling = false end)
            end)
            attachRipple(f, btn)

            return { Set = function(_, v) tL.Text = tostring(v) end, Destroy = function() f:Destroy() end }
        end

        -- ADD TOGGLE
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
                    U.Tw(sw, { BackgroundColor3 = T.accent }, 0.25, Enum.EasingStyle.Back)
                    U.Tw(ball, { Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Color3.new(1, 1, 1) }, 0.25, Enum.EasingStyle.Back)
                else
                    U.Tw(sw, { BackgroundColor3 = T.stroke }, 0.25, Enum.EasingStyle.Back)
                    U.Tw(ball, { Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Color3.fromRGB(200, 200, 205) }, 0.25, Enum.EasingStyle.Back)
                end
                if not silent then
                    U.PlaySound("toggle")
                    if flag then NINOMAX:SetFlag(flag, isOn) end
                    pcall(cb, isOn)
                end
            end
            apply(default, true)

            onTheme(function()
                if isOn then U.Tw(sw, { BackgroundColor3 = T.accent }, 0.35)
                else U.Tw(sw, { BackgroundColor3 = T.stroke }, 0.35) end
            end)

            btn.MouseEnter:Connect(function()
                U.Tw(f, { BackgroundColor3 = T.surfaceHi, BackgroundTransparency = 0 }, 0.15)
                U.Tw(fS, { Color = T.accentHi, Transparency = 0.3 }, 0.15)
            end)
            btn.MouseLeave:Connect(function()
                U.Tw(f, { BackgroundColor3 = T.surface, BackgroundTransparency = 0.05 }, 0.15)
                U.Tw(fS, { Color = T.stroke, Transparency = 0.7 }, 0.15)
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

        -- ADD CHECKBOX
        function Tab:AddCheckbox(cfg)
            cfg = cfg or {}
            if type(cfg) == "string" then cfg = { Title = cfg } end
            local title = cfg.Title or cfg.Name or "Checkbox"
            local desc = cfg.Desc or cfg.Description or ""
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag
            local default = cfg.Default or false
            if flag and NINOMAX.Flags[flag] ~= nil then default = NINOMAX.Flags[flag] end

            local f, tL, dL, fS = makeRow(title, desc)

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
                    U.Tw(box, { BackgroundColor3 = T.accent }, 0.2, Enum.EasingStyle.Back)
                    U.Tw(boxStroke, { Color = T.accentHi, Transparency = 0 }, 0.2)
                else
                    U.Tw(box, { BackgroundColor3 = T.stroke }, 0.2, Enum.EasingStyle.Back)
                    U.Tw(boxStroke, { Color = T.stroke, Transparency = 0.4 }, 0.2)
                end
                if not silent then
                    U.PlaySound("toggle")
                    if flag then NINOMAX:SetFlag(flag, toggled) end
                    pcall(cb, toggled)
                end
            end
            apply(default, true)

            onTheme(function()
                if toggled then
                    U.Tw(box, { BackgroundColor3 = T.accent }, 0.35)
                    U.Tw(boxStroke, { Color = T.accentHi }, 0.35)
                else
                    U.Tw(box, { BackgroundColor3 = T.stroke }, 0.35)
                    U.Tw(boxStroke, { Color = T.stroke }, 0.35)
                end
            end)

            btn.MouseEnter:Connect(function()
                U.Tw(f, { BackgroundColor3 = T.surfaceHi, BackgroundTransparency = 0 }, 0.15)
                U.Tw(fS, { Color = T.accentHi, Transparency = 0.3 }, 0.15)
                U.Tw(boxStroke, { Color = T.accentHi, Transparency = 0.1 }, 0.15)
            end)
            btn.MouseLeave:Connect(function()
                U.Tw(f, { BackgroundColor3 = T.surface, BackgroundTransparency = 0.05 }, 0.15)
                U.Tw(fS, { Color = T.stroke, Transparency = 0.7 }, 0.15)
                if not toggled then U.Tw(boxStroke, { Color = T.stroke, Transparency = 0.4 }, 0.15) end
            end)

            btn.MouseButton1Click:Connect(function() apply(not toggled) end)

            return {
                Set = function(_, v) apply(v, false) end,
                Get = function() return toggled end,
                Destroy = function() f:Destroy() end,
            }
        end

        -- ADD SWITCH (com glow)
        function Tab:AddSwitch(cfg)
            cfg = cfg or {}
            if type(cfg) == "string" then cfg = { Title = cfg } end
            local title = cfg.Title or cfg.Name or "Switch"
            local desc = cfg.Desc or cfg.Description or ""
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag
            local default = cfg.Default or false
            if flag and NINOMAX.Flags[flag] ~= nil then default = NINOMAX.Flags[flag] end

            local f, tL, dL, fS = makeRow(title, desc)

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
                    U.Tw(circle, { Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Color3.new(1, 1, 1) }, 0.25, Enum.EasingStyle.Back)
                    U.Tw(sw, { BackgroundColor3 = T.accent }, 0.25, Enum.EasingStyle.Back)
                    U.Tw(glow, { Transparency = 0 }, 0.25)
                else
                    U.Tw(circle, { Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(210, 210, 215) }, 0.25, Enum.EasingStyle.Back)
                    U.Tw(sw, { BackgroundColor3 = T.stroke }, 0.25, Enum.EasingStyle.Back)
                    U.Tw(glow, { Transparency = 1 }, 0.25)
                end
                if not silent then
                    U.PlaySound("toggle")
                    if flag then NINOMAX:SetFlag(flag, state) end
                    pcall(cb, state)
                end
            end
            apply(default, true)

            onTheme(function()
                if state then
                    U.Tw(sw, { BackgroundColor3 = T.accent }, 0.35)
                    U.Tw(glow, { Color = T.accentHi }, 0.35)
                else
                    U.Tw(sw, { BackgroundColor3 = T.stroke }, 0.35)
                end
            end)

            btn.MouseEnter:Connect(function()
                U.Tw(f, { BackgroundColor3 = T.surfaceHi, BackgroundTransparency = 0 }, 0.15)
                U.Tw(fS, { Color = T.accentHi, Transparency = 0.3 }, 0.15)
            end)
            btn.MouseLeave:Connect(function()
                U.Tw(f, { BackgroundColor3 = T.surface, BackgroundTransparency = 0.05 }, 0.15)
                U.Tw(fS, { Color = T.stroke, Transparency = 0.7 }, 0.15)
            end)

            btn.MouseButton1Click:Connect(function() apply(not state) end)

            return {
                Set = function(_, v) apply(v, false) end,
                Get = function() return state end,
                Destroy = function() f:Destroy() end,
            }
        end

        -- ADD SLIDER (com input manual no valor)
        function Tab:AddSlider(cfg)
            cfg = cfg or {}
            local title = cfg.Title or cfg.Name or "Slider"
            local min = cfg.Min or 0
            local max = cfg.Max or 100
            local default = cfg.Default or min
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag
            local suffix = cfg.Suffix or ""
            if flag and NINOMAX.Flags[flag] ~= nil then default = NINOMAX.Flags[flag] end

            local page = getPage()
            local holder = Instance.new("Frame", page)
            holder.Size = UDim2.new(1, 0, 0, 46)
            holder.BackgroundColor3 = T.surface
            holder.BackgroundTransparency = 0.05
            holder.BorderSizePixel = 0
            newCorner(holder, UDim.new(0, 6))
            local bgS = newStroke(holder, T.stroke, 1, 0.7)

            local t = Instance.new("TextLabel", holder)
            t.Size = UDim2.new(1, -70, 0, 12)
            t.Position = UDim2.new(0, 12, 0, 6)
            t.Text = title
            t.TextColor3 = T.text
            t.TextSize = 11
            t.Font = Enum.Font.GothamMedium
            t.BackgroundTransparency = 1
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.TextTruncate = Enum.TextTruncate.AtEnd

            local vl = Instance.new("TextBox", holder)
            vl.Size = UDim2.new(0, 55, 0, 14)
            vl.Position = UDim2.new(1, -64, 0, 5)
            vl.Text = tostring(default) .. suffix
            vl.TextColor3 = T.accentHi
            vl.TextSize = 11
            vl.Font = Enum.Font.GothamBold
            vl.BackgroundTransparency = 1
            vl.ClearTextOnFocus = false

            local bar = Instance.new("Frame", holder)
            bar.Size = UDim2.new(1, -24, 0, 8)
            bar.Position = UDim2.new(0, 12, 0, 30)
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
            knob.Size = UDim2.new(0, 12, 0, 12)
            knob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
            knob.BorderSizePixel = 0
            newCorner(knob, UDim.new(1, 0))
            local knobStroke = newStroke(knob, T.accentHi, 1.5, 0.3)

            onTheme(function()
                U.Tw(holder, { BackgroundColor3 = T.surface }, 0.35)
                U.Tw(bgS, { Color = T.stroke }, 0.35)
                U.Tw(t, { TextColor3 = T.text }, 0.35)
                U.Tw(fill, { BackgroundColor3 = T.accent }, 0.35)
                U.AnimateGradient(fg, fg.Color, ColorSequence.new(T.accentSoft, T.accentHi), 0.35)
                U.Tw(vl, { TextColor3 = T.accentHi }, 0.35)
                U.Tw(bar, { BackgroundColor3 = T.stroke }, 0.35)
                U.Tw(knobStroke, { Color = T.accentHi }, 0.35)
            end)

            local function update(x, silent)
                local bp = bar.AbsolutePosition.X
                local bw = bar.AbsoluteSize.X
                if bw <= 0 then return end
                local c = math.clamp((x - bp) / bw, 0, 1)
                local val = min + (max - min) * c
                if max - min > 20 then val = math.floor(val + 0.5) end
                fill.Size = UDim2.new(c, 0, 1, 0)
                knob.Position = UDim2.new(c, 0, 0.5, 0)
                vl.Text = tostring(val) .. suffix
                if not silent then
                    if flag then NINOMAX:SetFlag(flag, val) end
                    pcall(cb, val)
                end
            end

            local drag = false
            bar.InputBegan:Connect(function(i)
                if U.IsPress(i) then
                    drag = true
                    U.Tw(knob, { Size = UDim2.new(0, 15, 0, 15) }, 0.12, Enum.EasingStyle.Back)
                    update(i.Position.X)
                end
            end)
            UIS.InputChanged:Connect(function(i)
                if drag and U.IsMove(i) then update(i.Position.X) end
            end)
            UIS.InputEnded:Connect(function(i)
                if U.IsPress(i) then
                    drag = false
                    U.Tw(knob, { Size = UDim2.new(0, 12, 0, 12) }, 0.15, Enum.EasingStyle.Back)
                end
            end)

            vl.Focused:Connect(function() vl.TextColor3 = T.text end)
            vl.FocusLost:Connect(function()
                local n = tonumber(vl.Text:gsub("[^%-%d%.]", ""))
                if n then
                    n = math.clamp(n, min, max)
                    update(bar.AbsolutePosition.X + (n - min) / (max - min) * bar.AbsoluteSize.X, true)
                    if flag then NINOMAX:SetFlag(flag, n) end
                    pcall(cb, n)
                end
                vl.TextColor3 = T.accentHi
                vl.Text = tostring(tonumber(vl.Text:gsub("[^%-%d%.]", "")) or default) .. suffix
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
                Get = function()
                    local c = fill.Size.X.Scale
                    return min + (max - min) * c
                end,
                Destroy = function() holder:Destroy() end,
            }
        end

        -- ADD DROPDOWN (com busca + multi-select)
        function Tab:AddDropdown(cfg)
            cfg = cfg or {}
            local title = cfg.Title or cfg.Name or "Dropdown"
            local desc = cfg.Desc or cfg.Description or ""
            local options = cfg.Options or {}
            local default = cfg.Default
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag
            local multi = cfg.Multi or false
            local searchable = cfg.Searchable ~= false and #options > 6
            if flag and NINOMAX.Flags[flag] ~= nil then default = NINOMAX.Flags[flag] end

            local f, tL, dL, fS = makeRow(title, desc)

            local sel = Instance.new("TextLabel", f)
            sel.BackgroundTransparency = 1
            if multi and type(default) == "table" then
                sel.Text = #default > 0 and table.concat(default, ", ") or "Selecionar"
            else
                sel.Text = tostring(default or "Selecionar")
            end
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
            arrow.Image = NINOMAX.Icons.chevrondown
            arrow.ImageColor3 = T.textDim

            local btn = Instance.new("TextButton", f)
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.ZIndex = 10

            local list = Instance.new("Frame", gui)
            list.Size = UDim2.new(0, 200, 0, 0)
            list.BackgroundColor3 = T.surface
            list.BorderSizePixel = 0
            list.Visible = false
            list.ClipsDescendants = true
            list.ZIndex = 999
            newCorner(list, UDim.new(0, 8))
            local listStroke = newStroke(list, T.stroke, 1, 0.4)

            -- Search bar (dentro do list)
            local searchInner
            if searchable then
                searchInner = Instance.new("TextBox", list)
                searchInner.Size = UDim2.new(1, -12, 0, 22)
                searchInner.Position = UDim2.new(0, 6, 0, 6)
                searchInner.BackgroundColor3 = T.surfaceHi
                searchInner.BorderSizePixel = 0
                searchInner.PlaceholderText = "🔍 Buscar..."
                searchInner.PlaceholderColor3 = T.textDim
                searchInner.TextColor3 = T.text
                searchInner.Font = Enum.Font.Gotham
                searchInner.TextSize = 10
                searchInner.TextXAlignment = Enum.TextXAlignment.Left
                searchInner.ClearTextOnFocus = false
                newCorner(searchInner, UDim.new(0, 5))
                newPad(searchInner, 0, 6, 6, 0)
            end

            local listTop = searchable and 34 or 6

            local scroll = Instance.new("ScrollingFrame", list)
            scroll.Size = UDim2.new(1, -6, 1, -listTop - 6)
            scroll.Position = UDim2.new(0, 3, 0, listTop)
            scroll.BackgroundTransparency = 1
            scroll.BorderSizePixel = 0
            scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            scroll.ScrollBarThickness = 2
            scroll.ScrollBarImageColor3 = T.accent

            local listLay = Instance.new("UIListLayout", scroll)
            listLay.Padding = UDim.new(0, 2)
            listLay.SortOrder = Enum.SortOrder.LayoutOrder

            local selected = multi and (type(default) == "table" and default or {}) or default
            local optBtns = {}

            local function isSelected(opt)
                if multi then
                    for _, v in ipairs(selected) do if v == opt then return true end end
                    return false
                else
                    return selected == opt
                end
            end

            local function updateLabel()
                if multi then
                    local txt = #selected > 0 and table.concat(selected, ", ") or "Selecionar"
                    sel.Text = txt
                else
                    sel.Text = tostring(selected or "Selecionar")
                end
            end

            local function closeList()
                list.Visible = false
                U.Tw(arrow, { Rotation = 0 }, 0.2)
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
                dot.Visible = isSelected(opt)
                newCorner(dot, UDim.new(1, 0))

                local ol = Instance.new("TextLabel", o)
                ol.BackgroundTransparency = 1
                ol.Text = tostring(opt)
                ol.TextColor3 = T.text
                ol.TextTransparency = isSelected(opt) and 0 or 0.35
                ol.Font = Enum.Font.GothamMedium
                ol.TextSize = 10
                ol.TextXAlignment = Enum.TextXAlignment.Left
                ol.Position = UDim2.new(0, 18, 0, 0)
                ol.Size = UDim2.new(1, -22, 1, 0)
                ol.TextTruncate = Enum.TextTruncate.AtEnd

                o.MouseEnter:Connect(function()
                    U.Tw(o, { BackgroundColor3 = T.surfaceHi, BackgroundTransparency = 0 }, 0.12)
                    U.Tw(ol, { TextTransparency = 0 }, 0.12)
                end)
                o.MouseLeave:Connect(function()
                    U.Tw(o, { BackgroundTransparency = 1 }, 0.12)
                    if not isSelected(opt) then U.Tw(ol, { TextTransparency = 0.35 }, 0.12) end
                end)
                o.MouseButton1Click:Connect(function()
                    if multi then
                        local found = false
                        for k, v in ipairs(selected) do
                            if v == opt then table.remove(selected, k); found = true; break end
                        end
                        if not found then table.insert(selected, opt) end
                        dot.Visible = isSelected(opt)
                        U.Tw(ol, { TextTransparency = isSelected(opt) and 0 or 0.35 }, 0.2)
                        updateLabel()
                        if flag then NINOMAX:SetFlag(flag, selected) end
                        pcall(cb, selected)
                    else
                        for _, v in pairs(optBtns) do
                            v.dot.Visible = false
                            U.Tw(v.label, { TextTransparency = 0.35 }, 0.2)
                        end
                        dot.Visible = true
                        U.Tw(ol, { TextTransparency = 0 }, 0.2)
                        selected = opt
                        updateLabel()
                        if flag then NINOMAX:SetFlag(flag, selected) end
                        pcall(cb, opt)
                        closeList()
                    end
                end)
                optBtns[opt] = { btn = o, dot = dot, label = ol }
            end

            if searchInner then
                searchInner:GetPropertyChangedSignal("Text"):Connect(function()
                    local q = string.lower(searchInner.Text)
                    for optName, refs in pairs(optBtns) do
                        refs.btn.Visible = (q == "") or string.find(string.lower(tostring(optName)), q, 1, true) ~= nil
                    end
                end)
            end

            local function openList()
                list.Visible = true
                local ap = f.AbsolutePosition
                local av = f.AbsoluteSize
                list.Position = UDim2.new(0, ap.X, 0, ap.Y + av.Y + 4)
                local targetH = math.min(#options * 24 + 12 + (searchable and 28 or 0), 240)
                list.Size = UDim2.new(0, 200, 0, 0)
                U.Tw(list, { Size = UDim2.new(0, 200, 0, targetH) }, 0.25, Enum.EasingStyle.Back)
                U.Tw(arrow, { Rotation = 180 }, 0.2)
                if searchInner then searchInner.Text = "" end
            end

            btn.MouseButton1Click:Connect(function()
                if list.Visible then closeList() else openList() end
            end)

            f.MouseEnter:Connect(function()
                U.Tw(f, { BackgroundColor3 = T.surfaceHi, BackgroundTransparency = 0 }, 0.15)
                U.Tw(fS, { Color = T.accentHi, Transparency = 0.3 }, 0.15)
            end)
            f.MouseLeave:Connect(function()
                U.Tw(f, { BackgroundColor3 = T.surface, BackgroundTransparency = 0.05 }, 0.15)
                U.Tw(fS, { Color = T.stroke, Transparency = 0.7 }, 0.15)
            end)

            onTheme(function()
                U.Tw(list, { BackgroundColor3 = T.surface }, 0.35)
                U.Tw(listStroke, { Color = T.stroke }, 0.35)
                for _, v in pairs(optBtns) do
                    U.Tw(v.dot, { BackgroundColor3 = T.accentHi }, 0.35)
                    U.Tw(v.label, { TextColor3 = T.text }, 0.35)
                end
                U.Tw(sel, { TextColor3 = T.accentHi }, 0.35)
            end)

            return {
                Set = function(_, v)
                    selected = multi and v or v
                    for k, refs in pairs(optBtns) do
                        local on = multi and (function() for _, x in ipairs(selected) do if x == k then return true end end return false end)() or (k == v)
                        refs.dot.Visible = on
                        U.Tw(refs.label, { TextTransparency = on and 0 or 0.35 }, 0.2)
                    end
                    updateLabel()
                    if flag then NINOMAX:SetFlag(flag, selected) end
                    pcall(cb, selected)
                end,
                Destroy = function() f:Destroy(); list:Destroy() end,
            }
        end

        -- ADD TEXTBOX
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
            box.ZIndex = 10
            newCorner(box, UDim.new(0, 5))
            local boxS = newStroke(box, T.stroke, 1, 0.4)
            newPad(box, 0, 8, 8, 0)

            onTheme(function()
                U.Tw(box, { BackgroundColor3 = T.surfaceHi, TextColor3 = T.text, PlaceholderColor3 = T.textDim }, 0.35)
                U.Tw(boxS, { Color = T.stroke }, 0.35)
            end)

            box.Focused:Connect(function() U.Tw(boxS, { Color = T.accentHi, Transparency = 0 }, 0.2) end)
            box.FocusLost:Connect(function(enter)
                U.Tw(boxS, { Color = T.stroke, Transparency = 0.4 }, 0.2)
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

        -- ADD KEYBIND
        function Tab:AddKeybind(cfg)
            cfg = cfg or {}
            local title = cfg.Title or cfg.Name or "Keybind"
            local default = cfg.Default or "Nenhuma"
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag
            if flag and NINOMAX.Flags[flag] ~= nil then default = NINOMAX.Flags[flag] end

            local f, tL, dL, fS = makeRow(title, "")

            local kbBtn = Instance.new("TextButton", f)
            kbBtn.Size = UDim2.new(0, 90, 0, 20)
            kbBtn.Position = UDim2.new(1, -10, 0.5, -10)
            kbBtn.AnchorPoint = Vector2.new(1, 0)
            kbBtn.BackgroundColor3 = T.surfaceHi
            kbBtn.Text = default
            kbBtn.TextColor3 = T.text
            kbBtn.Font = Enum.Font.Code
            kbBtn.TextSize = 10
            kbBtn.AutoButtonColor = false
            newCorner(kbBtn, UDim.new(0, 5))
            local kbS = newStroke(kbBtn, T.stroke, 1, 0.4)

            local capturing = false
            local currentKey = default

            kbBtn.MouseButton1Click:Connect(function()
                capturing = not capturing
                kbBtn.Text = capturing and "Pressione..." or currentKey
                kbBtn.TextColor3 = capturing and T.accentHi or T.text
                U.Tw(kbS, { Color = capturing and T.accentHi or T.stroke }, 0.2)
            end)

            maid:Give(UIS.InputBegan:Connect(function(input, gpe)
                if gpe or not capturing then return end
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode.Name
                    kbBtn.Text = currentKey
                    kbBtn.TextColor3 = T.text
                    capturing = false
                    U.Tw(kbS, { Color = T.stroke }, 0.2)
                    if flag then NINOMAX:SetFlag(flag, currentKey) end
                    pcall(cb, input.KeyCode)
                end
            end))

            onTheme(function()
                U.Tw(kbBtn, { BackgroundColor3 = T.surfaceHi, TextColor3 = T.text }, 0.35)
                U.Tw(kbS, { Color = T.stroke }, 0.35)
            end)

            return {
                Set = function(_, v) currentKey = v; kbBtn.Text = v end,
                Destroy = function() f:Destroy() end,
            }
        end

        -- ADD COLOR PICKER (com ciclar e presets)
        function Tab:AddColorPicker(cfg)
            cfg = cfg or {}
            local title = cfg.Title or cfg.Name or "Cor"
            local default = cfg.Default or Color3.fromRGB(220, 30, 55)
            local cb = cfg.Callback or function() end
            local flag = cfg.Flag
            if flag and NINOMAX.Flags[flag] ~= nil then
                local fv = NINOMAX.Flags[flag]
                if type(fv) == "table" then pcall(function() default = Color3.fromRGB(fv[1], fv[2], fv[3]) end) end
            end

            local current = default
            local h, s, v = Color3.toHSV(current)

            local page = getPage()
            local frame = Instance.new("Frame", page)
            frame.Size = UDim2.new(1, 0, 0, 28)
            frame.BackgroundColor3 = T.surface
            frame.BackgroundTransparency = 0.05
            frame.ClipsDescendants = true
            frame.BorderSizePixel = 0
            newCorner(frame, UDim.new(0, 6))
            local fS = newStroke(frame, T.stroke, 1, 0.7)

            local header = Instance.new("TextButton", frame)
            header.Size = UDim2.new(1, 0, 0, 28)
            header.BackgroundTransparency = 1
            header.Text = ""

            local lbl = Instance.new("TextLabel", header)
            lbl.BackgroundTransparency = 1
            lbl.Text = title
            lbl.TextColor3 = T.text
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Position = UDim2.new(0, 12, 0, 0)
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
            body.Position = UDim2.new(0, 0, 0, 28)
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
            infoCol.Size = UDim2.new(0, 100, 0, padSize)
            infoCol.Position = UDim2.new(1, -110, 0, 10)
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
            hexBox.Text = U.ToHex(current)
            hexBox.ClearTextOnFocus = false
            newCorner(hexBox, UDim.new(0, 4))
            newStroke(hexBox, T.stroke, 1, 0.5)

            local rgbHolder = Instance.new("Frame", infoCol)
            rgbHolder.Size = UDim2.new(1, 0, 0, 22)
            rgbHolder.Position = UDim2.new(0, 0, 0, 42)
            rgbHolder.BackgroundTransparency = 1
            local rgbLay = Instance.new("UIListLayout", rgbHolder)
            rgbLay.FillDirection = Enum.FillDirection.Horizontal
            rgbLay.Padding = UDim.new(0, 3)

            local function makeRGB(col)
                local ff = Instance.new("Frame", rgbHolder)
                ff.Size = UDim2.new(0, 31, 1, 0)
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
                Color3.fromRGB(255, 60, 60),   Color3.fromRGB(255, 140, 50),
                Color3.fromRGB(255, 220, 60),  Color3.fromRGB(120, 220, 90),
                Color3.fromRGB(60, 200, 220),  Color3.fromRGB(80, 120, 255),
                Color3.fromRGB(160, 90, 255),  Color3.fromRGB(255, 90, 200),
                Color3.fromRGB(255, 255, 255), Color3.fromRGB(80, 80, 90),
            }

            local cycling = false
            local cycleBtn

            local function stopCycle()
                if cycling then
                    cycling = false
                    if cycleBtn then
                        cycleBtn.Text = "🌈 Ciclar"
                        cycleBtn.TextColor3 = T.text
                    end
                end
            end

            local function updateAll(silent)
                local color = Color3.fromHSV(h, s, v)
                current = color
                pad.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                padMarker.Position = UDim2.new(s, 0, 1 - v, 0)
                hueMarker.Position = UDim2.new(0.5, 0, h, 0)
                previewDot.BackgroundColor3 = color
                hexBox.Text = U.ToHex(color)
                rIn.Text = tostring(math.floor(color.R * 255 + 0.5))
                gIn.Text = tostring(math.floor(color.G * 255 + 0.5))
                bIn.Text = tostring(math.floor(color.B * 255 + 0.5))
                if not silent then
                    if flag then
                        NINOMAX:SetFlag(flag, {
                            math.floor(color.R * 255),
                            math.floor(color.G * 255),
                            math.floor(color.B * 255),
                        })
                    end
                    pcall(cb, color)
                end
            end

            for _, pc in ipairs(presetColors) do
                local sw2 = Instance.new("TextButton", presetsRow)
                sw2.Size = UDim2.new(0, 18, 0, 18)
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
            actionRow.Position = UDim2.new(0, 10, 0, 10 + padSize + 32)
            actionRow.BackgroundTransparency = 1

            local function styleActionBtn(b)
                b.BackgroundColor3 = T.surfaceHi
                b.TextColor3 = T.text
                b.Font = Enum.Font.GothamMedium
                b.TextSize = 10
                b.AutoButtonColor = false
                newCorner(b, UDim.new(0, 4))
                newStroke(b, T.stroke, 1, 0.5)
                b.MouseEnter:Connect(function() U.Tw(b, { BackgroundColor3 = U.Mix(T.surfaceHi, T.accent, 0.35) }, 0.15) end)
                b.MouseLeave:Connect(function() U.Tw(b, { BackgroundColor3 = T.surfaceHi }, 0.15) end)
            end

            local randBtn = Instance.new("TextButton", actionRow)
            randBtn.Size = UDim2.new(0.33, -2, 1, 0)
            randBtn.Position = UDim2.new(0, 0, 0, 0)
            randBtn.Text = "🎲 Rand"
            styleActionBtn(randBtn)

            cycleBtn = Instance.new("TextButton", actionRow)
            cycleBtn.Size = UDim2.new(0.33, -2, 1, 0)
            cycleBtn.Position = UDim2.new(0.33, 2, 0, 0)
            cycleBtn.Text = "🌈 Ciclar"
            styleActionBtn(cycleBtn)

            local copyBtn = Instance.new("TextButton", actionRow)
            copyBtn.Size = UDim2.new(0.33, -2, 1, 0)
            copyBtn.Position = UDim2.new(0.66, 4, 0, 0)
            copyBtn.Text = "📋 HEX"
            styleActionBtn(copyBtn)

            -- Pad drag
            local padDrag = false
            local function padUpdateFromInput(i)
                local px = math.clamp(i.Position.X - pad.AbsolutePosition.X, 0, pad.AbsoluteSize.X)
                local py = math.clamp(i.Position.Y - pad.AbsolutePosition.Y, 0, pad.AbsoluteSize.Y)
                s = px / pad.AbsoluteSize.X
                v = 1 - (py / pad.AbsoluteSize.Y)
                updateAll()
            end
            pad.InputBegan:Connect(function(i)
                if U.IsPress(i) then padDrag = true; padUpdateFromInput(i) end
            end)
            maid:Give(UIS.InputChanged:Connect(function(i)
                if padDrag and U.IsMove(i) then padUpdateFromInput(i) end
            end))
            maid:Give(UIS.InputEnded:Connect(function(i) if U.IsPress(i) then padDrag = false end end))

            -- Hue drag
            local hueDrag = false
            local function hueUpdateFromInput(i)
                local py = math.clamp(i.Position.Y - hueBar.AbsolutePosition.Y, 0, hueBar.AbsoluteSize.Y)
                h = py / hueBar.AbsoluteSize.Y
                updateAll()
            end
            hueBar.InputBegan:Connect(function(i)
                if U.IsPress(i) then hueDrag = true; hueUpdateFromInput(i) end
            end)
            maid:Give(UIS.InputChanged:Connect(function(i)
                if hueDrag and U.IsMove(i) then hueUpdateFromInput(i) end
            end))
            maid:Give(UIS.InputEnded:Connect(function(i) if U.IsPress(i) then hueDrag = false end end))

            hexBox.FocusLost:Connect(function()
                local c = U.FromHex(hexBox.Text)
                if c then
                    h, s, v = Color3.toHSV(c)
                    updateAll()
                    return
                end
                hexBox.Text = U.ToHex(current)
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

            copyBtn.MouseButton1Click:Connect(function()
                U.Clip(U.ToHex(current))
                U.PlaySound("success")
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
                local targetH = expanded and (28 + 10 + padSize + 10 + 18 + 8 + 22 + 10) or 28
                U.Tw(frame, { Size = UDim2.new(1, 0, 0, targetH) }, 0.3, Enum.EasingStyle.Back)
                body.Size = UDim2.new(1, 0, 0, expanded and (targetH - 28) or 0)
            end
            header.MouseButton1Click:Connect(function() setExpanded(not expanded) end)

            onTheme(function()
                U.Tw(frame, { BackgroundColor3 = T.surface }, 0.35)
                U.Tw(fS, { Color = T.stroke }, 0.35)
                U.Tw(lbl, { TextColor3 = T.text }, 0.35)
                U.Tw(hexBox, { BackgroundColor3 = T.surfaceHi, TextColor3 = T.text }, 0.35)
                U.Tw(hexLbl, { TextColor3 = T.textDim }, 0.35)
            end)

            updateAll(true)

            return {
                Set = function(_, c) h, s, v = Color3.toHSV(c); updateAll() end,
                Get = function() return current end,
                Destroy = function() frame:Destroy() end,
            }
        end

        -- ADD PROGRESSBAR
        function Tab:AddProgressBar(cfg)
            cfg = cfg or {}
            local title = cfg.Title or cfg.Name or "Progresso"

            local page = getPage()
            local f = Instance.new("Frame", page)
            f.Size = UDim2.new(1, 0, 0, 38)
            f.BackgroundColor3 = T.surface
            f.BackgroundTransparency = 0.05
            f.BorderSizePixel = 0
            newCorner(f, UDim.new(0, 6))
            newStroke(f, T.stroke, 1, 0.7)

            local t = Instance.new("TextLabel", f)
            t.Size = UDim2.new(1, -70, 0, 12)
            t.Position = UDim2.new(0, 12, 0, 6)
            t.BackgroundTransparency = 1
            t.Text = title
            t.TextColor3 = T.text
            t.Font = Enum.Font.GothamMedium
            t.TextSize = 11
            t.TextXAlignment = Enum.TextXAlignment.Left

            local pct = Instance.new("TextLabel", f)
            pct.Size = UDim2.new(0, 50, 0, 12)
            pct.Position = UDim2.new(1, -60, 0, 6)
            pct.BackgroundTransparency = 1
            pct.Text = "0%"
            pct.TextColor3 = T.accentHi
            pct.Font = Enum.Font.GothamBold
            pct.TextSize = 11
            pct.TextXAlignment = Enum.TextXAlignment.Right

            local bar = Instance.new("Frame", f)
            bar.Size = UDim2.new(1, -24, 0, 6)
            bar.Position = UDim2.new(0, 12, 0, 26)
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
                U.Tw(f, { BackgroundColor3 = T.surface }, 0.35)
                U.Tw(t, { TextColor3 = T.text }, 0.35)
                U.Tw(pct, { TextColor3 = T.accentHi }, 0.35)
                U.Tw(bar, { BackgroundColor3 = T.stroke }, 0.35)
                U.Tw(fill, { BackgroundColor3 = T.accent }, 0.35)
                U.AnimateGradient(fg, fg.Color, ColorSequence.new(T.accentSoft, T.accentHi), 0.35)
            end)

            return {
                Set = function(_, value)
                    local p = math.clamp(value / 100, 0, 1)
                    U.Tw(fill, { Size = UDim2.new(p, 0, 1, 0) }, 0.35, Enum.EasingStyle.Quart)
                    pct.Text = string.format("%d%%", math.floor(p * 100 + 0.5))
                end,
                Destroy = function() f:Destroy() end,
            }
        end

        -- ADD STATS CARDS
        function Tab:AddStatsCards(stats)
            stats = stats or {}
            local page = getPage()
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(1, 0, 0, 60)
            container.BackgroundTransparency = 1
            local grid = Instance.new("UIGridLayout", container)
            grid.CellSize = UDim2.new(0, 90, 0, 56)
            grid.CellPadding = UDim2.new(0, 6, 0, 6)
            grid.SortOrder = Enum.SortOrder.LayoutOrder

            local cards = {}
            for i, stat in ipairs(stats) do
                local card = Instance.new("Frame", container)
                card.BackgroundColor3 = T.surface
                card.BackgroundTransparency = 0.05
                card.BorderSizePixel = 0
                card.LayoutOrder = i
                newCorner(card, UDim.new(0, 6))
                local cs = newStroke(card, T.stroke, 1, 0.6)

                local iconL = Instance.new("ImageLabel", card)
                iconL.Size = UDim2.new(0, 14, 0, 14)
                iconL.Position = UDim2.new(0, 8, 0, 6)
                iconL.BackgroundTransparency = 1
                iconL.Image = U.Icon(stat.Icon) or NINOMAX.Icons.activity
                iconL.ImageColor3 = T.accentHi

                local titleL = Instance.new("TextLabel", card)
                titleL.BackgroundTransparency = 1
                titleL.Text = stat.Title or "Stat"
                titleL.TextColor3 = T.textDim
                titleL.Font = Enum.Font.Gotham
                titleL.TextSize = 9
                titleL.Position = UDim2.new(0, 8, 0, 22)
                titleL.Size = UDim2.new(1, -16, 0, 10)
                titleL.TextXAlignment = Enum.TextXAlignment.Left
                titleL.TextTruncate = Enum.TextTruncate.AtEnd

                local valL = Instance.new("TextLabel", card)
                valL.BackgroundTransparency = 1
                valL.Text = stat.Value or "0"
                valL.TextColor3 = T.text
                valL.Font = Enum.Font.GothamBold
                valL.TextSize = 14
                valL.Position = UDim2.new(0, 8, 0, 32)
                valL.Size = UDim2.new(1, -16, 0, 18)
                valL.TextXAlignment = Enum.TextXAlignment.Left

                onTheme(function()
                    U.Tw(card, { BackgroundColor3 = T.surface }, 0.35)
                    U.Tw(cs, { Color = T.stroke }, 0.35)
                    U.Tw(titleL, { TextColor3 = T.textDim }, 0.35)
                    U.Tw(valL, { TextColor3 = T.text }, 0.35)
                    U.Tw(iconL, { ImageColor3 = T.accentHi }, 0.35)
                end)

                cards[i] = { Set = function(_, v) valL.Text = tostring(v) end, Instance = card }
            end

            return {
                SetValue = function(_, idx, v) if cards[idx] then cards[idx]:Set(v) end end,
                Cards = cards,
                Destroy = function() container:Destroy() end,
            }
        end

        -- ADD COLLAPSIBLE GROUP
        function Tab:AddGroup(cfg)
            cfg = cfg or {}
            local title = cfg.Title or "Grupo"
            local page = getPage()
            local holder = Instance.new("Frame", page)
            holder.Size = UDim2.new(1, 0, 0, 30)
            holder.BackgroundColor3 = T.surface
            holder.BackgroundTransparency = 0.15
            holder.BorderSizePixel = 0
            holder.ClipsDescendants = true
            newCorner(holder, UDim.new(0, 6))
            local hs = newStroke(holder, T.stroke, 1, 0.7)

            local hdr = Instance.new("TextButton", holder)
            hdr.Size = UDim2.new(1, 0, 0, 30)
            hdr.BackgroundTransparency = 1
            hdr.Text = ""

            local arrow = Instance.new("TextLabel", hdr)
            arrow.BackgroundTransparency = 1
            arrow.Text = "▶"
            arrow.TextColor3 = T.accentHi
            arrow.Font = Enum.Font.GothamBold
            arrow.TextSize = 10
            arrow.Position = UDim2.new(0, 8, 0, 0)
            arrow.Size = UDim2.new(0, 14, 1, 0)

            local tl = Instance.new("TextLabel", hdr)
            tl.BackgroundTransparency = 1
            tl.Text = title
            tl.TextColor3 = T.text
            tl.Font = Enum.Font.GothamBold
            tl.TextSize = 11
            tl.TextXAlignment = Enum.TextXAlignment.Left
            tl.Position = UDim2.new(0, 26, 0, 0)
            tl.Size = UDim2.new(1, -34, 1, 0)

            local content = Instance.new("Frame", holder)
            content.Size = UDim2.new(1, -16, 0, 0)
            content.Position = UDim2.new(0, 8, 0, 34)
            content.BackgroundTransparency = 1
            content.AutomaticSize = Enum.AutomaticSize.Y
            local cLay = Instance.new("UIListLayout", content)
            cLay.Padding = UDim.new(0, 5)
            cLay.SortOrder = Enum.SortOrder.LayoutOrder

            local expanded = false
            local function setExpanded(v)
                expanded = v
                arrow.Text = expanded and "▼" or "▶"
                local h = content.AbsoluteSize.Y
                U.Tw(holder, { Size = UDim2.new(1, 0, 0, expanded and (h + 42) or 30) }, 0.3, Enum.EasingStyle.Back)
            end
            hdr.MouseButton1Click:Connect(function() setExpanded(not expanded) end)

            onTheme(function()
                U.Tw(holder, { BackgroundColor3 = T.surface }, 0.35)
                U.Tw(hs, { Color = T.stroke }, 0.35)
                U.Tw(tl, { TextColor3 = T.text }, 0.35)
                U.Tw(arrow, { TextColor3 = T.accentHi }, 0.35)
            end)

            return {
                Content = content,
                SetExpanded = setExpanded,
                Destroy = function() holder:Destroy() end,
            }
        end

        -- ADD THEMEBOXES
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
                { name = "Ice",       accent = Color3.fromRGB(120, 210, 255) },
            }

            local page = getPage()
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(1, 0, 0, 0)
            container.BackgroundTransparency = 1
            container.AutomaticSize = Enum.AutomaticSize.Y

            local grid = Instance.new("Frame", container)
            grid.Size = UDim2.new(1, 0, 0, 0)
            grid.BackgroundTransparency = 1
            grid.AutomaticSize = Enum.AutomaticSize.Y
            local gridLay = Instance.new("UIGridLayout", grid)
            gridLay.CellSize = UDim2.new(0, 66, 0, 26)
            gridLay.CellPadding = UDim2.new(0, 5, 0, 5)
            gridLay.SortOrder = Enum.SortOrder.LayoutOrder

            local lastSelected = nil
            for _, t in ipairs(THEMES) do
                local card = Instance.new("TextButton", grid)
                card.BackgroundColor3 = T.surface
                card.Text = ""
                card.AutoButtonColor = false
                newCorner(card, UDim.new(0, 5))
                local cs = newStroke(card, T.stroke, 1, 0.6)
                local cg = Instance.new("UIGradient", card)
                cg.Rotation = 135
                cg.Color = ColorSequence.new(t.accent, U.Mix(t.accent, Color3.new(0,0,0), 0.7))

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
                    U.Tw(card, { Size = UDim2.new(0, 70, 0, 28) }, 0.2, Enum.EasingStyle.Back)
                    U.Tw(cs, { Color = t.accent, Transparency = 0 }, 0.2)
                end)
                card.MouseLeave:Connect(function()
                    if lastSelected ~= card then
                        U.Tw(card, { Size = UDim2.new(0, 66, 0, 26) }, 0.2, Enum.EasingStyle.Back)
                        U.Tw(cs, { Color = T.stroke, Transparency = 0.6 }, 0.2)
                    end
                end)

                card.MouseButton1Click:Connect(function()
                    if NINOMAX.Themes[t.name] then
                        NINOMAX.CurrentTheme = t.name
                        broadcastTheme(NINOMAX.Themes[t.name])
                    end
                    if lastSelected and lastSelected.Parent then
                        U.Tw(lastSelected, { Size = UDim2.new(0, 66, 0, 26) }, 0.3, Enum.EasingStyle.Back)
                    end
                    U.Tw(card, { Size = UDim2.new(0, 70, 0, 28) }, 0.3, Enum.EasingStyle.Back)
                    lastSelected = card
                    Window:Notify({ Title = "TEMA APLICADO", Text = t.name .. " aplicado!", Type = "success", Duration = 2 })
                end)
            end

            return container
        end

        -- ADD INFOBOX
        function Tab:AddInfoBox(title, infoList)
            local page = getPage()
            local box = Instance.new("Frame", page)
            box.BackgroundColor3 = T.surface
            box.BackgroundTransparency = 0.05
            box.BorderSizePixel = 0
            box.AutomaticSize = Enum.AutomaticSize.Y
            box.ClipsDescendants = true
            box.Size = UDim2.new(1, 0, 0, 0)
            newCorner(box, UDim.new(0, 6))
            local bx = newStroke(box, T.accentSoft, 1.2, 0.4)

            local pad = Instance.new("UIPadding", box)
            pad.PaddingTop = UDim.new(0, 8); pad.PaddingBottom = UDim.new(0, 10)
            pad.PaddingLeft = UDim.new(0, 12); pad.PaddingRight = UDim.new(0, 12)

            local lay = Instance.new("UIListLayout", box)
            lay.SortOrder = Enum.SortOrder.LayoutOrder
            lay.Padding = UDim.new(0, 5)

            local tl = Instance.new("TextLabel", box)
            tl.Text = string.upper(title or "INFORMAÇÃO")
            tl.Font = Enum.Font.GothamBold
            tl.TextSize = 11
            tl.TextColor3 = T.text
            tl.BackgroundTransparency = 1
            tl.Size = UDim2.new(1, 0, 0, 16)
            tl.TextXAlignment = Enum.TextXAlignment.Left
            tl.LayoutOrder = 0

            for i, text in ipairs(infoList or {}) do
                local item = Instance.new("Frame", box)
                item.BackgroundColor3 = T.surfaceHi
                item.BackgroundTransparency = 0.3
                item.BorderSizePixel = 0
                item.AutomaticSize = Enum.AutomaticSize.Y
                item.Size = UDim2.new(1, 0, 0, 0)
                item.ClipsDescendants = true
                item.LayoutOrder = i
                newCorner(item, UDim.new(0, 4))
                newStroke(item, T.stroke, 1, 0.6)

                local num = Instance.new("TextLabel", item)
                num.Text = tostring(i) .. "."
                num.Font = Enum.Font.GothamBold
                num.TextSize = 10
                num.TextColor3 = T.accentHi
                num.BackgroundTransparency = 1
                num.Size = UDim2.new(0, 22, 1, 0)
                num.Position = UDim2.new(0, 8, 0, 4)
                num.TextXAlignment = Enum.TextXAlignment.Left
                num.TextYAlignment = Enum.TextYAlignment.Top

                local dl = Instance.new("TextLabel", item)
                dl.Text = text
                dl.Font = Enum.Font.Gotham
                dl.TextSize = 10
                dl.TextColor3 = T.text
                dl.BackgroundTransparency = 1
                dl.Position = UDim2.new(0, 30, 0, 4)
                dl.Size = UDim2.new(1, -36, 0, 0)
                dl.AutomaticSize = Enum.AutomaticSize.Y
                dl.TextWrapped = true
                dl.TextXAlignment = Enum.TextXAlignment.Left
                dl.TextYAlignment = Enum.TextYAlignment.Top
            end

            onTheme(function()
                U.Tw(box, { BackgroundColor3 = T.surface }, 0.35)
                U.Tw(bx, { Color = T.accentSoft }, 0.35)
                U.Tw(tl, { TextColor3 = T.text }, 0.35)
            end)

            return { MainFrame = box, TitleLabel = tl, Destroy = function() box:Destroy() end }
        end

        -- ADD PROMOBOX (imageId prefix corrigido)
        function Tab:AddPromoBox(title, description, imageId, link, channelName)
            local page = getPage()
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
            ic.Position = UDim2.new(0, 12, 0, 14)
            ic.Image = tostring(imageId):find("rbxasset") and imageId or ("rbxassetid://" .. tostring(imageId))
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
            ttl.Position = UDim2.new(0, 82, 0, 10)
            ttl.Size = UDim2.new(1, -94, 0, 16)
            ttl.TextXAlignment = Enum.TextXAlignment.Left

            local dl = Instance.new("TextLabel", box)
            dl.Text = description or ""
            dl.Font = Enum.Font.Gotham
            dl.TextSize = 9
            dl.TextColor3 = T.textDim
            dl.BackgroundTransparency = 1
            dl.Position = UDim2.new(0, 82, 0, 26)
            dl.Size = UDim2.new(1, -94, 0, 22)
            dl.TextWrapped = true
            dl.TextXAlignment = Enum.TextXAlignment.Left
            dl.TextYAlignment = Enum.TextYAlignment.Top

            local chBox = Instance.new("TextButton", box)
            chBox.Size = UDim2.new(1, -94, 0, 20)
            chBox.Position = UDim2.new(0, 82, 0, 58)
            chBox.BackgroundColor3 = T.surfaceHi
            chBox.Text = (channelName or "CANAL") .. "  ·  COPIAR LINK"
            chBox.TextColor3 = T.text
            chBox.Font = Enum.Font.GothamBold
            chBox.TextSize = 9
            chBox.AutoButtonColor = false
            newCorner(chBox, UDim.new(0, 4))
            newStroke(chBox, T.accent, 1, 0.4)
            attachRipple(chBox, chBox)

            local fb = Instance.new("Frame", chBox)
            fb.Size = UDim2.new(0, 0, 1, 0)
            fb.BackgroundColor3 = T.accentHi
            fb.BorderSizePixel = 0
            fb.ZIndex = 1
            newCorner(fb, UDim.new(0, 4))

            chBox.MouseButton1Click:Connect(function()
                U.Clip(link or "")
                fb.Size = UDim2.new(0, 0, 1, 0)
                U.Tw(fb, { Size = UDim2.new(1, 0, 1, 0) }, 0.4, Enum.EasingStyle.Sine)
                Window:Notify({ Title = "COPIADO!", Text = "Link na área de transferência", Type = "success", Duration = 2 })
            end)

            onTheme(function()
                U.Tw(box, { BackgroundColor3 = T.surface }, 0.35)
                U.Tw(bx, { Color = T.accentSoft }, 0.35)
                U.Tw(ttl, { TextColor3 = T.text }, 0.35)
                U.Tw(dl, { TextColor3 = T.textDim }, 0.35)
                U.Tw(chBox, { BackgroundColor3 = T.surfaceHi, TextColor3 = T.text }, 0.35)
            end)

            return { MainFrame = box, CopyButton = chBox, Destroy = function() box:Destroy() end }
        end

        windowTabs[tabName] = Tab

        -- Auto-seleciona primeira tab
        if not selectedTab then
            task.defer(function() switchTab(tabName) end)
        end

        return Tab
    end

    -- ── API PÚBLICA (Window:Create*) ──────────────────────────────────
    local function _normalize(cfg)
        cfg = cfg or {}
        if type(cfg) == "string" then cfg = { Text = cfg } end
        if cfg.Text and not cfg.Title then cfg.Title = cfg.Text end
        if cfg.State ~= nil and cfg.Default == nil then cfg.Default = cfg.State end
        if cfg.PlaceholderText and not cfg.Placeholder then cfg.Placeholder = cfg.PlaceholderText end
        if cfg.Description and not cfg.Desc then cfg.Desc = cfg.Description end
        return cfg
    end

    function Window:CreateToggle(tabName, cfg) local t = windowTabs[tabName]; if t then return t:AddToggle(_normalize(cfg)) end end
    function Window:CreateCheckbox(tabName, cfg) local t = windowTabs[tabName]; if t then return t:AddCheckbox(_normalize(cfg)) end end
    function Window:CreateSwitch(tabName, cfg) local t = windowTabs[tabName]; if t then return t:AddSwitch(_normalize(cfg)) end end
    function Window:CreateSlider(tabName, cfg) local t = windowTabs[tabName]; if t then return t:AddSlider(_normalize(cfg)) end end
    function Window:CreateDropdown(tabName, cfg) local t = windowTabs[tabName]; if t then return t:AddDropdown(_normalize(cfg)) end end
    function Window:CreateKeybind(tabName, cfg) local t = windowTabs[tabName]; if t then return t:AddKeybind(_normalize(cfg)) end end
    function Window:CreateColorPicker(tabName, cfg) local t = windowTabs[tabName]; if t then return t:AddColorPicker(_normalize(cfg)) end end
    function Window:CreateParagraph(tabName, cfg) local t = windowTabs[tabName]; if t then return t:AddParagraph(_normalize(cfg)) end end
    function Window:CreateProgressBar(tabName, cfg) local t = windowTabs[tabName]; if t then return t:AddProgressBar(_normalize(cfg)) end end
    function Window:CreateButton(tabName, title, cb, desc) local t = windowTabs[tabName]; if t then return t:AddButton({ Title = title, Desc = desc, Callback = cb }) end end
    function Window:CreateLabel(tabName, text) local t = windowTabs[tabName]; if t then return t:AddLabel(text) end end
    function Window:CreateSection(tabName, s) local t = windowTabs[tabName]; if t then return t:AddSection(s) end end
    function Window:CreateLine(tabName, color) local t = windowTabs[tabName]; if t then return t:AddLine(color) end end
    function Window:CreateTextBox(tabName, ph, cb) local t = windowTabs[tabName]; if t then return t:AddTextBox({ Title = ph, Placeholder = ph, Callback = cb }) end end
    function Window:CreateInfoBox(tabName, title, list) local t = windowTabs[tabName]; if t then return t:AddInfoBox(title, list) end end
    function Window:CreatePromoBox(tabName, title, desc, img, link, ch) local t = windowTabs[tabName]; if t then return t:AddPromoBox(title, desc, img, link, ch) end end
    function Window:CreateThemeBoxes(tabName) local t = windowTabs[tabName]; if t then return t:AddThemeBoxes() end end
    function Window:CreateStatsCards(tabName, stats) local t = windowTabs[tabName]; if t then return t:AddStatsCards(stats) end end
    function Window:CreateGroup(tabName, cfg) local t = windowTabs[tabName]; if t then return t:AddGroup(cfg) end end

    -- ── Métodos do Window ─────────────────────────────────────────────
    function Window:SetTheme(name)
        if NINOMAX.Themes[name] then
            NINOMAX.CurrentTheme = name
            broadcastTheme(NINOMAX.Themes[name])
        end
    end
    function Window:GetTheme() return NINOMAX.CurrentTheme end
    function Window:SetSubtitle(text)
        subtitle.Text = tostring(text)
    end
    function Window:SetTitle(text)
        text = tostring(text)
        local mid = math.max(1, math.floor(#text / 2))
        titleNino.Text = text:sub(1, mid)
        titleMax.Text = text:sub(mid + 1)
    end
    function Window:Hide() doHide() end
    function Window:Show() doShow() end
    function Window:Toggle() if isHidden then doShow() else doHide() end end

    -- ── Botão de close com Dialog ─────────────────────────────────────
    btnClose.MouseButton1Click:Connect(function()
        Window:Dialog({
            Title = "Fechar NINOMAX?",
            Text = "Deseja realmente fechar a interface?",
            Options = {
                { "Fechar", function()
                    U.Tw(mainFrame, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                    U.Tw(shadowImg, { ImageTransparency = 1 }, 0.25)
                    task.delay(0.3, function() gui:Destroy() end)
                end },
                { "Cancelar", function() end },
            }
        })
    end)

    return Window
end

-- ═══════════════════════════════════════════════════════════════════════
-- 11 · COMMAND PALETTE (Ctrl+K)
-- ═══════════════════════════════════════════════════════════════════════
do
    local paletteSg = Instance.new("ScreenGui")
    paletteSg.Name = "NINOMAX_Palette"
    paletteSg.ResetOnSpawn = false
    paletteSg.IgnoreGuiInset = true
    paletteSg.DisplayOrder = 999997
    paletteSg.Enabled = false
    U.Mount(paletteSg)

    local backdrop = Instance.new("Frame", paletteSg)
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
    backdrop.BackgroundTransparency = 0.55
    backdrop.BorderSizePixel = 0

    local box = Instance.new("Frame", backdrop)
    box.Size = UDim2.new(0, 460, 0, 60)
    box.Position = UDim2.new(0.5, 0, 0.3, 0)
    box.AnchorPoint = Vector2.new(0.5, 0)
    box.BackgroundColor3 = NINOMAX.Themes[NINOMAX.CurrentTheme].bg
    box.BorderSizePixel = 0
    newCorner(box, UDim.new(0, 10))
    newStroke(box, NINOMAX.Themes[NINOMAX.CurrentTheme].stroke, 1.2, 0.3)

    local inp = Instance.new("TextBox", box)
    inp.Size = UDim2.new(1, -20, 0, 40)
    inp.Position = UDim2.new(0, 10, 0, 10)
    inp.BackgroundColor3 = NINOMAX.Themes[NINOMAX.CurrentTheme].surfaceHi
    inp.BorderSizePixel = 0
    inp.PlaceholderText = "🔍 Buscar comandos / abas..."
    inp.PlaceholderColor3 = NINOMAX.Themes[NINOMAX.CurrentTheme].textDim
    inp.TextColor3 = NINOMAX.Themes[NINOMAX.CurrentTheme].text
    inp.Font = Enum.Font.GothamMedium
    inp.TextSize = 13
    inp.TextXAlignment = Enum.TextXAlignment.Left
    inp.ClearTextOnFocus = false
    newCorner(inp, UDim.new(0, 6))
    newPad(inp, 0, 12, 12, 0)

    local results = Instance.new("ScrollingFrame", box)
    results.Size = UDim2.new(1, -20, 0, 0)
    results.Position = UDim2.new(0, 10, 0, 56)
    results.BackgroundTransparency = 1
    results.BorderSizePixel = 0
    results.CanvasSize = UDim2.new(0, 0, 0, 0)
    results.AutomaticCanvasSize = Enum.AutomaticSize.Y
    results.ScrollBarThickness = 2
    results.ScrollBarImageColor3 = NINOMAX.Themes[NINOMAX.CurrentTheme].accent
    local rLay = Instance.new("UIListLayout", results)
    rLay.Padding = UDim.new(0, 3)
    rLay.SortOrder = Enum.SortOrder.LayoutOrder

    local function clearResults()
        for _, c in ipairs(results:GetChildren()) do
            if c:IsA("GuiObject") then c:Destroy() end
        end
    end

    local function search(q)
        clearResults()
        q = string.lower(q or "")
        local count = 0
        for _, w in ipairs(NINOMAX.Windows) do
            for tabName in pairs(w._tabRegistry or {}) do
                if q == "" or string.find(string.lower(tabName), q, 1, true) then
                    count = count + 1
                    if count > 8 then break end
                    local b = Instance.new("TextButton", results)
                    b.Size = UDim2.new(1, 0, 0, 28)
                    b.BackgroundColor3 = NINOMAX.Themes[NINOMAX.CurrentTheme].surface
                    b.BackgroundTransparency = 0.2
                    b.Text = "  " .. tabName
                    b.TextColor3 = NINOMAX.Themes[NINOMAX.CurrentTheme].text
                    b.Font = Enum.Font.GothamMedium
                    b.TextSize = 11
                    b.TextXAlignment = Enum.TextXAlignment.Left
                    b.AutoButtonColor = false
                    newCorner(b, UDim.new(0, 5))
                    b.MouseButton1Click:Connect(function()
                        if w._switchTab then w._switchTab(tabName) end
                        paletteSg.Enabled = false
                    end)
                end
            end
        end
        local needed = math.min(count * 31 + 10, 260)
        box.Size = UDim2.new(0, 460, 0, 60 + needed)
        results.Size = UDim2.new(1, -20, 0, needed)
    end

    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.K and UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            paletteSg.Enabled = not paletteSg.Enabled
            if paletteSg.Enabled then
                inp.Text = ""
                search("")
                task.defer(function() inp:CaptureFocus() end)
            end
        end
        if input.KeyCode == Enum.KeyCode.Escape and paletteSg.Enabled then
            paletteSg.Enabled = false
        end
    end)

    inp:GetPropertyChangedSignal("Text"):Connect(function() search(inp.Text) end)
    backdrop.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 and i.Target == backdrop then
            paletteSg.Enabled = false
        end
    end)
end

-- Expõe registro de tabs pro palette
local function registerWindow(w)
    table.insert(NINOMAX.Windows, w)
end

-- ═══════════════════════════════════════════════════════════════════════
-- 12 · UNLOAD
-- ═══════════════════════════════════════════════════════════════════════
function NINOMAX.Unload()
    for _, w in ipairs(NINOMAX.Windows) do pcall(function() w:Destroy() end) end
    NINOMAX.Windows = {}
    pcall(function() NINOMAX.Events.Unloaded:Fire() end)
    pcall(function() if genv then genv.__NINOMAX = nil end end)
end

-- Registra no genv
if genv then genv.__NINOMAX = NINOMAX end

-- ═══════════════════════════════════════════════════════════════════════
-- 13 · SHORTCUTS EXTRAS
-- ═══════════════════════════════════════════════════════════════════════
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    -- Right Ctrl: libera mouse (Roblox faz nativo mas reforçamos)
    if input.KeyCode == Enum.KeyCode.RightControl then
        pcall(function() UIS.MouseBehavior = Enum.MouseBehavior.Default end)
    end
    -- F2: toggle watermark
    if input.KeyCode == Enum.KeyCode.F2 then
        NINOMAX.Settings.Watermark = not NINOMAX.Settings.Watermark
        Watermark.SetEnabled(NINOMAX.Settings.Watermark)
    end
end)

return NINOMAX
