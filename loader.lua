-- ================================================
--   ASCEND OFFICIAL - Universal Loader
--   GitHub: https://github.com/mingaja/Ascend-Official
--
--   Pakai di executor:
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/mingaja/Ascend-Official/main/loader.lua"))()
-- ================================================

local RAW = "https://raw.githubusercontent.com/mingaja/Ascend-Official/main"

-- ================================================
--   DAFTAR GAME
--   Key bisa GameId (UniverseId) ATAU PlaceId (angka / string).
--   GameId sama untuk semua map dalam satu game.
-- ================================================

local GAMES = {
	-- Steal An Egg (UniverseId: 10563114921 | PlaceId: 107778070777162)
	[10563114921] = { name = "Steal An Egg", path = "games/sae/main.lua" },
	["10563114921"] = { name = "Steal An Egg", path = "games/sae/main.lua" },
	[107778070777162] = { name = "Steal An Egg", path = "games/sae/main.lua" },
	["107778070777162"] = { name = "Steal An Egg", path = "games/sae/main.lua" },

	-- VD (UniverseId: 6739698191 | PlaceId: 93978595733734)
	[6739698191] = { name = "VD", path = "games/vd/main.lua" },
	["6739698191"] = { name = "VD", path = "games/vd/main.lua" },
	[93978595733734] = { name = "VD", path = "games/vd/main.lua" },
	["93978595733734"] = { name = "VD", path = "games/vd/main.lua" },

	-- Tambah game baru di sini:
	-- [GAME_ID] = { name = "Nama Game", path = "games/nama/main.lua" },
}

-- ================================================
--   LOADER CORE
-- ================================================

-- Debounce 3 detik agar tidak spam-click tapi TIDAK lock permanen jika ada error
local genv = (type(getgenv) == "function" and getgenv()) or _G
local now = tick()
if genv.__AscendLoaderLastRun and (now - genv.__AscendLoaderLastRun) < 3 then
	warn("[Ascend Loader] Sedang memuat, mohon tunggu sebentar...")
	return
end
genv.__AscendLoaderLastRun = now

local function notify(title, text)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = 5,
		})
	end)
end

-- Tunggu game loaded jika dipanggil sangat awal
if not game:IsLoaded() then
	pcall(function() game.Loaded:Wait() end)
end

-- Tunggu GameId ter-replicate (kadang 0 di detik pertama)
local waitStart = tick()
while (not game.GameId or game.GameId == 0) and (tick() - waitStart) < 5 do
	task.wait(0.2)
end

local gameId = game.GameId
local placeId = game.PlaceId

-- Cari konfigurasi game berdasarkan GameId atau PlaceId
local entry = GAMES[gameId]
	or GAMES[tostring(gameId)]
	or GAMES[placeId]
	or GAMES[tostring(placeId)]

if not entry then
	warn(string.format("[Ascend Loader] Game belum didukung. GameId: %s | PlaceId: %s", tostring(gameId), tostring(placeId)))
	notify("Ascend Loader", "Game belum didukung (GameId: " .. tostring(gameId) .. ")")
	return
end

print(string.format("[Ascend Loader] %s terdeteksi (GameId %s). Mengambil script...", entry.name, tostring(gameId)))
notify("Ascend Loader", "Memuat " .. entry.name .. "...")

-- Multi-fallback HTTP fetch
local function fetchScript(url)
	-- Cara 1: game:HttpGet standar tanpa query param
	local ok, body = pcall(function()
		return game:HttpGet(url)
	end)
	if ok and type(body) == "string" and #body > 0 and not body:find("^404") then
		return body
	end

	-- Cara 2: game:HttpGet dengan cache-buster
	local ok2, body2 = pcall(function()
		return game:HttpGet(url .. "?t=" .. tostring(os.time()))
	end)
	if ok2 and type(body2) == "string" and #body2 > 0 and not body2:find("^404") then
		return body2
	end

	-- Cara 3: request / http_request (Synapse, Fluxus, Delta, Wave, dll.)
	local req = request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request)
	if type(req) == "function" then
		local okReq, res = pcall(req, { Url = url, Method = "GET" })
		local resBody = okReq and res and (res.Body or res.body)
		local status = okReq and res and (res.StatusCode or res.status_code)
		if type(resBody) == "string" and #resBody > 0 and (status == nil or status == 200) then
			return resBody
		end
	end

	return nil
end

local targetUrl = RAW .. "/" .. entry.path
local code = fetchScript(targetUrl)

if not code then
	warn("[Ascend Loader] Gagal mengambil script dari: " .. targetUrl)
	notify("Ascend Loader", "Gagal mengambil script. Cek koneksi internet!")
	return
end

-- Compile script
local compile = loadstring or load
local fn, err = compile(code)
if not fn then
	warn("[Ascend Loader] Compile error: " .. tostring(err))
	notify("Ascend Loader", "Compile error! Cek console F9.")
	return
end

-- Eksekusi di thread Luau baru via task.spawn
-- JANGAN pakai xpcall langsung karena script game memanggil task.wait/yield yang akan
-- menyebabkan error 'attempt to yield across C-call boundary' jika dibungkus xpcall!
task.spawn(function()
	local ok, runErr = pcall(fn)
	if not ok then
		warn("[Ascend Loader] Runtime error di script game: " .. tostring(runErr))
		notify("Ascend Loader", "Script error! Cek console F9.")
	end
end)
