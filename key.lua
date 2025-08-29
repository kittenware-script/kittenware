--// KittenWare Auth UI — Safe Hotfix (shows even in picky executors)

local APP_NAME   = "KittenWare"
local OWNER_ID   = "FYv0xlPRAW"
local VERSION    = "1.0"
local API_URL    = "https://keyauth.win/api/1.3/"
local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/kittenware-script/kittenware/refs/heads/main/kittenware.lua"

-- services
local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local HttpService    = game:GetService("HttpService")
local Lighting       = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

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
}

-- utils
local function enc(s) return HttpService:UrlEncode(s) end
local function log(...) pcall(print, "[KittenWareAuth]", ...) end

local function tweenTo(inst, goal, dur)
    dur = dur or 0.22
    local ok, tw = pcall(function()
        return TweenService:Create(inst, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
    end)
    if ok and tw then tw:Play() else
        -- hard apply as fallback
        for k,v in pairs(goal) do pcall(function() inst[k] = v end) end
    end
end

local function getGuiParent()
    -- prefer hidden UI container if executor provides it
    local parent
    if typeof(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and typeof(hui) == "Instance" then parent = hui end
    end
    if not parent then parent = game:FindFirstChildOfClass("CoreGui") end
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

-- http helpers
local function httpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url, true) end)
    if ok then return true, res end
    return false, tostring(res)
end

-- keyauth
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
    local url = API_URL .. "?type=license&key=" .. enc(key) .. "&name=" .. enc(APP_NAME) ..
                "&ownerid=" .. enc(OWNER_ID) .. "&ver=" .. enc(VERSION) .. "&sessionid=" .. enc(sessionId)
    local ok, body = httpGet(url)
    if not ok then return false, "Connection failed: " .. body end
    local good, decoded = pcall(function() return HttpService:JSONDecode(body) end)
    if not good or not decoded then return false, "Invalid server response format" end
    if decoded.success then return true, "Key validated successfully" end
    return false, decoded.message or "Key validation failed"
end

