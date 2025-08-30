--// KittenWare Auth UI — HWID Lock + Close-on-download + Town-only + High/Low exec + Success toast
--// Adds: writes a hidden CoreGui flag "auth-successful" on successful auth+download

local APP_NAME   = "KittenWare"
local OWNER_ID   = "FYv0xlPRAW"
local VERSION    = "1.0"
local API_URL    = "https://keyauth.win/api/1.3/"

-- Place detection (Town only)
local TOWN_PLACE_ID = 4991214437

-- Script URLs
local MAIN_SCRIPT_URL_HIGH = "https://raw.githubusercontent.com/kittenware-script/kittenware/main/kittenware.lua"
-- TODO: put your future low-exec build here when it’s ready:
local MAIN_SCRIPT_URL_LOW  = "https://raw.githubusercontent.com/kittenware-script/kittenware/main/kittenware_low.lua"

-- services
local Players              = game:GetService("Players")
local TweenService         = game:GetService("TweenService")
local HttpService          = game:GetService("HttpService")
local Lighting             = game:GetService("Lighting")
local UserInputService     = game:GetService("UserInputService")
local RbxAnalyticsService  = game:GetService("RbxAnalyticsService")
local StarterGui           = game:GetService("StarterGui")

-- theme
local theme = {
    bg = Color3.fromRGB(12,12,14),
    card = Color3.fromRGB(22,22,28),
    header = Color3.fromRGB(28,28,36),
    stroke = Color3.fromRGB(50,50,60),
    text = Color3.fromRGB(230,230,235),
    sub  = Color3.fromRGB(160,160,170),
    primary = Color3.fromRGB(0,120,215),
    primaryHover = Color3.fromRGB(10,140,230),
    danger = Color3.fromRGB(220,80,80),
    success = Color3.fromRGB(80,220,120),
    warn = Color3.fromRGB(255,180,70),
    field = Color3.fromRGB(34,34,42),
    dim = Color3.fromRGB(18,18,22),
    selectOn  = Color3.fromRGB(38,38,48),
    selectOff = Color3.fromRGB(28,28,36),
}

-- notify helper (tries SetCore then falls back to a tiny banner)
local function notify(title, text, duration)
    duration = duration or 5
    local ok = pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "KittenWare",
            Text = text or "",
            Duration = duration
        })
    end)
    if ok then return end
    -- fallback: minimal banner
    local parent = (function()
        local v
        pcall(function() v = game:GetService("CoreGui") end)
        return v or (Players.LocalPlayer and Players.LocalPlayer:FindFirstChildOfClass("PlayerGui"))
    end)()
    if not parent then return end
    local g = Instance.new("ScreenGui")
    g.DisplayOrder = 9999
    g.Name = "KW_Toast"
    g.IgnoreGuiInset = true
    g.Parent = parent
    local f = Instance.new("Frame", g)
    f.BackgroundColor3 = Color3.fromRGB(30,30,38)
    f.Size = UDim2.new(0, 320, 0, 42)
    f.Position = UDim2.new(1, -340, 1, -62)
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    local tl = Instance.new("TextLabel", f)
    tl.BackgroundTransparency = 1
    tl.Font = Enum.Font.GothamBold
    tl.TextColor3 = Color3.fromRGB(255,255,255)
    tl.TextSize = 14
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Text = (title or "KittenWare") .. " — " .. (text or "")
    tl.Position = UDim2.new(0, 12, 0, 10)
    tl.Size = UDim2.new(1, -24, 1, -20)
    task.delay(duration, function()
        pcall(function() g:Destroy() end)
    end)
end

-- utils
local function enc(s) return HttpService:UrlEncode(s) end

-- HWID helpers (executor-agnostic with safe fallbacks)
local function getHWID()
    local ok, id = pcall(function()
        if typeof(gethwid) == "function" then return gethwid() end
        if syn and syn.get_hwid then return syn.get_hwid() end
    end)
    if ok and type(id) == "string" and #id > 0 then return id end
    local ok2, cid = pcall(function() return RbxAnalyticsService:GetClientId() end)
    if ok2 and type(cid) == "string" and #cid > 0 then
        return cid:gsub("[^%w]", ""):lower()
    end
    local uid = (Players.LocalPlayer and Players.LocalPlayer.UserId) or 0
    local plat = tostring(UserInputService:GetPlatform()):gsub("[^%w]", "")
    return ("uid%s-%s"):format(uid, plat)
