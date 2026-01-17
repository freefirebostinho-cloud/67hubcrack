-- 67 HUB v1.0 - DARK BLUE EDITION COMPLETE
-- ✅ All Features | ✅ Platform Builder | ✅ Smooth Animations

local plr = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local run = game:GetService("RunService")
local sg = game:GetService("StarterGui")
local tw = game:GetService("TweenService")

-- ===== CONFIGURATION =====
local CONFIG = {
    -- Movement
    SuperJump = false,
    NoClip = false,
    FlyMode = false,
    SpeedBoost = false,
    PlatformBuilder = false,
    WalkSpeed = 50,
    JumpPower = 150,
    FlySpeed = 1, -- FIXED at minimum
    PlatformHeight = 3,
    
    -- Combat
    KingMode = false,
    InfiniteHealth = false,
    
    -- Visual
    Fullbright = false,
    FOV = 90,
    RemoveFog = false,
    ESPBoxes = false,
    ESPNames = false,
    ESPDistance = false,
    Tracers = false,
    
    -- FPS Boost
    FPSBoost = false,
    DisableParticles = false,
    
    -- Misc
    AntiAFK = false,
    RemoveKillBricks = false,
    InfiniteZoom = false,
    FreeCam = false,
    ShowFPS = false,
}

-- State Variables
local flyCheckpoint = nil
local flyCheckpointSet = false
local originalWalkSpeed = 16
local originalJumpPower = 50
local originalFOV = 70
local currentTab = "Main"
local espCache = {}
local connections = {}
local processedObjects = {}
local originalSettings = {lighting = {}}
local platformActive = false
local platformSpeed = 16

-- ===== GOD/KING FILTER =====
local function processText(txt)
    if type(txt) ~= "string" then return txt end
    if not txt:find("god") and not txt:find("God") and not txt:find("GOD") then return txt end
    
    txt = txt:gsub("GOD", "KING"):gsub("God", "King"):gsub("god", "king")
    txt = txt:gsub("GodMode", "KingMode"):gsub("godmode", "kingmode"):gsub("GODMODE", "KINGMODE")
    return txt
end

local function scanInstance(inst)
    if processedObjects[inst] then return end
    processedObjects[inst] = true
    
    pcall(function()
        if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
            if inst.Text and inst.Text ~= "" then
                local newTxt = processText(inst.Text)
                if newTxt ~= inst.Text then inst.Text = newTxt end
            end
        end
        if inst.Name and inst.Name ~= "" then
            local newName = processText(inst.Name)
            if newName ~= inst.Name then inst.Name = newName end
        end
    end)
end

workspace.DescendantAdded:Connect(function(obj) task.wait(0.05) scanInstance(obj) end)
plr.PlayerGui.DescendantAdded:Connect(function(obj) task.wait(0.05) scanInstance(obj) end)

task.spawn(function()
    task.wait(2)
    for i, obj in pairs(workspace:GetDescendants()) do
        scanInstance(obj)
        if i % 100 == 0 then task.wait() end
    end
    for i, obj in pairs(plr.PlayerGui:GetDescendants()) do
        scanInstance(obj)
        if i % 50 == 0 then task.wait() end
    end
end)

-- ===== COLOR SCHEME - DARK BLUE =====
local COLORS = {
    Primary = Color3.fromRGB(30, 80, 180),      
    Secondary = Color3.fromRGB(20, 50, 120),    
    Accent = Color3.fromRGB(50, 120, 240),      
    Background = Color3.fromRGB(10, 10, 15),    
    SecondaryBG = Color3.fromRGB(18, 18, 25),   
    Frame = Color3.fromRGB(25, 30, 40),         
    Text = Color3.fromRGB(255, 255, 255),       
    TextDim = Color3.fromRGB(180, 190, 200),    
    Success = Color3.fromRGB(50, 255, 50),
    Error = Color3.fromRGB(255, 50, 50),
    Green = Color3.fromRGB(0, 255, 0),
}

-- ===== UTILITY FUNCTIONS =====
local function tween(obj, props, duration, style, direction)
    local info = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    tw:Create(obj, info, props):Play()
end

local function notify(title, text, duration)
    pcall(function()
        sg:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3,
            Icon = "rbxassetid://109911941749492"
        })
    end)
end

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner", parent)
    corner.CornerRadius = UDim.new(0, radius or 10)
    return corner
end

local function createStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke", parent)
    stroke.Color = color or COLORS.Primary
    stroke.Thickness = thickness or 2
    stroke.Transparency = transparency or 0
    return stroke
end

local function createGradient(parent, colors, rotation)
    local gradient = Instance.new("UIGradient", parent)
    gradient.Color = colors
    gradient.Rotation = rotation or 0
    return gradient
end

local function disconnectConnection(key)
    if connections[key] then
        pcall(function() connections[key]:Disconnect() end)
        connections[key] = nil
    end
end

-- ===== GUI CREATION =====
local gui = Instance.new("ScreenGui")
gui.Name = "LHub_" .. math.random(1000, 9999)
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game.CoreGui

-- ===== ICON BUTTON =====
local iconBtn = Instance.new("ImageButton", gui)
iconBtn.Size = UDim2.new(0, 0, 0, 0)
iconBtn.Position = UDim2.new(0, 20, 0, 20)
iconBtn.BackgroundColor3 = COLORS.Background
iconBtn.BorderSizePixel = 0
iconBtn.AutoButtonColor = false
iconBtn.Image = "rbxassetid://109911941749492"
iconBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
iconBtn.ScaleType = Enum.ScaleType.Fit
iconBtn.Active = true
iconBtn.Draggable = true
iconBtn.ImageTransparency = 1

createCorner(iconBtn, 14)
createStroke(iconBtn, COLORS.Primary, 3, 0.2)

local iconGlow = Instance.new("ImageLabel", iconBtn)
iconGlow.Size = UDim2.new(1, 20, 1, 20)
iconGlow.Position = UDim2.new(0, -10, 0, -10)
iconGlow.BackgroundTransparency = 1
iconGlow.Image = "rbxassetid://4996891970"
iconGlow.ImageColor3 = COLORS.Primary
iconGlow.ImageTransparency = 1
iconGlow.ZIndex = 0

spawn(function()
    wait(0.5)
    tween(iconBtn, {Size = UDim2.new(0, 65, 0, 65), ImageTransparency = 0}, 0.8, Enum.EasingStyle.Back)
    wait(0.3)
    tween(iconGlow, {ImageTransparency = 0.5}, 0.5)
    
    while iconBtn and iconBtn.Parent do
        tween(iconGlow, {ImageTransparency = 0.3, Size = UDim2.new(1, 30, 1, 30)}, 1, Enum.EasingStyle.Sine)
        wait(1)
        tween(iconGlow, {ImageTransparency = 0.7, Size = UDim2.new(1, 20, 1, 20)}, 1, Enum.EasingStyle.Sine)
        wait(1)
    end
end)

-- ===== MAIN FRAME =====
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 480, 0, 340)
mainFrame.Position = UDim2.new(0.5, -240, 0.5, -170)
mainFrame.BackgroundColor3 = COLORS.Background
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.ZIndex = 5

createCorner(mainFrame, 16)
createStroke(mainFrame, COLORS.Primary, 3, 0)

local bgPattern = Instance.new("Frame", mainFrame)
bgPattern.Size = UDim2.new(1, 0, 1, 0)
bgPattern.BackgroundTransparency = 0.97
bgPattern.BackgroundColor3 = COLORS.Primary
bgPattern.BorderSizePixel = 0
bgPattern.ZIndex = 5
createCorner(bgPattern, 16)

-- Header
local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = COLORS.Primary
header.BorderSizePixel = 0
header.ZIndex = 6

createCorner(header, 16)
createGradient(header, ColorSequence.new{
    ColorSequenceKeypoint.new(0, COLORS.Accent),
    ColorSequenceKeypoint.new(1, COLORS.Secondary)
}, 90)

