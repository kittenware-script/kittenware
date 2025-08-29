-- UI for KeyAuth system with API 1.3
local name = "KittenWare"
local ownerid = "FYv0xlPRAW"
local version = "1.0"
local api_url = "https://keyauth.win/api/1.3/"

-- Function to make HTTP requests with better error handling
local function httpRequest(url)
    local success, response = pcall(function()
        local result = game:HttpGet(url, true)
        return result
    end)
    
    if success then
        return response
    else
        return nil, "HTTP request failed: " .. response
    end
end

-- Function to initialize session with KeyAuth API
local function initSession()
    local url = api_url .. "?type=init&name=" .. name .. "&ownerid=" .. ownerid .. "&ver=" .. version
    print("Init URL: " .. url)
    
    local response, err = httpRequest(url)
    if not response then
        return false, nil, err or "Connection failed"
    end
    
    local success, decoded = pcall(function()
        return game:GetService("HttpService"):JSONDecode(response)
    end)
    
    if not success or not decoded then
        return false, nil, "Invalid server response format"
    end
    
    if decoded.success then
        return true, decoded.sessionid, "Session initialized"
    else
        return false, nil, decoded.message or "Initialization failed"
    end
end

-- Function to check key with KeyAuth API
local function checkKey(key, sessionid)
    local url = api_url .. "?type=license&key=" .. key .. "&name=" .. name .. "&ownerid=" .. ownerid .. "&ver=" .. version .. "&sessionid=" .. sessionid
    print("License URL: " .. url)
    
    local response, err = httpRequest(url)
    if not response then
        return false, err or "Connection failed"
    end
    
    local success, decoded = pcall(function()
        return game:GetService("HttpService"):JSONDecode(response)
    end)
    
    if not success or not decoded then
        print("Raw response: " .. response)
        return false, "Invalid server response format"
    end
    
    if decoded.success then
        return true, "Key validated successfully"
    else
        return false, decoded.message or "Key validation failed"
    end
end

