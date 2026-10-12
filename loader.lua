-- ============================================================
-- SYNTAX MENU v6.8 — LOADER
-- Dono: NICOINFERNALX (UserId: 9375423697)
-- Baixa e executa o menu do GitHub
-- ============================================================

local GITHUB_USER   = "joao10y6"
local GITHUB_REPO   = "syntax-roblox"
local GITHUB_BRANCH = "main"          -- troque para "master" se o seu repo usar master
local ARQUIVO_MENU  = "syntax.lua"    -- nome do arquivo que contém o MENU

-- ============================================================
-- ESPERA O LOCALPLAYER CARREGAR (correção para contas novas)
-- ============================================================
local Players = game:GetService("Players")
local tentativas = 0
while not Players.LocalPlayer and tentativas < 100 do
    task.wait(0.1)
    tentativas = tentativas + 1
end

if not Players.LocalPlayer then
    warn("[SYNTAX] ❌ LocalPlayer não carregou. Reinicie o jogo.")
    return
end

-- ============================================================
-- MONTA A URL
-- ============================================================
local URL = string.format(
    "https://raw.githubusercontent.com/%s/%s/%s/%s",
    GITHUB_USER, GITHUB_REPO, GITHUB_BRANCH, ARQUIVO_MENU
)

-- ============================================================
-- HttpGet compatível com vários executores
-- ============================================================
local function httpGet(url)
    if game.HttpGet then
        local ok, res = pcall(function() return game:HttpGet(url, true) end)
        if ok and res and #res > 0 then return res end
    end
    if syn and syn.request then
        local ok, res = pcall(function()
            return syn.request({ Url = url, Method = "GET" }).Body
        end)
        if ok and res and #res > 0 then return res end
    end
    if http_request then
        local ok, res = pcall(function()
            return http_request({ Url = url, Method = "GET" }).Body
        end)
        if ok and res and #res > 0 then return res end
    end
    if request then
        local ok, res = pcall(function()
            return request({ Url = url, Method = "GET" }).Body
        end)
        if ok and res and #res > 0 then return res end
    end
    if fluxus and fluxus.request then
        local ok, res = pcall(function()
            return fluxus.request({ Url = url, Method = "GET" }).Body
        end)
        if ok and res and #res > 0 then return res end
    end
    return nil
end

-- ============================================================
-- BAIXA E EXECUTA O MENU
-- ============================================================
print("[SYNTAX] Baixando menu de: " .. URL)

local conteudo = httpGet(URL)
if not conteudo or #conteudo < 50 then
    warn("[SYNTAX] ❌ Não foi possível baixar o menu. Verifique sua internet ou o link do GitHub.")
    return
end

-- Se por engano o arquivo for o próprio loader, avisa
if conteudo:find("SYNTAX MENU v6.8 — LOADER") and conteudo:find("local GITHUB_REPO") then
    warn("[SYNTAX] ⚠️ O arquivo baixado é o LOADER, não o MENU.")
    return
end

local chunk, err = loadstring(conteudo, "@syntax.lua")
if not chunk then
    warn("[SYNTAX] ❌ Erro de sintaxe ao carregar: " .. tostring(err))
    return
end

local ok, execErr = pcall(chunk)
if not ok then
    warn("[SYNTAX] ❌ Erro ao executar: " .. tostring(execErr))
    return
end

print("[SYNTAX] ✅ Menu carregado com sucesso. Use INSERT para abrir.")