local headerLogo = Instance.new("ImageLabel", header)
headerLogo.Size = UDim2.new(0, 35, 0, 35)
headerLogo.Position = UDim2.new(0, 10, 0.5, -17.5)
headerLogo.BackgroundTransparency = 1
headerLogo.Image = "rbxassetid://109911941749492"
headerLogo.ZIndex = 7

local headerTitle = Instance.new("TextLabel", header)
headerTitle.Size = UDim2.new(0, 150, 0, 22)
headerTitle.Position = UDim2.new(0, 52, 0, 6)
headerTitle.BackgroundTransparency = 1
headerTitle.Text = "L/LOPES HUB"
headerTitle.TextColor3 = COLORS.Text
headerTitle.Font = Enum.Font.GothamBold
headerTitle.TextSize = 19
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.ZIndex = 7

local headerSubtitle = Instance.new("TextLabel", header)
headerSubtitle.Size = UDim2.new(0, 150, 0, 16)
headerSubtitle.Position = UDim2.new(0, 52, 0, 28)
headerSubtitle.BackgroundTransparency = 1
headerSubtitle.Text = "Dark Blue • v1.0"
headerSubtitle.TextColor3 = Color3.fromRGB(200, 220, 255)
headerSubtitle.Font = Enum.Font.Gotham
headerSubtitle.TextSize = 10
headerSubtitle.TextXAlignment = Enum.TextXAlignment.Left
headerSubtitle.ZIndex = 7

-- MINIMIZE BUTTON
local minimizeBtn = Instance.new("ImageButton", header)
minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
minimizeBtn.Position = UDim2.new(1, -82, 0.5, -17.5)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Image = "rbxassetid://122847348583955"
minimizeBtn.ScaleType = Enum.ScaleType.Fit
minimizeBtn.BorderSizePixel = 0
minimizeBtn.AutoButtonColor = false
minimizeBtn.ZIndex = 8

-- CLOSE BUTTON
local closeBtn = Instance.new("ImageButton", header)
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -42, 0.5, -17.5)
closeBtn.BackgroundTransparency = 1
closeBtn.Image = "rbxassetid://122618517713798"
closeBtn.ScaleType = Enum.ScaleType.Fit
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 9

-- Tab Container
local tabContainer = Instance.new("Frame", mainFrame)
tabContainer.Size = UDim2.new(0, 100, 0, 195)
tabContainer.Position = UDim2.new(0, 8, 0, 58)
tabContainer.BackgroundColor3 = COLORS.SecondaryBG
tabContainer.BorderSizePixel = 0
tabContainer.ZIndex = 6
createCorner(tabContainer, 12)
createStroke(tabContainer, COLORS.Primary, 2, 0.5)

-- Player Avatar Card
local avatarCard = Instance.new("Frame", mainFrame)
avatarCard.Size = UDim2.new(0, 100, 0, 64)
avatarCard.Position = UDim2.new(0, 8, 0, 261)
avatarCard.BackgroundColor3 = COLORS.SecondaryBG
avatarCard.BorderSizePixel = 0
avatarCard.ZIndex = 6
createCorner(avatarCard, 12)
createStroke(avatarCard, COLORS.Primary, 2, 0.5)

local avatarIcon = Instance.new("ImageLabel", avatarCard)
avatarIcon.Size = UDim2.new(0, 36, 0, 36)
avatarIcon.Position = UDim2.new(0.5, -18, 0, 5)
avatarIcon.BackgroundColor3 = COLORS.Frame
avatarIcon.BorderSizePixel = 0
avatarIcon.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. plr.UserId .. "&width=150&height=150&format=png"
avatarIcon.ZIndex = 7
createCorner(avatarIcon, 18)
createStroke(avatarIcon, COLORS.Primary, 2, 0)

local avatarName = Instance.new("TextLabel", avatarCard)
avatarName.Size = UDim2.new(1, -6, 0, 16)
avatarName.Position = UDim2.new(0, 3, 0, 44)
avatarName.BackgroundTransparency = 1
avatarName.Text = plr.Name
avatarName.TextColor3 = COLORS.Text
avatarName.Font = Enum.Font.GothamBold
avatarName.TextSize = 9
avatarName.TextScaled = true
avatarName.TextWrapped = true
avatarName.ZIndex = 7

-- Content Frame
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(0, 362, 0, 267)
contentFrame.Position = UDim2.new(0, 113, 0, 58)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.ZIndex = 6

-- ===== TAB SYSTEM =====
local tabs = {
    {name = "Main", icon = "rbxassetid://140173604192563"},
    {name = "Movement", icon = "rbxassetid://83519504381634"},
    {name = "ESP", icon = "rbxassetid://109173210610119"},
    {name = "Visual", icon = "rbxassetid://134596882934842"},
    {name = "FPS Boost", icon = "rbxassetid://72363433960406"},
    {name = "Settings", icon = "rbxassetid://124083756981755"},
}

local tabButtons = {}

local function createTab(data, index)
    local btn = Instance.new("TextButton", tabContainer)
    btn.Size = UDim2.new(1, -8, 0, 27)
    btn.Position = UDim2.new(0, 4, 0, 4 + (index * 31))
    btn.Text = ""
    btn.BackgroundColor3 = COLORS.Frame
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.ZIndex = 7
    
    createCorner(btn, 8)
    
    local iconImg = Instance.new("ImageLabel", btn)
    iconImg.Size = UDim2.new(0, 15, 0, 15)
    iconImg.Position = UDim2.new(0, 6, 0.5, -7.5)
    iconImg.BackgroundTransparency = 1
    iconImg.Image = data.icon
    iconImg.ScaleType = Enum.ScaleType.Fit
    iconImg.ZIndex = 8
    
    local textLabel = Instance.new("TextLabel", btn)
    textLabel.Size = UDim2.new(1, -26, 1, 0)
    textLabel.Position = UDim2.new(0, 24, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = data.name
    textLabel.TextColor3 = COLORS.TextDim
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 10
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.ZIndex = 8
    
    tabButtons[data.name] = {button = btn, icon = iconImg, label = textLabel}
    
    btn.MouseButton1Click:Connect(function()
        currentTab = data.name
        for tabName, tabData in pairs(tabButtons) do
            if tabName == data.name then
                tween(tabData.button, {BackgroundColor3 = COLORS.Primary}, 0.2)
                tween(tabData.label, {TextColor3 = COLORS.Text}, 0.2)
                tween(tabData.icon, {ImageColor3 = COLORS.Text}, 0.2)
            else
                tween(tabData.button, {BackgroundColor3 = COLORS.Frame}, 0.2)
                tween(tabData.label, {TextColor3 = COLORS.TextDim}, 0.2)
                tween(tabData.icon, {ImageColor3 = COLORS.TextDim}, 0.2)
            end
        end
        
        for _, child in pairs(contentFrame:GetChildren()) do
            if child:IsA("ScrollingFrame") then
                child.Visible = false
            end
        end
        
        local targetFrame = contentFrame:FindFirstChild(data.name .. "Content")
        if targetFrame then targetFrame.Visible = true end
    end)
    
    return btn
end

for i, data in ipairs(tabs) do
    createTab(data, i - 1)
end

-- ===== UI COMPONENTS =====
local function createToggle(parent, text, key, posY, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -12, 0, 30)
    container.Position = UDim2.new(0, 6, 0, posY)
    container.BackgroundColor3 = COLORS.Frame
    container.BorderSizePixel = 0
    container.ZIndex = 7
    createCorner(container, 8)
    createStroke(container, COLORS.Primary, 1, 0.7)
    
    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(0, 240, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = COLORS.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 8
    
    local toggle = Instance.new("TextButton", container)
    toggle.Size = UDim2.new(0, 44, 0, 22)
    toggle.Position = UDim2.new(1, -48, 0.5, -11)
    toggle.BackgroundColor3 = COLORS.SecondaryBG
    toggle.Text = ""
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false
    toggle.ZIndex = 8
    createCorner(toggle, 11)
    
    local indicator = Instance.new("Frame", toggle)
    indicator.Size = UDim2.new(0, 18, 0, 18)
    indicator.Position = UDim2.new(0, 2, 0.5, -9)
    indicator.BackgroundColor3 = COLORS.TextDim
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 9
    createCorner(indicator, 9)
    
    local debounce = false
    toggle.MouseButton1Click:Connect(function()
        if debounce then return end
        debounce = true
        
        CONFIG[key] = not CONFIG[key]
        
        if CONFIG[key] then
            tween(indicator, {Position = UDim2.new(1, -20, 0.5, -9), BackgroundColor3 = COLORS.Text}, 0.2)
            tween(toggle, {BackgroundColor3 = COLORS.Primary}, 0.2)
        else
            tween(indicator, {Position = UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = COLORS.TextDim}, 0.2)
            tween(toggle, {BackgroundColor3 = COLORS.SecondaryBG}, 0.2)
        end
        
        if callback then callback(CONFIG[key]) end
        
        wait(0.3)
        debounce = false
    end)
    
    return container
end

local function createSlider(parent, text, key, min, max, posY, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -12, 0, 50)
    container.Position = UDim2.new(0, 6, 0, posY)
    container.BackgroundColor3 = COLORS.Frame
    container.BorderSizePixel = 0
    container.ZIndex = 7
    createCorner(container, 8)
    createStroke(container, COLORS.Primary, 1, 0.7)
    
    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, -12, 0, 18)
    label.Position = UDim2.new(0, 6, 0, 3)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. CONFIG[key]
    label.TextColor3 = COLORS.Text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 8
    
    local sliderBg = Instance.new("Frame", container)
    sliderBg.Size = UDim2.new(1, -12, 0, 9)
    sliderBg.Position = UDim2.new(0, 6, 0, 35)
    sliderBg.BackgroundColor3 = COLORS.SecondaryBG
    sliderBg.BorderSizePixel = 0
    sliderBg.ZIndex = 8
    createCorner(sliderBg, 4.5)
    
    local sliderFill = Instance.new("Frame", sliderBg)
    local percentage = (CONFIG[key] - min) / (max - min)
    sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    sliderFill.BackgroundColor3 = COLORS.Primary
    sliderFill.BorderSizePixel = 0
    sliderFill.ZIndex = 9
    createCorner(sliderFill, 4.5)
    
    local knob = Instance.new("Frame", sliderBg)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(percentage, -8, 0.5, -8)
    knob.BackgroundColor3 = COLORS.Text
    knob.BorderSizePixel = 0
    knob.ZIndex = 10
    createCorner(knob, 8)
    createStroke(knob, COLORS.Primary, 2, 0)
    
    local dragging = false
    
    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos)
        
        CONFIG[key] = value
        label.Text = text .. ": " .. value
        
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -8, 0.5, -8)
        
        if callback then callback(value) end
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    uis.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    return container
end