end
local HWID = getHWID()

local function tweenTo(inst, goal, dur)
    dur = dur or 0.22
    local ok, tw = pcall(function()
        return TweenService:Create(inst, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
    end)
    if ok and tw then tw:Play() else
        for k,v in pairs(goal) do pcall(function() inst[k] = v end) end
    end
end

local function getGuiParent()
    local parent
    if typeof(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and typeof(hui) == "Instance" then parent = hui end
    end
    if not parent then
        pcall(function() parent = game:GetService("CoreGui") end)
    end
    if not parent then
        local lp = Players.LocalPlayer
        if lp then
            parent = lp:FindFirstChildOfClass("PlayerGui") or lp:FindFirstChild("PlayerGui")
            if not parent then
                local ok, pg = pcall(function() return lp:WaitForChild("PlayerGui", 5) end)
                if ok then parent = pg end
            end
        end
    end
    return parent
end

local function protectGui(gui)
    if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end
end

-- HTTP helpers
local function httpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url, true) end)
    if ok then return true, res end
    return false, tostring(res)
end

-- Robust fetch (tries HttpGet, then executor request())
local function fetchText(url)
    local ok, body = pcall(function() return game:HttpGet(url, true) end)
    if ok and type(body) == "string" and #body > 0 then
        return true, body, 200
    end
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if req then
        local ok2, resp = pcall(function() return req({Url=url, Method="GET"}) end)
        if ok2 and resp then
            local code = resp.StatusCode or resp.Status or 0
            local b = resp.Body or resp.body
            if type(b) == "string" and #b > 0 and (code == 200 or code == 0) then
                return true, b, code
            end
            return false, ("HTTP %s / empty body"):format(tostring(code)), code
        end
        return false, "request() failed", 0
    end
    return false, "HttpGet failed and no request() available", 0
end

-- Run chunk silently (swallow compile/runtime errors like BindToClose server-only)
local function runChunkSilently(luaSource)
    local loader = loadstring or load
    if type(loader) ~= "function" then return end
    local chunk = select(2, pcall(loader, luaSource))
    if type(chunk) ~= "function" then return end
    pcall(chunk)
end

-- ====== CoreGui Auth Flag Writer ===========================================
local function writeAuthSuccessFlag(info)
    -- Create (or reuse) a tiny hidden folder under CoreGui: KittenWareBridge/auth-successful
    local parent = nil
    pcall(function() parent = game:GetService("CoreGui") end)
    parent = parent or getGuiParent()
    if not parent then return end

    local root = parent:FindFirstChild("KittenWareBridge") or Instance.new("Folder")
    root.Name = "KittenWareBridge"
    root.Archivable = false
    root.Parent = parent

    -- BoolValue named "auth-successful" (hidden, non-visual)
    local flag = root:FindFirstChild("auth-successful")
    if not flag then
        flag = Instance.new("BoolValue")
        flag.Name = "auth-successful"
        flag.Parent = root
    end
    flag.Value = true

    -- Optional: drop some tiny metadata as attributes (not required for the loader)
    pcall(function()
        root:SetAttribute("app", APP_NAME)
        root:SetAttribute("version", VERSION)
        root:SetAttribute("ts", os.time and os.time() or tick())
        if type(info) == "table" then
            for k,v in pairs(info) do
                if typeof(v) ~= "Instance" then
                    root:SetAttribute(tostring(k), tostring(v))
                end
            end
        end
    end)
end
-- ===========================================================================

-- KeyAuth
local sessionId
local function initSession()
    local url = API_URL .. "?type=init&name=" .. enc(APP_NAME) .. "&ownerid=" .. enc(OWNER_ID) .. "&ver=" .. enc(VERSION)
    local ok, body = httpGet(url)
    if not ok then return false, "Connection failed: " .. body end
    local good, decoded = pcall(function() return HttpService:JSONDecode(body) end)
    if not good or not decoded then return false, "Invalid server response format" end
    if decoded.success then
        sessionId = decoded.sessionid
        return true, "Session initialized"
    else
        return false, decoded.message or "Initialization failed"
    end
