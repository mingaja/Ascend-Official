local HttpService = game:GetService("HttpService")

pcall(function()
    if not isfolder("Ascend Official") then
        makefolder("Ascend Official")
    end
    if not isfolder("Ascend Official/Config") then
        makefolder("Ascend Official/Config")
    end
end)

local univId = tostring(game.GameId)
if univId == "0" or univId == "" then
    univId = tostring(game.PlaceId)
end

local ConfigFile = "Ascend Official/Config/Ascend Official_" .. univId .. ".json"

ConfigData       = {}
Elements         = {}
CURRENT_VERSION  = nil

function SaveConfig()
    if writefile then
        ConfigData._version = CURRENT_VERSION
        pcall(function()
            writefile(ConfigFile, HttpService:JSONEncode(ConfigData))
        end)
    end
end

function LoadConfigFromFile()
    if not CURRENT_VERSION then return end
    
    local isFileSuccess, isFileResult = false, false
    if isfile then
        isFileSuccess, isFileResult = pcall(function() return isfile(ConfigFile) end)
    end

    if isFileSuccess and isFileResult then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFile))
        end)
        if success and type(result) == "table" then
            if result._version == CURRENT_VERSION then
                ConfigData = result
            else
                ConfigData = { _version = CURRENT_VERSION }
            end
        else
            ConfigData = { _version = CURRENT_VERSION }
        end
    else
        ConfigData = { _version = CURRENT_VERSION }
    end
end

function LoadConfigElements()
    for key, element in pairs(Elements) do
        if ConfigData[key] ~= nil and element.Set then
            element:Set(ConfigData[key], true)
        end
    end
end

-- ============================================================
-- CONFIG PROFILE SYSTEM
-- ============================================================
local PROFILE_FOLDER = "Ascend Official/Profiles"

local function EnsureProfileFolder()
    pcall(function()
        if not isfolder("Ascend Official") then makefolder("Ascend Official") end
        if not isfolder("Ascend Official/Config") then makefolder("Ascend Official/Config") end
        if not isfolder(PROFILE_FOLDER) then makefolder(PROFILE_FOLDER) end
    end)
end

function GetProfileList()
    local profiles = {}
    pcall(function()
        EnsureProfileFolder()
        local files = listfiles(PROFILE_FOLDER)
        for _, filePath in ipairs(files) do
            local normalized = tostring(filePath):gsub("\\", "/")
            local fileName = normalized:match("([^/]+)$") or ""
            if fileName:match("%.json$") then
                table.insert(profiles, (fileName:gsub("%.json$", "")))
            end
        end
    end)
    table.sort(profiles)
    return profiles
end

function SaveProfile(name)
    if not name or name == "" then return false end
    EnsureProfileFolder()
    local ok, err = pcall(function()
        writefile(PROFILE_FOLDER .. "/" .. name .. ".json", HttpService:JSONEncode(ConfigData))
    end)
    return ok, err
end

function LoadProfile(name)
    if not name or name == "" then return false end
    local path = PROFILE_FOLDER .. "/" .. name .. ".json"
    if not isfile then return false end
    local isFileSuccess, isFileResult = pcall(function() return isfile(path) end)
    if not isFileSuccess or not isFileResult then return false end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if ok and type(data) == "table" then
        for key, val in pairs(data) do
            ConfigData[key] = val
        end
        for key, element in pairs(Elements) do
            if ConfigData[key] ~= nil and element.Set then
                pcall(function()
                    element:Set(ConfigData[key])
                end)
                task.wait(0.03)
            end
        end
        SaveConfig()
        return true
    end
    return false
end

function DeleteProfile(name)
    if not name or name == "" then return false end
    local path = PROFILE_FOLDER .. "/" .. name .. ".json"
    local ok = pcall(function()
        if isfile(path) then delfile(path) end
    end)
    return ok
end

local Icons = {
    player    = "rbxassetid://12120698352",
    web       = "rbxassetid://137601480983962",
    bag       = "rbxassetid://8601111810",
    shop      = "rbxassetid://4985385964",
    cart      = "rbxassetid://128874923961846",
    plug      = "rbxassetid://137601480983962",
    settings  = "rbxassetid://70386228443175",
    loop      = "rbxassetid://122032243989747",
    gps       = "rbxassetid://17824309485",
    compas    = "rbxassetid://125300760963399",
    gamepad   = "rbxassetid://84173963561612",
    boss      = "rbxassetid://13132186360",
    scroll    = "rbxassetid://114127804740858",
    menu      = "rbxassetid://6340513838",
    crosshair = "rbxassetid://12614416478",
    user      = "rbxassetid://108483430622128",
    stat      = "rbxassetid://12094445329",
    eyes      = "rbxassetid://14321059114",
    sword     = "rbxassetid://82472368671405",
    discord   = "rbxassetid://94434236999817",
    star      = "rbxassetid://107005941750079",
    skeleton  = "rbxassetid://17313330026",
    payment   = "rbxassetid://18747025078",
    scan      = "rbxassetid://109869955247116",
    alert     = "rbxassetid://73186275216515",
    question  = "rbxassetid://17510196486",
    idea      = "rbxassetid://16833255748",
    strom     = "rbxassetid://13321880293",
    water     = "rbxassetid://100076212630732",
    dcs       = "rbxassetid://15310731934",
    start     = "rbxassetid://108886429866687",
    next      = "rbxassetid://12662718374",
    rod       = "rbxassetid://103247953194129",
    fish      = "rbxassetid://97167558235554",
    enviicon  = "rbxassetid://101669656973003",
    nplnicon  = "rbxassetid://111882698376264",
    nplnv4    = "rbxassetid://111882698376264",
    ascendicon = "rbxassetid://111882698376264",
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = LocalPlayer:GetMouse()

local function resolveUIHost()
    if gethui then
        local ok, host = pcall(gethui)
        if ok and host then return host end
    end
    for _, getter in ipairs({ "get_hidden_gui", "gethiddengui" }) do
        local fn = (getgenv and getgenv()[getter]) or _G[getter]
        if type(fn) == "function" then
            local ok, host = pcall(fn)
            if ok and host then return host end
        end
    end
    local okCore, core = pcall(function() return game:GetService("CoreGui") end)
    if okCore and core then
        local testOk = pcall(function()
            local test = Instance.new("ScreenGui")
            test.Parent = core
            test:Destroy()
        end)
        if testOk then return core end
    end
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
    if pg then return pg end
    return game:GetService("CoreGui")
end

local CoreGui = resolveUIHost()
local camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera")
local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)

local function isMobileDevice()
    return UserInputService.TouchEnabled
        and not UserInputService.KeyboardEnabled
        and not UserInputService.MouseEnabled
end

local isMobile = isMobileDevice()

local function safeSize(pxWidth, pxHeight)
    local scaleX = pxWidth / viewport.X
    local scaleY = pxHeight / viewport.Y

    if isMobile then
        if scaleX > 0.5 then scaleX = 0.5 end
        if scaleY > 0.3 then scaleY = 0.3 end
    end

    return UDim2.new(scaleX, 0, scaleY, 0)
end

local ASCEND_LOGO_B64 = "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"

local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local b64lookup = {}
for i = 1, 64 do b64lookup[b64chars:byte(i)] = i - 1 end

local function b64decode(data)
    local cryptDecode = (crypt and crypt.base64decode) or (syn and syn.crypt and syn.crypt.base64 and syn.crypt.base64.decode) or base64_decode
    if type(cryptDecode) == "function" then
        local ok, res = pcall(cryptDecode, data)
        if ok and res then return res end
    end
    local output = {}
    local buffer = 0
    local bits = 0
    for i = 1, #data do
        local byte = data:byte(i)
        local val = b64lookup[byte]
        if val then
            buffer = bit32.bor(bit32.lshift(buffer, 6), val)
            bits = bits + 6
            if bits >= 8 then
                bits = bits - 8
                table.insert(output, string.char(bit32.band(bit32.rshift(buffer, bits), 0xFF)))
                buffer = bit32.band(buffer, bit32.lshift(1, bits) - 1)
            end
        end
    end
    return table.concat(output)
end

local ASCEND_LOGO_CACHE = nil
local function getAscendLogo()
    if ASCEND_LOGO_CACHE and ASCEND_LOGO_CACHE ~= "" then return ASCEND_LOGO_CACHE end
    local getAsset = getcustomasset or getsynasset
    local filename = "Ascend_Logo_Official.png"
    
    if getAsset and writefile then
        local fileReady = false
        if isfile and isfile(filename) then
            pcall(function()
                if readfile and #readfile(filename) > 500 then
                    fileReady = true
                end
            end)
        end
        
        if not fileReady then
            local rawData = nil
            pcall(function()
                if game and game.HttpGet then
                    rawData = game:HttpGet("https://tr.rbxcdn.com/180DAY-2be8e7fca051aa5649a9b1a0439942a6/420/420/Image/Png/noFilter")
                end
            end)
            if not rawData or #rawData < 500 then
                pcall(function()
                    rawData = b64decode(ASCEND_LOGO_B64)
                end)
            end
            if rawData and #rawData > 500 then
                pcall(writefile, filename, rawData)
                fileReady = true
            end
        end
        
        if fileReady then
            task.wait(0.05)
            local ok, asset = pcall(getAsset, filename)
            if ok and asset and tostring(asset) ~= "" then
                ASCEND_LOGO_CACHE = asset
                return asset
            end
        end
    end
    
    ASCEND_LOGO_CACHE = "rbxassetid://111882698376264"
    return ASCEND_LOGO_CACHE
end

local function formatAssetId(id)
    if not id or tostring(id) == "" then return "rbxassetid://111882698376264" end
    local str = tostring(id)
    if str:find("111882698376264") or str:find("75562318586145") or str:find("96205589953310") or str:find("135599367349381") then
        return "rbxassetid://111882698376264"
    end
    if str:find("rbxthumb://") or str:find("rbxassetid://") or str:find("http://") or str:find("https://") then
        return str
    end
    local num = str:match("%d+")
    if num then
        return "rbxassetid://" .. num
    end
    return "rbxassetid://111882698376264"
end

local function applyLogoImage(imageLabel, preferredId)
    if not imageLabel then return end
    imageLabel.Image = formatAssetId(preferredId or "111882698376264")
end

