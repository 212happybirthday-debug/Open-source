-- Noob Hub - Integrated Script
-- Combined from multiple sources: Player, Target, Grab, Blobman, Anti, Teleport, Aura, Visual, ESP, Wing

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LP = Players.LocalPlayer

-- OrionLib
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion"))()
local Window = OrionLib:MakeWindow({
    Name = "Noob Hub",
    HidePremium = true,
    SaveConfig = false,
    IntroEnabled = false,
    Theme = {
        Toggle = {
            EnabledColor = Color3.fromRGB(255, 255, 0), -- 黄色のチェックマーク
        }
    }
})

-- Global Configuration
local Config = {
    Player = {
        SpeedValue = 16,
        JumpValue = 50,
        SpeedEnabled = false,
        JumpEnabled = false,
        Noclip = false
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
    Grab = {
        KickGrab = false,
        KillGrab = false,
        VoidGrab = false,
        AnchorGrab = false,
        SuperStrength = false,
        StrengthPower = 250,
        PoisonGrab = false,
        FireGrab = false,
        RadioactiveGrab = false,
        NoclipGrab = false,
        SkyGrab = false,
        GroundGrab = false,
        ThrowPower = 400,
        ThrowEnabled = false
    },
    Aura = {
        KillAura = false,
        VoidAura = false,
        RagdollAura = false,
        FireAura = false,
        AnchorAura = false,
        NoclipAura = false,
        Radius = 32
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
    Visual = {
        TimeSync = false,
        FakeCoins = "0",
        FOV = 100,
        ThirdPerson = false
    },
    ESP = {
        Enabled = false,
        BoxEnabled = false,
        SkeletonEnabled = false,
        TracerEnabled = false,
        NameEnabled = false,
        HighlightColor = Color3.fromRGB(255, 0, 0),
        HighlightTransparency = 0.6,
        BoxColor = Color3.fromRGB(255, 255, 255),
        SkeletonColor = Color3.fromRGB(255, 255, 255),
        SkeletonThickness = 1.5,
        NameColor = Color3.fromRGB(255, 255, 255),
        NameSize = 13
    },
    Wing = {
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

-- Helper Functions
local function HRP()
    local c = LP.Character or LP.CharacterAdded:Wait()
    return c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = LP.Character
    if not c then return nil end
    return c:FindFirstChildOfClass("Humanoid")
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
    b.P, b.D = 2e4, 5e3
    b.Parent = part
    task.spawn(function()
        task.wait(1)
        pcall(function()
            b:Destroy()
            for _, v in ipairs(part.Parent:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end)
    end)
end

local function ungrab(part)
    pcall(function()
        ReplicatedStorage.GrabEvents.DestroyGrabLine:FireServer(part)
    end)
end

local function GetNearParts(origin, radius)
    return Workspace:GetPartBoundsInRadius(origin, radius)
end

-- Player Movement
local speedConnection
local jumpConnection
local noclipConnection

local function updatePlayerMovement()
    if speedConnection then speedConnection:Disconnect() end
    if jumpConnection then jumpConnection:Disconnect() end
    if noclipConnection then noclipConnection:Disconnect() end
    
    if Config.Player.SpeedEnabled then
        speedConnection = RunService.Heartbeat:Connect(function()
            if LP.Character and LP.Character:FindFirstChild("Humanoid") then
                LP.Character.Humanoid.WalkSpeed = Config.Player.SpeedValue
            end
        end)
    end
    
    if Config.Player.JumpEnabled then
        jumpConnection = RunService.Heartbeat:Connect(function()
            if LP.Character and LP.Character:FindFirstChild("Humanoid") then
                LP.Character.Humanoid.JumpPower = Config.Player.JumpValue
            end
        end)
    end
    
    if Config.Player.Noclip then
        noclipConnection = RunService.Stepped:Connect(function()
            if LP.Character then
                for _, part in ipairs(LP.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

-- Loop (Target) Functions
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
        if player ~= LP then
            table.insert(displayNames, player.DisplayName)
        end
    end
    return displayNames
end

local function Snipefunc(root, func, ...)
    if not root or not root.Parent then return end
    local pos = HRP().CFrame
    local args = {...}
    task.spawn(function()
        local parts = {"Head", "Torso", "HumanoidRootPart"}
        for _, p in pairs(parts) do
            local part = LP.Character:FindFirstChild(p)
            if part then part.CanCollide = false end
        end
        local targetPos = root.Position
        HRP().CFrame = CFrame.new(targetPos.X, targetPos.Y - 6, targetPos.Z)
        task.wait(0.1)
        Workspace.CurrentCamera.CFrame = CFrame.lookAt(Workspace.CurrentCamera.CFrame.Position, root.Position)
        for _ = 1, 4 do
            SetNetworkOwner(root, HRP().CFrame)
            task.wait(0.05)
        end
        local look = Workspace.CurrentCamera.CFrame
        task.wait(0.1)
        func(unpack(args))
        Workspace.CurrentCamera.CFrame = look
        task.wait(0.1)
        for _, p in pairs(parts) do
            local part = LP.Character:FindFirstChild(p)
            if part then part.CanCollide = true end
        end
        HRP().CFrame = pos
        Velocity(HRP(), Vector3.zero)
    end)
end

local function SnipeKill(target)
    local character = target.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    Snipefunc(root, function()
        MoveTo(root, CFrame.new(4096, -75, 4096))
        Velocity(root, Vector3.new(0, -1000, 0))
    end)
end

local function SnipeVoid(target)
    local character = target.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    Snipefunc(root, function()
        Velocity(root, Vector3.new(0, 10000, 0))
    end)
end

local function SnipePoison(target)
    local character = target.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    Snipefunc(root, function()
        MoveTo(root, CFrame.new(58, -70, 271))
    end)
end

local function SnipeRagdoll(target)
    local character = target.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    Snipefunc(root, function()
        local rpos = root.CFrame
        Velocity(root, Vector3.new(0, -64, 0))
        task.wait(0.1)
        HRP().CFrame = rpos
        Velocity(root, Vector3.zero)
    end)
end

local function SnipeDeath(target)
    local character = target.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    Snipefunc(root, function()
        local hum = character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Dead) end
        task.wait(0.5)
        ungrab(root)
    end)
end

local function SnipeBring(target)
    local character = target.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local pos = HRP().CFrame
    Snipefunc(root, function()
        task.wait(0.01)
        root.CFrame = pos
        task.wait(0.5)
        ungrab(root)
    end)
end

local function SnipePull(target)
    local character = target.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    Snipefunc(root, function()
        local bp = Instance.new("BodyPosition")
        bp.Name = "PullBodyPosition"
        bp.MaxForce = Vector3.new(1e8, 1e8, 1e8)
        bp.P, bp.D = 1e6, 1e5
        bp.Parent = root
        task.spawn(function()
            while bp and bp.Parent do
                if not root or not root.Parent then break end
                local currentMyPos = HRP().Position
                bp.Position = currentMyPos
                root.CFrame = CFrame.new(currentMyPos)
                SetNetworkOwner(root)
                task.wait(0.05)
            end
        end)
        task.wait(0.1)
    end)
    task.delay(2, function()
        if root and root.Parent then
            local bp = root:FindFirstChild("PullBodyPosition")
            if bp then bp:Destroy() end
            ungrab(root)
        end
    end)
end

-- Aura Functions
local AuraTimer = 0

-- Anti Functions
local AntiExplodeConnection
local function SetupAntiExplode()
    if Config.Anti.AntiExplode then
        if AntiExplodeConnection then return end
        AntiExplodeConnection = Workspace.ChildAdded:Connect(function(child)
            if child.Name:find("Explosion") or child.Name:find("Bomb") then
                pcall(function() child:Destroy() end)
            end
        end)
    else
        if AntiExplodeConnection then
            AntiExplodeConnection:Disconnect()
            AntiExplodeConnection = nil
        end
    end
end

local function Struggle()
    pcall(function()
        ReplicatedStorage.CharacterEvents.Struggle:FireServer(LP)
        ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer()
    end)
end

-- ESP Functions
local Camera = Workspace.CurrentCamera
local SkeletonLines = {}
local TracerLines = {}
local nameESPObjects = {}
local highlights = {}

local function getRainbowColor(offset)
    local t = tick() + (offset or 0)
    return Color3.new(
        math.sin(t * 2) * 0.5 + 0.5,
        math.sin(t * 2 + 2) * 0.5 + 0.5,
        math.sin(t * 2 + 4) * 0.5 + 0.5
    )
end

local function GetBone(char, name)
    return char:FindFirstChild(name)
end

local function GetLineTable(player)
    if not SkeletonLines[player] then
        SkeletonLines[player] = {
            Head = Drawing.new("Line"),
            Neck = Drawing.new("Line"),
            Spine = Drawing.new("Line"),
            LeftArm = Drawing.new("Line"),
            RightArm = Drawing.new("Line"),
            LeftLeg = Drawing.new("Line"),
            RightLeg = Drawing.new("Line")
        }
    end
    return SkeletonLines[player]
end

local function createTracer(player)
    if player == LP or TracerLines[player] then return end
    local line = Drawing.new("Line")
    line.Visible = false
    line.Thickness = 1
    line.Transparency = 1
    TracerLines[player] = line
end

local function removeTracer(player)
    if TracerLines[player] then
        TracerLines[player]:Remove()
        TracerLines[player] = nil
    end
end

local function highlightCharacter(char)
    if not Config.ESP.Enabled or char:FindFirstChild("Highlight") then return end
    task.delay(1, function()
        if Config.ESP.Enabled and not char:FindFirstChild("Highlight") then
            local h = Instance.new("Highlight")
            h.Name = "Highlight"
            h.FillColor = Config.ESP.HighlightColor
            h.FillTransparency = Config.ESP.HighlightTransparency
            h.OutlineTransparency = 1
            h.Adornee = char
            h.Parent = char
            highlights[char] = h
        end
    end)
end

local function addBoxESP(char)
    if not Config.ESP.BoxEnabled or char:FindFirstChild("BoxESP") then return end
    task.delay(1, function()
        local root = char:FindFirstChild("HumanoidRootPart")
        if root and not root:FindFirstChild("BoxESP") then
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "BoxESP"
            box.Size = Vector3.new(4, 6, 2)
            box.Adornee = root
            box.AlwaysOnTop = true
            box.ZIndex = 5
            box.Transparency = 0.5
            box.Color3 = Config.ESP.BoxColor
            box.Parent = root
        end
    end)
end

local function updateESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local c = p.Character
            local h = c:FindFirstChild("Highlight")
            if Config.ESP.Enabled then
                if not h then
                    highlightCharacter(c)
                else
                    h.FillColor = Config.ESP.HighlightColor
                    h.FillTransparency = Config.ESP.HighlightTransparency
                end
            elseif h then
                h:Destroy()
            end
        end
    end
end

local function updateBoxESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if Config.ESP.BoxEnabled and root then
                if not root:FindFirstChild("BoxESP") then
                    addBoxESP(p.Character)
                else
                    root:FindFirstChild("BoxESP").Color3 = Config.ESP.BoxColor
                end
            elseif root and root:FindFirstChild("BoxESP") then
                root:FindFirstChild("BoxESP"):Destroy()
            end
        end
    end
end

local function setupPlayer(player)
    if player == LP then return end
    if player.Character then
        if Config.ESP.Enabled then highlightCharacter(player.Character) end
        if Config.ESP.BoxEnabled then addBoxESP(player.Character) end
    end
    player.CharacterAdded:Connect(function(char)
        char:WaitForChild("HumanoidRootPart", 5)
        if Config.ESP.Enabled then highlightCharacter(char) end
        if Config.ESP.BoxEnabled then addBoxESP(char) end
    end)
end

-- Wing (Feather) Functions
local WingToys = {}
local WingRowPoints = {}
local WingAssignedToys = {}
local WingLoopConn = nil
local WingTime = 0

local function findFireworkSparklers()
    local sparklers = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "FireworkSparkler" and obj:IsA("Model") then
            table.insert(sparklers, obj)
        end
    end
    return sparklers
end

local function getPrimaryPart(model)
    return model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
end

local function createWingRowPoints(count)
    local points = {}
    
    if count == 0 then return points end
    
    local totalWidth = (count - 1) * Config.Wing.spacing
    local startX = -totalWidth / 2
    
    for i = 1, count do
        local x = startX + (i - 1) * Config.Wing.spacing
        local part = Instance.new("Part")
        part.CanCollide = false
        part.Anchored = true
        part.Transparency = 1
        part.Size = Vector3.new(4, 1, 4)
        part.Parent = Workspace
        
        points[i] = {
            offsetX = x,
            part = part,
            assignedToy = nil,
        }
    end
    
    return points
end

local function attachWingPhysics(part)
    if not part then return nil, nil end
    
    local existingBG = part:FindFirstChildOfClass("BodyGyro")
    local existingBP = part:FindFirstChildOfClass("BodyPosition")
    
    if existingBG and existingBP then 
        return existingBG, existingBP
    end
    
    if existingBG then existingBG:Destroy() end
    if existingBP then existingBP:Destroy() end
    
    local BP = Instance.new("BodyPosition")  
    local BG = Instance.new("BodyGyro")  
    
    BP.P = 15000  
    BP.D = 200  
    BP.MaxForce = Vector3.new(1, 1, 1) * 1e10  
    BP.Parent = part  
    
    BG.P = 15000  
    BG.D = 200  
    BG.MaxTorque = Vector3.new(1, 1, 1) * 1e10  
    BG.Parent = part  
    
    return BG, BP
end

local function assignWingToysToPoints()
    WingAssignedToys = {}
    local distanceGroups = {}
    
    for i, point in ipairs(WingRowPoints) do
        local absDistance = math.abs(point.offsetX)
        
        if not distanceGroups[absDistance] then
            distanceGroups[absDistance] = {}
        end
        table.insert(distanceGroups[absDistance], i)
    end
    
    local sortedDistances = {}
    for distance, _ in pairs(distanceGroups) do
        table.insert(sortedDistances, distance)
    end
    table.sort(sortedDistances)
    
    for rank, distance in ipairs(sortedDistances) do
        for _, pointIndex in ipairs(distanceGroups[distance]) do
            WingRowPoints[pointIndex].distanceRank = rank
        end
    end
    
    for i = 1, math.min(#WingToys, #WingRowPoints) do
        local toy = WingToys[i]
        if toy and toy:IsA("Model") and toy.Name == "FireworkSparkler" then
            local primaryPart = getPrimaryPart(toy)
            
            if primaryPart then  
                for _, child in ipairs(toy:GetChildren()) do  
                    if child:IsA("BasePart") then  
                        child.CanCollide = false
                        child.CanTouch = false
                        child.Anchored = false
                    end  
                end
                
                local BG, BP = attachWingPhysics(primaryPart)  
                local toyTable = {  
                    BG = BG,  
                    BP = BP,  
                    Pallet = primaryPart,
                    Model = toy,
                    RowIndex = i,
                    offsetX = WingRowPoints[i].offsetX,
                    distanceRank = WingRowPoints[i].distanceRank
                }  
                
                WingRowPoints[i].assignedToy = toyTable
                table.insert(WingAssignedToys, toyTable)
            end  
        end
    end
    
    return WingAssignedToys
end

local function startWingLoop()
    if WingLoopConn then
        WingLoopConn:Disconnect()
        WingLoopConn = nil
    end
    
    WingTime = 0
    
    WingLoopConn = RunService.RenderStepped:Connect(function(dt)
        if not Config.Wing.Enabled or not LP.Character then
            return
        end
        
        local humanoidRootPart = LP.Character:FindFirstChild("HumanoidRootPart")
        local torso = LP.Character:FindFirstChild("Torso") or LP.Character:FindFirstChild("UpperTorso")
        
        if not humanoidRootPart or not torso then
            return
        end
        
        WingTime += dt * Config.Wing.waveSpeed
        
        local charCFrame = humanoidRootPart.CFrame
        local rightVector = charCFrame.RightVector
        local lookVector = charCFrame.LookVector
        
        local backVector = -lookVector
        
        local basePosition = torso.Position + 
                             Vector3.new(0, Config.Wing.heightOffset, 0) + 
                             (backVector * Config.Wing.backwardOffset)
        
        for i, point in ipairs(WingRowPoints) do
            if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
                local toy = point.assignedToy
                
                local targetPosition = basePosition + (rightVector * toy.offsetX)
                
                local amplitude = Config.Wing.baseAmplitude * toy.distanceRank
                local waveMovement = math.sin(WingTime) * amplitude
                local finalPosition = targetPosition + Vector3.new(0, waveMovement, 0)
                
                if point.part then
                    point.part.Position = finalPosition
                end
                
                toy.BP.Position = finalPosition
                
                local backYRotation = math.atan2(-lookVector.X, -lookVector.Z)
                local baseCFrame = CFrame.new(finalPosition) * CFrame.Angles(0, backYRotation, 0)
                local tiltedCFrame = baseCFrame * CFrame.Angles(math.rad(-Config.Wing.tiltAngle), 0, 0)
                
                local currentCFrame = toy.BG.CFrame
                local interpolatedCFrame = currentCFrame:Lerp(tiltedCFrame, 0.3)
                
                toy.BG.CFrame = interpolatedCFrame
            end
        end
    end)
end

local function stopWingLoop()
    if WingLoopConn then
        WingLoopConn:Disconnect()
        WingLoopConn = nil
    end
    
    for _, point in ipairs(WingRowPoints) do
        if point.part then
            point.part:Destroy()
        end
        if point.assignedToy then
            if point.assignedToy.BG then
                point.assignedToy.BG:Destroy()
            end
            if point.assignedToy.BP then
                point.assignedToy.BP:Destroy()
            end
        end
    end
    
    WingRowPoints = {}
    WingAssignedToys = {}
end

local function toggleWing(state)
    Config.Wing.Enabled = state
    if state then
        WingToys = findFireworkSparklers()
        WingRowPoints = createWingRowPoints(math.min(#WingToys, Config.Wing.maxSparklers))
        WingAssignedToys = assignWingToysToPoints()
        startWingLoop()
        
        OrionLib:MakeNotification({
            Name = "Wing起動",
            Content = "花火数: " .. #WingAssignedToys .. "本 (背中側)",
            Image = "rbxassetid://4483362458",
            Time = 3
        })
    else
        stopWingLoop()
        OrionLib:MakeNotification({
            Name = "Wing停止",
            Content = "Wingの配置を解除しました",
            Image = "rbxassetid://4483362458",
            Time = 2
        })
    end
end

-- Grab Handlers
local function grabHandler(type)
    -- Grab handler implementation
    while task.wait() do
        local grabParts = Workspace:FindFirstChild("GrabParts")
        if not grabParts then continue end
        
        local grabPart = grabParts:FindFirstChild("GrabPart")
        local weld = grabPart and grabPart:FindFirstChild("WeldConstraint")
        local targetPart = weld and weld.Part1
        
        if targetPart then
            if type == "poison" then
                -- Poison grab logic
            elseif type == "radioactive" then
                -- Radioactive grab logic
            end
        end
    end
end

local strengthConnection
local function setupThrow()
    if strengthConnection then
        strengthConnection:Disconnect()
        strengthConnection = nil
    end
    
    if Config.Grab.ThrowEnabled then
        strengthConnection = Workspace.ChildAdded:Connect(function(model)
            if model.Name == "GrabParts" then
                local grabPart = model:FindFirstChild("GrabPart")
                local weld = grabPart and grabPart:FindFirstChild("WeldConstraint")
                local partToImpulse = weld and weld.Part1
                
                if partToImpulse then
                    local velocityObj = Instance.new("BodyVelocity")
                    velocityObj.Parent = partToImpulse
                    velocityObj.MaxForce = Vector3.zero
                    
                    model:GetPropertyChangedSignal("Parent"):Connect(function()
                        if not model.Parent then
                            local lastInput = UserInputService:GetLastInputType()
                            if lastInput == Enum.UserInputType.MouseButton2 or lastInput == Enum.UserInputType.Touch then
                                velocityObj.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                velocityObj.Velocity = Workspace.CurrentCamera.CFrame.LookVector * Config.Grab.ThrowPower
                                Debris:AddItem(velocityObj, 1)
                            else
                                velocityObj:Destroy()
                            end
                        end
                    end)
                end
            end
        end)
    end
end

-- Blobman Functions
local selectedPlayerName = nil
local function findBlobmanForLocalPlayer()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v.Name == "CreatureBlobman" and v:FindFirstChild("VehicleSeat") then
            local weld = v.VehicleSeat:FindFirstChild("SeatWeld")
            if weld and weld.Part1 and weld.Part1:IsDescendantOf(LP.Character) then
                return v
            end
        end
    end
    return nil
end

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

local function getPlayerList()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
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

-- Main Loops
local LoopTimer = 0
local DefenseTimer = 0

RunService.Heartbeat:Connect(function(dt)
    LoopTimer = LoopTimer + dt
    DefenseTimer = DefenseTimer + dt
    AuraTimer = AuraTimer + dt
    
    -- Loop (Target) Attacks
    if LoopTimer >= 1.5 then
        if Config.Snipes.TargetPlayer and Config.Snipes.TargetPlayer.Character then
            if Config.Snipes.LoopKill    then task.spawn(SnipeKill,    Config.Snipes.TargetPlayer) end
            if Config.Snipes.LoopVoid    then task.spawn(SnipeVoid,    Config.Snipes.TargetPlayer) end
            if Config.Snipes.LoopPoison  then task.spawn(SnipePoison,  Config.Snipes.TargetPlayer) end
            if Config.Snipes.LoopRagdoll then task.spawn(SnipeRagdoll, Config.Snipes.TargetPlayer) end
            if Config.Snipes.LoopDeath   then task.spawn(SnipeDeath,   Config.Snipes.TargetPlayer) end
            if Config.Snipes.LoopBring   then task.spawn(SnipeBring,   Config.Snipes.TargetPlayer) end
            if Config.Snipes.LoopPull    then task.spawn(SnipePull,    Config.Snipes.TargetPlayer) end
        end
        LoopTimer = 0
    end
    
    -- Aura Attacks
    if AuraTimer >= 0.5 then
        local root, hum = HRP(), getHum()
        if root and hum and (Config.Aura.KillAura or Config.Aura.VoidAura or Config.Aura.RagdollAura or Config.Aura.NoclipAura) then
            for _, part in ipairs(GetNearParts(root.Position, Config.Aura.Radius)) do
                if part.Name == "HumanoidRootPart" and not part:IsDescendantOf(LP.Character) then
                    SetNetworkOwner(part)
                    if Config.Aura.KillAura then MoveTo(part, CFrame.new(4096, -75, 4096)) Velocity(part, Vector3.new(0, -1000, 0)) end
                    if Config.Aura.VoidAura then Velocity(part, Vector3.new(0, 10000, 0)) end
                    if Config.Aura.RagdollAura then Velocity(part, Vector3.new(0, -256, 0)) end
                    if Config.Aura.NoclipAura then part.CanCollide = false end
                end
            end
        end
        AuraTimer = 0
    end
    
    -- Anti Defense
    if DefenseTimer >= 0.1 then
        if Config.Anti.AntiGrab or Config.Anti.StruggleSpam then
            Struggle()
        end
        
        if Config.Anti.AntiVoid then
            local hrp = HRP()
            if hrp and hrp.Position.Y < -80 then
                hrp.CFrame = CFrame.new(0, 10, 0)
            end
        end
        
        if Config.Anti.AntiRagdoll then
            local hum = getHum()
            if hum and hum:GetState() == Enum.HumanoidStateType.Ragdoll then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
        
        DefenseTimer = 0
    end
end)

-- ESP Render Loop
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            
            -- Skeleton ESP
            if Config.ESP.SkeletonEnabled then
                local bones = {
                    Head = GetBone(char, "Head"),
                    Torso = GetBone(char, "UpperTorso") or GetBone(char, "Torso"),
                    LeftArm = GetBone(char, "LeftUpperArm") or GetBone(char, "Left Arm"),
                    RightArm = GetBone(char, "RightUpperArm") or GetBone(char, "Right Arm"),
                    LeftLeg = GetBone(char, "LeftUpperLeg") or GetBone(char, "Left Leg"),
                    RightLeg = GetBone(char, "RightUpperLeg") or GetBone(char, "Right Leg")
                }
                local lines = GetLineTable(player)
                local function drawLine(l, a, b)
                    if a and b then
                        local af, av = Camera:WorldToViewportPoint(a.Position)
                        local bf, bv = Camera:WorldToViewportPoint(b.Position)
                        if av and bv then
                            l.From = Vector2.new(af.X, af.Y)
                            l.To = Vector2.new(bf.X, bf.Y)
                            l.Color = Config.ESP.SkeletonColor
                            l.Thickness = Config.ESP.SkeletonThickness
                            l.Visible = true
                        else
                            l.Visible = false
                        end
                    else 
                        l.Visible = false 
                    end
                end
                drawLine(lines.Head, bones.Head, bones.Torso)
                drawLine(lines.Neck, bones.Head, bones.Torso)
                drawLine(lines.Spine, bones.Torso, hrp)
                drawLine(lines.LeftArm, bones.Torso, bones.LeftArm)
                drawLine(lines.RightArm, bones.Torso, bones.RightArm)
                drawLine(lines.LeftLeg, hrp, bones.LeftLeg)
                drawLine(lines.RightLeg, hrp, bones.RightLeg)
            end
            
            -- Tracer ESP
            if Config.ESP.TracerEnabled then
                if not TracerLines[player] then createTracer(player) end
                local t = TracerLines[player]
                local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
                t.Visible = vis
                if vis then
                    t.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    t.To = Vector2.new(pos.X, pos.Y)
                    t.Color = getRainbowColor(player.UserId % 10)
                end
            elseif TracerLines[player] then
                TracerLines[player].Visible = false
            end
            
            -- Name ESP
            if not nameESPObjects[player] then
                local t = Drawing.new("Text")
                t.Center = true
                t.Outline = true
                t.Font = 2
                nameESPObjects[player] = t
            end
            local text = nameESPObjects[player]
            local head = char:FindFirstChild("Head")
            if Config.ESP.NameEnabled and head then
                local pos, vis = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
                text.Text = player.Name
                text.Position = Vector2.new(pos.X, pos.Y)
                text.Color = Config.ESP.NameColor
                text.Size = Config.ESP.NameSize
                text.Visible = vis
            else
                text.Visible = false
            end
        end
    end
    
    for player, text in pairs(nameESPObjects) do
        if not Players:FindFirstChild(player.Name) then
            text:Remove()
            nameESPObjects[player] = nil
        end
    end
end)

-- Grab Auto-Processing
Workspace.ChildAdded:Connect(function(v)
    if v.Name == "GrabParts" and v:IsA("Model") then
        local GrabPart = v:FindFirstChild("GrabPart")
        if not GrabPart then return end
        
        local WeldConstraint = GrabPart:FindFirstChild("WeldConstraint")
        if not WeldConstraint or not WeldConstraint.Part1 then return end
        
        local target = WeldConstraint.Part1
        
        -- Super Strength (Throw)
        if Config.Grab.SuperStrength then
            v:GetPropertyChangedSignal("Parent"):Connect(function()
                if not v.Parent and target and target.Parent then
                    local throwVel = Instance.new("BodyVelocity")
                    throwVel.MaxForce = Vector3.new(1e8, 1e8, 1e8)
                    throwVel.Velocity = Workspace.CurrentCamera.CFrame.LookVector * Config.Grab.StrengthPower
                    throwVel.Parent = target
                    Debris:AddItem(throwVel, 0.1)
                end
            end)
        end
        
        -- Various Grab Options
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

-- UI Creation
-- Grab Tab
local GrabTab = Window:MakeTab({ Name = "Grab", Icon = "rbxassetid://4483362458", PremiumOnly = false })

GrabTab:AddSection({ Name = "基本Grab機能" })
GrabTab:AddToggle({ Name = "キックGrab", Default = false, Callback = function(v) Config.Grab.KickGrab = v end })
GrabTab:AddToggle({ Name = "キルGrab", Default = false, Callback = function(v) Config.Grab.KillGrab = v end })
GrabTab:AddToggle({ Name = "ボイドGrab", Default = false, Callback = function(v) Config.Grab.VoidGrab = v end })
GrabTab:AddToggle({ Name = "アンカーGrab", Default = false, Callback = function(v) Config.Grab.AnchorGrab = v end })
GrabTab:AddToggle({ Name = "毒Grab", Default = false, Callback = function(v) Config.Grab.PoisonGrab = v end })
GrabTab:AddToggle({ Name = "火Grab", Default = false, Callback = function(v) Config.Grab.FireGrab = v end })
GrabTab:AddToggle({ Name = "放射性Grab", Default = false, Callback = function(v) Config.Grab.RadioactiveGrab = v end })
GrabTab:AddToggle({ Name = "ノークリップGrab", Default = false, Callback = function(v) Config.Grab.NoclipGrab = v end })
GrabTab:AddToggle({ Name = "上空Grab", Default = false, Callback = function(v) Config.Grab.SkyGrab = v end })
GrabTab:AddToggle({ Name = "地面Grab", Default = false, Callback = function(v) Config.Grab.GroundGrab = v end })

GrabTab:AddSection({ Name = "投げる機能" })
GrabTab:AddSlider({ Name = "投げるパワー", Min = 300, Max = 4000, Default = 400, Increment = 1, ValueName = "", Callback = function(v) Config.Grab.ThrowPower = v end })
GrabTab:AddToggle({ Name = "投げる", Default = false, Callback = function(v) 
    Config.Grab.ThrowEnabled = v 
    setupThrow()
end })
GrabTab:AddSlider({ Name = "スーパーパワー", Min = 0, Max = 10000, Default = 250, Increment = 10, Callback = function(v) Config.Grab.StrengthPower = v end })
GrabTab:AddToggle({ Name = "スーパーパワー", Default = false, Callback = function(v) Config.Grab.SuperStrength = v end })

-- Blobman Tab
local BlobmanTab = Window:MakeTab({ Name = "Blobman", Icon = "rbxassetid://7733916988", PremiumOnly = false })

local playerDropdown = BlobmanTab:AddDropdown({
    Name = "プレイヤー選択",
    Options = getPlayerList(),
    Callback = function(value)
        selectedPlayerName = value
    end
})

BlobmanTab:AddButton({
    Name = "🔄 プレイヤーリスト更新",
    Callback = function()
        playerDropdown:Refresh(getPlayerList(), true)
    end
})

BlobmanTab:AddButton({
    Name = "Bring（選択した人を1回）",
    Callback = function()
        if not selectedPlayerName then 
            OrionLib:MakeNotification({Name="エラー", Content="プレイヤーが選択されていません", Time=3})
            return 
        end

        local target = getPlayerByDisplayName(selectedPlayerName)
        local blobman = findBlobmanForLocalPlayer()
        if not target or not blobman then return end

        local originalPos = LP.Character and LP.Character.HumanoidRootPart.CFrame
        local targetHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        
        if targetHRP then
            LP.Character.HumanoidRootPart.CFrame = CFrame.new(targetHRP.Position + Vector3.new(0, 5, 0))
            task.wait(0.4)
        end

        blobGrabPlayer(target, blobman, "Left")
        task.wait(0.6)

        if originalPos then
            LP.Character.HumanoidRootPart.CFrame = originalPos
        end
    end
})

BlobmanTab:AddToggle({
    Name = "左手オール",
    Default = false,
    Callback = function(enabled)
        if enabled then
            task.spawn(function()
                while enabled do
                    local blobman = findBlobmanForLocalPlayer()
                    if not blobman then task.wait(1) continue end

                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LP then
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
    Name = "右手オール",
    Default = false,
    Callback = function(enabled)
        if enabled then
            task.spawn(function()
                while enabled do
                    local blobman = findBlobmanForLocalPlayer()
                    if not blobman then task.wait(1) continue end

                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LP then
                            blobGrabPlayer(plr, blobman, "Right")
                        end
                    end
                    task.wait(0.35)
                end
            end)
        end
    end
})

-- Anti Tab
local AntiTab = Window:MakeTab({ Name = "Anti", Icon = "rbxassetid://4483362458", PremiumOnly = false })

AntiTab:AddSection({ Name = "Anti機能" })
AntiTab:AddToggle({ Name = "Anti Grab", Default = false, Callback = function(v) Config.Anti.AntiGrab = v end })
AntiTab:AddToggle({ Name = "Anti Void", Default = false, Callback = function(v) Config.Anti.AntiVoid = v end })
AntiTab:AddToggle({ Name = "Anti Ragdoll", Default = false, Callback = function(v) Config.Anti.AntiRagdoll = v end })
AntiTab:AddToggle({ Name = "Anti Explode", Default = false, Callback = function(v) 
    Config.Anti.AntiExplode = v 
    SetupAntiExplode()
end })
AntiTab:AddToggle({ Name = "Struggle Spam", Default = false, Callback = function(v) Config.Anti.StruggleSpam = v end })

AntiTab:AddSection({ Name = "ユーティリティ" })
AntiTab:AddButton({ Name = "キャラクターリセット", Callback = function() 
    local hum = getHum()
    if hum then hum:ChangeState(Enum.HumanoidStateType.Dead) end
end })
AntiTab:AddButton({ Name = "セーフゾーンにTP", Callback = function() 
    local hrp = HRP()
    if hrp then hrp.CFrame = CFrame.new(0, 50, 0) end
end })

-- Player Tab
local PlayerTab = Window:MakeTab({ Name = "Player", Icon = "rbxassetid://4483362458", PremiumOnly = false })

PlayerTab:AddSection({ Name = "Movement" })
PlayerTab:AddSlider({ Name = "スピード値", Min = 16, Max = 1000, Default = 16, Increment = 1, Callback = function(v) 
    Config.Player.SpeedValue = v 
    if Config.Player.SpeedEnabled then updatePlayerMovement() end
end })
PlayerTab:AddToggle({ Name = "スピードブースト", Default = false, Callback = function(v) 
    Config.Player.SpeedEnabled = v 
    updatePlayerMovement()
end })
PlayerTab:AddSlider({ Name = "ジャンプ値", Min = 50, Max = 500, Default = 50, Increment = 1, Callback = function(v) 
    Config.Player.JumpValue = v 
    if Config.Player.JumpEnabled then updatePlayerMovement() end
end })
PlayerTab:AddToggle({ Name = "ジャンプブースト", Default = false, Callback = function(v) 
    Config.Player.JumpEnabled = v 
    updatePlayerMovement()
end })
PlayerTab:AddToggle({ Name = "ノークリップ", Default = false, Callback = function(v) 
    Config.Player.Noclip = v 
    updatePlayerMovement()
end })

-- Teleport Tab
local TeleportTab = Window:MakeTab({ Name = "Teleport", Icon = "rbxassetid://4483362458", PremiumOnly = false })

TeleportTab:AddButton({ Name = "赤い家", Callback = function() 
    local hrp = HRP()
    if hrp then hrp.CFrame = CFrame.new(551, 123, -75) end
end })
TeleportTab:AddButton({ Name = "青い家", Callback = function() 
    local hrp = HRP()
    if hrp then hrp.CFrame = CFrame.new(513, 83, -342) end
end })
TeleportTab:AddButton({ Name = "紫の家", Callback = function() 
    local hrp = HRP()
    if hrp then hrp.CFrame = CFrame.new(251, -8, 462) end
end })
TeleportTab:AddButton({ Name = "鶏小屋", Callback = function() 
    local hrp = HRP()
    if hrp then hrp.CFrame = CFrame.new(-203, 60, -293) end
end })
TeleportTab:AddButton({ Name = "緑の家（バリアなし）", Callback = function() 
    local hrp = HRP()
    if hrp then hrp.CFrame = CFrame.new(-323, 81, 331) end
end })
TeleportTab:AddButton({ Name = "ピンクの家", Callback = function() 
    local hrp = HRP()
    if hrp then hrp.CFrame = CFrame.new(-488, -8, -168) end
end })
TeleportTab:AddButton({ Name = "緑の家", Callback = function() 
    local hrp = HRP()
    if hrp then hrp.CFrame = CFrame.new(-534, -8, 91) end
end })

-- Loop Tab (formerly Target)
local LoopTab = Window:MakeTab({ Name = "Loop", Icon = "rbxassetid://4483362458", PremiumOnly = false })

LoopTab:AddSection({ Name = "ターゲット選択" })
local LoopPlayerDropdown = LoopTab:AddDropdown({
    Name = "ターゲットリスト",
    Default = "",
    Options = updatePlayerList(),
    Callback = function(selectedDisplayName)
        Config.Snipes.TargetPlayer = getPlayerFromDisplayName(selectedDisplayName)
    end
})

LoopTab:AddButton({
    Name = "🔄 プレイヤーリスト更新",
    Callback = function()
        LoopPlayerDropdown:Refresh(updatePlayerList(), true)
    end
})

LoopTab:AddSection({ Name = "ループ攻撃" })
LoopTab:AddToggle({ Name = "ループキル", Default = false, Callback = function(v) Config.Snipes.LoopKill = v end })
LoopTab:AddToggle({ Name = "ループボイド", Default = false, Callback = function(v) Config.Snipes.LoopVoid = v end })
LoopTab:AddToggle({ Name = "ループ毒", Default = false, Callback = function(v) Config.Snipes.LoopPoison = v end })
LoopTab:AddToggle({ Name = "ループラグドール", Default = false, Callback = function(v) Config.Snipes.LoopRagdoll = v end })
LoopTab:AddToggle({ Name = "ループデス", Default = false, Callback = function(v) Config.Snipes.LoopDeath = v end })
LoopTab:AddToggle({ Name = "ループブリング", Default = false, Callback = function(v) Config.Snipes.LoopBring = v end })
LoopTab:AddToggle({ Name = "ループプル", Default = false, Callback = function(v) Config.Snipes.LoopPull = v end })

-- Aura Tab
local AuraTab = Window:MakeTab({ Name = "Aura", Icon = "rbxassetid://4483362458", PremiumOnly = false })

AuraTab:AddSection({ Name = "Aura攻撃" })
AuraTab:AddToggle({ Name = "キルAura", Default = false, Callback = function(v) Config.Aura.KillAura = v end })
AuraTab:AddToggle({ Name = "ボイドAura", Default = false, Callback = function(v) Config.Aura.VoidAura = v end })
AuraTab:AddToggle({ Name = "ラグドールAura", Default = false, Callback = function(v) Config.Aura.RagdollAura = v end })
AuraTab:AddToggle({ Name = "ノークリップAura", Default = false, Callback = function(v) Config.Aura.NoclipAura = v end })
AuraTab:AddSlider({ Name = "Aura半径", Min = 10, Max = 100, Default = 32, Increment = 1, Callback = function(v) Config.Aura.Radius = v end })

-- Visual Tab
local VisualTab = Window:MakeTab({ Name = "Visual", Icon = "rbxassetid://7733774602", PremiumOnly = false })

VisualTab:AddLabel("空")
VisualTab:AddSlider({ Name = "時間帯", Min = 0, Max = 23, Default = 14, Color = Color3.fromRGB(206, 206, 206), Increment = 0.001, Callback = function(v) Lighting.ClockTime = v end })
VisualTab:AddToggle({ Name = "今の時間と同期", Default = false, Callback = function(v) 
    Config.Visual.TimeSync = v
    task.spawn(function()
        while Config.Visual.TimeSync do
            local response = request({
                Url = "https://www.timeapi.io/api/time/current/zone?timeZone=Europe%2FAmsterdam",
                Method = "GET",
            })
            if response.Success then
                local data = HttpService:JSONDecode(response.Body)
                Lighting.TimeOfDay = string.format("%02d:%02d:%02d", 
                    tonumber(data.hour)+1, 
                    tonumber(data.minute), 
                    tonumber(data.seconds)
                )
            end
            task.wait(1)
        end
    end)
end })

VisualTab:AddLabel("コイン")
VisualTab:AddTextbox({ Name = "偽コインの枚数", Default = "", TextDisappear = false, Callback = function(text) Config.Visual.FakeCoins = text end })
VisualTab:AddButton({ Name = "偽のコインを適用", Callback = function()
    local coinAmount = tonumber(Config.Visual.FakeCoins) or 0
    local playerGui = LP.PlayerGui
    local coinText = playerGui.MenuGui.TopRight.CoinsFrame.CoinsDisplay.Coins
    if coinText then coinText.Text = tostring(coinAmount) end
end })

VisualTab:AddLabel("カメラ関係")
VisualTab:AddButton({ Name = "三人称", Callback = function()
    LP.CameraMaxZoomDistance = 8000000
    LP.CameraMode = Enum.CameraMode.Classic
end })
VisualTab:AddSlider({ Name = "視野角", Min = 0, Max = 120, Default = 100, Color = Color3.fromRGB(206, 206, 206), Increment = 1, ValueName = "", Callback = function(v) 
    Config.Visual.FOV = v
    Workspace.CurrentCamera.FieldOfView = v
end })

-- ESP Tab
local ESPTab = Window:MakeTab({ Name = "ESP", Icon = "rbxassetid://7733774602", PremiumOnly = false })

ESPTab:AddToggle({ Name = "ESP（ハイライト）", Default = false, Callback = function(v) 
    Config.ESP.Enabled = v 
    updateESP()
end })
ESPTab:AddColorpicker({ Name = "ハイライトカラー", Default = Config.ESP.HighlightColor, Callback = function(v) 
    Config.ESP.HighlightColor = v 
    updateESP()
end })
ESPTab:AddSlider({ Name = "ハイライト透明度", Min = 0, Max = 1, Default = 0.6, Color = Color3.fromRGB(206, 206, 206), Increment = 0.05, Callback = function(v) 
    Config.ESP.HighlightTransparency = v 
    updateESP()
end })

ESPTab:AddLabel("ボックスESP")
ESPTab:AddToggle({ Name = "ESP（箱）", Default = false, Callback = function(v) 
    Config.ESP.BoxEnabled = v 
    updateBoxESP()
end })
ESPTab:AddColorpicker({ Name = "箱のカラー", Default = Config.ESP.BoxColor, Callback = function(v) 
    Config.ESP.BoxColor = v 
    updateBoxESP()
end })

ESPTab:AddLabel("スケルトンESP")
ESPTab:AddToggle({ Name = "ESP（スケルトン）", Default = false, Callback = function(v) 
    Config.ESP.SkeletonEnabled = v
    if not v then
        for _, parts in pairs(SkeletonLines) do
            for _, line in pairs(parts) do
                line.Visible = false
            end
        end
    end
end })
ESPTab:AddColorpicker({ Name = "スケルトン色", Default = Config.ESP.SkeletonColor, Callback = function(v) Config.ESP.SkeletonColor = v end })

ESPTab:AddLabel("トレーサーESP")
ESPTab:AddToggle({ Name = "ライン表示", Default = false, Callback = function(v) 
    Config.ESP.TracerEnabled = v
    if not v then
        for _, line in pairs(TracerLines) do
            line.Visible = false
        end
    end
end })

ESPTab:AddLabel("ネームESP")
ESPTab:AddToggle({ Name = "名前表示", Default = false, Callback = function(v) Config.ESP.NameEnabled = v end })
ESPTab:AddColorpicker({ Name = "名前色", Default = Config.ESP.NameColor, Callback = function(v) Config.ESP.NameColor = v end })
ESPTab:AddSlider({ Name = "名前サイズ", Min = 10, Max = 30, Default = 13, Color = Color3.fromRGB(206, 206, 206), Increment = 1, Callback = function(v) Config.ESP.NameSize = v end })

-- Wing Tab
local WingTab = Window:MakeTab({ Name = "Wing", Icon = "rbxassetid://4483362458", PremiumOnly = false })

WingTab:AddToggle({
    Name = "Wingを起動 (背中側)",
    Default = false,
    Callback = function(v)
        toggleWing(v)
    end
})

WingTab:AddSection({ Name = "配置設定" })
WingTab:AddSlider({ Name = "最大花火数", Min = 2, Max = 40, Default = Config.Wing.maxSparklers, Increment = 2, ValueName = "本", Callback = function(v) 
    Config.Wing.maxSparklers = v
    if Config.Wing.Enabled then
        toggleWing(false)
        task.wait(0.1)
        toggleWing(true)
    end
end })
WingTab:AddSlider({ Name = "花火の間隔", Min = 1, Max = 10, Default = Config.Wing.spacing, Increment = 0.5, ValueName = "studs", Callback = function(v) 
    Config.Wing.spacing = v
    if Config.Wing.Enabled then
        toggleWing(false)
        task.wait(0.1)
        toggleWing(true)
    end
end })
WingTab:AddSlider({ Name = "高さオフセット", Min = -5, Max = 10, Default = Config.Wing.heightOffset, Increment = 0.5, ValueName = "studs", Callback = function(v) Config.Wing.heightOffset = v end })
WingTab:AddSlider({ Name = "背中オフセット", Min = 0, Max = 10, Default = Config.Wing.backwardOffset, Increment = 0.5, ValueName = "studs", Callback = function(v) Config.Wing.backwardOffset = v end })

WingTab:AddSection({ Name = "角度設定" })
WingTab:AddSlider({ Name = "花火の傾き角度", Min = 0, Max = 90, Default = Config.Wing.tiltAngle, Increment = 5, ValueName = "度", Callback = function(v) Config.Wing.tiltAngle = v end })

WingTab:AddSection({ Name = "上下動設定" })
WingTab:AddSlider({ Name = "上下動の速度", Min = 0, Max = 10, Default = Config.Wing.waveSpeed, Increment = 0.5, ValueName = "速度", Callback = function(v) Config.Wing.waveSpeed = v end })
WingTab:AddSlider({ Name = "基本振幅", Min = 0, Max = 5, Default = Config.Wing.baseAmplitude, Increment = 0.5, ValueName = "studs", Callback = function(v) Config.Wing.baseAmplitude = v end })

WingTab:AddButton({
    Name = "花火を再検出",
    Callback = function()
        if Config.Wing.Enabled then
            toggleWing(false)
            task.wait(0.1)
            toggleWing(true)
            OrionLib:MakeNotification({
                Name = "再検出完了",
                Content = "花火を再検出しました",
                Image = "rbxassetid://4483362458",
                Time = 3
            })
        end
    end
})

-- Info Tab
local InfoTab = Window:MakeTab({ Name = "Info", Icon = "rbxassetid://4483362458", PremiumOnly = false })

InfoTab:AddLabel("Made in Lulu！")
InfoTab:AddLabel("Noob hub v1.0")
InfoTab:AddLabel("名前の許可とってます👍")
InfoTab:AddButton({
    Name = "Discord Link!!",
    Callback = function()
        setclipboard("https://discord.gg/pS24D6zxf")
        OrionLib:MakeNotification({
            Name = "コピー完了",
            Content = "Discordリンクがクリップボードにコピーされました！",
            Time = 3
        })
    end
})

-- Initialize players for ESP
for _, p in ipairs(Players:GetPlayers()) do setupPlayer(p) end

-- Player join/leave events
Players.PlayerAdded:Connect(function(player)
    setupPlayer(player)
    task.wait(0.5)
    if LoopPlayerDropdown then
        LoopPlayerDropdown:Refresh(updatePlayerList(), true)
    end
    if playerDropdown then
        playerDropdown:Refresh(getPlayerList(), true)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if Config.Snipes.TargetPlayer == player then
        Config.Snipes.TargetPlayer = nil
        OrionLib:MakeNotification({
            Name = "ターゲット退出",
            Content = "ターゲットがサーバーを離れました",
            Time = 3
        })
    end
    
    if SkeletonLines[player] then
        for _, line in pairs(SkeletonLines[player]) do line:Remove() end
        SkeletonLines[player] = nil
    end
    if nameESPObjects[player] then 
        nameESPObjects[player]:Remove() 
        nameESPObjects[player] = nil 
    end
    removeTracer(player)
    
    task.wait(0.5)
    if LoopPlayerDropdown then
        LoopPlayerDropdown:Refresh(updatePlayerList(), true)
    end
    if playerDropdown then
        playerDropdown:Refresh(getPlayerList(), true)
    end
end)

-- Initialize OrionLib
OrionLib:Init()

OrionLib:MakeNotification({
    Name = "Noob Hub",
    Content = "すべての機能が読み込まれました！",
    Image = "rbxassetid://4483362458",
    Time = 5
})