end

local function checkKey(key)
    if not sessionId then
        local ok, msg = initSession()
        if not ok then return false, msg end
    end
    local url = API_URL
        .. "?type=license"
        .. "&key=" .. enc(key)
        .. "&name=" .. enc(APP_NAME)
        .. "&ownerid=" .. enc(OWNER_ID)
        .. "&ver=" .. enc(VERSION)
        .. "&sessionid=" .. enc(sessionId)
        .. "&hwid=" .. enc(HWID)

    local ok, body = httpGet(url)
    if not ok then return false, "Connection failed: " .. body end
    local good, decoded = pcall(function() return HttpService:JSONDecode(body) end)
    if not good or not decoded then return false, "Invalid server response format" end
    if decoded.success then return true, "Key validated successfully" end

    local msg = tostring(decoded.message or "Key validation failed")
    if msg:lower():find("hwid") then
        pcall(function() if typeof(setclipboard) == "function" then setclipboard(HWID) end end)
        msg = msg .. "  (Device ID: " .. string.sub(HWID, 1, 12) .. "…"
            .. (typeof(setclipboard)=="function" and " — copied to clipboard)" or ")")
    end
    return false, msg
end

-- ========= TOWN CHECK (EARLY EXIT) =========
if game.PlaceId ~= TOWN_PLACE_ID then
    notify("KittenWare", "Wrong game", 5)
    return
end

