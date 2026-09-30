-- =================================================================
--            WINDUI FULL SCRIPT WITH FIXED KEY SYSTEM
-- =================================================================

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/FootGes/WindUI/main/Main.lua"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- -----------------------------------------------------------------
-- 1. إعدادات المفتاح الثابت
-- -----------------------------------------------------------------
local KeyFileName = "WindUI_KeyData.json"

-- اكتب المفتاح الثابت الذي تريده هنا:
local ValidKey = "VIP_vip" 

-- اكتب الرابط الذي تريد نسخه عند الضغط على زر النسخ:
local KeyLink = "https://pastebin.com/X6EunhQR" 

-- -----------------------------------------------------------------
-- آليات حفظ المفتاح لمدة 48 ساعة
-- -----------------------------------------------------------------
local function SaveKeyData(key)
    local data = {
        Key = key,
        ExpireTime = os.time() + (48 * 60 * 60) -- صالحة لمدة يومين
    }
    if writefile then
        writefile(KeyFileName, HttpService:JSONEncode(data))
    end
end

local function LoadKeyData()
    if isfile and isfile(KeyFileName) then
        local success, res = pcall(function()
            return HttpService:JSONDecode(readfile(KeyFileName))
        end)
        if success and res and res.ExpireTime then
            if os.time() < res.ExpireTime then
                return res
            end
        end
    end
    return nil
end

local SavedData = LoadKeyData()
local IsKeyValid = SavedData ~= nil and SavedData.Key == ValidKey

-- نافذة التفعيل إذا لم يكن الجهاز مفعلاً
if not IsKeyValid then
    local KeyWindow = WindUI:CreateWindow({
        Title = "نظام التفعيل | Key System",
        Icon = "key",
        Size = UDim2.fromOffset(400, 250),
        Theme = "Dark",
    })

    local KeyTab = KeyWindow:Tab({ Title = "المفتاح", Icon = "lock" })

    KeyTab:Button({
        Title = "نسخ رابط الحصول على المفتاح",
        Callback = function()
            if setclipboard then
                setclipboard(KeyLink)
                WindUI:Notify({ Title = "تم النسخ!", Content = "تم نسخ الرابط للحافظة، افتحه في قوقل للحصول على المفتاح.", Duration = 4 })
            end
        end
    })

    local InputKey = ""
    KeyTab:Input({
        Title = "أدخل المفتاح هنا",
        Placeholder = "الكود...",
        Callback = function(text)
            InputKey = string.gsub(text, "%s+", "")
        end
    })

    KeyTab:Button({
        Title = "تأكيد المفتاح",
        Callback = function()
            if InputKey == ValidKey then
                SaveKeyData(InputKey)
                WindUI:Notify({ Title = "نجاح!", Content = "تم التفعيل بنجاح! السكربت صالِح لمُدة 48 ساعة على جهازك.", Duration = 3 })
                task.wait(1)
                KeyWindow:Destroy()
                IsKeyValid = true
            else
                WindUI:Notify({ Title = "خطأ", Content = "المفتاح غير صحيح! أدخل المفتاح الصحيح.", Duration = 3 })
            end
        end
    })

    repeat task.wait() until IsKeyValid
end

-- -----------------------------------------------------------------
-- 2. النافذة الرئيسية والـ 8 تبويبات
-- -----------------------------------------------------------------
local Window = WindUI:CreateWindow({
    Title = "Ultimate WindUI Hub ⚡",
    Icon = "shield",
    Author = "Script Master",
    Size = UDim2.fromOffset(600, 450),
    Theme = "Dark",
})

