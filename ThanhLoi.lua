

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "AURORA ELITE X - V104",
   LoadingTitle = "BYPASSING BAC ALPHA-3B...",
   ConfigurationSaving = { Enabled = false }
})

_G.Skeleton_ESP = false
_G.HealthBar_ESP = false
_G.Distance_ESP = false
_G.NoFlash_Enabled = false
_G.NoSmoke_Enabled = false
_G.Aimbot_Enabled = false
_G.NoRecoil_Enabled = false
_G.SpeedRun_Enabled = false
_G.SpeedValue = 100
_G.Aimbot_FOV = 250
_G.CamFOV = 70
_G.Aim_Smoothness = 0.15
_G.BoxESP_Active = false
_G.Tracers_Enabled = false

-- [[ HÀM KIỂM TRA AN TOÀN - FIX LỖI CONSOLE ]]
local function GetSafeHum(player)
    local char = player.Character
    if char then
        -- Sử dụng FindFirstChildOfClass để không văng lỗi đỏ khi nhân vật đang load
        return char:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

-- [[ XỬ LÝ XÓA FLASH & SMOKE ]]
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

local Cache = {}

-- [[ HÀM TẠO DRAWING ]]
local function CreateDrawing(type, properties)
    local d = Drawing.new(type)
    for i, v in pairs(properties) do d[i] = v end
    return d
end

local function CreateESP(p)
    if Cache[p] then return end
    Cache[p] = {
        Skeleton = {
            HeadTorso = CreateDrawing("Line", {Thickness = 1.5, Color = Color3.new(1,1,1)}),
            HumToL = CreateDrawing("Line", {Thickness = 1.5, Color = Color3.new(1,1,1)}),
            HumToR = CreateDrawing("Line", {Thickness = 1.5, Color = Color3.new(1,1,1)}),
            -- Thêm các đoạn xương khác tùy ý
        },
        HealthBarOutline = CreateDrawing("Square", {Thickness = 1, Filled = true, Color = Color3.new(0,0,0)}),
        HealthBar = CreateDrawing("Square", {Thickness = 1, Filled = true, Color = Color3.new(0,1,0)}),
        DistanceText = CreateDrawing("Text", {Size = 14, Center = true, Outline = true, Color = Color3.new(1,1,1)})
    }
end