local function createButton(parent, text, posY, color, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -12, 0, 34)
    btn.Position = UDim2.new(0, 6, 0, posY)
    btn.Text = text
    btn.BackgroundColor3 = color or COLORS.Primary
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.ZIndex = 7
    createCorner(btn, 8)
    createGradient(btn, ColorSequence.new{
        ColorSequenceKeypoint.new(0, color or COLORS.Accent),
        ColorSequenceKeypoint.new(1, color or COLORS.Primary)
    }, 90)
    
    local debounce = false
    btn.MouseButton1Click:Connect(function()
        if debounce then return end
        debounce = true
        
        tween(btn, {Size = UDim2.new(1, -16, 0, 32)}, 0.1)
        wait(0.1)
        tween(btn, {Size = UDim2.new(1, -12, 0, 34)}, 0.1)
        if callback then callback() end
        
        wait(0.2)
        debounce = false
    end)
    
    return btn
end

-- ===== CREATE CONTENT FRAMES =====
for _, data in ipairs(tabs) do
    local content = Instance.new("ScrollingFrame", contentFrame)
    content.Name = data.name .. "Content"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = COLORS.Primary
    content.Visible = (data.name == "Main")
    content.CanvasSize = UDim2.new(0, 0, 0, 700)
    content.ZIndex = 6
end

-- ===== MAIN TAB =====
local mainContent = contentFrame:FindFirstChild("MainContent")
createToggle(mainContent, "King Mode", "KingMode", 6)
createToggle(mainContent, "Infinite Health", "InfiniteHealth", 42)
createToggle(mainContent, "Anti-AFK", "AntiAFK", 78)
createToggle(mainContent, "Remove Kill Bricks", "RemoveKillBricks", 114)

-- PELIMEN BRANDING
local pelimenBrand = Instance.new("Frame", mainContent)
pelimenBrand.Size = UDim2.new(1, -12, 0, 70)
pelimenBrand.Position = UDim2.new(0, 6, 0, 155)
pelimenBrand.BackgroundColor3 = COLORS.Frame
pelimenBrand.BorderSizePixel = 0
pelimenBrand.ZIndex = 7
createCorner(pelimenBrand, 8)
createStroke(pelimenBrand, COLORS.Primary, 1, 0.7)

local pelimenLogo = Instance.new("ImageLabel", pelimenBrand)
pelimenLogo.Size = UDim2.new(0, 50, 0, 50)
pelimenLogo.Position = UDim2.new(0, 10, 0.5, -25)
pelimenLogo.BackgroundTransparency = 1
pelimenLogo.Image = "rbxassetid://109911941749492"
pelimenLogo.ZIndex = 8

local pelimenText = Instance.new("TextLabel", pelimenBrand)
pelimenText.Size = UDim2.new(1, -70, 0, 28)
pelimenText.Position = UDim2.new(0, 65, 0, 8)
pelimenText.BackgroundTransparency = 1
pelimenText.Text = "PELIMEN"
pelimenText.TextColor3 = COLORS.Accent
pelimenText.Font = Enum.Font.GothamBold
pelimenText.TextSize = 24
pelimenText.TextXAlignment = Enum.TextXAlignment.Left
pelimenText.ZIndex = 8

local pelimenSubtext = Instance.new("TextLabel", pelimenBrand)
pelimenSubtext.Size = UDim2.new(1, -70, 0, 30)
pelimenSubtext.Position = UDim2.new(0, 65, 0, 36)
pelimenSubtext.BackgroundTransparency = 1
pelimenSubtext.Text = "Premium Scripts\nMade with passion"
pelimenSubtext.TextColor3 = COLORS.TextDim
pelimenSubtext.Font = Enum.Font.Gotham
pelimenSubtext.TextSize = 10
pelimenSubtext.TextXAlignment = Enum.TextXAlignment.Left
pelimenSubtext.TextYAlignment = Enum.TextYAlignment.Top
pelimenSubtext.ZIndex = 8

-- ===== MOVEMENT TAB =====
local movementContent = contentFrame:FindFirstChild("MovementContent")

createToggle(movementContent, "Super Jump", "SuperJump", 6, function(enabled)
    if not enabled then
        if plr.Character then
            local hum = plr.Character:FindFirstChildWhichIsA("Humanoid")
            if hum then hum.JumpPower = originalJumpPower end
        end
    end
end)

createToggle(movementContent, "NoClip", "NoClip", 42)

-- ===== FLY CHECKPOINT MENU =====
local flyCheckpointMenu = Instance.new("Frame", gui)
flyCheckpointMenu.Name = "FlyCheckpointMenu"
flyCheckpointMenu.Size = UDim2.new(0, 240, 0, 140)
flyCheckpointMenu.Position = UDim2.new(0.5, -120, 0.5, -70)
flyCheckpointMenu.BackgroundColor3 = COLORS.Background
flyCheckpointMenu.BorderSizePixel = 0
flyCheckpointMenu.Visible = false
flyCheckpointMenu.Active = true
flyCheckpointMenu.Draggable = true
flyCheckpointMenu.ZIndex = 50
createCorner(flyCheckpointMenu, 12)
createStroke(flyCheckpointMenu, COLORS.Primary, 3, 0)

