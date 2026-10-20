-- ================================================
--   ASCEND OFFICIAL - Universal Loader
--   GitHub: https://github.com/mingaja/Ascend-Official
--
--   Pakai di executor:
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/mingaja/Ascend-Official/main/loader.lua"))()
-- ================================================

local RAW = "https://raw.githubusercontent.com/mingaja/Ascend-Official/main"

-- ================================================
--   DAFTAR GAME (Key = PlaceId)
--   Cari PlaceId: print(game.PlaceId) di executor
--   atau ambil angka dari link browser Roblox: roblox.com/games/PLACEID/...
-- ================================================

local GAMES = {
	-- Steal An Egg
	["107778070777162"] = { name = "Steal An Egg", path = "games/sae/main.lua" },

	-- Violence District (VD)
	["93978595733734"] = { name = "Violence District", path = "games/vd/main.lua" },

	-- Tambah game baru di sini:
	-- [PLACE_ID] = { name = "Nama Game", path = "games/nama/main.lua" },
}

-- ================================================
--   LOADER CORE
-- ================================================

-- Debounce 3 detik agar tidak spam-click tapi tidak lock permanen jika ada error koneksi
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

-- Tunggu game selesai loading jika dipanggil di Auto Execute
if not game:IsLoaded() then
	pcall(function() game.Loaded:Wait() end)
end

local placeId = game.PlaceId
local entry = GAMES[placeId] or GAMES[tostring(placeId)]

-- Fallback opsional ke GameId jika user mendaftarkan GameId
if not entry and game.GameId and game.GameId ~= 0 then
	entry = GAMES[game.GameId] or GAMES[tostring(game.GameId)]
end

if not entry then
	warn(string.format("[Ascend Loader] PlaceId belum didukung: %s (GameId: %s)", tostring(placeId), tostring(game.GameId)))
	notify("Ascend Loader", "Game belum didukung (PlaceId: " .. tostring(placeId) .. ")")
	return
end

print(string.format("[Ascend Loader] %s terdeteksi (PlaceId %s). Mengambil script...", entry.name, tostring(placeId)))
notify("Ascend Loader", "Memuat " .. entry.name .. "...")

-- Multi-fallback HTTP fetch
local function fetchScript(url)
	-- Cara 1: game:HttpGet standar
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
-- Jangan pakai xpcall langsung karena script game memanggil task.wait/yield yang akan
-- memicu error 'attempt to yield across C-call boundary' jika dibungkus xpcall.
task.spawn(function()
	local ok, runErr = pcall(fn)
	if not ok then
		warn("[Ascend Loader] Runtime error di script game: " .. tostring(runErr))
		notify("Ascend Loader", "Script error! Cek console F9.")
	end
end)
