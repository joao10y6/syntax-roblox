-- ============================================================
-- SYNTAX MENU v6.7
-- Hitbox Expander + ESP Visible + Lock + Kick + Binds
-- Dono: NICOINFERNALX (UserId: 9375423697)
-- ============================================================

-- ============================================================
-- DONO CONFIG
-- ============================================================
local DONO = {
    UserId    = 9375423697,
    KeyMestra = "SYNTAX-MASTER",
}

local DISCORD_LINK = "https://discord.gg/3fwtTtrqdV"

local TIPOS = {
    ["1D"]  = { prefixo = "SYN1D-", dias = 1,     nome = "1 Day"   },
    ["7D"]  = { prefixo = "SYN7D-", dias = 7,     nome = "7 Days"  },
    ["1M"]  = { prefixo = "SYN1M-", dias = 30,    nome = "1 Month" },
    ["LF"]  = { prefixo = "SYNLF-", dias = 99999, nome = "Lifetime"},
}

local ARQ_KEYS_GERADAS = "syntax_keys_geradas.txt"

-- ============================================================
-- KEY UTILS
-- ============================================================
local function gerarKey(tipo)
    local prefixo = TIPOS[tipo].prefixo
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local function bloco()
        local s = ""
        for i = 1, 4 do
            local idx = math.random(1, #chars)
            s = s .. chars:sub(idx, idx)
        end
        return s
    end
    return prefixo .. bloco() .. "-" .. bloco() .. "-" .. bloco() .. "-" .. bloco()
end

local function tipoDaKey(key)
    if not key then return nil end
    if key:sub(1, 6) == "SYN1D-" then return "1D" end
    if key:sub(1, 6) == "SYN7D-" then return "7D" end
    if key:sub(1, 6) == "SYN1M-" then return "1M" end
    if key:sub(1, 6) == "SYNLF-" then return "LF" end
    return nil
end

local function formatarTempo(segundos)
    if segundos >= 99999 * 86400 then return "LIFETIME ♾️" end
    if segundos <= 0 then return "EXPIRED" end
    local dias  = math.floor(segundos / 86400)
    local horas = math.floor((segundos % 86400) / 3600)
    local mins  = math.floor((segundos % 3600) / 60)
    local segs  = math.floor(segundos % 60)
    if dias > 0 then return dias .. "d " .. horas .. "h " .. mins .. "m"
    elseif horas > 0 then return horas .. "h " .. mins .. "m " .. segs .. "s"
    elseif mins > 0 then return mins .. "m " .. segs .. "s"
    else return segs .. "s" end
end

local function lerKeysGeradas()
    local lista = {}
    if not readfile or not isfile then return lista end
    local ok, conteudo = pcall(function()
        if isfile(ARQ_KEYS_GERADAS) then return readfile(ARQ_KEYS_GERADAS) end
    end)
    if ok and conteudo then
        for linha in conteudo:gmatch("[^\r\n]+") do
            local key, tipo, expira = linha:match("^([^|]+)|([^|]+)|([^|]+)$")
            if key and tipo and expira then
                lista[key] = { tipo = tipo, expira = tonumber(expira) or 0 }
            end
        end
    end
    return lista
end

local function salvarKeysGeradas(lista)
    if not writefile then return end
    local linhas = {}
    for key, dados in pairs(lista) do
        table.insert(linhas, key .. "|" .. dados.tipo .. "|" .. tostring(dados.expira))
    end
    pcall(function() writefile(ARQ_KEYS_GERADAS, table.concat(linhas, "\n")) end)
end

local function validarKeyInterna(key, userId)
    if not key or #key < 10 then return false, "Key too short.", nil end
    if key == DONO.KeyMestra then return true, "Owner", 999999999 end
    local tipo = tipoDaKey(key)
    if not tipo then return false, "Invalid key format.", nil end
    local keysGeradas = lerKeysGeradas()
    if not keysGeradas[key] then return false, "Unknown key.", nil end
    if tipo == "LF" then return true, "Lifetime", 999999999 end
    local chaveArquivo = "syntax_key_" .. tostring(userId) .. ".txt"
    if readfile and isfile and isfile(chaveArquivo) then
        local ok, conteudo = pcall(function() return readfile(chaveArquivo) end)
        if ok and conteudo then
            local keySalva, expiraStr = conteudo:match("^([^|]+)|(%d+)$")
            if keySalva == key then
                local expira = tonumber(expiraStr)
                if expira and os.time() < expira then
                    return true, formatarTempo(expira - os.time()), expira
                else
                    return false, "Key expired.", nil
                end
            end
        end
    end
    local expira = os.time() + (TIPOS[tipo].dias * 86400)
    if writefile then
        pcall(function() writefile(chaveArquivo, key .. "|" .. tostring(expira)) end)
    end
    return true, formatarTempo(expira - os.time()), expira
end

local function tentarLoginAutomatico(userId)
    if not readfile or not isfile then return nil end
    if userId == DONO.UserId then return DONO.KeyMestra, 999999999 end
    local chaveArquivo = "syntax_key_" .. tostring(userId) .. ".txt"
    if not isfile(chaveArquivo) then return nil end
    local ok, conteudo = pcall(function() return readfile(chaveArquivo) end)
    if not ok or not conteudo then return nil end
    local keySalva, expiraStr = conteudo:match("^([^|]+)|(%d+)$")
    if not keySalva then return nil end
    local expira = tonumber(expiraStr)
    if not expira then return nil end
    if tipoDaKey(keySalva) == "LF" then return keySalva, 999999999 end
    if os.time() < expira then return keySalva, expira end
    return nil
end

-- ============================================================
-- SERVICES
-- ============================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService       = game:GetService("GuiService")
local LocalPlayer      = Players.LocalPlayer
local Lighting         = game:GetService("Lighting")

local ehDono = (LocalPlayer.UserId == DONO.UserId)

-- ============================================================
-- COLORS
-- ============================================================
local C = {
    Fundo       = Color3.fromRGB(18, 16, 22),
    FundoTopo   = Color3.fromRGB(24, 22, 30),
    FundoPainel = Color3.fromRGB(28, 26, 34),
    AbaAtiva    = Color3.fromRGB(140, 90, 220),
    AbaAtivaTxt = Color3.fromRGB(255, 255, 255),
    AbaInativa  = Color3.fromRGB(130, 130, 140),
    Texto       = Color3.fromRGB(230, 230, 235),
    TextoFraco  = Color3.fromRGB(160, 160, 170),
    Secao       = Color3.fromRGB(160, 110, 240),
    Check       = Color3.fromRGB(140, 90, 220),
    CheckOff    = Color3.fromRGB(55, 52, 65),
    SliderFundo = Color3.fromRGB(45, 42, 55),
    SliderFill  = Color3.fromRGB(140, 90, 220),
    Neve        = Color3.fromRGB(230, 220, 255),
    DropBg      = Color3.fromRGB(40, 36, 50),
    Botao       = Color3.fromRGB(40, 38, 48),
    BotaoHover  = Color3.fromRGB(55, 52, 68),
    BotaoVerde  = Color3.fromRGB(60, 130, 80),
    BotaoVerm   = Color3.fromRGB(140, 60, 60),
    Acao        = Color3.fromRGB(180, 130, 255),
    Dourado     = Color3.fromRGB(220, 180, 80),
    Laranja     = Color3.fromRGB(255, 180, 60),
    Vermelho    = Color3.fromRGB(255, 100, 100),
    Verde       = Color3.fromRGB(60, 220, 80),
    Discord     = Color3.fromRGB(88, 101, 242),
    DiscordHov  = Color3.fromRGB(110, 122, 255),
    None        = Color3.fromRGB(60, 60, 70),
}

-- ============================================================
-- SCREEN GUI
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SyntaxMenu"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 100
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================================
-- CONTROLE DE MOUSE CENTRALIZADO (A CORREÇÃO PRINCIPAL)
-- Toda e qualquer mudança de MouseBehavior passa por aqui.
-- Se detectarmos que o jogo abriu inventário/chat/menu, NÃO mexe.
-- ============================================================
local MouseCtrl = {
    modo = "auto",  -- "auto" (Camlock) | "livre" (Mouse Free)
    bloqueioAte = 0, -- timestamp até quando NÃO mexer no mouse (após Tab, chat, etc)
}

-- Detecta se o Roblox está com alguma UI nativa que exige o mouse
local function jogoQuerMouse()
    -- 1) Menu nativo (ESC, inventário do Roblox)
    local ok, menuAberto = pcall(function() return GuiService.MenuIsOpen end)
    if ok and menuAberto then return true end

    -- 2) Chat (novo TextChatService)
    local ok2, chatAtivo = pcall(function()
        local tcs = game:GetService("TextChatService")
        local chatWindow = tcs.ChatWindowConfiguration
        if chatWindow and chatWindow.Enabled == false then return false end
        -- verifica se o TextBox do chat está focado
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            local chatGui = pg:FindFirstChild("Chat")
            if chatGui then
                for _, d in ipairs(chatGui:GetDescendants()) do
                    if d:IsA("TextBox") and d:IsFocused() then return true end
                end
            end
        end
        return false
    end)
    if ok2 and chatAtivo then return true end

    -- 3) O próprio Roblox já liberou o mouse (Tab/inventário clássico)
    --    Se o engine está em Default e não fomos nós que colocamos, respeita.
    if UserInputService.MouseBehavior == Enum.MouseBehavior.Default then
        return true
    end

    return false
end

-- Aplica o estado de mouse desejado, respeitando o jogo
local function aplicarMouse(forcar)
    local agora = tick()

    -- Se estamos em "janela de bloqueio" (acabamos de ver Tab/chat), não toca
    if not forcar and agora < MouseCtrl.bloqueioAte then
        return
    end

    -- Se o jogo quer o mouse livre, não briga
    if not forcar and jogoQuerMouse() then
        return
    end

    if MouseCtrl.modo == "livre" then
        pcall(function()
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true
        end)
    else
        pcall(function()
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            UserInputService.MouseIconEnabled = false
        end)
    end
end

-- Bloqueia intervenção do script por X segundos
local function bloquearMouse(segundos)
    MouseCtrl.bloqueioAte = math.max(MouseCtrl.bloqueioAte, tick() + (segundos or 1.5))
end

-- Libera o mouse imediatamente e bloqueia intervenção
local function liberarMouseAgora(segundos)
    bloquearMouse(segundos or 1.5)
    pcall(function()
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
    end)
end

-- Setter usado pelos botões/sliders
local function setMouseModo(modo)
    MouseCtrl.modo = modo
    if modo == "livre" then
        liberarMouseAgora(0.5)
    end
end

-- Inicializa como "livre" na tela de key
setMouseModo("livre")

-- ============================================================
-- KEY SCREEN
-- ============================================================
local keyGui = Instance.new("Frame")
keyGui.Size = UDim2.new(0, 400, 0, 340)
keyGui.Position = UDim2.new(0.5, -200, 0.5, -170)
keyGui.BackgroundColor3 = C.Fundo
keyGui.BorderSizePixel = 0
keyGui.Active = true
keyGui.Visible = true
keyGui.ZIndex = 200
keyGui.Parent = screenGui

local kgCorner = Instance.new("UICorner")
kgCorner.CornerRadius = UDim.new(0, 8)
kgCorner.Parent = keyGui

local kgStroke = Instance.new("UIStroke")
kgStroke.Color = Color3.fromRGB(140, 90, 220)
kgStroke.Thickness = 2
kgStroke.Parent = keyGui

local kgTitle = Instance.new("TextLabel")
kgTitle.Size = UDim2.new(1, 0, 0, 40)
kgTitle.Position = UDim2.new(0, 0, 0, 12)
kgTitle.BackgroundTransparency = 1
kgTitle.Text = "SYNTAX MENU"
kgTitle.TextColor3 = Color3.fromRGB(180, 130, 255)
kgTitle.Font = Enum.Font.GothamBold
kgTitle.TextSize = 24
kgTitle.ZIndex = 201
kgTitle.Parent = keyGui

local kgSub = Instance.new("TextLabel")
kgSub.Size = UDim2.new(1, 0, 0, 18)
kgSub.Position = UDim2.new(0, 0, 0, 50)
kgSub.BackgroundTransparency = 1
kgSub.Text = "Enter your key to continue"
kgSub.TextColor3 = C.TextoFraco
kgSub.Font = Enum.Font.Gotham
kgSub.TextSize = 12
kgSub.ZIndex = 201
kgSub.Parent = keyGui

local kgInput = Instance.new("TextBox")
kgInput.Size = UDim2.new(1, -40, 0, 40)
kgInput.Position = UDim2.new(0, 20, 0, 78)
kgInput.BackgroundColor3 = C.DropBg
kgInput.BorderSizePixel = 0
kgInput.Text = ""
kgInput.PlaceholderText = "SYN1D-XXXX-XXXX-XXXX-XXXX"
kgInput.PlaceholderColor3 = C.TextoFraco
kgInput.TextColor3 = C.Texto
kgInput.Font = Enum.Font.Gotham
kgInput.TextSize = 14
kgInput.ClearTextOnFocus = false
kgInput.ZIndex = 201
kgInput.Parent = keyGui

local kgInputCorner = Instance.new("UICorner")
kgInputCorner.CornerRadius = UDim.new(0, 6)
kgInputCorner.Parent = kgInput

local kgBtn = Instance.new("TextButton")
kgBtn.Size = UDim2.new(1, -40, 0, 40)
kgBtn.Position = UDim2.new(0, 20, 0, 128)
kgBtn.BackgroundColor3 = Color3.fromRGB(140, 90, 220)
kgBtn.Text = "VALIDATE KEY"
kgBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
kgBtn.Font = Enum.Font.GothamBold
kgBtn.TextSize = 14
kgBtn.BorderSizePixel = 0
kgBtn.AutoButtonColor = false
kgBtn.ZIndex = 201
kgBtn.Parent = keyGui