local Tab1 = Window:Tab({ Title = "اللاعب", Icon = "user" })
local Tab2 = Window:Tab({ Title = "عصا الطيران", Icon = "plane" })
local Tab3 = Window:Tab({ Title = "كشف ESP", Icon = "eye" })
local Tab4 = Window:Tab({ Title = "القتال Aimbot", Icon = "crosshair" })
local Tab5 = Window:Tab({ Title = "الأدوات", Icon = "wrench" })
local Tab6 = Window:Tab({ Title = "العالم والطقس", Icon = "sun" })
local Tab7 = Window:Tab({ Title = "السيرفر", Icon = "server" })
local Tab8 = Window:Tab({ Title = "المفتاح والضبط", Icon = "settings" })

-- =================================================================
-- التبويب 1: إعدادات اللاعب (Speed / Jump)
-- =================================================================
Tab1:Slider({
    Title = "سرعة المشي (Speed)",
    Min = 16,
    Max = 250,
    Default = 16,
    Callback = function(v)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    end
})

Tab1:Slider({
    Title = "قوة القفز (Jump Power)",
    Min = 50,
    Max = 300,
    Default = 50,
    Callback = function(v)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = v
        end
    end
})

local InfJump = false
Tab1:Toggle({
    Title = "قفز لا نهائي (Infinite Jump)",
    Callback = function(state)
        InfJump = state
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- =================================================================
-- التبويب 2: عصا الطيران (تحكم بعصا المشي)
-- =================================================================
local FlySpeed = 60
local Flying = false
local BodyVel, BodyGyro

Tab2:Slider({
    Title = "سرعة الطيران",
    Min = 20,
    Max = 200,
    Default = 60,
    Callback = function(v)
        FlySpeed = v
    end
})

Tab2:Button({
    Title = "إعطاء عصا الطيران 🪄 (المشي تحكم باليد)",
    Callback = function()
        if LocalPlayer.Backpack:FindFirstChild("عصا الطيران") then return end

        local Tool = Instance.new("Tool")
        Tool.Name = "عصا الطيران"
        Tool.RequiresHandle = false
        Tool.Parent = LocalPlayer.Backpack

        Tool.Equipped:Connect(function()
            local Char = LocalPlayer.Character
            if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
            
            Flying = true
            local HRP = Char.HumanoidRootPart
            local Cam = workspace.CurrentCamera

            BodyVel = Instance.new("BodyVelocity")
            BodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            BodyVel.Velocity = Vector3.zero
            BodyVel.Parent = HRP

            BodyGyro = Instance.new("BodyGyro")
            BodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            BodyGyro.CFrame = HRP.CFrame
            BodyGyro.Parent = HRP

            task.spawn(function()
                while Flying and Char:FindFirstChild("Humanoid") do
                    local MoveDir = Char.Humanoid.MoveDirection
                    if MoveDir.Magnitude > 0 then
                        local CamCFrame = Cam.CFrame
                        local Direction = (CamCFrame.LookVector * (MoveDir.Z < 0 and 1 or (MoveDir.Z > 0 and -1 or 0)))
                                        + (CamCFrame.RightVector * MoveDir.X)
                        
                        if Direction.Magnitude > 0 then
                            BodyVel.Velocity = Direction.Unit * FlySpeed
                        else
                            BodyVel.Velocity = MoveDir * FlySpeed
                        end
                    else
                        BodyVel.Velocity = Vector3.zero
                    end
                    BodyGyro.CFrame = Cam.CFrame
                    RunService.RenderStepped:Wait()
                end
            end)
        end)

        Tool.Unequipped:Connect(function()
            Flying = false
            if BodyVel then BodyVel:Destroy() end
            if BodyGyro then BodyGyro:Destroy() end
        end)

        WindUI:Notify({ Title = "تم الإضافة", Content = "تمت إضافة عصا الطيران لحقيبتك!", Duration = 3 })
    end
})

-- =================================================================
-- التبويب 3: كشف اللاعبين (ESP)
-- =================================================================
local ESPEnabled = false
Tab3:Toggle({
    Title = "تفعيل كشف الأماكن (ESP)",
    Callback = function(state)
        ESPEnabled = state
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                if state then
                    if not p.Character:FindFirstChild("ESP_Box") then
                        local Highlight = Instance.new("Highlight")
                        Highlight.Name = "ESP_Box"
                        Highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        Highlight.Parent = p.Character
                    end
                else
                    if p.Character:FindFirstChild("ESP_Box") then
                        p.Character.ESP_Box:Destroy()
                    end
                end
            end
        end
    end
})

-- =================================================================
-- التبويب 4: القتال والمنظار (Aimbot)
-- =================================================================
local AimbotEnabled = false
Tab4:Toggle({
    Title = "تفعيل المساعدة بالصوب (Aimbot)",
    Callback = function(state)
        AimbotEnabled = state
    end
})

RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local Target = nil
        local ShortestDist = math.huge
        local Cam = workspace.CurrentCamera

        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                local Pos, OnScreen = Cam:WorldToViewportPoint(v.Character.Head.Position)
                if OnScreen then
                    local MousePos = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
                    local Dist = (Vector2.new(Pos.X, Pos.Y) - MousePos).Magnitude
                    if Dist < ShortestDist then
                        ShortestDist = Dist
                        Target = v.Character.Head
                    end
                end
            end
        end

        if Target then
            Cam.CFrame = CFrame.new(Cam.CFrame.Position, Target.Position)
        end
    end
end)

-- =================================================================
-- التبويب 5: الأدوات (Utilities)
-- =================================================================
Tab5:Button({
    Title = "اختراق الجدران (Noclip)",
    Callback = function()
        RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, v in pairs(LocalPlayer.Character:GetChildren()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end)
        WindUI:Notify({ Title = "Noclip", Content = "تم تفعيل اختراق الجدران!", Duration = 3 })
    end
})

Tab5:Button({
    Title = "الانتقال المباشر (Click TP)",
    Callback = function()
        local Mouse = LocalPlayer:GetMouse()
        Mouse.Button1Down:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end)
        WindUI:Notify({ Title = "Click TP", Content = "اضغط في أي مكان بالماوس للانتقال له!", Duration = 3 })
    end
})

