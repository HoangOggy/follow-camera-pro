--[[ 
    Follow Player Camera Script
    Upgraded UI Version
    Made by HoangOggy
]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- GUI Root
local gui = Instance.new("ScreenGui")
gui.Name = "FollowPlayerUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- Main Frame
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 180, 0, 110)
main.Position = UDim2.new(0, 30, 1, -150)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BackgroundTransparency = 0.1
main.Parent = gui

-- Corner
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

-- Shadow
local shadow = Instance.new("Frame")
shadow.Size = main.Size + UDim2.new(0, 10, 0, 10)
shadow.Position = main.Position + UDim2.new(0, 5, 0, 5)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.5
shadow.ZIndex = main.ZIndex - 1
shadow.Parent = gui
Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 14)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 0, 30)
title.Position = UDim2.new(0, 5, 0, 5)
title.BackgroundTransparency = 1
title.Text = "🎯 Follow Camera"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = main

-- Follow Button
local followBtn = Instance.new("TextButton")
followBtn.Size = UDim2.new(1, -20, 0, 35)
followBtn.Position = UDim2.new(0, 10, 0, 40)
followBtn.Text = "Enable Follow"
followBtn.Font = Enum.Font.GothamBold
followBtn.TextSize = 14
followBtn.TextColor3 = Color3.fromRGB(255,255,255)
followBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
followBtn.Parent = main
Instance.new("UICorner", followBtn).CornerRadius = UDim.new(0, 10)

-- Minimize Button
local miniBtn = Instance.new("TextButton")
miniBtn.Size = UDim2.new(0, 28, 0, 28)
miniBtn.Position = UDim2.new(1, -33, 0, 5)
miniBtn.Text = "-"
miniBtn.Font = Enum.Font.GothamBold
miniBtn.TextSize = 18
miniBtn.TextColor3 = Color3.fromRGB(255,255,255)
miniBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
miniBtn.Parent = main
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 8)

-- Gradient Button
local grad = Instance.new("UIGradient", followBtn)
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,180,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0,90,160))
}

-- States
local following = false
local minimized = false
local holdingRight = false
local targetPlayer = nil

-- Toggle Follow
followBtn.MouseButton1Click:Connect(function()
    following = not following
    if following then
        followBtn.Text = "Disable Follow"
        followBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    else
        followBtn.Text = "Enable Follow"
        followBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    end
end)

-- Minimize
miniBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(
        main,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad),
        {Size = minimized and UDim2.new(0,180,0,40) or UDim2.new(0,180,0,110)}
    ):Play()
end)

-- Drag System
local dragging, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    main.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
    shadow.Position = main.Position + UDim2.new(0,5,0,5)
end

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateDrag(input)
    end
end)

-- Right Click Detect Target
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and following then
        holdingRight = true
        local mousePos = UserInputService:GetMouseLocation()
        local closest, dist = nil, math.huge

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local pos, visible = Camera:WorldToScreenPoint(plr.Character.Head.Position)
                if visible then
                    local d = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if d < dist then
                        dist = d
                        closest = plr
                    end
                end
            end
        end
        targetPlayer = closest
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holdingRight = false
        targetPlayer = nil
    end
end)

-- Camera Follow
RunService.RenderStepped:Connect(function()
    if holdingRight and targetPlayer and targetPlayer.Character then
        local head = targetPlayer.Character:FindFirstChild("Head")
        if head then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
        end
    end
end)

