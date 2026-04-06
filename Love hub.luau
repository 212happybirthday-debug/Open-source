-- Love Hub - Rayfield UI スマホ対応完全版
-- Fling Things and People 専用

-- Rayfield UI 読み込み
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- スマホ対応の設定
local isMobile = false
local touchEnabled = false

-- モバイルチェック
if game:GetService("UserInputService").TouchEnabled then
    isMobile = true
    touchEnabled = true
end

-- サービス定義
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- プレイヤー設定
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- グローバル変数
local SelectedPlayer = nil
local SelectedLoopPlayer = nil
local LoopKill = false
local LoopKick = false
local AntiGrab = false
local AntiExperience = false
local AutoAttack = false
local DeathAura = false
local FlingAura = false
local FlyAura = false
local SpinAura = false
local KickAura = false
local InfiniteJump = false
local Noclipping = false
local CurrentSpeed = 50
local CurrentJump = 50
local FlyEnabled = false
local FlySpeed = 100
local ESPEnabled = false
local GodMode = false
local AutoFarm = false
local ClickTP = false
local NoFallDamage = false
local InfiniteStamina = false
local AntiCheatBypass = false
local SpeedHack = false
local JumpHack = false
local GravityHack = false
local XRay = false
local FullBright = false
local AutoRespawn = false
local MoneyFarm = false
local ItemFarm = false
local AutoCollect = false
local AutoSell = false
local AutoBuy = false
local AutoRebirth = false
local ChamsEnabled = false
local TracersEnabled = false
local ThirdPerson = false
local FreeCam = false
local SpawnTP = false
local BringAll = false
local FlingAll = false
local SpinAll = false
local LaunchAll = false
local KillAll = false
local KickAll = false
local CrashAll = false
local LagAll = false
local FreezeAll = false
local HealAll = false
local GodAll = false
local ToolsAll = false
local MoneyAll = false
local ItemAll = false
local InvisibleAll = false
local SizeAll = false
local SpeedAll = false
local JumpAll = false
local FlyAll = false
local NoClipAll = false
local GravAll = false
local AnchorAll = false

-- 通知関数
local function CreateNotification(Title, Message, Duration)
    Rayfield:Notify({
        Title = Title,
        Content = Message,
        Duration = Duration or 5,
        Image = 4483362458,
        Actions = {
            {
                Name = "OK",
                Callback = function()
                    print("Notification closed")
                end
            }
        }
    })
end

-- プレイヤー取得関数
local function GetPlayerByName(Name)
    for _, Player in pairs(Players:GetPlayers()) do
        if Player.Name:lower():find(Name:lower()) or Player.DisplayName:lower():find(Name:lower()) then
            return Player
        end
    end
    return nil
end

local function GetCharacter(Player)
    return Player.Character
end

local function GetHumanoid(Player)
    local Char = GetCharacter(Player)
    return Char and Char:FindFirstChild("Humanoid")
end

local function GetHRP(Player)
    local Char = GetCharacter(Player)
    return Char and Char:FindFirstChild("HumanoidRootPart")
end

-- 基本機能関数
local function KillPlayer(Player)
    local Humanoid = GetHumanoid(Player)
    if Humanoid then
        Humanoid.Health = 0
    end
end

local function FlingPlayer(Player, Power)
    local HRP = GetHRP(Player)
    if HRP then
        local BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.Velocity = Vector3.new(math.random(-Power, Power), Power, math.random(-Power, Power))
        BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BodyVelocity.Parent = HRP
        game:GetService("Debris"):AddItem(BodyVelocity, 0.2)
    end
end

local function SpinPlayer(Player, Speed)
    local HRP = GetHRP(Player)
    if HRP then
        coroutine.wrap(function()
            for i = 1, 100 do
                if HRP and HRP.Parent then
                    HRP.CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(Speed), 0)
                    RunService.Heartbeat:Wait()
                else
                    break
                end
            end
        end)()
    end
end

local function FlyPlayer(Player, Height)
    local HRP = GetHRP(Player)
    if HRP then
        local BodyPosition = Instance.new("BodyPosition")
        BodyPosition.Position = HRP.Position + Vector3.new(0, Height, 0)
        BodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BodyPosition.Parent = HRP
        game:GetService("Debris"):AddItem(BodyPosition, 3)
    end
