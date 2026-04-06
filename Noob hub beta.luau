-- =============================================
--                 Noob Hub
--   Integrated Script from Multiple Sources
-- =============================================

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Player
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- UI Library (OrionLib)
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion"))()
local Window = OrionLib:MakeWindow({ 
    Name = "Noob Hub", 
    HidePremium = true, 
    SaveConfig = false,
    IntroEnabled = false
})

-- Configuration
local Config = {
    Grab = {
        KickGrab = false,
        KillGrab = false,
        VoidGrab = false,
        AnchorGrab = false,
        SuperStrength = false,
        StrengthPower = 250
    },
    Snipes = {
        TargetPlayer = nil,
        LoopKill = false,
        LoopVoid = false,
        LoopPoison = false,
        LoopRagdoll = false,
        LoopDeath = false,
        LoopBring = false,
        LoopPull = false
    },
    Anti = {
        AntiGrab = false,
        AntiVoid = false,
        AntiRagdoll = false,
        AntiExplode = false,
        AntiGucci = false,
        AntiGrabTP = false,
        StruggleSpam = false
    },
    Player = {
        SpeedValue = 16,
        JumpValue = 50,
        SpeedEnabled = false,
        JumpEnabled = false,
        Noclip = false
    },
    Aura = {
        Enabled = false,
        spacing = 3,
        heightOffset = 2,
        backwardOffset = 3,
        maxSparklers = 20,
        tiltAngle = 45,
        waveSpeed = 2,
        baseAmplitude = 1
    }
}

-- Visual/ESP Variables
local ESPEnabled = false
local ESPBoxEnabled = false
local SkeletonESPEnabled = false
local TracerESPEnabled = false
local NameESPEnabled = false
local HighlightColor = Color3.fromRGB(255, 0, 0)
local HighlightTransparency = 0.6
local ESPBoxColor = Color3.fromRGB(255, 255, 255)
local SkeletonColor = Color3.fromRGB(255, 255, 255)
local SkeletonThickness = 1.5
local ESPColor = Color3.fromRGB(255, 255, 255)
local ESPTextSize = 13
local timesync = false

-- Grab Variables
local poisonGrabCoroutine, fireGrabCoroutine, ufoGrabCoroutine, noclipGrabCoroutine
local skygrabLoop, groundgrabLoop
local nageru = 400
local killg = false

-- Aura Variables
local AuraToys = {}
local AuraRowPoints = {}
local AuraAssignedToys = {}
local AuraLoopConn = nil
local AuraTime = 0

-- ESP Objects
local SkeletonLines = {}
local TracerLines = {}
local nameESPObjects = {}
local Camera = Workspace.CurrentCamera

-- Helper Functions
local function HRP()
    local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return c:FindFirstChild("HumanoidRootPart")
end

local function SetNetworkOwner(part, cframe)
    if not part then return end
    pcall(function()
        ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(part, cframe or HRP().CFrame)
    end)
end

local function Velocity(part, vel)
    if not part or not part.Parent then return end
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e8, 1e8, 1e8)
    bv.Velocity = vel
    bv.Parent = part
    Debris:AddItem(bv, 1)
end

