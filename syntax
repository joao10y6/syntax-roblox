-- ============================================================
-- SYNTAX MENU v6.7
-- Hitbox Expander + ESP Visible + Lock + Kick + Binds
-- ============================================================

-- ============================================================
-- DONO CONFIG
-- ============================================================

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
    modoH
