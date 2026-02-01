--[[ 
    Follow Player Camera Script
    + Safe List System (FIXED)
    Made by HoangOggy (fixed & upgraded)
]]

-- ================= SERVICES =================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================= GUI ROOT =================
local gui = Instance.new("ScreenGui")
gui.Name = "FollowPlayerUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- ================= DRAG FUNCTION =================
local function makeDraggable(frame)
    local dragging, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ================= MAIN GUI =================
local main = Instance.new("Frame")
main.Size = UDim2.new(0,180,0,145)
main.Position = UDim2.new(0,30,1,-190)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.BackgroundTransparency = 0.1
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)
makeDraggable(main)

-- Shadow
local shadow = Instance.new("Frame")
shadow.Size = main.Size + UDim2.new(0,10,0,10)
shadow.Position = main.Position + UDim2.new(0,5,0,5)
shadow.BackgroundColor3 = Color3.new(0,0,0)
shadow.BackgroundTransparency = 0.5
shadow.ZIndex = main.ZIndex - 1
shadow.Parent = gui
Instance.new("UICorner", shadow).CornerRadius = UDim.new(0,14)

-- Sync shadow
RunService.RenderStepped:Connect(function()
    shadow.Position = main.Position + UDim2.new(0,5,0,5)
end)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-10,0,30)
title.Position = UDim2.new(0,5,0,5)
title.BackgroundTransparency = 1
title.Text = "🎯 Follow Camera"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)
title.Parent = main

-- Button creator
local function createBtn(text, y, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-20,0,32)
    b.Position = UDim2.new(0,10,0,y)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = color
    b.Parent = main
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    return b
end

local followBtn = createBtn("Enable Follow",40,Color3.fromRGB(0,140,255))
local safeBtn   = createBtn("Safe List",78,Color3.fromRGB(90,90,90))

-- Minimize
local miniBtn = Instance.new("TextButton")
miniBtn.Size = UDim2.new(0,28,0,28)
miniBtn.Position = UDim2.new(1,-33,0,5)
miniBtn.Text = "-"
miniBtn.Font = Enum.Font.GothamBold
miniBtn.TextSize = 18
miniBtn.TextColor3 = Color3.new(1,1,1)
miniBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
miniBtn.Parent = main
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0,8)

-- ================= SAFE LIST GUI =================
local safeGui = Instance.new("Frame")
safeGui.Size = UDim2.new(0,220,0,260)
safeGui.Position = UDim2.new(0,220,1,-300)
safeGui.BackgroundColor3 = Color3.fromRGB(25,25,25)
safeGui.Visible = false
safeGui.Parent = gui
Instance.new("UICorner", safeGui).CornerRadius = UDim.new(0,14)
makeDraggable(safeGui)

local safeTitle = Instance.new("TextLabel")
safeTitle.Size = UDim2.new(1,0,0,30)
safeTitle.Text = "🛡 Safe List Players"
safeTitle.Font = Enum.Font.GothamBold
safeTitle.TextSize = 15
safeTitle.TextColor3 = Color3.new(1,1,1)
safeTitle.BackgroundTransparency = 1
safeTitle.Parent = safeGui

local list = Instance.new("ScrollingFrame")
list.Position = UDim2.new(0,6,0,35)
list.Size = UDim2.new(1,-12,1,-75)
list.CanvasSize = UDim2.new(0,0,0,0)
list.ScrollBarThickness = 4
list.BackgroundTransparency = 1
list.Parent = safeGui

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(1,-20,0,30)
refreshBtn.Position = UDim2.new(0,10,1,-35)
refreshBtn.Text = "🔄 Refresh Players"
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 13
refreshBtn.TextColor3 = Color3.new(1,1,1)
refreshBtn.BackgroundColor3 = Color3.fromRGB(60,120,255)
refreshBtn.Parent = safeGui
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0,10)

-- ================= STATES =================
local following = false
local holdingRight = false
local targetPlayer = nil
local safeList = {} -- [UserId] = true

-- ================= SAFE LIST FUNCTION =================
local function refreshPlayers()
    list:ClearAllChildren()

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,6)
    layout.Parent = list

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,-4,0,28)
            btn.Text = plr.Name
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 13
            btn.TextColor3 = Color3.new(1,1,1)
            btn.BackgroundColor3 =
                safeList[plr.UserId]
                and Color3.fromRGB(0,150,80)
                or Color3.fromRGB(50,50,50)

            btn.Parent = list
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

            btn.MouseButton1Click:Connect(function()
                safeList[plr.UserId] = not safeList[plr.UserId]
                btn.BackgroundColor3 =
                    safeList[plr.UserId]
                    and Color3.fromRGB(0,150,80)
                    or Color3.fromRGB(50,50,50)
            end)
        end
    end

    task.wait()
    list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 8)
end

-- ================= BUTTON EVENTS =================
followBtn.MouseButton1Click:Connect(function()
    following = not following
    followBtn.Text = following and "Disable Follow" or "Enable Follow"
    followBtn.BackgroundColor3 =
        following and Color3.fromRGB(220,60,60)
        or Color3.fromRGB(0,140,255)
end)

safeBtn.MouseButton1Click:Connect(function()
    safeGui.Visible = not safeGui.Visible
    if safeGui.Visible then
        refreshPlayers()
    end
end)

refreshBtn.MouseButton1Click:Connect(refreshPlayers)

-- ================= TARGET DETECT =================
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and following then
        holdingRight = true
        local mousePos = UserInputService:GetMouseLocation()
        local closest, dist = nil, math.huge

        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer
            and not safeList[plr.UserId]
            and plr.Character
            and plr.Character:FindFirstChild("Head") then

                local pos, visible = Camera:WorldToScreenPoint(plr.Character.Head.Position)
                if visible then
                    local d = (Vector2.new(pos.X,pos.Y) - mousePos).Magnitude
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

-- ================= CAMERA FOLLOW =================
RunService.RenderStepped:Connect(function()
    if holdingRight and targetPlayer and targetPlayer.Character then
        local head = targetPlayer.Character:FindFirstChild("Head")
        if head then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
        end
    end
end)