local function MoveTo(part, targetCFrame)
    if not part or not part.Parent then return end
    for _, v in ipairs(part.Parent:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end
    local b = Instance.new("BodyPosition")
    b.MaxForce = Vector3.new(1e8, 1e8, 1e8)
    b.Position = targetCFrame.Position
    b.P, b.D = 20000, 5000
    b.Parent = part
    task.delay(1, function()
        pcall(function() b:Destroy() end)
        for _, v in ipairs(part.Parent:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
    end)
end

local function ungrab(part)
    pcall(function() ReplicatedStorage.GrabEvents.DestroyGrabLine:FireServer(part) end)
end

local function getPlayerFromDisplayName(displayName)
    if not displayName or displayName == "" then return nil end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.DisplayName == displayName then return player end
    end
    return nil
end

local function updatePlayerList()
    local displayNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(displayNames, player.DisplayName)
        end
    end
    return displayNames
end

-- =============================================
--                     TABS
-- =============================================

-- 1. Grab Tab
local GrabTab = Window:MakeTab({ Name = "Grab", Icon = "rbxassetid://4483362458" })

GrabTab:AddSection({ Name = "Grab Controls" })
GrabTab:AddToggle({
    Name = "Kick Grab",
    Default = false,
    Callback = function(v)
        Config.Grab.KickGrab = v
    end
})

GrabTab:AddToggle({
    Name = "Kill Grab",
    Default = false,
    Callback = function(v)
        Config.Grab.KillGrab = v
    end
})

GrabTab:AddToggle({
    Name = "Void Grab",
    Default = false,
    Callback = function(v)
        Config.Grab.VoidGrab = v
    end
})

GrabTab:AddToggle({
    Name = "Anchor Grab",
    Default = false,
    Callback = function(v)
        Config.Grab.AnchorGrab = v
    end
})

GrabTab:AddSection({ Name = "Super Strength" })
GrabTab:AddSlider({
    Name = "Throw Power",
    Min = 0,
    Max = 10000,
    Default = 250,
    Increment = 10,
    Callback = function(v)
        Config.Grab.StrengthPower = v
    end
})

GrabTab:AddToggle({
    Name = "Super Strength",
    Default = false,
    Callback = function(v)
        Config.Grab.SuperStrength = v
    end
})

GrabTab:AddSection({ Name = "Advanced Grab Mods" })

GrabTab:AddToggle({
    Name = "Poison Grab",
    Default = false,
    Callback = function(enabled)
        if enabled then
            poisonGrabCoroutine = coroutine.create(function()
                -- Poison grab logic here
            end)
            coroutine.resume(poisonGrabCoroutine)
        else
            if poisonGrabCoroutine then
                coroutine.close(poisonGrabCoroutine)
                poisonGrabCoroutine = nil
            end
        end
    end
})

GrabTab:AddToggle({
    Name = "Radioactive Grab",
    Default = false,
    Callback = function(enabled)
        if enabled then
            ufoGrabCoroutine = coroutine.create(function()
                -- Radioactive grab logic here
            end)
            coroutine.resume(ufoGrabCoroutine)
        else
            if ufoGrabCoroutine then
                coroutine.close(ufoGrabCoroutine)
                ufoGrabCoroutine = nil
            end
        end
    end
})

GrabTab:AddToggle({
    Name = "Noclip Grab",
    Default = false,
    Callback = function(state)
        if state then
            noclipGrabCoroutine = coroutine.create(function()
                -- Noclip grab logic here
            end)
            coroutine.resume(noclipGrabCoroutine)
        elseif noclipGrabCoroutine then
            coroutine.close(noclipGrabCoroutine)
            noclipGrabCoroutine = nil
        end
    end
})

GrabTab:AddToggle({
    Name = "上に上がる掴む",
    Default = false,
    Callback = function(Value)
        if Value then
            skygrabLoop = task.spawn(function()
                while task.wait(0.1) do
                    local grabParts = Workspace:FindFirstChild("GrabParts")
                    if not grabParts then continue end

                    local grabPart = grabParts:FindFirstChild("GrabPart")
                    local weld = grabPart and grabPart:FindFirstChild("WeldConstraint")
                    local targetPart = weld and weld.Part1

                    if targetPart and targetPart:IsA("Part") then
                        local existing = targetPart:FindFirstChild("SkyGrabBP")
                        if not existing then
                            local bp = Instance.new("BodyPosition")
                            bp.Name = "SkyGrabBP"
                            bp.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                            bp.Position = targetPart.Position + Vector3.new(0, 999, 0)
                            bp.D = 1000
                            bp.P = 3000
                            bp.Parent = targetPart
                        else
                            existing.Position = targetPart.Position + Vector3.new(0, 9999, 0)
                        end
                    end
                end
            end)
        else
            if skygrabLoop then
                task.cancel(skygrabLoop)
                skygrabLoop = nil
            end
        end
    end
})

GrabTab:AddToggle({
    Name = "下に下がる掴む",
    Default = false,
    Callback = function(Value)
        if Value then
            groundgrabLoop = task.spawn(function()
                while task.wait(0.1) do
                    local grabParts = Workspace:FindFirstChild("GrabParts")
                    if not grabParts then continue end

                    local grabPart = grabParts:FindFirstChild("GrabPart")
                    local weld = grabPart and grabPart:FindFirstChild("WeldConstraint")
                    local targetPart = weld and weld.Part1

                    if targetPart and targetPart:IsA("Part") then
                        local existing = targetPart:FindFirstChild("GroundGrabBP")
                        if not existing then
                            local bp = Instance.new("BodyPosition")
                            bp.Name = "GroundGrabBP"
                            bp.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                            bp.Position = targetPart.Position + Vector3.new(0, -9999, 0)
                            bp.D = 1000
                            bp.P = 3000
                            bp.Parent = targetPart
                        else
                            existing.Position = targetPart.Position + Vector3.new(0, -9999, 0)
                        end
                    end
                end
            end)
        else
            if groundgrabLoop then
                task.cancel(groundgrabLoop)
                groundgrabLoop = nil
            end
        end
    end
})

GrabTab:AddSlider({
    Name = "投げるパワー",
    Min = 300,
    Max = 4000,
    Default = 400,
    Increment = 1,
    Callback = function(value)
        nageru = value
    end
})

-- 2. Blobman Tab
local BlobmanTab = Window:MakeTab({ Name = "Blobman", Icon = "rbxassetid://7733916988" })

local selectedPlayerName = nil
local playerDropdown

local function blobGrabPlayer(player, blobman, hand)
    if not player or not player.Character then return end
    local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end

    local detector = (hand == "Left") and blobman.LeftDetector or blobman.RightDetector
    local weld = detector and detector:FindFirstChild(hand .. "Weld")

    if detector and weld then
        blobman.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
            detector,
            targetHRP,
            weld
        )
    end
end

local function findBlobmanForLocalPlayer()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v.Name == "CreatureBlobman" and v:FindFirstChild("VehicleSeat") then
            local weld = v.VehicleSeat:FindFirstChild("SeatWeld")
            if weld and weld.Part1 and weld.Part1:IsDescendantOf(LocalPlayer.Character) then
                return v
            end
        end
    end
    return nil
end

local function getPlayerList()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player.DisplayName .. " (" .. player.Name .. ")")
        end
    end
    return list
