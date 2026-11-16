-- =============================================================================
-- SCRIPT ROBLOX XENO - ITATOOLS V3 (QUADRILLAGE EN ZIG-ZAG PARFAIT SANS FIN)
-- =============================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- État Global (_G)
local _G = getgenv and getgenv() or _G
_G.ESP_Enabled = false
_G.MM2_ESP_Enabled = false
_G.Noclip_Enabled = false
_G.Speed_Enabled = false
_G.WalkSpeedValue = 32
_G.Tourniquer_Enabled = false
_G.Tourniquer_Speed = 60
_G.Ressort_Enabled = false
_G.Run_Enabled = false
_G.Run_Speed = 2.0
_G.Shaders_Enabled = false
_G.Colle_Enabled = false
_G.Colle_Target = nil
_G.ESP_Color = Color3.fromRGB(255, 255, 255)

_G.MenuKeybind = Enum.KeyCode.RightAlt
_G.FlyKeybind = Enum.KeyCode.F
_G.ESPKeybind = Enum.KeyCode.E
_G.AimLockKeybind = Enum.KeyCode.Q
_G.ToggleLockKeybind = Enum.KeyCode.R

_G.Fly_Enabled = false
_G.Fly_Speed = 200
_G.Fly_Boost = 2.5
local flyVelocity, flyGyro = nil, nil
local flyInput = { Forward = false, Backward = false, Left = false, Right = false, Up = false, Down = false, Boost = false }

_G.AimLock_Enabled = false
_G.ToggleLock_Enabled = false
_G.TpKill_Enabled = false
local aimLockTarget = nil
local isAiming = false

local mm2Roles = {}
local currentESP = {}
local connections = {}
local bindingActionName = nil
local bindingBtnObject = nil

local spinVelocity, currentRunTrack, colleAnimTrack = nil, nil, nil
local droppedGunHighlight, droppedGunBillboard = nil, nil
local shaderEffects = {}
local moduleRegistry = {}
local globalLayoutOrderCounter = 0

-- Parent UI Sécurisé (gethui ou CoreGui ou PlayerGui fallback)
local ParentFolder = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- Nettoyage des anciens GUI
local oldGui = ParentFolder:FindFirstChild("ItatoolsV3UI")
if oldGui then oldGui:Destroy() end
local oldOverlay = ParentFolder:FindFirstChild("ItatoolsV3OverlayGui")
if oldOverlay then oldOverlay:Destroy() end

-- ScreenGui Principal (Menu)
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "ItatoolsV3UI"
MainGui.Parent = ParentFolder
MainGui.ResetOnSpawn = false
MainGui.Enabled = true
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ScreenGui Séparé pour l'Overlay
local OverlayGui = Instance.new("ScreenGui")
OverlayGui.Name = "ItatoolsV3OverlayGui"
OverlayGui.Parent = ParentFolder
OverlayGui.ResetOnSpawn = false
OverlayGui.Enabled = true
OverlayGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "ITATOOLS V3",
        Text = "Appuie sur ALT DROIT pour ouvrir / fermer le menu.",
        Duration = 4
    })
end)

-- =============================================================================
-- OVERLAY INDÉPENDANT (EN BAS À GAUCHE)
-- =============================================================================
local OverlayFrame = Instance.new("Frame")
OverlayFrame.Name = "ActiveFeaturesOverlay"
OverlayFrame.Parent = OverlayGui
OverlayFrame.BackgroundTransparency = 1
OverlayFrame.AnchorPoint = Vector2.new(0, 1)
OverlayFrame.Position = UDim2.new(0, 15, 1, -15)
OverlayFrame.Size = UDim2.new(0, 110, 0, 300)
OverlayFrame.ZIndex = 50

local UIListOverlay = Instance.new("UIListLayout")
UIListOverlay.Parent = OverlayFrame
UIListOverlay.SortOrder = Enum.SortOrder.LayoutOrder
UIListOverlay.Padding = UDim.new(0, 4)
UIListOverlay.VerticalAlignment = Enum.VerticalAlignment.Bottom

local function updateOverlay()
    for _, child in ipairs(OverlayFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local function createBox(text)
        local box = Instance.new("Frame")
        box.Size = UDim2.new(1, 0, 0, 22)
        box.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
        box.BackgroundTransparency = 0.1
        box.Parent = OverlayFrame
        box.ZIndex = 51

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = box

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(0, 210, 255)
        stroke.Thickness = 1
        stroke.Transparency = 0.15
        stroke.Parent = box

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 10
        label.Parent = box
        label.ZIndex = 52
    end

    if _G.Fly_Enabled then createBox("FLY") end
    if _G.ESP_Enabled then createBox("ESP") end
    if _G.MM2_ESP_Enabled then createBox("ESP MM2 (AUTO)") end
    if _G.AimLock_Enabled then createBox("AIMLOCK") end
    if _G.ToggleLock_Enabled then createBox("LOCK AUTO") end
    if _G.TpKill_Enabled then createBox("TP KILL") end
    if _G.Noclip_Enabled then createBox("NOCLIP") end
    if _G.Speed_Enabled then createBox("SPEED") end
    if _G.Tourniquer_Enabled then createBox("TOURNIQUER") end
    if _G.Ressort_Enabled then createBox("RESSORT") end
    if _G.Run_Enabled then createBox("RUN") end
    if _G.Colle_Enabled and _G.Colle_Target then createBox("COLLE: " .. _G.Colle_Target.Name) end
    if _G.Shaders_Enabled then createBox("SHADERS") end
    if _G.BGS_AutoBlow then createBox("AUTO BULLES") end
    if _G.BGS_AutoSell then createBox("AUTO VENTE") end
    if _G.BGS_AutoTake then createBox("AUTO TAKE") end
end

-- =============================================================================
-- BAS DE PAGE (TITRE ITATOOLS V3 RGB & CROIX X ROUGE)
-- =============================================================================
local BottomHeaderFrame = Instance.new("Frame")
BottomHeaderFrame.Name = "BottomHeaderFrame"
BottomHeaderFrame.Parent = MainGui
BottomHeaderFrame.BackgroundTransparency = 1
BottomHeaderFrame.AnchorPoint = Vector2.new(0.5, 1)
BottomHeaderFrame.Position = UDim2.new(0.5, 0, 1, -12)
BottomHeaderFrame.Size = UDim2.new(0, 280, 0, 36)
BottomHeaderFrame.ZIndex = 20

local Watermark = Instance.new("TextLabel")
Watermark.Name = "ItatoolsWatermark"
Watermark.Parent = BottomHeaderFrame
Watermark.BackgroundTransparency = 1
Watermark.Position = UDim2.new(0, 0, 0, 0)
Watermark.Size = UDim2.new(0, 230, 1, 0)
Watermark.Font = Enum.Font.GothamBold
Watermark.Text = "6f5e"
Watermark.TextColor3 = Color3.fromRGB(255, 255, 255)
Watermark.TextSize = 28
Watermark.TextXAlignment = Enum.TextXAlignment.Center
Watermark.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
Watermark.TextStrokeTransparency = 0
Watermark.ZIndex = 21

local TextOutline = Instance.new("UIStroke")
TextOutline.Parent = Watermark
TextOutline.Color = Color3.fromRGB(255, 255, 255)
TextOutline.Thickness = 1.8
TextOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual

connections.watermarkRGB = RunService.RenderStepped:Connect(function()
    local t = (tick() * 1.2) % 3
    local col
    local cWhite = Color3.fromRGB(255, 255, 255)
    local cCyan  = Color3.fromRGB(0, 220, 255)
    local cNavy  = Color3.fromRGB(15, 60, 170)

    if t < 1 then col = cWhite:Lerp(cCyan, t)
    elseif t < 2 then col = cCyan:Lerp(cNavy, t - 1)
    else col = cNavy:Lerp(cWhite, t - 2) end

    if Watermark then Watermark.TextColor3 = col end
end)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = BottomHeaderFrame
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
CloseBtn.Position = UDim2.new(0, 235, 0, 4)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.ZIndex = 25
CloseBtn.Active = true

local UICorner_Close = Instance.new("UICorner")
UICorner_Close.CornerRadius = UDim.new(0, 6)
UICorner_Close.Parent = CloseBtn

-- =============================================================================
-- CRÉATION DES COLONNES
-- =============================================================================
local function createColumn(categoryName, posXOffset)
    local Frame = Instance.new("Frame")
    Frame.Name = "ItatoolsCol_" .. categoryName
    Frame.Parent = MainGui
    Frame.BackgroundColor3 = Color3.fromRGB(18, 21, 26)
    Frame.BackgroundTransparency = 0.02
    Frame.AnchorPoint = Vector2.new(0.5, 0)
    Frame.Position = UDim2.new(0.5, posXOffset, 0, 45)
    Frame.Size = UDim2.new(0, 150, 0, 36)
    Frame.ClipsDescendants = false
    Frame.Active = true
    Frame.ZIndex = 10

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Parent = Frame
    Stroke.Color = Color3.fromRGB(45, 50, 65)
    Stroke.Thickness = 1.2

    local Header = Instance.new("TextButton")
    Header.Name = "Header"
    Header.Parent = Frame
    Header.BackgroundTransparency = 1
    Header.Size = UDim2.new(1, 0, 0, 36)
    Header.Text = ""
    Header.ZIndex = 11

    local Title = Instance.new("TextLabel")
    Title.Parent = Header
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = categoryName
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 12
    Title.ZIndex = 12

    local ModuleContainer = Instance.new("ScrollingFrame")
    ModuleContainer.Name = "ModuleContainer"
    ModuleContainer.Parent = Frame
    ModuleContainer.BackgroundTransparency = 1
    ModuleContainer.Position = UDim2.new(0, 0, 0, 36)
    ModuleContainer.Size = UDim2.new(1, 0, 0, 0)
    ModuleContainer.ScrollBarThickness = 3
    ModuleContainer.BorderSizePixel = 0
    ModuleContainer.ZIndex = 11

    local UIList = Instance.new("UIListLayout")
    UIList.Parent = ModuleContainer
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 1)

    local isCollapsed = false
    local function updateSize()
        if isCollapsed then
            ModuleContainer.Visible = false
            Frame.Size = UDim2.new(0, 150, 0, 36)
        else
            ModuleContainer.Visible = true
            local h = math.min(UIList.AbsoluteContentSize.Y, 380)
            ModuleContainer.Size = UDim2.new(1, 0, 0, h)
            ModuleContainer.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 4)
            Frame.Size = UDim2.new(0, 150, 0, 36 + h + 4)
        end
    end

    UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            isCollapsed = not isCollapsed
            updateSize()
        end
    end)

    local dragging, dragInput, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = Frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    return ModuleContainer