local kgBtnCorner = Instance.new("UICorner")
kgBtnCorner.CornerRadius = UDim.new(0, 6)
kgBtnCorner.Parent = kgBtn

local kgDiscord = Instance.new("TextButton")
kgDiscord.Size = UDim2.new(1, -40, 0, 40)
kgDiscord.Position = UDim2.new(0, 20, 0, 178)
kgDiscord.BackgroundColor3 = C.Discord
kgDiscord.Text = "💬  Join Discord to get a key"
kgDiscord.TextColor3 = Color3.fromRGB(255, 255, 255)
kgDiscord.Font = Enum.Font.GothamBold
kgDiscord.TextSize = 13
kgDiscord.BorderSizePixel = 0
kgDiscord.AutoButtonColor = false
kgDiscord.ZIndex = 201
kgDiscord.Parent = keyGui

local kgDiscordCorner = Instance.new("UICorner")
kgDiscordCorner.CornerRadius = UDim.new(0, 6)
kgDiscordCorner.Parent = kgDiscord

kgDiscord.MouseEnter:Connect(function() kgDiscord.BackgroundColor3 = C.DiscordHov end)
kgDiscord.MouseLeave:Connect(function() kgDiscord.BackgroundColor3 = C.Discord end)

local kgDiscordStatus = Instance.new("TextLabel")
kgDiscordStatus.Size = UDim2.new(1, -20, 0, 14)
kgDiscordStatus.Position = UDim2.new(0, 10, 0, 220)
kgDiscordStatus.BackgroundTransparency = 1
kgDiscordStatus.Text = ""
kgDiscordStatus.TextColor3 = Color3.fromRGB(120, 220, 120)
kgDiscordStatus.Font = Enum.Font.Gotham
kgDiscordStatus.TextSize = 10
kgDiscordStatus.ZIndex = 201
kgDiscordStatus.Parent = keyGui

kgDiscord.MouseButton1Click:Connect(function()
    local copiou = false
    if setclipboard then
        pcall(function() setclipboard(DISCORD_LINK); copiou = true end)
    end
    if copiou then
        kgDiscordStatus.Text = "✅ Link copied! Paste in browser (Ctrl+V)"
    else
        kgDiscordStatus.Text = "📋 Link: " .. DISCORD_LINK
    end
    task.wait(5)
    kgDiscordStatus.Text = ""
end)

local kgStatus = Instance.new("TextLabel")
kgStatus.Size = UDim2.new(1, -20, 0, 45)
kgStatus.Position = UDim2.new(0, 10, 0, 240)
kgStatus.BackgroundTransparency = 1
kgStatus.Text = ""
kgStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
kgStatus.Font = Enum.Font.Gotham
kgStatus.TextSize = 11
kgStatus.TextWrapped = true
kgStatus.TextYAlignment = Enum.TextYAlignment.Top
kgStatus.ZIndex = 201
kgStatus.Parent = keyGui

-- ============================================================
-- MAIN MENU
-- ============================================================
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 660, 0, 480)
main.Position = UDim2.new(0.5, -330, 0.5, -240)
main.BackgroundColor3 = C.Fundo
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Visible = false
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 6)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(60, 55, 75)
mainStroke.Thickness = 1
mainStroke.Parent = main

-- SNOW
local snowLayer = Instance.new("Frame")
snowLayer.Size = UDim2.new(1, 0, 1, 0)
snowLayer.BackgroundTransparency = 1
snowLayer.ClipsDescendants = true
snowLayer.ZIndex = 1
snowLayer.Parent = main

local flocos = {}
for i = 1, 60 do
    local floco = Instance.new("Frame")
    local tam = math.random(1, 2)
    floco.Size = UDim2.new(0, tam, 0, tam)
    floco.Position = UDim2.new(math.random(), 0, math.random() * -1, 0)
    floco.BackgroundColor3 = C.Neve
    floco.BackgroundTransparency = math.random(40, 75) / 100
    floco.BorderSizePixel = 0
    floco.ZIndex = 1
    floco.Parent = snowLayer
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = floco
    table.insert(flocos, {
        obj = floco,
        velY = math.random(15, 35) / 1000,
        velX = math.random(-10, 10) / 1000,
        alpha = math.random() * math.pi * 2,
    })
end

RunService.RenderStepped:Connect(function(dt)
    if not main.Visible then return end
    for _, f in ipairs(flocos) do
        if not f.obj.Parent then continue end
        f.alpha = f.alpha + dt
        local p = f.obj.Position
        local nx = p.X.Scale + (f.velX * dt) + (math.sin(f.alpha) * 0.0015)
        local ny = p.Y.Scale + (f.velY * dt)
        if ny > 1 then ny = -0.02; nx = math.random() end
        if nx < -0.02 then nx = 1 end
        if nx > 1.02 then nx = 0 end
        f.obj.Position = UDim2.new(nx, 0, ny, 0)
    end
end)

-- TOP BAR
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 34)
topBar.BackgroundColor3 = C.FundoTopo
topBar.BorderSizePixel = 0
topBar.ZIndex = 3
topBar.Parent = main

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 6)
topCorner.Parent = topBar

local topCover = Instance.new("Frame")
topCover.Size = UDim2.new(1, 0, 0, 6)
topCover.Position = UDim2.new(0, 0, 1, -6)
topCover.BackgroundColor3 = C.FundoTopo
topCover.BorderSizePixel = 0
topCover.ZIndex = 3
topCover.Parent = topBar

local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(0, 90, 1, 0)
logo.Position = UDim2.new(0, 10, 0, 0)
logo.BackgroundTransparency = 1
logo.Text = "syntax"
logo.TextColor3 = Color3.fromRGB(180, 130, 255)
logo.Font = Enum.Font.GothamBold
logo.TextSize = 15
logo.TextXAlignment = Enum.TextXAlignment.Left
logo.ZIndex = 3
logo.Parent = topBar

local keyInfoLabel = Instance.new("TextLabel")
keyInfoLabel.Size = UDim2.new(0, 220, 1, 0)
keyInfoLabel.Position = UDim2.new(1, -230, 0, 0)
keyInfoLabel.BackgroundTransparency = 1
keyInfoLabel.Text = ""
keyInfoLabel.TextColor3 = C.Dourado
keyInfoLabel.Font = Enum.Font.GothamBold
keyInfoLabel.TextSize = 12
keyInfoLabel.TextXAlignment = Enum.TextXAlignment.Right
keyInfoLabel.ZIndex = 3
keyInfoLabel.Parent = topBar

local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(1, -340, 1, 0)
tabsFrame.Position = UDim2.new(0, 100, 0, 0)
tabsFrame.BackgroundTransparency = 1
tabsFrame.ZIndex = 3
tabsFrame.Parent = topBar

local tabsLayout = Instance.new("UIListLayout")
tabsLayout.FillDirection = Enum.FillDirection.Horizontal
tabsLayout.Padding = UDim.new(0, 2)
tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabsLayout.Parent = tabsFrame

-- CONTENT
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -50)
content.Position = UDim2.new(0, 10, 0, 42)
content.BackgroundTransparency = 1
content.ZIndex = 3
content.Parent = main

local contentLayout = Instance.new("UIListLayout")
contentLayout.FillDirection = Enum.FillDirection.Horizontal
contentLayout.Padding = UDim.new(0, 10)
contentLayout.Parent = content

local leftCol = Instance.new("Frame")
leftCol.Size = UDim2.new(0.5, -5, 1, 0)
leftCol.BackgroundColor3 = C.FundoPainel
leftCol.BackgroundTransparency = 0.35
leftCol.BorderSizePixel = 0
leftCol.ZIndex = 3
leftCol.Parent = content

local leftCorner = Instance.new("UICorner")
leftCorner.CornerRadius = UDim.new(0, 4)
leftCorner.Parent = leftCol

local rightCol = Instance.new("Frame")
rightCol.Size = UDim2.new(0.5, -5, 1, 0)
rightCol.BackgroundColor3 = C.FundoPainel
rightCol.BackgroundTransparency = 0.35
rightCol.BorderSizePixel = 0
rightCol.ZIndex = 3
rightCol.Parent = content

local rightCorner = Instance.new("UICorner")
rightCorner.CornerRadius = UDim.new(0, 4)
rightCorner.Parent = rightCol

local function criarScroll(parent)
    local s = Instance.new("ScrollingFrame")
    s.Size = UDim2.new(1, -10, 1, -10)
    s.Position = UDim2.new(0, 5, 0, 5)
    s.BackgroundTransparency = 1
    s.BorderSizePixel = 0
    s.ScrollBarThickness = 3
    s.ScrollBarImageColor3 = C.SliderFill
    s.CanvasSize = UDim2.new(0, 0, 0, 0)
    s.AutomaticCanvasSize = Enum.AutomaticSize.Y
    s.ZIndex = 4
    s.Parent = parent
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, 4)
    l.Parent = s
    return s
end

local leftScroll  = criarScroll(leftCol)
local rightScroll = criarScroll(rightCol)

-- ============================================================
-- STATE
-- ============================================================
local opcoes = {
    Aimbot = false, AimbotToggle = false, AimMode = "Camlock",
    Smoothing = true, Smoothness = 1.0,
    VisibleCheck = true, Predict = true, PredictVal = 0.15,
    DrawFOV = false, AimFOV = 120, TargetBone = "Head",
    ESP_Esqueleto = false, ESP_Cabeca = false, ESP_Caixa = false,
    ESP_Nome = false, ESP_Distancia = false, ESP_Vida = false,
    ESP_BarraVida = false, ESP_Chams = false, ESP_Tracer = false,
    ESP_Visible = true,
    VerificarTime = true, LimiteAtivo = false, LimiteDist = 500,
    ESP_NomeSize = 14, ESP_CaixaWidth = 60, ESP_CaixaHeight = 100, ESP_StudsOffset = 3,
    Fly = false, Noclip = false, Speed = false, SpeedVal = 32,
    Freecam = false, FreecamSpeed = 1.0, InfiniteJump = false,
    VehicleFly = false, VehicleFlySpeed = 1.5,
    CameraFOVAtivo = false, CameraFOV = 70, FullBright = false,
    RemoverMoita = false, OtimizadorFPS = false, RemoverSombras = false,
    RemoverEfeitos = false, RemoverParticulas = false,
    ReduzirGraficos = false, ModoCartoon = false,

    HitboxEnabled     = false,
    HitboxSize        = 0,
    HitboxPart        = "Head",
    HitboxVisible     = false,
    HitboxTransparency= 1.0,
}

local BINDS = {
    Fly          = { Tipo = "None" },
    Noclip       = { Tipo = "None" },
    Speed        = { Tipo = "None" },
    Freecam      = { Tipo = "None" },
    InfiniteJump = { Tipo = "None" },
    VehicleFly   = { Tipo = "None" },
    LockTarget   = { Tipo = "None" },
    Hitbox       = { Tipo = "None" },
}

local function nomeBind(bind)
    if not bind or bind.Tipo == "None" then return "None" end
    if bind.Tipo == "Mouse" then
        local mapa = {
            [Enum.UserInputType.MouseButton1] = "Mouse L",
            [Enum.UserInputType.MouseButton2] = "Mouse R",
            [Enum.UserInputType.MouseButton3] = "Mouse M",
        }
        return mapa[bind.Botao] or "Mouse"
    else
        return tostring(bind.Tecla):gsub("Enum.KeyCode.", "")
    end
end

local alvoLockado = nil
local lockando    = false

local teclas = { Menu = Enum.KeyCode.Insert, Aimbot = Enum.KeyCode.B }
local aimbotInput = {
    Tipo  = "Mouse",
    Botao = Enum.UserInputType.MouseButton2,
    Tecla = Enum.KeyCode.B,
}

local aguardandoTeclaAimbot = false
local aguardandoBind        = nil
local aimbotSegurando       = false
local aimbotToggleAtivo     = false
local digitandoNome         = false
local minhaKey              = nil
local minhaExpiracao        = 0
local jaKickado             = false

-- ============================================================
-- UI HELPERS
-- ============================================================
local function nomeTecla(kc)
    if not kc then return "?" end
    return tostring(kc):gsub("Enum.KeyCode.", "")
end

local function nomeInputAimbot()
    if aimbotInput.Tipo == "Mouse" then
        local mapa = {
            [Enum.UserInputType.MouseButton1] = "Left Mouse",
            [Enum.UserInputType.MouseButton2] = "Right Mouse",
            [Enum.UserInputType.MouseButton3] = "Middle Mouse",
        }
        return mapa[aimbotInput.Botao] or "Right Mouse"
    else
        return nomeTecla(aimbotInput.Tecla)
    end
end

local function criarSecao(parent, texto)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = texto
    lbl.TextColor3 = C.Secao
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 6
    lbl.Parent = parent
end