end

local function getPlayerByDisplayName(displayString)
    for _, player in ipairs(Players:GetPlayers()) do
        local label = player.DisplayName .. " (" .. player.Name .. ")"
        if label == displayString then
            return player
        end
    end
    return nil
end

local function updateDropdown()
    if playerDropdown then
        playerDropdown:Refresh(getPlayerList(), true)
    end
end

playerDropdown = BlobmanTab:AddDropdown({
    Name = "プレイヤー選択",
    Options = getPlayerList(),
    Callback = function(value)
        selectedPlayerName = value
    end
})

BlobmanTab:AddButton({
    Name = "Bring（選択した人を1回）",
    Callback = function()
        if not selectedPlayerName then 
            OrionLib:MakeNotification({Name="エラー",Content="プレイヤーが選択されていません",Time=3})
            return 
        end

        local target = getPlayerByDisplayName(selectedPlayerName)
        local blobman = findBlobmanForLocalPlayer()
        if not target or not blobman then return end

        local originalPos = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.CFrame

        local targetHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if targetHRP then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetHRP.Position + Vector3.new(0, 5, 0))
            task.wait(0.4)
        end

        blobGrabPlayer(target, blobman, "Left")
        task.wait(0.6)

        if originalPos then
            LocalPlayer.Character.HumanoidRootPart.CFrame = originalPos
        end
    end
})

