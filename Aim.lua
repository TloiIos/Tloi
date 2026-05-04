-- [[ 🛡️ BYPASS NHẸ ]] --
pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local old = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        return old(self, ...)
    end)
    setreadonly(mt, true)
end)

-- [[ 🎨 LOAD ORION LIB ]] --
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local Window = OrionLib:MakeWindow({
    Name = "⚔️ UAOT VIP | AUTO KILL FIX",
    HidePremium = false,
    SaveConfig = false,
    IntroText = "Untitled Attack on Titan"
})

-- [[ ⚙️ SETTINGS ]] --
local Settings = {
    AutoKill = false,
    Distance = 3.5,
    AttackSpeed = 0.05
}

local player = game.Players.LocalPlayer
local function GetChar() return player.Character or player.CharacterAdded:Wait() end

-- [[ 🗡️ LOGIC TÌM TITAN GẦN NHẤT ]] --
local function GetClosestTitan()
    local target, dist = nil, math.huge
    local char = GetChar()
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    for _, v in pairs(workspace:GetChildren()) do
        -- Kiểm tra model có gáy (Nape) và còn sống
        if v:FindFirstChild("Nape") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local d = (char.HumanoidRootPart.Position - v.Nape.Position).Magnitude
            if d < dist then
                dist = d
                target = v
            end
        end
    end
    return target
end

-- [[ 📌 TAB CHÍNH ]] --
local MainTab = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "rbxassetid://4483345998"
})

MainTab:AddToggle({
    Name = "Auto Kill Titan (Tele Gáy)",
    Default = false,
    Callback = function(Value)
        Settings.AutoKill = Value
        if Value then
            task.spawn(function()
                while Settings.AutoKill do
                    pcall(function()
                        local titan = GetClosestTitan()
                        local char = GetChar()
                        local root = char:FindFirstChild("HumanoidRootPart")
                        
                        if titan and root then
                            -- Teleport chính xác vào phía sau gáy
                            local targetPos = titan.Nape.CFrame * CFrame.new(0, 0, Settings.Distance)
                            root.CFrame = targetPos
                            
                            -- Tự động chém
                            game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0))
                            task.wait(Settings.AttackSpeed)
                            game:GetService("VirtualUser"):Button1Up(Vector2.new(0,0))
                        end
                    end)
                    task.wait()
                end
            end)
        end
    end
})

MainTab:AddSlider({
    Name = "Khoảng cách chém",
    Min = 1, Max = 10, Default = 3.5, Increment = 0.5,
    Callback = function(v) Settings.Distance = v end
})

-- [[ 👁️ ESP SYSTEM ]] --
local ESPTab = Window:MakeTab({ Name = "Visuals", Icon = "rbxassetid://4483345998" })
local ESPEnabled = false

ESPTab:AddToggle({
    Name = "ESP Titan",
    Default = false,
    Callback = function(v) ESPEnabled = v end
})

task.spawn(function()
    while task.wait(1) do
        if ESPEnabled then
            for _, v in pairs(workspace:GetChildren()) do
                if v:FindFirstChild("Nape") and not v.Nape:FindFirstChild("ESP") then
                    local bg = Instance.new("BillboardGui", v.Nape)
                    bg.Name = "ESP"
                    bg.AlwaysOnTop = true
                    bg.Size = UDim2.new(4,0,4,0)
                    local f = Instance.new("Frame", bg)
                    f.Size = UDim2.new(1,0,1,0)
                    f.BackgroundColor3 = Color3.new(1,0,0)
                    f.BackgroundTransparency = 0.5
                end
            end
        end
    end
end)

OrionLib:Init()
