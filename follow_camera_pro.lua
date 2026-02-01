--[[ 
    Follow Player Camera Script
    + Safe List System
    Upgraded UI Version
    Made by HoangOggy (edited)
]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ================= GUI ROOT =================
local gui = Instance.new("ScreenGui")
gui.Name = "FollowPlayerUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- ================= MAIN =================
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 180, 0, 145)
main.Position = UDim2.new(0, 30, 1, -190)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BackgroundTransparency = 0.1
main.Parent = gui
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

-- ================= BUTTONS =================
local function createBtn(text, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 32)
    b.Position = UDim2.new(0, 10, 0, y)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.BackgroundColor3 = Color3.fromRGB(70,70,70)
    b.Parent = main
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    return b
end

local followBtn = createBtn("Enable Follow", 40)
followBtn.BackgroundColor3 = Color3.fromRGB(0,140,255)

local safeBtn = createBtn("Safe List", 78)
safeBtn.BackgroundColor3 = Color3.fromRGB(90,90,90)

-- Minimize
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

-- ================= STATES =================
local following = false
local holdingRight = false
local targetPlayer = nil
local safeList = {} -- [UserId] = true

-- ================= SAFE LIST GUI =================
local safeGui = Instance.new("Frame", gui)
safeGui.Size = UDim2.new(0, 220, 0, 260)
safeGui.Position = UDim2.new(0, 220, 1, -300)
safeGui.BackgroundColor3 = Color3.fromRGB(25,25,25)
safeGui.Visible = false
Instance.new("UICorner", safeGui).CornerRadius = UDim.new(0, 14)

local safeTitle = Instance.new("TextLabel", safeGui)
safeTitle.Size = UDim2.new(1,0,0,30)
safeTitle.Text = "🛡 Safe List Players"
safeTitle.Font = Enum.Font.GothamBold
safeTitle.TextSize = 15
safeTitle.TextColor3 = Color3.new(1,1,1)
safeTitle.BackgroundTransparency = 1

local list = Instance.new("ScrollingFrame", safeGui)
list.Position = UDim2.new(0,5,0,35)
list.Size = UDim2.new(1,-10,1,-75)
list.CanvasSize = UDim2.new(0,0,0,0)
list.ScrollBarThickness = 4
list.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,6)

local refreshBtn = Instance.new("TextButton", safeGui)
refreshBtn.Size = UDim2.new(1,-20,0,30)
refreshBtn.Position = UDim2.new(0,10,1,-35)
refreshBtn.Text = "🔄 Refresh Players"
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 13
refreshBtn.TextColor3 = Color3.new(1,1,1)
refreshBtn.BackgroundColor3 = Color3.fromRGB(60,120,255)
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0,10)

-- ================= FUNCTIONS =================
local function refreshPlayers()
    list:ClearAllChildren()
    layout.Parent = list

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -4, 0, 28)
            b.Text = plr.Name
            b.Font = Enum.Font.Gotham
            b.TextSize = 13
            b.TextColor3 = Color3.new(1,1,1)
            b.BackgroundColor3 = safeList[plr.UserId] and Color3.fromRGB(0,150,80) or Color3.fromRGB(50,50,50)
            b.Parent = list
            Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)

            b.MouseButton1Click:Connect(function()
                safeList[plr.UserId] = not safeList[plr.UserId]
                b.BackgroundColor3 = safeList[plr.UserId] and Color3.fromRGB(0,150,80) or Color3.fromRGB(50,50,50)
            end)
        end
    end

    task.wait()
    list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 5)
end

-- ================= EVENTS =================
followBtn.MouseButton1Click:Connect(function()
    following = not following
    followBtn.Text = following and "Disable Follow" or "Enable Follow"
    followBtn.BackgroundColor3 = following and Color3.fromRGB(220,60,60) or Color3.fromRGB(0,140,255)
end)

safeBtn.MouseButton1Click:Connect(function()
    safeGui.Visible = not safeGui.Visible
    if safeGui.Visible then
        refreshPlayers()
    end
end)

refreshBtn.MouseButton1Click:Connect(refreshPlayers)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and following then
        holdingRight = true
        local mousePos = UserInputService:GetMouseLocation()
        local closest, dist = nil, math.huge

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer
            and not safeList[plr.UserId]
            and plr.Character
            and plr.Character:FindFirstChild("Head") then

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

RunService.RenderStepped:Connect(function()
    if holdingRight and targetPlayer and targetPlayer.Character then
        local head = targetPlayer.Character:FindFirstChild("Head")
        if head then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
        end
    end
end)