BlobmanTab:AddButton({
    Name = "Kick（選択した人を高速Bring・浮遊）",
    Callback = function()
        if not selectedPlayerName then 
            OrionLib:MakeNotification({Name="エラー",Content="プレイヤーが選択されていません",Time=3})
            return 
        end

        local target = getPlayerByDisplayName(selectedPlayerName)
        local blobman = findBlobmanForLocalPlayer()
        if not target or not blobman then return end

        local seat = blobman:FindFirstChild("VehicleSeat")
        if seat then
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 40, 0)
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Parent = seat
            Debris:AddItem(bv, 8)
        end

        for i = 1, 12 do
            blobGrabPlayer(target, blobman, "Left")
            blobGrabPlayer(target, blobman, "Right")
            task.wait(0.25)
        end
    end
})

BlobmanTab:AddLabel("オール系（近くのプレイヤーを繰り返しBring）")

BlobmanTab:AddToggle({
    Name = "左手オール（左手で高速Bring）",
    Default = false,
    Callback = function(enabled)
        if enabled then
            task.spawn(function()
                while enabled do
                    local blobman = findBlobmanForLocalPlayer()
                    if not blobman then task.wait(1) continue end

                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer then
                            blobGrabPlayer(plr, blobman, "Left")
                        end
                    end
                    task.wait(0.35)
                end
            end)
        end
    end
})

BlobmanTab:AddToggle({
    Name = "右手オール（右手で高速Bring）",
    Default = false,
    Callback = function(enabled)
        if enabled then
            task.spawn(function()
                while enabled do
                    local blobman = findBlobmanForLocalPlayer()
                    if not blobman then task.wait(1) continue end

                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer then
                            blobGrabPlayer(plr, blobman, "Right")
                        end
                    end
                    task.wait(0.35)
                end
            end)
        end
    end
})

BlobmanTab:AddToggle({
    Name = "高速オール（両手交互・テレポートなし）",
    Default = false,
    Callback = function(enabled)
        if enabled then
            task.spawn(function()
                local useLeft = true
                while enabled do
                    local blobman = findBlobmanForLocalPlayer()
                    if not blobman then task.wait(1) continue end

                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer then
                            local hand = useLeft and "Left" or "Right"
                            blobGrabPlayer(plr, blobman, hand)
                            useLeft = not useLeft
                        end
                    end
                    task.wait(0.28)
                end
            end)
        end
    end
})

-- 3. Anti Tab
local AntiTab = Window:MakeTab({ Name = "Anti", Icon = "rbxassetid://4483362458" })

AntiTab:AddSection({ Name = "Anti Features" })

AntiTab:AddToggle({
    Name = "Anti Grab",
    Default = false,
    Callback = function(v)
        Config.Anti.AntiGrab = v
    end
})

AntiTab:AddToggle({
    Name = "Anti Void",
    Default = false,
    Callback = function(v)
        Config.Anti.AntiVoid = v
    end
})

AntiTab:AddToggle({
    Name = "Anti Ragdoll",
    Default = false,
    Callback = function(v)
        Config.Anti.AntiRagdoll = v
    end
})

AntiTab:AddToggle({
    Name = "Anti Explode",
    Default = false,
    Callback = function(v)
        Config.Anti.AntiExplode = v
    end
})

AntiTab:AddToggle({
    Name = "Anti Grab TP (Experimental)",
    Default = false,
    Callback = function(v)
        Config.Anti.AntiGrabTP = v
    end
})

AntiTab:AddToggle({
    Name = "Struggle Spam (Anti Grab強化)",
    Default = false,
    Callback = function(v)
        Config.Anti.StruggleSpam = v
    end
})

AntiTab:AddSection({ Name = "Utility" })

AntiTab:AddButton({
    Name = "Reset Character",
    Callback = function()
        if Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        end
    end
})

AntiTab:AddButton({
    Name = "Teleport to Safe Zone",
    Callback = function()
        HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
    end
})

-- 4. Player Tab
local PlayerTab = Window:MakeTab({ Name = "Player", Icon = "rbxassetid://4483362458" })

PlayerTab:AddSection({ Name = "Movement" })