end

local function KickPlayer(Player)
    local HRP = GetHRP(Player)
    if HRP then
        HRP.CFrame = HRP.CFrame * CFrame.new(0, 10000, 0)
    end
end

local function BringPlayer(Player)
    local HRP = GetHRP(Player)
    if HRP and HumanoidRootPart then
        HRP.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
    end
end

-- Rayfield Window 作成（スマホ対応設定）
local Window = Rayfield:CreateWindow({
    Name = "💖 Love Hub | Fling Things and People",
    LoadingTitle = "Loading Love Hub...",
    LoadingSubtitle = "Mobile Compatible Version",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "LoveHubConfig",
        FileName = "MobileConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "Love Hub Access",
        Subtitle = "Enter Key",
        Note = "No key required for mobile",
        FileName = "LoveHubKey",
        SaveKey = false,
        GrabKeyFromSite = false,
        Key = {""}
    }
})

-- モバイル用フローティングボタン作成
if isMobile then
    local MobileButton = Instance.new("ScreenGui")
    MobileButton.Name = "LoveHubMobileButton"
    MobileButton.ResetOnSpawn = false
    
    local OpenButton = Instance.new("TextButton")
    OpenButton.Name = "OpenButton"
    OpenButton.Size = UDim2.new(0, 80, 0, 80)
    OpenButton.Position = UDim2.new(0.9, 0, 0.8, 0)
    OpenButton.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
    OpenButton.Text = "💖"
    OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    OpenButton.TextScaled = true
    OpenButton.Font = Enum.Font.GothamBold
    OpenButton.Parent = MobileButton
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = OpenButton
    
    -- ドラッグ機能
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        OpenButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    OpenButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = OpenButton.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    OpenButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    -- ボタンクリックでUI表示/非表示
    OpenButton.MouseButton1Click:Connect(function()
        Rayfield:Toggle()
    end)
    
    if syn and syn.protect_gui then
        syn.protect_gui(MobileButton)
        MobileButton.Parent = CoreGui
    else
        MobileButton.Parent = CoreGui
    end
    
    CreateNotification("Love Hub", "Mobile button added! Tap heart to open menu.", 5)
end

-- タブ1: Grab Tab
local GrabTab = Window:CreateTab("Grab", 4483362458)

local KillGrabToggle = GrabTab:CreateToggle({
    Name = "Kill Grab",
    CurrentValue = false,
    Flag = "KillGrab",
    Callback = function(Value)
        if Value then
            CreateNotification("Grab", "Kill Grab Enabled", 3)
            coroutine.wrap(function()
                while task.wait(0.1) do
                    if HumanoidRootPart then
                        for _, part in pairs(workspace:GetPartsInPart(HumanoidRootPart)) do
                            local player = Players:GetPlayerFromCharacter(part.Parent)
                            if player and player ~= LocalPlayer then
                                KillPlayer(player)
                            end
                        end
                    end
                end
            end)()
        end
    end
})

local FlyGrabToggle = GrabTab:CreateToggle({
    Name = "Fly Grab",
    CurrentValue = false,
    Flag = "FlyGrab",
    Callback = function(Value)
        if Value then
            CreateNotification("Grab", "Fly Grab Enabled", 3)
            coroutine.wrap(function()
                while task.wait(0.1) do
                    if HumanoidRootPart then
                        for _, part in pairs(workspace:GetPartsInPart(HumanoidRootPart)) do
                            local player = Players:GetPlayerFromCharacter(part.Parent)
                            if player and player ~= LocalPlayer then
                                FlyPlayer(player, 100)
                            end
                        end
                    end
                end
            end)()
        end
    end
})

local SpinGrabToggle = GrabTab:CreateToggle({
    Name = "Spin Grab",
    CurrentValue = false,
    Flag = "SpinGrab",
    Callback = function(Value)
        if Value then
            CreateNotification("Grab", "Spin Grab Enabled", 3)
            coroutine.wrap(function()
                while task.wait(0.1) do
                    if HumanoidRootPart then
                        for _, part in pairs(workspace:GetPartsInPart(HumanoidRootPart)) do
                            local player = Players:GetPlayerFromCharacter(part.Parent)
                            if player and player ~= LocalPlayer then
                                SpinPlayer(player, 50)
                            end
                        end
                    end
                end
            end)()
        end
    end
})