end

local function registerModule(key, moduleBtn, plusLabel, callback)
    local state = false
    local function toggle(forceState)
        if forceState ~= nil then state = forceState else state = not state end
        if state then
            moduleBtn.TextColor3 = Color3.fromRGB(0, 220, 255)
            if plusLabel then plusLabel.TextColor3 = Color3.fromRGB(0, 220, 255) end
        else
            moduleBtn.TextColor3 = Color3.fromRGB(240, 245, 255)
            if plusLabel then plusLabel.TextColor3 = Color3.fromRGB(150, 160, 175) end
        end
        pcall(callback, state)
        updateOverlay()
    end

    moduleRegistry[key] = { Toggle = toggle, GetState = function() return state end }
    return toggle
end

local function addModule(container, moduleName, defaultActive, callback, rightClickCallback)
    globalLayoutOrderCounter = globalLayoutOrderCounter + 1

    local moduleBtn = Instance.new("TextButton")
    moduleBtn.Name = moduleName
    moduleBtn.Parent = container
    moduleBtn.BackgroundColor3 = Color3.fromRGB(20, 24, 30)
    moduleBtn.BackgroundTransparency = 0.05
    moduleBtn.Size = UDim2.new(1, 0, 0, 25)
    moduleBtn.AutoButtonColor = false
    moduleBtn.Font = Enum.Font.GothamBold
    moduleBtn.Text = "  " .. moduleName
    moduleBtn.TextColor3 = Color3.fromRGB(240, 245, 255)
    moduleBtn.TextSize = 11
    moduleBtn.TextXAlignment = Enum.TextXAlignment.Left
    moduleBtn.ZIndex = 12
    moduleBtn.LayoutOrder = globalLayoutOrderCounter

    local plusLabel = Instance.new("TextLabel")
    plusLabel.Parent = moduleBtn
    plusLabel.BackgroundTransparency = 1
    plusLabel.Position = UDim2.new(1, -18, 0, 0)
    plusLabel.Size = UDim2.new(0, 15, 1, 0)
    plusLabel.Font = Enum.Font.GothamBold
    plusLabel.Text = "+"
    plusLabel.TextColor3 = Color3.fromRGB(150, 160, 175)
    plusLabel.TextSize = 12
    plusLabel.ZIndex = 13

    local toggleFunc = registerModule(moduleName, moduleBtn, plusLabel, callback)

    moduleBtn.MouseButton1Click:Connect(function()
        toggleFunc()
    end)

    if rightClickCallback then
        moduleBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                pcall(rightClickCallback)
            end
        end)
    end

    if defaultActive then toggleFunc(true) end
    return moduleBtn
end

local function addSimpleActionBtn(container, text, actionCallback)
    globalLayoutOrderCounter = globalLayoutOrderCounter + 1

    local btn = Instance.new("TextButton")
    btn.Name = text
    btn.Parent = container
    btn.BackgroundColor3 = Color3.fromRGB(20, 24, 30)
    btn.BackgroundTransparency = 0.05
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.AutoButtonColor = true
    btn.Font = Enum.Font.GothamBold
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.fromRGB(240, 245, 255)
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.ZIndex = 12
    btn.LayoutOrder = globalLayoutOrderCounter

    btn.MouseButton1Click:Connect(function() pcall(actionCallback) end)
    return btn
end

local function addSliderModule(container, text, min, max, defaultVal, callback, isFloat)
    globalLayoutOrderCounter = globalLayoutOrderCounter + 1

    local frame = Instance.new("Frame")
    frame.Name = "Slider_" .. text
    frame.Parent = container
    frame.BackgroundColor3 = Color3.fromRGB(15, 18, 23)
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.ZIndex = 12
    frame.LayoutOrder = globalLayoutOrderCounter

    local function formatVal(v)
        if isFloat then
            return string.format("%.1f", v / 10)
        else
            return tostring(v)
        end
    end

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 6, 0, 2)
    label.Size = UDim2.new(1, -12, 0, 14)
    label.Font = Enum.Font.GothamBold
    label.Text = text .. " : " .. formatVal(defaultVal)
    label.TextColor3 = Color3.fromRGB(240, 245, 255)
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 13

    local sliderBar = Instance.new("Frame")
    sliderBar.Parent = frame
    sliderBar.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
    sliderBar.Position = UDim2.new(0, 6, 0, 19)
    sliderBar.Size = UDim2.new(1, -12, 0, 8)
    sliderBar.ZIndex = 13
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 4)
    barCorner.Parent = sliderBar

    local pct = math.clamp((defaultVal - min) / (max - min), 0, 1)
    local fill = Instance.new("Frame")
    fill.Parent = sliderBar
    fill.BackgroundColor3 = Color3.fromRGB(0, 210, 255)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.ZIndex = 14
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fill

    local isDragging = false
    local function update(inputX)
        local p = math.clamp((inputX - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (p * (max - min)))
        label.Text = text .. " : " .. formatVal(val)
        fill.Size = UDim2.new(p, 0, 1, 0)
        if isFloat then
            pcall(callback, val / 10)
        else
            pcall(callback, val)
        end
    end

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true; update(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end)
    return frame
end

-- 7 Colonnes
local CombatCol   = createColumn("Combat", -480)
local VisualCol   = createColumn("Tracker ESP", -320)
local MovementCol = createColumn("Mouvement", -160)
local TrollCol    = createColumn("Troll & Colle", 0)
local TeleportCol = createColumn("Téléportation", 160)
local GameCol     = createColumn("Jeu (Auto)", 320)
local SettingsCol = createColumn("Paramètres", 480)

-- =============================================================================
-- 1. COMBAT (AIMLOCK ULTRA SÉCURISÉ SANS HOOKMETAMETHOD)
-- =============================================================================
addModule(CombatCol, "AimLock (Droit)", false, function(s) _G.AimLock_Enabled = s end)
addModule(CombatCol, "Lock Auto (R)", false, function(s) _G.ToggleLock_Enabled = s end)

local function getClosestPlayer()
    local closestPlayer = nil; local shortestDistance = math.huge
    local mouseLocation = UserInputService:GetMouseLocation()
    local myChar = LocalPlayer.Character; local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local targetHead = player.Character.Head
                local dist3D = myRoot and (targetHead.Position - myRoot.Position).Magnitude or 0
                if dist3D <= 250 then
                    local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(targetHead.Position)
                    if onScreen then
                        local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - mouseLocation).Magnitude
                        if dist2D < shortestDistance then closestPlayer = player; shortestDistance = dist2D end
                    end
                end
            end
        end
    end
    return closestPlayer