local flyMenuHeader = Instance.new("Frame", flyCheckpointMenu)
flyMenuHeader.Size = UDim2.new(1, 0, 0, 35)
flyMenuHeader.BackgroundColor3 = COLORS.Primary
flyMenuHeader.BorderSizePixel = 0
flyMenuHeader.ZIndex = 51
createCorner(flyMenuHeader, 12)
createGradient(flyMenuHeader, ColorSequence.new{
    ColorSequenceKeypoint.new(0, COLORS.Accent),
    ColorSequenceKeypoint.new(1, COLORS.Secondary)
}, 90)

local flyMenuTitle = Instance.new("TextLabel", flyMenuHeader)
flyMenuTitle.Size = UDim2.new(1, -40, 1, 0)
flyMenuTitle.Position = UDim2.new(0, 10, 0, 0)
flyMenuTitle.BackgroundTransparency = 1
flyMenuTitle.Text = "Fly Checkpoint"
flyMenuTitle.TextColor3 = COLORS.Text
flyMenuTitle.Font = Enum.Font.GothamBold
flyMenuTitle.TextSize = 13
flyMenuTitle.TextXAlignment = Enum.TextXAlignment.Left
flyMenuTitle.ZIndex = 52

local flyMenuClose = Instance.new("ImageButton", flyMenuHeader)
flyMenuClose.Size = UDim2.new(0, 28, 0, 28)
flyMenuClose.Position = UDim2.new(1, -32, 0.5, -14)
flyMenuClose.BackgroundTransparency = 1
flyMenuClose.Image = "rbxassetid://122618517713798"
flyMenuClose.ScaleType = Enum.ScaleType.Fit
flyMenuClose.BorderSizePixel = 0
flyMenuClose.AutoButtonColor = false
flyMenuClose.ZIndex = 52

local flyMenuInfo = Instance.new("TextLabel", flyCheckpointMenu)
flyMenuInfo.Size = UDim2.new(1, -16, 0, 28)
flyMenuInfo.Position = UDim2.new(0, 8, 0, 42)
flyMenuInfo.BackgroundTransparency = 1
flyMenuInfo.Text = "Save position & fly back!\nLaunches 1m up, then flies."
flyMenuInfo.TextColor3 = COLORS.TextDim
flyMenuInfo.Font = Enum.Font.Gotham
flyMenuInfo.TextSize = 10
flyMenuInfo.TextWrapped = true
flyMenuInfo.TextYAlignment = Enum.TextYAlignment.Top
flyMenuInfo.ZIndex = 51

local flyCheckStatus = Instance.new("TextLabel", flyCheckpointMenu)
flyCheckStatus.Size = UDim2.new(1, -16, 0, 20)
flyCheckStatus.Position = UDim2.new(0, 8, 0, 78)
flyCheckStatus.BackgroundTransparency = 1
flyCheckStatus.Text = "No checkpoint set"
flyCheckStatus.TextColor3 = COLORS.Error
flyCheckStatus.Font = Enum.Font.GothamBold
flyCheckStatus.TextSize = 11
flyCheckStatus.ZIndex = 51

local flyMarkBtn = Instance.new("TextButton", flyCheckpointMenu)
flyMarkBtn.Size = UDim2.new(0, 106, 0, 32)
flyMarkBtn.Position = UDim2.new(0, 8, 0, 102)
flyMarkBtn.Text = "Save"
flyMarkBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
flyMarkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyMarkBtn.Font = Enum.Font.GothamBold
flyMarkBtn.TextSize = 11
flyMarkBtn.BorderSizePixel = 0
flyMarkBtn.AutoButtonColor = false
flyMarkBtn.ZIndex = 51
createCorner(flyMarkBtn, 8)

local flyTeleportBtn = Instance.new("TextButton", flyCheckpointMenu)
flyTeleportBtn.Size = UDim2.new(0, 106, 0, 32)
flyTeleportBtn.Position = UDim2.new(0, 126, 0, 102)
flyTeleportBtn.Text = "Fly"
flyTeleportBtn.BackgroundColor3 = COLORS.Primary
flyTeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyTeleportBtn.Font = Enum.Font.GothamBold
flyTeleportBtn.TextSize = 11
flyTeleportBtn.BorderSizePixel = 0
flyTeleportBtn.AutoButtonColor = false
flyTeleportBtn.ZIndex = 51
createCorner(flyTeleportBtn, 8)
createGradient(flyTeleportBtn, ColorSequence.new{
    ColorSequenceKeypoint.new(0, COLORS.Accent),
    ColorSequenceKeypoint.new(1, COLORS.Primary)
}, 90)

