-- ================================================
-- SERVER BROWSER V5 – Mała ikona + Filtry + Region (z Twojego Pastebin)
-- Połączyłem Twój zaawansowany browser z moją ikoną i filtrami
-- ================================================

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

local HISTORY_FILE = "join_history.json"
local joinHistory = {}

-- Load history
pcall(function()
    joinHistory = HttpService:JSONDecode(readfile(HISTORY_FILE))
end)

-- ====================== MAŁA IKONA ======================
local gui = Instance.new("ScreenGui")
gui.Name = "ServerBrowserV5"
gui.ResetOnSpawn = false
gui.Parent = Player:WaitForChild("PlayerGui")

local iconFrame = Instance.new("Frame")
iconFrame.Size = UDim2.new(0, 70, 0, 70)
iconFrame.Position = UDim2.new(1, -90, 1, -90)
iconFrame.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
iconFrame.BorderSizePixel = 0
iconFrame.Parent = gui

local iconCorner = Instance.new("UICorner", iconFrame)
iconCorner.CornerRadius = UDim.new(1, 0)

local iconBtn = Instance.new("TextButton", iconFrame)
iconBtn.Size = UDim2.new(1,0,1,0)
iconBtn.BackgroundTransparency = 1
iconBtn.Text = "🌍"
iconBtn.TextSize = 45
iconBtn.Font = Enum.Font.GothamBold
iconBtn.TextColor3 = Color3.new(1,1,1)

-- Drag ikony
local dragging, dragInput, dragStart, startPos
iconFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = iconFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        iconFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

iconFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ====================== GŁÓWNE GUI ======================
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0.65, 0, 0.78, 0)
mainFrame.Position = UDim2.new(0.175, 0, 0.11, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
mainFrame.Visible = false

local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 55)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Text = "🌐 SERVER BROWSER V5 – Z FILTRAMI I REGIONEM"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 26
title.Font = Enum.Font.GothamBold

local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 50, 0, 50)
closeBtn.Position = UDim2.new(1, -60, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextSize = 32
closeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 10)

local refreshBtn = Instance.new("TextButton", mainFrame)
refreshBtn.Size = UDim2.new(0, 160, 0, 45)
refreshBtn.Position = UDim2.new(1, -230, 0, 8)
refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
refreshBtn.Text = "🔄 Odśwież listę"
refreshBtn.TextColor3 = Color3.new(1,1,1)
refreshBtn.TextSize = 18
refreshBtn.Font = Enum.Font.GothamSemibold
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 10)

-- Filtry
local filterFrame = Instance.new("Frame", mainFrame)
filterFrame.Size = UDim2.new(1, -30, 0, 160)
filterFrame.Position = UDim2.new(0, 15, 0, 65)
filterFrame.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
Instance.new("UICorner", filterFrame).CornerRadius = UDim.new(0, 12)

-- Search
local searchBox = Instance.new("TextBox", filterFrame)
searchBox.Size = UDim2.new(0.4, 0, 0, 40)
searchBox.Position = UDim2.new(0, 15, 0, 15)
searchBox.PlaceholderText = "Szukaj po ID serwera..."
searchBox.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
searchBox.TextColor3 = Color3.new(1,1,1)
searchBox.TextSize = 18
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 8)

-- Min graczy
local minLabel = Instance.new("TextLabel", filterFrame)
minLabel.Size = UDim2.new(0, 130, 0, 30)
minLabel.Position = UDim2.new(0.42, 0, 0, 15)
minLabel.BackgroundTransparency = 1
minLabel.Text = "Min. graczy:"
minLabel.TextColor3 = Color3.new(1,1,1)
minLabel.TextSize = 17
minLabel.Font = Enum.Font.GothamSemibold

local minBox = Instance.new("TextBox", filterFrame)
minBox.Size = UDim2.new(0, 90, 0, 40)
minBox.Position = UDim2.new(0.42, 0, 0, 48)
minBox.PlaceholderText = "0"
minBox.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
minBox.TextColor3 = Color3.new(1,1,1)
minBox.TextSize = 19
Instance.new("UICorner", minBox).CornerRadius = UDim.new(0, 8)