PlayerTab:AddSlider({
    Name = "Speed Value",
    Min = 16,
    Max = 1000,
    Default = 16,
    Increment = 1,
    Callback = function(v)
        Config.Player.SpeedValue = v
    end
})

PlayerTab:AddToggle({
    Name = "Speed Boost",
    Default = false,
    Callback = function(v)
        Config.Player.SpeedEnabled = v
    end
})

PlayerTab:AddSlider({
    Name = "Jump Value",
    Min = 50,
    Max = 500,
    Default = 50,
    Increment = 1,
    Callback = function(v)
        Config.Player.JumpValue = v
    end
})

PlayerTab:AddToggle({
    Name = "Jump Boost",
    Default = false,
    Callback = function(v)
        Config.Player.JumpEnabled = v
    end
})

PlayerTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(v)
        Config.Player.Noclip = v
    end
})

-- 5. Aura Tab (Feather/Wing)
local AuraTab = Window:MakeTab({ Name = "Aura", Icon = "rbxassetid://4483362458" })

AuraTab:AddToggle({
    Name = "羽を起動 (背中側)",
    Default = false,
    Callback = function(Value)
        Config.Aura.Enabled = Value
        -- Add aura activation logic here
    end
})

AuraTab:AddSection({ Name = "配置設定" })

AuraTab:AddSlider({
    Name = "最大花火数",
    Min = 2,
    Max = 40,
    Default = Config.Aura.maxSparklers,
    Increment = 2,
    ValueName = "本",
    Callback = function(Value)
        Config.Aura.maxSparklers = Value
    end
})

AuraTab:AddSlider({
    Name = "花火の間隔",
    Min = 1,
    Max = 10,
    Default = Config.Aura.spacing,
    Increment = 0.5,
    ValueName = "studs",
    Callback = function(Value)
        Config.Aura.spacing = Value
    end
})

AuraTab:AddSlider({
    Name = "高さオフセット",
    Min = -5,
    Max = 10,
    Default = Config.Aura.heightOffset,
    Increment = 0.5,
    ValueName = "studs",
    Callback = function(Value)
        Config.Aura.heightOffset = Value
    end
})

AuraTab:AddSlider({
    Name = "背中オフセット",
    Min = 0,
    Max = 10,
    Default = Config.Aura.backwardOffset,
    Increment = 0.5,
    ValueName = "studs",
    Callback = function(Value)
        Config.Aura.backwardOffset = Value
    end
})

-- 6. Visual Tab
local VisualTab = Window:MakeTab({ Name = "Visual", Icon = "rbxassetid://7733774602" })

VisualTab:AddLabel("空")

VisualTab:AddSlider({
    Name = "時間帯",
    Min = 0,
    Max = 23,
    Default = 14,
    Increment = 0.001,
    Callback = function(Value)
        Lighting.ClockTime = Value
    end
})

VisualTab:AddToggle({
    Name = "今の時間と同期",
    Default = false,
    Callback = function(Value)
        timesync = Value
        task.spawn(function()
            while timesync do
                local response = request({
                    Url = "https://www.timeapi.io/api/time/current/zone?timeZone=Europe%2FAmsterdam",
                    Method = "GET",
                })
                local data = HttpService:JSONDecode(response.Body)
                Lighting.TimeOfDay = string.format("%02d:%02d:%02d", 
                    tonumber(data.hour)+1, 
                    tonumber(data.minute), 
                    tonumber(data.seconds)
                )
                task.wait(1)
            end
        end)
    end
})

VisualTab:AddLabel("カメラ関係")

VisualTab:AddButton({
    Name = "三人称",
    Callback = function()
        LocalPlayer.CameraMaxZoomDistance = 8000000
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
    end
})

VisualTab:AddSlider({
    Name = "視野角",
    Min = 0,
    Max = 120,
    Default = 100,
    Increment = 1,
    Callback = function(siya)
        Camera.FieldOfView = siya
    end
})

