-- Khởi tạo thư viện Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "💎 Bloxstrike ULTRA VIP | Gemini",
   LoadingTitle = "Đang khởi tạo hệ thống Visual VIP...",
   LoadingSubtitle = "Hỗ trợ Android Executor",
})

local Settings = {
    Aimbot = false,
    SilentAim = false,
    AimPart = "Head",
    AimFOV = 150,
    -- ESP Settings
    ESP_Box = false,
    ESP_Line = false,
    ESP_Color = Color3.fromRGB(0, 255, 255), -- Màu xanh Neon VIP
}

-- TAB CHIẾN ĐẤU
local CombatTab = Window:CreateTab("🎯 Chiến Đấu", 4483362458)
CombatTab:CreateToggle({
   Name = "Silent Aim (Đạn Tự Tìm)",
   CurrentValue = false,
   Callback = function(Value) Settings.SilentAim = Value end,
})

CombatTab:CreateSlider({
   Name = "Vòng tròn FOV",
   Min = 50, Max = 800, DefaultValue = 150, Increment = 10,
   Callback = function(Value) Settings.AimFOV = Value end,
})

-- TAB THỊ GIÁC (ESP VIP)
local VisualTab = Window:CreateTab("👁️ Visual VIP", 4483362458)

VisualTab:CreateToggle({
   Name = "Hiện Khung (Box ESP)",
   CurrentValue = false,
   Callback = function(Value) Settings.ESP_Box = Value end,
})

VisualTab:CreateToggle({
   Name = "Hiện Dây (Line/Tracers)",
   CurrentValue = false,
   Callback = function(Value) Settings.ESP_Line = Value end,
})

--- LOGIC VẼ ESP (VIP DRAWING) ---

local function CreateESP(Player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Settings.ESP_Color
    Box.Thickness = 1.5
    Box.Filled = false

    local Line = Drawing.new("Line")
    Line.Visible = false
    Line.Color = Settings.ESP_Color
    Line.Thickness = 1.5

    game:GetService("RunService").RenderStepped:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player ~= game.Players.LocalPlayer then
            local RootPart = Player.Character.HumanoidRootPart
            local Position, OnScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(RootPart.Position)
            
            if OnScreen then
                -- Tính toán kích thước Box dựa trên khoảng cách
                local Scale = 1 / (Position.Z * 0.7) * 1000
                local w, h = 1.8 * Scale, 3 * Scale

                -- Vẽ Box
                if Settings.ESP_Box then
                    Box.Size = Vector2.new(w, h)
                    Box.Position = Vector2.new(Position.X - w/2, Position.Y - h/2)
                    Box.Visible = true
                else
                    Box.Visible = false
                end

                -- Vẽ Line (Từ giữa dưới màn hình tới kẻ địch)
                if Settings.ESP_Line then
                    Line.From = Vector2.new(game.Workspace.CurrentCamera.ViewportSize.X / 2, game.Workspace.CurrentCamera.ViewportSize.Y)
                    Line.To = Vector2.new(Position.X, Position.Y)
                    Line.Visible = true
                else
                    Line.Visible = false
                end
            else
                Box.Visible = false
                Line.Visible = false
            end
        else
            Box.Visible = false
            Line.Visible = false
        end
    end)
end

-- Khởi tạo ESP cho tất cả người chơi
for _, p in pairs(game.Players:GetPlayers()) do CreateESP(p) end
game.Players.PlayerAdded:Connect(CreateESP)

--- SILENT AIM CORE ---
local function GetClosest()
    local t, d = nil, Settings.AimFOV
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            local p, os = game.Workspace.CurrentCamera:WorldToViewportPoint(v.Character.Head.Position)
            if os then
                local mag = (Vector2.new(p.X, p.Y) - game:GetService("UserInputService"):GetMouseLocation()).Magnitude
                if mag < d then t = v d = mag end
            end
        end
    end
    return t
end

local old; old = hookmetamethod(game, "__namecall", function(self, ...)
    local m = getnamecallmethod()
    if Settings.SilentAim and m == "FindPartOnRayWithIgnoreList" then
        local target = GetClosest()
        if target then return target.Character.Head, target.Character.Head.Position, target.Character.Head.Position end
    end
    return old(self, ...)
end)

Rayfield:Notify({
   Title = "ULTRA VIP LOADED",
   Content = "Box & Line ESP Android đã sẵn sàng!",
   Duration = 5
})
