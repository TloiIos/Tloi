-- [[ SERVICES ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
-- [[ TẢI THƯ VIỆN UI ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "AURORA ELITE X - V104",
   LoadingTitle = "BYPASSING BAC ALPHA-3B...",
   ConfigurationSaving = { Enabled = false }
})

-- [[ KHỞI TẠO BIẾN TOÀN CỤC ]]
_G.Skeleton_ESP = false
_G.HealthBar_ESP = false
_G.Distance_ESP = false
_G.NoFlash_Enabled = false
_G.NoSmoke_Enabled = false
_G.Aimbot_Enabled = false
_G.NoRecoil_Enabled = false
_G.Aimbot_FOV = 250
_G.CamFOV = 70
_G.CamHeight = 0 -- Biến mới cho Camera Cao
_G.Aim_Smoothness = 0.15
_G.BoxESP_Active = false
_G.Tracers_Enabled = false
_G.FPS_Boost_Enabled = false
local Cache = {}



local function GetSafeHum(player)
    local char = player.Character
    return char and char:FindFirstChildOfClass("Humanoid") or nil
end

local function CreateDrawing(type, properties)
    local d = Drawing.new(type)
    for i, v in pairs(properties) do d[i] = v end
    return d
end

local function CreateESP(p)
    if Cache[p] then return end
    Cache[p] = {
        Box = CreateDrawing("Square", {Thickness = 1, Filled = false, Color = Color3.new(1,1,1)}),
        Line = CreateDrawing("Line", {Thickness = 1, Color = Color3.new(1,1,1)}),
        Skeleton = {
            HeadTorso = CreateDrawing("Line", {Thickness = 1.5, Color = Color3.new(1,1,1)}),
        },
        HealthBarOutline = CreateDrawing("Square", {Thickness = 1, Filled = true, Color = Color3.new(0,0,0)}),
        HealthBar = CreateDrawing("Square", {Thickness = 1, Filled = true, Color = Color3.new(0,1,0)}),
        DistanceText = CreateDrawing("Text", {Size = 14, Center = true, Outline = true, Color = Color3.new(1,1,1)})
    }
end

-- [[ SCANNER CORE ]]
local Scanner = { EnemyFolder = nil }
function Scanner:GetFolder()
    pcall(function()
        local groups = {"Terrorists", "Counter-Terrorists", "T", "CT", "Police", "Criminals"}
        for _, n in pairs(groups) do
            local f = workspace:FindFirstChild(n, true)
            if f and (f:IsA("Folder") or f:IsA("Model")) then
                if not LocalPlayer.Character or not LocalPlayer.Character:IsDescendantOf(f) then
                    self.EnemyFolder = f
                end
            end
        end
    end)
end

function Scanner:IsEnemy(p)
    local hum = GetSafeHum(p)
    if not p or p == LocalPlayer or not p.Character or not hum or hum.Health <= 0 then return false end
    if self.EnemyFolder and p.Character:IsDescendantOf(self.EnemyFolder) then return true end
    return p.TeamColor ~= LocalPlayer.TeamColor
end

-- [[ XỬ LÝ NO FLASH & SMOKE ]]
task.spawn(function()
    while task.wait(1) do
        if _G.NoFlash_Enabled then
            pcall(function()
                local flash = LocalPlayer.PlayerGui:FindFirstChild("FlashbangGui", true) 
                if flash then flash.Enabled = false end
            end)
        end
        if _G.NoSmoke_Enabled then
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("ParticleEmitter") and (v.Name:find("Smoke") or v.Name:find("VoxelSmoke")) then
                        v.Enabled = false
                    end
                end
            end)
        end
    end
end)

-- [[ MAIN LOOP ]]
RunService.RenderStepped:Connect(function()
    local Center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local myHum = GetSafeHum(LocalPlayer)
    local SelfAlive = myHum and myHum.Health > 0
    local mousePos = UserInputService:GetMouseLocation()
    
    local BestTarget = nil
    local ClosestMag = _G.Aimbot_FOV

    -- Xử lý FOV và Camera Cao
    Camera.FieldOfView = _G.CamFOV
    if _G.CamHeight ~= 0 and SelfAlive then
        Camera.CFrame = Camera.CFrame * CFrame.new(0, _G.CamHeight, 0)
    end

    -- No Recoil logic giữ nguyên
    if _G.NoRecoil_Enabled then
        pcall(function()
            for _, v in pairs(getgc(true)) do
                if type(v) == "table" and rawget(v, "Recoil") then
                    v.Recoil = 0
                    v.Spread = 0
                end
            end
        end)
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not Cache[p] then CreateESP(p) end
        
        local vis = Cache[p]
        local char = p.Character
        local isEnemy = Scanner:IsEnemy(p)

        if isEnemy and char and char:FindFirstChild("Head") and char:FindFirstChild("HumanoidRootPart") then
            local head = char.Head
            local root = char.HumanoidRootPart
            local hum = char:FindFirstChildOfClass("Humanoid")
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            local dist = (Camera.CFrame.Position - root.Position).Magnitude

            -- Kiểm tra vật cản (Visible Check)
            local rp = RaycastParams.new()
            rp.FilterDescendantsInstances = {LocalPlayer.Character, Camera, char}
            rp.FilterType = Enum.RaycastFilterType.Exclude
            local ray = workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * dist, rp)
            local isVisible = not ray

            -- [AIMBOT 360 LOGIC] - Ghim chặt mục tiêu gần tâm nhất
            if _G.Aimbot_Enabled and isVisible then
                local mag = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if mag < ClosestMag then
                    BestTarget = head
                    ClosestMag = mag
                end
            end

            -- [ESP LOGIC] - Giữ nguyên bộ ESP Full
            if onScreen then
                local color = isVisible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                local sizeY = 4500 / pos.Z
                local sizeX = 2800 / pos.Z
                
                vis.Box.Visible = _G.BoxESP_Active
                vis.Box.Color = color
                vis.Box.Position = Vector2.new(pos.X - sizeX/2, pos.Y - sizeY/2)
                vis.Box.Size = Vector2.new(sizeX, sizeY)

                vis.Line.Visible = _G.Tracers_Enabled
                vis.Line.From = Vector2.new(Center.X, Camera.ViewportSize.Y)
                vis.Line.To = Vector2.new(pos.X, pos.Y + sizeY/2)
                vis.Line.Color = color

                if _G.HealthBar_ESP and hum then
                    vis.HealthBarOutline.Visible = true
                    vis.HealthBarOutline.Position = Vector2.new(pos.X - (sizeX/2) - 6, pos.Y - (sizeY/2))
                    vis.HealthBarOutline.Size = Vector2.new(4, sizeY)
                    vis.HealthBar.Visible = true
                    vis.HealthBar.Position = vis.HealthBarOutline.Position
                    vis.HealthBar.Size = Vector2.new(4, sizeY * (hum.Health / hum.MaxHealth))
                    vis.HealthBar.Color = Color3.fromHSV(hum.Health/100 * 0.3, 1, 1)
                else
                    vis.HealthBar.Visible = false
                    vis.HealthBarOutline.Visible = false
                end

                if _G.Skeleton_ESP and char:FindFirstChild("UpperTorso") then
                    local torsoV = Camera:WorldToViewportPoint(char.UpperTorso.Position)
                    vis.Skeleton.HeadTorso.Visible = true
                    vis.Skeleton.HeadTorso.From = Vector2.new(pos.X, pos.Y)
                    vis.Skeleton.HeadTorso.To = Vector2.new(torsoV.X, torsoV.Y)
                    vis.Skeleton.HeadTorso.Color = color
                else
                    vis.Skeleton.HeadTorso.Visible = false
                end

                vis.DistanceText.Visible = _G.Distance_ESP
                vis.DistanceText.Position = Vector2.new(pos.X, pos.Y + sizeY/2 + 5)
                vis.DistanceText.Text = math.floor(dist) .. "m"
            else
                -- Ẩn ESP khi không onScreen
                vis.Box.Visible = false
                vis.Line.Visible = false
                vis.Skeleton.HeadTorso.Visible = false
                vis.HealthBar.Visible = false
                vis.HealthBarOutline.Visible = false
                vis.DistanceText.Visible = false
            end
        else
            -- Ẩn hoàn toàn khi không hợp lệ
            if vis then
                vis.Box.Visible = false
                vis.Line.Visible = false
                vis.Skeleton.HeadTorso.Visible = false
                vis.HealthBar.Visible = false
                vis.HealthBarOutline.Visible = false
                vis.DistanceText.Visible = false
            end
        end
    end

    -- [GHIM CHẶT AIMBOT]
    if BestTarget and _G.Aimbot_Enabled and SelfAlive then
        local tPos = Camera:WorldToViewportPoint(BestTarget.Position)
        -- Sử dụng lerp nhẹ hoặc trực tiếp tùy smoothness để ghim chặt
        local moveX = (tPos.X - mousePos.X) * (1 - _G.Aim_Smoothness)
        local moveY = (tPos.Y - mousePos.Y) * (1 - _G.Aim_Smoothness)
        mousemoverel(moveX, moveY)
    end
end)