local function MakeDraggable(topbarobject, object, excludeButtons)
    topbarobject.Active = true
    local dragging = false
    local dragStart, startPos

    local function isExcluded(pos)
        if type(excludeButtons) == "table" then
            for _, btn in ipairs(excludeButtons) do
                if btn and btn.Parent then
                    local bPos = btn.AbsolutePosition
                    local bSize = btn.AbsoluteSize
                    if pos.X >= bPos.X and pos.X <= bPos.X + bSize.X
                        and pos.Y >= bPos.Y and pos.Y <= bPos.Y + bSize.Y then
                        return true
                    end
                end
            end
        end
        return false
    end

    local function onStart(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isExcluded(input.Position) then
                return
            end
            dragging = true
            dragStart = input.Position
            startPos = object.Position
        end
    end

    topbarobject.InputBegan:Connect(onStart)
    for _, child in ipairs(topbarobject:GetChildren()) do
        if not child:IsA("TextButton") and not child:IsA("ImageButton") then
            pcall(function() child.InputBegan:Connect(onStart) end)
        end
    end

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            object.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    local function onEnd(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end
    UserInputService.InputEnded:Connect(onEnd)
end

function CircleClick(Button, X, Y)
    spawn(function()
        Button.ClipsDescendants = true
        local Circle = Instance.new("ImageLabel")
        Circle.Image = "rbxassetid://266543268"
        Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
        Circle.ImageTransparency = 0.8999999761581421
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Circle.BackgroundTransparency = 1
        Circle.ZIndex = 10
        Circle.Name = "Circle"
        Circle.Parent = Button

        local NewX = X - Circle.AbsolutePosition.X
        local NewY = Y - Circle.AbsolutePosition.Y
        Circle.Position = UDim2.new(0, NewX, 0, NewY)
        local Size = 0
        if Button.AbsoluteSize.X > Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.X * 1.5
        elseif Button.AbsoluteSize.X < Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.Y * 1.5
        elseif Button.AbsoluteSize.X == Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.X * 1.5
        end

        local Time = 0.5
        Circle:TweenSizeAndPosition(UDim2.new(0, Size, 0, Size), UDim2.new(0.5, -Size / 2, 0.5, -Size / 2), "Out", "Quad",
            Time, false, nil)
        for i = 1, 10 do
            Circle.ImageTransparency = Circle.ImageTransparency + 0.01
            wait(Time / 10)
        end
        Circle:Destroy()
    end)
end

local AscendOfficial = {}
local Napoleon = AscendOfficial
if getgenv then
    getgenv().AscendOfficial = AscendOfficial
    getgenv().Napoleon = AscendOfficial
end
function AscendOfficial:MakeNotify(NotifyConfig)
    local NotifyConfig = NotifyConfig or {}
    NotifyConfig.Title = NotifyConfig.Title or "Ascend Official"
    NotifyConfig.Description = NotifyConfig.Description or "Notification"
    NotifyConfig.Content = NotifyConfig.Content or "Content"
    NotifyConfig.Icon = NotifyConfig.Icon or "111882698376264"
    NotifyConfig.Color = NotifyConfig.Color or Color3.fromRGB(30, 150, 255)
    NotifyConfig.Time = NotifyConfig.Time or 0.5
    NotifyConfig.Delay = NotifyConfig.Delay or 5
    local NotifyFunction = {}
    spawn(function()
        local notifyGui = CoreGui:FindFirstChild("NotifyGui")
        if not notifyGui then
            notifyGui = Instance.new("ScreenGui")
            notifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            notifyGui.Name = "NotifyGui"
            notifyGui.ResetOnSpawn = false
            notifyGui.Parent = CoreGui
        end

        local notifyLayout = notifyGui:FindFirstChild("NotifyLayout")
        if not notifyLayout then
            notifyLayout = Instance.new("Frame")
            notifyLayout.AnchorPoint = Vector2.new(1, 0)
            notifyLayout.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            notifyLayout.BackgroundTransparency = 1
            notifyLayout.BorderSizePixel = 0
            notifyLayout.Position = UDim2.new(1, -30, 0, 30)
            notifyLayout.Size = UDim2.new(0, 320, 1, 0)
            notifyLayout.Name = "NotifyLayout"
            notifyLayout.Parent = notifyGui
            local Count = 0
            notifyLayout.ChildRemoved:Connect(function()
                Count = 0
                for _, v in ipairs(notifyLayout:GetChildren()) do
                    if v:IsA("GuiObject") then
                        TweenService:Create(
                            v,
                            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                            { Position = UDim2.new(0, 0, 0, ((v.Size.Y.Offset + 12) * Count)) }
                        ):Play()
                        Count = Count + 1
                    end
                end
            end)
        end
        local NotifyPosHeigh = 0
        for _, v in ipairs(notifyLayout:GetChildren()) do
            if v:IsA("GuiObject") then
                NotifyPosHeigh = v.Position.Y.Offset + v.Size.Y.Offset + 12
            end
        end
        local NotifyFrame = Instance.new("Frame");
        local NotifyFrameReal = Instance.new("Frame");
        local UICorner = Instance.new("UICorner");
        local DropShadowHolder = Instance.new("Frame");
        local DropShadow = Instance.new("ImageLabel");
        local Top = Instance.new("Frame");
        local TextLabel = Instance.new("TextLabel");
        local TextLabel1 = Instance.new("TextLabel");
        local TextLabel2 = Instance.new("TextLabel");

        NotifyFrame.BackgroundColor3 = Color3.fromRGB(29, 30, 35)
        NotifyFrame.BorderColor3 = Color3.fromRGB(29, 30, 35)
        NotifyFrame.BorderSizePixel = 0
        NotifyFrame.Size = UDim2.new(1, 0, 0, 150)
        NotifyFrame.Name = "NotifyFrame"
        NotifyFrame.BackgroundTransparency = 1
        NotifyFrame.Parent = notifyLayout
        NotifyFrame.AnchorPoint = Vector2.new(0, 0)
        NotifyFrame.Position = UDim2.new(0, 0, 0, NotifyPosHeigh)

        NotifyFrameReal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        NotifyFrameReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
        NotifyFrameReal.BorderSizePixel = 0
        NotifyFrameReal.Position = UDim2.new(0, 400, 0, 0)
        NotifyFrameReal.Size = UDim2.new(1, 0, 1, 0)
        NotifyFrameReal.Name = "NotifyFrameReal"
        NotifyFrameReal.Parent = NotifyFrame

        UICorner.Parent = NotifyFrameReal
        UICorner.CornerRadius = UDim.new(0, 8)

        DropShadowHolder.BackgroundTransparency = 1
        DropShadowHolder.BorderSizePixel = 0
        DropShadowHolder.Size = UDim2.new(1, 0, 1, 0)
        DropShadowHolder.ZIndex = 0
        DropShadowHolder.Name = "DropShadowHolder"
        DropShadowHolder.Parent = NotifyFrameReal

        local NotifIcon = Instance.new("ImageLabel")
        NotifIcon.Image = formatAssetId(NotifyConfig.Icon or "111882698376264")
        NotifIcon.BackgroundTransparency = 1
        NotifIcon.ImageTransparency = 0
        NotifIcon.BorderSizePixel = 0
        NotifIcon.Size = UDim2.new(0, 60, 0, 60)
        NotifIcon.Position = UDim2.new(0., 0, 0.05, 0)
        NotifIcon.ScaleType = Enum.ScaleType.Fit
        NotifIcon.Name = "NotifIcon"
        NotifIcon.ZIndex = 0
        NotifIcon.Parent = NotifyFrameReal

        Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Top.BackgroundTransparency = 0.9990000128746033
        Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Top.BorderSizePixel = 0
        Top.Position = UDim2.new(0, 55, 0, 0)
        Top.Size = UDim2.new(1, -55, 0, 36)
        Top.Name = "Top"
        Top.Parent = NotifyFrameReal

        TextLabel.Font = Enum.Font.GothamBold
        TextLabel.Text = NotifyConfig.Title
        TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.TextSize = 14
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.BackgroundTransparency = 0.9990000128746033
        TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel.BorderSizePixel = 0
        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.Parent = Top
        TextLabel.Position = UDim2.new(0, 10, 0, 0)

        UICorner1.Parent = Top
        UICorner1.CornerRadius = UDim.new(0, 5)

        TextLabel1.Font = Enum.Font.GothamBold
        TextLabel1.Text = NotifyConfig.Description
        TextLabel1.TextColor3 = NotifyConfig.Color
        TextLabel1.TextSize = 14
        TextLabel1.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel1.BackgroundColor3 = Color3.fromRGB(255, 130, 130)
        TextLabel1.BackgroundTransparency = 0.9990000128746033
        TextLabel1.TextTransparency = 0.3
        TextLabel1.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel1.BorderSizePixel = 0
        TextLabel1.Size = UDim2.new(1, 0, 1, 0)
        TextLabel1.Position = UDim2.new(0, TextLabel.TextBounds.X + 15, 0, 0)
        TextLabel1.Parent = Top

        Close.Font = Enum.Font.SourceSans
        Close.Text = ""
        Close.TextColor3 = Color3.fromRGB(0, 0, 0)
        Close.TextSize = 14
        Close.AnchorPoint = Vector2.new(1, 0.5)
        Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Close.BackgroundTransparency = 0.9990000128746033
        Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Close.BorderSizePixel = 0
        Close.Position = UDim2.new(1, -5, 0.5, 0)
        Close.Size = UDim2.new(0, 25, 0, 25)
        Close.Name = "Close"
        Close.Parent = Top

        ImageLabel.Image = "rbxassetid://9886659671"
        ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageLabel.BackgroundTransparency = 0.9990000128746033
        ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageLabel.BorderSizePixel = 0
        ImageLabel.Position = UDim2.new(0.49000001, 0, 0.5, 0)
        ImageLabel.Size = UDim2.new(1, -8, 1, -8)
        ImageLabel.Parent = Close

        TextLabel2.Font = Enum.Font.GothamBold
        TextLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel2.TextSize = 13
        TextLabel2.Text = NotifyConfig.Content
        TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel2.TextYAlignment = Enum.TextYAlignment.Top
        TextLabel2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel2.BackgroundTransparency = 0.9990000128746033
        TextLabel2.TextColor3 = Color3.fromRGB(150.0000062584877, 150.0000062584877, 150.0000062584877)
        TextLabel2.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel2.BorderSizePixel = 0
        TextLabel2.Position = UDim2.new(0, 65, 0, 27)
        TextLabel2.Parent = NotifyFrameReal
        TextLabel2.Size = UDim2.new(1, -90, 0, 13)

        TextLabel2.Size = UDim2.new(1, -90, 0, 13 + (13 * (TextLabel2.TextBounds.X // TextLabel2.AbsoluteSize.X)))
        TextLabel2.TextWrapped = true

        if TextLabel2.AbsoluteSize.Y < 27 then
            NotifyFrame.Size = UDim2.new(1, 0, 0, 65)
        else
            NotifyFrame.Size = UDim2.new(1, 0, 0, TextLabel2.AbsoluteSize.Y + 40)
        end
        local waitbruh = false
        function NotifyFunction:Close()
            if waitbruh then
                return false
            end
            waitbruh = true
            TweenService:Create(
                NotifyFrameReal,
                TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                { Position = UDim2.new(0, 400, 0, 0) }
            ):Play()
            task.wait(tonumber(NotifyConfig.Time) / 1.2)
            NotifyFrame:Destroy()
        end

        Close.Activated:Connect(function()
            NotifyFunction:Close()
        end)
        TweenService:Create(
            NotifyFrameReal,
            TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
            { Position = UDim2.new(0, 0, 0, 0) }
        ):Play()
        task.wait(tonumber(NotifyConfig.Delay))
        NotifyFunction:Close()
    end)
    return NotifyFunction
end

function notif(msg, delay, color, title, desc)
    return AscendOfficial:MakeNotify({
        Title = title or "Ascend Official",
        Description = desc or "Notification",
        Content = msg or "Content",
        Color = color or Color3.fromRGB(30, 150, 255),
        Delay = delay or 4
    })
end

function AscendOfficial:Window(GuiConfig)
    GuiConfig              = GuiConfig or {}
    GuiConfig.Title        = GuiConfig.Title or "Ascend Official"
    GuiConfig.Footer       = GuiConfig.Footer or "Ascend Official"
    GuiConfig.Color        = GuiConfig.Color or Color3.fromRGB(30, 150, 255)
    GuiConfig.Color2       = GuiConfig.Color2 or Color3.fromRGB(10, 10, 15)
    GuiConfig.LogoHUB      = GuiConfig.LogoHUB or "111882698376264"
    GuiConfig["Tab Width"] = GuiConfig["Tab Width"] or 120
    GuiConfig.Version      = GuiConfig.Version or 1

    CURRENT_VERSION        = GuiConfig.Version
    LoadConfigFromFile()

    pcall(function()
        for _, old in ipairs(CoreGui:GetChildren()) do
            if old.Name == "AscendOfficialOnTop" or old.Name == "NapoleonOnTop" then
                old:Destroy()
            end
        end
    end)

    local GuiFunc = {}

    local AscendOfficialOnTop = Instance.new("ScreenGui");
    local NapoleonOnTop = AscendOfficialOnTop
    local DropShadowHolder = Instance.new("Frame");
    local DropShadow = Instance.new("ImageLabel");
    local Main = Instance.new("Frame");
    local UICorner = Instance.new("UICorner");
    local Top = Instance.new("Frame");
    local TextLabel = Instance.new("TextLabel");
    local UICorner1 = Instance.new("UICorner");
    local TextLabel1 = Instance.new("TextLabel");
    local Close = Instance.new("TextButton");
    local ImageLabel1 = Instance.new("ImageLabel");
    local Min = Instance.new("TextButton");
    local ImageLabel2 = Instance.new("ImageLabel");
    local FullScreen = Instance.new("TextButton")
    local ImageLabel3 = Instance.new("ImageLabel")
    local LayersTab = Instance.new("Frame");
    local AccountTab = Instance.new("Frame");
    local UICorner2 = Instance.new("UICorner");
    local UICorner3 = Instance.new("UICorner")
    local DecideFrame = Instance.new("Frame");
    local Layers = Instance.new("Frame");
    local UICorner6 = Instance.new("UICorner");
    local NameTab = Instance.new("TextLabel");
    local LayersReal = Instance.new("Frame");
    local LayersFolder = Instance.new("Folder");
    local LayersPageLayout = Instance.new("UIPageLayout");

    AscendOfficialOnTop.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    AscendOfficialOnTop.Name = "AscendOfficialOnTop"
    AscendOfficialOnTop.ResetOnSpawn = false
    AscendOfficialOnTop.Parent = CoreGui

    DropShadowHolder.BackgroundTransparency = 1
	--DropShadowHolder.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    DropShadowHolder.BorderSizePixel = 0
    DropShadowHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadowHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
    if isMobile then
        DropShadowHolder.Size = UDim2.new(0, 470, 0, 270)
    else
        DropShadowHolder.Size = UDim2.new(0, 586, 0, 364)
    end
    DropShadowHolder.ZIndex = 0
    DropShadowHolder.Name = "DropShadowHolder"
    DropShadowHolder.Active = true
    DropShadowHolder.Draggable = true
    DropShadowHolder.Parent = AscendOfficialOnTop

    DropShadowHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow.ImageTransparency = 1
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1
    DropShadow.BorderSizePixel = 0
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.Size = UDim2.new(1, 47, 1, 47)
    DropShadow.ZIndex = 0
    DropShadow.Name = "DropShadow"
    DropShadow.Parent = DropShadowHolder

    if GuiConfig.Theme then
        Main:Destroy()
        Main = Instance.new("ImageLabel")
        Main.Image = "rbxassetid://" .. GuiConfig.Theme
        Main.ScaleType = Enum.ScaleType.Crop
        Main.BackgroundTransparency = 0
        Main.ImageTransparency = GuiConfig.ThemeTransparency or 0
    else
        Main.BackgroundColor3 = GuiConfig.Color2 or Color3.fromRGB(12, 12, 16)
        Main.BackgroundTransparency = 0
    end

    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(1, -47, 1, -47)
    Main.Name = "Main"
    Main.Parent = DropShadow

    UICorner3.Parent = Main
    UICorner3.CornerRadius = UDim.new(0, 0)

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = GuiConfig.Color or Color3.fromRGB(30, 150, 255)
    MainStroke.Transparency = 0
    MainStroke.Thickness = 1.5
    MainStroke.Parent = Main

    Top.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    Top.BackgroundTransparency = 0
    Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Top.BorderSizePixel = 0
    Top.Size = UDim2.new(1, 0, 0, 38)
    Top.Name = "Top"
    Top.Active = false
    Top.Parent = Main

    local TopDivider = Instance.new("Frame")
    TopDivider.Name = "TopDivider"
    TopDivider.Size = UDim2.new(1, 0, 0, 1)
    TopDivider.Position = UDim2.new(0, 0, 1, -1)
    TopDivider.BackgroundColor3 = Color3.fromRGB(35, 45, 60)
    TopDivider.BorderSizePixel = 0
    TopDivider.ZIndex = 5
    TopDivider.Parent = Top

    local DragArea = Instance.new("TextButton")
    DragArea.Name = "DragArea"
    DragArea.Text = ""
    DragArea.Size = UDim2.new(1, -115, 1, 0)
    DragArea.Position = UDim2.new(0, 0, 0, 0)
    DragArea.BackgroundTransparency = 1
    DragArea.Active = true
    DragArea.ZIndex = 2
    DragArea.Parent = Top

    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.Text = GuiConfig.Title
    TextLabel.TextColor3 = GuiConfig.Color
    TextLabel.TextSize = 14
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.BackgroundTransparency = 1
    TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BorderSizePixel = 0
    TextLabel.Size = UDim2.new(0, 0, 1, 0)
    TextLabel.AutomaticSize = Enum.AutomaticSize.X
    TextLabel.Position = UDim2.new(0, 38, 0, 0)
    TextLabel.ZIndex = 4
    TextLabel.Active = false
    TextLabel.Parent = Top

    local LogoImg = Instance.new("ImageLabel")
	LogoImg.BackgroundTransparency = 1
	LogoImg.BorderSizePixel = 0
	LogoImg.Size = UDim2.new(0, 24, 0, 24)
	LogoImg.Position = UDim2.new(0, 8, 0.5, -12)
	LogoImg.ScaleType = Enum.ScaleType.Fit
	LogoImg.Name = "LogoImg"
    LogoImg.ZIndex = 4
    LogoImg.Active = false
    LogoImg.Image = "rbxassetid://111882698376264"
	LogoImg.Parent = Top

    UICorner1.Parent = Top
    UICorner1.CornerRadius = UDim.new(0, 0)

    local RightContainer = Instance.new("Frame")
    RightContainer.Name = "RightContainer"
    RightContainer.BackgroundTransparency = 1
    RightContainer.Size = UDim2.new(0, 0, 1, 0)
    RightContainer.AutomaticSize = Enum.AutomaticSize.X
    RightContainer.Position = UDim2.new(1, -120, 0, 0)
    RightContainer.AnchorPoint = Vector2.new(1, 0)
    RightContainer.ZIndex = 4
    RightContainer.Parent = Top

    local TopListLayout = Instance.new("UIListLayout")
    TopListLayout.FillDirection = Enum.FillDirection.Horizontal
    TopListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    TopListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TopListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TopListLayout.Padding = UDim.new(0, 8)
    TopListLayout.Parent = RightContainer

    local FooterFrame = Instance.new("Frame")
    FooterFrame.Name = "FooterFrame"
    FooterFrame.LayoutOrder = 1
    FooterFrame.Size = UDim2.new(0, 0, 0.6, 0)
    FooterFrame.BackgroundColor3 = GuiConfig.Color
    FooterFrame.BackgroundTransparency = 0
    FooterFrame.BorderSizePixel = 0
    FooterFrame.AutomaticSize = Enum.AutomaticSize.X
    FooterFrame.Parent = RightContainer

    local FooterPadding = Instance.new("UIPadding")
    FooterPadding.PaddingLeft = UDim.new(0, 10)
    FooterPadding.PaddingRight = UDim.new(0, 10)
    FooterPadding.Parent = FooterFrame

    local FooterCorner = Instance.new("UICorner")
    FooterCorner.CornerRadius = UDim.new(1, 0)
    FooterCorner.Parent = FooterFrame

    TextLabel1.Name = "FooterText"
    TextLabel1.Size = UDim2.new(0, 0, 1, 0)
    TextLabel1.Position = UDim2.new(0, 0, 0, 0)
    TextLabel1.BackgroundTransparency = 1
    TextLabel1.Font = Enum.Font.GothamBold
    TextLabel1.Text = GuiConfig.Footer
    TextLabel1.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel1.TextSize = 12
    TextLabel1.TextXAlignment = Enum.TextXAlignment.Center
    TextLabel1.AutomaticSize = Enum.AutomaticSize.X
    TextLabel1.Parent = FooterFrame

    local execName = (identifyexecutor and identifyexecutor()) or "Unknown"
    local execText = "Executor: " .. tostring(execName)

    local Executor = Instance.new("Frame")
    Executor.Name = "Executor"
    Executor.LayoutOrder = 2
    Executor.Size = UDim2.new(0, 0, 0.6, 0)
    Executor.BackgroundColor3 = GuiConfig.Color
    Executor.BackgroundTransparency = 0
    Executor.BorderSizePixel = 0
    Executor.AutomaticSize = Enum.AutomaticSize.X
    Executor.Parent = RightContainer

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingLeft = UDim.new(0, 10)
    UIPadding.PaddingRight = UDim.new(0, 10)
    UIPadding.Parent = Executor

    local ExecutorUICorner = Instance.new("UICorner")
    ExecutorUICorner.CornerRadius = UDim.new(1, 0)
    ExecutorUICorner.Parent = Executor

    local ExecutorTextLabel = Instance.new("TextLabel")
    ExecutorTextLabel.Name = "TextLabel"
    ExecutorTextLabel.Size = UDim2.new(0, 0, 1, 0)
    ExecutorTextLabel.Position = UDim2.new(0, 0, 0, 0)
    ExecutorTextLabel.BackgroundTransparency = 1
    ExecutorTextLabel.Font = Enum.Font.GothamBold
    ExecutorTextLabel.Text = execText
    ExecutorTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExecutorTextLabel.TextSize = 12
    ExecutorTextLabel.TextXAlignment = Enum.TextXAlignment.Center
    ExecutorTextLabel.AutomaticSize = Enum.AutomaticSize.X
    ExecutorTextLabel.Parent = Executor

    local WindowControls = Instance.new("Frame")
    WindowControls.Name = "WindowControls"
    WindowControls.Size = UDim2.new(0, 95, 0, 38)
    WindowControls.Position = UDim2.new(1, -6, 0, 0)
    WindowControls.AnchorPoint = Vector2.new(1, 0)
    WindowControls.BackgroundTransparency = 1
    WindowControls.ZIndex = 100
    WindowControls.Parent = Main

    Min.Font = Enum.Font.SourceSans
    Min.Text = ""
    Min.TextColor3 = Color3.fromRGB(0, 0, 0)
    Min.TextSize = 14
    Min.AnchorPoint = Vector2.new(0, 0.5)
    Min.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Min.BackgroundTransparency = 0.6
    Min.BorderSizePixel = 0
    Min.Position = UDim2.new(0, 2, 0.5, 0)
    Min.Size = UDim2.new(0, 26, 0, 26)
    Min.Name = "Min"
    Min.Active = true
    Min.ZIndex = 60
    Min.Parent = WindowControls
    local minCorner = Instance.new("UICorner", Min)
    minCorner.CornerRadius = UDim.new(0, 0)

    ImageLabel2.Image = "rbxassetid://9886659276"
    ImageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
    ImageLabel2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel2.BackgroundTransparency = 1
    ImageLabel2.ImageTransparency = 0.1
    ImageLabel2.BorderSizePixel = 0
    ImageLabel2.Position = UDim2.new(0.5, 0, 0.5, 0)
    ImageLabel2.Size = UDim2.new(0, 16, 0, 16)
    ImageLabel2.Active = false
    ImageLabel2.ZIndex = 61
    ImageLabel2.Parent = Min

    FullScreen.Font = Enum.Font.SourceSans
    FullScreen.Text = ""
    FullScreen.TextColor3 = Color3.fromRGB(0, 0, 0)
    FullScreen.TextSize = 14
    FullScreen.AnchorPoint = Vector2.new(0, 0.5)
    FullScreen.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    FullScreen.BackgroundTransparency = 0.6
    FullScreen.BorderSizePixel = 0
    FullScreen.Position = UDim2.new(0, 33, 0.5, 0)
    FullScreen.Size = UDim2.new(0, 26, 0, 26)
    FullScreen.Name = "FullScreen"
    FullScreen.Active = true
    FullScreen.ZIndex = 60
    FullScreen.Parent = WindowControls
    local fsCorner = Instance.new("UICorner", FullScreen)
    fsCorner.CornerRadius = UDim.new(0, 0)

    ImageLabel3.Image = "rbxassetid://113480421738477"
    ImageLabel3.AnchorPoint = Vector2.new(0.5, 0.5)
    ImageLabel3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel3.BackgroundTransparency = 1
    ImageLabel3.ImageTransparency = 0.1
    ImageLabel3.BorderSizePixel = 0
    ImageLabel3.Position = UDim2.new(0.5, 0, 0.5, 0)
    ImageLabel3.Size = UDim2.new(0, 16, 0, 16)
    ImageLabel3.Active = false
    ImageLabel3.ZIndex = 61
    ImageLabel3.Parent = FullScreen

    Close.Font = Enum.Font.SourceSans
    Close.Text = ""
    Close.TextColor3 = Color3.fromRGB(0, 0, 0)
    Close.TextSize = 14
    Close.AnchorPoint = Vector2.new(0, 0.5)
    Close.BackgroundColor3 = Color3.fromRGB(50, 20, 25)
    Close.BackgroundTransparency = 0.5
    Close.BorderSizePixel = 0
    Close.Position = UDim2.new(0, 64, 0.5, 0)
    Close.Size = UDim2.new(0, 26, 0, 26)
    Close.Name = "Close"
    Close.Active = true
    Close.ZIndex = 60
    Close.Parent = WindowControls
    local closeCorner = Instance.new("UICorner", Close)
    closeCorner.CornerRadius = UDim.new(0, 0)

    ImageLabel1.Image = "rbxassetid://9886659671"
    ImageLabel1.AnchorPoint = Vector2.new(0.5, 0.5)
    ImageLabel1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel1.BackgroundTransparency = 1
    ImageLabel1.ImageTransparency = 0.1
    ImageLabel1.BorderSizePixel = 0
    ImageLabel1.Position = UDim2.new(0.5, 0, 0.5, 0)
    ImageLabel1.Size = UDim2.new(0, 16, 0, 16)
    ImageLabel1.Active = false
    ImageLabel1.ZIndex = 61
    ImageLabel1.Parent = Close

    LayersTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LayersTab.BackgroundTransparency = 1
    LayersTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
    LayersTab.BorderSizePixel = 0
    LayersTab.Position = UDim2.new(0, 9, 0, 50)
    LayersTab.Size = UDim2.new(0, GuiConfig["Tab Width"], 1, -95)
    LayersTab.Name = "LayersTab"
    LayersTab.Parent = Main

    local SearchBarFrame = Instance.new("Frame")
    SearchBarFrame.Name = "SearchBarFrame"
    SearchBarFrame.Size = UDim2.new(1, 0, 0, 26)
    SearchBarFrame.Position = UDim2.new(0, 0, 0, 0)
    SearchBarFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SearchBarFrame.BackgroundTransparency = 0.93
    SearchBarFrame.Parent = LayersTab

    local SearchBarCorner = Instance.new("UICorner")
    SearchBarCorner.CornerRadius = UDim.new(0, 6)
    SearchBarCorner.Parent = SearchBarFrame

    local SearchBarStroke = Instance.new("UIStroke")
    SearchBarStroke.Thickness = 1
    SearchBarStroke.Transparency = 0.7
    SearchBarStroke.Color = GuiConfig.Color
    SearchBarStroke.Parent = SearchBarFrame

    local SearchBox = Instance.new("TextBox")
    SearchBox.Name = "SearchBox"
    SearchBox.BackgroundTransparency = 1
    SearchBox.Size = UDim2.new(1, -30, 1, 0)
    SearchBox.Position = UDim2.new(0, 24, 0, 0)
    SearchBox.TextSize = 11
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "Search..."
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.Parent = SearchBarFrame

    local SearchIcon = Instance.new("ImageLabel")
    SearchIcon.Name = "SearchIcon"
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Image = "rbxassetid://109869955247116"
    SearchIcon.AnchorPoint = Vector2.new(0, 0.5)
    SearchIcon.Position = UDim2.new(0, 7, 0.5, 0)
    SearchIcon.Size = UDim2.new(0, 13, 0, 13)
    SearchIcon.Parent = SearchBarFrame



	AccountTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    AccountTab.BackgroundTransparency = 0.9350000023841858
    AccountTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
    AccountTab.BorderSizePixel = 0
    AccountTab.Position = UDim2.new(0, 9, 1, -45)
    AccountTab.Size = UDim2.new(0, GuiConfig["Tab Width"], 0, 35)
    AccountTab.Name = "AccountTab"
    AccountTab.Parent = Main

    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = AccountTab

    local AvatarCircle = Instance.new("Frame")
    AvatarCircle.Size = UDim2.new(0, 26, 0, 26)
    AvatarCircle.Position = UDim2.new(0, 5, 0.5, -13)
    AvatarCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    AvatarCircle.BackgroundTransparency = 1
    AvatarCircle.BorderSizePixel = 0
    AvatarCircle.ClipsDescendants = true  -- bikin bulat
    AvatarCircle.Name = "AvatarCircle"
    AvatarCircle.Parent = AccountTab

    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0)  -- full bulat
    AvatarCorner.Parent = AvatarCircle

    local AvatarImg = Instance.new("ImageLabel")
    AvatarImg.Size = UDim2.new(1, 0, 1, 0)
    AvatarImg.BackgroundTransparency = 1
    AvatarImg.BorderSizePixel = 0
    AvatarImg.Name = "AvatarImg"
    AvatarImg.Parent = AvatarCircle

    -- Nama player di sebelah kanan avatar
    local AccountName = Instance.new("TextLabel")
    AccountName.Font = Enum.Font.GothamBold
    -- AccountName.Text = game:GetService("Players").LocalPlayer.Name
    AccountName.TextSize = 11
    AccountName.TextColor3 = Color3.fromRGB(231, 231, 231)
    AccountName.TextXAlignment = Enum.TextXAlignment.Left
    AccountName.BackgroundTransparency = 1
    AccountName.Position = UDim2.new(0, 36, 0, 0)
    AccountName.Size = UDim2.new(1, -40, 1, 0)
    AccountName.TextTruncate = Enum.TextTruncate.AtEnd  -- potong kalau kepanjangan
    AccountName.Parent = AccountTab

    local playerName = game:GetService("Players").LocalPlayer.Name

    if #playerName > 3 then
        local hiddenLength = #playerName - 3
        local visible = string.sub(playerName, -3)
        AccountName.Text = string.rep("*", hiddenLength) .. visible
    else
        AccountName.Text = playerName
    end

    -- Ambil foto avatar
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    spawn(function()
        local url, _ = Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size420x420
        )
        AvatarImg.Image = url
    end)

    UICorner2.CornerRadius = UDim.new(0, 0)
    UICorner2.Parent = LayersTab

    DecideFrame.AnchorPoint = Vector2.new(0.5, 0)
    DecideFrame.BackgroundColor3 = GuiConfig.Color
    DecideFrame.BackgroundTransparency = 0.5
    DecideFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DecideFrame.BorderSizePixel = 0
    DecideFrame.Position = UDim2.new(0.5, 0, 0, 38)
    DecideFrame.Size = UDim2.new(1, 0, 0, 1)
    DecideFrame.Name = "DecideFrame"
    DecideFrame.Parent = Main

    Layers.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Layers.BackgroundTransparency = 0.9990000128746033
    Layers.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Layers.BorderSizePixel = 0
    Layers.Position = UDim2.new(0, GuiConfig["Tab Width"] + 18, 0, 50)
    Layers.Size = UDim2.new(1, -(GuiConfig["Tab Width"] + 9 + 18), 1, -59)
    Layers.Name = "Layers"
    Layers.Parent = Main

    UICorner6.CornerRadius = UDim.new(0, 0)
    UICorner6.Parent = Layers

	local WindowImg1 = Instance.new("ImageLabel")
	WindowImg1.Image = formatAssetId(GuiConfig.LogoHUB or "111882698376264")
	WindowImg1.BackgroundTransparency = 1
	WindowImg1.ImageTransparency = 0.8
	WindowImg1.BorderSizePixel = 0
	WindowImg1.Size = UDim2.new(0.5, 0, 0.9, 0)
	WindowImg1.Position = UDim2.new(0, 0, 0.1, 0)
	WindowImg1.ScaleType = Enum.ScaleType.Fit
	WindowImg1.Name = "WindowImg1"
	WindowImg1.ZIndex = -1
	WindowImg1.Parent = Layers
    WindowImg1.Visible = false

	local WindowImg2 = Instance.new("ImageLabel")
	WindowImg2.Image = "rbxassetid://" .. GuiConfig.WindowIMG
	WindowImg2.BackgroundTransparency = 1
	WindowImg2.ImageTransparency = 0.8
	WindowImg2.BorderSizePixel = 0
	WindowImg2.Size = UDim2.new(0.68, 0, 0.9, 0)
	WindowImg2.Position = UDim2.new(0.32, 0, 0.125, 0)
	WindowImg2.ScaleType = Enum.ScaleType.Fit
	WindowImg2.Name = "WindowImg2"
	WindowImg2.ZIndex = 0
	WindowImg2.Parent = Layers
    WindowImg2.Visible = false

    -- NameTab.Font = Enum.Font.GothamBold
    -- NameTab.Text = ""
    -- NameTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    -- NameTab.TextSize = 24
    -- NameTab.TextWrapped = true
    -- NameTab.TextXAlignment = Enum.TextXAlignment.Left
    -- NameTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    -- NameTab.BackgroundTransparency = 0.9990000128746033
    -- NameTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
    -- NameTab.BorderSizePixel = 0
    -- NameTab.Size = UDim2.new(1, 0, 0, 30)
    -- NameTab.Name = "NameTab"
    -- NameTab.Parent = Layers

    LayersReal.AnchorPoint = Vector2.new(0, 1)
    LayersReal.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LayersReal.BackgroundTransparency = 0.9990000128746033
    LayersReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
    LayersReal.BorderSizePixel = 0
    LayersReal.ClipsDescendants = true
    LayersReal.Position = UDim2.new(0, 0, 1, 0)
    LayersReal.Size = UDim2.new(1, 0, 1, 0)
    LayersReal.Name = "LayersReal"
    LayersReal.Parent = Layers

    LayersFolder.Name = "LayersFolder"
    LayersFolder.Parent = LayersReal

    LayersPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LayersPageLayout.Name = "LayersPageLayout"
    LayersPageLayout.Parent = LayersFolder
    LayersPageLayout.TweenTime = 0.5
    LayersPageLayout.EasingDirection = Enum.EasingDirection.InOut
    LayersPageLayout.EasingStyle = Enum.EasingStyle.Quad

    local ScrollTab = Instance.new("ScrollingFrame");
    local UIListLayout = Instance.new("UIListLayout");

    ScrollTab.CanvasSize = UDim2.new(0, 0, 1.10000002, 0)
    ScrollTab.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
    ScrollTab.ScrollBarThickness = 0
    ScrollTab.Active = true
    ScrollTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ScrollTab.BackgroundTransparency = 0.9990000128746033
    ScrollTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ScrollTab.BorderSizePixel = 0
    ScrollTab.Size = UDim2.new(1, 0, 0.88, 0)
	ScrollTab.Position = UDim2.new(0, 0, 0.11, 0)
    ScrollTab.Name = "ScrollTab"
    ScrollTab.Parent = LayersTab

    UIListLayout.Padding = UDim.new(0, 3)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = ScrollTab

    local function UpdateSize1()
        local OffsetY = 0
        for _, child in ScrollTab:GetChildren() do
            if child.Name ~= "UIListLayout" then
                OffsetY = OffsetY + 3 + child.Size.Y.Offset
            end
        end
        ScrollTab.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
    end
    ScrollTab.ChildAdded:Connect(UpdateSize1)
    ScrollTab.ChildRemoved:Connect(UpdateSize1)

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(SearchBox.Text)
        local jumpedToTab = false
        for _, scrolLayers in pairs(LayersFolder:GetChildren()) do
            if scrolLayers:IsA("ScrollingFrame") and scrolLayers.Name == "ScrolLayers" then
                for _, section in pairs(scrolLayers:GetChildren()) do
                    if section.Name == "Section" then
                        local sectionAdd = section:FindFirstChild("SectionAdd")
                        local sectionReal = section:FindFirstChild("SectionReal")
                        if sectionAdd and sectionReal then
                            local sectionVisible = false
                            for _, item in pairs(sectionAdd:GetChildren()) do
                                if item.Name ~= "UIListLayout" and item.Name ~= "UICorner" then
                                    local match = false
                                    for _, desc in pairs(item:GetDescendants()) do
                                        if desc:IsA("TextLabel") and (string.find(desc.Name, "Title") or string.find(desc.Name, "Text")) then
                                            local txt = string.lower(desc.Text)
                                            if string.find(txt, query) then
                                                match = true
                                                if query ~= "" and not jumpedToTab then
                                                    jumpedToTab = true
                                                    for _, sideTab in pairs(ScrollTab:GetChildren()) do
                                                        if sideTab.Name == "Tab" and sideTab.LayoutOrder == scrolLayers.LayoutOrder then
                                                            local selectEvt = sideTab:FindFirstChild("SelectEvent")
                                                            if selectEvt then selectEvt:Fire() end
                                                            break
                                                        end
                                                    end
                                                end
                                                break
                                            end
                                        end
                                    end
                                    if query == "" then match = true end
                                    item.Visible = match
                                    if match then sectionVisible = true end
                                end
                            end
                            if query ~= "" then
                                section.Visible = sectionVisible
                            else
                                section.Visible = true
                            end
                        end
                    end
                end
            end
        end
    end)

    function GuiFunc:DestroyGui()
        if CoreGui:FindFirstChild("AscendOfficialOnTop") then
            AscendOfficialOnTop:Destroy()
        elseif CoreGui:FindFirstChild("NapoleonOnTop") then
            CoreGui.NapoleonOnTop:Destroy()
        end
    end

    local function doMinimize()
        DropShadowHolder.Visible = false
    end
    Min.MouseButton1Down:Connect(doMinimize)
    Min.MouseButton1Click:Connect(doMinimize)
    Min.Activated:Connect(doMinimize)

    local function doClose()
        pcall(CircleClick, Close, Mouse and Mouse.X or 0, Mouse and Mouse.Y or 0)

        local Overlay = Instance.new("Frame")
        Overlay.Size = UDim2.new(1, 0, 1, 0)
        Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Overlay.BackgroundTransparency = 0.3
        Overlay.ZIndex = 50
        Overlay.Parent = DropShadowHolder

        local Dialog = Instance.new("ImageLabel")
        Dialog.Size = UDim2.new(0, 300, 0, 150)
        Dialog.Position = UDim2.new(0.5, -150, 0.5, -75)
        Dialog.Image = "rbxassetid://9542022979"
        Dialog.ImageTransparency = 0
        Dialog.BorderSizePixel = 0
        Dialog.ZIndex = 51
        Dialog.Parent = Overlay
        local UICorner = Instance.new("UICorner", Dialog)
        UICorner.CornerRadius = UDim.new(0, 8)

        local DialogGlow = Instance.new("Frame")
        DialogGlow.Size = UDim2.new(0, 310, 0, 160)
        DialogGlow.Position = UDim2.new(0.5, -155, 0.5, -80)
        DialogGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        DialogGlow.BackgroundTransparency = 0.75
        DialogGlow.BorderSizePixel = 0
        DialogGlow.ZIndex = 50
        DialogGlow.Parent = Overlay

        local GlowCorner = Instance.new("UICorner", DialogGlow)
        GlowCorner.CornerRadius = UDim.new(0, 10)

        local Gradient = Instance.new("UIGradient")
        Gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(0, 191, 255)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 140, 255)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(0, 191, 255))
        })
        Gradient.Rotation = 90
        Gradient.Parent = DialogGlow

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 0, 40)
        Title.Position = UDim2.new(0, 0, 0, 4)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamBold
        Title.Text = "Ascend Official Window"
        Title.TextSize = 22
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.ZIndex = 52
        Title.Parent = Dialog

        local Message = Instance.new("TextLabel")
        Message.Size = UDim2.new(1, -20, 0, 60)
        Message.Position = UDim2.new(0, 10, 0, 30)
        Message.BackgroundTransparency = 1
        Message.Font = Enum.Font.Gotham
        Message.Text = "Do you want to close this window?\nYou will not be able to open it again"
        Message.TextSize = 14
        Message.TextColor3 = Color3.fromRGB(200, 200, 200)
        Message.TextWrapped = true
        Message.ZIndex = 52
        Message.Parent = Dialog

        local Yes = Instance.new("TextButton")
        Yes.Size = UDim2.new(0.45, -10, 0, 35)
        Yes.Position = UDim2.new(0.05, 0, 1, -55)
        Yes.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Yes.BackgroundTransparency = 0.935
        Yes.Text = "Yes"
        Yes.Font = Enum.Font.GothamBold
        Yes.TextSize = 15
        Yes.TextColor3 = Color3.fromRGB(255, 255, 255)
        Yes.TextTransparency = 0.3
        Yes.ZIndex = 52
        Yes.Name = "Yes"
        Yes.Parent = Dialog
        Instance.new("UICorner", Yes).CornerRadius = UDim.new(0, 6)

        local Cancel = Instance.new("TextButton")
        Cancel.Size = UDim2.new(0.45, -10, 0, 35)
        Cancel.Position = UDim2.new(0.5, 10, 1, -55)
        Cancel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Cancel.BackgroundTransparency = 0.935
        Cancel.Text = "Cancel"
        Cancel.Font = Enum.Font.GothamBold
        Cancel.TextSize = 15
        Cancel.TextColor3 = Color3.fromRGB(255, 255, 255)
        Cancel.TextTransparency = 0.3
        Cancel.ZIndex = 52
        Cancel.Name = "Cancel"
        Cancel.Parent = Dialog
        Instance.new("UICorner", Cancel).CornerRadius = UDim.new(0, 6)

        Yes.MouseButton1Click:Connect(function()
            if AscendOfficialOnTop then AscendOfficialOnTop:Destroy() end
            if CoreGui:FindFirstChild("ToggleUIAscendOfficial") then
                CoreGui.ToggleUIAscendOfficial:Destroy()
            end
            if CoreGui:FindFirstChild("ToggleUIAscend") then
                CoreGui.ToggleUIAscend:Destroy()
            end
            if CoreGui:FindFirstChild("ToggleUINapoleon") then
                CoreGui.ToggleUINapoleon:Destroy()
            end
        end)

        Cancel.MouseButton1Click:Connect(function()
            Overlay:Destroy()
        end)
    end
    Close.MouseButton1Down:Connect(doClose)
    Close.MouseButton1Click:Connect(doClose)
    Close.Activated:Connect(doClose)

    local ToggleKey = Enum.KeyCode.F3
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == ToggleKey then
            if DropShadowHolder then
                DropShadowHolder.Visible = not DropShadowHolder.Visible
            end
        end
    end)

    function GuiFunc:ToggleUI()
        pcall(function()
            for _, old in ipairs(CoreGui:GetChildren()) do
                if old.Name == "ToggleUIAscendOfficial" or old.Name == "ToggleUIAscend" or old.Name == "ToggleUINapoleon" then
                    old:Destroy()
                end
            end
        end)

        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Parent = CoreGui
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.Name = "ToggleUIAscendOfficial"
        ScreenGui.ResetOnSpawn = false

        local MainButton = Instance.new("ImageButton")
        MainButton.Name = "FloatingLogoToggle"
        MainButton.Parent = ScreenGui
        MainButton.Size = UDim2.new(0, 44, 0, 44)
        MainButton.Position = UDim2.new(0, 18, 0.5, -22)
        MainButton.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        MainButton.BackgroundTransparency = 0
        MainButton.BorderSizePixel = 0
        MainButton.ZIndex = 100
        MainButton.AutoButtonColor = false
        MainButton.ClipsDescendants = true

        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 0)
        ButtonCorner.Parent = MainButton

        local ButtonStroke = Instance.new("UIStroke")
        ButtonStroke.Color = GuiConfig.Color or Color3.fromRGB(30, 150, 255)
        ButtonStroke.Thickness = 1.5
        ButtonStroke.Transparency = 0
        ButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        ButtonStroke.Parent = MainButton

        local LogoIcon = Instance.new("ImageLabel")
        LogoIcon.Name = "LogoIcon"
        LogoIcon.Parent = MainButton
        LogoIcon.Size = UDim2.new(1, 0, 1, 0)
        LogoIcon.Position = UDim2.new(0, 0, 0, 0)
        LogoIcon.BackgroundTransparency = 1
        LogoIcon.BorderSizePixel = 0
        LogoIcon.ScaleType = Enum.ScaleType.Fit
        LogoIcon.ZIndex = 101
        LogoIcon.Active = false
        LogoIcon.Image = "rbxassetid://111882698376264"

        MainButton.MouseEnter:Connect(function()
            TweenService:Create(ButtonStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(100, 190, 255) }):Play()
        end)
        MainButton.MouseLeave:Connect(function()
            TweenService:Create(ButtonStroke, TweenInfo.new(0.15), { Color = GuiConfig.Color or Color3.fromRGB(30, 150, 255) }):Play()
        end)

        local dragging = false
        local dragStart, startPos
        local hasMoved = false

        MainButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                hasMoved = false
                dragStart = input.Position
                startPos = MainButton.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                if delta.Magnitude > 5 then
                    hasMoved = true
                end
                MainButton.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)

        local function onRelease(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if dragging then
                    dragging = false
                    if not hasMoved then
                        if DropShadowHolder then
                            DropShadowHolder.Visible = not DropShadowHolder.Visible
                            TweenService:Create(MainButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), { Size = UDim2.new(0, 38, 0, 38) }):Play()
                            task.delay(0.1, function()
                                TweenService:Create(MainButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), { Size = UDim2.new(0, 44, 0, 44) }):Play()
                            end)
                        end
                    end
                end
            end
        end

        MainButton.InputEnded:Connect(onRelease)
        UserInputService.InputEnded:Connect(onRelease)

        GuiFunc.FloatingToggle = ScreenGui
        return ScreenGui
    end

    GuiFunc:ToggleUI()

    local defW = isMobile and 470 or 586
    local defH = isMobile and 270 or 364
    local titleW = TextLabel and TextLabel.TextBounds and TextLabel.TextBounds.X or 100
    local footerW = TextLabel1 and TextLabel1.TextBounds and TextLabel1.TextBounds.X or 100
    DropShadowHolder.Size = UDim2.new(0, math.max(defW, 115 + titleW + 1 + footerW), 0, defH)
    MakeDraggable(DragArea, DropShadowHolder)
    local isFullscreen = false
    local originalSize = DropShadowHolder.Size
    local originalPos  = DropShadowHolder.Position

    local function toggleFullscreen()
        isFullscreen = not isFullscreen

        if isFullscreen then
            originalSize = DropShadowHolder.Size
            originalPos  = DropShadowHolder.Position

            TweenService:Create(DropShadowHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size     = UDim2.new(0.96, 0, 0.94, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
            }):Play()
        else
            TweenService:Create(DropShadowHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size     = originalSize,
                Position = originalPos,
            }):Play()
        end
    end
    FullScreen.MouseButton1Down:Connect(toggleFullscreen)
    FullScreen.MouseButton1Click:Connect(toggleFullscreen)
    FullScreen.Activated:Connect(toggleFullscreen)

    local MoreBlur = Instance.new("Frame");
    local DropShadowHolder1 = Instance.new("Frame");
    local DropShadow1 = Instance.new("ImageLabel");
    local UICorner28 = Instance.new("UICorner");
    local ConnectButton = Instance.new("TextButton");

    MoreBlur.AnchorPoint = Vector2.new(1, 1)
    MoreBlur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MoreBlur.BackgroundTransparency = 0.999
    MoreBlur.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MoreBlur.BorderSizePixel = 0
    MoreBlur.ClipsDescendants = true
    MoreBlur.Position = UDim2.new(1, 8, 1, 8)
    MoreBlur.Size = UDim2.new(1, 154, 1, 54)
    MoreBlur.Visible = false
    MoreBlur.Name = "MoreBlur"
    MoreBlur.Parent = Layers

    DropShadowHolder1.BackgroundTransparency = 1
    DropShadowHolder1.BorderSizePixel = 0
    DropShadowHolder1.Size = UDim2.new(1, 0, 1, 0)
    DropShadowHolder1.ZIndex = 0
    DropShadowHolder1.Name = "DropShadowHolder"
    DropShadowHolder1.Parent = MoreBlur

    DropShadow1.Image = "rbxassetid://6015897843"
    DropShadow1.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow1.ImageTransparency = 1
    DropShadow1.ScaleType = Enum.ScaleType.Slice
    DropShadow1.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow1.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow1.BackgroundTransparency = 1
    DropShadow1.BorderSizePixel = 0
    DropShadow1.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow1.Size = UDim2.new(1, 35, 1, 35)
    DropShadow1.ZIndex = 0
    DropShadow1.Name = "DropShadow"
    DropShadow1.Parent = DropShadowHolder1

    UICorner28.Parent = MoreBlur

    ConnectButton.Font = Enum.Font.SourceSans
    ConnectButton.Text = ""
    ConnectButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    ConnectButton.TextSize = 14
    ConnectButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ConnectButton.BackgroundTransparency = 0.999
    ConnectButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ConnectButton.BorderSizePixel = 0
    ConnectButton.Size = UDim2.new(1, 0, 1, 0)
    ConnectButton.Name = "ConnectButton"
    ConnectButton.Parent = MoreBlur

    local DropdownSelect = Instance.new("Frame");
    local UICorner36 = Instance.new("UICorner");
    local UIStroke14 = Instance.new("UIStroke");
    local DropdownSelectReal = Instance.new("Frame");
    local DropdownFolder = Instance.new("Folder");
    local DropPageLayout = Instance.new("UIPageLayout");

    DropdownSelect.AnchorPoint = Vector2.new(1, 0.5)
    DropdownSelect.BackgroundColor3 = Color3.fromRGB(30.00000011175871, 30.00000011175871, 30.00000011175871)
    DropdownSelect.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DropdownSelect.BorderSizePixel = 0
    DropdownSelect.LayoutOrder = 1
    DropdownSelect.Position = UDim2.new(1, 172, 0.5, 0)
    DropdownSelect.Size = UDim2.new(0, 160, 1, -16)
    DropdownSelect.Name = "DropdownSelect"
    DropdownSelect.ClipsDescendants = true
    DropdownSelect.Parent = MoreBlur

    ConnectButton.Activated:Connect(function()
        if MoreBlur.Visible then
            TweenService:Create(MoreBlur, TweenInfo.new(0.3), { BackgroundTransparency = 0.999 }):Play()
            TweenService:Create(DropdownSelect, TweenInfo.new(0.3), { Position = UDim2.new(1, 172, 0.5, 0) }):Play()
            task.wait(0.3)
            MoreBlur.Visible = false
        end
    end)
    UICorner36.CornerRadius = UDim.new(0, 3)
    UICorner36.Parent = DropdownSelect

    UIStroke14.Color = Color3.fromRGB(12, 159, 255)
    UIStroke14.Thickness = 2.5
    UIStroke14.Transparency = 0.8
    UIStroke14.Parent = DropdownSelect

    DropdownSelectReal.AnchorPoint = Vector2.new(0.5, 0.5)
    DropdownSelectReal.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Latar Warna Dropdown
    DropdownSelectReal.BackgroundTransparency = 0.7
    DropdownSelectReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DropdownSelectReal.BorderSizePixel = 0
    DropdownSelectReal.LayoutOrder = 1
    DropdownSelectReal.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropdownSelectReal.Size = UDim2.new(1, 1, 1, 1)
    DropdownSelectReal.Name = "DropdownSelectReal"
    DropdownSelectReal.Parent = DropdownSelect

    DropdownFolder.Name = "DropdownFolder"
    DropdownFolder.Parent = DropdownSelectReal

    DropPageLayout.EasingDirection = Enum.EasingDirection.InOut
    DropPageLayout.EasingStyle = Enum.EasingStyle.Quad
    DropPageLayout.TweenTime = 0.009999999776482582
    DropPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DropPageLayout.FillDirection = Enum.FillDirection.Vertical
    DropPageLayout.Archivable = false
    DropPageLayout.Name = "DropPageLayout"
    DropPageLayout.Parent = DropdownFolder
    --// Tabs
    local Tabs = {}
    local CountTab = 0
    local CountDropdown = 0
    function Tabs:AddTab(TabConfig)
        local TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or ""

        local ScrolLayers = Instance.new("ScrollingFrame");
        local UIListLayout1 = Instance.new("UIListLayout");

        ScrolLayers.ScrollBarImageColor3 = Color3.fromRGB(80.00000283122063, 80.00000283122063, 80.00000283122063)
        ScrolLayers.ScrollBarThickness = 0
        ScrolLayers.Active = true
        ScrolLayers.LayoutOrder = CountTab
        ScrolLayers.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ScrolLayers.BackgroundTransparency = 0.9990000128746033
        ScrolLayers.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ScrolLayers.BorderSizePixel = 0
        ScrolLayers.Size = UDim2.new(1, 0, 1, 0)
        ScrolLayers.Name = "ScrolLayers"
        ScrolLayers.Parent = LayersFolder

        UIListLayout1.Padding = UDim.new(0, 3)
        UIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout1.Parent = ScrolLayers

        local Tab = Instance.new("Frame");
        local UICorner3 = Instance.new("UICorner");
        local TabButton = Instance.new("TextButton");
        local TabName = Instance.new("TextLabel")
        local UIStroke2 = Instance.new("UIStroke");
        local UICorner4 = Instance.new("UICorner");

        Tab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        if CountTab == 0 then
            Tab.BackgroundTransparency = 0.9200000166893005
        else
            Tab.BackgroundTransparency = 0.9990000128746033
        end
        Tab.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Tab.BorderSizePixel = 0
        Tab.LayoutOrder = CountTab
        Tab.Size = UDim2.new(1, 0, 0, 30)
        Tab.Name = "Tab"
        Tab.Parent = ScrollTab

        UICorner3.CornerRadius = UDim.new(0, 4)
        UICorner3.Parent = Tab

        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = ""
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.TextSize = 13
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.BackgroundTransparency = 0.9990000128746033
        TabButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, 0, 1, 0)
        TabButton.Name = "TabButton"
        TabButton.Parent = Tab

        TabName.Font = Enum.Font.GothamBold
        TabName.Text = tostring(TabConfig.Name)
        TabName.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabName.TextSize = 13
        TabName.TextXAlignment = Enum.TextXAlignment.Left
        TabName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabName.BackgroundTransparency = 0.9990000128746033
        TabName.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TabName.BorderSizePixel = 0
        TabName.Size = UDim2.new(1, 0, 1, 0)
        TabName.Position = UDim2.new(0, 8, 0, 0)
        TabName.Name = "TabName"
        TabName.Parent = Tab

        if CountTab == 0 then
            LayersPageLayout:JumpToIndex(0)
            NameTab.Text = TabConfig.Name
            local ChooseFrame = Instance.new("Frame");
            ChooseFrame.BackgroundColor3 = GuiConfig.Color
            ChooseFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            ChooseFrame.BorderSizePixel = 0
            ChooseFrame.Position = UDim2.new(0, 2, 0, 9)
            ChooseFrame.Size = UDim2.new(0, 1, 0, 12)
            ChooseFrame.Name = "ChooseFrame"
            ChooseFrame.Parent = Tab

            UIStroke2.Color = GuiConfig.Color
            UIStroke2.Thickness = 1.600000023841858
            UIStroke2.Parent = ChooseFrame

            UICorner4.Parent = ChooseFrame
        end

        local SelectEvent = Instance.new("BindableEvent")
        SelectEvent.Name = "SelectEvent"
        SelectEvent.Parent = Tab

        TabButton.Activated:Connect(function()
            CircleClick(TabButton, Mouse.X, Mouse.Y)
            SelectEvent:Fire()
        end)

        SelectEvent.Event:Connect(function()
            local FrameChoose
            for a, s in ScrollTab:GetChildren() do
                for i, v in s:GetChildren() do
                    if v.Name == "ChooseFrame" then
                        FrameChoose = v
                        break
                    end
                end
            end
            if FrameChoose ~= nil and Tab.LayoutOrder ~= LayersPageLayout.CurrentPage.LayoutOrder then
                for _, TabFrame in ScrollTab:GetChildren() do
                    if TabFrame.Name == "Tab" then
                        TweenService:Create(
                            TabFrame,
                            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                            { BackgroundTransparency = 0.9990000128746033 }
                        ):Play()
                    end
                end
                TweenService:Create(
                    Tab,
                    TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                    { BackgroundTransparency = 0.9200000166893005 }
                ):Play()
                TweenService:Create(
                    FrameChoose,
                    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    { Position = UDim2.new(0, 2, 0, 9 + (33 * Tab.LayoutOrder)) }
                ):Play()
                LayersPageLayout:JumpToIndex(Tab.LayoutOrder)
                task.wait(0.05)
                NameTab.Text = TabConfig.Name
                TweenService:Create(
                    FrameChoose,
                    TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    { Size = UDim2.new(0, 1, 0, 20) }
                ):Play()
                task.wait(0.2)
                TweenService:Create(
                    FrameChoose,
                    TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    { Size = UDim2.new(0, 1, 0, 12) }
                ):Play()
            end
        end)
        --// Section
        local Sections = {}
        local CountSection = 0
        function Sections:AddSection(Title, AlwaysOpen)
            local Title = Title or "Title"
            local Section = Instance.new("Frame");
            local UICorner1 = Instance.new("UICorner");
            local UIGradient = Instance.new("UIGradient");

            Section.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Section.BackgroundTransparency = 0.9990000128746033
            Section.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Section.BorderSizePixel = 0
            Section.LayoutOrder = CountSection
            Section.ClipsDescendants = true
            Section.LayoutOrder = 1
            Section.Size = UDim2.new(1, 0, 0, 30)
            Section.Name = "Section"
            Section.Parent = ScrolLayers

            local SectionReal = Instance.new("Frame");
            local UICorner = Instance.new("UICorner");
            local UIStroke = Instance.new("UIStroke");
            local SectionButton = Instance.new("TextButton");
            local FeatureFrame = Instance.new("Frame");
            local FeatureImg = Instance.new("ImageLabel");
            local SectionTitle = Instance.new("TextLabel");

            SectionReal.AnchorPoint = Vector2.new(0.5, 0)
            SectionReal.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionReal.BackgroundTransparency = 1
            SectionReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SectionReal.BorderSizePixel = 0
            SectionReal.LayoutOrder = 1
            SectionReal.Position = UDim2.new(0.5, 0, 0, 0)
            SectionReal.Size = UDim2.new(1, 1, 0, 30)
            SectionReal.Name = "SectionReal"
            SectionReal.Parent = Section

            UICorner.CornerRadius = UDim.new(0, 4)
            UICorner.Parent = SectionReal

            SectionButton.Font = Enum.Font.SourceSans
            SectionButton.Text = ""
            SectionButton.TextColor3 = Color3.fromRGB(0, 0, 0)
            SectionButton.TextSize = 14
            SectionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionButton.BackgroundTransparency = 0.9990000128746033
            SectionButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SectionButton.BorderSizePixel = 0
            SectionButton.Size = UDim2.new(1, 0, 1, 0)
            SectionButton.Name = "SectionButton"
            SectionButton.Parent = SectionReal

            FeatureFrame.AnchorPoint = Vector2.new(1, 0.5)
            FeatureFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            FeatureFrame.BackgroundTransparency = 0.9990000128746033
            FeatureFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            FeatureFrame.BorderSizePixel = 0
            FeatureFrame.Position = UDim2.new(1, -5, 0.5, 0)
            FeatureFrame.Size = UDim2.new(0, 20, 0, 20)
            FeatureFrame.Name = "FeatureFrame"
            FeatureFrame.Parent = SectionReal

            FeatureImg.Image = "rbxassetid://16851841101"
            FeatureImg.AnchorPoint = Vector2.new(0.5, 0.5)
            FeatureImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            FeatureImg.BackgroundTransparency = 0.9990000128746033
            FeatureImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
            FeatureImg.BorderSizePixel = 0
            FeatureImg.Position = UDim2.new(0.5, 0, 0.5, 0)
            FeatureImg.Rotation = -90
            FeatureImg.Size = UDim2.new(1, 6, 1, 6)
            FeatureImg.Name = "FeatureImg"
            FeatureImg.Parent = FeatureFrame

            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.Text = Title
            SectionTitle.TextColor3 = Color3.fromRGB(230.77499270439148, 230.77499270439148, 230.77499270439148)
            SectionTitle.TextSize = 13
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.TextYAlignment = Enum.TextYAlignment.Top
            SectionTitle.AnchorPoint = Vector2.new(0, 0.5)
            SectionTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionTitle.BackgroundTransparency = 0.9990000128746033
            SectionTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SectionTitle.BorderSizePixel = 0
            SectionTitle.Position = UDim2.new(0, 10, 0.5, 0)
            SectionTitle.Size = UDim2.new(1, -50, 0, 13)
            SectionTitle.Name = "SectionTitle"
            SectionTitle.Parent = SectionReal

            --// Section Add
            local SectionAdd = Instance.new("Frame");
            local UICorner8 = Instance.new("UICorner");
            local UIListLayout2 = Instance.new("UIListLayout");

            SectionAdd.AnchorPoint = Vector2.new(0.5, 0)
            SectionAdd.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionAdd.BackgroundTransparency = 0.9990000128746033
            SectionAdd.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SectionAdd.BorderSizePixel = 0
            SectionAdd.ClipsDescendants = true
            SectionAdd.LayoutOrder = 1
            SectionAdd.Position = UDim2.new(0.5, 0, 0, 32)
            SectionAdd.Size = UDim2.new(1, 0, 0, 100)
            SectionAdd.Name = "SectionAdd"
            SectionAdd.Parent = Section

            UICorner8.CornerRadius = UDim.new(0, 2)
            UICorner8.Parent = SectionAdd

            UIListLayout2.Padding = UDim.new(0, 3)
            UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout2.Parent = SectionAdd

            local OpenSection = false

            local function UpdateSizeScroll()
                local OffsetY = 0
                for _, child in ScrolLayers:GetChildren() do
                    if child.Name ~= "UIListLayout" then
                        OffsetY = OffsetY + 3 + child.Size.Y.Offset
                    end
                end
                ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
            end

            local function UpdateSizeSection()
                if OpenSection then
                    local SectionSizeYWitdh = 38
                    for _, v in SectionAdd:GetChildren() do
                        if v.Name ~= "UIListLayout" and v.Name ~= "UICorner" and v.Visible then
                            SectionSizeYWitdh = SectionSizeYWitdh + v.Size.Y.Offset + 3
                        end
                    end
                    TweenService:Create(FeatureFrame, TweenInfo.new(0.5), { Rotation = 90 }):Play()
                    TweenService:Create(SectionTitle, TweenInfo.new(0.5), { TextColor3 = GuiConfig.Color }):Play()
                    TweenService:Create(Section, TweenInfo.new(0.5), { Size = UDim2.new(1, 1, 0, SectionSizeYWitdh) })
                        :Play()
                    TweenService:Create(SectionAdd, TweenInfo.new(0.5),
                        { Size = UDim2.new(1, 0, 0, SectionSizeYWitdh - 38) }):Play()
                    task.wait(0.5)
                    UpdateSizeScroll()
                end
            end

            if AlwaysOpen == true then
                SectionButton:Destroy()
                FeatureFrame:Destroy()
                OpenSection = true
                UpdateSizeSection()
            elseif AlwaysOpen == false then
                OpenSection = true
                UpdateSizeSection()
            else
                OpenSection = false
            end

            if AlwaysOpen ~= true then
                SectionButton.Activated:Connect(function()
                    CircleClick(SectionButton, Mouse.X, Mouse.Y)
                    if OpenSection then
                        TweenService:Create(FeatureFrame, TweenInfo.new(0.5), { Rotation = 0 }):Play()
                        TweenService:Create(SectionTitle, TweenInfo.new(0.5), { TextColor3 = Color3.fromRGB(231, 231, 231) }):Play()
                        TweenService:Create(Section, TweenInfo.new(0.5), { Size = UDim2.new(1, 1, 0, 30) }):Play()
                        OpenSection = false
                        task.wait(0.5)
                        UpdateSizeScroll()
                    else
                        OpenSection = true
                        UpdateSizeSection()
                    end
                end)
            end

            if AlwaysOpen == true or AlwaysOpen == false then
                OpenSection = true
                local SectionSizeYWitdh = 38
                for _, v in SectionAdd:GetChildren() do
                    if v.Name ~= "UIListLayout" and v.Name ~= "UICorner" and v.Visible then
                        SectionSizeYWitdh = SectionSizeYWitdh + v.Size.Y.Offset + 3
                    end
                end
                FeatureFrame.Rotation = 90
                SectionTitle.TextColor3 = GuiConfig.Color
                Section.Size = UDim2.new(1, 1, 0, SectionSizeYWitdh)
                SectionAdd.Size = UDim2.new(1, 0, 0, SectionSizeYWitdh - 38)
                UpdateSizeScroll()
            end

            SectionAdd.ChildAdded:Connect(function(child)
                if child:IsA("GuiObject") then
                    child:GetPropertyChangedSignal("Visible"):Connect(UpdateSizeSection)
                end
                UpdateSizeSection()
            end)
            SectionAdd.ChildRemoved:Connect(UpdateSizeSection)

            local layout = ScrolLayers:FindFirstChildOfClass("UIListLayout")
            if layout then
                layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
                end)
            end

            local Items = {}
            local CountItem = 0

            function Items:AddParagraph(ParagraphConfig)
                local ParagraphConfig = ParagraphConfig or {}
                ParagraphConfig.Title = ParagraphConfig.Title or "Title"
                ParagraphConfig.Content = ParagraphConfig.Content or "Content"
                local ParagraphFunc = {}

                local Paragraph = Instance.new("Frame")
                local UICorner14 = Instance.new("UICorner")
                local ParagraphTitle = Instance.new("TextLabel")
                local ParagraphContent = Instance.new("TextLabel")

                Paragraph.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Paragraph.BackgroundTransparency = 0.935
                Paragraph.BorderSizePixel = 0
                Paragraph.LayoutOrder = CountItem
                Paragraph.Size = UDim2.new(1, 0, 0, 46)
                Paragraph.Name = "Paragraph"
                Paragraph.Parent = SectionAdd

                UICorner14.CornerRadius = UDim.new(0, 4)
                UICorner14.Parent = Paragraph

                local iconOffset = 10
                if ParagraphConfig.Icon then
                    local IconImg = Instance.new("ImageLabel")
                    IconImg.Size = UDim2.new(0, 20, 0, 20)
                    IconImg.Position = UDim2.new(0, 8, 0, 12)
                    IconImg.BackgroundTransparency = 1
                    IconImg.Name = "ParagraphIcon"
                    IconImg.Parent = Paragraph

                    if Icons and Icons[ParagraphConfig.Icon] then
                        IconImg.Image = Icons[ParagraphConfig.Icon]
                    else
                        IconImg.Image = ParagraphConfig.Icon
                    end

                    iconOffset = 30
                end

                ParagraphTitle.Font = Enum.Font.GothamBold
                ParagraphTitle.Text = ParagraphConfig.Title
                ParagraphTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
                ParagraphTitle.TextSize = 13
                ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
                ParagraphTitle.TextYAlignment = Enum.TextYAlignment.Top
                ParagraphTitle.BackgroundTransparency = 1
                ParagraphTitle.Position = UDim2.new(0, iconOffset, 0, 10)
                ParagraphTitle.Size = UDim2.new(1, -16, 0, 13)
                ParagraphTitle.Name = "ParagraphTitle"
                ParagraphTitle.Parent = Paragraph

                ParagraphContent.Font = Enum.Font.Gotham
                ParagraphContent.Text = ParagraphConfig.Content
                ParagraphContent.TextColor3 = Color3.fromRGB(220, 225, 235)
                ParagraphContent.TextSize = 12
                ParagraphContent.TextXAlignment = Enum.TextXAlignment.Left
                ParagraphContent.TextYAlignment = Enum.TextYAlignment.Top
                ParagraphContent.BackgroundTransparency = 1
                ParagraphContent.Position = UDim2.new(0, iconOffset, 0, 28)
                ParagraphContent.Name = "ParagraphContent"
                ParagraphContent.TextWrapped = true
                ParagraphContent.RichText = true
                ParagraphContent.Parent = Paragraph

                local ParagraphButton
                if ParagraphConfig.ButtonText then
                    ParagraphButton = Instance.new("TextButton")
                    ParagraphButton.Name = "ParagraphButton"
                    ParagraphButton.Size = UDim2.new(1, -20, 0, 28)
                    ParagraphButton.BackgroundColor3 = Color3.fromRGB(30, 150, 255)
                    ParagraphButton.BackgroundTransparency = 0.2
                    ParagraphButton.Font = Enum.Font.GothamBold
                    ParagraphButton.TextSize = 12
                    ParagraphButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    ParagraphButton.Text = ParagraphConfig.ButtonText
                    ParagraphButton.Parent = Paragraph

                    local btnCorner = Instance.new("UICorner")
                    btnCorner.CornerRadius = UDim.new(0, 4)
                    btnCorner.Parent = ParagraphButton

                    if ParagraphConfig.ButtonCallback then
                        ParagraphButton.MouseButton1Click:Connect(ParagraphConfig.ButtonCallback)
                    end
                end

                local function UpdateSize()
                    local contentH = ParagraphContent.TextBounds.Y
                    ParagraphContent.Size = UDim2.new(1, -(iconOffset + 12), 0, contentH)
                    if ParagraphButton then
                        ParagraphButton.Position = UDim2.new(0, 10, 0, 28 + contentH + 8)
                        Paragraph.Size = UDim2.new(1, 0, 0, 28 + contentH + 8 + ParagraphButton.Size.Y.Offset + 10)
                    else
                        Paragraph.Size = UDim2.new(1, 0, 0, math.max(46, 28 + contentH + 10))
                    end
                end

                UpdateSize()

                ParagraphContent:GetPropertyChangedSignal("TextBounds"):Connect(UpdateSize)

                function ParagraphFunc:SetContent(content)
                    content = content or "Content"
                    ParagraphContent.Text = content
                    UpdateSize()
                end

                function ParagraphFunc:SetTitle(title)
                    ParagraphTitle.Text = title or "Title"
                end

                ParagraphFunc.Frame = Paragraph
                CountItem = CountItem + 1
                return ParagraphFunc
            end

            function Items:AddPanel(PanelConfig)
                PanelConfig = PanelConfig or {}
                PanelConfig.Title = PanelConfig.Title or "Title"
                PanelConfig.Content = PanelConfig.Content or ""
                PanelConfig.Placeholder = PanelConfig.Placeholder or nil
                PanelConfig.Default = PanelConfig.Default or ""
                PanelConfig.ButtonText = PanelConfig.Button or PanelConfig.ButtonText or "Confirm"
                PanelConfig.ButtonCallback = PanelConfig.Callback or PanelConfig.ButtonCallback or function() end
                PanelConfig.SubButtonText = PanelConfig.SubButton or PanelConfig.SubButtonText or nil
                PanelConfig.SubButtonCallback = PanelConfig.SubCallback or PanelConfig.SubButtonCallback or
                    function() end

                local configKey = "Panel_" .. PanelConfig.Title
                if ConfigData[configKey] ~= nil then
                    PanelConfig.Default = ConfigData[configKey]
                end

                local PanelFunc = { Value = PanelConfig.Default }

                local baseHeight = 50

                if PanelConfig.Placeholder then
                    baseHeight = baseHeight + 40
                end

                if PanelConfig.SubButtonText then
                    baseHeight = baseHeight + 40
                else
                    baseHeight = baseHeight + 36
                end

                local Panel = Instance.new("Frame")
                Panel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Panel.BackgroundTransparency = 0.935
                Panel.Size = UDim2.new(1, 0, 0, baseHeight)
                Panel.LayoutOrder = CountItem
                Panel.Parent = SectionAdd

                local UICorner = Instance.new("UICorner")
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = Panel

                local Title = Instance.new("TextLabel")
                Title.Font = Enum.Font.GothamBold
                Title.Text = PanelConfig.Title
                Title.TextSize = 13
                Title.TextColor3 = Color3.fromRGB(255, 255, 255)
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 10, 0, 10)
                Title.Size = UDim2.new(1, -20, 0, 13)
                Title.Parent = Panel

                local Content = Instance.new("TextLabel")
                Content.Font = Enum.Font.Gotham
                Content.Text = PanelConfig.Content
                Content.TextSize = 12
                Content.TextColor3 = Color3.fromRGB(255, 255, 255)
                Content.TextTransparency = 0
                Content.TextXAlignment = Enum.TextXAlignment.Left
                Content.BackgroundTransparency = 1
                Content.RichText = true
                Content.Position = UDim2.new(0, 10, 0, 28)
                Content.Size = UDim2.new(1, -20, 0, 14)
                Content.Parent = Panel

                local InputBox
                if PanelConfig.Placeholder then
                    local InputFrame = Instance.new("Frame")
                    InputFrame.AnchorPoint = Vector2.new(0.5, 0)
                    InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    InputFrame.BackgroundTransparency = 0.95
                    InputFrame.Position = UDim2.new(0.5, 0, 0, 48)
                    InputFrame.Size = UDim2.new(1, -20, 0, 30)
                    InputFrame.Parent = Panel

                    local inputCorner = Instance.new("UICorner")
                    inputCorner.CornerRadius = UDim.new(0, 4)
                    inputCorner.Parent = InputFrame

                    InputBox = Instance.new("TextBox")
                    InputBox.Font = Enum.Font.GothamBold
                    InputBox.PlaceholderText = PanelConfig.Placeholder
                    InputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
                    InputBox.Text = PanelConfig.Default
                    InputBox.TextSize = 11
                    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                    InputBox.BackgroundTransparency = 1
                    InputBox.TextXAlignment = Enum.TextXAlignment.Left
                    InputBox.Size = UDim2.new(1, -10, 1, -6)
                    InputBox.Position = UDim2.new(0, 5, 0, 3)
                    InputBox.Parent = InputFrame
                end

                local yBtn = 0
                if PanelConfig.Placeholder then
                    yBtn = 88
                else
                    yBtn = 48
                end

                local ButtonMain = Instance.new("TextButton")
                ButtonMain.Font = Enum.Font.GothamBold
                ButtonMain.Text = PanelConfig.ButtonText
                ButtonMain.TextColor3 = Color3.fromRGB(255, 255, 255)
                ButtonMain.TextSize = 12
                ButtonMain.TextTransparency = 0.3
                ButtonMain.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ButtonMain.BackgroundTransparency = 0.935
                ButtonMain.Size = PanelConfig.SubButtonText and UDim2.new(0.5, -12, 0, 30) or UDim2.new(1, -20, 0, 30)
                ButtonMain.Position = UDim2.new(0, 10, 0, yBtn)
                ButtonMain.Parent = Panel

                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 6)
                btnCorner.Parent = ButtonMain

                ButtonMain.MouseButton1Click:Connect(function()
                    PanelConfig.ButtonCallback(InputBox and InputBox.Text or "")
                end)

                if PanelConfig.SubButtonText then
                    local SubButton = Instance.new("TextButton")
                    SubButton.Font = Enum.Font.GothamBold
                    SubButton.Text = PanelConfig.SubButtonText
                    SubButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    SubButton.TextSize = 12
                    SubButton.TextTransparency = 0.3
                    SubButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    SubButton.BackgroundTransparency = 0.935
                    SubButton.Size = UDim2.new(0.5, -12, 0, 30)
                    SubButton.Position = UDim2.new(0.5, 2, 0, yBtn)
                    SubButton.Parent = Panel

                    local subCorner = Instance.new("UICorner")
                    subCorner.CornerRadius = UDim.new(0, 6)
                    subCorner.Parent = SubButton

                    SubButton.MouseButton1Click:Connect(function()
                        PanelConfig.SubButtonCallback(InputBox and InputBox.Text or "")
                    end)
                end

                if InputBox then
                    InputBox.FocusLost:Connect(function()
                        PanelFunc.Value = InputBox.Text
                        ConfigData[configKey] = InputBox.Text
                        SaveConfig()
                    end)
                end

                function PanelFunc:GetInput()
                    return InputBox and InputBox.Text or ""
                end

                CountItem = CountItem + 1
                return PanelFunc
            end

            function Items:AddButton(ButtonConfig)
                ButtonConfig = ButtonConfig or {}
                ButtonConfig.Title = ButtonConfig.Title or "Confirm"
                ButtonConfig.Callback = ButtonConfig.Callback or function() end
                ButtonConfig.SubTitle = ButtonConfig.SubTitle or nil
                ButtonConfig.SubCallback = ButtonConfig.SubCallback or function() end

                local Button = Instance.new("Frame")
                Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Button.BackgroundTransparency = 1
                Button.Size = UDim2.new(1, 0, 0, 40)
                Button.LayoutOrder = CountItem
                Button.Parent = SectionAdd

                local UICorner = Instance.new("UICorner")
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = Button

                -- Konfigurasi Animasi
                local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

                -- MAIN BUTTON
                local MainButton = Instance.new("TextButton")
                MainButton.Font = Enum.Font.GothamBold
                MainButton.Text = "    " .. ButtonConfig.Title
                MainButton.TextSize = 12
                MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                MainButton.TextTransparency = 0.3
                MainButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                MainButton.BackgroundTransparency = 0.935
                MainButton.AutoButtonColor = false
                MainButton.TextXAlignment = Enum.TextXAlignment.Left

                local ButtonIcon = Instance.new("ImageLabel")
                ButtonIcon.Name = "Icon"
                ButtonIcon.Parent = MainButton -- Masuk ke dalam MainButton

                -- Ukuran & Posisi (Sesuaikan angka di bawah dengan kebutuhanmu)
                ButtonIcon.Size = UDim2.new(0, 20, 0, 20) -- Ganti 20, 20 dengan ukuranmu
                ButtonIcon.Position = UDim2.new(0.92, 0, 0.5, 0) -- Ganti 5 dengan posisi X keinginanmu
                ButtonIcon.AnchorPoint = Vector2.new(0, 0.5) -- Agar posisi Y (0.5) benar-benar di tengah vertikal

                -- Properti Tampilan
                ButtonIcon.BackgroundTransparency = 1 -- Agar background icon tidak kelihatan
                ButtonIcon.Image = "rbxassetid://90520342625816" -- Ganti 0 dengan ID gambarmu
                ButtonIcon.ImageColor3 = Color3.fromRGB(255, 255, 255) -- Warna icon
                ButtonIcon.ImageTransparency = 0.3 -- Biar estetik (cocok dengan teksmu yang transparan 0.3)
                ButtonIcon.ScaleType = Enum.ScaleType.Fit -- Agar gambar tidak gepeng
                
                local mainNormalSize = ButtonConfig.SubTitle
                    and UDim2.new(0.5, -4, 1, 0)
                    or  UDim2.new(1, 0, 1, 0)
                local mainShrinkSize = UDim2.new(
                    mainNormalSize.X.Scale,
                    mainNormalSize.X.Offset - 2,
                    mainNormalSize.Y.Scale,
                    mainNormalSize.Y.Offset - 2
                )

                MainButton.Size     = mainNormalSize
                MainButton.Position = UDim2.new(0, 0, 0, 0)
                MainButton.AnchorPoint = Vector2.new(0, 0)
                MainButton.Parent = Button


                local mainCorner = Instance.new("UICorner")
                mainCorner.CornerRadius = UDim.new(0, 4)
                mainCorner.Parent = MainButton

                -- Efek Animasi Main Button
                MainButton.MouseButton1Down:Connect(function()
                    TweenService:Create(MainButton, tweenInfo, {Size = mainShrinkSize}):Play()
                end)
                MainButton.MouseButton1Up:Connect(function()
                    TweenService:Create(MainButton, tweenInfo, {Size = mainNormalSize}):Play()
                end)
                MainButton.MouseLeave:Connect(function()
                    TweenService:Create(MainButton, tweenInfo, {Size = mainNormalSize}):Play()
                end)

                MainButton.MouseButton1Click:Connect(ButtonConfig.Callback)

                -- SUB BUTTON
                if ButtonConfig.SubTitle then
                    local SubButton = Instance.new("TextButton")
                    SubButton.Font = Enum.Font.GothamBold
                    SubButton.Text = "    " .. ButtonConfig.SubTitle
                    SubButton.TextSize = 12
                    SubButton.TextTransparency = 0.3
                    SubButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    SubButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    SubButton.BackgroundTransparency = 0.935
                    SubButton.AutoButtonColor = false
                    SubButton.TextXAlignment = Enum.TextXAlignment.Left
                    
                    local SubButtonIcon = Instance.new("ImageLabel")
                    SubButtonIcon.Name = "Icon"
                    SubButtonIcon.Parent = SubButton
                    SubButtonIcon.Size = UDim2.new(0, 20, 0, 20)
                    SubButtonIcon.Position = UDim2.new(0.92, 0, 0.5, 0)
                    SubButtonIcon.AnchorPoint = Vector2.new(0, 0.5)
                    SubButtonIcon.BackgroundTransparency = 1
                    SubButtonIcon.Image = "rbxassetid://90520342625816"
                    SubButtonIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
                    SubButtonIcon.ImageTransparency = 0.3
                    SubButtonIcon.ScaleType = Enum.ScaleType.Fit

                    local subNormalSize = UDim2.new(0.5, -4, 1, 0)
                    local subShrinkSize = UDim2.new(
                        subNormalSize.X.Scale,
                        subNormalSize.X.Offset - 2,
                        subNormalSize.Y.Scale,
                        subNormalSize.Y.Offset - 2
                    )

                    SubButton.Size     = subNormalSize
                    SubButton.Position = UDim2.new(0.5, 4, 0, 0)
                    SubButton.AnchorPoint = Vector2.new(0, 0)
                    SubButton.Parent = Button


                    local subCorner = Instance.new("UICorner")
                    subCorner.CornerRadius = UDim.new(0, 4)
                    subCorner.Parent = SubButton

                    -- Efek Animasi Sub Button
                    SubButton.MouseButton1Down:Connect(function()
                        TweenService:Create(SubButton, tweenInfo, {Size = subShrinkSize}):Play()
                    end)
                    SubButton.MouseButton1Up:Connect(function()
                        TweenService:Create(SubButton, tweenInfo, {Size = subNormalSize}):Play()
                    end)
                    SubButton.MouseLeave:Connect(function()
                        TweenService:Create(SubButton, tweenInfo, {Size = subNormalSize}):Play()
                    end)

                    SubButton.MouseButton1Click:Connect(ButtonConfig.SubCallback)
                end

                CountItem = CountItem + 1
            end

            function Items:AddToggle(ToggleConfig)
                local ToggleConfig = ToggleConfig or {}
                ToggleConfig.Title = ToggleConfig.Title or "Title"
                ToggleConfig.Title2 = ToggleConfig.Title2 or ""
                ToggleConfig.Content = ToggleConfig.Content or ""
                ToggleConfig.Default = ToggleConfig.Default or false
                ToggleConfig.Callback = ToggleConfig.Callback or function() end
                ToggleConfig.Keybind = ToggleConfig.Keybind or false

                local configKey = "Toggle_" .. ToggleConfig.Title
                local keybindConfigKey = configKey .. "_Keybind"

                if ConfigData[configKey] ~= nil then
                    ToggleConfig.Default = ConfigData[configKey]
                end

                local currentKeybind = nil
                if ConfigData[keybindConfigKey] ~= nil then
                    currentKeybind = ConfigData[keybindConfigKey]
                end

                local ToggleFunc = { Value = ToggleConfig.Default }

                local Toggle = Instance.new("Frame")
                local UICorner20 = Instance.new("UICorner")
                local ToggleTitle = Instance.new("TextLabel")
                local ToggleContent = Instance.new("TextLabel")
                local ToggleButton = Instance.new("TextButton")
                local FeatureFrame2 = Instance.new("Frame")
                local KeybindFrame = Instance.new("Frame")
                local UICorner22 = Instance.new("UICorner")
                local UIStroke8 = Instance.new("UIStroke")
                local ToggleCircle = Instance.new("Frame")
                local UICorner23 = Instance.new("UICorner")
                local UICorner24 = Instance.new("UICorner")
                local KeybindButton = Instance.new("TextButton")

                Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Toggle.BackgroundTransparency = 0.935
                Toggle.BorderSizePixel = 0
                Toggle.LayoutOrder = CountItem
                Toggle.Name = "Toggle"
                Toggle.Parent = SectionAdd

                UICorner20.CornerRadius = UDim.new(0, 4)
                UICorner20.Parent = Toggle

                ToggleTitle.Font = Enum.Font.GothamBold
                ToggleTitle.Text = ToggleConfig.Title
                ToggleTitle.TextSize = 13
                ToggleTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
                ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
                ToggleTitle.TextYAlignment = Enum.TextYAlignment.Top
                ToggleTitle.BackgroundTransparency = 1
                ToggleTitle.Position = UDim2.new(0, 10, 0, 10)
                ToggleTitle.Size = UDim2.new(1, -100, 0, 13)
                ToggleTitle.Name = "ToggleTitle"
                ToggleTitle.Parent = Toggle

                local ToggleTitle2 = Instance.new("TextLabel")
                ToggleTitle2.Font = Enum.Font.GothamBold
                ToggleTitle2.Text = ToggleConfig.Title2
                ToggleTitle2.TextSize = 12
                ToggleTitle2.TextColor3 = Color3.fromRGB(231, 231, 231)
                ToggleTitle2.TextXAlignment = Enum.TextXAlignment.Left
                ToggleTitle2.TextYAlignment = Enum.TextYAlignment.Top
                ToggleTitle2.BackgroundTransparency = 1
                ToggleTitle2.Position = UDim2.new(0, 10, 0, 23)
                ToggleTitle2.Size = UDim2.new(1, -100, 0, 12)
                ToggleTitle2.Name = "ToggleTitle2"
                ToggleTitle2.Parent = Toggle

                ToggleContent.Font = Enum.Font.GothamBold
                ToggleContent.Text = ToggleConfig.Content
                ToggleContent.TextColor3 = Color3.fromRGB(255, 255, 255)
                ToggleContent.TextSize = 12
                ToggleContent.TextTransparency = 0.6
                ToggleContent.TextXAlignment = Enum.TextXAlignment.Left
                ToggleContent.TextYAlignment = Enum.TextYAlignment.Bottom
                ToggleContent.BackgroundTransparency = 1
                ToggleContent.Size = UDim2.new(1, -100, 0, 12)
                ToggleContent.Name = "ToggleContent"
                ToggleContent.Parent = Toggle

                if ToggleConfig.Title2 ~= "" then
                    Toggle.Size = UDim2.new(1, 0, 0, 57)
                    ToggleContent.Position = UDim2.new(0, 10, 0, 36)
                    ToggleTitle2.Visible = true
                else
                    Toggle.Size = UDim2.new(1, 0, 0, 46)
                    ToggleContent.Position = UDim2.new(0, 10, 0, 23)
                    ToggleTitle2.Visible = false
                end

                ToggleContent.Size = UDim2.new(1, -100, 0,
                    12 + (12 * (ToggleContent.TextBounds.X // ToggleContent.AbsoluteSize.X)))
                ToggleContent.TextWrapped = true
                if ToggleConfig.Title2 ~= "" then
                    Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 47)
                else
                    Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 33)
                end

                ToggleContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    ToggleContent.TextWrapped = false
                    ToggleContent.Size = UDim2.new(1, -100, 0,
                        12 + (12 * (ToggleContent.TextBounds.X // ToggleContent.AbsoluteSize.X)))
                    if ToggleConfig.Title2 ~= "" then
                        Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 47)
                    else
                        Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 33)
                    end
                    ToggleContent.TextWrapped = true
                    UpdateSizeSection()
                end)

                ToggleButton.Font = Enum.Font.SourceSans
                ToggleButton.Text = ""
                ToggleButton.BackgroundTransparency = 1
                ToggleButton.Size = UDim2.new(1, 0, 1, 0)
                ToggleButton.Name = "ToggleButton"
                ToggleButton.Parent = Toggle

                FeatureFrame2.AnchorPoint = Vector2.new(1, 0.5)
                FeatureFrame2.BackgroundTransparency = 0.92
                FeatureFrame2.BorderSizePixel = 0
                FeatureFrame2.Position = UDim2.new(1, -15, 0.5, 0)
                FeatureFrame2.Size = UDim2.new(0, 30, 0, 15)
                FeatureFrame2.Name = "FeatureFrame"
                FeatureFrame2.Parent = Toggle

                UICorner22.Parent = FeatureFrame2

                UIStroke8.Color = Color3.fromRGB(255, 255, 255)
                UIStroke8.Thickness = 2
                UIStroke8.Transparency = 0.9
                UIStroke8.Parent = FeatureFrame2

                ToggleCircle.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
                ToggleCircle.BorderSizePixel = 0
                ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
                ToggleCircle.Name = "ToggleCircle"
                ToggleCircle.Parent = FeatureFrame2

                UICorner23.CornerRadius = UDim.new(0, 15)
                UICorner23.Parent = ToggleCircle

                KeybindFrame.AnchorPoint = Vector2.new(1, 0.5)
                KeybindFrame.BackgroundTransparency = 0.92
                KeybindFrame.BorderSizePixel = 0
                KeybindFrame.Position = UDim2.new(0.9, -20, 0.5, 0)
                KeybindFrame.Size = UDim2.new(0, 70, 0, 20)
                KeybindFrame.Name = "KeybindFrame"
                KeybindFrame.Parent = Toggle

                UICorner24.Parent = KeybindFrame

                KeybindButton.Font = Enum.Font.GothamBold
                KeybindButton.Text = "Keybind"
                KeybindButton.BackgroundTransparency = 1
                KeybindButton.Size = UDim2.new(1, 0, 1, 0)
                KeybindButton.Position = UDim2.new(0, 0, 0, 0)
                KeybindButton.TextXAlignment = Enum.TextXAlignment.Center
                KeybindButton.TextYAlignment = Enum.TextYAlignment.Center
                KeybindButton.Name = "KeybindButton"
                KeybindButton.TextColor3 = Color3.fromRGB(225, 225, 225)
                KeybindButton.TextSize = 12
                KeybindButton.Parent = KeybindFrame

                local isRecording = false
                local lastRecordCancel = 0

                local ignoredKeys = {
                    [Enum.KeyCode.LeftControl] = true, [Enum.KeyCode.RightControl] = true,
                    [Enum.KeyCode.LeftAlt] = true, [Enum.KeyCode.RightAlt] = true,
                    [Enum.KeyCode.LeftShift] = true, [Enum.KeyCode.RightShift] = true,
                    [Enum.KeyCode.Unknown] = true
                }

                local function GetModifiersString(excludeKey)
                    local keys = ""
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and excludeKey ~= Enum.KeyCode.LeftControl then keys = keys .. "LeftControl + " end
                    if UserInputService:IsKeyDown(Enum.KeyCode.RightControl) and excludeKey ~= Enum.KeyCode.RightControl then keys = keys .. "RightControl + " end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) and excludeKey ~= Enum.KeyCode.LeftAlt then keys = keys .. "LeftAlt + " end
                    if UserInputService:IsKeyDown(Enum.KeyCode.RightAlt) and excludeKey ~= Enum.KeyCode.RightAlt then keys = keys .. "RightAlt + " end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and excludeKey ~= Enum.KeyCode.LeftShift then keys = keys .. "LeftShift + " end
                    if UserInputService:IsKeyDown(Enum.KeyCode.RightShift) and excludeKey ~= Enum.KeyCode.RightShift then keys = keys .. "RightShift + " end
                    return keys
                end

                KeybindButton:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    KeybindFrame.Size = UDim2.new(0, KeybindButton.TextBounds.X + 20, 0, 20)
                end)

                if not ToggleConfig.Keybind or isMobile then
                    KeybindFrame.Visible = false
                else
                    if currentKeybind then
                        KeybindButton.Text = "[ " .. currentKeybind .. " ]"
                    else
                        KeybindButton.Text = "Keybind"
                    end

                    KeybindButton.MouseButton1Click:Connect(function()
                        if not isRecording and tick() - lastRecordCancel > 0.1 then
                            isRecording = true
                            KeybindButton.Text = "[ ... ]"
                        end
                    end)

                    UserInputService.InputBegan:Connect(function(input, gameProcessed)
                        if isRecording then
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                isRecording = false
                                lastRecordCancel = tick()
                                currentKeybind = nil
                                KeybindButton.Text = "Keybind"
                                ConfigData[keybindConfigKey] = nil
                                SaveConfig()
                            elseif input.UserInputType == Enum.UserInputType.Keyboard then
                                local key = input.KeyCode
                                if key == Enum.KeyCode.Escape or key == Enum.KeyCode.Backspace then
                                    isRecording = false
                                    currentKeybind = nil
                                    KeybindButton.Text = "Keybind"
                                    ConfigData[keybindConfigKey] = nil
                                    SaveConfig()
                                elseif ignoredKeys[key] then
                                    if key ~= Enum.KeyCode.Unknown then
                                        KeybindButton.Text = "[ " .. GetModifiersString() .. "... ]"
                                    end
                                else
                                    local finalBind = GetModifiersString() .. key.Name
                                    currentKeybind = finalBind
                                    KeybindButton.Text = "[ " .. finalBind .. " ]"
                                    isRecording = false
                                    ConfigData[keybindConfigKey] = currentKeybind
                                    SaveConfig()
                                end
                            end
                        else
                            if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
                                if currentKeybind then
                                    local checkStr = GetModifiersString(input.KeyCode) .. input.KeyCode.Name
                                    if checkStr == currentKeybind then
                                        ToggleFunc.Value = not ToggleFunc.Value
                                        ToggleFunc:Set(ToggleFunc.Value)
                                    end
                                end
                            end
                        end
                    end)

                    UserInputService.InputEnded:Connect(function(input, gameProcessed)
                        if isRecording and ignoredKeys[input.KeyCode] and input.KeyCode ~= Enum.KeyCode.Unknown then
                            currentKeybind = input.KeyCode.Name
                            KeybindButton.Text = "[ " .. currentKeybind .. " ]"
                            isRecording = false
                            ConfigData[keybindConfigKey] = currentKeybind
                            SaveConfig()
                        end
                    end)
                end

                ToggleButton.Activated:Connect(function()
                    ToggleFunc.Value = not ToggleFunc.Value
                    ToggleFunc:Set(ToggleFunc.Value)
                end)

                function ToggleFunc:Set(Value)
                    if typeof(ToggleConfig.Callback) == "function" then
                        local ok, err = pcall(function()
                            ToggleConfig.Callback(Value)
                        end)
                        if not ok then warn("Toggle Callback error:", err) end
                    end
                    ConfigData[configKey] = Value
                    SaveConfig()
                    if Value then
                        TweenService:Create(ToggleTitle, TweenInfo.new(0.2), { TextColor3 = GuiConfig.Color }):Play()
                        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 15, 0, 0), BackgroundColor3 = Color3.fromRGB(46, 46, 46) })
                            :Play()
                        TweenService:Create(UIStroke8, TweenInfo.new(0.2), { Color = GuiConfig.Color, Transparency = 0 })
                            :Play()
                        TweenService:Create(FeatureFrame2, TweenInfo.new(0.2),
                            { BackgroundColor3 = GuiConfig.Color, BackgroundTransparency = 0 }):Play()
                    else
                        TweenService:Create(ToggleTitle, TweenInfo.new(0.2),
                            { TextColor3 = Color3.fromRGB(230, 230, 230) }):Play()
                        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(230, 230, 230) }):Play()
                        TweenService:Create(UIStroke8, TweenInfo.new(0.2),
                            { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.9 }):Play()
                        TweenService:Create(FeatureFrame2, TweenInfo.new(0.2),
                            { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92 }):Play()
                    end
                end

                ToggleFunc:Set(ToggleFunc.Value)
                CountItem = CountItem + 1
                Elements[configKey] = ToggleFunc
                return ToggleFunc
            end

            function Items:AddSlider(SliderConfig)
                local SliderConfig = SliderConfig or {}
                SliderConfig.Title = SliderConfig.Title or "Slider"
                SliderConfig.Content = SliderConfig.Content or ""
                SliderConfig.Increment = SliderConfig.Increment or 1
                SliderConfig.Min = SliderConfig.Min or 0
                SliderConfig.Max = SliderConfig.Max or 100
                SliderConfig.Default = SliderConfig.Default or 50
                SliderConfig.Callback = SliderConfig.Callback or function() end

                local configKey = "Slider_" .. SliderConfig.Title
                if ConfigData[configKey] ~= nil then
                    SliderConfig.Default = ConfigData[configKey]
                end

                local SliderFunc = { Value = SliderConfig.Default }

                local Slider = Instance.new("Frame");
                local UICorner15 = Instance.new("UICorner");
                local SliderTitle = Instance.new("TextLabel");
                local SliderContent = Instance.new("TextLabel");
                local SliderInput = Instance.new("Frame");
                local UICorner16 = Instance.new("UICorner");
                local TextBox = Instance.new("TextBox");
                local SliderFrame = Instance.new("Frame");
                local UICorner17 = Instance.new("UICorner");
                local SliderDraggable = Instance.new("Frame");
                local UICorner18 = Instance.new("UICorner");
                local UIStroke5 = Instance.new("UIStroke");
                local SliderCircle = Instance.new("Frame");
                local UICorner19 = Instance.new("UICorner");
                local UIStroke6 = Instance.new("UIStroke");
                local UIStroke7 = Instance.new("UIStroke");

                Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Slider.BackgroundTransparency = 0.935
                Slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Slider.BorderSizePixel = 0
                Slider.LayoutOrder = CountItem
                Slider.Size = UDim2.new(1, 0, 0, 46)
                Slider.Name = "Slider"
                Slider.Parent = SectionAdd

                UICorner15.CornerRadius = UDim.new(0, 4)
                UICorner15.Parent = Slider

                SliderTitle.Font = Enum.Font.GothamBold
                SliderTitle.Text = SliderConfig.Title
                SliderTitle.TextColor3 = Color3.fromRGB(230.77499270439148, 230.77499270439148, 230.77499270439148)
                SliderTitle.TextSize = 13
                SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
                SliderTitle.TextYAlignment = Enum.TextYAlignment.Top
                SliderTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderTitle.BackgroundTransparency = 0.9990000128746033
                SliderTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
                SliderTitle.BorderSizePixel = 0
                SliderTitle.Position = UDim2.new(0, 10, 0, 10)
                SliderTitle.Size = UDim2.new(1, -180, 0, 13)
                SliderTitle.Name = "SliderTitle"
                SliderTitle.Parent = Slider

                SliderContent.Font = Enum.Font.GothamBold
                SliderContent.Text = SliderConfig.Content
                SliderContent.TextColor3 = Color3.fromRGB(255, 255, 255)
                SliderContent.TextSize = 12
                SliderContent.TextTransparency = 0.6000000238418579
                SliderContent.TextXAlignment = Enum.TextXAlignment.Left
                SliderContent.TextYAlignment = Enum.TextYAlignment.Bottom
                SliderContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderContent.BackgroundTransparency = 0.9990000128746033
                SliderContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
                SliderContent.BorderSizePixel = 0
                SliderContent.Position = UDim2.new(0, 10, 0, 25)
                SliderContent.Size = UDim2.new(1, -180, 0, 12)
                SliderContent.Name = "SliderContent"
                SliderContent.Parent = Slider

                SliderContent.Size = UDim2.new(1, -180, 0,
                    12 + (12 * (SliderContent.TextBounds.X // SliderContent.AbsoluteSize.X)))
                SliderContent.TextWrapped = true
                Slider.Size = UDim2.new(1, 0, 0, SliderContent.AbsoluteSize.Y + 33)

                SliderContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    SliderContent.TextWrapped = false
                    SliderContent.Size = UDim2.new(1, -180, 0,
                        12 + (12 * (SliderContent.TextBounds.X // SliderContent.AbsoluteSize.X)))
                    Slider.Size = UDim2.new(1, 0, 0, SliderContent.AbsoluteSize.Y + 33)
                    SliderContent.TextWrapped = true
                    UpdateSizeSection()
                end)

                SliderInput.AnchorPoint = Vector2.new(0, 0.5)
                SliderInput.BackgroundColor3 = GuiConfig.Color
                SliderInput.BorderColor3 = Color3.fromRGB(0, 0, 0)
                SliderInput.BackgroundTransparency = 1
                SliderInput.BorderSizePixel = 0
                SliderInput.Position = UDim2.new(1, -155, 0.5, 0)
                SliderInput.Size = UDim2.new(0, 28, 0, 20)
                SliderInput.Name = "SliderInput"
                SliderInput.Parent = Slider

                UICorner16.CornerRadius = UDim.new(0, 2)
                UICorner16.Parent = SliderInput

                TextBox.Font = Enum.Font.GothamBold
                TextBox.Text = "90"
                TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                TextBox.TextSize = 13
                TextBox.TextWrapped = true
                TextBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                TextBox.BackgroundTransparency = 0.9990000128746033
                TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
                TextBox.BorderSizePixel = 0
                TextBox.Position = UDim2.new(0, -1, 0, 0)
                TextBox.Size = UDim2.new(1, 0, 1, 0)
                TextBox.Parent = SliderInput

                SliderFrame.AnchorPoint = Vector2.new(1, 0.5)
                SliderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderFrame.BackgroundTransparency = 0.800000011920929
                SliderFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
                SliderFrame.BorderSizePixel = 0
                SliderFrame.Position = UDim2.new(1, -20, 0.5, 0)
                SliderFrame.Size = UDim2.new(0, 100, 0, 3)
                SliderFrame.Name = "SliderFrame"
                SliderFrame.Parent = Slider

                UICorner17.Parent = SliderFrame

                SliderDraggable.AnchorPoint = Vector2.new(0, 0.5)
                SliderDraggable.BackgroundColor3 = GuiConfig.Color
                SliderDraggable.BorderColor3 = Color3.fromRGB(0, 0, 0)
                SliderDraggable.BorderSizePixel = 0
                SliderDraggable.Position = UDim2.new(0, 0, 0.5, 0)
                SliderDraggable.Size = UDim2.new(0.899999976, 0, 0, 1)
                SliderDraggable.Name = "SliderDraggable"
                SliderDraggable.Parent = SliderFrame

                UICorner18.Parent = SliderDraggable

                SliderCircle.AnchorPoint = Vector2.new(1, 0.5)
                SliderCircle.BackgroundColor3 = GuiConfig.Color
                SliderCircle.BorderColor3 = Color3.fromRGB(0, 0, 0)
                SliderCircle.BorderSizePixel = 0
                SliderCircle.Position = UDim2.new(1, 4, 0.5, 0)
                SliderCircle.Size = UDim2.new(0, 8, 0, 8)
                SliderCircle.Name = "SliderCircle"
                SliderCircle.Parent = SliderDraggable

                UICorner19.Parent = SliderCircle

                UIStroke6.Color = GuiConfig.Color
                UIStroke6.Parent = SliderCircle

                local Dragging = false
                local function Round(Number, Factor)
                    local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
                    if Result < 0 then
                        Result = Result + Factor
                    end
                    return Result
                end
                function SliderFunc:Set(Value)
                    Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
                    SliderFunc.Value = Value
                    TextBox.Text = tostring(Value)
                    TweenService:Create(
                        SliderDraggable,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { Size = UDim2.fromScale((Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 1) }
                    ):Play()

                    SliderConfig.Callback(Value)
                    ConfigData[configKey] = Value
                    SaveConfig()
                end

                SliderFrame.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
                        TweenService:Create(
                            SliderCircle,
                            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                            { Size = UDim2.new(0, 14, 0, 14) }
                        ):Play()
                        local SizeScale = math.clamp(
                            (Input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X,
                            0,
                            1
                        )
                        SliderFunc:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale))
                    end
                end)

                SliderFrame.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = false
                        SliderConfig.Callback(SliderFunc.Value)
                        TweenService:Create(
                            SliderCircle,
                            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                            { Size = UDim2.new(0, 8, 0, 8) }
                        ):Play()
                    end
                end)

                UserInputService.InputChanged:Connect(function(Input)
                    if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                        local SizeScale = math.clamp(
                            (Input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X,
                            0,
                            1
                        )
                        SliderFunc:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale))
                    end
                end)

                TextBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local Valid = TextBox.Text:gsub("[^%d%.]", "")
                    if Valid ~= "" and tonumber(Valid) then
                        local ValidNumber = math.clamp(tonumber(Valid), SliderConfig.Min, SliderConfig.Max)
                        SliderFunc:Set(ValidNumber)
                    elseif Valid == "" then
                        SliderFunc:Set(SliderConfig.Min)
                    end
                end)
                SliderFunc:Set(SliderConfig.Default)
                CountItem = CountItem + 1
                Elements[configKey] = SliderFunc
                return SliderFunc
            end

            function Items:AddInput(InputConfig)
                local InputConfig = InputConfig or {}
                InputConfig.Title = InputConfig.Title or "Title"
                InputConfig.Content = InputConfig.Content or ""
                InputConfig.Callback = InputConfig.Callback or function() end
                InputConfig.Default = InputConfig.Default or ""

                local configKey = "Input_" .. InputConfig.Title
                if ConfigData[configKey] ~= nil then
                    InputConfig.Default = ConfigData[configKey]
                end

                local InputFunc = { Value = InputConfig.Default }

                local Input = Instance.new("Frame");
                local UICorner12 = Instance.new("UICorner");
                local InputTitle = Instance.new("TextLabel");
                local InputContent = Instance.new("TextLabel");
                local InputFrame = Instance.new("Frame");
                local UICorner13 = Instance.new("UICorner");
                local InputTextBox = Instance.new("TextBox");

                Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Input.BackgroundTransparency = 0.935
                Input.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Input.BorderSizePixel = 0
                Input.LayoutOrder = CountItem
                Input.Size = UDim2.new(1, 0, 0, 46)
                Input.Name = "Input"
                Input.Parent = SectionAdd

                UICorner12.CornerRadius = UDim.new(0, 4)
                UICorner12.Parent = Input

                InputTitle.Font = Enum.Font.GothamBold
                InputTitle.Text = InputConfig.Title or "TextBox"
                InputTitle.TextColor3 = Color3.fromRGB(230.77499270439148, 230.77499270439148, 230.77499270439148)
                InputTitle.TextSize = 13
                InputTitle.TextXAlignment = Enum.TextXAlignment.Left
                InputTitle.TextYAlignment = Enum.TextYAlignment.Top
                InputTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                InputTitle.BackgroundTransparency = 0.9990000128746033
                InputTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
                InputTitle.BorderSizePixel = 0
                InputTitle.Position = UDim2.new(0, 10, 0, 10)
                InputTitle.Size = UDim2.new(1, -20, 0, 13)
                InputTitle.Name = "InputTitle"
                InputTitle.Parent = Input

                InputContent.Font = Enum.Font.GothamBold
                InputContent.Text = InputConfig.Content or "This is a TextBox"
                InputContent.TextColor3 = Color3.fromRGB(255, 255, 255)
                InputContent.TextSize = 12
                InputContent.TextTransparency = 0.6000000238418579
                InputContent.TextWrapped = true
                InputContent.TextXAlignment = Enum.TextXAlignment.Left
                InputContent.TextYAlignment = Enum.TextYAlignment.Bottom
                InputContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                InputContent.BackgroundTransparency = 0.9990000128746033
                InputContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
                InputContent.BorderSizePixel = 0
                InputContent.Position = UDim2.new(0, 10, 0, 25)
                InputContent.Size = UDim2.new(1, -20, 0, 12)
                InputContent.Name = "InputContent"
                InputContent.Parent = Input

                if InputConfig.Content == "" then
                    InputContent.Visible = false
                    InputContent.Size = UDim2.new(1, -20, 0, 0)
                    Input.Size = UDim2.new(1, 0, 0, 73)
                else
                    InputContent.Size = UDim2.new(1, -20, 0,
                        12 + (12 * (InputContent.TextBounds.X // math.max(1, InputContent.AbsoluteSize.X))))
                    InputContent.TextWrapped = true
                    Input.Size = UDim2.new(1, 0, 0, InputContent.AbsoluteSize.Y + 75)
                end

                InputContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    if InputConfig.Content ~= "" then
                        InputContent.TextWrapped = false
                        InputContent.Size = UDim2.new(1, -20, 0,
                            12 + (12 * (InputContent.TextBounds.X // math.max(1, InputContent.AbsoluteSize.X))))
                        Input.Size = UDim2.new(1, 0, 0, InputContent.AbsoluteSize.Y + 75)
                        InputFrame.Position = UDim2.new(0.5, 0, 0, InputContent.Position.Y.Offset + InputContent.AbsoluteSize.Y + 10)
                        InputContent.TextWrapped = true
                        UpdateSizeSection()
                    end
                end)

                InputFrame.AnchorPoint = Vector2.new(0.5, 0)
                InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                InputFrame.BackgroundTransparency = 0.949999988079071
                InputFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
                InputFrame.BorderSizePixel = 0
                InputFrame.ClipsDescendants = true
                if InputConfig.Content == "" then
                    InputFrame.Position = UDim2.new(0.5, 0, 0, 33)
                else
                    InputFrame.Position = UDim2.new(0.5, 0, 0, InputContent.Position.Y.Offset + InputContent.AbsoluteSize.Y + 10)
                end
                InputFrame.Size = UDim2.new(1, -20, 0, 30)
                InputFrame.Name = "InputFrame"
                InputFrame.Parent = Input

                UICorner13.CornerRadius = UDim.new(0, 4)
                UICorner13.Parent = InputFrame

                InputTextBox.CursorPosition = -1
                InputTextBox.Font = Enum.Font.GothamBold
                InputTextBox.PlaceholderColor3 = Color3.fromRGB(120.00000044703484, 120.00000044703484,
                    120.00000044703484)
                InputTextBox.PlaceholderText = "Write ur input here!"
                InputTextBox.Text = InputConfig.Default
                InputTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                InputTextBox.TextSize = 12
                InputTextBox.TextXAlignment = Enum.TextXAlignment.Left
                InputTextBox.AnchorPoint = Vector2.new(0, 0.5)
                InputTextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                InputTextBox.BackgroundTransparency = 0.9990000128746033
                InputTextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
                InputTextBox.BorderSizePixel = 0
                InputTextBox.Position = UDim2.new(0, 5, 0.5, 0)
                InputTextBox.Size = UDim2.new(1, -10, 1, -8)
                InputTextBox.Name = "InputTextBox"
                InputTextBox.Parent = InputFrame
                function InputFunc:Set(Value)
                    InputTextBox.Text = Value
                    InputFunc.Value = Value
                    InputConfig.Callback(Value)
                    ConfigData[configKey] = Value
                    SaveConfig()
                end

                InputFunc:Set(InputFunc.Value)

                InputTextBox.FocusLost:Connect(function()
                    InputFunc:Set(InputTextBox.Text)
                end)
                CountItem = CountItem + 1
                Elements[configKey] = InputFunc
                return InputFunc
            end
            
            function Items:AddDropdown(DropdownConfig)
                local DropdownConfig = DropdownConfig or {}
                DropdownConfig.Title = DropdownConfig.Title or "Title"
                DropdownConfig.Content = DropdownConfig.Content or ""
                DropdownConfig.Multi = DropdownConfig.Multi or false
                DropdownConfig.Options = DropdownConfig.Options or {}
                DropdownConfig.Default = DropdownConfig.Default or (DropdownConfig.Multi and {} or nil)
                DropdownConfig.Callback = DropdownConfig.Callback or function() end

                local configKey = "Dropdown_" .. DropdownConfig.Title
                if ConfigData[configKey] ~= nil then
                    DropdownConfig.Default = ConfigData[configKey]
                end

                local DropdownFunc = { Value = DropdownConfig.Default, Options = DropdownConfig.Options }

                local Dropdown = Instance.new("Frame")
                local DropdownButton = Instance.new("TextButton")
                local UICorner10 = Instance.new("UICorner")
                local DropdownTitle = Instance.new("TextLabel")
                local DropdownContent = Instance.new("TextLabel")
                local SelectOptionsFrame = Instance.new("Frame")
                local UICorner11 = Instance.new("UICorner")
                local OptionSelecting = Instance.new("TextLabel")
                local OptionImg = Instance.new("ImageLabel")

                Dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Dropdown.BackgroundTransparency = 0.935
                Dropdown.BorderSizePixel = 0
                Dropdown.LayoutOrder = CountItem
                Dropdown.Size = UDim2.new(1, 0, 0, 46)
                Dropdown.Name = "Dropdown"
                Dropdown.Parent = SectionAdd

                DropdownButton.Text = ""
                DropdownButton.BackgroundTransparency = 1
                DropdownButton.Size = UDim2.new(1, 0, 1, 0)
                DropdownButton.Name = "ToggleButton"
                DropdownButton.Parent = Dropdown

                UICorner10.CornerRadius = UDim.new(0, 4)
                UICorner10.Parent = Dropdown

                DropdownTitle.Font = Enum.Font.GothamBold
                DropdownTitle.Text = DropdownConfig.Title
                DropdownTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
                DropdownTitle.TextSize = 13
                DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
                DropdownTitle.BackgroundTransparency = 1
                DropdownTitle.Position = UDim2.new(0, 10, 0, 10)
                DropdownTitle.Size = UDim2.new(1, -180, 0, 13)
                DropdownTitle.Name = "DropdownTitle"
                DropdownTitle.Parent = Dropdown

                DropdownContent.Font = Enum.Font.GothamBold
                DropdownContent.Text = DropdownConfig.Content
                DropdownContent.TextColor3 = Color3.fromRGB(255, 255, 255)
                DropdownContent.TextSize = 12
                DropdownContent.TextTransparency = 0.6
                DropdownContent.TextWrapped = true
                DropdownContent.TextXAlignment = Enum.TextXAlignment.Left
                DropdownContent.BackgroundTransparency = 1
                DropdownContent.Position = UDim2.new(0, 10, 0, 25)
                DropdownContent.Size = UDim2.new(1, -180, 0, 12)
                DropdownContent.Name = "DropdownContent"
                DropdownContent.Parent = Dropdown

                SelectOptionsFrame.AnchorPoint = Vector2.new(1, 0.5)
                SelectOptionsFrame.BackgroundTransparency = 0.95
                SelectOptionsFrame.Position = UDim2.new(1, -7, 0.5, 0)
                SelectOptionsFrame.Size = UDim2.new(0, 148, 0, 30)
                SelectOptionsFrame.Name = "SelectOptionsFrame"
                SelectOptionsFrame.LayoutOrder = CountDropdown
                SelectOptionsFrame.Parent = Dropdown

                UICorner11.CornerRadius = UDim.new(0, 4)
                UICorner11.Parent = SelectOptionsFrame

                DropdownButton.Activated:Connect(function()
                    if not MoreBlur.Visible then
                        MoreBlur.Visible = true
                        DropPageLayout:JumpToIndex(SelectOptionsFrame.LayoutOrder)
                        TweenService:Create(MoreBlur, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
                        TweenService:Create(DropdownSelect, TweenInfo.new(0.3), { Position = UDim2.new(1, -11, 0.5, 0) })
                            :Play()
                    end
                end)

                OptionSelecting.Font = Enum.Font.GothamBold
                OptionSelecting.Text = DropdownConfig.Multi and "Select Options" or "Select Option"
                OptionSelecting.TextColor3 = Color3.fromRGB(255, 255, 255)
                OptionSelecting.TextSize = 12
                OptionSelecting.TextTransparency = 0.6
                OptionSelecting.TextXAlignment = Enum.TextXAlignment.Left
                OptionSelecting.AnchorPoint = Vector2.new(0, 0.5)
                OptionSelecting.BackgroundTransparency = 1
                OptionSelecting.Position = UDim2.new(0, 5, 0.5, 0)
                OptionSelecting.Size = UDim2.new(1, -30, 1, -8)
                OptionSelecting.Name = "OptionSelecting"
                OptionSelecting.Parent = SelectOptionsFrame

                OptionImg.Image = "rbxassetid://16851841101"
                OptionImg.ImageColor3 = Color3.fromRGB(230, 230, 230)
                OptionImg.AnchorPoint = Vector2.new(1, 0.5)
                OptionImg.BackgroundTransparency = 1
                OptionImg.Position = UDim2.new(1, 0, 0.5, 0)
                OptionImg.Size = UDim2.new(0, 25, 0, 25)
                OptionImg.Name = "OptionImg"
                OptionImg.Parent = SelectOptionsFrame

                local DropdownContainer = Instance.new("Frame")
                DropdownContainer.Size = UDim2.new(1, 0, 1, 0)
                DropdownContainer.BackgroundTransparency = 1
                DropdownContainer.Parent = DropdownFolder

                local SearchBox = Instance.new("TextBox")
                SearchBox.PlaceholderText = "Search"
                SearchBox.Font = Enum.Font.Gotham
                SearchBox.Text = ""
                SearchBox.TextSize = 12
                SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                SearchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                SearchBox.BackgroundTransparency = 0.9
                SearchBox.BorderSizePixel = 0
                SearchBox.Size = UDim2.new(1, 0, 0, 25)
                SearchBox.Position = UDim2.new(0, 0, 0, 0)
                SearchBox.ClearTextOnFocus = false
                SearchBox.Name = "SearchBox"
                SearchBox.Parent = DropdownContainer

                local ScrollSelect = Instance.new("ScrollingFrame")
                ScrollSelect.Size = UDim2.new(1, 0, 1, -30)
                ScrollSelect.Position = UDim2.new(0, 0, 0, 30)
                ScrollSelect.ScrollBarImageTransparency = 1
                ScrollSelect.BorderSizePixel = 0
                ScrollSelect.BackgroundTransparency = 1
                ScrollSelect.ScrollBarThickness = 0
                ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, 0)
                ScrollSelect.Name = "ScrollSelect"
                ScrollSelect.Parent = DropdownContainer

                local UIListLayout4 = Instance.new("UIListLayout")
                UIListLayout4.Padding = UDim.new(0, 3)
                UIListLayout4.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout4.Parent = ScrollSelect

                UIListLayout4:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, UIListLayout4.AbsoluteContentSize.Y)
                end)

                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local query = string.lower(SearchBox.Text)
                    for _, option in pairs(ScrollSelect:GetChildren()) do
                        if option.Name == "Option" and option:FindFirstChild("OptionText") then
                            local text = string.lower(option.OptionText.Text)
                            option.Visible = query == "" or string.find(text, query, 1, true)
                        end
                    end
                    ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, UIListLayout4.AbsoluteContentSize.Y)
                end)

                local DropCount = 0

                function DropdownFunc:Clear()
                    for _, DropFrame in ScrollSelect:GetChildren() do
                        if DropFrame.Name == "Option" then
                            DropFrame:Destroy()
                        end
                    end
                    DropdownFunc.Value = DropdownConfig.Multi and {} or nil
                    DropdownFunc.Options = {}
                    OptionSelecting.Text = DropdownConfig.Multi and "Select Options" or "Select Option"
                    DropCount = 0
                end

                function DropdownFunc:AddOption(option)
                    local label, value
                    if typeof(option) == "table" and option.Label and option.Value ~= nil then
                        label = tostring(option.Label)
                        value = option.Value
                    else
                        label = tostring(option)
                        value = option
                    end

                    local Option = Instance.new("Frame")
                    local OptionButton = Instance.new("TextButton")
                    local OptionText = Instance.new("TextLabel")
                    local ChooseFrame = Instance.new("Frame")
                    local UIStroke15 = Instance.new("UIStroke")
                    local UICorner38 = Instance.new("UICorner")
                    local UICorner37 = Instance.new("UICorner")

                    Option.BackgroundTransparency = 1
                    Option.Size = UDim2.new(1, 0, 0, 30)
                    Option.Name = "Option"
                    Option.Parent = ScrollSelect

                    UICorner37.CornerRadius = UDim.new(0, 3)
                    UICorner37.Parent = Option

                    OptionButton.BackgroundTransparency = 1
                    OptionButton.Size = UDim2.new(1, 0, 1, 0)
                    OptionButton.Text = ""
                    OptionButton.Name = "OptionButton"
                    OptionButton.Parent = Option

                    OptionText.Font = Enum.Font.GothamBold
                    OptionText.Text = label
                    OptionText.TextSize = 13
                    OptionText.TextColor3 = Color3.fromRGB(230, 230, 230)
                    OptionText.Position = UDim2.new(0, 8, 0, 8)
                    OptionText.Size = UDim2.new(1, -100, 0, 13)
                    OptionText.BackgroundTransparency = 1
                    OptionText.TextXAlignment = Enum.TextXAlignment.Left
                    OptionText.Name = "OptionText"
                    OptionText.Parent = Option

                    Option:SetAttribute("RealValue", value)

                    ChooseFrame.AnchorPoint = Vector2.new(0, 0.5)
                    ChooseFrame.BackgroundColor3 = GuiConfig.Color
                    ChooseFrame.Position = UDim2.new(0, 2, 0.5, 0)
                    ChooseFrame.Size = UDim2.new(0, 0, 0, 0)
                    ChooseFrame.Name = "ChooseFrame"
                    ChooseFrame.Parent = Option

                    UIStroke15.Color = GuiConfig.Color
                    UIStroke15.Thickness = 1.6
                    UIStroke15.Transparency = 0.999
                    UIStroke15.Parent = ChooseFrame
                    UICorner38.Parent = ChooseFrame

                    OptionButton.Activated:Connect(function()
                        if DropdownConfig.Multi then
                            if not table.find(DropdownFunc.Value, value) then
                                table.insert(DropdownFunc.Value, value)
                            else
                                for i, v in pairs(DropdownFunc.Value) do
                                    if v == value then
                                        table.remove(DropdownFunc.Value, i)
                                        break
                                    end
                                end
                            end
                        else
                            DropdownFunc.Value = value
                        end
                        DropdownFunc:Set(DropdownFunc.Value)
                    end)
                end

                function DropdownFunc:Set(Value)
                    if DropdownConfig.Multi then
                        DropdownFunc.Value = type(Value) == "table" and Value or {}
                    else
                        DropdownFunc.Value = (type(Value) == "table" and Value[1]) or Value
                    end

                    ConfigData[configKey] = DropdownFunc.Value
                    SaveConfig()

                    local texts = {}
                    for _, Drop in ScrollSelect:GetChildren() do
                        if Drop.Name == "Option" and Drop:FindFirstChild("OptionText") then
                            local v = Drop:GetAttribute("RealValue")
                            local selected = DropdownConfig.Multi and table.find(DropdownFunc.Value, v) or
                                DropdownFunc.Value == v

                            if selected then
                                TweenService:Create(Drop.ChooseFrame, TweenInfo.new(0.2),
                                    { Size = UDim2.new(0, 1, 0, 12) }):Play()
                                TweenService:Create(Drop.ChooseFrame.UIStroke, TweenInfo.new(0.2), { Transparency = 0 })
                                    :Play()
                                TweenService:Create(Drop, TweenInfo.new(0.2), { BackgroundTransparency = 0.935 }):Play()
                                table.insert(texts, Drop.OptionText.Text)
                            else
                                TweenService:Create(Drop.ChooseFrame, TweenInfo.new(0.1),
                                    { Size = UDim2.new(0, 0, 0, 0) }):Play()
                                TweenService:Create(Drop.ChooseFrame.UIStroke, TweenInfo.new(0.1),
                                    { Transparency = 0.999 }):Play()
                                TweenService:Create(Drop, TweenInfo.new(0.1), { BackgroundTransparency = 0.999 }):Play()
                            end
                        end
                    end

                    OptionSelecting.Text = (#texts == 0)
                        and (DropdownConfig.Multi and "Select Options" or "Select Option")
                        or table.concat(texts, ", ")

                    if DropdownConfig.Callback then
                        if DropdownConfig.Multi then
                            DropdownConfig.Callback(DropdownFunc.Value)
                        else
                            local str = (DropdownFunc.Value ~= nil) and tostring(DropdownFunc.Value) or ""
                            DropdownConfig.Callback(str)
                        end
                    end
                end

                function DropdownFunc:SetValue(val)
                    self:Set(val)
                end

                function DropdownFunc:GetValue()
                    return self.Value
                end

                function DropdownFunc:SetValues(newList, selecting)
                    newList = newList or {}
                    selecting = selecting or (DropdownConfig.Multi and {} or nil)
                    DropdownFunc:Clear()
                    for _, v in ipairs(newList) do
                        DropdownFunc:AddOption(v)
                    end
                    DropdownFunc.Options = newList
                    DropdownFunc:Set(selecting)
                end

                DropdownFunc:SetValues(DropdownFunc.Options, DropdownFunc.Value)

                CountItem = CountItem + 1
                CountDropdown = CountDropdown + 1
                Elements[configKey] = DropdownFunc
                return DropdownFunc
            end

            function Items:AddDivider()
                local Divider = Instance.new("Frame")
                Divider.Name = "Divider"
                Divider.Parent = SectionAdd
                Divider.AnchorPoint = Vector2.new(0.5, 0)
                Divider.Position = UDim2.new(0.5, 0, 0, 0)
                Divider.Size = UDim2.new(1, 0, 0, 2)
                Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Divider.BackgroundTransparency = 0
                Divider.BorderSizePixel = 0
                Divider.LayoutOrder = CountItem

                local UIGradient = Instance.new("UIGradient")
                UIGradient.Color = ColorSequence.new {
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
                    ColorSequenceKeypoint.new(0.5, GuiConfig.Color),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
                }
                UIGradient.Parent = Divider

                local UICorner = Instance.new("UICorner")
                UICorner.CornerRadius = UDim.new(0, 2)
                UICorner.Parent = Divider

                CountItem = CountItem + 1
                return Divider
            end

            function Items:AddSubSection(title)
                title = title or "Sub Section"

                local SubSection = Instance.new("Frame")
                SubSection.Name = "SubSection"
                SubSection.Parent = SectionAdd
                SubSection.BackgroundTransparency = 1
                SubSection.Size = UDim2.new(1, 0, 0, 22)
                SubSection.LayoutOrder = CountItem

                local Background = Instance.new("Frame")
                Background.Parent = SubSection
                Background.Size = UDim2.new(1, 0, 1, 0)
                Background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Background.BackgroundTransparency = 1
                Background.BorderSizePixel = 0
                Instance.new("UICorner", Background).CornerRadius = UDim.new(0, 6)

                local Label = Instance.new("TextLabel")
                Label.Parent = SubSection
                Label.AnchorPoint = Vector2.new(0, 0.5)
                Label.Position = UDim2.new(0, 10, 0.5, 0)
                Label.Size = UDim2.new(1, -20, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Font = Enum.Font.GothamBold
                Label.Text = title
                Label.TextColor3 = GuiConfig.Color
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left

                CountItem = CountItem + 1
                return SubSection
            end

            CountSection = CountSection + 1
            return Items
        end

        CountTab = CountTab + 1
        local safeName = TabConfig.Name:gsub("%s+", "_")
        _G[safeName] = Sections
        return Sections
    end

    -- ═══════════════════════════════════════════════════
    -- SETTINGS TAB (Config Profile System)
    -- ═══════════════════════════════════════════════════
    function Tabs:AddConfigTab()
        pcall(function()
            local SettingsTab = Tabs:AddTab({ Name = "Config", Icon = "settings" })

            -- helper notif dengan title "Config" (global notif: msg, delay, color, title)
            local function cnotif(msg, delay)
                notif(msg, delay, GuiConfig.Color, "Config")
            end

            -- ═══ INFO SECTION ═══
            -- local InfoSection = SettingsTab:AddSection("Informasi", true)
            -- InfoSection:AddParagraph({
            --     Title   = "Auto-Save Aktif",
            --     Content = "Semua perubahan (toggle, slider, dropdown) otomatis tersimpan ke file saat kamu ubah. Saat relog, setting kamu akan otomatis ter-load kembali.\n\nGunakan Profile untuk menyimpan beberapa preset yang berbeda."
            -- })

            -- ═══ AUTO-LOAD SAAT STARTUP ═══
            -- Panggil LoadConfigElements setelah semua element dibuat
            task.defer(function()
                pcall(function()
                    LoadConfigElements()
                end)
            end)

            -- ═══ PROFILE SECTION ═══
            local ConfigSection = SettingsTab:AddSection("Config Profile")

            local profileDropdown
            local selectedProfile = "None"

            local function RefreshProfileDropdown()
                local fresh = GetProfileList()
                if #fresh == 0 then table.insert(fresh, "None") end
                if profileDropdown and profileDropdown.SetValues then
                    profileDropdown:SetValues(fresh, fresh[1] or "None")
                end
                selectedProfile = fresh[1] or "None"
                return fresh
            end

            local profiles = GetProfileList()
            if #profiles == 0 then table.insert(profiles, "None") end

            profileDropdown = ConfigSection:AddDropdown({
                Title   = "Select Profile",
                Content = "Select the profile you want to load or delete",
                Options = profiles,
                Default = profiles[1] or "None",
                Multi   = false,
                Callback = function(val)
                    selectedProfile = val
                end
            })

            ConfigSection:AddButton({
                Title = "Refresh",
                Callback = function()
                    local fresh = RefreshProfileDropdown()
                    cnotif("Found " .. tostring(#fresh) .. " profiles", 3)
                end
            })

            local profileNameInput = ConfigSection:AddInput({
                Title   = "New Profile Name",
                Content = "Type a name to save new profile",
                Default = "",
                Callback = function(val) end
            })


            ConfigSection:AddButton({
                Title    = "Save Profile",
                SubTitle = "Load Profile",
                Callback = function()
                    local name = profileNameInput.Value
                    if not name or name == "" or name == "None" then
                        cnotif("Type a profile name first!", 3)
                        return
                    end
                    name = name:gsub("[^%w_%-]", "_")
                    local ok = SaveProfile(name)
                    if ok then
                        cnotif("Profile '" .. name .. "' saved successfully!", 4)
                        task.wait(0.2)
                        local newList = GetProfileList()
                        if not table.find(newList, name) then
                            table.insert(newList, name)
                            table.sort(newList)
                        end
                        if #newList > 1 then
                            for i = #newList, 1, -1 do
                                if newList[i] == "None" then table.remove(newList, i) end
                            end
                        end
                        if profileDropdown and profileDropdown.SetValues then
                            profileDropdown:SetValues(newList, name)
                        end
                        selectedProfile = name
                    else
                        cnotif("Failed to save profile!", 3)
                    end
                end,
                SubCallback = function()
                    if not selectedProfile or selectedProfile == "" or selectedProfile == "None" then
                        cnotif("Select a profile from the dropdown first!", 3)
                        return
                    end
                    cnotif("Loading '" .. selectedProfile .. "'...", 2)
                    task.spawn(function()
                        local ok = LoadProfile(selectedProfile)
                        if ok then
                            cnotif("Profile '" .. selectedProfile .. "' loaded successfully!", 4)
                        else
                            cnotif("Failed to load profile!", 3)
                        end
                    end)
                end
            })

            ConfigSection:AddButton({
                Title    = "Delete Profile",
                SubTitle = "Copy Config",
                Callback = function()
                    if not selectedProfile or selectedProfile == "" or selectedProfile == "None" then
                        cnotif("Select the profile you want to delete!", 3)
                        return
                    end
                    local ok = DeleteProfile(selectedProfile)
                    if ok then
                        cnotif("Profile '" .. selectedProfile .. "' dihapus!", 3)
                        selectedProfile = "None"
                        local newList = GetProfileList()
                        if #newList == 0 then table.insert(newList, "None") end
                        if profileDropdown and profileDropdown.SetValues then
                            profileDropdown:SetValues(newList, newList[1])
                        end
                    else
                        cnotif("Failed to delete profile!", 3)
                    end
                end,
                SubCallback = function()
                    -- Copy current ConfigData as JSON to clipboard
                    if setclipboard then
                        local json = HttpService:JSONEncode(ConfigData)
                        setclipboard(json)
                        cnotif("Config copied to clipboard successfully!", 3)
                    else
                        cnotif("Executor does not support clipboard!", 3)
                    end
                end
            })

            -- ═══ IMPORT CONFIG ═══
            local ImportSection = SettingsTab:AddSection("Import Config")

            local importInput = ImportSection:AddPanel({
                Title       = "Paste JSON Config",
                Placeholder = "Paste JSON Config here...",
                ButtonText  = "Import & Load",
                Callback    = function(val)
                    if not val or val == "" then
                        cnotif("JSON Input is empty!", 3)
                        return
                    end
                    local ok, data = pcall(function()
                        return HttpService:JSONDecode(val)
                    end)
                    if not ok or type(data) ~= "table" then
                        cnotif("Invalid JSON!", 3)
                        return
                    end
                    -- Apply ke ConfigData dan semua elemen
                    for key, v in pairs(data) do
                        ConfigData[key] = v
                    end
                    SaveConfig()
                    for key, element in pairs(Elements) do
                        if ConfigData[key] ~= nil and element.Set then
                            pcall(function()
                                element:Set(ConfigData[key])
                            end)
                            task.wait(0.02)
                        end
                    end
                    cnotif("Config imported successfully!", 4)
                end
            })


            -- ═══ THEME SECTION ═══
            local ThemeSection = SettingsTab:AddSection("Theme")

            local themePresets = {
                ["Blue"]  = { color = Color3.fromRGB(30, 150, 255), color2 = Color3.fromRGB(10, 10, 15) },
                ["Red"] = { color = Color3.fromRGB(255, 66, 66),  color2 = Color3.fromRGB(14, 0, 0) },
                ["Purple"]  = { color = Color3.fromRGB(160, 30, 255), color2 = Color3.fromRGB(10, 0, 14) },
            }

            ThemeSection:AddDropdown({
                Title   = "Theme",
                Options = { "Blue", "Red", "Purple" },
                Default = "Blue",
                Callback = function(value)
                    local preset = themePresets[value]
                    if preset then
                        Tabs:SetTheme(preset.color, preset.color2)
                    end
                end
            })
        end)
    end


    -- Kumpulkan referensi elemen warna yang bisa diubah secara dinamis
    local _themeColorElements = {
        titleLabel  = TextLabel,
        footerFrm   = FooterFrame,
        mainStroke  = MainStroke,
        decideFrm   = DecideFrame,
        mainBG      = Main,
        executorFrm = Executor,
    }
    local _themeTabChooseFrames = {} -- referensi semua ChooseFrame tab

    function Tabs:SetTheme(newColor, newColor2)
        GuiConfig.Color  = newColor
        GuiConfig.Color2 = newColor2 or newColor

        -- Update topbar (Title & Footer text)
        TweenService:Create(_themeColorElements.titleLabel, TweenInfo.new(0.4), { TextColor3 = newColor }):Play()
        if _themeColorElements.footerFrm then
            TweenService:Create(_themeColorElements.footerFrm, TweenInfo.new(0.4), { BackgroundColor3 = newColor }):Play()
        end
        if _themeColorElements.executorFrm then
            TweenService:Create(_themeColorElements.executorFrm, TweenInfo.new(0.4), { BackgroundColor3 = newColor }):Play()
        end

        -- Update border stroke & DecideFrame
        TweenService:Create(_themeColorElements.mainStroke, TweenInfo.new(0.4), { Color = newColor }):Play()
        TweenService:Create(_themeColorElements.decideFrm, TweenInfo.new(0.4), { BackgroundColor3 = newColor }):Play()

        -- Update window background (Color2)
        TweenService:Create(_themeColorElements.mainBG, TweenInfo.new(0.4), { BackgroundColor3 = GuiConfig.Color2 }):Play()

        -- Update ChooseFrame & UIStroke di semua tab
        for _, tab in ScrollTab:GetChildren() do
            if tab.Name == "Tab" then
                local cf = tab:FindFirstChild("ChooseFrame")
                if cf then
                    TweenService:Create(cf, TweenInfo.new(0.3), { BackgroundColor3 = newColor }):Play()
                    local stk = cf:FindFirstChildOfClass("UIStroke")
                    if stk then
                        TweenService:Create(stk, TweenInfo.new(0.3), { Color = newColor }):Play()
                    end
                end
            end
        end

        for _, gui in AscendOfficialOnTop:GetDescendants() do
            if gui.Name == "SectionTitle" and gui:IsA("TextLabel") then
                local sectionReal = gui.Parent
                if sectionReal and sectionReal.Name == "SectionReal" then
                    local featureFrame = sectionReal:FindFirstChild("FeatureFrame")
                    -- Jika FeatureFrame tidak ada (AlwaysOpen=true) atau rotasinya 90 (terbuka)
                    if not featureFrame or featureFrame.Rotation > 45 then
                        TweenService:Create(gui, TweenInfo.new(0.4), { TextColor3 = newColor }):Play()
                    end
                end
            end

            -- SubSection label
            if gui.Name == "SubSection" and gui:IsA("Frame") then
                local lbl = gui:FindFirstChildOfClass("TextLabel")
                if lbl then
                    TweenService:Create(lbl, TweenInfo.new(0.4), { TextColor3 = newColor }):Play()
                end
            end

            -- Divider gradient
            if gui.Name == "Divider" and gui:IsA("Frame") then
                local grad = gui:FindFirstChildOfClass("UIGradient")
                if grad then
                    grad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
                        ColorSequenceKeypoint.new(0.5, newColor),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
                    })
                end
            end

            -- Dropdown ChooseFrame option
            if gui.Name == "ChooseFrame" and gui:IsA("Frame") and gui.Parent and gui.Parent.Name == "Option" then
                TweenService:Create(gui, TweenInfo.new(0.3), { BackgroundColor3 = newColor }):Play()
                local stk = gui:FindFirstChildOfClass("UIStroke")
                if stk then
                    TweenService:Create(stk, TweenInfo.new(0.3), { Color = newColor }):Play()
                end
            end

            -- Toggle yang sedang ON (FeatureFrame.BackgroundTransparency ≈ 0)
            if gui.Name == "FeatureFrame" and gui:IsA("Frame") and gui.Parent and gui.Parent.Name == "Toggle" then
                if gui.BackgroundTransparency < 0.1 then
                    -- toggle ini ON, update warnanya langsung
                    TweenService:Create(gui, TweenInfo.new(0.3), { BackgroundColor3 = newColor }):Play()
                    local stk = gui:FindFirstChildOfClass("UIStroke")
                    if stk then
                        TweenService:Create(stk, TweenInfo.new(0.3), { Color = newColor }):Play()
                    end
                    -- update juga teks judul toggle yang ON
                    local toggleParent = gui.Parent
                    if toggleParent then
                        local ttl = toggleParent:FindFirstChild("ToggleTitle")
                        if ttl then
                            TweenService:Create(ttl, TweenInfo.new(0.3), { TextColor3 = newColor }):Play()
                        end
                    end
                end
            end

        end
    end

    return Tabs
end

-- ============================================================
-- UI TESTING / EXECUTION
-- ============================================================
local ICON_ID = "111882698376264"
local function notif(content, duration, title)
    if AscendOfficial and AscendOfficial.MakeNotify then
        AscendOfficial:MakeNotify({
            Title   = title or "Ascend Official",
            Content = content,
            Delay   = duration or 4,
            Icon    = ICON_ID
        })
    end
end

local MarketplaceService = game:GetService("MarketplaceService")
local GameName = "Steal An Egg"
pcall(function()
    GameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

local Window = AscendOfficial:Window({
    Title         = "Ascend Official",
    Footer        = GameName .. " | v1.0",
    Color         = Color3.fromRGB(30, 150, 255),
    Color2        = Color3.fromRGB(10, 10, 15),
    ["Tab Width"] = 130,
    Image         = "111882698376264",
    WindowIMG     = "111882698376264",
    LogoHUB       = "111882698376264",
    Version       = 1,
})
local Tabs = Window

-- Munculkan tombol logo melayang untuk minimize / buka UI
pcall(function() Window:ToggleUI() end)

local function LoadInfoTab()
    local InfoTab = Tabs:AddTab({ Name = "About", Icon = "info" })
    local InfoSection = InfoTab:AddSection("About Ascend Official", true)

    local inviteCode = "ascendofficial"
    local discordLink = "https://discord.gg/" .. inviteCode

    local DiscordParagraph = InfoSection:AddParagraph({
        Title          = "Ascend Official",
        Icon           = "ascendicon",
        Content        = [[Tema Biru + Hitam dengan logo 111882698376264.
- Klik tombol logo bulat di kiri layar untuk minimize / buka UI.
- Topbar dapat di-drag dengan bebas.
- Tombol minimize (-) di kanan atas untuk menyembunyikan window.]],
        ButtonText     = "Copy Discord Link",
        ButtonCallback = function()
            if setclipboard then
                setclipboard(discordLink)
                notif("Successfully copied the link!", 3, "Ascend Official")
            end
        end
    })
end

local function LoadMainTab()
    local MainTab = Tabs:AddTab({ Name = "Main", Icon = "home" })
    local DemoSection = MainTab:AddSection("Elements Showcase")

    DemoSection:AddParagraph({
        Title          = "Paragraph Demo",
        Content        = [[This is a paragraph example.
Klik tombol logo bulat di kiri untuk minimize / buka UI kapan saja.]],
        ButtonText     = "Click Me",
        ButtonCallback = function()
            notif("Paragraph button clicked!", 2)
        end
    })

    DemoSection:AddButton({
        Title = "Normal Button",
        Callback = function()
            notif("Normal button clicked!", 2)
        end
    })

    DemoSection:AddButton({
        Title       = "Dual Button",
        SubTitle    = "Second Button",
        Callback    = function()
            notif("Main button clicked!", 2)
        end,
        SubCallback = function()
            notif("Sub button clicked!", 2)
        end
    })

    DemoSection:AddDivider()
    DemoSection:AddSubSection("Toggles & Sliders")

    DemoSection:AddToggle({
        Title    = "Auto Farm Demo",
        Default  = false,
        Keybind  = true,
        Callback = function(value)
            notif("Toggle is now: " .. tostring(value), 2)
        end
    })

    DemoSection:AddSlider({
        Title     = "WalkSpeed Multiplier",
        Increment = 1,
        Min       = 16,
        Max       = 250,
        Default   = 32,
        Callback  = function(value)
            local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = value end
        end
    })

    DemoSection:AddDivider()
    DemoSection:AddSubSection("Inputs & Dropdowns")

    DemoSection:AddInput({
        Title    = "Example Input",
        Content  = "Type something and press enter",
        Default  = "1000",
        Callback = function(val)
            notif("Input submitted: " .. tostring(val), 2)
        end
    })

    DemoSection:AddDropdown({
        Title    = "Single Dropdown",
        Content  = "Select one option",
        Options  = { "Forest", "Lake", "Desert", "Volcano", "Cosmic", "Abyss Ocean" },
        Default  = "Forest",
        Multi    = false,
        Callback = function(val)
            notif("Selected: " .. tostring(val), 2)
        end
    })

    DemoSection:AddDropdown({
        Title    = "Multi Dropdown",
        Content  = "Select multiple options",
        Options  = { "Common", "Rare", "Epic", "Legendary", "Mythic", "Divine", "Secret" },
        Default  = {"Divine", "Secret"},
        Multi    = true,
        Callback = function(val)
            local s = type(val) == "table" and table.concat(val, ", ") or tostring(val)
            notif("Selected: " .. s, 2)
        end
    })
end

LoadInfoTab()
LoadMainTab()

-- Panggil fungsi untuk menambahkan tab config di urutan paling akhir
Tabs:AddConfigTab()

return AscendOfficial