end

connections.aimLockStep = RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    local shouldLock = _G.ToggleLock_Enabled or (_G.AimLock_Enabled and isAiming)
    if shouldLock then if not aimLockTarget then aimLockTarget = getClosestPlayer() end else aimLockTarget = nil end
    if aimLockTarget and aimLockTarget.Character and aimLockTarget.Character:FindFirstChild("Head") then
        cam.CFrame = CFrame.new(cam.CFrame.Position, aimLockTarget.Character.Head.Position)
    end
end)

-- =============================================================================
-- 2. TRACKER ESP (COLORATION ET CRÉATION DE L'ESP PROPRE)
-- =============================================================================
local colorList = {
    Color3.fromRGB(255, 45, 85),  -- Rouge
    Color3.fromRGB(0, 122, 255),  -- Bleu
    Color3.fromRGB(40, 200, 50),  -- Vert
    Color3.fromRGB(255, 200, 0),  -- Jaune
    Color3.fromRGB(255, 255, 255),-- Blanc
    Color3.fromRGB(150, 0, 255),  -- Violet
    Color3.fromRGB(0, 210, 255)   -- Cyan
}
local currentColorIdx = 5

local function updateActiveESPColors()
    for player, data in pairs(currentESP) do
        if data then
            local roleColor = nil
            local roleName = mm2Roles[player]
            if _G.MM2_ESP_Enabled then
                if roleName == "Murderer" then
                    roleColor = Color3.fromRGB(255, 0, 0) -- ROUGE
                elseif roleName == "Sheriff" then
                    roleColor = Color3.fromRGB(0, 0, 255) -- BLEU
                end
            end

            local isRolePlayer = (roleColor ~= nil)
            local isVisible = isRolePlayer or _G.ESP_Enabled
            local c = roleColor or _G.ESP_Color

            if data.Highlight then
                data.Highlight.Enabled = isVisible
                data.Highlight.FillColor = c
                data.Highlight.OutlineColor = c
            end
            if data.Billboard then
                data.Billboard.Enabled = isVisible
            end
            if data.NameLabel then
                data.NameLabel.TextColor3 = c
                if _G.MM2_ESP_Enabled and roleName and roleName ~= "Innocent" then
                    data.NameLabel.Text = player.DisplayName .. " [" .. roleName .. "]"
                else
                    data.NameLabel.Text = player.DisplayName
                end
            end
        end
    end
end

function applyESP(player)
    if player == LocalPlayer or currentESP[player] then return end
    currentESP[player] = {}

    local function onCharacterAdded(character)
        if currentESP[player].Highlight then pcall(function() currentESP[player].Highlight:Destroy() end) end
        if currentESP[player].Billboard then pcall(function() currentESP[player].Billboard:Destroy() end) end

        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"; highlight.Adornee = character
        highlight.FillColor = _G.ESP_Color; highlight.FillTransparency = 0.55
        highlight.OutlineColor = _G.ESP_Color; highlight.Enabled = _G.ESP_Enabled
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = character
        currentESP[player].Highlight = highlight

        task.spawn(function()
            local rootPart = character:WaitForChild("HumanoidRootPart", 5) or character:FindFirstChild("Head")
            if not rootPart then return end

            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESP_Billboard_" .. player.Name; billboard.Adornee = rootPart
            billboard.Size = UDim2.new(4, 0, 5.5, 0); billboard.AlwaysOnTop = true; billboard.Enabled = _G.ESP_Enabled
            billboard.Parent = OverlayGui
            currentESP[player].Billboard = billboard

            local nameLabel = Instance.new("TextLabel", billboard)
            nameLabel.BackgroundTransparency = 1; nameLabel.Size = UDim2.new(1, 0, 0, 20); nameLabel.Position = UDim2.new(0, 0, 0, -25)
            nameLabel.Text = player.DisplayName; nameLabel.TextColor3 = _G.ESP_Color; nameLabel.Font = Enum.Font.GothamBold; nameLabel.TextSize = 12
            currentESP[player].NameLabel = nameLabel

            local hpBg = Instance.new("Frame", billboard)
            hpBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0); hpBg.Size = UDim2.new(0, 5, 1, 0); hpBg.Position = UDim2.new(0, -8, 0, 0)
            local hpFill = Instance.new("Frame", hpBg)
            hpFill.BackgroundColor3 = Color3.fromRGB(40, 200, 50); hpFill.AnchorPoint = Vector2.new(0, 1); hpFill.Position = UDim2.new(0, 0, 1, 0)

            local hum = character:WaitForChild("Humanoid", 5)
            if hum then
                local function updateHealth()
                    local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    hpFill.Size = UDim2.new(1, 0, hpPercent, 0)
                    hpFill.BackgroundColor3 = Color3.fromRGB(255 - (hpPercent * 255), hpPercent * 255, 0)
                end
                updateHealth()
                currentESP[player].HPConnection = hum.HealthChanged:Connect(updateHealth)
            end
            updateActiveESPColors()
        end)
    end

    if player.Character then onCharacterAdded(player.Character) end
    currentESP[player].CharConnection = player.CharacterAdded:Connect(onCharacterAdded)
end

-- Attachement des joueurs
for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

function removeAllESP()
    for player, data in pairs(currentESP) do
        if data then
            pcall(function()
                if data.Highlight then data.Highlight:Destroy() end
                if data.Billboard then data.Billboard:Destroy() end
            end)
        end
    end
    currentESP = {}
end

