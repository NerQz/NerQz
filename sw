-- ================================================
-- Skrypt Lua: Mała ikona + GUI z listą serwerów + FILTRY (w tym REGION)
-- Dodano: Filtr po regionie (dropdown z popularnymi regionami)
-- Uwaga: Roblox oficjalnie nie zwraca regionu w API od dłuższego czasu.
--       Dlatego używamy zewnętrznego API (ip-api.com) do wykrywania regionu na podstawie IP serwera.
--       Może być wolniejsze przy dużej liczbie serwerów i czasem mniej dokładne.
-- ================================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "ServerListGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- ====================== MAŁA IKONA ======================
local iconFrame = Instance.new("Frame")
iconFrame.Name = "Icon"
iconFrame.Size = UDim2.new(0, 65, 0, 65)
iconFrame.Position = UDim2.new(1, -80, 1, -80)
iconFrame.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
iconFrame.BorderSizePixel = 0
iconFrame.Parent = gui

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(1, 0)
iconCorner.Parent = iconFrame

local iconButton = Instance.new("TextButton")
iconButton.Size = UDim2.new(1, 0, 1, 0)
iconButton.BackgroundTransparency = 1
iconButton.Text = "🌍"
iconButton.TextSize = 42
iconButton.Font = Enum.Font.GothamBold
iconButton.TextColor3 = Color3.new(1, 1, 1)
iconButton.Parent = iconFrame

-- Drag ikony
local dragging = false
local dragStart, startPos

iconFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = iconFrame.Position
	end
end)

iconFrame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		iconFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- ====================== GŁÓWNE GUI ======================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainGUI"
mainFrame.Size = UDim2.new(0.68, 0, 0.82, 0)
mainFrame.Position = UDim2.new(0.16, 0, 0.09, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Tytuł
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.BackgroundTransparency = 1
title.Text = "📡 LISTA SERWERÓW"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 28
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Zamknij
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 50, 0, 50)
closeBtn.Position = UDim2.new(1, -55, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextSize = 30
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 10)

-- Odśwież
local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0, 140, 0, 45)
refreshBtn.Position = UDim2.new(1, -200, 0, 8)
refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
refreshBtn.Text = "🔄 Odśwież"
refreshBtn.TextColor3 = Color3.new(1, 1, 1)
refreshBtn.TextSize = 18
refreshBtn.Font = Enum.Font.GothamSemibold
refreshBtn.Parent = mainFrame
local refreshCorner = Instance.new("UICorner", refreshBtn)
refreshCorner.CornerRadius = UDim.new(0, 10)

-- ====================== FILTRY ======================
local filterFrame = Instance.new("Frame")
filterFrame.Size = UDim2.new(1, -30, 0, 145)
filterFrame.Position = UDim2.new(0, 15, 0, 70)
filterFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
filterFrame.BorderSizePixel = 0
filterFrame.Parent = mainFrame

local filterCorner = Instance.new("UICorner")
filterCorner.CornerRadius = UDim.new(0, 10)
filterCorner.Parent = filterFrame

-- Wyszukiwanie po ID
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(0.38, 0, 0, 40)
searchBox.Position = UDim2.new(0, 15, 0, 10)
searchBox.PlaceholderText = "Wyszukaj po ID serwera..."
searchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
searchBox.TextSize = 18
searchBox.Font = Enum.Font.Gotham
searchBox.ClearTextOnFocus = false
searchBox.Parent = filterFrame
local searchCorner = Instance.new("UICorner", searchBox)
searchCorner.CornerRadius = UDim.new(0, 8)

-- Min. graczy
local minPlayersLabel = Instance.new("TextLabel")
minPlayersLabel.Size = UDim2.new(0, 120, 0, 25)
minPlayersLabel.Position = UDim2.new(0.42, 0, 0, 10)
minPlayersLabel.BackgroundTransparency = 1
minPlayersLabel.Text = "Min. graczy:"
minPlayersLabel.TextColor3 = Color3.new(1, 1, 1)
minPlayersLabel.TextSize = 16
minPlayersLabel.Font = Enum.Font.GothamSemibold
minPlayersLabel.TextXAlignment = Enum.TextXAlignment.Left
minPlayersLabel.Parent = filterFrame