-- UI
local function createUI()
    local parent = getGuiParent()
    if not parent then
        warn("KittenWareAuth: No visible GUI parent (CoreGui/PlayerGui unavailable). Are you running client-side?")
        return
    end

    -- optional blur (don’t let this block the UI)
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

    local dim = Instance.new("Frame")
    dim.BackgroundColor3 = theme.bg
    dim.BackgroundTransparency = 0.4
    dim.Size = UDim2.new(1,0,1,0)
    dim.ZIndex = 1
    dim.Parent = gui

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 460, 0, 320)
    card.Position = UDim2.new(0.5, -230, 0.5, -160)
    card.BackgroundColor3 = theme.card
    card.BackgroundTransparency = 0.05 -- visible even if tween fails
    card.ZIndex = 10
    card.Parent = gui

    local cardCorner = Instance.new("UICorner", card) cardCorner.CornerRadius = UDim.new(0, 12)
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
    subtitle.Text = "v" .. VERSION .. "  •  License Authentication"
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

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -36, 1, -110)
    content.Position = UDim2.new(0, 18, 0, 80)
    content.BackgroundTransparency = 1
    content.ZIndex = 11
    content.Parent = card

    local blurb = Instance.new("TextLabel")
    blurb.BackgroundTransparency = 1
    blurb.Font = Enum.Font.Gotham
    blurb.Text = "Enter your license key below to continue."
    blurb.TextSize = 14
    blurb.TextWrapped = true
    blurb.TextXAlignment = Enum.TextXAlignment.Left
    blurb.TextColor3 = theme.sub
    blurb.Size = UDim2.new(1, 0, 0, 32)
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

    local status = Instance.new("TextLabel")
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.Text = ""
    status.TextSize = 14
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextColor3 = theme.sub
    status.Size = UDim2.new(1, 0, 0, 22)
    status.Position = UDim2.new(0, 0, 0, 100)
    status.ZIndex = 11
    status.Parent = content

    local buttons = Instance.new("Frame")
    buttons.BackgroundTransparency = 1
    buttons.Size = UDim2.new(1, -36, 0, 44)
    buttons.Position = UDim2.new(0, 18, 1, -52)
    buttons.ZIndex = 11
    buttons.Parent = card
    local layout = Instance.new("UIListLayout", buttons)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 10)

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

    local go = Instance.new("TextButton")
    go.Text = "Authenticate"
    go.Font = Enum.Font.GothamBold
    go.TextSize = 14
    go.TextColor3 = Color3.fromRGB(255,255,255)
    go.AutoButtonColor = false
    go.BackgroundColor3 = theme.primary
    go.Size = UDim2.new(0, 140, 1, 0)
    go.ZIndex = 12
    go.Parent = buttons
    Instance.new("UICorner", go).CornerRadius = UDim.new(0, 8)

    -- basic hover
    go.MouseEnter:Connect(function() tweenTo(go, {BackgroundColor3 = theme.primaryHover}, 0.1) end)
    go.MouseLeave:Connect(function() tweenTo(go, {BackgroundColor3 = theme.primary}, 0.1) end)
    closeBtn.MouseEnter:Connect(function() tweenTo(closeBtn, {BackgroundColor3 = theme.field}, 0.1) end)
    closeBtn.MouseLeave:Connect(function() tweenTo(closeBtn, {BackgroundColor3 = theme.dim}, 0.1) end)

    -- close/destroy
    local destroying = false
    local function destroyUI()
        if destroying then return end
        destroying = true
        pcall(function() tweenTo(card, {BackgroundTransparency = 1}, 0.15) end)
        pcall(function() tweenTo(dim,  {BackgroundTransparency = 1}, 0.15) end)
        pcall(function() if blur then tweenTo(blur, {Size=0}, 0.15) end end)
        task.delay(0.16, function()
            if gui then gui:Destroy() end
            pcall(function() if blur then blur:Destroy() end end)
        end)
    end
    close.MouseButton1Click:Connect(destroyUI)
    closeBtn.MouseButton1Click:Connect(destroyUI)
    UserInputService.InputBegan:Connect(function(io, gp)
        if gp then return end
        if io.KeyCode == Enum.KeyCode.Escape then destroyUI() end
    end)

    -- auth flow
    local processing = false
    local function precheckKey(k)
        if not k or k == "" then return false, "Please enter a license key" end
        if #k < 6 then return false, "That key looks too short" end
        return true
    end

    local function setProcessing(on)
        processing = on
        go.AutoButtonColor = not on
        closeBtn.AutoButtonColor = not on
        input.ClearTextOnFocus = not on
        go.Text = on and "Working..." or "Authenticate"
    end

    go.MouseButton1Click:Connect(function()
        if processing then return end
        local k = input.Text
        local ok, msg = precheckKey(k)
        if not ok then
            status.TextColor3 = theme.danger
            status.Text = msg
            return
        end

        setProcessing(true)
        status.TextColor3 = theme.sub
        status.Text = "Initializing session..."
        task.wait(0.03)

        local sOk, sMsg = initSession()
        if not sOk then
            status.TextColor3 = theme.danger
            status.Text = sMsg
            setProcessing(false)
            return
        end

        status.TextColor3 = theme.sub
        status.Text = "Validating key..."
        task.wait(0.03)

        local good, message = checkKey(k)
        if good then
            status.TextColor3 = theme.success
            status.Text = message
            -- load main
            task.spawn(function()
                local loadedOk, loadErr = pcall(function()
                    local raw = game:HttpGet(MAIN_SCRIPT_URL, true)
                    local f = loadstring(raw)
                    if typeof(f) == "function" then f() end
                end)
                if not loadedOk then
                    log("Script load error:", loadErr)
                end
            end)
            task.delay(1, destroyUI)
        else
            status.TextColor3 = theme.danger
            status.Text = message
            setProcessing(false)
        end
    end)
end

-- main
local ok, err = pcall(createUI)
if not ok then
    warn("KittenWareAuth UI error: " .. tostring(err))
    -- last-resort tiny banner so you *see something* if parent/tween failed
    local p = game:FindFirstChildOfClass("CoreGui") or (Players.LocalPlayer and Players.LocalPlayer:FindFirstChildOfClass("PlayerGui"))
    if p then
        local g = Instance.new("ScreenGui", p)
        g.DisplayOrder = 9999
        local b = Instance.new("TextLabel", g)
        b.Size = UDim2.new(1,0,0,30)
        b.BackgroundColor3 = Color3.fromRGB(50,0,0)
        b.TextColor3 = Color3.new(1,1,1)
        b.Text = "KittenWareAuth failed to build UI: ".. tostring(err)
    end
end