addModule(VisualCol, "ESP Tracker", false, function(s)
    _G.ESP_Enabled = s
    updateActiveESPColors()
end, function()
    currentColorIdx = (currentColorIdx % #colorList) + 1
    _G.ESP_Color = colorList[currentColorIdx]
    updateActiveESPColors()
end)

addModule(VisualCol, "Shaders Graphiques", false, function(s)
    _G.Shaders_Enabled = s
    for _, effect in ipairs(shaderEffects) do if effect then effect:Destroy() end end
    shaderEffects = {}

    if s then
        pcall(function()
            Lighting.GlobalShadows = true; Lighting.Brightness = 3.5
            local cc = Instance.new("ColorCorrectionEffect", Lighting); cc.Contrast = 0.35; table.insert(shaderEffects, cc)
            local bloom = Instance.new("BloomEffect", Lighting); bloom.Intensity = 0.7; table.insert(shaderEffects, bloom)
        end)
    end
end)

-- =============================================================================
-- 3. MOUVEMENT
-- =============================================================================
addModule(MovementCol, "Noclip", false, function(s)
    _G.Noclip_Enabled = s
    if s then
        connections.noclipStepped = RunService.Stepped:Connect(function()
            if _G.Noclip_Enabled and LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end
            end
        end)
    else
        if connections.noclipStepped then connections.noclipStepped:Disconnect() end
    end
end)

addModule(MovementCol, "Speed", false, function(s)
    _G.Speed_Enabled = s
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = s and _G.WalkSpeedValue or 16
    end
end)

addSliderModule(MovementCol, "WalkSpeed", 16, 1000, 32, function(val)
    _G.WalkSpeedValue = val
    if _G.Speed_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = val
    end
end)

local flyAngleY = 0

local function startFly()
    local char = LocalPlayer.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); local hum = char:FindFirstChildOfClass("Humanoid")
    if not root then return end
    flyVelocity = Instance.new("BodyVelocity", root); flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyGyro = Instance.new("BodyGyro", root); flyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    if hum then hum.PlatformStand = true end

    connections.flyLoop = RunService.RenderStepped:Connect(function(dt)
        if not _G.Fly_Enabled or not LocalPlayer.Character then return end
        for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end

        local cam = workspace.CurrentCamera; local dir = Vector3.zero
        if flyInput.Forward then dir += cam.CFrame.LookVector end
        if flyInput.Backward then dir -= cam.CFrame.LookVector end
        if flyInput.Left then dir -= cam.CFrame.RightVector end
        if flyInput.Right then dir += cam.CFrame.RightVector end
        if flyInput.Up then dir += Vector3.new(0, 1, 0) end
        if flyInput.Down then dir -= Vector3.new(0, 1, 0) end

        local speed = _G.Fly_Speed * (flyInput.Boost and _G.Fly_Boost or 1)
        flyVelocity.Velocity = dir.Magnitude > 0 and (dir.Unit * speed) or Vector3.zero

        if _G.Tourniquer_Enabled then
            flyAngleY = flyAngleY + (dt * _G.Tourniquer_Speed * 0.1)
            flyGyro.CFrame = cam.CFrame * CFrame.Angles(0, flyAngleY, 0)
        else
            flyGyro.CFrame = cam.CFrame
        end
    end)
end

addModule(MovementCol, "Fly (F)", false, function(s)
    _G.Fly_Enabled = s
    if s then startFly() else
        if connections.flyLoop then connections.flyLoop:Disconnect() end
        if flyVelocity then flyVelocity:Destroy() end
        if flyGyro then flyGyro:Destroy() end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then LocalPlayer.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false end
    end
end)

addSliderModule(MovementCol, "Vitesse Fly", 50, 2000, 200, function(val) _G.Fly_Speed = val end)

-- =============================================================================
-- 4. TROLL & COLLER (ANTI-ENVOL ET ANTI-TRAVERSÉE DE SOL)
-- =============================================================================
addModule(TrollCol, "Tourniquer", false, function(s)
    _G.Tourniquer_Enabled = s
    local char = LocalPlayer.Character; local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        if s then
            spinVelocity = Instance.new("BodyAngularVelocity", root)
            spinVelocity.Name = "TourniquerSpin"; spinVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
            spinVelocity.AngularVelocity = Vector3.new(0, _G.Tourniquer_Speed, 0)
        else
            if spinVelocity then spinVelocity:Destroy(); spinVelocity = nil end
        end
    end
    updateOverlay()
end)

addSliderModule(TrollCol, "Vitesse Spin", 10, 300, 60, function(val)
    _G.Tourniquer_Speed = val
    if spinVelocity then spinVelocity.AngularVelocity = Vector3.new(0, val, 0) end
end)

addModule(TrollCol, "Ressort (Fling)", false, function(s)
    _G.Ressort_Enabled = s
    if s then
        local isFlinging = false
        connections.ressortFling = RunService.Heartbeat:Connect(function()
            if _G.Ressort_Enabled and not isFlinging then
                local myChar = LocalPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local targetRoot = player.Character.HumanoidRootPart
                            if (myRoot.Position - targetRoot.Position).Magnitude < 8 then
                                isFlinging = true
                                task.spawn(function()
                                    local savedCFrame = myRoot.CFrame
                                    
                                    local bav = Instance.new("BodyAngularVelocity")
                                    bav.Name = "FlingBav"
                                    bav.MaxTorque = Vector3.new(0, math.huge, 0)
                                    bav.AngularVelocity = Vector3.new(0, 99999, 0)
                                    bav.Parent = myRoot

                                    local startTime = tick()
                                    while tick() - startTime < 0.35 and targetRoot and targetRoot.Parent and myRoot and myRoot.Parent do
                                        for _, p in ipairs(myChar:GetChildren()) do
                                            if p:IsA("BasePart") then p.CanCollide = false end
                                        end
                                        myRoot.CFrame = targetRoot.CFrame * CFrame.Angles(0, math.rad(math.random(0, 360)), 0)
                                        myRoot.Velocity = Vector3.zero
                                        myRoot.RotVelocity = Vector3.new(0, 99999, 0)
                                        RunService.Heartbeat:Wait()
                                    end

                                    bav:Destroy()
                                    
                                    for _, p in ipairs(myChar:GetChildren()) do
                                        if p:IsA("BasePart") then p.CanCollide = true end
                                    end
                                    myRoot.Velocity = Vector3.zero
                                    myRoot.RotVelocity = Vector3.zero
                                    myRoot.CFrame = savedCFrame + Vector3.new(0, 2, 0)

                                    task.wait(0.15)
                                    isFlinging = false
                                end)
                                break
                            end
                        end
                    end
                end
            end
        end)
    else
        if connections.ressortFling then
            connections.ressortFling:Disconnect()
            connections.ressortFling = nil
        end
    end
end)

addModule(TrollCol, "Run", false, function(s)
    _G.Run_Enabled = s
    local char = LocalPlayer.Character
    if currentRunTrack then currentRunTrack:Stop(); currentRunTrack = nil end
    if s and char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local animator = hum:FindFirstChildOfClass("Animator") or hum
            local anim = Instance.new("Animation")
            anim.AnimationId = (hum.RigType == Enum.HumanoidRigType.R15) and "rbxassetid://507767714" or "rbxassetid://180426354"
            currentRunTrack = animator:LoadAnimation(anim)
            currentRunTrack.Looped = true
            currentRunTrack.Priority = Enum.AnimationPriority.Action
            currentRunTrack:Play(0.1, 1, _G.Run_Speed)
        end
    end
end)

addSliderModule(TrollCol, "Vitesse Run", 1, 100, 20, function(val)
    _G.Run_Speed = val
    if currentRunTrack and _G.Run_Enabled then
        currentRunTrack:AdjustSpeed(_G.Run_Speed)
    end
end, true)

local setColleState

local colleBtnObj = addModule(TrollCol, "Coller", false, function(s)
    if setColleState then setColleState(s) end
end, function()
    if InlineColleFrame then
        InlineColleFrame.Visible = not InlineColleFrame.Visible
        if InlineColleFrame.Visible and updateInlinePlayers then updateInlinePlayers() end
    end
end)

InlineColleFrame = Instance.new("Frame")
InlineColleFrame.Name = "InlineColleFrame"
InlineColleFrame.Parent = TrollCol
InlineColleFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 23)
InlineColleFrame.Size = UDim2.new(1, 0, 0, 140)
InlineColleFrame.Visible = false
InlineColleFrame.ZIndex = 12
globalLayoutOrderCounter = globalLayoutOrderCounter + 1
InlineColleFrame.LayoutOrder = globalLayoutOrderCounter

local InlineSearch = Instance.new("TextBox", InlineColleFrame)
InlineSearch.Size = UDim2.new(1, -8, 0, 22); InlineSearch.Position = UDim2.new(0, 4, 0, 4)
InlineSearch.BackgroundColor3 = Color3.fromRGB(24, 28, 36); InlineSearch.PlaceholderText = ""
InlineSearch.Text = ""
InlineSearch.TextColor3 = Color3.fromRGB(255, 255, 255); InlineSearch.Font = Enum.Font.GothamBold; InlineSearch.TextSize = 10
InlineSearch.ZIndex = 13
local SearchCorner = Instance.new("UICorner", InlineSearch); SearchCorner.CornerRadius = UDim.new(0, 4)