local minPlayersBox = Instance.new("TextBox")
minPlayersBox.Size = UDim2.new(0, 80, 0, 35)
minPlayersBox.Position = UDim2.new(0.42, 0, 0, 38)
minPlayersBox.PlaceholderText = "0"
minPlayersBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minPlayersBox.TextColor3 = Color3.new(1, 1, 1)
minPlayersBox.TextSize = 18
minPlayersBox.Font = Enum.Font.Gotham
minPlayersBox.Parent = filterFrame
local minCorner = Instance.new("UICorner", minPlayersBox)
minCorner.CornerRadius = UDim.new(0, 8)

-- Filtr pełne
local fullToggle = Instance.new("TextButton")
fullToggle.Size = UDim2.new(0, 170, 0, 40)
fullToggle.Position = UDim2.new(0.68, 0, 0, 10)
fullToggle.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
fullToggle.Text = "✅ Pokazuj pełne"
fullToggle.TextColor3 = Color3.new(1, 1, 1)
fullToggle.TextSize = 17
fullToggle.Font = Enum.Font.GothamSemibold
fullToggle.Parent = filterFrame
local fullCorner = Instance.new("UICorner", fullToggle)
fullCorner.CornerRadius = UDim.new(0, 10)

local hideFull = false

fullToggle.MouseButton1Click:Connect(function()
	hideFull = not hideFull
	if hideFull then
		fullToggle.Text = "❌ Ukrywaj pełne"
		fullToggle.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
	else
		fullToggle.Text = "✅ Pokazuj pełne"
		fullToggle.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
	end
	applyFilters()
end)

-- ====================== FILTR PO REGIONIE ======================
local regionLabel = Instance.new("TextLabel")
regionLabel.Size = UDim2.new(0, 140, 0, 25)
regionLabel.Position = UDim2.new(0, 15, 0, 65)
regionLabel.BackgroundTransparency = 1
regionLabel.Text = "Region:"
regionLabel.TextColor3 = Color3.new(1, 1, 1)
regionLabel.TextSize = 16
regionLabel.Font = Enum.Font.GothamSemibold
regionLabel.TextXAlignment = Enum.TextXAlignment.Left
regionLabel.Parent = filterFrame

local regionDropdown = Instance.new("TextButton")
regionDropdown.Size = UDim2.new(0.38, 0, 0, 40)
regionDropdown.Position = UDim2.new(0, 15, 0, 92)
regionDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
regionDropdown.Text = "Wszystkie regiony ▼"
regionDropdown.TextColor3 = Color3.new(1, 1, 1)
regionDropdown.TextSize = 18
regionDropdown.Font = Enum.Font.Gotham
regionDropdown.Parent = filterFrame
local regionDropCorner = Instance.new("UICorner", regionDropdown)
regionDropCorner.CornerRadius = UDim.new(0, 8)

local selectedRegion = "Wszystkie"

-- Proste menu dropdown (lista regionów)
local regionList = {"Wszystkie", "United States", "United Kingdom", "Germany", "France", "Poland", "Netherlands", "Singapore", "Japan", "Brazil", "Australia", "Canada", "Unknown"}

local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(0.38, 0, 0, 0)
dropdownFrame.Position = UDim2.new(0, 15, 0, 135)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
dropdownFrame.BorderSizePixel = 0
dropdownFrame.Visible = false
dropdownFrame.Parent = filterFrame
local dropCorner = Instance.new("UICorner", dropdownFrame)
dropCorner.CornerRadius = UDim.new(0, 8)