flyMenuClose.MouseButton1Click:Connect(function()
    tween(flyCheckpointMenu, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
    wait(0.3)
    flyCheckpointMenu.Visible = false
    flyCheckpointMenu.Size = UDim2.new(0, 240, 0, 140)
    flyCheckpointMenu.Position = UDim2.new(0.5, -120, 0.5, -70)
    CONFIG.FlyMode = false
end)

flyMarkBtn.MouseButton1Click:Connect(function()
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        flyCheckpoint = plr.Character.HumanoidRootPart.Position
        flyCheckpointSet = true
        flyCheckStatus.Text = "Checkpoint saved!"
        flyCheckStatus.TextColor3 = COLORS.Success
        notify("Checkpoint", "Position saved!", 3)
        tween(flyMarkBtn, {Size = UDim2.new(0, 104, 0, 30)}, 0.1)
        wait(0.1)
        tween(flyMarkBtn, {Size = UDim2.new(0, 106, 0, 32)}, 0.1)
    end
end)

local flying = false
local flyBodyGyro, flyBodyVel
local returningToCheckpoint = false

flyTeleportBtn.MouseButton1Click:Connect(function()
    if not flyCheckpointSet or not flyCheckpoint then
        notify("Error", "No checkpoint set!", 2)
        return
    end
    
    if not CONFIG.FlyMode then
        notify("Error", "Enable Fly Mode first!", 2)
        return
    end
    
    local char = plr.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if flying and returningToCheckpoint then
        returningToCheckpoint = false
        flying = false
        if flyBodyGyro then flyBodyGyro:Destroy() end
        if flyBodyVel then flyBodyVel:Destroy() end
        notify("Stopped", "Flight cancelled!", 2)
        return
    end
    
    flying = true
    returningToCheckpoint = true
    
    local liftHeight = 3
    
    flyBodyGyro = Instance.new("BodyGyro", hrp)
    flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.P = 9e4
    
    flyBodyVel = Instance.new("BodyVelocity", hrp)
    flyBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBodyVel.Velocity = Vector3.new(0, 0, 0)
    
    notify("Flying", "Lifting and flying to checkpoint...", 2)
    
    spawn(function()
        local hasLifted = false
        local currentHeight = hrp.Position.Y
        local targetLiftHeight = currentHeight + liftHeight
        
        while returningToCheckpoint and flying and CONFIG.FlyMode do
            if not hrp or not hrp.Parent then break end
            
            if not hasLifted then
                if hrp.Position.Y < targetLiftHeight then
                    flyBodyVel.Velocity = Vector3.new(0, 30, 0)
                    flyBodyGyro.CFrame = hrp.CFrame
                else
                    hasLifted = true
                end
            else
                local horizontalTarget = Vector3.new(flyCheckpoint.X, hrp.Position.Y, flyCheckpoint.Z)
                local direction = (horizontalTarget - hrp.Position).Unit
                local distance = (horizontalTarget - hrp.Position).Magnitude
                
                if distance < 3 then
                    returningToCheckpoint = false
                    flying = false
                    
                    notify("Landing", "Descending...", 1)
                    
                    local groundY = flyCheckpoint.Y
                    while hrp.Position.Y > groundY + 1 do
                        if not hrp or not hrp.Parent then break end
                        flyBodyVel.Velocity = Vector3.new(0, -50, 0)
                        task.wait()
                    end
                    
                    if flyBodyVel then flyBodyVel.Velocity = Vector3.new(0, 0, 0) end
                    wait(0.1)
                    
                    if flyBodyGyro then flyBodyGyro:Destroy() end
                    if flyBodyVel then flyBodyVel:Destroy() end
                    
                    notify("Arrived", "Reached checkpoint!", 2)
                    break
                end
                
                flyBodyVel.Velocity = direction * (CONFIG.FlySpeed * 50)
                flyBodyGyro.CFrame = CFrame.new(hrp.Position, horizontalTarget)
            end
            
            task.wait()
        end
        
        if flyBodyGyro then flyBodyGyro:Destroy() end
        if flyBodyVel then flyBodyVel:Destroy() end
        returningToCheckpoint = false
        flying = false
    end)
    
    tween(flyTeleportBtn, {Size = UDim2.new(0, 104, 0, 30)}, 0.1)
    wait(0.1)
    tween(flyTeleportBtn, {Size = UDim2.new(0, 106, 0, 32)}, 0.1)
end)

createToggle(movementContent, "Fly Mode", "FlyMode", 78, function(enabled)
    if enabled then
        flyCheckpointMenu.Size = UDim2.new(0, 0, 0, 0)
        flyCheckpointMenu.Position = UDim2.new(0.5, 0, 0.5, 0)
        flyCheckpointMenu.Visible = true
        tween(flyCheckpointMenu, {Size = UDim2.new(0, 240, 0, 140), Position = UDim2.new(0.5, -120, 0.5, -70)}, 0.4, Enum.EasingStyle.Back)
    else
        flying = false
        returningToCheckpoint = false
        if flyBodyGyro then flyBodyGyro:Destroy() end
        if flyBodyVel then flyBodyVel:Destroy() end
        tween(flyCheckpointMenu, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
        wait(0.3)
        flyCheckpointMenu.Visible = false
        flyCheckpointMenu.Size = UDim2.new(0, 240, 0, 140)
        flyCheckpointMenu.Position = UDim2.new(0.5, -120, 0.5, -70)
    end
end)

createToggle(movementContent, "Speed Boost", "SpeedBoost", 114, function(enabled)
    if not enabled then
        if plr.Character then
            local hum = plr.Character:FindFirstChildWhichIsA("Humanoid")
            if hum then hum.WalkSpeed = originalWalkSpeed end
        end
    end
end)

-- ===== PLATFORM BUILDER MENU =====
local platformMenu = Instance.new("Frame", gui)
platformMenu.Name = "PlatformMenu"
platformMenu.Size = UDim2.new(0, 240, 0, 160)
platformMenu.Position = UDim2.new(0.5, -120, 0.5, -80)
platformMenu.BackgroundColor3 = COLORS.Background
platformMenu.BorderSizePixel = 0
platformMenu.Visible = false
platformMenu.Active = true
platformMenu.Draggable = true
platformMenu.ZIndex = 50
createCorner(platformMenu, 12)
createStroke(platformMenu, COLORS.Primary, 3, 0)

local platformHeader = Instance.new("Frame", platformMenu)
platformHeader.Size = UDim2.new(1, 0, 0, 35)
platformHeader.BackgroundColor3 = COLORS.Primary
platformHeader.BorderSizePixel = 0
platformHeader.ZIndex = 51
createCorner(platformHeader, 12)
createGradient(platformHeader, ColorSequence.new{
    ColorSequenceKeypoint.new(0, COLORS.Accent),
    ColorSequenceKeypoint.new(1, COLORS.Secondary)
}, 90)

local platformTitle = Instance.new("TextLabel", platformHeader)
platformTitle.Size = UDim2.new(1, -40, 1, 0)
platformTitle.Position = UDim2.new(0, 10, 0, 0)
platformTitle.BackgroundTransparency = 1
platformTitle.Text = "Platform Builder"
platformTitle.TextColor3 = COLORS.Text
platformTitle.Font = Enum.Font.GothamBold
platformTitle.TextSize = 13
platformTitle.TextXAlignment = Enum.TextXAlignment.Left
platformTitle.ZIndex = 52

local platformClose = Instance.new("ImageButton", platformHeader)
platformClose.Size = UDim2.new(0, 28, 0, 28)
platformClose.Position = UDim2.new(1, -32, 0.5, -14)
platformClose.BackgroundTransparency = 1
platformClose.Image = "rbxassetid://122618517713798"
platformClose.ScaleType = Enum.ScaleType.Fit
platformClose.BorderSizePixel = 0
platformClose.AutoButtonColor = false
platformClose.ZIndex = 52

local platformInfo = Instance.new("TextLabel", platformMenu)
platformInfo.Size = UDim2.new(1, -16, 0, 40)
platformInfo.Position = UDim2.new(0, 8, 0, 42)
platformInfo.BackgroundTransparency = 1
platformInfo.Text = "Automatic Lift Platform!\n\nActivate to slowly rise upward.\nIcon appears below your feet."
platformInfo.TextColor3 = COLORS.TextDim
platformInfo.Font = Enum.Font.Gotham
platformInfo.TextSize = 10
platformInfo.TextWrapped = true
platformInfo.TextYAlignment = Enum.TextYAlignment.Top
platformInfo.ZIndex = 51

local platformStatus = Instance.new("TextLabel", platformMenu)
platformStatus.Size = UDim2.new(1, -16, 0, 20)
platformStatus.Position = UDim2.new(0, 8, 0, 92)
platformStatus.BackgroundTransparency = 1
platformStatus.Text = "Status: Inactive"
platformStatus.TextColor3 = COLORS.Error
platformStatus.Font = Enum.Font.GothamBold
platformStatus.TextSize = 11
platformStatus.ZIndex = 51

local platformActivateBtn = Instance.new("TextButton", platformMenu)
platformActivateBtn.Size = UDim2.new(1, -16, 0, 36)
platformActivateBtn.Position = UDim2.new(0, 8, 0, 116)
platformActivateBtn.Text = "Activate"
platformActivateBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
platformActivateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
platformActivateBtn.Font = Enum.Font.GothamBold
platformActivateBtn.TextSize = 12
platformActivateBtn.BorderSizePixel = 0
platformActivateBtn.AutoButtonColor = false
platformActivateBtn.ZIndex = 51
createCorner(platformActivateBtn, 8)

createToggle(movementContent, "Platform Builder", "PlatformBuilder", 150, function(enabled)
    if enabled then
        platformMenu.Size = UDim2.new(0, 0, 0, 0)
        platformMenu.Position = UDim2.new(0.5, 0, 0.5, 0)
        platformMenu.Visible = true
        tween(platformMenu, {Size = UDim2.new(0, 240, 0, 160), Position = UDim2.new(0.5, -120, 0.5, -80)}, 0.4, Enum.EasingStyle.Back)
    else
        CONFIG.PlatformBuilder = false
        platformActive = false
        disconnectConnection("platformBuilder")
        tween(platformMenu, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
        wait(0.3)
        platformMenu.Visible = false
        platformMenu.Size = UDim2.new(0, 240, 0, 160)
        platformMenu.Position = UDim2.new(0.5, -120, 0.5, -80)
    end
end)

platformClose.MouseButton1Click:Connect(function()
    CONFIG.PlatformBuilder = false
    platformActive = false
    disconnectConnection("platformBuilder")
    tween(platformMenu, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
    wait(0.3)
    platformMenu.Visible = false
    platformMenu.Size = UDim2.new(0, 240, 0, 160)
    platformMenu.Position = UDim2.new(0.5, -120, 0.5, -80)
end)

platformActivateBtn.MouseButton1Click:Connect(function()
    if not platformActive then
        platformActive = true
        platformStatus.Text = "Status: Active ✓"
        platformStatus.TextColor3 = COLORS.Success
        platformActivateBtn.Text = "Deactivate"
        platformActivateBtn.BackgroundColor3 = COLORS.Error
        notify("Platform Builder", "Activated! Rising slowly...", 2)
        
        tween(platformActivateBtn, {Size = UDim2.new(1, -18, 0, 34)}, 0.1)
        wait(0.1)
        tween(platformActivateBtn, {Size = UDim2.new(1, -16, 0, 36)}, 0.1)
        
        -- PLATFORM BUILDER LOGIC
        local platform = nil
        
        connections.platformBuilder = run.Heartbeat:Connect(function()
            if not platformActive or not CONFIG.PlatformBuilder then
                if platform then platform:Destroy() end
                return
            end
            
            local char = plr.Character
            if not char then return end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            -- Create Platform if doesn't exist
            if not platform or not platform.Parent then
                platform = Instance.new("Part", workspace)
                platform.Name = "67Hub_Platform"
                platform.Size = Vector3.new(6, 0.8, 6)
                platform.Position = hrp.Position - Vector3.new(0, 3.5, 0) -- ISPOD igrača
                platform.Anchored = true
                platform.CanCollide = true
                platform.Material = Enum.Material.Neon
                platform.Color = COLORS.Primary
                platform.Transparency = 0.3
                
                local mesh = Instance.new("SpecialMesh", platform)
                mesh.MeshType = Enum.MeshType.Brick
                mesh.Scale = Vector3.new(1, 1, 1)
                
                -- Add Icon Decal (NA VRHU platforme)
                local decal = Instance.new("Decal", platform)
                decal.Face = Enum.NormalId.Top
                decal.Texture = "rbxassetid://109911941749492"
                decal.Color3 = Color3.fromRGB(255, 255, 255)
                
                local light = Instance.new("PointLight", platform)
                light.Color = COLORS.Primary
                light.Brightness = 2
                light.Range = 15
            end
            
            -- PODIŽE PLATFORMU (i igrača na njoj) polako
            platform.CFrame = platform.CFrame + Vector3.new(0, platformSpeed / 60, 0)
            
            -- Prati igrača horizontalno (X i Z osa)
            local currentY = platform.Position.Y
            platform.Position = Vector3.new(hrp.Position.X, currentY, hrp.Position.Z)
        end)
        
    else
        platformActive = false
        platformStatus.Text = "Status: Inactive"
        platformStatus.TextColor3 = COLORS.Error
        platformActivateBtn.Text = "Activate"
        platformActivateBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        notify("Platform Builder", "Deactivated!", 2)
        
        disconnectConnection("platformBuilder")
        
        -- Remove platform
        for _, obj in pairs(workspace:GetChildren()) do
            if obj.Name == "67Hub_Platform" then
                obj:Destroy()
            end
        end
        
        tween(platformActivateBtn, {Size = UDim2.new(1, -18, 0, 34)}, 0.1)
        wait(0.1)
        tween(platformActivateBtn, {Size = UDim2.new(1, -16, 0, 36)}, 0.1)
    end
end)

createSlider(movementContent, "Walk Speed", "WalkSpeed", 16, 200, 196)
createSlider(movementContent, "Jump Power", "JumpPower", 50, 300, 254)
createSlider(movementContent, "Platform Height Offset", "PlatformHeight", 0, 10, 312)

-- ===== ESP TAB =====
local espContent = contentFrame:FindFirstChild("ESPContent")

local function clearESP(player)
    if espCache[player] then
        for _, obj in pairs(espCache[player]) do
            pcall(function()
                if obj and obj.Parent then obj:Destroy() end
            end)
        end
        espCache[player] = nil
    end
    
    disconnectConnection("esp_" .. player.Name)
end

local function createESP(player)
    if player == plr then return end
    if not CONFIG.ESPBoxes then return end
    
    local char = player.Character
    if not char then return end
    
    pcall(function()
        clearESP(player)
        espCache[player] = {}
        
        if CONFIG.ESPBoxes then
            local highlight = Instance.new("Highlight", char)
            highlight.Name = "67Hub_ESP_Highlight"
            highlight.FillColor = COLORS.Primary
            highlight.OutlineColor = COLORS.Text
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            table.insert(espCache[player], highlight)
            
            for _, obj in pairs(char:GetChildren()) do
                if obj:IsA("BasePart") then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Name = "67Hub_ESP_Box"
                    box.Adornee = obj
                    box.Size = obj.Size
                    box.Color3 = COLORS.Primary
                    box.Transparency = 0.7
                    box.ZIndex = 1
                    box.AlwaysOnTop = true
                    box.Parent = obj
                    table.insert(espCache[player], box)
                end
            end
        end
        
        if CONFIG.ESPBoxes and (CONFIG.ESPNames or CONFIG.ESPDistance) then
            local head = char:FindFirstChild("Head")
            if head then
                local bill = Instance.new("BillboardGui", char)
                bill.Name = "67Hub_ESP_Billboard"
                bill.Adornee = head
                bill.Size = UDim2.new(0, 200, 0, 60)
                bill.StudsOffset = Vector3.new(0, 2, 0)
                bill.AlwaysOnTop = true
                
                local nameLabel = Instance.new("TextLabel", bill)
                nameLabel.Name = "NameLabel"
                nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                nameLabel.Position = UDim2.new(0, 0, 0, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = player.Name
                nameLabel.TextColor3 = COLORS.Primary
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextSize = 16
                nameLabel.TextStrokeTransparency = 0.5
                nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                nameLabel.Visible = CONFIG.ESPNames
                
                local distLabel = Instance.new("TextLabel", bill)
                distLabel.Name = "DistLabel"
                distLabel.Size = UDim2.new(1, 0, 0.5, 0)
                distLabel.Position = UDim2.new(0, 0, 0.5, 0)
                distLabel.BackgroundTransparency = 1
                distLabel.Text = ""
                distLabel.TextColor3 = COLORS.Green
                distLabel.Font = Enum.Font.GothamBold
                distLabel.TextSize = 14
                distLabel.TextStrokeTransparency = 0.5
                distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                distLabel.Visible = CONFIG.ESPDistance
                
                table.insert(espCache[player], bill)
                
                local lastDistUpdate = tick()
                connections["esp_" .. player.Name] = run.Heartbeat:Connect(function()
                    pcall(function()
                        if not bill or not bill.Parent then return end
                        if not CONFIG.ESPBoxes then 
                            clearESP(player)
                            return 
                        end
                        
                        nameLabel.Visible = CONFIG.ESPNames
                        distLabel.Visible = CONFIG.ESPDistance
                        
                        if CONFIG.ESPDistance and tick() - lastDistUpdate >= 0.1 then
                            if plr.Character then
                                local myHRP = plr.Character:FindFirstChild("HumanoidRootPart")
                                local theirHRP = char:FindFirstChild("HumanoidRootPart")
                                if myHRP and theirHRP then
                                    local dist = (myHRP.Position - theirHRP.Position).Magnitude
                                    distLabel.Text = "[" .. math.floor(dist) .. " studs]"
                                end
                            end
                            lastDistUpdate = tick()
                        end
                    end)
                end)
            end
        end
        
        if CONFIG.ESPBoxes and CONFIG.Tracers then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and plr.Character then
                local myHRP = plr.Character:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    local attach1 = Instance.new("Attachment", hrp)
                    attach1.Name = "67Hub_Tracer"
                    
                    local attach2 = Instance.new("Attachment", myHRP)
                    attach2.Name = "67Hub_TracerOrigin"
                    
                    local beam = Instance.new("Beam", attach1)
                    beam.Attachment0 = attach1
                    beam.Attachment1 = attach2
                    beam.Color = ColorSequence.new(COLORS.Primary)
                    beam.FaceCamera = true
                    beam.Width0 = 0.15
                    beam.Width1 = 0.15
                    
                    table.insert(espCache[player], attach1)
                    table.insert(espCache[player], attach2)
                    table.insert(espCache[player], beam)
                end
            end
        end
    end)
end

function updateAllESP()
    for player, _ in pairs(espCache) do
        clearESP(player)
    end
    
    if CONFIG.ESPBoxes then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= plr and player.Character then
                task.spawn(function()
                    createESP(player)
                end)
            end
        end
    end
end

createToggle(espContent, "ESP Boxes (Highlight + Boxes)", "ESPBoxes", 6, function(enabled)
    if enabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= plr and player.Character then
                task.spawn(function()
                    createESP(player)
                end)
            end
        end
    else
        for player, _ in pairs(espCache) do
            clearESP(player)
        end
        espCache = {}
    end
end)

createToggle(espContent, "Show Names (Red)", "ESPNames", 42, function(enabled)
    if CONFIG.ESPBoxes then 
        updateAllESP() 
    end
end)

createToggle(espContent, "Show Distance (Green)", "ESPDistance", 78, function(enabled)
    if CONFIG.ESPBoxes then 
        updateAllESP() 
    end
end)

createToggle(espContent, "Tracers", "Tracers", 114, function(enabled)
    if CONFIG.ESPBoxes then 
        updateAllESP() 
    end
end)

-- ===== VISUAL TAB =====
local visualContent = contentFrame:FindFirstChild("VisualContent")
createToggle(visualContent, "Fullbright", "Fullbright", 6)
createToggle(visualContent, "Remove Fog", "RemoveFog", 42)
createToggle(visualContent, "Infinite Zoom", "InfiniteZoom", 78)
createToggle(visualContent, "Free Cam", "FreeCam", 114)

createSlider(visualContent, "Field of View", "FOV", 70, 120, 160, function(value)
    workspace.CurrentCamera.FieldOfView = value
end)

-- ===== FPS BOOST TAB =====
local fpsContent = contentFrame:FindFirstChild("FPS BoostContent")

createToggle(fpsContent, "FPS Boost (Remove Effects)", "FPSBoost", 6, function(enabled)
    local lighting = game:GetService("Lighting")
    if enabled then
        originalSettings.lighting.Brightness = lighting.Brightness
        originalSettings.lighting.GlobalShadows = lighting.GlobalShadows
        originalSettings.lighting.Technology = lighting.Technology
        
        lighting.GlobalShadows = false
        lighting.Technology = Enum.Technology.Compatibility
        
        for _, effect in pairs(lighting:GetChildren()) do
            if effect:IsA("PostEffect") then
                effect.Enabled = false
            end
        end
        
        notify("FPS Boost", "Effects removed for performance!", 2)
    else
        lighting.GlobalShadows = originalSettings.lighting.GlobalShadows or true
        lighting.Technology = originalSettings.lighting.Technology or Enum.Technology.ShadowMap
        
        for _, effect in pairs(lighting:GetChildren()) do
            if effect:IsA("PostEffect") then
                effect.Enabled = true
            end
        end
        
        notify("FPS Boost", "Effects restored!", 2)
    end
end)

createToggle(fpsContent, "Disable Particles & Smoke", "DisableParticles", 42, function(enabled)
    if enabled then
        for _, obj in pairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    obj.Enabled = false
                end
            end)
        end
        
        connections.particleDisabler = workspace.DescendantAdded:Connect(function(obj)
            if CONFIG.DisableParticles then
                pcall(function()
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                        obj.Enabled = false
                    end
                end)
            end
        end)
        
        notify("Particles", "All particles disabled!", 2)
    else
        for _, obj in pairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    obj.Enabled = true
                end
            end)
        end
        
        disconnectConnection("particleDisabler")
        notify("Particles", "Particles enabled!", 2)
    end
end)

local fpsInfoLabel = Instance.new("TextLabel", fpsContent)
fpsInfoLabel.Size = UDim2.new(1, -12, 0, 90)
fpsInfoLabel.Position = UDim2.new(0, 6, 0, 88)
fpsInfoLabel.BackgroundColor3 = COLORS.Frame
fpsInfoLabel.BorderSizePixel = 0
fpsInfoLabel.Text = [[FPS Boost Tips:

FPS Boost - Removes shadows & effects
Disable Particles - Stops all particles

Use both for maximum FPS!
Best for low-end devices.]]
fpsInfoLabel.TextColor3 = COLORS.Text
fpsInfoLabel.Font = Enum.Font.Gotham
fpsInfoLabel.TextSize = 11
fpsInfoLabel.TextWrapped = true
fpsInfoLabel.TextYAlignment = Enum.TextYAlignment.Top
fpsInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsInfoLabel.ZIndex = 7
createCorner(fpsInfoLabel, 8)
createStroke(fpsInfoLabel, COLORS.Primary, 1, 0.7)

local fpsPadding = Instance.new("UIPadding", fpsInfoLabel)
fpsPadding.PaddingLeft = UDim.new(0, 10)
fpsPadding.PaddingTop = UDim.new(0, 8)

-- ===== SETTINGS TAB =====
local settingsContent = contentFrame:FindFirstChild("SettingsContent")

local fpsLabel = Instance.new("TextLabel", settingsContent)
fpsLabel.Size = UDim2.new(1, -12, 0, 30)
fpsLabel.Position = UDim2.new(0, 6, 0, 6)
fpsLabel.BackgroundColor3 = COLORS.Frame
fpsLabel.BorderSizePixel = 0
fpsLabel.Text = "FPS: 0"
fpsLabel.TextColor3 = COLORS.Success
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 15
fpsLabel.ZIndex = 7
fpsLabel.Visible = false
createCorner(fpsLabel, 8)
createStroke(fpsLabel, COLORS.Primary, 1, 0.7)

createToggle(settingsContent, "Show FPS Counter", "ShowFPS", 42, function(enabled)
    fpsLabel.Visible = enabled
end)

createButton(settingsContent, "Respawn Character", 78, COLORS.Primary, function()
    if plr.Character then
        plr.Character:BreakJoints()
        notify("Respawning", "Character will respawn...", 2)
    end
end)

createButton(settingsContent, "Reset All Settings", 118, COLORS.Error, function()
    for key, _ in pairs(CONFIG) do
        if type(CONFIG[key]) == "boolean" then
            CONFIG[key] = false
        end
    end
    flyCheckpoint = nil
    flyCheckpointSet = false
    flyCheckStatus.Text = "No checkpoint set"
    flyCheckStatus.TextColor3 = COLORS.Error
    fpsLabel.Visible = false
    notify("Reset", "All settings reset!", 3)
end)

tween(tabButtons["Main"].button, {BackgroundColor3 = COLORS.Primary}, 0)
tween(tabButtons["Main"].label, {TextColor3 = COLORS.Text}, 0)
tween(tabButtons["Main"].icon, {ImageColor3 = COLORS.Text}, 0)

-- ===== MINIMIZE BUTTON =====
local minimizing = false
minimizeBtn.MouseButton1Click:Connect(function()
    if minimizing then return end
    minimizing = true
    
    if mainFrame.Visible then
        tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.4)
        wait(0.4)
        mainFrame.Visible = false
        mainFrame.Size = UDim2.new(0, 480, 0, 340)
        mainFrame.Position = UDim2.new(0.5, -240, 0.5, -170)
    else
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        mainFrame.Visible = true
        tween(mainFrame, {Size = UDim2.new(0, 480, 0, 340), Position = UDim2.new(0.5, -240, 0.5, -170)}, 0.5, Enum.EasingStyle.Back)
    end
    
    wait(0.5)
    minimizing = false
end)

-- ===== ICON BUTTON =====
local iconDebounce = false
iconBtn.MouseButton1Click:Connect(function()
    if iconDebounce then return end
    iconDebounce = true
    
    if mainFrame.Visible then
        tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.4)
        wait(0.4)
        mainFrame.Visible = false
        mainFrame.Size = UDim2.new(0, 480, 0, 340)
        mainFrame.Position = UDim2.new(0.5, -240, 0.5, -170)
    else
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        mainFrame.Visible = true
        tween(mainFrame, {Size = UDim2.new(0, 480, 0, 340), Position = UDim2.new(0.5, -240, 0.5, -170)}, 0.5, Enum.EasingStyle.Back)
    end
    
    wait(0.5)
    iconDebounce = false
end)

-- ===== CLOSE BUTTON =====
closeBtn.MouseButton1Click:Connect(function()
    tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.4)
    wait(0.5)
    
    if CONFIG.FPSBoost then
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = originalSettings.lighting.GlobalShadows or true
        lighting.Technology = originalSettings.lighting.Technology or Enum.Technology.ShadowMap
        for _, effect in pairs(lighting:GetChildren()) do
            if effect:IsA("PostEffect") then
                effect.Enabled = true
            end
        end
    end
    
    if CONFIG.DisableParticles then
        for _, obj in pairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    obj.Enabled = true
                end
            end)
        end
    end
    
    if CONFIG.SpeedBoost and plr.Character then
        local hum = plr.Character:FindFirstChildWhichIsA("Humanoid")
        if hum then hum.WalkSpeed = originalWalkSpeed end
    end
    
    if CONFIG.SuperJump and plr.Character then
        local hum = plr.Character:FindFirstChildWhichIsA("Humanoid")
        if hum then hum.JumpPower = originalJumpPower end
    end
    
    workspace.CurrentCamera.FieldOfView = originalFOV
    plr.CameraMaxZoomDistance = 128
    plr.CameraMinZoomDistance = 0.5
    
    for _, platform in pairs(workspace:GetChildren()) do
        if platform.Name == "67Hub_Platform" then
            platform:Destroy()
        end
    end
    
    for player, _ in pairs(espCache) do
        clearESP(player)
    end
    espCache = {}
    
    for key, conn in pairs(connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    connections = {}
    
    gui:Destroy()
    notify("Goodbye!", "67 HUB closed - All restored!", 3)
end)