local InlineScroll = Instance.new("ScrollingFrame", InlineColleFrame)
InlineScroll.Position = UDim2.new(0, 4, 0, 30); InlineScroll.Size = UDim2.new(1, -8, 1, -34)
InlineScroll.BackgroundTransparency = 1; InlineScroll.ScrollBarThickness = 2
InlineScroll.ZIndex = 13
local InlineLayout = Instance.new("UIListLayout", InlineScroll); InlineLayout.Padding = UDim.new(0, 2)

function updateInlinePlayers()
    for _, c in ipairs(InlineScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local query = string.lower(InlineSearch.Text)

    local playerList = Players:GetPlayers()
    table.sort(playerList, function(a, b) return string.lower(a.DisplayName) < string.lower(b.DisplayName) end)

    for _, p in ipairs(playerList) do
        if p ~= LocalPlayer and (query == "" or string.find(string.lower(p.Name), query) or string.find(string.lower(p.DisplayName), query)) then
            local b = Instance.new("TextButton", InlineScroll)
            b.Size = UDim2.new(1, 0, 0, 20); b.BackgroundColor3 = Color3.fromRGB(22, 26, 34); b.Text = " " .. p.DisplayName
            b.TextColor3 = Color3.fromRGB(240, 245, 255); b.Font = Enum.Font.GothamBold; b.TextSize = 9; b.TextXAlignment = Enum.TextXAlignment.Left
            b.ZIndex = 14
            local c = Instance.new("UICorner", b); c.CornerRadius = UDim.new(0, 4)

            b.MouseButton1Click:Connect(function()
                _G.Colle_Target = p
                if moduleRegistry["Coller"] then moduleRegistry["Coller"].Toggle(true) end
            end)
        end
    end
end
InlineSearch:GetPropertyChangedSignal("Text"):Connect(updateInlinePlayers)

setColleState = function(enabled)
    _G.Colle_Enabled = enabled
    if enabled then
        if not _G.Colle_Target then
            for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then _G.Colle_Target = p; break end end
        end
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            local anim = Instance.new("Animation"); anim.AnimationId = "rbxassetid://2506281703"
            colleAnimTrack = char:FindFirstChildOfClass("Humanoid"):LoadAnimation(anim)
            colleAnimTrack.Priority = Enum.AnimationPriority.Action; colleAnimTrack:Play()
        end
    else
        _G.Colle_Target = nil
        if colleAnimTrack then colleAnimTrack:Stop() end
    end
    updateOverlay()
end

connections.colleStepped = RunService.Stepped:Connect(function()
    if _G.Colle_Enabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

connections.colleHeartbeat = RunService.Heartbeat:Connect(function()
    if _G.Colle_Enabled and _G.Colle_Target and _G.Colle_Target.Character then
        local myChar = LocalPlayer.Character; local tHead = _G.Colle_Target.Character:FindFirstChild("Head")
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myRoot and tHead then
            myRoot.CFrame = tHead.CFrame * CFrame.new(0, 1.6, 0)
            myRoot.Velocity = Vector3.zero
            myRoot.RotVelocity = Vector3.zero
        end
    end
end)

-- =============================================================================
-- 5. TÉLÉPORTATION
-- =============================================================================
local forceTeleportToPlayer

local TpSearchBox = Instance.new("TextBox", TeleportCol)
TpSearchBox.Size = UDim2.new(1, -8, 0, 22); TpSearchBox.Position = UDim2.new(0, 4, 0, 4)
TpSearchBox.BackgroundColor3 = Color3.fromRGB(24, 28, 36); TpSearchBox.PlaceholderText = ""
TpSearchBox.Text = ""
TpSearchBox.TextColor3 = Color3.fromRGB(255, 255, 255); TpSearchBox.Font = Enum.Font.GothamBold; TpSearchBox.TextSize = 10
TpSearchBox.ZIndex = 13
globalLayoutOrderCounter = globalLayoutOrderCounter + 1
TpSearchBox.LayoutOrder = 0
local TpSearchCorner = Instance.new("UICorner", TpSearchBox); TpSearchCorner.CornerRadius = UDim.new(0, 4)

forceTeleportToPlayer = function(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if targetRoot and myRoot then myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3) end
end

local function populateTeleportList()
    for _, child in ipairs(TeleportCol:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local query = string.lower(TpSearchBox.Text)
    local playerList = Players:GetPlayers()
    table.sort(playerList, function(a, b) return string.lower(a.DisplayName) < string.lower(b.DisplayName) end)

    for _, player in ipairs(playerList) do
        if player ~= LocalPlayer and (query == "" or string.find(string.lower(player.Name), query) or string.find(string.lower(player.DisplayName), query)) then
            addSimpleActionBtn(TeleportCol, "TP: " .. player.DisplayName, function()
                forceTeleportToPlayer(player)
            end)
        end
    end
end

TpSearchBox:GetPropertyChangedSignal("Text"):Connect(populateTeleportList)
populateTeleportList()
Players.PlayerAdded:Connect(populateTeleportList)
Players.PlayerRemoving:Connect(populateTeleportList)

-- =============================================================================
-- 6. JEU (AUTO DETECTOR MM2 & BUBBLE GUM SIMULATOR)
-- =============================================================================
local GameTitleLabel = Instance.new("TextLabel", GameCol)
GameTitleLabel.BackgroundTransparency = 1; GameTitleLabel.Size = UDim2.new(1, 0, 0, 24); GameTitleLabel.Font = Enum.Font.GothamBold
GameTitleLabel.Text = "Jeu : Chargement..."; GameTitleLabel.TextColor3 = Color3.fromRGB(0, 210, 255); GameTitleLabel.TextSize = 10; GameTitleLabel.ZIndex = 12

local function scanDroppedGun()
    if not _G.MM2_ESP_Enabled then
        if droppedGunHighlight then droppedGunHighlight:Destroy(); droppedGunHighlight = nil end
        if droppedGunBillboard then droppedGunBillboard:Destroy(); droppedGunBillboard = nil end
        return
    end

    local foundGun = nil
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj.Name == "GunDrop" or obj.Name == "Gun") then
            local isPlayerItem = false
            for _, p in ipairs(Players:GetPlayers()) do
                if (p.Character and obj:IsDescendantOf(p.Character)) or (p:FindFirstChild("Backpack") and obj:IsDescendantOf(p.Backpack)) then
                    isPlayerItem = true
                    break
                end
            end

            if not isPlayerItem then
                foundGun = obj
                break
            end
        end
    end

    if foundGun then
        local targetPart = foundGun:IsA("BasePart") and foundGun or (foundGun:FindFirstChild("Handle") or foundGun:FindFirstChildOfClass("BasePart"))
        if targetPart then
            if not droppedGunHighlight or droppedGunHighlight.Adornee ~= foundGun then
                if droppedGunHighlight then droppedGunHighlight:Destroy() end
                droppedGunHighlight = Instance.new("Highlight")
                droppedGunHighlight.Name = "GunDropHighlight"
                droppedGunHighlight.Adornee = foundGun
                droppedGunHighlight.FillColor = Color3.fromRGB(255, 220, 0)
                droppedGunHighlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                droppedGunHighlight.FillTransparency = 0.2
                droppedGunHighlight.OutlineTransparency = 0
                droppedGunHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                droppedGunHighlight.Parent = targetPart
            end

            if not droppedGunBillboard or droppedGunBillboard.Adornee ~= targetPart then
                if droppedGunBillboard then droppedGunBillboard:Destroy() end
                droppedGunBillboard = Instance.new("BillboardGui")
                droppedGunBillboard.Name = "GunDropBillboard"
                droppedGunBillboard.Adornee = targetPart
                droppedGunBillboard.Size = UDim2.new(5, 0, 1.8, 0)
                droppedGunBillboard.AlwaysOnTop = true
                droppedGunBillboard.Parent = OverlayGui

                local label = Instance.new("TextLabel", droppedGunBillboard)
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = "🔫 GUN AU SOL !"
                label.TextColor3 = Color3.fromRGB(255, 220, 0)
                label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                label.TextStrokeTransparency = 0
                label.Font = Enum.Font.GothamBold
                label.TextSize = 14
            end
        end
    else
        if droppedGunHighlight then droppedGunHighlight:Destroy(); droppedGunHighlight = nil end
        if droppedGunBillboard then droppedGunBillboard:Destroy(); droppedGunBillboard = nil end
    end
end

local function detectMM2Roles()
    mm2Roles = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local backpack = player:FindFirstChild("Backpack")
            local isMurderer = false
            local isSheriff = false

            if char then
                if char:FindFirstChild("Knife") then isMurderer = true end
                if char:FindFirstChild("Gun") then isSheriff = true end
            end
            if backpack then
                if backpack:FindFirstChild("Knife") then isMurderer = true end
                if backpack:FindFirstChild("Gun") then isSheriff = true end
            end

            if isMurderer then
                mm2Roles[player] = "Murderer"
            elseif isSheriff then
                mm2Roles[player] = "Sheriff"
            else
                mm2Roles[player] = "Innocent"
            end
        end
    end
    updateActiveESPColors()
    scanDroppedGun()
end

-- DÉTECTION MM2 TOUTES LES 0.8 SECONDES
task.spawn(function()
    while true do
        if _G.MM2_ESP_Enabled then
            pcall(detectMM2Roles)
        end
        task.wait(0.8)
    end
end)

-- TP Kill Logic (Clic) - V2 Original
local isTpKilling = false

local function performTpKill(targetPlayer)
    if isTpKilling or not _G.TpKill_Enabled then return end
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myRoot or not hum then return end

    local knife = myChar:FindFirstChild("Knife") or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Knife"))
    if not knife then
        knife = myChar:FindFirstChildOfClass("Tool") or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChildOfClass("Tool"))
    end

    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local tRoot = targetPlayer.Character.HumanoidRootPart
        local tHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if tHum and tHum.Health > 0 then
            isTpKilling = true
            local savedCFrame = myRoot.CFrame

            if knife and knife.Parent ~= myChar then
                hum:EquipTool(knife)
                task.wait(0.05)
            end

            myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 1.2)
            local activeTool = myChar:FindFirstChildOfClass("Tool")
            if activeTool then activeTool:Activate() end
            task.wait(0.12)
            myRoot.CFrame = savedCFrame
            task.wait(0.05)
            isTpKilling = false
        end
    end