local function criarCheckbox(parent, texto, chave, cb)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 22)
    row.BackgroundTransparency = 1
    row.ZIndex = 6
    row.Parent = parent

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 16, 0, 16)
    box.Position = UDim2.new(0, 0, 0.5, -8)
    box.BackgroundColor3 = opcoes[chave] and C.Check or C.CheckOff
    box.Text = opcoes[chave] and "✓" or ""
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 14
    box.BorderSizePixel = 0
    box.AutoButtonColor = false
    box.ZIndex = 6
    box.Parent = row

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 3)
    c.Parent = box

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -22, 1, 0)
    lbl.Position = UDim2.new(0, 22, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = texto
    lbl.TextColor3 = C.Texto
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 6
    lbl.Parent = row

    box.MouseButton1Click:Connect(function()
        opcoes[chave] = not opcoes[chave]
        box.BackgroundColor3 = opcoes[chave] and C.Check or C.CheckOff
        box.Text = opcoes[chave] and "✓" or ""
        if cb then cb(opcoes[chave]) end
    end)
end

local function criarSlider(parent, texto, chave, minV, maxV, padrao, fmt)
    fmt = fmt or function(v) return tostring(math.floor(v)) end
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 32)
    holder.BackgroundTransparency = 1
    holder.ZIndex = 6
    holder.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = texto
    lbl.TextColor3 = C.Texto
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 6
    lbl.Parent = holder

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 55, 0, 16)
    valLbl.Position = UDim2.new(1, -55, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = fmt(opcoes[chave] or padrao)
    valLbl.TextColor3 = C.Texto
    valLbl.Font = Enum.Font.Gotham
    valLbl.TextSize = 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 6
    valLbl.Parent = holder

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 4)
    bar.Position = UDim2.new(0, 0, 0, 22)
    bar.BackgroundColor3 = C.SliderFundo
    bar.BorderSizePixel = 0
    bar.ZIndex = 6
    bar.Parent = holder

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(1, 0)
    bc.Parent = bar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((opcoes[chave] - minV) / (maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = C.SliderFill
    fill.BorderSizePixel = 0
    fill.ZIndex = 6
    fill.Parent = bar

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1, 0)
    fc.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 10, 0, 10)
    knob.Position = UDim2.new((opcoes[chave] - minV) / (maxV - minV), -5, 0.5, -5)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 7
    knob.Parent = bar

    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent = knob

    local arrastando = false
    local function atualizar(x)
        local abs = bar.AbsolutePosition.X
        local lar = bar.AbsoluteSize.X
        local pct = math.clamp((x - abs) / lar, 0, 1)
        local v = minV + (maxV - minV) * pct
        opcoes[chave] = v
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -5, 0.5, -5)
        valLbl.Text = fmt(v)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            arrastando = true
            atualizar(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not arrastando then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            atualizar(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            arrastando = false
        end
    end)
end

local function criarBotao(parent, texto, cb, corCustom)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = corCustom or C.Botao
    btn.Text = texto
    btn.TextColor3 = C.Texto
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.ZIndex = 6
    btn.Parent = parent
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = btn
    btn.MouseEnter:Connect(function()
        if not corCustom then btn.BackgroundColor3 = C.BotaoHover end
    end)
    btn.MouseLeave:Connect(function()
        if not corCustom then btn.BackgroundColor3 = C.Botao end
    end)
    btn.MouseButton1Click:Connect(function() if cb then cb() end end)
    return btn
end

-- ============================================================
-- BIND WIDGET
-- ============================================================
local function criarBindWidget(parent, nomeModulo, chaveModulo)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 28)
    row.BackgroundTransparency = 1
    row.ZIndex = 6
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.42, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = nomeModulo
    lbl.TextColor3 = C.Texto
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 6
    lbl.Parent = row

    local btnKey = Instance.new("TextButton")
    btnKey.Size = UDim2.new(0.36, -2, 1, 0)
    btnKey.Position = UDim2.new(0.42, 0, 0, 0)
    local isNone = (BINDS[chaveModulo].Tipo == "None")
    btnKey.BackgroundColor3 = isNone and C.None or Color3.fromRGB(80, 60, 140)
    btnKey.Text = "[" .. nomeBind(BINDS[chaveModulo]) .. "]"
    btnKey.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnKey.Font = Enum.Font.GothamBold
    btnKey.TextSize = 11
    btnKey.BorderSizePixel = 0
    btnKey.AutoButtonColor = false
    btnKey.ZIndex = 6
    btnKey.Parent = row

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 4)
    bc.Parent = btnKey

    btnKey.MouseButton1Click:Connect(function()
        if aguardandoBind then return end
        aguardandoBind = chaveModulo
        btnKey.Text = "Press..."
        btnKey.BackgroundColor3 = Color3.fromRGB(200, 140, 0)
        _G._syntaxBindBtn = btnKey
        _G._syntaxBindChave = chaveModulo
    end)

    local btnRst = Instance.new("TextButton")
    btnRst.Size = UDim2.new(0.20, -2, 1, 0)
    btnRst.Position = UDim2.new(0.80, 0, 0, 0)
    btnRst.BackgroundColor3 = C.BotaoVerm
    btnRst.Text = "Reset"
    btnRst.TextColor3 = C.Texto
    btnRst.Font = Enum.Font.Gotham
    btnRst.TextSize = 10
    btnRst.BorderSizePixel = 0
    btnRst.AutoButtonColor = false
    btnRst.ZIndex = 6
    btnRst.Parent = row

    local rbc = Instance.new("UICorner")
    rbc.CornerRadius = UDim.new(0, 4)
    rbc.Parent = btnRst

    btnRst.MouseButton1Click:Connect(function()
        BINDS[chaveModulo] = { Tipo = "None" }
        aguardandoBind = nil
        _G._syntaxBindBtn = nil
        _G._syntaxBindChave = nil
        btnKey.Text = "[None]"
        btnKey.BackgroundColor3 = C.None
    end)
end

-- ============================================================
-- HITBOX EXPANDER
-- ============================================================
local hitboxOriginal = {}

local function restaurarHitboxes()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            for _, nome in ipairs({"Head", "UpperTorso", "LowerTorso", "Torso"}) do
                local part = plr.Character:FindFirstChild(nome)
                if part and part:IsA("BasePart") and hitboxOriginal[part] then
                    pcall(function()
                        part.Size         = hitboxOriginal[part].size
                        part.Transparency = hitboxOriginal[part].transp
                        part.Massless     = hitboxOriginal[part].massless
                        part.CanCollide   = hitboxOriginal[part].cancollide
                        part.CanQuery     = hitboxOriginal[part].canquery
                        part.CanTouch     = hitboxOriginal[part].cantouch
                    end)
                    hitboxOriginal[part] = nil
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not opcoes.HitboxEnabled then
        if next(hitboxOriginal) then restaurarHitboxes() end
        return
    end

    local tamanho = opcoes.HitboxSize or 0
    if tamanho <= 0 then
        if next(hitboxOriginal) then restaurarHitboxes() end
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local partNome = opcoes.HitboxPart or "Head"
            local part = plr.Character:FindFirstChild(partNome)
            if not part and partNome == "Chest" then
                part = plr.Character:FindFirstChild("UpperTorso") or plr.Character:FindFirstChild("Torso")
            end
            if part and part:IsA("BasePart") then
                if not hitboxOriginal[part] then
                    hitboxOriginal[part] = {
                        size       = part.Size,
                        transp     = part.Transparency,
                        massless   = part.Massless,
                        cancollide = part.CanCollide,
                        canquery   = part.CanQuery,
                        cantouch   = part.CanTouch,
                    }
                end
                pcall(function()
                    part.Size = Vector3.new(tamanho, tamanho, tamanho)
                    if opcoes.HitboxVisible then
                        part.Transparency = opcoes.HitboxTransparency or 1.0
                    else
                        part.Transparency = 1
                    end
                    part.Massless   = true
                    part.CanCollide = false
                    part.CanQuery   = true
                    part.CanTouch   = true
                end)
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if plr.Character then
        for _, nome in ipairs({"Head", "UpperTorso", "LowerTorso", "Torso"}) do
            local part = plr.Character:FindFirstChild(nome)
            if part then hitboxOriginal[part] = nil end
        end
    end
end)

-- ============================================================
-- APLICADORES
-- ============================================================
local fullBrightSalvo = nil
local function aplicarFullBright(ativo)
    if ativo then
        if not fullBrightSalvo then
            fullBrightSalvo = {
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                FogEnd = Lighting.FogEnd,
                GlobalShadows = Lighting.GlobalShadows,
                Ambient = Lighting.Ambient,
            }
        end
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    else
        if fullBrightSalvo then
            pcall(function()
                Lighting.Brightness = fullBrightSalvo.Brightness
                Lighting.ClockTime = fullBrightSalvo.ClockTime
                Lighting.FogEnd = fullBrightSalvo.FogEnd
                Lighting.GlobalShadows = fullBrightSalvo.GlobalShadows
                Lighting.Ambient = fullBrightSalvo.Ambient
            end)
            fullBrightSalvo = nil
        end
    end
end

local moitasEscondidas = {}
local moitaAplicada = false
local function aplicarRemoverMoita(ativo)
    if ativo and not moitaAplicada then
        moitaAplicada = true
        pcall(function()
            local terrain = workspace.Terrain
            if terrain and terrain.Decoration then
                table.insert(moitasEscondidas, {obj = terrain, prop = "Decoration", valor = true, virtual = true})
                terrain.Decoration = false
            end
        end)
        for _, obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                local nome = string.lower(obj.Name)
                if obj:IsA("BasePart") then
                    if nome:find("grass") or nome:find("bush") or nome:find("moita")
                    or nome:find("shrub") or nome:find("foliage") or nome:find("vegetation") then
                        table.insert(moitasEscondidas, {obj = obj, prop = "Transparency", valor = obj.Transparency})
                        obj.Transparency = 1
                    end
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    if nome:find("grass") or nome:find("moita") or nome:find("bush")
                    or nome:find("leaf") or nome:find("foliage") then
                        table.insert(moitasEscondidas, {obj = obj, prop = "Transparency", valor = obj.Transparency})
                        obj.Transparency = 1
                    end
                end
            end)
        end
    elseif not ativo and moitaAplicada then
        moitaAplicada = false
        for _, item in ipairs(moitasEscondidas) do
            pcall(function()
                if item.virtual then item.obj[item.prop] = item.valor
                elseif item.obj and item.obj.Parent then item.obj[item.prop] = item.valor end
            end)
        end
        moitasEscondidas = {}
    end
end

local sombrasSalvo = nil
local function aplicarRemoverSombras(ativo)
    if ativo then
        if not sombrasSalvo then sombrasSalvo = Lighting.GlobalShadows end
        Lighting.GlobalShadows = false
    else
        if sombrasSalvo ~= nil then
            Lighting.GlobalShadows = sombrasSalvo
            sombrasSalvo = nil
        end
    end
end

local efeitosRemovidos = {}
local efeitosAplicado = false
local function aplicarRemoverEfeitos(ativo)
    if ativo and not efeitosAplicado then
        efeitosAplicado = true
        pcall(function()
            for _, e in ipairs(Lighting:GetChildren()) do
                if e:IsA("PostEffect") or e:IsA("Atmosphere") or e:IsA("Sky") then
                    table.insert(efeitosRemovidos, {obj = e, enabled = e.Enabled})
                    e.Enabled = false
                end
            end
        end)
    elseif not ativo and efeitosAplicado then
        efeitosAplicado = false
        for _, item in ipairs(efeitosRemovidos) do
            if item.obj and item.obj.Parent then
                pcall(function() item.obj.Enabled = item.enabled end)
            end
        end
        efeitosRemovidos = {}
    end
end

local particulasRemovidas = {}
local particulasAplicado = false
local function aplicarRemoverParticulas(ativo)
    if ativo and not particulasAplicado then
        particulasAplicado = true
        for _, obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke")
                or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    table.insert(particulasRemovidas, {obj = obj, enabled = obj.Enabled})
                    obj.Enabled = false
                end
            end)
        end
    elseif not ativo and particulasAplicado then
        particulasAplicado = false
        for _, item in ipairs(particulasRemovidas) do
            if item.obj and item.obj.Parent then
                pcall(function() item.obj.Enabled = item.enabled end)
            end
        end
        particulasRemovidas = {}
    end
end

local function aplicarReduzirGraficos(ativo)
    if ativo then
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        pcall(function() settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01 end)
        pcall(function() settings().Rendering.EffectsQuality = Enum.QualityLevel.Level01 end)
    end
end

local function aplicarOtimizadorFPS(ativo)
    if ativo then
        aplicarRemoverEfeitos(true)
        aplicarRemoverParticulas(true)
        aplicarReduzirGraficos(true)
        aplicarRemoverSombras(true)
    else
        aplicarRemoverEfeitos(false)
        aplicarRemoverParticulas(false)
        aplicarRemoverSombras(false)
    end
end

-- ============================================================
-- TABS
-- ============================================================
local abas = {}
local abaAtual = nil

local function limparColunas()
    for _, ch in ipairs(leftScroll:GetChildren()) do
        if not ch:IsA("UIListLayout") then ch:Destroy() end
    end
    for _, ch in ipairs(rightScroll:GetChildren()) do
        if not ch:IsA("UIListLayout") then ch:Destroy() end
    end
end

local function criarAba(nome, desenhar, soDono)
    if soDono and not ehDono then return end
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 72, 0, 22)
    btn.BackgroundTransparency = 1
    btn.Text = nome
    btn.TextColor3 = C.AbaInativa
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.ZIndex = 3
    btn.Parent = tabsFrame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 0, 0, 2)
    bar.Position = UDim2.new(0, 0, 1, -2)
    bar.BackgroundColor3 = C.AbaAtiva
    bar.BorderSizePixel = 0
    bar.ZIndex = 3
    bar.Parent = btn

    abas[nome] = {btn = btn, bar = bar, desenhar = desenhar}

    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(abas) do
            v.btn.TextColor3 = C.AbaInativa
            v.bar.Size = UDim2.new(0, 0, 0, 2)
        end
        btn.TextColor3 = C.AbaAtivaTxt
        bar.Size = UDim2.new(1, 0, 0, 2)
        abaAtual = nome
        limparColunas()
        desenhar()
    end)
end

-- ============================================================
-- KEY MANAGER (owner only)
-- ============================================================
local keyManagerAbaAtual = "1D"