-- 7. ESP Tab
local ESPTab = Window:MakeTab({ Name = "ESP", Icon = "rbxassetid://7733774602" })

ESPTab:AddToggle({
    Name = "ESP（ハイライト）",
    Default = false,
    Callback = function(value)
        ESPEnabled = value
    end
})

ESPTab:AddColorpicker({
    Name = "ハイライトカラー",
    Default = HighlightColor,
    Callback = function(value)
        HighlightColor = value
    end
})

ESPTab:AddSlider({
    Name = "ハイライトの透明度",
    Min = 0,
    Max = 1,
    Default = HighlightTransparency,
    Increment = 0.05,
    Callback = function(value)
        HighlightTransparency = value
    end
})

ESPTab:AddLabel("ボックス（箱）")

ESPTab:AddToggle({
    Name = "ESP（箱）",
    Default = false,
    Callback = function(value)
        ESPBoxEnabled = value
    end
})

ESPTab:AddColorpicker({
    Name = "箱のカラー",
    Default = ESPBoxColor,
    Callback = function(value)
        ESPBoxColor = value
    end
})

ESPTab:AddLabel("スケルトン（骨）")

ESPTab:AddToggle({
    Name = "ESP（スケルトン）",
    Default = false,
    Callback = function(state)
        SkeletonESPEnabled = state
    end
})

ESPTab:AddColorpicker({
    Name = "スケルトンの色",
    Default = SkeletonColor,
    Callback = function(color)
        SkeletonColor = color
    end
})

ESPTab:AddLabel("ライン（トレーサー）")

ESPTab:AddToggle({
    Name = "ライン表示",
    Default = false,
    Callback = function(Value)
        TracerESPEnabled = Value
    end
})

ESPTab:AddLabel("プレイヤー全ての名前を表示させるESP")

ESPTab:AddToggle({
    Name = "名前を表示する",
    Default = false,
    Callback = function(v)
        NameESPEnabled = v
    end
})

ESPTab:AddColorpicker({
    Name = "名前の色",
    Default = ESPColor,
    Callback = function(c)
        ESPColor = c
    end
})

-- 8. Wing Tab (Similar to Feather)
local WingTab = Window:MakeTab({ Name = "Wing", Icon = "rbxassetid://4483362458" })

WingTab:AddLabel("Wing features coming soon...")
WingTab:AddButton({
    Name = "Wing Test Button",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Wing System",
            Content = "Wing functionality is under development",
            Time = 3
        })
    end
})

-- 9. Info Tab
local InfoTab = Window:MakeTab({ Name = "Info", Icon = "rbxassetid://4483362458" })

InfoTab:AddLabel("Made in Lulu!")
InfoTab:AddButton({
    Name = "Discord Link!!",
    Callback = function()
        setclipboard("https://discord.gg/pS24D6zxf")
        OrionLib:MakeNotification({
            Name = "Discord Link Copied!",
            Content = "Discord link has been copied to clipboard",
            Time = 3
        })
    end
})

-- =============================================
--              MAIN LOOPS
-- =============================================