end

connections.tpKillClick = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and _G.TpKill_Enabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local target = getClosestPlayer()
        if target then
            performTpKill(target)
        end
    end
end)

-- Détection du Jeu (MM2 ou Bubble Gum Simulator)
task.spawn(function()
    local success, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
    local gameName = (success and info and info.Name) or ""
    local lowerName = string.lower(gameName)
    local placeId = game.PlaceId

    if placeId == 142823684 or placeId == 142823291 or string.find(lowerName, "murder mystery") then
        GameTitleLabel.Text = "Jeu: MM2 🔪"

        addModule(GameCol, "ESP Roles MM2", true, function(s)
            _G.MM2_ESP_Enabled = s
            if not s then
                if droppedGunHighlight then droppedGunHighlight:Destroy(); droppedGunHighlight = nil end
                if droppedGunBillboard then droppedGunBillboard:Destroy(); droppedGunBillboard = nil end
            end
            updateActiveESPColors()
        end)

        addModule(GameCol, "TP Kill (Clic)", false, function(s) _G.TpKill_Enabled = s end)

    elseif placeId == 2512643572 or string.find(lowerName, "bubble gum") or string.find(lowerName, "gomme à bulles") or string.find(lowerName, "gomme a bulles") then
        GameTitleLabel.Text = "Jeu: Bubble Gum Sim 🎈"

        -- Auto Bulles (Multi-méthode BGS : Equipement Tool + Remotes Network + Clics Virtuels)
        addModule(GameCol, "Auto Bulles 🎈", false, function(s)
            _G.BGS_AutoBlow = s
            if s then
                task.spawn(function()
                    local Vim = pcall(function() return game:GetService("VirtualInputManager") end) and game:GetService("VirtualInputManager")
                    while _G.BGS_AutoBlow do
                        pcall(function()
                            local myChar = LocalPlayer.Character
                            local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
                            
                            if myChar then
                                for _, tool in ipairs(myChar:GetChildren()) do
                                    if tool:IsA("Tool") then tool:Activate() end
                                end
                                if LocalPlayer.Backpack then
                                    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                                        if tool:IsA("Tool") and hum then
                                            hum:EquipTool(tool)
                                            task.wait(0.02)
                                            tool:Activate()
                                        end
                                    end
                                end
                            end

                            local net = game:GetService("ReplicatedStorage"):FindFirstChild("Network")
                            if net then
                                for _, child in ipairs(net:GetChildren()) do
                                    local nameLower = string.lower(child.Name)
                                    if string.find(nameLower, "blow") or string.find(nameLower, "bubble") then
                                        if child:IsA("RemoteEvent") then
                                            child:FireServer()
                                        elseif child:IsA("RemoteFunction") then
                                            child:InvokeServer()
                                        end
                                    end
                                end
                            end

                            if Vim then
                                Vim:SendMouseButtonEvent(100, 100, 0, true, game, 0)
                                task.wait(0.02)
                                Vim:SendMouseButtonEvent(100, 100, 0, false, game, 0)
                            elseif mouse1press and mouse1release then
                                mouse1press()
                                task.wait(0.02)
                                mouse1release()
                            end
                        end)
                        task.wait(0.08)
                    end
                end)
            end
        end)

        -- Auto Vente (Spot le plus haut sans lag)
        addModule(GameCol, "Auto Vente 💰", false, function(s)
            _G.BGS_AutoSell = s
            if s then
                task.spawn(function()
                    while _G.BGS_AutoSell do
                        pcall(function()
                            local myChar = LocalPlayer.Character
                            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                            if myRoot then
                                local bestSpot = nil
                                local maxY = -999999

                                local islands = workspace:FindFirstChild("Islands") or workspace
                                for _, island in ipairs(islands:GetChildren()) do
                                    local sell = island:FindFirstChild("Sell", true) or island:FindFirstChild("SellCircle", true)
                                    if sell then
                                        local pos = sell:IsA("BasePart") and sell.Position or (sell:IsA("Model") and sell:GetModelCFrame().Position)
                                        if pos and pos.Y > maxY then
                                            maxY = pos.Y
                                            bestSpot = pos
                                        end
                                    end
                                end

                                if bestSpot then
                                    myRoot.CFrame = CFrame.new(bestSpot + Vector3.new(0, 3, 0))
                                end
                            end
                        end)
                        task.wait(2.0)
                    end
                end)
            end
        end)

        _G.BGS_AutoTake_Distance = 1000
        -- Auto Take 🪙 avec Zone 4 Coins & Parcours en Lignes
        _G.BGS_Zone_Corners = {}
        _G.BGS_Zone_Markers = {}
        _G.BGS_Zone_Running = false

        local function clearZoneMarkers()
            for _, m in ipairs(_G.BGS_Zone_Markers) do
                if m then pcall(function() m:Destroy() end) end
            end
            _G.BGS_Zone_Markers = {}
        end

        local function createCornerMarker(index, pos)
            local part = Instance.new("Part")
            part.Name = "BGS_ZoneMarker_" .. index
            part.Anchored = true
            part.CanCollide = false
            part.Size = Vector3.new(1.5, 6, 1.5)
            part.Position = pos
            part.Material = Enum.Material.Neon
            part.Color = Color3.fromRGB(0, 210, 255)
            part.Transparency = 0.3
            part.Parent = workspace

            local bb = Instance.new("BillboardGui", part)
            bb.Size = UDim2.new(0, 80, 0, 20)
            bb.AlwaysOnTop = true
            bb.StudsOffset = Vector3.new(0, 4, 0)

            local txt = Instance.new("TextLabel", bb)
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.Text = "Coin " .. index
            txt.TextColor3 = Color3.fromRGB(0, 255, 220)
            txt.Font = Enum.Font.GothamBold
            txt.TextSize = 12

            table.insert(_G.BGS_Zone_Markers, part)
        end

        addModule(GameCol, "Auto Take 🪙", false, function(s)
            _G.BGS_AutoTake = s
            if not s then _G.BGS_Zone_Running = false end
        end, function()
            if InlineAutoTakeFrame then
                InlineAutoTakeFrame.Visible = not InlineAutoTakeFrame.Visible
            end
        end)

        -- Panneau de configuration des 4 Coins et parcours en lignes
        InlineAutoTakeFrame = Instance.new("Frame")
        InlineAutoTakeFrame.Name = "InlineAutoTakeFrame"
        InlineAutoTakeFrame.Parent = GameCol
        InlineAutoTakeFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 23)
        InlineAutoTakeFrame.Size = UDim2.new(1, 0, 0, 175)
        InlineAutoTakeFrame.Visible = false
        InlineAutoTakeFrame.ZIndex = 12
        globalLayoutOrderCounter = globalLayoutOrderCounter + 1
        InlineAutoTakeFrame.LayoutOrder = globalLayoutOrderCounter

        local SubList = Instance.new("UIListLayout", InlineAutoTakeFrame)
        SubList.SortOrder = Enum.SortOrder.LayoutOrder
        SubList.Padding = UDim.new(0, 2)

        -- Boutons de placement des 4 coins
        local btnCoins = {}
        for i = 1, 4 do
            local btn = Instance.new("TextButton", InlineAutoTakeFrame)
            btn.Size = UDim2.new(1, -8, 0, 22)
            btn.Position = UDim2.new(0, 4, 0, 0)
            btn.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
            btn.Text = "  Placer Coin " .. i .. " 📍"
            btn.TextColor3 = Color3.fromRGB(240, 245, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 10
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.ZIndex = 13
            local c = Instance.new("UICorner", btn); c.CornerRadius = UDim.new(0, 4)

            btn.MouseButton1Click:Connect(function()
                local myChar = LocalPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    _G.BGS_Zone_Corners[i] = myRoot.Position
                    if _G.BGS_Zone_Markers[i] then _G.BGS_Zone_Markers[i]:Destroy() end
                    createCornerMarker(i, myRoot.Position)
                    btn.Text = "  Coin " .. i .. " placé ✅"
                    btn.TextColor3 = Color3.fromRGB(0, 220, 255)
                end
            end)
            table.insert(btnCoins, btn)
        end

        -- Bouton Démarrer / Arrêter le parcours
        local toggleRunBtn = Instance.new("TextButton", InlineAutoTakeFrame)
        toggleRunBtn.Size = UDim2.new(1, -8, 0, 24)
        toggleRunBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
        toggleRunBtn.Text = "Démarrer Zone 🚀"
        toggleRunBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleRunBtn.Font = Enum.Font.GothamBold
        toggleRunBtn.TextSize = 10
        toggleRunBtn.ZIndex = 13
        local cRun = Instance.new("UICorner", toggleRunBtn); cRun.CornerRadius = UDim.new(0, 4)

        -- Bouton Réinitialiser Coins
        local resetBtn = Instance.new("TextButton", InlineAutoTakeFrame)
        resetBtn.Size = UDim2.new(1, -8, 0, 22)
        resetBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        resetBtn.Text = "Réinitialiser Coins 🔄"
        resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        resetBtn.TextSize = 10
        resetBtn.Font = Enum.Font.GothamBold
        resetBtn.ZIndex = 13
        local cReset = Instance.new("UICorner", resetBtn); cReset.CornerRadius = UDim.new(0, 4)

        resetBtn.MouseButton1Click:Connect(function()
            _G.BGS_Zone_Corners = {}
            _G.BGS_Zone_Running = false
            clearZoneMarkers()
            for idx, b in ipairs(btnCoins) do
                b.Text = "  Placer Coin " .. idx .. " 📍"
                b.TextColor3 = Color3.fromRGB(240, 245, 255)
            end
            toggleRunBtn.Text = "Démarrer Zone 🚀"
            toggleRunBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
        end)

        toggleRunBtn.MouseButton1Click:Connect(function()
            if not _G.BGS_Zone_Running then
                local corners = _G.BGS_Zone_Corners
                local p1 = corners[1]
                local p2 = corners[2]
                local p3 = corners[3]
                local p4 = corners[4]

                if not p1 or not p2 then
                    pcall(function()
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "Coins manquants",
                            Text = "Place au moins P1 (Haut-Gauche) et P2 (Haut-Droit).",
                            Duration = 3
                        })
                    end)
                    return
                end

                -- Auto-complétion si seulement 2 ou 3 coins placés
                if not p3 and not p4 then
                    local offset = Vector3.new(0, 0, 40)
                    p3 = p2 + offset
                    p4 = p1 + offset
                elseif not p3 then
                    p3 = p2 + (p4 - p1)
                elseif not p4 then
                    p4 = p1 + (p3 - p2)
                end

                _G.BGS_Zone_Running = true
                toggleRunBtn.Text = "Arrêter Zone ⏹️"
                toggleRunBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

                -- Lancer le quadrillage serpentine infini P1->P2 -> ZigZag -> P4/P3 -> Boucle P1
                task.spawn(function()
                    local stepDist = 6 -- Distance entre chaque ligne en studs

                    local leftEdgeDist = (p4 - p1).Magnitude
                    local rightEdgeDist = (p3 - p2).Magnitude
                    local avgEdgeDist = (leftEdgeDist + rightEdgeDist) / 2
                    local numRows = math.max(3, math.floor(avgEdgeDist / stepDist))

                    -- Génération du chemin de points
                    local waypoints = {}
                    for row = 0, numRows do
                        local t = row / numRows
                        local leftPt = p1:Lerp(p4, t)
                        local rightPt = p2:Lerp(p3, t)

                        if row % 2 == 0 then
                            table.insert(waypoints, leftPt)
                            table.insert(waypoints, rightPt)
                        else
                            table.insert(waypoints, rightPt)
                            table.insert(waypoints, leftPt)
                        end
                    end

                    -- Boucle de quadrillage infinie tant que la zone est active
                    while _G.BGS_Zone_Running and _G.BGS_AutoTake do
                        for i, targetPos in ipairs(waypoints) do
                            if not _G.BGS_Zone_Running or not _G.BGS_AutoTake then break end

                            local myChar = LocalPlayer.Character
                            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                            local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")

                            if myRoot and hum then
                                hum.WalkSpeed = _G.WalkSpeedValue or 50
                                hum:MoveTo(targetPos)

                                local moveStartTime = tick()
                                while _G.BGS_Zone_Running and _G.BGS_AutoTake do
                                    myChar = LocalPlayer.Character
                                    myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                                    if not myRoot then break end

                                    local dist = (Vector3.new(myRoot.Position.X, 0, myRoot.Position.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude
                                    if dist <= 3 then break end

                                    -- Si bloqué plus de 1.2s, téléporter au point intermédiaire
                                    if tick() - moveStartTime > 1.2 then
                                        myRoot.CFrame = CFrame.new(targetPos + Vector3.new(0, 1, 0))
                                        break
                                    end

                                    -- Collecte des pièces aux alentours pendant le déplacement
                                    local pickupFolder = workspace:FindFirstChild("RenderedPickups", true)
                                                      or workspace:FindFirstChild("Pickups", true)
                                                      or workspace:FindFirstChild("Coins", true)

                                    if pickupFolder and firetouchinterest then
                                        for _, item in ipairs(pickupFolder:GetChildren()) do
                                            local part = item:IsA("BasePart") and item or (item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildOfClass("BasePart")))
                                            if part and (part.Position - myRoot.Position).Magnitude <= 22 then
                                                pcall(function()
                                                    firetouchinterest(myRoot, part, 0)
                                                    firetouchinterest(myRoot, part, 1)
                                                end)
                                            end
                                        end
                                    end

                                    task.wait(0.03)
                                end
                            end
                        end
                        task.wait(0.05)
                    end

                    _G.BGS_Zone_Running = false
                    toggleRunBtn.Text = "Démarrer Zone 🚀"
                    toggleRunBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
                end)
            else
                _G.BGS_Zone_Running = false
                toggleRunBtn.Text = "Démarrer Zone 🚀"
                toggleRunBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
            end
        end)

        addModule(GameCol, "Saut Infini ☁️", false, function(s)
            _G.BGS_InfJump = s
            if s then
                connections.bgsInfJump = UserInputService.JumpRequest:Connect(function()
                    if _G.BGS_InfJump and LocalPlayer.Character then
                        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                    end
                end)
            else
                if connections.bgsInfJump then connections.bgsInfJump:Disconnect() end
            end
        end)
    else
        GameTitleLabel.Text = "Jeu: " .. (success and info and string.sub(info.Name, 1, 15) or "Universel")
    end
