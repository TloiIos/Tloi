

-- Khởi tạo thư viện Rayfield (Bản VIP)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = " Bloxstrike VIP",
   LoadingTitle = "Đang tải hệ thống VIP...",
   LoadingSubtitle = "Vui lòng đợi trong giây lát",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "ThanhLoi",
      FileName = "VIPConfig"
   }
})

-- Cài đặt mặc định
local Settings = {
    Aimbot = false,
    AimPart = "Head",
    AimFOV = 150,
    ESP = false,
    ESP_Highlight = false,
    NoRecoil = false
}

-- TAB CHÍNH: CHIẾN ĐẤU
local CombatTab = Window:CreateTab("🎯 Chiến Đấu", 4483362458)

CombatTab:CreateToggle({
   Name = "Bật Aimbot (Auto Lock)",
   CurrentValue = false,
   Callback = function(Value)
      Settings.Aimbot = Value
   end,
})

CombatTab:CreateSlider({
   Name = "Tầm ngắm (FOV Range)",
   Min = 50,
   Max = 500,
   DefaultValue = 150,
   Increment = 10,
   Callback = function(Value)
      Settings.AimFOV = Value
   end,
})

CombatTab:CreateToggle({
   Name = "Không Giật (No Recoil)",
   CurrentValue = false,
   Callback = function(Value)
      Settings.NoRecoil = Value
      -- Logic No Recoil cho Bloxstrike
      if Value then
         local old; old = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" and self.Name == "Recoil" then
               return nil -- Chặn lệnh Recoil gửi về Server
            end
            return old(self, ...)
         end)
      end
   end,
})

-- TAB THỊ GIÁC: ESP
local VisualTab = Window:CreateTab("👁️ Thị Giác", 4483362458)

VisualTab:CreateToggle({
   Name = "Nhìn Xuyên Tường (Highlight)",
   CurrentValue = false,
   Callback = function(Value)
      Settings.ESP_Highlight = Value
   end,
})

--- LOGIC CORE (CHẠY NGẦM) ---

local function GetClosestPlayer()
    local target = nil
    local dist = Settings.AimFOV
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(game.Players.LocalPlayer:GetMouse().X, game.Players.LocalPlayer:GetMouse().Y)).Magnitude
                if magnitude < dist then
                    target = v
                    dist = magnitude
                end
            end
        end
    end
    return target
end

-- Vòng lặp chính xử lý ESP và Aimbot
game:GetService("RunService").RenderStepped:Connect(function()
    -- Xử lý Aimbot
    if Settings.Aimbot then
        local target = GetClosestPlayer()
        if target and target.Character:FindFirstChild(Settings.AimPart) then
            local cam = game.Workspace.CurrentCamera
            cam.CFrame = CFrame.new(cam.CFrame.Position, target.Character[Settings.AimPart].Position)
        end
    end

    -- Xử lý ESP Highlight
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character then
            local char = p.Character
            if Settings.ESP_Highlight then
                if not char:FindFirstChild("VIP_Glow") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "VIP_Glow"
                    highlight.Parent = char
                    highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Màu đỏ
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- Viền trắng
                end
            else
                if char:FindFirstChild("VIP_Glow") then
                    char.VIP_Glow:Destroy()
                end
            end
        end
    end
end)

Rayfield:Notify({
   Title = "Kích hoạt thành công!",
   Content = "Chào mừng bạn đến với Bloxstrike VIP. Hãy sử dụng cẩn thận!",
   Duration = 5,
   Image = 4483362458,
})