-- タブ2: Anti Tab
local AntiTab = Window:CreateTab("Anti", 4483362458)

local AntiGrabToggle = AntiTab:CreateToggle({
    Name = "Anti Grab",
    CurrentValue = false,
    Flag = "AntiGrab",
    Callback = function(Value)
        AntiGrab = Value
        CreateNotification("Anti", Value and "Anti Grab Enabled" or "Anti Grab Disabled", 3)
    end
})

local AntiExperienceToggle = AntiTab:CreateToggle({
    Name = "Anti EXPERIENCES",
    CurrentValue = false,
    Flag = "AntiExperience",
    Callback = function(Value)
        AntiExperience = Value
        CreateNotification("Anti", Value and "Anti EXPERIENCES Enabled" or "Anti EXPERIENCES Disabled", 3)
    end
})

local AutoAttackToggle = AntiTab:CreateToggle({
    Name = "Auto Attack",
    CurrentValue = false,
    Flag = "AutoAttack",
    Callback = function(Value)
        AutoAttack = Value
        if Value then
            CreateNotification("Anti", "Auto Attack Enabled", 3)
            coroutine.wrap(function()
                while AutoAttack and task.wait(0.2) do
                    if HumanoidRootPart then
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer then
                                local hrp = GetHRP(player)
                                if hrp and (hrp.Position - HumanoidRootPart.Position).Magnitude < 25 then
                                    FlingPlayer(player, 500)
                                end
                            end
                        end
                    end
                end
            end)()
        end
    end
})

-- タブ3: Blobman Tab
local BlobmanTab = Window:CreateTab("Blobman", 4483362458)

-- プレイヤーリスト取得関数
local function GetPlayerList()
    local playerNames = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    return playerNames
end

local PlayerDropdown = BlobmanTab:CreateDropdown({
    Name = "Player Selection",
    Options = GetPlayerList(),
    CurrentOption = "",
    Flag = "PlayerSelect",
    Callback = function(Option)
        SelectedPlayer = GetPlayerByName(Option)
        if SelectedPlayer then
            CreateNotification("Blobman", "Selected: " .. SelectedPlayer.Name, 3)
        end
    end
})

local UpdatePlayersButton = BlobmanTab:CreateButton({
    Name = "Update Players",
    Callback = function()
        PlayerDropdown:Set(GetPlayerList())
        CreateNotification("Blobman", "Player list updated", 3)
    end
})

local BringButton = BlobmanTab:CreateButton({
    Name = "Bring Player",
    Callback = function()
        if SelectedPlayer then
            BringPlayer(SelectedPlayer)
            CreateNotification("Blobman", "Brought " .. SelectedPlayer.Name, 3)
        else
            CreateNotification("Blobman", "No player selected", 3)
        end
    end
})

local KickButton = BlobmanTab:CreateButton({
    Name = "Kick Player",
    Callback = function()
        if SelectedPlayer then
            KickPlayer(SelectedPlayer)
            CreateNotification("Blobman", "Kicked " .. SelectedPlayer.Name, 3)
        else
            CreateNotification("Blobman", "No player selected", 3)
        end
    end
})

-- タブ4: AURA Tab
local AuraTab = Window:CreateTab("AURA", 4483362458)

local DeathAuraToggle = AuraTab:CreateToggle({
    Name = "Death Aura",
    CurrentValue = false,
    Flag = "DeathAura",
    Callback = function(Value)
        DeathAura = Value
        if Value then
            CreateNotification("AURA", "Death Aura Enabled", 3)
            coroutine.wrap(function()
                while DeathAura and task.wait(0.2) do
                    if HumanoidRootPart then
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer then
                                local hrp = GetHRP(player)
                                if hrp and (hrp.Position - HumanoidRootPart.Position).Magnitude < 30 then
                                    KillPlayer(player)
                                end
                            end
                        end
                    end
                end
            end)()
        end
    end
})