-- [[ VÒNG LẶP RENDER ]]
RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then 
            if Cache[p] then 
                -- Ẩn tất cả khi không hợp lệ
                for _, v in pairs(Cache[p].Skeleton) do v.Visible = false end
                Cache[p].HealthBar.Visible = false
                Cache[p].DistanceText.Visible = false
            end
            continue 
        end
        
        if not Cache[p] then CreateESP(p) end
        local vis = Cache[p]
        local char = p.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")

        if hum and root and head and hum.Health > 0 then
            local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local dist = (Camera.CFrame.Position - root.Position).Magnitude

            if onScreen then
                -- 1. XỬ LÝ KHOẢNG CÁCH (DISTANCE)
                vis.DistanceText.Visible = _G.Distance_ESP
                vis.DistanceText.Position = Vector2.new(rootPos.X, rootPos.Y + 20)
                vis.DistanceText.Text = math.floor(dist) .. "m"

                -- 2. XỬ LÝ THANH MÁU (HEALTHBAR)
                if _G.HealthBar_ESP then
                    local sizeY = 4500 / rootPos.Z
                    vis.HealthBarOutline.Visible = true
                    vis.HealthBarOutline.Position = Vector2.new(rootPos.X - (sizeY/4) - 5, rootPos.Y - (sizeY/2))
                    vis.HealthBarOutline.Size = Vector2.new(4, sizeY)

                    vis.HealthBar.Visible = true
                    vis.HealthBar.Position = vis.HealthBarOutline.Position
                    vis.HealthBar.Size = Vector2.new(4, sizeY * (hum.Health / hum.MaxHealth))
                    vis.HealthBar.Color = Color3.fromHSV(hum.Health/100 * 0.3, 1, 1)
                else
                    vis.HealthBar.Visible = false
                    vis.HealthBarOutline.Visible = false
                end

                -- 3. XỬ LÝ XƯƠNG (SKELETON) - Ví dụ đoạn Head đến Torso
                if _G.Skeleton_ESP and char:FindFirstChild("UpperTorso") then
                    local headV = Camera:WorldToViewportPoint(head.Position)
                    local torsoV = Camera:WorldToViewportPoint(char.UpperTorso.Position)
                    vis.Skeleton.HeadTorso.Visible = true
                    vis.Skeleton.HeadTorso.From = Vector2.new(headV.X, headV.Y)
                    vis.Skeleton.HeadTorso.To = Vector2.new(torsoV.X, torsoV.Y)
                else
                    vis.Skeleton.HeadTorso.Visible = false
                end
            else
                for _, v in pairs(vis.Skeleton) do v.Visible = false end
                vis.HealthBar.Visible = false
                vis.DistanceText.Visible = false
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local Center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local myHum = GetSafeHum(LocalPlayer)
    local SelfAlive = myHum and myHum.Health > 0
    
    -- 1. Anti-Kick FOV (Bypass Error 267)
    if _G.CamFOV > 90 then _G.CamFOV = 90 end
    Camera.FieldOfView = _G.CamFOV

    -- 2. Speed Run Logic (Bypass Mode)
    if _G.SpeedRun_Enabled and SelfAlive then
        myHum.WalkSpeed = _G.SpeedValue
    elseif SelfAlive then
        myHum.WalkSpeed = 16 
    end

    -- 3. No Spread / No Recoil
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

    local BestTarget = nil
    local ClosestMag = _G.Aimbot_FOV
    local mousePos = UserInputService:GetMouseLocation()

    -- 4. ESP & Aimbot System
    for _, p in pairs(Players:GetPlayers()) do
        if not Cache[p] then Cache[p] = {Box = Drawing.new("Square"), Line = Drawing.new("Line")} end
        local esp = Cache[p]

        local isEnemy = false
        pcall(function() isEnemy = Scanner:IsEnemy(p) end)

        if isEnemy and SelfAlive then
            local eChar = p.Character
            local head = eChar:FindFirstChild("Head")
            if head then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    -- Visible Check
                    local rp = RaycastParams.new()
                    rp.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
                    rp.FilterType = Enum.RaycastFilterType.Exclude
                    local ray = workspace:Raycast(Camera.CFrame.Position, head.Position - Camera.CFrame.Position, rp)
                    local visible = not ray or ray.Instance:IsDescendantOf(eChar)
                    
                    local color = visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)

                    -- Vẽ ESP
                    esp.Box.Visible = _G.BoxESP_Active
                    esp.Box.Color = color
                    esp.Box.Position = Vector2.new(pos.X - (2800/pos.Z)/2, pos.Y - (4500/pos.Z)/2)
                    esp.Box.Size = Vector2.new(2800/pos.Z, 4500/pos.Z)

                    esp.Line.Visible = _G.Tracers_Enabled
                    esp.Line.From = Vector2.new(Center.X, 0)
                    esp.Line.To = Vector2.new(pos.X, pos.Y - (4500/pos.Z)/2)
                    esp.Line.Color = color

                    -- Aimbot Logic
                    if _G.Aimbot_Enabled and visible then
                        local mag = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if mag < ClosestMag then
                            BestTarget = head
                            ClosestMag = mag
                        end
                    end
                else esp.Box.Visible = false; esp.Line.Visible = false end
            end
        else
            if esp then esp.Box.Visible = false; esp.Line.Visible = false end
        end
    end

    -- Khóa mục tiêu
    if BestTarget and _G.Aimbot_Enabled and SelfAlive then
        local tPos = Camera:WorldToViewportPoint(BestTarget.Position)
        mousemoverel((tPos.X - mousePos.X) * _G.Aim_Smoothness, (tPos.Y - mousePos.Y) * _G.Aim_Smoothness)
    end
end)

-- [[ GIAO DIỆN RAYFIELD ]]
local Combat = Window:CreateTab("Combat", 4483345998)
Combat:CreateToggle({Name = "Aimbot Head", CurrentValue = false, Callback = function(v) _G.Aimbot_Enabled = v end})
Combat:CreateSlider({Name = "Aim FOV", Range = {50, 1000}, Increment = 10, CurrentValue = 250, Callback = function(v) _G.Aimbot_FOV = v end})
Combat:CreateToggle({Name = "No Recoil / Spread", CurrentValue = false, Callback = function(v) _G.NoRecoil_Enabled = v end})

local Move = Window:CreateTab("Extra", 4483345998)
Visual:CreateToggle({Name = "No Flash (Xóa Flash)", CurrentValue = true, Callback = function(v) _G.NoFlash_Enabled = v end})
Visual:CreateToggle({Name = "No Smoke (Xóa Khói)", CurrentValue = true, Callback = function(v) _G.NoSmoke_Enabled = v end})
Visual:CreateSlider({Name = "Safe Cam Xa", Range = {70, 90}, Increment = 1, CurrentValue = 70, Callback = function(v) _G.CamFOV = v end})

local Visual = Window:CreateTab("Visuals", 4483345998)
Visual:CreateToggle({Name = "Box ESP", CurrentValue = true, Callback = function(v) _G.BoxESP_Active = v end})
Visual:CreateToggle({Name = "Tracers (Top)", CurrentValue = true, Callback = function(v) _G.Tracers_Enabled = v end})
Tab:CreateToggle({Name = "Skeleton ESP", CurrentValue = true, Callback = function(v) _G.Skeleton_ESP = v end})
Tab:CreateToggle({Name = "Health Bar", CurrentValue = true, Callback = function(v) _G.HealthBar_ESP = v end})
Tab:CreateToggle({Name = "Distance Info", CurrentValue = true, Callback = function(v) _G.Distance_ESP = v end})

task.spawn(function() while true do Scanner:GetFolder() task.wait(5) end end)
Rayfield:Notify({Title = "AURORA ELITE X", Content = "V104: Đã dọn sạch lỗi & Sẵn sàng quấy!", Duration = 5})