local dropLayout = Instance.new("UIListLayout")
dropLayout.Padding = UDim.new(0, 2)
dropLayout.Parent = dropdownFrame

for _, reg in ipairs(regionList) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 35)
	btn.BackgroundTransparency = 1
	btn.Text = reg
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextSize = 17
	btn.Font = Enum.Font.Gotham
	btn.Parent = dropdownFrame
	
	btn.MouseButton1Click:Connect(function()
		selectedRegion = reg
		regionDropdown.Text = reg .. " ▼"
		dropdownFrame.Visible = false
		applyFilters()
	end)
end

regionDropdown.MouseButton1Click:Connect(function()
	dropdownFrame.Visible = not dropdownFrame.Visible
end)

-- ====================== SCROLL ======================
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -30, 1, -235)
scroll.Position = UDim2.new(0, 15, 0, 225)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 8
scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scroll

local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0, 5)
listPadding.PaddingBottom = UDim.new(0, 5)
listPadding.Parent = scroll

-- ====================== DANE ======================
local serversData = {}  -- oryginalna lista z API
local enrichedServers = {}  -- lista z dodanym regionem

local currentFilters = {
	search = "",
	minPlayers = 0,
	hideFull = false,
	region = "Wszystkie"
}

-- Funkcja pobierająca region z zewnętrznego API
local function getServerRegion(server)
	if not server.ip then
		return "Unknown"
	end
	
	local success, response = pcall(function()
		return HttpService:GetAsync("http://ip-api.com/json/" .. server.ip .. "?fields=regionName")
	end)
	
	if success then
		local decoded = HttpService:JSONDecode(response)
		return decoded.regionName or "Unknown"
	else
		return "Unknown"
	end
end

local function fetchServers()
	serversData = {}
	enrichedServers = {}
	local cursor = nil
	local maxServers = 250  -- zmniejszyłem trochę dla szybszego działania

	repeat
		local url = "https://games.roblox.com/v1/games/" .. game.GameId .. "/servers/Public?limit=100"
		if cursor then url = url .. "&cursor=" .. cursor end

		local success, response = pcall(function()
			return HttpService:GetAsync(url)
		end)

		if not success then break end

		local decoded = HttpService:JSONDecode(response)

		for _, server in ipairs(decoded.data or {}) do
			if #serversData < maxServers then
				table.insert(serversData, server)
			end
		end

		cursor = decoded.nextPageCursor
	until not cursor or #serversData >= maxServers

	-- Sortuj po liczbie graczy
	table.sort(serversData, function(a, b) return a.playing > b.playing end)

	-- Wzbogacamy o region (może chwilę potrwać)
	refreshBtn.Text = "🔄 Pobieram regiony..."
	for _, server in ipairs(serversData) do
		local region = getServerRegion(server)
		table.insert(enrichedServers, {
			id = server.id,
			playing = server.playing,
			maxPlayers = server.maxPlayers,
			ip = server.ip,
			region = region
		})
	end
end

local function shouldShowServer(server)
	if currentFilters.search \~= "" then
		if not string.find(string.lower(server.id), string.lower(currentFilters.search)) then
			return false
		end
	end

	if server.playing < currentFilters.minPlayers then
		return false
	end

	if currentFilters.hideFull and server.playing >= server.maxPlayers then
		return false
	end

	if currentFilters.region \~= "Wszystkie" and server.region \~= currentFilters.region then
		return false
	end

	return true
end