local Combat = Window:CreateTab("Combat", 4483345998)
Combat:CreateToggle({Name = "Aimbot 360° Ghim", CurrentValue = false, Callback = function(v) _G.Aimbot_Enabled = v end})
Combat:CreateSlider({Name = "Aimbot Radius (FOV)", Range = {50, 2000}, Increment = 50, CurrentValue = 250, Callback = function(v) _G.Aimbot_FOV = v end})
Combat:CreateSlider({Name = "Aim Smoothness (0 = Ghim Cứng)", Range = {0, 0.9}, Increment = 0.05, CurrentValue = 0.1, Callback = function(v) _G.Aim_Smoothness = v end})
Combat:CreateToggle({Name = "No Recoil / Spread", CurrentValue = false, Callback = function(v) _G.NoRecoil_Enabled = v end})

local Extra = Window:CreateTab("Extra", 4483345998)
Extra:CreateSlider({Name = "Camera Cao (Height)", Range = {0, 50}, Increment = 1, CurrentValue = 0, Callback = function(v) _G.CamHeight = v end})
Extra:CreateSlider({Name = "Field of View", Range = {70, 90}, Increment = 1, CurrentValue = 70, Callback = function(v) _G.CamFOV = v end})
Extra:CreateToggle({Name = "No Flash", CurrentValue = false, Callback = function(v) _G.NoFlash_Enabled = v end})
Extra:CreateToggle({Name = "No Smoke", CurrentValue = false, Callback = function(v) _G.NoSmoke_Enabled = v end})

local Visual = Window:CreateTab("Visuals", 4483345998)
Visual:CreateToggle({Name = "Box ESP", CurrentValue = false, Callback = function(v) _G.BoxESP_Active = v end})
Visual:CreateToggle({Name = "Tracers", CurrentValue = false, Callback = function(v) _G.Tracers_Enabled = v end})
Visual:CreateToggle({Name = "Skeleton ESP", CurrentValue = false, Callback = function(v) _G.Skeleton_ESP = v end})
Visual:CreateToggle({Name = "Health Bar", CurrentValue = false, Callback = function(v) _G.HealthBar_ESP = v end})
Visual:CreateToggle({Name = "Distance Info", CurrentValue = false, Callback = function(v) _G.Distance_ESP = v end})

task.spawn(function() while true do Scanner:GetFolder() task.wait(5) end end)
Rayfield:Notify({Title = "AURORA ELITE X", Content = "V104: Tối ưu Aimbot 360 & Cam Height!", Duration = 5}) 