-- =================================================================
-- التبويب 6: العالم والطقس (World)
-- =================================================================
Tab6:Button({
    Title = "إضاءة كاملة (Fullbright)",
    Callback = function()
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").FogEnd = 100000
        game:GetService("Lighting").GlobalShadows = false
    end
})

Tab6:Button({
    Title = "تسريع اللعبة وإزالة اللغاق (FPS Boost)",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(LocalPlayer.Character) then
                v.Material = Enum.Material.SmoothPlastic
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            end
        end
    end
})

-- =================================================================
-- التبويب 7: السيرفر (Server)
-- =================================================================
Tab7:Button({
    Title = "إعادة الدخول للسيرفر (Rejoin)",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

Tab7:Button({
    Title = "تغيير السيرفر (Server Hop)",
    Callback = function()
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        
        local success, res = pcall(function() return Http:JSONDecode(game:HttpGet(Api)) end)
        if success and res and res.data then
            for _, server in pairs(res.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TPS:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    break
                end
            end
        end
    end
})

-- =================================================================
-- التبويب 8: حالة المفتاح والضبط (Settings)
-- =================================================================
local Data = LoadKeyData()
local RemainingHours = Data and math.floor((Data.ExpireTime - os.time()) / 3600) or 48

Tab8:Paragraph({
    Title = "حالة التفعيل",
    Content = "المفتاح حالياً: مفعل ✅\nالوقت المتبقي لانتهاء التفعيل: " .. tostring(RemainingHours) .. " ساعة"
})

Tab8:Button({
    Title = "نسخ رابط المفتاح",
    Callback = function()
        if setclipboard then
            setclipboard(KeyLink)
            WindUI:Notify({ Title = "تم النسخ", Content = "تم نسخ الرابط للحافظة!", Duration = 3 })
        end
    end
})

Tab8:Button({
    Title = "إغلاق الواجهة",
    Callback = function()
        Window:Destroy()
    end
})