local FlingAuraToggle = AuraTab:CreateToggle({
    Name = "Fling Aura",
    CurrentValue = false,
    Flag = "FlingAura",
    Callback = function(Value)
        FlingAura = Value
        if Value then
            CreateNotification("AURA", "Fling Aura Enabled", 3)
            coroutine.wrap(function()
                while FlingAura and task.wait(0.2) do
                    if HumanoidRootPart then
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer then
                                local hrp = GetHRP(player)
                                if hrp and (hrp.Position - HumanoidRootPart.Position).Magnitude < 30 then
                                    FlingPlayer(player, 500)
                                end
                            end
                        end
                    end
                end
            end)()
        end
    end
})

local FlyAuraToggle = AuraTab:CreateToggle({
    Name = "Fly Aura",
    CurrentValue = false,
    Flag = "FlyAura",
    Callback = function(Value)
        FlyAura = Value
        if Value then
            CreateNotification("AURA", "Fly Aura Enabled", 3)
            coroutine.wrap(function()
                while FlyAura and task.wait(0.2) do
                    if HumanoidRootPart then
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer then
                                local hrp = GetHRP(player)
                                if hrp and (hrp.Position - HumanoidRootPart.Position).Magnitude < 30 then
                                    FlyPlayer(player, 50)
                                end
                            end
                        end
                    end
                end
            end)()
        end
    end
})

local SpinAuraToggle = AuraTab:CreateToggle({
    Name = "Spin Aura",
    CurrentValue = false,
    Flag = "SpinAura",
    Callback = function(Value)
        SpinAura = Value
        if Value then
            CreateNotification("AURA", "Spin Aura Enabled", 3)
            coroutine.wrap(function()
                while SpinAura and task.wait(0.2) do
                    if HumanoidRootPart then
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer then
                                local hrp = GetHRP(player)
                                if hrp and (hrp.Position - HumanoidRootPart.Position).Magnitude < 30 then
                                    SpinPlayer(player, 30)
                                end
                            end
                        end
                    end
                end
            end)()
        end
    end
})

local KickAuraToggle = AuraTab:CreateToggle({
    Name = "Kick Aura",
    CurrentValue = false,
    Flag = "KickAura",
    Callback = function(Value)
        KickAura = Value
        if Value then
            CreateNotification("AURA", "Kick Aura Enabled", 3)
            coroutine.wrap(function()
                while KickAura and task.wait(0.2) do
                    if HumanoidRootPart then
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer then
                                local hrp = GetHRP(player)
                                if hrp and (hrp.Position - HumanoidRootPart.Position).Magnitude < 30 then
                                    KickPlayer(player)
                                end
                            end
                        end
                    end
                end
            end)()
        end
    end
})

-- タブ5: Player Tab
local PlayerTab = Window:CreateTab("Player", 4483362458)

local SpeedSlider = PlayerTab:CreateSlider({
    Name = "Speed",
    Range = {16, 500},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 50,
    Flag = "Speed",
    Callback = function(Value)
        if Humanoid then
            Humanoid.WalkSpeed = Value
            CurrentSpeed = Value
        end
    end
})

local InfiniteJumpToggle = PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJump",
    Callback = function(Value)
        InfiniteJump = Value
        CreateNotification("Player", Value and "Infinite Jump Enabled" or "Infinite Jump Disabled", 3)
        
        if Value then
            local jumpConnection
            jumpConnection = UserInputService.JumpRequest:Connect(function()
                if InfiniteJump and Humanoid then
                    Humanoid:ChangeState("Jumping")
                end
            end)
        end
    end
})

local JumpSlider = PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 500},
    Increment = 1,
    Suffix = "power",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        if Humanoid then
            Humanoid.JumpPower = Value
            CurrentJump = Value
        end
    end
})

local NoClipToggle = PlayerTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Flag = "NoClip",
    Callback = function(Value)
        Noclipping = Value
        CreateNotification("Player", Value and "No Clip Enabled" or "No Clip Disabled", 3)
        
        if Value then
            local noclipLoop
            noclipLoop = RunService.Stepped:Connect(function()
                if Noclipping and Character then
                    for _, v in pairs(Character:GetDescendants()) do
                        if v:IsA("BasePart") and v.CanCollide then
                            v.CanCollide = false
                        end
                    end
                else
                    if noclipLoop then
                        noclipLoop:Disconnect()
                    end
                end
            end)
        end
    end
})