local function desenharKeyManager()
    local subHolder = Instance.new("Frame")
    subHolder.Size = UDim2.new(1, 0, 0, 30)
    subHolder.BackgroundTransparency = 1
    subHolder.ZIndex = 6
    subHolder.Parent = leftScroll

    local subLayout = Instance.new("UIListLayout")
    subLayout.FillDirection = Enum.FillDirection.Horizontal
    subLayout.Padding = UDim.new(0, 4)
    subLayout.Parent = subHolder

    local subAbas = {
        {id = "1D", label = "1 Day"},
        {id = "7D", label = "7 Days"},
        {id = "1M", label = "1 Month"},
        {id = "LF", label = "Lifetime"},
    }
    for _, sub in ipairs(subAbas) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 72, 0, 26)
        btn.BackgroundColor3 = (keyManagerAbaAtual == sub.id) and C.Check or C.CheckOff
        btn.Text = sub.label
        btn.TextColor3 = (keyManagerAbaAtual == sub.id) and Color3.fromRGB(255,255,255) or C.TextoFraco
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.ZIndex = 6
        btn.Parent = subHolder
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 4)
        c.Parent = btn
        btn.MouseButton1Click:Connect(function()
            keyManagerAbaAtual = sub.id
            if abaAtual == "KeyManager" then
                limparColunas()
                desenharKeyManager()
            end
        end)
    end

    local tipoSel = keyManagerAbaAtual
    local infoTipo = TIPOS[tipoSel]

    criarSecao(leftScroll, "Generate Keys — " .. infoTipo.nome)

    local qtdAtual = 1
    criarSlider(leftScroll, "Quantity (1 to 25)", "ESP_NomeSize", 1, 25, 1,
        function(v)
            qtdAtual = math.clamp(math.floor(v + 0.5), 1, 25)
            return tostring(qtdAtual)
        end)

    criarBotao(leftScroll, "🎲 GENERATE KEY(S) — " .. string.upper(infoTipo.nome), function()
        local keys = lerKeysGeradas()
        local novas = 0
        for i = 1, qtdAtual do
            local novaKey = gerarKey(tipoSel)
            local tentativas = 0
            while keys[novaKey] and tentativas < 100 do
                novaKey = gerarKey(tipoSel)
                tentativas = tentativas + 1
            end
            keys[novaKey] = { tipo = tipoSel, expira = 0 }
            novas = novas + 1
        end
        salvarKeysGeradas(keys)
        print("[KEY MANAGER] " .. novas .. " keys generated.")
        if abaAtual == "KeyManager" then
            limparColunas()
            desenharKeyManager()
        end
    end, C.BotaoVerde)

    criarBotao(leftScroll, "🗑️ Delete keys of " .. infoTipo.nome, function()
        local keys = lerKeysGeradas()
        for k, dados in pairs(keys) do
            if dados.tipo == tipoSel then keys[k] = nil end
        end
        salvarKeysGeradas(keys)
        if abaAtual == "KeyManager" then
            limparColunas()
            desenharKeyManager()
        end
    end, C.BotaoVerm)

    criarSecao(rightScroll, "Keys — " .. infoTipo.nome)
    local keys = lerKeysGeradas()
    local listaTipo = {}
    for key, dados in pairs(keys) do
        if dados.tipo == tipoSel then table.insert(listaTipo, key) end
    end
    table.sort(listaTipo)

    if #listaTipo == 0 then
        local vazio = Instance.new("TextLabel")
        vazio.Size = UDim2.new(1, 0, 0, 40)
        vazio.BackgroundTransparency = 1
        vazio.Text = "No keys of " .. infoTipo.nome .. " generated yet."
        vazio.TextColor3 = C.TextoFraco
        vazio.Font = Enum.Font.Gotham
        vazio.TextSize = 12
        vazio.TextXAlignment = Enum.TextXAlignment.Left
        vazio.TextWrapped = true
        vazio.ZIndex = 6
        vazio.Parent = rightScroll
    else
        local contLbl = Instance.new("TextLabel")
        contLbl.Size = UDim2.new(1, 0, 0, 16)
        contLbl.BackgroundTransparency = 1
        contLbl.Text = "Total: " .. #listaTipo .. " keys"
        contLbl.TextColor3 = C.Dourado
        contLbl.Font = Enum.Font.GothamBold
        contLbl.TextSize = 11
        contLbl.TextXAlignment = Enum.TextXAlignment.Left
        contLbl.ZIndex = 6
        contLbl.Parent = rightScroll

        local copiarTudo = Instance.new("TextButton")
        copiarTudo.Size = UDim2.new(1, 0, 0, 24)
        copiarTudo.BackgroundColor3 = C.BotaoVerde
        copiarTudo.Text = "📋 Copy ALL " .. #listaTipo .. " keys"
        copiarTudo.TextColor3 = C.Texto
        copiarTudo.Font = Enum.Font.GothamBold
        copiarTudo.TextSize = 12
        copiarTudo.BorderSizePixel = 0
        copiarTudo.AutoButtonColor = false
        copiarTudo.ZIndex = 6
        copiarTudo.Parent = rightScroll
        local ctc = Instance.new("UICorner")
        ctc.CornerRadius = UDim.new(0, 4)
        ctc.Parent = copiarTudo
        copiarTudo.MouseButton1Click:Connect(function()
            if setclipboard then
                pcall(function() setclipboard(table.concat(listaTipo, "\n")) end)
                copiarTudo.Text = "✅ Copied!"
                task.wait(2)
                copiarTudo.Text = "📋 Copy ALL " .. #listaTipo .. " keys"
            end
        end)

        for _, key in ipairs(listaTipo) do
            local linha = Instance.new("TextButton")
            linha.Size = UDim2.new(1, 0, 0, 24)
            linha.BackgroundColor3 = C.Botao
            linha.Text = "  " .. key
            linha.TextColor3 = C.Texto
            linha.Font = Enum.Font.Code
            linha.TextSize = 12
            linha.TextXAlignment = Enum.TextXAlignment.Left
            linha.BorderSizePixel = 0
            linha.AutoButtonColor = false
            linha.ZIndex = 6
            linha.Parent = rightScroll
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 4)
            c.Parent = linha
            linha.MouseButton1Click:Connect(function()
                if setclipboard then
                    pcall(function() setclipboard(key) end)
                    local original = linha.Text
                    linha.Text = "  ✅ COPIED!"
                    linha.BackgroundColor3 = C.BotaoVerde
                    task.wait(1)
                    linha.Text = original
                    linha.BackgroundColor3 = C.Botao
                end
            end)
        end
    end
end

-- ============================================================
-- AIMBOT TAB
-- ============================================================
local desenharAimbot

desenharAimbot = function()
    criarSecao(leftScroll, "Aimbot")
    criarCheckbox(leftScroll, "Aimbot",             "Aimbot")
    criarCheckbox(leftScroll, "Aimbot Toggle (B)",  "AimbotToggle")

    local modoHolder = Instance.new("Frame")
    modoHolder.Size = UDim2.new(1, 0, 0, 44)
    modoHolder.BackgroundTransparency = 1
    modoHolder.ZIndex = 6
    modoHolder.Parent = leftScroll

    local modoLbl = Instance.new("TextLabel")
    modoLbl.Size = UDim2.new(1, 0, 0, 16)
    modoLbl.BackgroundTransparency = 1
    modoLbl.Text = "Mode"
    modoLbl.TextColor3 = C.Texto
    modoLbl.Font = Enum.Font.Gotham
    modoLbl.TextSize = 12
    modoLbl.TextXAlignment = Enum.TextXAlignment.Left
    modoLbl.ZIndex = 6
    modoLbl.Parent = modoHolder

    local modos = {"Camlock", "Mouse Free"}
    local botoesModo = {}
    for i, nome in ipairs(modos) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.5, -3, 0, 24)
        btn.Position = UDim2.new((i-1) * 0.5 + (i==2 and 0.01 or 0), 0, 0, 18)
        btn.BackgroundColor3 = (opcoes.AimMode == nome) and C.Check or C.CheckOff
        btn.Text = nome
        btn.TextColor3 = (opcoes.AimMode == nome) and Color3.fromRGB(255,255,255) or C.TextoFraco
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.ZIndex = 6
        btn.Parent = modoHolder
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 4)
        c.Parent = btn
        botoesModo[nome] = btn
        btn.MouseButton1Click:Connect(function()
            opcoes.AimMode = nome
            for n, b in pairs(botoesModo) do
                if n == nome then
                    b.BackgroundColor3 = C.Check
                    b.TextColor3 = Color3.fromRGB(255,255,255)
                else
                    b.BackgroundColor3 = C.CheckOff
                    b.TextColor3 = C.TextoFraco
                end
            end
            if nome == "Mouse Free" then
                setMouseModo("livre")
            else
                setMouseModo("auto")
            end
        end)
    end

    criarSecao(leftScroll, "HOLD Key")
    local holdRow = Instance.new("Frame")
    holdRow.Size = UDim2.new(1, 0, 0, 26)
    holdRow.BackgroundTransparency = 1
    holdRow.ZIndex = 6
    holdRow.Parent = leftScroll

    local holdBtn = Instance.new("TextButton")
    holdBtn.Size = UDim2.new(0.62, -3, 1, 0)
    holdBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 140)
    holdBtn.Text = nomeInputAimbot()
    holdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    holdBtn.Font = Enum.Font.GothamBold
    holdBtn.TextSize = 12
    holdBtn.BorderSizePixel = 0
    holdBtn.AutoButtonColor = false
    holdBtn.ZIndex = 6
    holdBtn.Parent = holdRow
    local hbc = Instance.new("UICorner")
    hbc.CornerRadius = UDim.new(0, 4)
    hbc.Parent = holdBtn
    holdBtn.MouseButton1Click:Connect(function()
        if aguardandoTeclaAimbot then return end
        aguardandoTeclaAimbot = true
        holdBtn.Text = "Press key/button..."
        holdBtn.BackgroundColor3 = Color3.fromRGB(200, 140, 0)
        _G._syntaxRebindAimbot = {btn = holdBtn}
    end)

    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(0.38, -3, 1, 0)
    resetBtn.Position = UDim2.new(0.62, 3, 0, 0)
    resetBtn.BackgroundColor3 = C.BotaoVerm
    resetBtn.Text = "Reset"
    resetBtn.TextColor3 = C.Texto
    resetBtn.Font = Enum.Font.Gotham
    resetBtn.TextSize = 12
    resetBtn.BorderSizePixel = 0
    resetBtn.AutoButtonColor = false
    resetBtn.ZIndex = 6
    resetBtn.Parent = holdRow
    local rbc = Instance.new("UICorner")
    rbc.CornerRadius = UDim.new(0, 4)
    rbc.Parent = resetBtn
    resetBtn.MouseButton1Click:Connect(function()
        aimbotInput.Tipo = "Mouse"
        aimbotInput.Botao = Enum.UserInputType.MouseButton2
        if abaAtual == "Aimbot" then
            limparColunas()
            desenharAimbot()
        end
    end)

    criarCheckbox(leftScroll, "Smoothing",  "Smoothing")
    criarSlider(leftScroll, "Smoothness", "Smoothness", 0, 5, 1,
        function(v) return string.format("%.3f", v) end)

    criarSecao(leftScroll, "Target")
    criarCheckbox(leftScroll, "Visible Check", "VisibleCheck")
    criarCheckbox(leftScroll, "Predict",       "Predict")
    criarSlider(leftScroll, "Predict H Value", "PredictVal", 0, 1, 0.15,
        function(v) return string.format("%.2f", v) end)

    criarSecao(leftScroll, "FOV")
    criarCheckbox(leftScroll, "Draw FOV", "DrawFOV")
    criarSlider(leftScroll, "Aim FOV (px)", "AimFOV", 10, 600, 120,
        function(v) return tostring(math.floor(v)) end)

    criarSecao(leftScroll, "Lock (1 person)")
    local lockInfo = Instance.new("TextLabel")
    lockInfo.Size = UDim2.new(1, 0, 0, 30)
    lockInfo.BackgroundTransparency = 1
    lockInfo.Text = "Choose a key. With Aimbot on, press it near a player to lock."
    lockInfo.TextColor3 = C.TextoFraco
    lockInfo.Font = Enum.Font.Gotham
    lockInfo.TextSize = 10
    lockInfo.TextXAlignment = Enum.TextXAlignment.Left
    lockInfo.TextWrapped = true
    lockInfo.ZIndex = 6
    lockInfo.Parent = leftScroll

    local lockRow = Instance.new("Frame")
    lockRow.Size = UDim2.new(1, 0, 0, 26)
    lockRow.BackgroundTransparency = 1
    lockRow.ZIndex = 6
    lockRow.Parent = leftScroll

    local lockBtn = Instance.new("TextButton")
    lockBtn.Size = UDim2.new(0.62, -3, 1, 0)
    lockBtn.BackgroundColor3 = (BINDS.LockTarget.Tipo == "None") and C.None or Color3.fromRGB(80, 60, 140)
    lockBtn.Text = "[" .. nomeBind(BINDS.LockTarget) .. "]"
    lockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    lockBtn.Font = Enum.Font.GothamBold
    lockBtn.TextSize = 12
    lockBtn.BorderSizePixel = 0
    lockBtn.AutoButtonColor = false
    lockBtn.ZIndex = 6
    lockBtn.Parent = lockRow

    local lbc = Instance.new("UICorner")
    lbc.CornerRadius = UDim.new(0, 4)
    lbc.Parent = lockBtn

    lockBtn.MouseButton1Click:Connect(function()
        if aguardandoBind then return end
        aguardandoBind = "LockTarget"
        lockBtn.Text = "Press a key..."
        lockBtn.BackgroundColor3 = Color3.fromRGB(200, 140, 0)
        _G._syntaxBindBtn = lockBtn
        _G._syntaxBindChave = "LockTarget"
    end)

    local lockRst = Instance.new("TextButton")
    lockRst.Size = UDim2.new(0.38, -3, 1, 0)
    lockRst.Position = UDim2.new(0.62, 3, 0, 0)
    lockRst.BackgroundColor3 = C.BotaoVerm
    lockRst.Text = "Reset"
    lockRst.TextColor3 = C.Texto
    lockRst.Font = Enum.Font.Gotham
    lockRst.TextSize = 12
    lockRst.BorderSizePixel = 0
    lockRst.AutoButtonColor = false
    lockRst.ZIndex = 6
    lockRst.Parent = lockRow

    local lrc = Instance.new("UICorner")
    lrc.CornerRadius = UDim.new(0, 4)
    lrc.Parent = lockRst

    lockRst.MouseButton1Click:Connect(function()
        BINDS.LockTarget = { Tipo = "None" }
        lockBtn.Text = "[None]"
        lockBtn.BackgroundColor3 = C.None
        alvoLockado = nil
        lockando = false
    end)

    local lockStatus = Instance.new("TextLabel")
    lockStatus.Size = UDim2.new(1, 0, 0, 20)
    lockStatus.BackgroundTransparency = 1
    lockStatus.Text = "🔓 Free"
    lockStatus.TextColor3 = C.TextoFraco
    lockStatus.Font = Enum.Font.GothamBold
    lockStatus.TextSize = 11
    lockStatus.TextXAlignment = Enum.TextXAlignment.Left
    lockStatus.ZIndex = 6
    lockStatus.Parent = leftScroll

    task.spawn(function()
        while task.wait(0.3) do
            if lockStatus and lockStatus.Parent then
                if lockando and alvoLockado and alvoLockado.Parent then
                    lockStatus.Text = "🔒 Locked: " .. alvoLockado.Name
                    lockStatus.TextColor3 = C.Dourado
                else
                    lockStatus.Text = "🔓 Free"
                    lockStatus.TextColor3 = C.TextoFraco
                end
            end
        end
    end)

    -- HITBOX EXPANDER (coluna direita)
    criarSecao(rightScroll, "Hitbox Expander")
    criarCheckbox(rightScroll, "Enable Hitbox", "HitboxEnabled")
    criarSlider(rightScroll, "Hitbox Size (0-1000)", "HitboxSize", 0, 1000, 0,
        function(v) return tostring(math.floor(v)) end)

    local hpPartHolder = Instance.new("Frame")
    hpPartHolder.Size = UDim2.new(1, 0, 0, 44)
    hpPartHolder.BackgroundTransparency = 1
    hpPartHolder.ZIndex = 6
    hpPartHolder.Parent = rightScroll

    local hpPartLbl = Instance.new("TextLabel")
    hpPartLbl.Size = UDim2.new(1, 0, 0, 16)
    hpPartLbl.BackgroundTransparency = 1
    hpPartLbl.Text = "Hitbox Part"
    hpPartLbl.TextColor3 = C.Texto
    hpPartLbl.Font = Enum.Font.Gotham
    hpPartLbl.TextSize = 12
    hpPartLbl.TextXAlignment = Enum.TextXAlignment.Left
    hpPartLbl.ZIndex = 6
    hpPartLbl.Parent = hpPartHolder

    local partes = {"Head", "Chest"}
    local botoesParte = {}
    for i, nome in ipairs(partes) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.5, -3, 0, 24)
        btn.Position = UDim2.new((i-1) * 0.5 + (i==2 and 0.01 or 0), 0, 0, 18)
        btn.BackgroundColor3 = (opcoes.HitboxPart == nome) and C.Check or C.CheckOff
        btn.Text = nome
        btn.TextColor3 = (opcoes.HitboxPart == nome) and Color3.fromRGB(255,255,255) or C.TextoFraco
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.ZIndex = 6
        btn.Parent = hpPartHolder
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 4)
        c.Parent = btn
        botoesParte[nome] = btn
        btn.MouseButton1Click:Connect(function()
            opcoes.HitboxPart = nome
            for n, b in pairs(botoesParte) do
                if n == nome then
                    b.BackgroundColor3 = C.Check
                    b.TextColor3 = Color3.fromRGB(255,255,255)
                else
                    b.BackgroundColor3 = C.CheckOff
                    b.TextColor3 = C.TextoFraco
                end
            end
        end)
    end

    criarCheckbox(rightScroll, "Show Hitbox", "HitboxVisible")
    criarSlider(rightScroll, "Transparency (0-1)", "HitboxTransparency", 0, 1, 1,
        function(v) return string.format("%.2f", v) end)

    criarSecao(rightScroll, "Info")
    local help = Instance.new("TextLabel")
    help.Size = UDim2.new(1, 0, 0, 130)
    help.BackgroundTransparency = 1
    help.Text = "• Camlock = camera locks on target\n" ..
                "• Mouse Free = aim from cursor\n\n" ..
                "• HOLD = hold the chosen key\n" ..
                "• TOGGLE = press B\n\n" ..
                "Hitbox: enlarge Head or Chest\n" ..
                "0 = disabled  |  1000 = huge"
    help.TextColor3 = C.TextoFraco
    help.Font = Enum.Font.Gotham
    help.TextSize = 11
    help.TextXAlignment = Enum.TextXAlignment.Left
    help.TextWrapped = true
    help.ZIndex = 6
    help.Parent = rightScroll
