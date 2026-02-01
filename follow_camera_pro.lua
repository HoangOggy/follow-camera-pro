--[[ 
    Follow Player Camera Script By HoangOggy
    Safe List + Search + Hotkey GUI
]]

-- ================= SERVICES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================= SAVE =================
local SAVE_FILE = "FollowCamera_SafeList.json"
local safeList = {}

local function loadSafe()
    if isfile and isfile(SAVE_FILE) then
        safeList = HttpService:JSONDecode(readfile(SAVE_FILE))
    end
end

local function saveSafe()
    if writefile then
        writefile(SAVE_FILE, HttpService:JSONEncode(safeList))
    end
end

loadSafe()

-- ================= GUI ROOT =================
local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
gui.ResetOnSpawn = false

-- ================= DRAG =================
local function enableDrag(frame)
    local dragging, dragStart, startPos = false

    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = frame.Position
        end
    end)

    frame.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    frame.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

-- ================= MAIN GUI =================
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,190,0,185)
main.Position = UDim2.new(0,30,1,-230)
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

-- 🔑 Hotkey UI
local hotkeyBox = Instance.new("TextBox", main)
hotkeyBox.Size = UDim2.new(1,-20,0,30)
hotkeyBox.Position = UDim2.new(0,10,0,118)
hotkeyBox.Text = "Hotkey: F"
hotkeyBox.Font = Enum.Font.GothamBold
hotkeyBox.TextSize = 13
hotkeyBox.TextColor3 = Color3.new(1,1,1)
hotkeyBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
hotkeyBox.ClearTextOnFocus = true
Instance.new("UICorner", hotkeyBox).CornerRadius = UDim.new(0,10)

-- ================= SAFE GUI =================
local safeGui = Instance.new("Frame", gui)
safeGui.Size = UDim2.new(0,230,0,300)
safeGui.Position = UDim2.new(0,240,1,-340)
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

-- 🔍 Search box
local searchBox = Instance.new("TextBox", safeGui)
searchBox.Size = UDim2.new(1,-20,0,28)
searchBox.Position = UDim2.new(0,10,0,32)
searchBox.PlaceholderText = "🔍 Search player..."
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 13
searchBox.TextColor3 = Color3.new(1,1,1)
searchBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0,8)

local list = Instance.new("ScrollingFrame", safeGui)
list.Position = UDim2.new(0,6,0,65)
list.Size = UDim2.new(1,-12,1,-105)
list.ScrollBarThickness = 4
list.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,6)

local refreshBtn = Instance.new("TextButton", safeGui)
refreshBtn.Size = UDim2.new(1,-20,0,30)
refreshBtn.Position = UDim2.new(0,10,1,-35)
refreshBtn.Text = "🔄 Refresh"
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 13
refreshBtn.TextColor3 = Color3.new(1,1,1)
refreshBtn.BackgroundColor3 = Color3.fromRGB(60,120,255)
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0,10)

-- ================= LOGIC =================
local following = false
local holding = false
local target = nil
local followKey = Enum.KeyCode.F

local function refreshPlayers()
    for _,v in ipairs(list:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    RunService.Heartbeat:Wait()

    local filter = searchBox.Text:lower()

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if filter ~= "" and not plr.Name:lower():find(filter) then
                continue
            end

            local b = Instance.new("TextButton", list)
            b.Size = UDim2.new(1,-4,0,28)
            b.Text = plr.Name
            b.Font = Enum.Font.Gotham
            b.TextSize = 13
            b.TextColor3 = Color3.new(1,1,1)
            b.BackgroundColor3 =
                safeList[plr.UserId] and Color3.fromRGB(0,150,80)
                or Color3.fromRGB(50,50,50)
            Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)

            b.MouseButton1Click:Connect(function()
                safeList[plr.UserId] = not safeList[plr.UserId]
                saveSafe()
                b.BackgroundColor3 =
                    safeList[plr.UserId] and Color3.fromRGB(0,150,80)
                    or Color3.fromRGB(50,50,50)
            end)
        end
    end

    task.wait()
    list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 8)
end

-- ================= EVENTS =================
safeBtn.MouseButton1Click:Connect(function()
    safeGui.Visible = not safeGui.Visible
    if safeGui.Visible then refreshPlayers() end
end)

refreshBtn.MouseButton1Click:Connect(refreshPlayers)
searchBox:GetPropertyChangedSignal("Text"):Connect(refreshPlayers)

followBtn.MouseButton1Click:Connect(function()
    following = not following
    followBtn.Text = following and "Disable Follow" or "Enable Follow"
    followBtn.BackgroundColor3 =
        following and Color3.fromRGB(220,60,60)
        or Color3.fromRGB(0,140,255)
end)

-- 🔑 Change hotkey
hotkeyBox.FocusLost:Connect(function()
    local key = hotkeyBox.Text:upper()
    local code = Enum.KeyCode[key]
    if code then
        followKey = code
        hotkeyBox.Text = "Hotkey: "..key
    else
        hotkeyBox.Text = "Hotkey: "..followKey.Name
    end
end)

-- 🔑 Hotkey toggle
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == followKey then
        followBtn:Activate()
    end
end)

-- ================= FOLLOW LOGIC =================
UIS.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 and following then
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

UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
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