-- Ukryj pełne
local fullToggle = Instance.new("TextButton", filterFrame)
fullToggle.Size = UDim2.new(0, 180, 0, 45)
fullToggle.Position = UDim2.new(0.68, 0, 0, 20)
fullToggle.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
fullToggle.Text = "✅ Pokazuj pełne"
fullToggle.TextColor3 = Color3.new(1,1,1)
fullToggle.TextSize = 18
fullToggle.Font = Enum.Font.GothamSemibold
Instance.new("UICorner", fullToggle).CornerRadius = UDim.new(0, 10)

local hideFull = false
fullToggle.MouseButton1Click:Connect(function()
    hideFull = not hideFull
    fullToggle.Text = hideFull and "❌ Ukrywaj pełne" or "✅ Pokazuj pełne"
    fullToggle.BackgroundColor3 = hideFull and Color3.fromRGB(220, 40, 40) or Color3.fromRGB(0, 162, 255)
    applyFilters()
end)

-- Region filter
local regionLabel = Instance.new("TextLabel", filterFrame)
regionLabel.Size = UDim2.new(0, 140, 0, 30)
regionLabel.Position = UDim2.new(0, 15, 0, 80)
regionLabel.BackgroundTransparency = 1
regionLabel.Text = "Region:"
regionLabel.TextColor3 = Color3.new(1,1,1)
regionLabel.TextSize = 17
regionLabel.Font = Enum.Font.GothamSemibold

local regionBtn = Instance.new("TextButton", filterFrame)
regionBtn.Size = UDim2.new(0.4, 0, 0, 40)
regionBtn.Position = UDim2.new(0, 15, 0, 110)
regionBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
regionBtn.Text = "Wszystkie regiony ▼"
regionBtn.TextColor3 = Color3.new(1,1,1)
regionBtn.TextSize = 18
Instance.new("UICorner", regionBtn).CornerRadius = UDim.new(0, 8)

local selectedRegion = "Wszystkie"

-- Scroll z serwerami
local scroll = Instance.new("ScrollingFrame", mainFrame)
scroll.Size = UDim2.new(1, -30, 1, -245)
scroll.Position = UDim2.new(0, 15, 0, 235)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 10
scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)

local listLayout = Instance.new("UIListLayout", scroll)
listLayout.Padding = UDim.new(0, 10)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

local serversData = {}
local enrichedData = {}

local function getRegion(server)
    if not server.ip then return "Unknown" end
    local success, res = pcall(function()
        return HttpService:GetAsync("http://ip-api.com/json/" .. server.ip .. "?fields=regionName")
    end)
    if success then
        return HttpService:JSONDecode(res).regionName or "Unknown"
    end
    return "Unknown"
end

local function fetchServers()
    serversData = {}
    enrichedData = {}
    local cursor = nil

    repeat
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"
        if cursor then url = url .. "&cursor=" .. cursor end

        local success, res = pcall(function() return HttpService:GetAsync(url) end)
        if not success then break end

        local decoded = HttpService:JSONDecode(res)
        for _, s in ipairs(decoded.data or {}) do
            table.insert(serversData, s)
        end
        cursor = decoded.nextPageCursor
    until not cursor or #serversData >= 250

    table.sort(serversData, function(a,b) return (a.playing or 0) > (b.playing or 0) end)

    refreshBtn.Text = "🔄 Pobieram regiony..."
    for _, server in ipairs(serversData) do
        local region = getRegion(server)
        table.insert(enrichedData, {
            id = server.id,
            playing = server.playing or 0,
            maxPlayers = server.maxPlayers or 0,
            ping = server.ping or 0,
            ip = server.ip,
            region = region
        })
    end
end

local function shouldShow(server)
    if searchBox.Text \~= "" and not string.find(string.lower(server.id), string.lower(searchBox.Text)) then
        return false
    end
    if server.playing < (tonumber(minBox.Text) or 0) then return false end
    if hideFull and server.playing >= server.maxPlayers then return false end
    if selectedRegion \~= "Wszystkie" and server.region \~= selectedRegion then return false end
    return true
end

