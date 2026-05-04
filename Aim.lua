
local function SecureBypass()
    pcall(function()
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local old = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            if getnamecallmethod() == "FireServer" and (self.Name == "RemoteEvent" or self.Name == "DataEvent") then
                return nil 
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end)
end
SecureBypass()


local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "⚔️ UAOT VIP | Gemini Edition", HidePremium = false, SaveConfig = false, IntroText = "Đang nạp hệ thống..."})

local Settings = {
    AutoFarm = false,
    FlySpeed = 350,
    Distance = 4
}

function AddESP(Titan)
    pcall(function()
        if Titan:FindFirstChild("Nape") and not Titan.Nape:FindFirstChild("ESP") then
            local bgui = Instance.new("BillboardGui", Titan.Nape)
            bgui.Name = "ESP"
            bgui.AlwaysOnTop = true
            bgui.Size = UDim2.new(4, 0, 4, 0)
            local frame = Instance.new("Frame", bgui)
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            frame.BackgroundTransparency = 0.5
            Instance.new("UIStroke", frame).Thickness = 2
        end
    end)
end

task.spawn(function()
    while task.wait(2) do
        for _, v in pairs(workspace:GetChildren()) do
            if v:FindFirstChild("Nape") then AddESP(v) end
        end
    end
end)

local MainTab = Window:MakeTab({Name = "Farm Titan", Icon = "rbxassetid://4483345998", PremiumOnly = false})

MainTab:AddToggle({
    Name = "Auto Diệt Titan (Mượt)",
    Default = false,
    Callback = function(Value)
        Settings.AutoFarm = Value
        if Value then
            task.spawn(function()
                while Settings.AutoFarm do
                    pcall(function()
                        local Target = nil
                        local MinDist = math.huge
                        for _, v in pairs(workspace:GetChildren()) do
                            if v:FindFirstChild("Nape") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                local d = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.Nape.Position).Magnitude
                                if d < MinDist then MinDist = d; Target = v end
                            end
                        end

                        if Target then
                            local Root = game.Players.LocalPlayer.Character.HumanoidRootPart
                            local TargetPos = Target.Nape.CFrame * CFrame.new(0, 0, Settings.Distance)
                            local Dist = (Root.Position - TargetPos.Position).Magnitude
                            
                            if Dist > 10 then
                                Root.CFrame = Root.CFrame:Lerp(TargetPos, task.wait() * (Settings.FlySpeed / Dist))
                            else
                                Root.CFrame = TargetPos
                                game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0))
                                task.wait(0.1)
                            end
                        end
                    end)
                    task.wait()
                end
            end)
        end
    end    
})

MainTab:AddSlider({
    Name = "Tốc độ bay",
    Min = 100, Max = 1000, Default = 350, Color = Color3.fromRGB(255,255,255), Increment = 50,
    ValueName = "Studs",
    Callback = function(Value) Settings.FlySpeed = Value end    
})

OrionLib:Init()