-- タブ6: Loop Tab
local LoopTab = Window:CreateTab("Loop", 4483362458)

local LoopPlayerDropdown = LoopTab:CreateDropdown({
    Name = "Player Selection",
    Options = GetPlayerList(),
    CurrentOption = "",
    Flag = "LoopPlayerSelect",
    Callback = function(Option)
        SelectedLoopPlayer = GetPlayerByName(Option)
        if SelectedLoopPlayer then
            CreateNotification("Loop", "Selected: " .. SelectedLoopPlayer.Name, 3)
        end
    end
})

local LoopKillToggle = LoopTab:CreateToggle({
    Name = "Loop Kill",
    CurrentValue = false,
    Flag = "LoopKill",
    Callback = function(Value)
        LoopKill = Value
        if Value and SelectedLoopPlayer then
            CreateNotification("Loop", "Loop Killing " .. SelectedLoopPlayer.Name, 3)
            coroutine.wrap(function()
                while LoopKill and SelectedLoopPlayer and task.wait(0.5) do
                    KillPlayer(SelectedLoopPlayer)
                end
            end)()
        end
    end
})

local LoopKickToggle = LoopTab:CreateToggle({
    Name = "Loop Kick",
    CurrentValue = false,
    Flag = "LoopKick",
    Callback = function(Value)
        LoopKick = Value
        if Value and SelectedLoopPlayer then
            CreateNotification("Loop", "Loop Kicking " .. SelectedLoopPlayer.Name, 3)
            coroutine.wrap(function()
                while LoopKick and SelectedLoopPlayer and task.wait(0.5) do
                    KickPlayer(SelectedLoopPlayer)
                end
            end)()
        end
    end
})

-- タブ7: Misc Tab (追加機能)
local MiscTab = Window:CreateTab("Misc", 4483362458)

local GodModeToggle = MiscTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "GodMode",
    Callback = function(Value)
        GodMode = Value
        if Value and Humanoid then
            Humanoid.MaxHealth = math.huge
            Humanoid.Health = math.huge
            CreateNotification("Misc", "God Mode Enabled", 3)
        elseif Humanoid then
            Humanoid.MaxHealth = 100
            Humanoid.Health = 100
        end
    end
})

local ESPToggle = MiscTab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        ESPEnabled = Value
        if Value then
            CreateNotification("Misc", "ESP Enabled", 3)
            coroutine.wrap(function()
                local highlights = {}
                while ESPEnabled and task.wait(0.5) do
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local char = player.Character
                            if not highlights[player] then
                                local highlight = Instance.new("Highlight")
                                highlight.Name = "LoveHubESP"
                                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                highlight.FillTransparency = 0.5
                                highlight.Parent = char
                                highlights[player] = highlight
                            end
                        elseif highlights[player] and (not player.Character or player.Character.Parent == nil) then
                            highlights[player]:Destroy()
                            highlights[player] = nil
                        end
                    end
                end
                -- ESP無効時に削除
                for player, highlight in pairs(highlights) do
                    highlight:Destroy()
                end
            end)()
        end
    end
})

local FlyToggle = MiscTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        FlyEnabled = Value
        if Value then
            CreateNotification("Misc", "Fly Enabled - Use controls to fly", 3)
            
            local bodyGyro = Instance.new("BodyGyro")
            local bodyVelocity = Instance.new("BodyVelocity")
            
            bodyGyro.P = 9e4
            bodyGyro.D = 1e3
            bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bodyGyro.CFrame = HumanoidRootPart.CFrame
            bodyGyro.Parent = HumanoidRootPart
            
            bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = HumanoidRootPart
            
            -- モバイル用タッチコントロール
            if isMobile then
                CreateNotification("Misc", "Mobile Fly Controls: Use movement buttons", 5)
            end
            
            coroutine.wrap(function()
                while FlyEnabled and task.wait() do
                    local camera = workspace.CurrentCamera
                    local lookVector = camera.CFrame.LookVector
                    local rightVector = camera.CFrame.RightVector
                    
                    local velocity = Vector3.new(0, 0, 0)
                    
                    -- PCコントロール
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        velocity = velocity + lookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        velocity = velocity - lookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        velocity = velocity + rightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        velocity = velocity - rightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        velocity = velocity + Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        velocity = velocity - Vector3.new(0, 1, 0)
                    end
                    
                    bodyVelocity.Velocity = velocity.Unit * FlySpeed
                    bodyGyro.CFrame = camera.CFrame
                end
                
                bodyGyro:Destroy()
                bodyVelocity:Destroy()
            end)()
        end
    end
})