end

-- ============================================================
-- VISUALS TAB
-- ============================================================
local function desenharVisuals()
    criarSecao(leftScroll, "ESP — Players")
    criarCheckbox(leftScroll, "Name",           "ESP_Nome")
    criarCheckbox(leftScroll, "Distance",       "ESP_Distancia")
    criarCheckbox(leftScroll, "Health (HP)",    "ESP_Vida")
    criarCheckbox(leftScroll, "Health Bar",     "ESP_BarraVida")
    criarCheckbox(leftScroll, "Box 2D",         "ESP_Caixa")
    criarCheckbox(leftScroll, "Head Circle",    "ESP_Cabeca")
    criarCheckbox(leftScroll, "Skeleton",       "ESP_Esqueleto")
    criarCheckbox(leftScroll, "Chams",          "ESP_Chams")
    criarCheckbox(leftScroll, "Tracer",         "ESP_Tracer")
    criarCheckbox(leftScroll, "Show Visible Yes/No", "ESP_Visible")

    criarSecao(rightScroll, "Size")
    criarSlider(rightScroll, "Name Size",      "ESP_NomeSize",    8, 30, 14,
        function(v) return tostring(math.floor(v)) end)
    criarSlider(rightScroll, "Box Width %",  "ESP_CaixaWidth",  30, 150, 60,
        function(v) return tostring(math.floor(v)) .. "%" end)
    criarSlider(rightScroll, "Box Height %", "ESP_CaixaHeight", 30, 200, 100,
        function(v) return tostring(math.floor(v)) .. "%" end)
    criarSlider(rightScroll, "Studs Offset",   "ESP_StudsOffset", 0, 15, 3,
        function(v) return string.format("%.1f", v) end)

    criarSecao(rightScroll, "Filters")
    criarCheckbox(rightScroll, "Ignore Team", "VerificarTime")
    criarCheckbox(rightScroll, "Distance Limit", "LimiteAtivo")

    local distLbl = Instance.new("TextLabel")
    distLbl.Size = UDim2.new(1, 0, 0, 16)
    distLbl.BackgroundTransparency = 1
    distLbl.Text = "Max Distance"
    distLbl.TextColor3 = C.Texto
    distLbl.Font = Enum.Font.Gotham
    distLbl.TextSize = 12
    distLbl.TextXAlignment = Enum.TextXAlignment.Left
    distLbl.ZIndex = 6
    distLbl.Parent = rightScroll

    local distFrame = Instance.new("Frame")
    distFrame.Size = UDim2.new(1, 0, 0, 30)
    distFrame.BackgroundTransparency = 1
    distFrame.ZIndex = 6
    distFrame.Parent = rightScroll

    local distLayout = Instance.new("UIListLayout")
    distLayout.FillDirection = Enum.FillDirection.Horizontal
    distLayout.Padding = UDim.new(0, 4)
    distLayout.Parent = distFrame

    local distValores = {
        {label = "100",  valor = 100},
        {label = "500",  valor = 500},
        {label = "2000", valor = 2000},
        {label = "∞",    valor = math.huge},
    }
    local botoesDist = {}
    for _, item in ipairs(distValores) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 60, 0, 26)
        btn.BackgroundColor3 = (opcoes.LimiteDist == item.valor) and C.Check or C.CheckOff
        btn.Text = item.label
        btn.TextColor3 = (opcoes.LimiteDist == item.valor) and Color3.fromRGB(255,255,255) or C.TextoFraco
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.ZIndex = 6
        btn.Parent = distFrame
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 4)
        c.Parent = btn
        table.insert(botoesDist, {btn = btn, valor = item.valor})
        btn.MouseButton1Click:Connect(function()
            opcoes.LimiteDist = item.valor
            for _, b in ipairs(botoesDist) do
                local ativo = (opcoes.LimiteDist == b.valor)
                b.btn.BackgroundColor3 = ativo and C.Check or C.CheckOff
                b.btn.TextColor3 = ativo and Color3.fromRGB(255,255,255) or C.TextoFraco
            end
        end)
    end
end

-- ============================================================
-- MISC TAB
-- ============================================================
local desenharMisc

desenharMisc = function()
    criarSecao(leftScroll, "Movement")
    criarCheckbox(leftScroll, "Fly",           "Fly")
    criarCheckbox(leftScroll, "Noclip",        "Noclip")
    criarCheckbox(leftScroll, "Speed",         "Speed")
    criarCheckbox(leftScroll, "Infinite Jump", "InfiniteJump")
    criarCheckbox(leftScroll, "Vehicle Fly",   "VehicleFly")

    criarSlider(leftScroll, "Speed Value",     "SpeedVal",       16, 250, 32,
        function(v) return tostring(math.floor(v)) end)
    criarSlider(leftScroll, "Vehicle Speed",   "VehicleFlySpeed", 0.1, 5, 1.5,
        function(v) return string.format("%.1f", v) end)

    criarSecao(leftScroll, "Camera")
    criarCheckbox(leftScroll, "Freecam",     "Freecam")
    criarSlider(leftScroll, "Freecam Speed", "FreecamSpeed", 0.1, 5, 1,
        function(v) return string.format("%.1f", v) end)
    criarCheckbox(leftScroll, "Override FOV", "CameraFOVAtivo")
    criarSlider(leftScroll, "Camera FOV", "CameraFOV", 20, 120, 70,
        function(v) return tostring(math.floor(v)) end)

    criarSecao(rightScroll, "Binds (optional)")
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 26)
    info.BackgroundTransparency = 1
    info.Text = "Click the key to change, or Reset to clear."
    info.TextColor3 = C.TextoFraco
    info.Font = Enum.Font.Gotham
    info.TextSize = 10
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.TextWrapped = true
    info.ZIndex = 6
    info.Parent = rightScroll

    criarBindWidget(rightScroll, "Fly",           "Fly")
    criarBindWidget(rightScroll, "Noclip",        "Noclip")
    criarBindWidget(rightScroll, "Speed",         "Speed")
    criarBindWidget(rightScroll, "Freecam",       "Freecam")
    criarBindWidget(rightScroll, "Infinite Jump", "InfiniteJump")
    criarBindWidget(rightScroll, "Vehicle Fly",   "VehicleFly")
    criarBindWidget(rightScroll, "Hitbox Toggle", "Hitbox")
end

-- ============================================================
-- WORLD TAB
-- ============================================================
local function desenharWorld()
    criarSecao(leftScroll, "Lighting")
    criarCheckbox(leftScroll, "Full Bright", "FullBright", function(a)
        aplicarFullBright(a)
    end)

    criarSecao(leftScroll, "Remove")
    criarCheckbox(leftScroll, "Remove Bushes", "RemoverMoita", function(a)
        aplicarRemoverMoita(a)
    end)

    criarSecao(rightScroll, "FPS Optimizer")
    criarCheckbox(rightScroll, "Enable Optimizer", "OtimizadorFPS", function(a)
        aplicarOtimizadorFPS(a)
    end)
    criarCheckbox(rightScroll, "Remove Shadows",   "RemoverSombras", function(a)
        aplicarRemoverSombras(a)
    end)
    criarCheckbox(rightScroll, "Remove Effects",   "RemoverEfeitos", function(a)
        aplicarRemoverEfeitos(a)
    end)
    criarCheckbox(rightScroll, "Remove Particles","RemoverParticulas", function(a)
        aplicarRemoverParticulas(a)
    end)
    criarCheckbox(rightScroll, "Reduce Graphics",  "ReduzirGraficos", function(a)
        aplicarReduzirGraficos(a)
    end)
end

-- ============================================================
-- SETTINGS TAB
-- ============================================================
local function desenharSettings()
    criarSecao(leftScroll, "Menu Actions")
    criarBotao(leftScroll, "🗑️ Uninject Cheat", function()
        pcall(function() aplicarRemoverMoita(false) end)
        pcall(function() aplicarFullBright(false) end)
        pcall(function() aplicarRemoverSombras(false) end)
        pcall(function() aplicarRemoverEfeitos(false) end)
        pcall(function() aplicarRemoverParticulas(false) end)
        pcall(function() restaurarHitboxes() end)
        pcall(function()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and limparESP then limparESP(plr) end
            end
        end)
        pcall(function() liberarMouseAgora(999) end)
        pcall(function() screenGui:Destroy() end)
        print("[SYNTAX] Cheat uninjected.")
    end, C.BotaoVerm)

    criarSecao(leftScroll, "Rejoin")
    criarBotao(leftScroll, "🔄 Rejoin Server", function()
        local TS = game:GetService("TeleportService")
        pcall(function()
            if game.JobId and game.JobId ~= "" then
                TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            else
                TS:Teleport(game.PlaceId, LocalPlayer)
            end
        end)
    end, C.BotaoVerde)

    criarSecao(rightScroll, "About")
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 100)
    info.BackgroundTransparency = 1
    info.Text = "Syntax Menu v6.7\n\n" ..
                "Mode: " .. (ehDono and "OWNER" or "CLIENT") .. "\n" ..
                "Key: " .. (minhaKey and minhaKey:sub(1, 14) .. "..." or "—") .. "\n" ..
                "UserId: " .. tostring(LocalPlayer.UserId)
    info.TextColor3 = C.TextoFraco
    info.Font = Enum.Font.Gotham
    info.TextSize = 12
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.TextYAlignment = Enum.TextYAlignment.Top
    info.ZIndex = 6
    info.Parent = rightScroll