local function applyFilters()
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	local filtered = {}
	for _, server in ipairs(enrichedServers) do
		if shouldShowServer(server) then
			table.insert(filtered, server)
		end
	end

	if #filtered == 0 then
		local empty = Instance.new("TextLabel")
		empty.Size = UDim2.new(1, 0, 0, 120)
		empty.BackgroundTransparency = 1
		empty.Text = "Nie znaleziono serwerów spełniających filtry"
		empty.TextColor3 = Color3.fromRGB(255, 150, 150)
		empty.TextSize = 22
		empty.Font = Enum.Font.GothamBold
		empty.Parent = scroll
		return
	end

	for _, server in ipairs(filtered) do
		local entry = Instance.new("Frame")
		entry.Size = UDim2.new(1, 0, 0, 75)
		entry.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		entry.BorderSizePixel = 0
		entry.Parent = scroll

		local corner = Instance.new("UICorner", entry)
		corner.CornerRadius = UDim.new(0, 10)

		-- ID
		local idLabel = Instance.new("TextLabel")
		idLabel.Size = UDim2.new(0.38, 0, 1, 0)
		idLabel.Position = UDim2.new(0, 15, 0, 0)
		idLabel.BackgroundTransparency = 1
		idLabel.Text = "🆔 " .. string.sub(server.id, 1, 15) .. "..."
		idLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		idLabel.TextXAlignment = Enum.TextXAlignment.Left
		idLabel.TextSize = 17
		idLabel.Font = Enum.Font.GothamSemibold
		idLabel.Parent = entry

		-- Gracze
		local playersLabel = Instance.new("TextLabel")
		playersLabel.Size = UDim2.new(0.25, 0, 1, 0)
		playersLabel.Position = UDim2.new(0.38, 0, 0, 0)
		playersLabel.BackgroundTransparency = 1
		playersLabel.Text = "👥 " .. server.playing .. " / " .. server.maxPlayers
		playersLabel.TextColor3 = (server.playing >= server.maxPlayers * 0.9) and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(0, 255, 120)
		playersLabel.TextSize = 20
		playersLabel.Font = Enum.Font.GothamBold
		playersLabel.Parent = entry

		-- Region
		local regionLabelEntry = Instance.new("TextLabel")
		regionLabelEntry.Size = UDim2.new(0.22, 0, 1, 0)
		regionLabelEntry.Position = UDim2.new(0.63, 0, 0, 0)
		regionLabelEntry.BackgroundTransparency = 1
		regionLabelEntry.Text = "🌍 " .. server.region
		regionLabelEntry.TextColor3 = Color3.fromRGB(100, 200, 255)
		regionLabelEntry.TextSize = 17
		regionLabelEntry.Font = Enum.Font.GothamSemibold
		regionLabelEntry.Parent = entry

		-- Dołącz
		local joinBtn = Instance.new("TextButton")
		joinBtn.Size = UDim2.new(0, 120, 0, 52)
		joinBtn.Position = UDim2.new(1, -135, 0.5, -26)
		joinBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
		joinBtn.Text = "DOŁĄCZ"
		joinBtn.TextColor3 = Color3.new(1, 1, 1)
		joinBtn.TextSize = 19
		joinBtn.Font = Enum.Font.GothamBold
		joinBtn.Parent = entry

		local joinCorner = Instance.new("UICorner", joinBtn)
		joinCorner.CornerRadius = UDim.new(0, 8)

		joinBtn.MouseButton1Click:Connect(function()
			TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, player)
		end)
	end
end

-- ====================== EVENTY ======================
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	currentFilters.search = searchBox.Text
	applyFilters()
end)

minPlayersBox:GetPropertyChangedSignal("Text"):Connect(function()
	currentFilters.minPlayers = tonumber(minPlayersBox.Text) or 0
	applyFilters()
end)

iconButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
	if mainFrame.Visible then
		refreshBtn.Text = "🔄 Pobieram serwery..."
		fetchServers()
		currentFilters.region = selectedRegion
		applyFilters()
		refreshBtn.Text = "🔄 Odśwież"
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)

refreshBtn.MouseButton1Click:Connect(function()
	refreshBtn.Text = "🔄 Pobieram..."
	fetchServers()
	applyFilters()
	refreshBtn.Text = "🔄 Odśwież"
end)

print("✅ Skrypt z filtrem po regionie załadowany! Kliknij ikonę 🌍 (używa ip-api.com do wykrywania regionu)")