end)

-- =============================================================================
-- 7. PARAMÈTRES
-- =============================================================================
local function createKeybindSetting(name, getKeybind, setKeybind)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = SettingsCol
    btn.BackgroundColor3 = Color3.fromRGB(20, 24, 30)
    btn.BackgroundTransparency = 0.05
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.AutoButtonColor = false
    btn.Font = Enum.Font.GothamBold
    btn.Text = "  " .. name .. " : " .. (getKeybind() and getKeybind().Name or "Aucun")
    btn.TextColor3 = Color3.fromRGB(240, 245, 255)
    btn.TextSize = 10
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.ZIndex = 12

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            bindingActionName = name
            bindingBtnObject = btn
            btn.Text = "  " .. name .. " : [...]"
            btn.TextColor3 = Color3.fromRGB(0, 210, 255)
        end
    end)
end

createKeybindSetting("Touche Menu", function() return _G.MenuKeybind end, function(k) _G.MenuKeybind = k end)
createKeybindSetting("Touche Fly", function() return _G.FlyKeybind end, function(k) _G.FlyKeybind = k end)
createKeybindSetting("Touche ESP", function() return _G.ESPKeybind end, function(k) _G.ESPKeybind = k end)
createKeybindSetting("Touche AimLock", function() return _G.AimLockKeybind end, function(k) _G.AimLockKeybind = k end)
createKeybindSetting("Touche Lock Auto", function() return _G.ToggleLockKeybind end, function(k) _G.ToggleLockKeybind = k end)