-- ===== HOVER EFFECTS =====
local function addHover(button)
    button.MouseEnter:Connect(function()
        tween(button, {Size = UDim2.new(0, 37, 0, 37)}, 0.2)
    end)
    button.MouseLeave:Connect(function()
        tween(button, {Size = UDim2.new(0, 35, 0, 35)}, 0.2)
    end)
end

addHover(closeBtn)
addHover(minimizeBtn)
addHover(platformClose)
addHover(flyMenuClose)

local function addHoverBg(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        tween(button, {BackgroundColor3 = hoverColor}, 0.2)
    end)
    button.MouseLeave:Connect(function()
        tween(button, {BackgroundColor3 = normalColor}, 0.2)
    end)
end

addHoverBg(iconBtn, COLORS.Background, COLORS.SecondaryBG)
addHoverBg(platformActivateBtn, Color3.fromRGB(50, 150, 50), Color3.fromRGB(60, 180, 60))
addHoverBg(flyMarkBtn, Color3.fromRGB(50, 150, 50), Color3.fromRGB(60, 180, 60))
addHoverBg(flyTeleportBtn, COLORS.Primary, COLORS.Accent)

-- ===== FPS COUNTER =====
local lastUpdate = tick()
local frames = 0
connections.fpsCounter = run.RenderStepped:Connect(function()
    frames = frames + 1
    if tick() - lastUpdate >= 1 then
        local fps = frames
        fpsLabel.Text = "FPS: " .. fps
        
        if fps >= 60 then
            fpsLabel.TextColor3 = COLORS.Success
        elseif fps >= 30 then
            fpsLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        else
            fpsLabel.TextColor3 = COLORS.Error
        end
        
        frames = 0
        lastUpdate = tick()
    end
end)