end

-- ============================================================
-- CREATE TABS
-- ============================================================
criarAba("Aimbot",   desenharAimbot)
criarAba("Visuals",  desenharVisuals)
criarAba("Misc",     desenharMisc)
criarAba("World",    desenharWorld)
criarAba("Settings", desenharSettings)
if ehDono then
    criarAba("KeyManager", desenharKeyManager, true)
end

-- ============================================================
-- DRAG WINDOW
-- ============================================================
local arrastando = false
local inicioMouse, inicioPos

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        arrastando = true
        inicioMouse = input.Position
        inicioPos = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not arrastando then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        local d = input.Position - inicioMouse
        main.Position = UDim2.new(
            inicioPos.X.Scale, inicioPos.X.Offset + d.X,
            inicioPos.Y.Scale, inicioPos.Y.Offset + d.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        arrastando = false
    end
end)

RunService.RenderStepped:Connect(function()
    if not minhaKey and main.Visible then
        main.Visible = false
    end
end)

-- ============================================================
-- MONITOR DE MOUSE (aplicação contínua, respeitando o jogo)
-- ============================================================
RunService.RenderStepped:Connect(function()
    if not minhaKey then return end
    if main.Visible then return end -- menu aberto = mouse sempre livre
    if opcoes.Aimbot and (aimbotSegurando or (opcoes.AimbotToggle and aimbotToggleAtivo)) then
        return -- aimbot controla o mouse, deixa ele
    end
    aplicarMouse(false)
end)

-- ============================================================
-- GLOBAL INPUT
-- ============================================================
UserInputService.InputBegan:Connect(function(input, processado)
    -- Detecta Tab (inventário do Roblox) ou "/" (chat) e libera o mouse por 2s
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.Tab
        or input.KeyCode == Enum.KeyCode.Slash then
            liberarMouseAgora(2)
        end
    end

    if aguardandoBind then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local kc = input.KeyCode
            if kc == Enum.KeyCode.Unknown then return end
            if kc == Enum.KeyCode.Escape then
                if _G._syntaxBindBtn and _G._syntaxBindChave then
                    _G._syntaxBindBtn.Text = "[" .. nomeBind(BINDS[_G._syntaxBindChave]) .. "]"
                    _G._syntaxBindBtn.BackgroundColor3 = (BINDS[_G._syntaxBindChave].Tipo == "None") and C.None or Color3.fromRGB(80, 60, 140)
                end
                aguardandoBind = nil
                _G._syntaxBindBtn = nil
                _G._syntaxBindChave = nil
                return
            end
            BINDS[aguardandoBind] = { Tipo = "Tecla", Tecla = kc }
            if _G._syntaxBindBtn then
                _G._syntaxBindBtn.Text = "[" .. nomeTecla(kc) .. "]"
                _G._syntaxBindBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 140)
            end
            aguardandoBind = nil
            _G._syntaxBindBtn = nil
            _G._syntaxBindChave = nil
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.MouseButton2
        or input.UserInputType == Enum.UserInputType.MouseButton3 then
            BINDS[aguardandoBind] = { Tipo = "Mouse", Botao = input.UserInputType }
            if _G._syntaxBindBtn then
                _G._syntaxBindBtn.Text = "[" .. nomeBind(BINDS[aguardandoBind]) .. "]"
                _G._syntaxBindBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 140)
            end
            aguardandoBind = nil
            _G._syntaxBindBtn = nil
            _G._syntaxBindChave = nil
            return
        end
        return
    end

    if aguardandoTeclaAimbot then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local kc = input.KeyCode
            if kc == Enum.KeyCode.Unknown then return end
            if kc == Enum.KeyCode.Escape then
                aguardandoTeclaAimbot = false
                if _G._syntaxRebindAimbot then
                    _G._syntaxRebindAimbot.btn.Text = nomeInputAimbot()
                    _G._syntaxRebindAimbot.btn.BackgroundColor3 = Color3.fromRGB(80, 60, 140)
                end
                _G._syntaxRebindAimbot = nil
                return
            end
            aimbotInput.Tipo = "Tecla"
            aimbotInput.Tecla = kc
            aguardandoTeclaAimbot = false
            if _G._syntaxRebindAimbot then
                _G._syntaxRebindAimbot.btn.Text = nomeInputAimbot()
                _G._syntaxRebindAimbot.btn.BackgroundColor3 = Color3.fromRGB(80, 60, 140)
            end
            _G._syntaxRebindAimbot = nil
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.MouseButton2
        or input.UserInputType == Enum.UserInputType.MouseButton3 then
            aimbotInput.Tipo = "Mouse"
            aimbotInput.Botao = input.UserInputType
            aguardandoTeclaAimbot = false
            if _G._syntaxRebindAimbot then
                _G._syntaxRebindAimbot.btn.Text = nomeInputAimbot()
                _G._syntaxRebindAimbot.btn.BackgroundColor3 = Color3.fromRGB(80, 60, 140)
            end
            _G._syntaxRebindAimbot = nil
            return
        end
        return
    end

    if processado then return end
    if digitandoNome then return end

    local bateuHold = false
    if aimbotInput.Tipo == "Mouse" then
        bateuHold = (input.UserInputType == aimbotInput.Botao)
    else
        bateuHold = (input.UserInputType == Enum.UserInputType.Keyboard)
                    and (input.KeyCode == aimbotInput.Tecla)
    end

    if bateuHold then
        if main.Visible and aimbotInput.Tipo == "Mouse" then
            local mpos = UserInputService:GetMouseLocation()
            local mabs = main.AbsolutePosition
            local msize = main.AbsoluteSize
            local dentro = mpos.X >= mabs.X and mpos.X <= mabs.X + msize.X
                       and mpos.Y >= mabs.Y and mpos.Y <= mabs.Y + msize.Y
            if dentro then return end
        end
        aimbotSegurando = true
        return
    end

    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    if input.KeyCode == teclas.Menu then
        if not minhaKey then return end
        if main.Visible then
            main.Visible = false
            liberarMouseAgora(0.5)
        else
            main.Visible = true
            liberarMouseAgora(999)
        end
        return
    end

    if input.KeyCode == teclas.Aimbot then
        if opcoes.AimbotToggle then
            aimbotToggleAtivo = not aimbotToggleAtivo
        end
        return
    end

    if opcoes.Aimbot and BINDS.LockTarget.Tipo == "Tecla"
    and input.KeyCode == BINDS.LockTarget.Tecla then
        if lockando then
            alvoLockado = nil
            lockando = false
        else
            local alvo = encontrarAlvoLock()
            if alvo then
                alvoLockado = alvo
                lockando = true
            end
        end
        return
    end

    for modulo, bind in pairs(BINDS) do
        if modulo ~= "LockTarget" and bind.Tipo == "Tecla" and input.KeyCode == bind.Tecla then
            if modulo == "Hitbox" then
                opcoes.HitboxEnabled = not opcoes.HitboxEnabled
            else
                opcoes[modulo] = not opcoes[modulo]
            end
            return
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if aimbotInput.Tipo == "Mouse" then
        if input.UserInputType == aimbotInput.Botao then
            aimbotSegurando = false
        end
    else
        if input.UserInputType == Enum.UserInputType.Keyboard
        and input.KeyCode == aimbotInput.Tecla then
            aimbotSegurando = false
        end
    end
end)

-- ============================================================
-- ESP
-- ============================================================
local OssosR15 = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local OssosR6 = {
    {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},
    {"Torso","Left Leg"},{"Torso","Right Leg"},
}

local dadosESP = {}

local function corDoTime(plr)
    if plr.Team then return plr.Team.TeamColor.Color end
    return Color3.fromRGB(255, 80, 80)
end

local function mesmoTime(plr)
    if not opcoes.VerificarTime then return false end
    if not LocalPlayer.Team or not plr.Team then return false end
    return LocalPlayer.Team == plr.Team
end

local function criarESP(plr)
    if plr == LocalPlayer then return end
    if dadosESP[plr] then return end
    dadosESP[plr] = { linhas = {} }
end

function limparESP(plr)
    local dados = dadosESP[plr]
    if not dados then return end
    for _, l in pairs(dados.linhas) do if l then pcall(function() l:Remove() end) end end
    for _, k in ipairs({"billboard","caixa","cabeca","cabecaPonto","barraVidaBorda","barraVidaFundo","barraVidaFill","tracer"}) do
        if dados[k] then pcall(function() dados[k]:Remove() end) end
    end
    local char = plr.Character
    if char and char:FindFirstChild("ESP_Highlight") then char.ESP_Highlight:Destroy() end
    dadosESP[plr] = nil
end

local function checarVisivel(char)
    if not char then return false end
    local camera = workspace.CurrentCamera
    local origem = camera.CFrame.Position
    local head = char:FindFirstChild("Head")
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local alvo = head or hrp
    if not alvo then return false end
    local direcao = alvo.Position - origem
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, camera}
    params.IgnoreWater = true
    local resultado = workspace:Raycast(origem, direcao, params)
    if not resultado then return true end
    return resultado.Instance and resultado.Instance:IsDescendantOf(char)
end

local ultimoRaycast = {}
local cacheVisivel = {}
local INTERVALO_RAYCAST = 0.15