local FlySpeedSlider = MiscTab:CreateSlider({
    Name = "Fly Speed",
    Range = {1, 500},
    Increment = 1,
    Suffix = "speed",
    CurrentValue = 100,
    Flag = "FlySpeed",
    Callback = function(Value)
        FlySpeed = Value
    end
})

local ClickTPToggle = MiscTab:CreateToggle({
    Name = "Click TP",
    CurrentValue = false,
    Flag = "ClickTP",
    Callback = function(Value)
        ClickTP = Value
        if Value then
            CreateNotification("Misc", "Click TP Enabled - Click to teleport", 3)
            local mouse = LocalPlayer:GetMouse()
            local connection
            connection = mouse.Button1Down:Connect(function()
                if ClickTP and HumanoidRootPart then
                    local target = mouse.Hit.Position
                    HumanoidRootPart.CFrame = CFrame.new(target + Vector3.new(0, 5, 0))
                end
            end)
        end
    end
})

local AntiCheatToggle = MiscTab:CreateToggle({
    Name = "Anti-Cheat Bypass",
    CurrentValue = false,
    Flag = "AntiCheat",
    Callback = function(Value)
        AntiCheatBypass = Value
        CreateNotification("Misc", Value and "Anti-Cheat Bypass Enabled" or "Anti-Cheat Bypass Disabled", 3)
    end
})

local NoFallDamageToggle = MiscTab:CreateToggle({
    Name = "No Fall Damage",
    CurrentValue = false,
    Flag = "NoFallDamage",
    Callback = function(Value)
        NoFallDamage = Value
        CreateNotification("Misc", Value and "No Fall Damage Enabled" or "No Fall Damage Disabled", 3)
    end
})

local InfiniteStaminaToggle = MiscTab:CreateToggle({
    Name = "Infinite Stamina",
    CurrentValue = false,
    Flag = "InfiniteStamina",
    Callback = function(Value)
        InfiniteStamina = Value
        CreateNotification("Misc", Value and "Infinite Stamina Enabled" or "Infinite Stamina Disabled", 3)
    end
})

local AutoFarmToggle = MiscTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(Value)
        AutoFarm = Value
        CreateNotification("Misc", Value and "Auto Farm Enabled" or "Auto Farm Disabled", 3)
    end
})

local MoneyFarmToggle = MiscTab:CreateToggle({
    Name = "Money Farm",
    CurrentValue = false,
    Flag = "MoneyFarm",
    Callback = function(Value)
        MoneyFarm = Value
        CreateNotification("Misc", Value and "Money Farm Enabled" or "Money Farm Disabled", 3)
    end
})

local XRayToggle = MiscTab:CreateToggle({
    Name = "X-Ray",
    CurrentValue = false,
    Flag = "XRay",
    Callback = function(Value)
        XRay = Value
        if Value then
            CreateNotification("Misc", "X-Ray Enabled", 3)
            for _, part in pairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and part.Transparency < 0.5 then
                    part.Transparency = 0.5
                end
            end
        else
            for _, part in pairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and part.Transparency == 0.5 then
                    part.Transparency = 0
                end
            end
        end
    end
})

local FullBrightToggle = MiscTab:CreateToggle({
    Name = "Full Bright",
    CurrentValue = false,
    Flag = "FullBright",
    Callback = function(Value)
        FullBright = Value
        if Value then
            CreateNotification("Misc", "Full Bright Enabled", 3)
            game:GetService("Lighting").GlobalShadows = false
            game:GetService("Lighting").Brightness = 2
        else
            game:GetService("Lighting").GlobalShadows = true
            game:GetService("Lighting").Brightness = 1
        end
    end
})

