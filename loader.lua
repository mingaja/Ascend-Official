-- ================================================
--   ASCEND OFFICIAL - Universal Loader
--   GitHub: https://github.com/mingaja/Ascend-Official
--
--   Pakai di executor:
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/mingaja/Ascend-Official/main/loader.lua"))()
-- ================================================

local RAW = "https://raw.githubusercontent.com/mingaja/Ascend-Official/main"

-- ================================================
--   DAFTAR GAME (key = GameId / UniverseId)
--   GameId sama untuk semua map/server dalam satu game.
--   Cari GameId: jalankan print(game.GameId) di executor,
--   atau buka https://apis.roblox.com/universes/v1/places/<PlaceId>/universe
-- ================================================

local GAMES = {
	[10563114921] = { name = "Steal An Egg", path = "games/sae/main.lua" },
	[6739698191] = { name = "VD", path = "games/vd/main.lua" },

	-- tambah game baru di sini:
	-- [GAMEID] = { name = "Nama Game", path = "games/nama/main.lua" },
}

-- Opsional: override khusus PlaceId tertentu (mis. map/lobby beda script).
local PLACES = {
	-- [PLACEID] = { name = "Nama Map", path = "games/nama/lobby.lua" },
}

-- ================================================
--   LOADER ENGINE (gak perlu diubah)
-- ================================================

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local genv = (type(getgenv) == "function" and getgenv()) or _G
if genv.__AscendLoaderRunning then
	warn("[Ascend Loader] Loader sudah berjalan, abaikan eksekusi ganda.")
	return
end
genv.__AscendLoaderRunning = true

local httpRequest = request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request)

local function fetch(url)
	-- Cache buster supaya update di GitHub langsung kepakai, bukan versi cache CDN.
	local busted = url .. "?t=" .. tostring(os.time())
	for _, target in ipairs({ busted, url }) do
		local ok, body = pcall(function() return game:HttpGet(target, true) end)
		if ok and type(body) == "string" and body ~= "" and not body:find("^404") then
			return body
		end
		if type(httpRequest) == "function" then
			local okReq, res = pcall(httpRequest, { Url = target, Method = "GET" })
			local resBody = okReq and res and (res.Body or res.body)
			local status = okReq and res and (res.StatusCode or res.status_code)
			if type(resBody) == "string" and resBody ~= "" and (status == nil or status == 200) then
				return resBody
			end
		end
	end
	return nil
end

local function notify(title, text)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", { Title = title, Text = text, Duration = 6 })
	end)
end

local function run(code, label)
	local compile = loadstring or load
	local fn, err = compile(code, "=" .. label)
	if not fn then
		warn("[Ascend Loader] Compile error: " .. tostring(err))
		notify("Ascend Loader", "Compile error, cek console (F9)")
		return false
	end
	local ok, runErr = xpcall(fn, debug.traceback)
	if not ok then
		warn("[Ascend Loader] Runtime error: " .. tostring(runErr))
		notify("Ascend Loader", "Runtime error, cek console (F9)")
		return false
	end
	return true
end

local gameId = game.GameId
local placeId = game.PlaceId
local entry = PLACES[placeId] or GAMES[gameId]

if not entry then
	genv.__AscendLoaderRunning = nil
	warn(string.format("[Ascend Loader] Game belum didukung. GameId: %d | PlaceId: %d", gameId, placeId))
	notify("Ascend Loader", "Game belum didukung (GameId " .. tostring(gameId) .. ")")
	return
end

print(string.format("[Ascend Loader] %s terdeteksi (GameId %d). Mengambil script...", entry.name, gameId))
local code = fetch(RAW .. "/" .. entry.path)
genv.__AscendLoaderRunning = nil

if not code then
	warn("[Ascend Loader] Gagal fetch script: " .. entry.path)
	notify("Ascend Loader", "Gagal mengambil script " .. entry.name)
	return
end

run(code, entry.path)