local function applyFilters()
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local filtered = {}
    for _, s in ipairs(enrichedData) do
        if shouldShow(s) then table.insert(filtered, s) end
    end

    if #filtered == 0 then
        local empty = Instance.new("TextLabel", scroll)
        empty.Size = UDim2.new(1,0,0,100)
        empty.BackgroundTransparency = 1
        empty.Text = "Brak serwerów spełniających filtry"
        empty.TextColor3 = Color3.fromRGB(255, 120, 120)
        empty.TextSize = 24
        return
    end

    for _, server in ipairs(filtered) do
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 85)
        frame.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
        frame.Parent = scroll
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

        local info = Instance.new("TextLabel", frame)
        info.Size = UDim2.new(0.55, 0, 1, 0)
        info.Position = UDim2.new(0, 15, 0, 0)
        info.BackgroundTransparency = 1
        info.Text = string.format("👥 %d/%d   Ping: %dms\nLast Joined: %s", server.playing, server.maxPlayers, server.ping or 0, joinHistory[server.id] or "Nigdy")
        info.TextColor3 = Color3.fromRGB(220, 220, 220)
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.TextSize = 17
        info.Font = Enum.Font.GothamSemibold

        local regLabel = Instance.new("TextLabel", frame)
        regLabel.Size = UDim2.new(0.25, 0, 0.5, 0)
        regLabel.Position = UDim2.new(0.55, 0, 0.1, 0)
        regLabel.BackgroundTransparency = 1
        regLabel.Text = "🌍 " .. server.region
        regLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        regLabel.TextSize = 18
        regLabel.Font = Enum.Font.GothamBold

        local joinBtn = Instance.new("TextButton", frame)
        joinBtn.Size = UDim2.new(0, 130, 0, 55)
        joinBtn.Position = UDim2.new(1, -145, 0.5, -27.5)
        joinBtn.BackgroundColor3 = Color3.fromRGB(0, 190, 80)
        joinBtn.Text = "DOŁĄCZ"
        joinBtn.TextColor3 = Color3.new(1,1,1)
        joinBtn.TextSize = 20
        joinBtn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", joinBtn).CornerRadius = UDim.new(0, 10)

        joinBtn.MouseButton1Click:Connect(function()
            joinHistory[server.id] = os.date("%x %X")
            pcall(function() writefile(HISTORY_FILE, HttpService:JSONEncode(joinHistory)) end)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, Player)
        end)

        -- ? button jak w Twoim oryginale
        local qBtn = Instance.new("TextButton", frame)
        qBtn.Size = UDim2.new(0, 30, 0, 30)
        qBtn.Position = UDim2.new(0.78, 0, 0.1, 0)
        qBtn.Text = "?"
        qBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
        qBtn.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", qBtn).CornerRadius = UDim.new(1,0)

        local idBox = Instance.new("TextBox", frame)
        idBox.Size = UDim2.new(0.9, 0, 0, 25)
        idBox.Position = UDim2.new(0.05, 0, 1, -30)
        idBox.Text = server.id
        idBox.BackgroundColor3 = Color3.fromRGB(20,20,20)
        idBox.TextColor3 = Color3.fromRGB(255, 220, 0)
        idBox.TextEditable = false
        idBox.ClearTextOnFocus = false
        idBox.Visible = false

        qBtn.MouseButton1Click:Connect(function()
            idBox.Visible = not idBox.Visible
        end)
    end
end

-- Eventy
searchBox:GetPropertyChangedSignal("Text"):Connect(applyFilters)
minBox:GetPropertyChangedSignal("Text"):Connect(applyFilters)

iconBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    if mainFrame.Visible then
        refreshBtn.Text = "🔄 Pobieram..."
        fetchServers()
        applyFilters()
        refreshBtn.Text = "🔄 Odśwież listę"
    end
end)

closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)

refreshBtn.MouseButton1Click:Connect(function()
    refreshBtn.Text = "🔄 Pobieram..."
    fetchServers()
    applyFilters()
    refreshBtn.Text = "🔄 Odśwież listę"
end)

-- Region dropdown (prosty)
local regions = {"Wszystkie", "United States", "United Kingdom", "Germany", "France", "Poland", "Netherlands", "Singapore", "Japan", "Brazil", "Australia"}
-- Możesz dodać więcej

regionBtn.MouseButton1Click:Connect(function()
    -- Tu można rozbudować do pełnego dropdownu, ale dla szybkości – na razie zmiana na "Wszystkie" lub ręcznie
    -- Jeśli chcesz ładny dropdown – daj znać, dodam
    selectedRegion = selectedRegion == "Wszystkie" and "United States" or "Wszystkie"  -- prosty toggle na test
    regionBtn.Text = selectedRegion .. " ▼"
    applyFilters()
end)

print("✅ Server Browser V5 załadowany! Kliknij niebieską ikonę 🌍 w prawym dolnym rogu.")