-- =============================================================================
-- CONTRÔLES & DÉTECTION DES KEYBINDS
-- =============================================================================
connections.inputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if bindingActionName and input.UserInputType == Enum.UserInputType.Keyboard then
        local newKey = input.KeyCode
        if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then newKey = nil end

        if bindingActionName == "Touche Menu" then _G.MenuKeybind = newKey
        elseif bindingActionName == "Touche Fly" then _G.FlyKeybind = newKey
        elseif bindingActionName == "Touche ESP" then _G.ESPKeybind = newKey
        elseif bindingActionName == "Touche AimLock" then _G.AimLockKeybind = newKey
        elseif bindingActionName == "Touche Lock Auto" then _G.ToggleLockKeybind = newKey end

        if bindingBtnObject then
            bindingBtnObject.Text = "  " .. bindingActionName .. " : " .. (newKey and newKey.Name or "Aucun")
            bindingBtnObject.TextColor3 = Color3.fromRGB(240, 245, 255)
        end
        bindingActionName = nil
        bindingBtnObject = nil
        return
    end

    local isTyping = UserInputService:GetFocusedTextBox() ~= nil

    if not isTyping and input.UserInputType == Enum.UserInputType.Keyboard then
        if _G.MenuKeybind and input.KeyCode == _G.MenuKeybind then
            MainGui.Enabled = not MainGui.Enabled
        elseif _G.FlyKeybind and input.KeyCode == _G.FlyKeybind then
            if moduleRegistry["Fly (F)"] then moduleRegistry["Fly (F)"].Toggle() end
        elseif _G.ESPKeybind and input.KeyCode == _G.ESPKeybind then
            if moduleRegistry["ESP Tracker"] then moduleRegistry["ESP Tracker"].Toggle() end
        elseif _G.AimLockKeybind and input.KeyCode == _G.AimLockKeybind then
            if moduleRegistry["AimLock (Droit)"] then moduleRegistry["AimLock (Droit)"].Toggle() end
        elseif _G.ToggleLockKeybind and input.KeyCode == _G.ToggleLockKeybind then
            if moduleRegistry["Lock Auto (R)"] then moduleRegistry["Lock Auto (R)"].Toggle() end
        end

        local code = input.KeyCode
        if code == Enum.KeyCode.W or code == Enum.KeyCode.Z then flyInput.Forward = true end
        if code == Enum.KeyCode.S then flyInput.Backward = true end
        if code == Enum.KeyCode.A or code == Enum.KeyCode.Q then flyInput.Left = true end
        if code == Enum.KeyCode.D then flyInput.Right = true end
        if code == Enum.KeyCode.Space then flyInput.Up = true end
        if code == Enum.KeyCode.LeftShift then flyInput.Down = true end
        if code == Enum.KeyCode.LeftControl then flyInput.Boost = true end
    end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then isAiming = true end
end)

connections.inputEnded = UserInputService.InputEnded:Connect(function(input)
    local code = input.KeyCode
    if code == Enum.KeyCode.W or code == Enum.KeyCode.Z then flyInput.Forward = false end
    if code == Enum.KeyCode.S then flyInput.Backward = false end
    if code == Enum.KeyCode.A or code == Enum.KeyCode.Q then flyInput.Left = false end
    if code == Enum.KeyCode.D then flyInput.Right = false end
    if code == Enum.KeyCode.Space then flyInput.Up = false end
    if code == Enum.KeyCode.LeftShift then flyInput.Down = false end
    if code == Enum.KeyCode.LeftControl then flyInput.Boost = false end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then isAiming = false end
end)

CloseBtn.MouseButton1Click:Connect(function()
    -- Desactiver tous les modules enregistres
    for name, data in pairs(moduleRegistry) do
        if data.GetState and data.GetState() then
            pcall(function() data.Toggle(false) end)
        end
    end

    -- Forcer l'extinction de tous les flags _G
    _G.ESP_Enabled = false
    _G.MM2_ESP_Enabled = false
    _G.Noclip_Enabled = false
    _G.Speed_Enabled = false
    _G.Fly_Enabled = false
    _G.Tourniquer_Enabled = false
    _G.Ressort_Enabled = false
    _G.Run_Enabled = false
    _G.Colle_Enabled = false
    _G.Shaders_Enabled = false
    _G.AimLock_Enabled = false
    _G.ToggleLock_Enabled = false
    _G.TpKill_Enabled = false
    _G.BGS_AutoBlow = false
    _G.BGS_AutoSell = false
    _G.BGS_AutoTake = false
    _G.BGS_InfJump = false
    _G.BGS_Zone_Running = false

    -- Supprimer tout l'ESP et Highlights
    removeAllESP()
    for _, m in ipairs(_G.BGS_Zone_Markers) do
        if m then pcall(function() m:Destroy() end) end
    end
    _G.BGS_Zone_Markers = {}

    -- Nettoyer le Gun au sol
    if droppedGunHighlight then droppedGunHighlight:Destroy(); droppedGunHighlight = nil end
    if droppedGunBillboard then droppedGunBillboard:Destroy(); droppedGunBillboard = nil end

    -- Nettoyer les shaders
    for _, effect in ipairs(shaderEffects) do if effect then effect:Destroy() end end
    shaderEffects = {}

    -- Restaurer le personnage (WalkSpeed, PlatformStand, BodyVelocity)
    pcall(function()
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
                hum.PlatformStand = false
            end
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                for _, v in ipairs(root:GetChildren()) do
                    if v:IsA("BodyVelocity") or v:IsA("BodyGyro") or v:IsA("BodyAngularVelocity") then
                        v:Destroy()
                    end
                end
            end
        end
    end)

    -- Deconnecter tous les events
    for _, conn in pairs(connections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    connections = {}

    pcall(function() RunService:UnbindFromRenderStep("MizuAimLock") end)

    -- Detruire les ScreenGuis
    MainGui:Destroy()
    OverlayGui:Destroy()
end)

updateOverlay()