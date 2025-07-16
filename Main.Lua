local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "PeléHub"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 420)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
frame.BackgroundTransparency = 0.3

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Pelé Hub 👑"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1

local crown = Instance.new("ImageLabel", frame)
crown.Size = UDim2.new(0, 40, 0, 40)
crown.Position = UDim2.new(0.5, -20, 0, -45)
crown.BackgroundTransparency = 1
crown.Image = "rbxassetid://7483871526"
local angle = 0
RunService.RenderStepped:Connect(function()
    angle = (angle + 2) % 360
    crown.Rotation = angle
end)

local minimized = false
local minimizeButton = Instance.new("TextButton", frame)
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -35, 0, 0)
minimizeButton.Text = "🔽"
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.TextSize = 20
minimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minimizeButton.TextColor3 = Color3.new(1,1,1)

minimizeButton.MouseButton1Click:Connect(function()
    minimized = true
    frame.Visible = false
    local restore = Instance.new("TextButton", gui)
    restore.Size = UDim2.new(0,160,0,40)
    restore.Position = UDim2.new(0,10,0,10)
    restore.Text = "Pelé Hub 👑"
    restore.Font = Enum.Font.SourceSansBold
    restore.TextSize = 20
    restore.BackgroundColor3 = Color3.fromRGB(0,128,255)
    restore.TextColor3 = Color3.new(1,1,1)

    local dragging, dragStart, startPos = false
    restore.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos = restore.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    restore.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = i.Position - dragStart
                restore.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
    restore.MouseButton1Click:Connect(function()
        frame.Visible = true
        minimized = false
        restore:Destroy()
    end)
end)

-- Estados globais
local flyModeEnabled = false
local flying = false
local gy, vel
local noclipConn = nil

-- Criador de botões
local y = 40
local function createToggle(name, func)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 180, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
    btn.Text = name .. ": OFF"
    y = y + 35

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.Text = name .. ": " .. (active and "ON" or "OFF")
        btn.BackgroundColor3 = active and Color3.fromRGB(0,255,128) or Color3.fromRGB(0,128,255)
        func(active)
    end)
end

-- ESP com nome
createToggle("ESP", function(state)
    for _,player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            if state then
                if not char:FindFirstChild("ESP_H") then
                    local h = Instance.new("Highlight", char)
                    h.Name = "ESP_H"
                    h.FillColor = Color3.fromRGB(255,0,0)
                    h.OutlineColor = h.FillColor
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
                local head = char:FindFirstChild("Head")
                if head and not head:FindFirstChild("ESP_Tag") then
                    local tag = Instance.new("BillboardGui", head)
                    tag.Name = "ESP_Tag"
                    tag.Size = UDim2.new(0,200,0,25)
                    tag.Adornee = head
                    tag.AlwaysOnTop = true
                    tag.StudsOffset = Vector3.new(0,2,0)
                    local label = Instance.new("TextLabel", tag)
                    label.Size = UDim2.new(1,0,1,0)
                    label.BackgroundTransparency = 1
                    label.Text = player.Name
                    label.TextColor3 = Color3.fromRGB(255,0,0)
                    label.Font = Enum.Font.SourceSansBold
                    label.TextSize = 16
                end
            else
                local h = char:FindFirstChild("ESP_H") if h then h:Destroy() end
                local head = char:FindFirstChild("Head")
                if head then
                    local tag = head:FindFirstChild("ESP_Tag") if tag then tag:Destroy() end
                end
            end
        end
    end
end)

-- GodMode
createToggle("GodMode", function(state)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Health = math.huge
        if state then
            hum:GetPropertyChangedSignal("Health"):Connect(function()
                if hum.Health < math.huge then hum.Health = math.huge end
            end)
        end
    end
end)

-- NoClip
createToggle("NoClip", function(state)
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _,v in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    end
end)

-- Velocidade
createToggle("Velocidade", function(state)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = state and 100 or 16 end
end)

-- Voo (controlado por botão de pulo)
createToggle("Voo", function(state)
    flyModeEnabled = state
end)

UserInputService.JumpRequest:Connect(function()
    if not flyModeEnabled or flying then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    flying = true
    gy = Instance.new("BodyGyro", char.HumanoidRootPart)
    gy.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    gy.P = 9e4
    vel = Instance.new("BodyVelocity", char.HumanoidRootPart)
    vel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    vel.Velocity = Vector3.new(0, 50, 0)
end)

UserInputService.InputEnded:Connect(function(i)
    if flyModeEnabled and (i.KeyCode == Enum.KeyCode.Space or i.UserInputType == Enum.UserInputType.Touch) then
        if gy then gy:Destroy() end
        if vel then vel:Destroy() end
        flying = false
    end
end)
