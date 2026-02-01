--[[ 
    Follow Player Camera Script
    Safe List + Search + Hotkey
    Fixed Version
    Made by HoangOggy
]]

-- SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- STATES
local following = false
local holdingRight = false
local targetPlayer = nil
local safeList = {}
local hotkey = Enum.KeyCode.F
local waitingForKey = false

--------------------------------------------------
-- GUI ROOT
--------------------------------------------------
local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
gui.Name = "FollowCameraUI"
gui.ResetOnSpawn = false

--------------------------------------------------
-- MAIN FRAME
--------------------------------------------------
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 220, 0, 300)
main.Position = UDim2.new(0, 40, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

--------------------------------------------------
-- TITLE
--------------------------------------------------
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "🎯 Follow Camera"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

--------------------------------------------------
-- FOLLOW BUTTON
--------------------------------------------------
local followBtn = Instance.new("TextButton", main)
followBtn.Size = UDim2.new(1,-20,0,32)
followBtn.Position = UDim2.new(0,10,0,40)
followBtn.Text = "Follow: OFF"
followBtn.Font = Enum.Font.GothamBold
followBtn.TextSize = 14
followBtn.TextColor3 = Color3.new(1,1,1)
followBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
Instance.new("UICorner", followBtn).CornerRadius = UDim.new(0,8)

--------------------------------------------------
-- HOTKEY BUTTON
--------------------------------------------------
local hotkeyBtn = Instance.new("TextButton", main)
hotkeyBtn.Size = UDim2.new(1,-20,0,28)
hotkeyBtn.Position = UDim2.new(0,10,0,80)
hotkeyBtn.Text = "Hotkey: F"
hotkeyBtn.Font = Enum.Font.Gotham
hotkeyBtn.TextSize = 13
hotkeyBtn.TextColor3 = Color3.new(1,1,1)
hotkeyBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", hotkeyBtn).CornerRadius = UDim.new(0,8)

--------------------------------------------------
-- SEARCH BOX
--------------------------------------------------
local searchBox = Instance.new("TextBox", main)
searchBox.Size = UDim2.new(1,-20,0,26)
searchBox.Position = UDim2.new(0,10,0,120)
searchBox.PlaceholderText = "Search player..."
searchBox.Text = ""
searchBox.TextColor3 = Color3.new(1,1,1)
searchBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
searchBox.ClearTextOnFocus = false
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0,8)

--------------------------------------------------
-- PLAYER LIST
--------------------------------------------------
local listFrame = Instance.new("ScrollingFrame", main)
listFrame.Size = UDim2.new(1,-20,0,130)
listFrame.Position = UDim2.new(0,10,0,155)
listFrame.CanvasSize = UDim2.new(0,0,0,0)
listFrame.ScrollBarThickness = 6
listFrame.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", listFrame)
layout.Padding = UDim.new(0,6)

--------------------------------------------------
-- FUNCTIONS
--------------------------------------------------
local function toggleFollow()
    following = not following
    followBtn.Text = following and "Follow: ON" or "Follow: OFF"
    followBtn.BackgroundColor3 = following and Color3.fromRGB(60,200,100) or Color3.fromRGB(200,60,60)
end

followBtn.MouseButton1Click:Connect(toggleFollow)

hotkeyBtn.MouseButton1Click:Connect(function()
    waitingForKey = true
    hotkeyBtn.Text = "Press a key..."
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end

    if waitingForKey and input.KeyCode ~= Enum.KeyCode.Unknown then
        hotkey = input.KeyCode
        hotkeyBtn.Text = "Hotkey: "..hotkey.Name
        waitingForKey = false
        return
    end

    if input.KeyCode == hotkey then
        toggleFollow()
    end

    if input.UserInputType == Enum.UserInputType.MouseButton2 and following then
        holdingRight = true
        local mousePos = UIS:GetMouseLocation()
        local closest, dist = nil, math.huge

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                if not safeList[plr.Name] then
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
        end
        targetPlayer = closest
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holdingRight = false
        targetPlayer = nil
    end
end)

--------------------------------------------------
-- CAMERA FOLLOW
--------------------------------------------------
RunService.RenderStepped:Connect(function()
    if holdingRight and targetPlayer and targetPlayer.Character then
        local head = targetPlayer.Character:FindFirstChild("Head")
        if head then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
        end
    end
end)

--------------------------------------------------
-- PLAYER LIST UPDATE
--------------------------------------------------
local function refreshList()
    for _, v in ipairs(listFrame:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if searchBox.Text == "" or plr.Name:lower():find(searchBox.Text:lower()) then
                local btn = Instance.new("TextButton", listFrame)
                btn.Size = UDim2.new(1,-5,0,28)
                btn.Text = plr.Name .. (safeList[plr.Name] and " [SAFE]" or "")
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 13
                btn.TextColor3 = Color3.new(1,1,1)
                btn.BackgroundColor3 = safeList[plr.Name] and Color3.fromRGB(80,120,80) or Color3.fromRGB(50,50,50)
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

                btn.MouseButton1Click:Connect(function()
                    safeList[plr.Name] = not safeList[plr.Name]
                    refreshList()
                end)
            end
        end
    end

    task.wait()
    listFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 5)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(refreshList)
Players.PlayerAdded:Connect(refreshList)
Players.PlayerRemoving:Connect(refreshList)

refreshList()
