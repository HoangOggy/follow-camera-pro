--[[ 
    Follow Player Camera Script by HoangOggy
    Safe List + Drag FIXED
    
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI Root
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- ================= DRAG SYSTEM (FIXED) =================
local function enableDrag(frame)
    local dragging = false
    local dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    frame.InputChanged:Connect(function(input)
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
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,180,0,145)
main.Position = UDim2.new(0,30,1,-190)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)
enableDrag(main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,30)
title.Text = "🎯 Follow Camera"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

local function newBtn(text,y,color)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(1,-20,0,32)
    b.Position = UDim2.new(0,10,0,y)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = color
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    return b
end

local followBtn = newBtn("Enable Follow",40,Color3.fromRGB(0,140,255))
local safeBtn   = newBtn("Safe List",78,Color3.fromRGB(80,80,80))

-- ================= SAFE GUI =================
local safeGui = Instance.new("Frame", gui)
safeGui.Size = UDim2.new(0,220,0,260)
safeGui.Position = UDim2.new(0,220,1,-300)
safeGui.BackgroundColor3 = Color3.fromRGB(25,25,25)
safeGui.Visible = false
Instance.new("UICorner", safeGui).CornerRadius = UDim.new(0,14)
enableDrag(safeGui)

local safeTitle = Instance.new("TextLabel", safeGui)
safeTitle.Size = UDim2.new(1,0,0,30)
safeTitle.Text = "🛡 Safe List"
safeTitle.Font = Enum.Font.GothamBold
safeTitle.TextSize = 15
safeTitle.TextColor3 = Color3.new(1,1,1)
safeTitle.BackgroundTransparency = 1

local list = Instance.new("ScrollingFrame", safeGui)
list.Position = UDim2.new(0,6,0,35)
list.Size = UDim2.new(1,-12,1,-75)
list.ScrollBarThickness = 4
list.CanvasSize = UDim2.new()
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

-- ================= LOGIC =================
local following = false
local holding = false
local target = nil
local safeList = {}

local function refreshPlayers()
    for _,v in ipairs(list:GetChildren()) do
        if v:IsA("TextButton") then
            v:Destroy()
        end
    end

    RunService.Heartbeat:Wait()

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local b = Instance.new("TextButton", list)
            b.Size = UDim2.new(1,-4,0,28)
            b.Text = plr.Name
            b.Font = Enum.Font.Gotham
            b.TextSize = 13
            b.TextColor3 = Color3.new(1,1,1)
            b.BackgroundColor3 = safeList[plr.UserId] and Color3.fromRGB(0,150,80) or Color3.fromRGB(50,50,50)
            Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)

            b.MouseButton1Click:Connect(function()
                safeList[plr.UserId] = not safeList[plr.UserId]
                b.BackgroundColor3 = safeList[plr.UserId] and Color3.fromRGB(0,150,80) or Color3.fromRGB(50,50,50)
            end)
        end
    end

    task.wait()
    list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 8)
end

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

UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and following then
        holding = true
        local mouse = UIS:GetMouseLocation()
        local best, dist = nil, math.huge

        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and not safeList[plr.UserId]
            and plr.Character and plr.Character:FindFirstChild("Head") then
                local p, vis = Camera:WorldToScreenPoint(plr.Character.Head.Position)
                if vis then
                    local d = (Vector2.new(p.X,p.Y) - mouse).Magnitude
                    if d < dist then
                        dist = d
                        best = plr
                    end
                end
            end
        end
        target = best
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holding = false
        target = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if holding and target and target.Character then
        local h = target.Character:FindFirstChild("Head")
        if h then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, h.Position)
        end
    end
end)