RunService.RenderStepped:Connect(function(dt)
    local mostrarAlgo = opcoes.ESP_Nome or opcoes.ESP_Distancia or opcoes.ESP_Vida
                    or opcoes.ESP_BarraVida or opcoes.ESP_Caixa or opcoes.ESP_Cabeca
                    or opcoes.ESP_Esqueleto or opcoes.ESP_Chams or opcoes.ESP_Tracer
                    or opcoes.ESP_Visible

    local agora = tick()
    local camera = workspace.CurrentCamera
    local localChar = LocalPlayer.Character
    local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")
    local maxDist = opcoes.LimiteAtivo and opcoes.LimiteDist or math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChild("Humanoid")

        if not char or not hrp or not hum or hum.Health <= 0 then
            if dadosESP[plr] then limparESP(plr) end
            ultimoRaycast[plr] = nil
            cacheVisivel[plr] = nil
            continue
        end

        if opcoes.VerificarTime and mesmoTime(plr) then
            if dadosESP[plr] then limparESP(plr) end
            continue
        end

        if localHRP and maxDist ~= math.huge then
            local dist = (hrp.Position - localHRP.Position).Magnitude
            if dist > maxDist then
                if dadosESP[plr] then limparESP(plr) end
                continue
            end
        end

        if not mostrarAlgo then
            if dadosESP[plr] then limparESP(plr) end
            continue
        end

        if not dadosESP[plr] then criarESP(plr) end
        local dados = dadosESP[plr]
        if not dados then continue end

        if opcoes.ESP_Visible or opcoes.ESP_Chams then
            local ultimo = ultimoRaycast[plr] or 0
            if agora - ultimo >= INTERVALO_RAYCAST then
                cacheVisivel[plr] = checarVisivel(char)
                ultimoRaycast[plr] = agora
            end
        end

        local visivel = cacheVisivel[plr] or false
        local corTime = corDoTime(plr)
        if alvoLockado == plr then corTime = C.Dourado
        elseif visivel and opcoes.ESP_Visible then corTime = C.Verde end

        local desenhaAlgo = opcoes.ESP_Esqueleto or opcoes.ESP_Cabeca
                        or opcoes.ESP_Nome or opcoes.ESP_Distancia
                        or opcoes.ESP_Vida or opcoes.ESP_Visible
                        or opcoes.ESP_Caixa or opcoes.ESP_BarraVida
                        or opcoes.ESP_Tracer or opcoes.ESP_Chams

        if not desenhaAlgo then
            if dados.billboard then dados.billboard.Enabled = false end
            continue
        end

        local cabeca = char:FindFirstChild("Head")
        local posCabeca = cabeca and cabeca.Position
        local naTela = false
        if posCabeca then
            local _, vis = camera:WorldToViewportPoint(posCabeca)
            naTela = vis
        end

        if not naTela and not opcoes.ESP_Tracer then
            if dados.billboard then dados.billboard.Enabled = false end
            if dados.caixa then dados.caixa.Visible = false end
            if dados.cabeca then dados.cabeca.Visible = false end
            for _, l in pairs(dados.linhas) do if l then l.Visible = false end end
            if dados.barraVidaBorda then dados.barraVidaBorda.Visible = false end
            if dados.barraVidaFundo then dados.barraVidaFundo.Visible = false end
            if dados.barraVidaFill  then dados.barraVidaFill.Visible  = false end
            if dados.tracer then dados.tracer.Visible = false end
            continue
        end

        -- SKELETON
        if opcoes.ESP_Esqueleto then
            local lista = char:FindFirstChild("UpperTorso") and OssosR15 or OssosR6
            local i = 1
            for _, osso in ipairs(lista) do
                local p1 = char:FindFirstChild(osso[1])
                local p2 = char:FindFirstChild(osso[2])
                if p1 and p2 then
                    local s1,on1 = camera:WorldToViewportPoint(p1.Position)
                    local s2,on2 = camera:WorldToViewportPoint(p2.Position)
                    if not dados.linhas[i] then dados.linhas[i] = Drawing.new("Line") end
                    local l = dados.linhas[i]
                    if on1 and on2 then
                        l.Visible = true
                        l.From = Vector2.new(s1.X, s1.Y)
                        l.To   = Vector2.new(s2.X, s2.Y)
                        l.Color = corTime
                        l.Thickness = 1.5
                    else
                        l.Visible = false
                    end
                    i = i + 1
                end
            end
            for k = i, #dados.linhas do
                if dados.linhas[k] then dados.linhas[k].Visible = false end
            end
        else
            for _, l in pairs(dados.linhas) do if l then l.Visible = false end end
        end

        -- HEAD CIRCLE
        if opcoes.ESP_Cabeca and cabeca then
            local posC = cabeca.Position
            local tamC = cabeca.Size
            local cTopo = posC + Vector3.new(0, tamC.Y/2, 0)
            local cBase = posC - Vector3.new(0, tamC.Y/2, 0)
            local tTopo, onT = camera:WorldToViewportPoint(cTopo)
            local tBase, onB = camera:WorldToViewportPoint(cBase)
            local tCentro, onC = camera:WorldToViewportPoint(posC)
            if onT and onB and onC then
                local raio = math.abs(tBase.Y - tTopo.Y) / 2
                if not dados.cabeca then
                    dados.cabeca = Drawing.new("Circle")
                    dados.cabeca.Thickness = 1.5
                    dados.cabeca.Filled = false
                    dados.cabeca.NumSides = 24
                end
                dados.cabeca.Visible = true
                dados.cabeca.Radius = raio
                dados.cabeca.Position = Vector2.new(tCentro.X, tCentro.Y)
                dados.cabeca.Color = corTime
            elseif dados.cabeca then
                dados.cabeca.Visible = false
            end
        elseif dados.cabeca then
            dados.cabeca.Visible = false
        end

        -- TEXTO
        if cabeca then
            local textos = {}
            if alvoLockado == plr then table.insert(textos, "🔒") end
            if opcoes.ESP_Nome then table.insert(textos, plr.Name) end
            if opcoes.ESP_Distancia and localHRP then
                local d = math.floor((hrp.Position - localHRP.Position).Magnitude)
                table.insert(textos, "[" .. d .. "m]")
            end
            if opcoes.ESP_Vida then table.insert(textos, "HP " .. math.floor(hum.Health)) end
            if opcoes.ESP_Visible then
                table.insert(textos, "Visible: " .. (visivel and "Yes" or "No"))
            end
            local textoFinal = table.concat(textos, "  ")
            if #textos > 0 then
                if not dados.billboard then
                    local bb = Instance.new("BillboardGui")
                    bb.Size = UDim2.new(0, 260, 0, 20)
                    bb.AlwaysOnTop = true
                    bb.Parent = cabeca
                    local l = Instance.new("TextLabel")
                    l.Size = UDim2.new(1, 0, 1, 0)
                    l.BackgroundTransparency = 1
                    l.Font = Enum.Font.GothamBold
                    l.TextStrokeTransparency = 0
                    l.TextStrokeColor3 = Color3.fromRGB(0,0,0)
                    l.Parent = bb
                    dados.billboard = bb
                    dados.label = l
                end
                dados.label.TextSize = opcoes.ESP_NomeSize
                dados.billboard.StudsOffset = Vector3.new(0, opcoes.ESP_StudsOffset, 0)
                dados.label.Text = textoFinal
                dados.label.TextColor3 = corTime
                dados.billboard.Enabled = naTela
            elseif dados.billboard then
                dados.billboard.Enabled = false
            end
        end

        -- BOX 2D
        if opcoes.ESP_Caixa then
            local posHRP = hrp.Position
            local tam = hrp.Size
            local posTopo = posHRP + Vector3.new(0, tam.Y/2 + 3, 0)
            local posBase = posHRP - Vector3.new(0, tam.Y/2 + 3, 0)
            local tTopo, onT = camera:WorldToViewportPoint(posTopo)
            local tBase, onB = camera:WorldToViewportPoint(posBase)
            if onT and onB then
                local alturaBase = math.abs(tBase.Y - tTopo.Y)
                local altura  = alturaBase * (opcoes.ESP_CaixaHeight / 100)
                local largura = altura * (opcoes.ESP_CaixaWidth / 100)
                local x = tTopo.X - largura / 2
                local y = tTopo.Y
                if not dados.caixa then
                    dados.caixa = Drawing.new("Square")
                    dados.caixa.Thickness = 1
                    dados.caixa.Filled = false
                end
                dados.caixa.Visible = true
                dados.caixa.Size = Vector2.new(largura, altura)
                dados.caixa.Position = Vector2.new(x, y)
                dados.caixa.Color = corTime
            elseif dados.caixa then
                dados.caixa.Visible = false
            end
        elseif dados.caixa then
            dados.caixa.Visible = false
        end

        -- HEALTH BAR
        if opcoes.ESP_BarraVida then
            local posHRP = hrp.Position
            local tam = hrp.Size
            local posTopo = posHRP + Vector3.new(0, tam.Y/2 + 3, 0)
            local posBase = posHRP - Vector3.new(0, tam.Y/2 + 3, 0)
            local tTopo, onT = camera:WorldToViewportPoint(posTopo)
            local tBase, onB = camera:WorldToViewportPoint(posBase)
            if onT and onB then
                local altura  = math.abs(tBase.Y - tTopo.Y)
                local largura = 3
                local larguraCaixa = altura * (opcoes.ESP_CaixaWidth / 100)
                local x = tTopo.X + larguraCaixa / 2 + 5
                local y = tTopo.Y
                if not dados.barraVidaBorda then
                    dados.barraVidaBorda = Drawing.new("Square")
                    dados.barraVidaBorda.Filled = true
                    dados.barraVidaBorda.Color = Color3.fromRGB(0, 0, 0)
                end
                if not dados.barraVidaFundo then
                    dados.barraVidaFundo = Drawing.new("Square")
                    dados.barraVidaFundo.Filled = true
                    dados.barraVidaFundo.Color = Color3.fromRGB(30, 30, 35)
                end
                if not dados.barraVidaFill then
                    dados.barraVidaFill = Drawing.new("Square")
                    dados.barraVidaFill.Filled = true
                end
                local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                local hP = altura * pct
                dados.barraVidaBorda.Visible = true
                dados.barraVidaBorda.Size = Vector2.new(largura + 2, altura + 2)
                dados.barraVidaBorda.Position = Vector2.new(x - 1, y - 1)
                dados.barraVidaFundo.Visible = true
                dados.barraVidaFundo.Size = Vector2.new(largura, altura)
                dados.barraVidaFundo.Position = Vector2.new(x, y)
                dados.barraVidaFill.Visible = true
                dados.barraVidaFill.Size = Vector2.new(largura, hP)
                dados.barraVidaFill.Position = Vector2.new(x, y + (altura - hP))
                if pct > 0.5 then dados.barraVidaFill.Color = Color3.fromRGB(60, 220, 80)
                elseif pct > 0.25 then dados.barraVidaFill.Color = Color3.fromRGB(240, 200, 30)
                else dados.barraVidaFill.Color = Color3.fromRGB(255, 60, 60) end
            else
                if dados.barraVidaBorda then dados.barraVidaBorda.Visible = false end
                if dados.barraVidaFundo then dados.barraVidaFundo.Visible = false end
                if dados.barraVidaFill  then dados.barraVidaFill.Visible  = false end
            end
        else
            if dados.barraVidaBorda then dados.barraVidaBorda.Visible = false end
            if dados.barraVidaFundo then dados.barraVidaFundo.Visible = false end
            if dados.barraVidaFill  then dados.barraVidaFill.Visible  = false end
        end

        -- TRACER
        if opcoes.ESP_Tracer then
            local posPe = hrp.Position - Vector3.new(0, 3, 0)
            local telaPe, onPe = camera:WorldToViewportPoint(posPe)
            if not dados.tracer then
                dados.tracer = Drawing.new("Line")
                dados.tracer.Thickness = 1
                dados.tracer.Transparency = 0.7
            end
            if onPe then
                dados.tracer.Visible = true
                dados.tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                dados.tracer.To = Vector2.new(telaPe.X, telaPe.Y)
                dados.tracer.Color = corTime
            else
                dados.tracer.Visible = false
            end
        elseif dados.tracer then
            dados.tracer.Visible = false
        end

        -- CHAMS
        if opcoes.ESP_Chams then
            if not char:FindFirstChild("ESP_Highlight") then
                local hl = Instance.new("Highlight")
                hl.Name = "ESP_Highlight"
                hl.Adornee = char
                hl.FillColor = corTime
                hl.FillTransparency = 0.6
                hl.OutlineColor = corTime
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = char
            else
                local hl = char.ESP_Highlight
                hl.FillColor = corTime
                hl.OutlineColor = corTime
            end
        else
            if char and char:FindFirstChild("ESP_Highlight") then
                char.ESP_Highlight:Destroy()
            end
        end
    end
end)

-- ============================================================
-- AIMBOT LOOP
-- ============================================================
local aimbotMaxDist = 1500

local function resolverOsso(char, nome)
    if not char then return nil end
    if nome == "Head" then return char:FindFirstChild("Head")
    elseif nome == "Neck" then
        local head = char:FindFirstChild("Head")
        local ut = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        if head and ut then return head, (head.Position + ut.Position) / 2 end
        return head
    elseif nome == "Chest" then return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    elseif nome == "Pelvis" then return char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso")
    end
    return char:FindFirstChild("Head")
end

function obterPosicaoAlvo(plr)
    local char = plr.Character
    if not char then return nil end
    local osso, virtualPos = resolverOsso(char, opcoes.TargetBone or "Head")
    local basePos = virtualPos or (osso and osso.Position)
    if not basePos then return nil end
    if not opcoes.Predict then return basePos end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return basePos end
    local vel = hrp.AssemblyLinearVelocity
    if not vel or vel.Magnitude < 0.01 then vel = hrp.Velocity end
    if not vel then return basePos end
    local fH = opcoes.PredictVal or 0.15
    return basePos + Vector3.new(vel.X * fH, 0, vel.Z * fH)
end

local function estaVisivel(char)
    if not opcoes.VisibleCheck then return true end
    if not char then return false end
    local camera = workspace.CurrentCamera
    local origem = camera.CFrame.Position
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    local alvo = head or hrp
    if not alvo then return false end
    local direcao = alvo.Position - origem
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, camera}
    params.IgnoreWater = true
    local resultado = workspace:Raycast(origem, direcao, params)
    if not resultado then return true end
    return resultado.Instance and resultado.Instance:IsDescendantOf(char)
end

local function jogadorValido(plr)
    if not plr or plr == LocalPlayer then return false end
    local char = plr.Character
    if not char then return false end
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return false end
    if hum.Health <= 0 then return false end
    if opcoes.VerificarTime and mesmoTime(plr) then return false end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local dist = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        if dist > aimbotMaxDist then return false end
    end
    return true
end

function encontrarAlvoLock()
    local camera = workspace.CurrentCamera
    local referencia
    if opcoes.AimMode == "Mouse Free" then
        local mp = UserInputService:GetMouseLocation()
        referencia = Vector2.new(mp.X, mp.Y)
    else
        referencia = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    end
    local melhor, melhorDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if jogadorValido(plr) then
            local posAlvo = obterPosicaoAlvo(plr)
            if posAlvo then
                local posTela, onScreen = camera:WorldToViewportPoint(posAlvo)
                if onScreen then
                    local d = (Vector2.new(posTela.X, posTela.Y) - referencia).Magnitude
                    if d < opcoes.AimFOV and d < melhorDist then
                        melhorDist = d
                        melhor = plr
                    end
                end
            end
        end
    end
    return melhor
end

local function encontrarAlvo()
    local camera = workspace.CurrentCamera
    local referencia
    if opcoes.AimMode == "Mouse Free" then
        local mp = UserInputService:GetMouseLocation()
        referencia = Vector2.new(mp.X, mp.Y)
    else
        referencia = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    end
    local melhor, melhorDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if jogadorValido(plr) then
            local posAlvo = obterPosicaoAlvo(plr)
            if posAlvo then
                local posTela, onScreen = camera:WorldToViewportPoint(posAlvo)
                if onScreen then
                    local d = (Vector2.new(posTela.X, posTela.Y) - referencia).Magnitude
                    if d < opcoes.AimFOV and d < melhorDist then
                        if estaVisivel(plr.Character) then
                            melhorDist = d
                            melhor = plr
                        end
                    end
                end
            end
        end
    end
    return melhor
end

RunService.RenderStepped:Connect(function(dt)
    if not opcoes.Aimbot then
        if lockando then alvoLockado = nil; lockando = false end
        return
    end
    local ativo = aimbotSegurando or (opcoes.AimbotToggle and aimbotToggleAtivo)
    if not ativo then return end

    local alvo
    if lockando and alvoLockado and alvoLockado.Parent and jogadorValido(alvoLockado) then
        alvo = alvoLockado
    elseif lockando and alvoLockado and not jogadorValido(alvoLockado) then
        alvoLockado = nil
        lockando = false
        alvo = encontrarAlvo()
    else
        alvo = encontrarAlvo()
    end

    if not alvo then return end
    local posAlvo = obterPosicaoAlvo(alvo)
    if not posAlvo then return end

    local camera = workspace.CurrentCamera
    local novaCF = CFrame.new(camera.CFrame.Position, posAlvo)

    if opcoes.AimMode == "Mouse Free" then
        pcall(function()
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true
        end)
        if opcoes.Smoothing then
            local alpha = math.clamp((1.0 / math.max(opcoes.Smoothness, 0.01)) * (dt * 60) * 0.08, 0.02, 1)
            camera.CFrame = camera.CFrame:Lerp(novaCF, alpha)
        end
    else
        pcall(function()
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            UserInputService.MouseIconEnabled = false
        end)
        if opcoes.Smoothing then
            local alpha = math.clamp((1.0 / math.max(opcoes.Smoothness, 0.01)) * (dt * 60) * 0.15, 0.05, 1)
            camera.CFrame = camera.CFrame:Lerp(novaCF, alpha)
        else
            camera.CFrame = novaCF
        end
    end
end)