-- Create UI
local function createUI()
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KittenWareAuth"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Create Background Frame
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.Position = UDim2.new(0, 0, 0, 0)
    background.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    background.BackgroundTransparency = 0.3
    background.BorderSizePixel = 0
    background.Parent = screenGui
    
    -- Create Main Container
    local mainContainer = Instance.new("Frame")
    mainContainer.Size = UDim2.new(0, 400, 0, 280)
    mainContainer.Position = UDim2.new(0.5, -200, 0.5, -140)
    mainContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainContainer.BorderSizePixel = 0
    mainContainer.Parent = screenGui
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 8)
    containerCorner.Parent = mainContainer
    
    local containerStroke = Instance.new("UIStroke")
    containerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    containerStroke.Color = Color3.fromRGB(45, 45, 50)
    containerStroke.Thickness = 2
    containerStroke.Parent = mainContainer
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    header.BorderSizePixel = 0
    header.Parent = mainContainer
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header
    
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 0, 0, 20)
    logo.Position = UDim2.new(0.5, -60, 0.5, -10)
    logo.Text = "KITTENWARE"
    logo.TextColor3 = Color3.fromRGB(220, 220, 220)
    logo.BackgroundTransparency = 1
    logo.Font = Enum.Font.GothamBold
    logo.TextSize = 16
    logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.Parent = header
    
    local versionText = Instance.new("TextLabel")
    versionText.Size = UDim2.new(0, 0, 0, 14)
    versionText.Position = UDim2.new(0.5, 40, 0.5, -7)
    versionText.Text = "v" .. version
    versionText.TextColor3 = Color3.fromRGB(150, 150, 150)
    versionText.BackgroundTransparency = 1
    versionText.Font = Enum.Font.Gotham
    versionText.TextSize = 12
    versionText.TextXAlignment = Enum.TextXAlignment.Left
    versionText.Parent = header
    
    -- Content Area
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -40, 1, -100)
    content.Position = UDim2.new(0, 20, 0, 60)
    content.BackgroundTransparency = 1
    content.Parent = mainContainer
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "License Authentication"
    title.TextColor3 = Color3.fromRGB(220, 220, 220)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = content
    
    -- Description
    local description = Instance.new("TextLabel")
    description.Size = UDim2.new(1, 0, 0, 40)
    description.Position = UDim2.new(0, 0, 0, 30)
    description.Text = "Enter your license key below to access KittenWare features."
    description.TextColor3 = Color3.fromRGB(150, 150, 150)
    description.BackgroundTransparency = 1
    description.Font = Enum.Font.Gotham
    description.TextSize = 14
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.TextWrapped = true
    description.Parent = content
    
    -- Input Field
    local inputContainer = Instance.new("Frame")
    inputContainer.Size = UDim2.new(1, 0, 0, 40)
    inputContainer.Position = UDim2.new(0, 0, 0, 80)
    inputContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    inputContainer.BorderSizePixel = 0
    inputContainer.Parent = content
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = inputContainer
    
    local textBox = Instance.new("TextBox")
    textBox.Name = "KeyInput"
    textBox.Size = UDim2.new(1, -20, 1, -10)
    textBox.Position = UDim2.new(0, 10, 0, 5)
    textBox.BackgroundTransparency = 1
    textBox.TextColor3 = Color3.fromRGB(220, 220, 220)
    textBox.PlaceholderText = "Enter your license key"
    textBox.Text = ""
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 14
    textBox.Parent = inputContainer
    
    -- Status Message
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(1, 0, 0, 20)
    status.Position = UDim2.new(0, 0, 0, 130)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(150, 150, 150)
    status.Text = ""
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = content
    
    -- Button Container
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(1, -40, 0, 40)
    buttonContainer.Position = UDim2.new(0, 20, 1, -60)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = mainContainer
    
    -- Authenticate Button
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 120, 1, 0)
    button.Position = UDim2.new(1, -120, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = "Authenticate"
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.Parent = buttonContainer
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 80, 1, 0)
    closeButton.Position = UDim2.new(0, 0, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    closeButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    closeButton.Text = "Close"
    closeButton.Font = Enum.Font.Gotham
    closeButton.TextSize = 14
    closeButton.Parent = buttonContainer
    
    local closeButtonCorner = Instance.new("UICorner")
    closeButtonCorner.CornerRadius = UDim.new(0, 6)
    closeButtonCorner.Parent = closeButton
    
    -- Button click handler
    button.MouseButton1Click:Connect(function()
        local key = textBox.Text
        if not key or key == "" then
            status.Text = "Please enter a license key"
            status.TextColor3 = Color3.fromRGB(220, 80, 80)
            return
        end
        
        -- Disable button to prevent multiple clicks
        button.Text = "Processing..."
        button.Active = false
        
        status.Text = "Initializing session..."
        status.TextColor3 = Color3.fromRGB(150, 150, 150)
        
        -- Use a delay to allow UI to update
        task.wait(0.1)
        
        local initSuccess, sessionid, initMessage = initSession()
        
        if not initSuccess then
            status.Text = initMessage
            status.TextColor3 = Color3.fromRGB(220, 80, 80)
            button.Text = "Authenticate"
            button.Active = true
            return
        end
        
        status.Text = "Validating key..."
        task.wait(0.1)
        
        local success, message = checkKey(key, sessionid)
        
        if success then
            status.Text = message
            status.TextColor3 = Color3.fromRGB(80, 220, 80)
            
            -- Load the main cheat without checking for errors
            task.spawn(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/kittenware-script/kittenware/refs/heads/main/kittenware.lua"))()
            end)
            
            -- Wait a moment to show success message
            wait(1.5)
            -- Properly destroy the UI
            screenGui:Destroy()
        else
            status.Text = message
            status.TextColor3 = Color3.fromRGB(220, 80, 80)
            -- Re-enable button if authentication failed
            button.Text = "Authenticate"
            button.Active = true
        end
    end)
    
    -- Close button handler
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

-- Main execution
local function main()
    local success, err = pcall(createUI)
    if not success then
        warn("UI setup error: " .. err)
    end
end

main()