-- Grab Detection Loop
Workspace.ChildAdded:Connect(function(v)
    if v.Name == "GrabParts" and v:IsA("Model") then
        local GrabPart = v:FindFirstChild("GrabPart")
        if not GrabPart then return end
        
        local WeldConstraint = GrabPart:FindFirstChild("WeldConstraint")
        if not WeldConstraint or not WeldConstraint.Part1 then return end
        
        local target = WeldConstraint.Part1
        
        -- Super Strength
        if Config.Grab.SuperStrength then
            v:GetPropertyChangedSignal("Parent"):Connect(function()
                if not v.Parent and target and target.Parent then
                    local throwVel = Instance.new("BodyVelocity")
                    throwVel.MaxForce = Vector3.new(1e8, 1e8, 1e8)
                    throwVel.Velocity = Camera.CFrame.LookVector * Config.Grab.StrengthPower
                    throwVel.Parent = target
                    Debris:AddItem(throwVel, 0.1)
                end
            end)
        end
        
        -- Grab Options
        task.spawn(function()
            task.wait(0.1)
            
            if Config.Grab.VoidGrab then
                SetNetworkOwner(target)
                Velocity(target, Vector3.new(0, 10000, 0))
            end
            
            if Config.Grab.KillGrab then
                SetNetworkOwner(target)
                MoveTo(target, CFrame.new(4096, -75, 4096))
                Velocity(target, Vector3.new(0, -1000, 0))
            end
            
            if Config.Grab.KickGrab then
                local player = Players:GetPlayerFromCharacter(target.Parent)
                if player then
                    SetNetworkOwner(target)
                    MoveTo(target, CFrame.new(25e25, 25e25, 25e25))
                    task.wait(0.5)
                    ungrab(target)
                end
            end
            
            if Config.Grab.AnchorGrab then
                SetNetworkOwner(target)
                local pos = target.CFrame
                for _ = 1, 2 do
                    SetNetworkOwner(target)
                    local bp = Instance.new("BodyPosition")
                    bp.Position = pos.Position
                    bp.MaxForce = Vector3.new(1e8, 1e8, 1e8)
                    bp.Parent = target
                    
                    local bg = Instance.new("BodyGyro")
                    bg.CFrame = pos
                    bg.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
                    bg.Parent = target
                    
                    task.wait(0.5)
                end
            end
        end)
    end
end)

-- Anti Loop
local DefenseTimer = 0
RunService.Heartbeat:Connect(function(dt)
    DefenseTimer = DefenseTimer + dt

    if DefenseTimer >= 0.1 then
        -- Anti Grab
        if Config.Anti.AntiGrab or Config.Anti.StruggleSpam then
            pcall(function()
                ReplicatedStorage.CharacterEvents.Struggle:FireServer(LocalPlayer)
                ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer()
            end)
        end

        -- Anti Void
        if Config.Anti.AntiVoid then
            if HumanoidRootPart.Position.Y < -80 then
                HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
            end
        end

        -- Anti Ragdoll
        if Config.Anti.AntiRagdoll then
            if Humanoid:GetState() == Enum.HumanoidStateType.Ragdoll then
                Humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end

        DefenseTimer = 0
    end
end)

-- Player Movement Loop
RunService.Heartbeat:Connect(function()
    if Config.Player.SpeedEnabled and Humanoid then
        Humanoid.WalkSpeed = Config.Player.SpeedValue
    end
    if Config.Player.JumpEnabled and Humanoid then
        Humanoid.JumpPower = Config.Player.JumpValue
    end
    if Config.Player.Noclip and Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ESP Loop
local function updateESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local c = p.Character
            local h = c:FindFirstChild("Highlight")
            if ESPEnabled then
                if not h then
                    task.delay(1, function()
                        if ESPEnabled and not c:FindFirstChild("Highlight") then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "Highlight"
                            highlight.FillColor = HighlightColor
                            highlight.FillTransparency = HighlightTransparency
                            highlight.OutlineTransparency = 1
                            highlight.Adornee = c
                            highlight.Parent = c
                        end
                    end)
                else
                    h.FillColor = HighlightColor
                    h.FillTransparency = HighlightTransparency
                end
            elseif h then
                h:Destroy()
            end
        end
    end
end

-- Initialize OrionLib with yellow checkmarks
OrionLib:Init()

-- Make toggle checkmarks yellow
for _, obj in pairs(getgc(true)) do
    if type(obj) == "table" and rawget(obj, "Type") == "Toggle" then
        if rawget(obj, "Toggle") and rawget(obj, "ToggleFrame") then
            local toggleFrame = rawget(obj, "ToggleFrame")
            if toggleFrame and toggleFrame:FindFirstChild("Toggled") then
                toggleFrame.Toggled.BackgroundColor3 = Color3.fromRGB(255, 255, 0) -- Yellow
            end
        end
    end
end

OrionLib:MakeNotification({
    Name = "Noob Hub Loaded",
    Content = "All modules loaded successfully!",
    Time = 5
})
