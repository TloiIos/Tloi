
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

local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
local Window = OrionLib:MakeWindow({
    Name = "⚔️ UAOT VIP | Gemini Edition", 
    HidePremium = false, 
    SaveConfig = false, 
    IntroText = "3 Ngón tay để ẩn/hiện Menu"
})

local Settings = {
    AutoFarm = false,
    FlySpeed = 400,
    Distance = 4
}

local UserInputService = game:GetService("UserInputService")
local GuiVisible = true

UserInputService.InputBegan:Connect(function(input, processed)
 
    local touches = UserInputService:GetTouches()
    if #touches >= 3 then
        GuiVisible = not GuiVisible
        local orionGui = game:GetService("CoreGui"):FindFirstChild("Orion")
        if orionGui then
            orionGui.Enabled = GuiVisible
        end
    end
end)


local function CreateESP(Titan)
    pcall(function()
        if Titan:FindFirstChild("Nape") and not Titan.Nape:FindFirstChild("ESP_Box") then
            local Billboard = Instance.new("BillboardGui", Titan.Nape)
            Billboard.Name = "ESP_Box"
            Billboard.AlwaysOnTop = true
            Billboard.Size = UDim2.new(4, 0, 4, 0)
            
            local Frame = Instance.new("Frame", Billboard)
            Frame.Size = UDim2.new(1, 0, 1, 0)
            Frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            Frame.BackgroundTransparency = 0.5
            
            local Stroke = Instance.new("UIStroke", Frame)
            Stroke.Thickness = 2
            Stroke.Color = Color3.new(1, 1, 1)
        end
    end)
end

task.spawn(function()
    while task.wait(1) do
        
        for _, v in pairs(workspace:GetChildren()) do
            if v:FindFirstChild("Nape") or v.Name:lower():find("titan") then
                CreateESP(v)
            end
        end
    end
end)


local MainTab = Window:MakeTab({Name = "Farm Titan", Icon = "rbxassetid://4483345998"})

MainTab:AddToggle({
    Name = "Auto Bay + Tự Chém (Fix Nút)",
    Default = false,
    Callback = function(Value)
        Settings.AutoFarm = Value
        if Value then
            task.spawn(function()
                while Settings.AutoFarm do
                    local success, err = pcall(function()
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
                                task.wait(0.05)
                                game:GetService("VirtualUser"):Button1Up(Vector2.new(0,0))
                            end
                        end
                    end)
                    if not success then task.wait(1) end
                    task.wait()
                end
            end)
        end
    end    
})

MainTab:AddSlider({
    Name = "Tốc độ bay",
    Min = 100, Max = 1000, Default = 400, Increment = 50,
    ValueName = "Studs",
    Callback = function(Value) Settings.FlySpeed = Value end    
})

OrionLib:Init()