-- UI
local function createUI()
    local parent = getGuiParent()
    if not parent then
        notify("KittenWare", "UI error: no parent", 5)
        return
    end

    local blur
    pcall(function()
        blur = Instance.new("BlurEffect")
        blur.Size = 0
        blur.Parent = Lighting
        tweenTo(blur, {Size = 12}, 0.2)
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "KittenWareAuth"
    gui.DisplayOrder = 9999
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    protectGui(gui)
    gui.Parent = parent

    local function destroyUI()
        pcall(function() if blur then tweenTo(blur, {Size=0}, 0.12) end end)
        task.delay(0.12, function()
            pcall(function() if blur then blur:Destroy() end end)
            pcall(function() if gui then gui:Destroy() end end)
        end)
    end

    local dim = Instance.new("Frame")
    dim.BackgroundColor3 = theme.bg
    dim.BackgroundTransparency = 0.4
    dim.Size = UDim2.new(1,0,1,0)
    dim.ZIndex = 1
    dim.Parent = gui

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 480, 0, 380)
    card.Position = UDim2.new(0.5, -240, 0.5, -190)
    card.BackgroundColor3 = theme.card
    card.BackgroundTransparency = 0.05
    card.ZIndex = 10
    card.Parent = gui

    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)
    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    cardStroke.Thickness = 2
    cardStroke.Transparency = 0.15
    cardStroke.Color = theme.stroke

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 56)
    header.BackgroundColor3 = theme.header
    header.ZIndex = 11
    header.Parent = card
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = string.upper(APP_NAME)
    title.TextSize = 17
    title.TextColor3 = theme.text
    title.Position = UDim2.new(0, 18, 0, 14)
    title.Size = UDim2.new(0, 260, 0, 22)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 12
    title.Parent = header

    local subtitle = Instance.new("TextLabel")
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.Text = "v" .. VERSION .. "  •  License Authentication • Town detected"
    subtitle.TextSize = 13
    subtitle.TextColor3 = theme.sub
    subtitle.Position = UDim2.new(0, 18, 0, 32)
    subtitle.Size = UDim2.new(1, -36, 0, 18)
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.ZIndex = 12
    subtitle.Parent = header

    local close = Instance.new("TextButton")
    close.Text = "✕"
    close.Font = Enum.Font.GothamBold
    close.TextSize = 16
    close.TextColor3 = theme.sub
    close.AutoButtonColor = false
    close.BackgroundTransparency = 1
    close.Size = UDim2.new(0, 32, 0, 32)
    close.Position = UDim2.new(1, -42, 0, 12)
    close.ZIndex = 12
    close.Parent = header
    close.MouseButton1Click:Connect(destroyUI)

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -36, 1, -110)
    content.Position = UDim2.new(0, 18, 0, 80)
    content.BackgroundTransparency = 1
    content.ZIndex = 11
    content.Parent = card

    local blurb = Instance.new("TextLabel")
    blurb.BackgroundTransparency = 1
    blurb.Font = Enum.Font.Gotham
    blurb.Text = "Enter your license key below to continue.\nThis license will be locked to this device."
    blurb.TextSize = 14
    blurb.TextWrapped = true
    blurb.TextXAlignment = Enum.TextXAlignment.Left
    blurb.TextColor3 = theme.sub
    blurb.Size = UDim2.new(1, 0, 0, 40)
    blurb.ZIndex = 11
    blurb.Parent = content

    local field = Instance.new("Frame")
    field.Size = UDim2.new(1, 0, 0, 44)
    field.Position = UDim2.new(0, 0, 0, 44)
    field.BackgroundColor3 = theme.field
    field.ZIndex = 11
    field.Parent = content
    Instance.new("UICorner", field).CornerRadius = UDim.new(0, 8)
    local fS = Instance.new("UIStroke", field) fS.Color = theme.stroke fS.Transparency = 0.25 fS.Thickness = 1.5

    local input = Instance.new("TextBox")
    input.ClearTextOnFocus = false
    input.Text = ""
    input.PlaceholderText = "Enter your license key"
    input.TextColor3 = theme.text
    input.PlaceholderColor3 = Color3.fromRGB(120,120,130)
    input.BackgroundTransparency = 1
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.Size = UDim2.new(1, -16, 1, 0)
    input.Position = UDim2.new(0, 8, 0, 0)
    input.ZIndex = 12
    input.Parent = field

    -- Device ID preview
    local idPreview = Instance.new("TextLabel")
    idPreview.BackgroundTransparency = 1
    idPreview.Font = Enum.Font.Gotham
    idPreview.Text = "Device ID: " .. string.sub(HWID, 1, 12) .. "…"
    idPreview.TextSize = 12
    idPreview.TextColor3 = theme.sub
    idPreview.TextXAlignment = Enum.TextXAlignment.Left
    idPreview.Size = UDim2.new(1, 0, 0, 18)
    idPreview.Position = UDim2.new(0, 0, 0, 78)
    idPreview.ZIndex = 11
    idPreview.Parent = content

    -- High/Low exec selector
    local selectedTier = "high" -- default
    local tierFrame = Instance.new("Frame")
    tierFrame.BackgroundTransparency = 1
    tierFrame.Size = UDim2.new(1, 0, 0, 40)
    tierFrame.Position = UDim2.new(0, 0, 0, 100)
    tierFrame.ZIndex = 11
    tierFrame.Parent = content

    local layout = Instance.new("UIListLayout", tierFrame)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 10)

    local function mkTierButton(label)
        local btn = Instance.new("TextButton")
        btn.AutoButtonColor = false
        btn.Size = UDim2.new(0, 130, 0, 34)
        btn.BackgroundColor3 = theme.selectOff
        btn.Text = label
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.TextColor3 = theme.text
        btn.ZIndex = 12
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local st = Instance.new("UIStroke", btn)
        st.Color = theme.stroke
        st.Transparency = 0.25
        st.Thickness = 1.5
        return btn
    end

    local highBtn = mkTierButton("High exec")
    highBtn.Parent = tierFrame
    local lowBtn  = mkTierButton("Low exec")
    lowBtn.Parent = tierFrame

    local function refreshTier()
        tweenTo(highBtn, {BackgroundColor3 = (selectedTier=="high" and theme.selectOn or theme.selectOff)}, 0.08)
        tweenTo(lowBtn,  {BackgroundColor3 = (selectedTier=="low"  and theme.selectOn or theme.selectOff)}, 0.08)
    end
    refreshTier()
    highBtn.MouseButton1Click:Connect(function() selectedTier = "high"; refreshTier() end)
    lowBtn.MouseButton1Click:Connect(function()  selectedTier = "low";  refreshTier() end)

    local status = Instance.new("TextLabel")
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.Text = ""
    status.TextSize = 14
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextColor3 = theme.sub
    status.Size = UDim2.new(1, 0, 0, 22)
    status.Position = UDim2.new(0, 0, 0, 146)
    status.ZIndex = 11
    status.Parent = content

    local buttons = Instance.new("Frame")
    buttons.BackgroundTransparency = 1
    buttons.Size = UDim2.new(1, -36, 0, 44)
    buttons.Position = UDim2.new(0, 18, 1, -52)
    buttons.ZIndex = 11
    buttons.Parent = card
    local layout2 = Instance.new("UIListLayout", buttons)
    layout2.FillDirection = Enum.FillDirection.Horizontal
    layout2.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout2.VerticalAlignment = Enum.VerticalAlignment.Center
    layout2.Padding = UDim.new(0, 10)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "Close"
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = theme.text
    closeBtn.AutoButtonColor = false
    closeBtn.BackgroundColor3 = theme.dim
    closeBtn.Size = UDim2.new(0, 96, 1, 0)
    closeBtn.ZIndex = 12
    closeBtn.Parent = buttons
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    local cbS = Instance.new("UIStroke", closeBtn) cbS.Color = theme.stroke cbS.Transparency = 0.25
    closeBtn.MouseButton1Click:Connect(destroyUI)

    local go = Instance.new("TextButton")
    go.Text = "Authenticate"
    go.Font = Enum.Font.GothamBold
    go.TextSize = 14
    go.TextColor3 = Color3.fromRGB(255,255,255)
    go.AutoButtonColor = false
    go.BackgroundColor3 = theme.primary
    go.Size = UDim2.new(0, 160, 1, 0)
    go.ZIndex = 12
    go.Parent = buttons
    Instance.new("UICorner", go).CornerRadius = UDim.new(0, 8)
    go.MouseEnter:Connect(function() tweenTo(go, {BackgroundColor3 = theme.primaryHover}, 0.1) end)
    go.MouseLeave:Connect(function() tweenTo(go, {BackgroundColor3 = theme.primary}, 0.1) end)

    -- auth flow
    local processing = false
    local function setProcessing(on)
        processing = on
        go.AutoButtonColor = not on
        closeBtn.AutoButtonColor = not on
        input.ClearTextOnFocus = not on
        go.Text = on and "Working..." or "Authenticate"
    end

    local function precheckKey(k)
        if not k or k == "" then return false, "Please enter a license key" end
        if #k < 6 then return false, "That key looks too short" end
        return true
    end

    go.MouseButton1Click:Connect(function()
        if processing then return end
        local key = input.Text
        local ok0, msg0 = precheckKey(key)
        if not ok0 then
            status.TextColor3 = theme.danger
            status.Text = msg0
            return
        end

        setProcessing(true)
        status.TextColor3 = theme.sub
        status.Text = "Initializing session..."
        task.wait(0.03)

        local ok1, msg1 = initSession()
        if not ok1 then
            status.TextColor3 = theme.danger
            status.Text = msg1
            setProcessing(false)
            return
        end

        status.Text = "Validating key..."
        task.wait(0.03)
        local ok2, msg2 = checkKey(key)
        if not ok2 then
            status.TextColor3 = theme.danger
            status.Text = msg2
            setProcessing(false)
            return
        end

        -- Decide which script to fetch (high or low)
        local url = (selectedTier == "low") and MAIN_SCRIPT_URL_LOW or MAIN_SCRIPT_URL_HIGH

        status.TextColor3 = theme.sub
        status.Text = ("Downloading (%s exec)..."):format(selectedTier)
        local okD, body = fetchText(url)
        if not okD then
            status.TextColor3 = theme.danger
            status.Text = "Download failed."
            setProcessing(false)
            return
        end

        -- Immediately write CoreGui flag BEFORE closing UI
        writeAuthSuccessFlag({
            tier = selectedTier,
            hwid = string.sub(HWID or "", 1, 16) .. "…"
        })

        -- Close UI immediately after successful download
        status.TextColor3 = theme.success
        status.Text = "Success."
        task.delay(0.05, destroyUI)

        -- Show post-success tip
        task.delay(0.25, function()
            notify("KittenWare", "Right-Click to open", 6)
        end)

        -- Run silently in the background; swallow any errors (e.g., server-only APIs).
        task.spawn(function()
            runChunkSilently(body)
        end)
    end)
end

-- main
local ok, err = pcall(createUI)
if not ok then
    notify("KittenWare", "UI error: ".. tostring(err), 6)
end