-- ===== KING MODE & INFINITE HEALTH =====
connections.kingMode = run.Heartbeat:Connect(function()
    if not CONFIG.KingMode and not CONFIG.InfiniteHealth then return end
    
    local char = plr.Character
    if char then
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            if CONFIG.KingMode then
                hum.Health = hum.MaxHealth
                hum.MaxHealth = 999999
            end
            if CONFIG.InfiniteHealth then
                hum.Health = hum.MaxHealth
            end
        end
    end
end)

-- ===== SUPER JUMP =====
connections.superJump = uis.JumpRequest:Connect(function()
    if not CONFIG.SuperJump then return end
    
    local char = plr.Character
    if char then
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait(0.05)
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, CONFIG.JumpPower, hrp.Velocity.Z)
            end
        end
    end
end)

-- ===== NOCLIP =====
connections.noClip = run.Stepped:Connect(function()
    if not CONFIG.NoClip then return end
    
    local char = plr.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ===== SPEED BOOST =====
connections.speed = run.Heartbeat:Connect(function()
    local char = plr.Character
    if not char then return end
    
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end
    
    if CONFIG.SpeedBoost then
        hum.WalkSpeed = CONFIG.WalkSpeed
    elseif hum.WalkSpeed ~= originalWalkSpeed then
        hum.WalkSpeed = originalWalkSpeed
    end
end)

-- ===== FULLBRIGHT =====
connections.fullbright = run.Heartbeat:Connect(function()
    if not CONFIG.Fullbright then return end
    
    pcall(function()
        local lighting = game:GetService("Lighting")
        lighting.Brightness = 2
        lighting.ClockTime = 14
        lighting.FogEnd = 100000
        lighting.GlobalShadows = false
        lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end)
end)

-- ===== REMOVE FOG =====
connections.removeFog = run.Heartbeat:Connect(function()
    if not CONFIG.RemoveFog then return end
    
    pcall(function()
        local lighting = game:GetService("Lighting")
        lighting.FogEnd = 100000
    end)
end)

-- ===== ANTI-AFK =====
spawn(function()
    while task.wait(120) do
        if CONFIG.AntiAFK then
            pcall(function()
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
end)

-- ===== REMOVE KILL BRICKS =====
spawn(function()
    while task.wait(3) do
        if CONFIG.RemoveKillBricks then
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and (v.Name:lower():find("kill") or v.Name:lower():find("death") or v.Name:lower():find("lava")) then
                        v:Destroy()
                    end
                end
            end)
        end
    end
end)

-- ===== INFINITE ZOOM =====
connections.infZoom = run.Heartbeat:Connect(function()
    if CONFIG.InfiniteZoom then
        plr.CameraMaxZoomDistance = 9999
        plr.CameraMinZoomDistance = 0
    else
        plr.CameraMaxZoomDistance = 128
        plr.CameraMinZoomDistance = 0.5
    end
end)

-- ===== FREE CAM =====
local freeCamConnection
connections.freeCam = run.Heartbeat:Connect(function()
    if CONFIG.FreeCam then
        if not freeCamConnection then
            pcall(function()
                local cam = workspace.CurrentCamera
                cam.CameraType = Enum.CameraType.Fixed
            end)
        end
    else
        if freeCamConnection then
            freeCamConnection:Disconnect()
            freeCamConnection = nil
        end
        pcall(function()
            local cam = workspace.CurrentCamera
            cam.CameraType = Enum.CameraType.Custom
        end)
    end
end)

-- ===== CHARACTER ADDED =====
plr.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if char then
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            originalWalkSpeed = hum.WalkSpeed
            originalJumpPower = hum.JumpPower
        end
    end
    
    task.wait(1)
    if CONFIG.ESPBoxes then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= plr and player.Character then
                task.spawn(function()
                    createESP(player)
                end)
            end
        end
    end
end)

-- ===== PLAYER EVENTS =====
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if CONFIG.ESPBoxes then
            task.spawn(function()
                createESP(player)
            end)
        end
    end)
end)

game.Players.PlayerRemoving:Connect(function(player)
    clearESP(player)
end)

-- ===== INITIAL ESP =====
task.spawn(function()
    task.wait(2)
    if CONFIG.ESPBoxes then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= plr and player.Character then
                task.spawn(function()
                    createESP(player)
                end)
            end
        end
    end
end)

wait(0.5)
notify("67 HUB v1.0", "Dark Blue Edition Complete!", 5)

print("=== 67 HUB v1.0 - DARK BLUE COMPLETE ===")
print("✅ Platform Builder - AUTO LIFT")
print("✅ All Features Working")
print("✅ Smooth Animations")
print("✅ Fly Speed: Fixed at 1")
print("✅ PELIMEN Branding")
print("========================================")
