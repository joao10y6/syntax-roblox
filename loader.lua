-- ============================================================
-- SYNTAX MENU v6.8 — LOADER
-- Baixa e executa o menu do GitHub
-- ============================================================

local GITHUB_USER   = "joao10y6"
local GITHUB_REPO   = "syntax-roblox"
local GITHUB_BRANCH = "main"          -- troque para "master" se o seu repo usar master
local ARQUIVO_MENU  = "syntax.lua"    -- nome do arquivo que contém o MENU (não o loader)

local URL = string.format(
    "https://raw.githubusercontent.com/%s/%s/%s/%s",
    GITHUB_USER, GITHUB_REPO, GITHUB_BRANCH, ARQUIVO_MENU
)

-- ============================================================
-- HttpGet compatível com vários executores
-- ============================================================
local function httpGet(url)
    -- Roblox nativo
    if game.HttpGet then
        local ok, res = pcall(function() return game:HttpGet(url, true) end)
        if ok and res and #res > 0 then return res end
    end
    -- Synapse
    if syn and syn.request then
        local ok, res = pcall(function()
            return syn.request({ Url = url, Method = "GET" }).Body
        end)
        if ok and res and #res > 0 then return res end
    end
    -- Delta / outros
    if http_request then
        local ok, res = pcall(function()
            return http_request({ Url = url, Method = "GET" }).Body
        end)
        if ok and res and #res > 0 then return res end
    end
    -- request (ScriptWare / Krnl / etc)
    if request then
        local ok, res = pcall(function()
            return request({ Url = url, Method = "GET" }).Body
        end)
        if ok and res and #res > 0 then return res end
    end
    -- fluxus
    if fluxus and fluxus.request then
        local ok, res = pcall(function()
            return fluxus.request({ Url = url, Method = "GET" }).Body
        end)
        if ok and res and #res > 0 then return res end
    end
    return nil
end

-- ============================================================
-- Carrega o menu
-- ============================================================
print("[SYNTAX] Baixando menu de: " .. URL)

local conteudo = httpGet(URL)
if not conteudo or #conteudo < 50 then
    warn("[SYNTAX] ❌ Não foi possível baixar o menu. Verifique sua internet ou o link do GitHub.")
    return
end

-- Verificação: se o conteúdo baixado for o próprio loader, avisa
if conteudo:find("SYNTAX MENU v6.8 — LOADER") and conteudo:find("local GITHUB_REPO") then
    warn("[SYNTAX] ⚠️ O arquivo baixado é o LOADER, não o MENU.")
    warn("         Coloque o código-fonte do menu dentro de syntax.lua no GitHub.")
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