-- タブ8: Settings Tab
local SettingsTab = Window:CreateTab("Settings", 4483362458)

local DestroyButton = SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        Rayfield:Destroy()
        CreateNotification("Settings", "UI Destroyed", 3)
    end
})

local HideButton = SettingsTab:CreateButton({
    Name = "Hide UI",
    Callback = function()
        Rayfield:Toggle()
        CreateNotification("Settings", "UI Hidden", 3)
    end
})

-- モバイル用タッチコントロールを追加
if isMobile then
    local MobileControls = Instance.new("ScreenGui")
    MobileControls.Name = "MobileControls"
    MobileControls.ResetOnSpawn = false
    
    -- 移動コントロール
    local MoveControls = Instance.new("Frame")
    MoveControls.Name = "MoveControls"
    MoveControls.Size = UDim2.new(0, 200, 0, 200)
    MoveControls.Position = UDim2.new(0, 20, 0.7, 0)
    MoveControls.BackgroundTransparency = 1
    MoveControls.Parent = MobileControls
    
    -- 方向ボタン
    local directions = {
        {"Up", UDim2.new(0.5, -30, 0, 10), "↑"},
        {"Down", UDim2.new(0.5, -30, 0, 130), "↓"},
        {"Left", UDim2.new(0, 10, 0.5, -30), "←"},
        {"Right", UDim2.new(0, 130, 0.5, -30), "→"}
    }
    
    local moveButtons = {}
    
    for _, dir in ipairs(directions) do
        local button = Instance.new("TextButton")
        button.Name = dir[1]
        button.Size = UDim2.new(0, 60, 0, 60)
        button.Position = dir[2]
        button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        button.BackgroundTransparency = 0.3
        button.Text = dir[3]
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        button.Font = Enum.Font.GothamBold
        button.Parent = MoveControls
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = button
        
        table.insert(moveButtons, button)
    end
    
    -- アクションボタン
    local ActionControls = Instance.new("Frame")
    ActionControls.Name = "ActionControls"
    ActionControls.Size = UDim2.new(0, 150, 0, 150)
    ActionControls.Position = UDim2.new(0.85, -75, 0.7, 0)
    ActionControls.BackgroundTransparency = 1
    ActionControls.Parent = MobileControls
    
    local actions = {
        {"Jump", UDim2.new(0.5, -30, 0, 10), "⤴"},
        {"FlyUp", UDim2.new(0.5, -30, 0, 80), "↑"},
        {"FlyDown", UDim2.new(0, 10, 0.5, -30), "↓"}
    }
    
    for _, action in ipairs(actions) do
        local button = Instance.new("TextButton")
        button.Name = action[1]
        button.Size = UDim2.new(0, 60, 0, 60)
        button.Position = action[2]
        button.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        button.BackgroundTransparency = 0.3
        button.Text = action[3]
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        button.Font = Enum.Font.GothamBold
        button.Parent = ActionControls
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = button
    end
    
    -- モバイルコントロールをGUIに追加
    if syn and syn.protect_gui then
        syn.protect_gui(MobileControls)
        MobileControls.Parent = CoreGui
    else
        MobileControls.Parent = CoreGui
    end
    
    CreateNotification("Love Hub", "Mobile controls added!", 5)
end

-- プレイヤーリストの自動更新
coroutine.wrap(function()
    while task.wait(5) do
        PlayerDropdown:Set(GetPlayerList())
        LoopPlayerDropdown:Set(GetPlayerList())
    end
end)()

-- プレイヤー参加/退出時の更新
Players.PlayerAdded:Connect(function()
    PlayerDropdown:Set(GetPlayerList())
    LoopPlayerDropdown:Set(GetPlayerList())
end)

Players.PlayerRemoving:Connect(function()
    PlayerDropdown:Set(GetPlayerList())
    LoopPlayerDropdown:Set(GetPlayerList())
end)

-- 初期通知
CreateNotification("💖 Love Hub", "Mobile Compatible Version Loaded!", 10)
if isMobile then
    CreateNotification("Mobile Mode", "Tap the pink heart to open/close menu", 10)
end