-- ============================================================
-- FOV CIRCLE — funciona em 1ª pessoa (centro da tela)
-- ============================================================
local fovCircle = Drawing and Drawing.new("Circle")
if fovCircle then
    fovCircle.Thickness = 1
    fovCircle.Filled = false
    fovCircle.NumSides = 64
    fovCircle.Color = Color3.fromRGB(180, 130, 255)
    fovCircle.Visible = false
end

RunService.RenderStepped:Connect(function()
    if not fovCircle then return end
    if not opcoes.DrawFOV then
        fovCircle.Visible = false
        return
    end
    if main.Visible then
        fovCircle.Visible = false
        return
    end

    local camera = workspace.CurrentCamera
    if not camera then
        fovCircle.Visible = false
        return
    end

    local centro = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local travado = (UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter)

    if travado then
        fovCircle.Position = centro
    else
        local mp = UserInputService:GetMouseLocation()
        fovCircle.Position = Vector2.new(mp.X, mp.Y)
    end
    fovCircle.Radius = opcoes.AimFOV
    fovCircle.Visible = true
end)

-- ============================================================
-- FLY / NOCLIP / SPEED / INFJUMP / VEHICLE FLY / FREECAM
-- ============================================================
local voando = false
local flyGyro, flyVel

local function pararFly()
    voando = false
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if flyGyro then flyGyro:Destroy(); flyGyro = nil end
    if flyVel then flyVel:Destroy(); flyVel = nil end
    if hum then hum.PlatformStand = false end
end

local function iniciarFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    voando = true
    hum.PlatformStand = true
    flyGyro = Instance.new("BodyGyro")
    flyGyro.P = 9e4
    flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyGyro.CFrame = hrp.CFrame
    flyGyro.Parent = hrp
    flyVel = Instance.new("BodyVelocity")
    flyVel.Velocity = Vector3.new(0, 0, 0)
    flyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyVel.P = 1250
    flyVel.Parent = hrp
end

local veiculoVoando = false
local vehGyro, vehVel

local function pararVehicleFly()
    veiculoVoando = false
    if vehGyro then vehGyro:Destroy(); vehGyro = nil end
    if vehVel  then vehVel:Destroy();  vehVel  = nil end
end

local function iniciarVehicleFly(veh)
    if not veh then return end
    local prim = veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
    if not prim then return end
    veiculoVoando = true
    vehGyro = Instance.new("BodyGyro")
    vehGyro.P = 9e4
    vehGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    vehGyro.CFrame = prim.CFrame
    vehGyro.Parent = prim
    vehVel = Instance.new("BodyVelocity")
    vehVel.Velocity = Vector3.new(0, 0, 0)
    vehVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    vehVel.P = 1250
    vehVel.Parent = prim
end

local freecamAtiva   = false
local freecamCFrame  = nil
local freecamYaw     = 0
local freecamPitch   = 0
local oldCameraType  = nil
local oldCameraSubj  = nil

local function iniciarFreecam()
    local cam = workspace.CurrentCamera
    if not cam then return end
    freecamAtiva  = true
    freecamCFrame = cam.CFrame
    freecamYaw    = 0
    freecamPitch  = 0
    oldCameraType = cam.CameraType
    oldCameraSubj = cam.CameraSubject
    cam.CameraType = Enum.CameraType.Scriptable
    cam.CameraSubject = nil
end

local function pararFreecam()
    freecamAtiva = false
    local cam = workspace.CurrentCamera
    if not cam then return end
    pcall(function()
        cam.CameraType = oldCameraType or Enum.CameraType.Custom
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        cam.CameraSubject = oldCameraSubj or hum
    end)
    oldCameraType = nil
    oldCameraSubj = nil
end

UserInputService.InputChanged:Connect(function(input, processado)
    if not freecamAtiva then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        freecamYaw   = freecamYaw   - input.Delta.X * 0.15
        freecamPitch = math.clamp(freecamPitch - input.Delta.Y * 0.15, -85, 85)
    end
end)

RunService.RenderStepped:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if opcoes.Fly then
        if not voando then iniciarFly() end
        if flyGyro and flyVel then
            local cam = workspace.CurrentCamera
            local direcao = Vector3.new(0, 0, 0)
            local vel = 50
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direcao = direcao + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direcao = direcao - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direcao = direcao - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direcao = direcao + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direcao = direcao + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direcao = direcao - Vector3.new(0, 1, 0) end
            flyVel.Velocity = direcao * vel
            flyGyro.CFrame = cam.CFrame
        end
    else
        if voando then pararFly() end
    end

    if opcoes.VehicleFly then
        local seat = hum.SeatPart
        if seat then
            local veiculo = seat.Parent
            local prim = veiculo and (veiculo.PrimaryPart or veiculo:FindFirstChildWhichIsA("BasePart"))
            if prim then
                if not veiculoVoando then iniciarVehicleFly(veiculo) end
                if vehGyro and vehVel then
                    local cam = workspace.CurrentCamera
                    local direcao = Vector3.new(0, 0, 0)
                    local vel = (opcoes.VehicleFlySpeed or 1.5) * 32
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then direcao = direcao + cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then direcao = direcao - cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then direcao = direcao - cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then direcao = direcao + cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direcao = direcao + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direcao = direcao - Vector3.new(0, 1, 0) end
                    vehVel.Velocity = direcao * vel
                    vehGyro.CFrame = CFrame.new(prim.Position, prim.Position + cam.CFrame.LookVector)
                end
            end
        else
            if veiculoVoando then pararVehicleFly() end
        end
    else
        if veiculoVoando then pararVehicleFly() end
    end

    if opcoes.Noclip and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    if opcoes.Speed then
        if hum.WalkSpeed ~= opcoes.SpeedVal then hum.WalkSpeed = opcoes.SpeedVal end
    else
        if hum.WalkSpeed ~= 16 and hum.WalkSpeed == opcoes.SpeedVal then hum.WalkSpeed = 16 end
    end

    if opcoes.InfiniteJump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end

    if opcoes.Freecam then
        if not freecamAtiva then iniciarFreecam() end
        if freecamCFrame then
            local cam = workspace.CurrentCamera
            local vel = (opcoes.FreecamSpeed or 1) * 60 * dt
            local move = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
            local base = CFrame.new(freecamCFrame.Position + move * vel)
            local rot = CFrame.fromEulerAnglesYXZ(
                math.rad(freecamPitch),
                math.rad(freecamYaw),
                0
            )
            freecamCFrame = base * rot
            cam.CFrame = freecamCFrame
        end
    else
        if freecamAtiva then pararFreecam() end
    end
end)

local fovOriginal = nil
RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    if not cam then return end
    if opcoes.CameraFOVAtivo then
        if fovOriginal == nil then fovOriginal = cam.FieldOfView end
        local alvo = math.clamp(opcoes.CameraFOV, 1, 120)
        if math.abs(cam.FieldOfView - alvo) > 0.1 then cam.FieldOfView = alvo end
    else
        if fovOriginal ~= nil then
            cam.FieldOfView = fovOriginal
            fovOriginal = nil
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    voando = false
    flyGyro, flyVel = nil, nil
    veiculoVoando = false
    vehGyro, vehVel = nil, nil
    freecamAtiva = false
    alvoLockado = nil
    lockando = false
    task.wait(0.5)
    if opcoes.Noclip then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- ============================================================
-- KEY TIMER + KICK ON EXPIRE
-- ============================================================
local function kickarPorExpiracao()
    if jaKickado then return end
    jaKickado = true

    pcall(function()
        if screenGui and screenGui.Parent then
            local aviso = Instance.new("Frame")
            aviso.Size = UDim2.new(0, 400, 0, 150)
            aviso.Position = UDim2.new(0.5, -200, 0.5, -75)
            aviso.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
            aviso.BorderSizePixel = 0
            aviso.ZIndex = 300
            aviso.Parent = screenGui

            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 8)
            c.Parent = aviso

            local s = Instance.new("UIStroke")
            s.Color = Color3.fromRGB(255, 60, 60)
            s.Thickness = 2
            s.Parent = aviso

            local t = Instance.new("TextLabel")
            t.Size = UDim2.new(1, -20, 0, 40)
            t.Position = UDim2.new(0, 10, 0, 20)
            t.BackgroundTransparency = 1
            t.Text = "⛔ KEY EXPIRED"
            t.TextColor3 = Color3.fromRGB(255, 80, 80)
            t.Font = Enum.Font.GothamBold
            t.TextSize = 22
            t.ZIndex = 301
            t.Parent = aviso

            local sub = Instance.new("TextLabel")
            sub.Size = UDim2.new(1, -20, 0, 50)
            sub.Position = UDim2.new(0, 10, 0, 65)
            sub.BackgroundTransparency = 1
            sub.Text = "Your key has expired.\nJoin the Discord to renew it."
            sub.TextColor3 = Color3.fromRGB(200, 200, 200)
            sub.Font = Enum.Font.Gotham
            sub.TextSize = 14
            sub.TextWrapped = true
            sub.ZIndex = 301
            sub.Parent = aviso
        end
    end)

    task.wait(3)

    pcall(function()
        if screenGui and screenGui.Parent then
            screenGui:Destroy()
        end
    end)

    pcall(function()
        LocalPlayer:Kick("⛔ Your key has expired. Join the Discord to renew: " .. DISCORD_LINK)
    end)

    task.wait(0.5)
    pcall(function()
        LocalPlayer.Character:BreakJoints()
        game:GetService("Players").LocalPlayer:Kick("KEY EXPIRED")
    end)
end

task.spawn(function()
    while task.wait(1) do
        if minhaKey and not jaKickado then
            if LocalPlayer.UserId == DONO.UserId then
                keyInfoLabel.Text = "KEY: DONO ♾️"
                keyInfoLabel.TextColor3 = C.Dourado
            elseif minhaExpiracao >= 99999 * 86400 then
                keyInfoLabel.Text = "KEY: LIFETIME ♾️"
                keyInfoLabel.TextColor3 = C.Dourado
            elseif minhaExpiracao > 0 then
                local resto = minhaExpiracao - os.time()
                if resto <= 0 then
                    keyInfoLabel.Text = "EXPIRED"
                    keyInfoLabel.TextColor3 = C.Vermelho
                    kickarPorExpiracao()
                else
                    keyInfoLabel.Text = "KEY: " .. formatarTempo(resto)
                    if resto < 3600 then
                        keyInfoLabel.TextColor3 = C.Vermelho
                    elseif resto < 86400 then
                        keyInfoLabel.TextColor3 = C.Laranja
                    else
                        keyInfoLabel.TextColor3 = C.Dourado
                    end
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    limparESP(plr)
    ultimoRaycast[plr] = nil
    cacheVisivel[plr] = nil
    if alvoLockado == plr then
        alvoLockado = nil
        lockando = false
    end
end)

-- ============================================================
-- LOGIN
-- ============================================================
local funcaoLiberarMenu

local function handlerValidarKey()
    local digitada = kgInput.Text
    if not digitada or #digitada == 0 then
        kgStatus.Text = "Enter a key."
        return
    end
    local ok, msg, expira = validarKeyInterna(digitada, LocalPlayer.UserId)
    if ok then
        jaKickado = false
        minhaKey = digitada
        minhaExpiracao = expira or 0
        kgStatus.TextColor3 = Color3.fromRGB(120, 220, 120)
        if digitada == DONO.KeyMestra then
            kgStatus.Text = "Welcome, OWNER! Opening menu..."
        else
            kgStatus.Text = "Key valid! Time: " .. msg
        end
        task.wait(0.8)
        keyGui:Destroy()
        main.Visible = true
        liberarMouseAgora(999)
        if funcaoLiberarMenu then funcaoLiberarMenu() end
    else
        kgStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
        kgStatus.Text = "❌ " .. msg
        kgInput.Text = ""
    end
end

kgBtn.MouseButton1Click:Connect(handlerValidarKey)
kgInput.FocusLost:Connect(function(enter) if enter then handlerValidarKey() end end)

task.spawn(function()
    task.wait(0.3)
    local keySalva, expira = tentarLoginAutomatico(LocalPlayer.UserId)
    if keySalva then
        minhaKey = keySalva
        minhaExpiracao = expira or 0
        if keyGui and keyGui.Parent then keyGui:Destroy() end
        main.Visible = true
        liberarMouseAgora(999)
        if funcaoLiberarMenu then funcaoLiberarMenu() end
    end
end)

funcaoLiberarMenu = function()
    if not abaAtual then
        if abas["Aimbot"] then
            abas["Aimbot"].btn.TextColor3 = C.AbaAtivaTxt
            abas["Aimbot"].bar.Size = UDim2.new(1, 0, 0, 2)
            abaAtual = "Aimbot"
            limparColunas()
            desenharAimbot()
        end
    end
end

print("✅ Syntax Menu v6.7 loaded!")
print("  Owner: NICOINFERNALX | UserId: 9375423697")
print("  INSERT = menu | B = aimbot toggle")
print("  Tab abre inventário sem sumir o mouse")
print("  FOV funciona em 1ª pessoa")
