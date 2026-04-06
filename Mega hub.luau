local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

local localPlayer = Players.LocalPlayer
local Mouse = localPlayer:GetMouse()
local Camera = Workspace.CurrentCamera
local OriginalFOV = Camera.FieldOfView

local backpacks = Workspace:FindFirstChild("Backpacks")

local CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents")
local Struggle = CharacterEvents:WaitForChild("Struggle")

local GameCorrectionEvents = ReplicatedStorage:WaitForChild("GameCorrectionEvents")
local StopAllVelocity = GameCorrectionEvents:WaitForChild("StopAllVelocity")

if not Struggle then
    warn("Struggle RemoteEvent not found in CharacterEvents")
end

if not StopAllVelocity then
    warn("StopAllVelocity RemoteEvent not found in GameCorrectionEvents")
end

getgenv().AntiExplosionEnabled = false

local jumpConnection
local twohand = false
local allblobs = false
local killg = false
local gt = false
local blobmanCoroutine
local airSuspendActive = false
local antiGrabConnection
local AntiGrabTPEnabled = false
local freezeEnabled = false
local autoReset = false
local antivoid = false

local walkSpeedEnabled = false
local infiniteJumpEnabled = false
local noclipEnabled = false
local AutoHouseTP = false
local timesync = false
local bringLooping = false
local ZoomEnabled = false

local AutoHouseTPCoroutine = nil
local airSuspendCoroutine = nil
local antiExplosionConnection = nil
local strengthConnection = nil
local autoStruggleCoroutine = nil
local skygrabLoop = nil
local groundgrabLoop = nil
local bringLoopThread = nil
local burnPart = nil

local S = { w = Workspace }
local storedObjects = {}
local OriginalProperties = {}

local nageru = 400
local N = { gs = 100 }
local blobalter = 1
local all_Speed = 0.01
local walkSpeedValue = 5
local jumpPowerValue = 24
N = N or {}
N.jps = 24


local function muteGrabSounds(character)
    for _, sound in ipairs(character:GetDescendants()) do
        if sound:IsA("Sound") and (sound.Name:lower():find("scream") or sound.Name:lower():find("cry")) then
            sound:Stop()
            sound.Volume = 0
            sound.Playing = false
        end
    end
end

local function preventVoidFall(character)
end

local function getDescendantParts(name)
    local parts = {}
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("Part") and d.Name == name then
            table.insert(parts, d)
        end
    end
    return parts
end

local poisonHurtParts = getDescendantParts("PoisonHurtPart")
local paintPlayerParts = getDescendantParts("PaintPlayerPart")

local function grabHandler(grabType)
    while true do
        task.wait()
        pcall(function()
            local child = Workspace:FindFirstChild("GrabParts")
            if child and child:FindFirstChild("GrabPart") then
                local weld = child.GrabPart:FindFirstChild("WeldConstraint")
                if weld and weld.Part1 then
                    local head = weld.Part1.Parent and weld.Part1.Parent:FindFirstChild("Head")
                    if head then
                        local partsTable = (grabType == "poison") and poisonHurtParts or paintPlayerParts

                        for _, part in pairs(partsTable) do
                            part.Size = Vector3.new(2, 2, 2)
                            part.Transparency = 1
                            part.Position = head.Position
                        end

                        task.wait()

                        for _, part in pairs(partsTable) do
                            part.Position = Vector3.new(0, -200, 0)
                        end
                    end
                end
            end
        end)
    end
end

local function isModelSelf(model)
    return model:IsDescendantOf(localPlayer.Character)
end

local function isAnchoredMapObject(model)
    for _, part in pairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Anchored then
            return true
        end
    end
    return false
end

local function noclipGrab()
    while true do
        local grabParts = Workspace:FindFirstChild("GrabParts")
        if grabParts then
            local grabPart = grabParts:FindFirstChild("GrabPart")
            local weld = grabPart and grabPart:FindFirstChild("WeldConstraint")
            local part1 = weld and weld.Part1

            if part1 then
                local model = part1:FindFirstAncestorWhichIsA("Model") or part1

                if isModelSelf(model) or isAnchoredMapObject(model) then
                    task.wait()
                    continue
                end

                for _, part in ipairs(model:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
        task.wait()
    end
end

local function setupAntiExplosion(character)
    local humanoid = character:WaitForChild("Humanoid")
    local partOwner = character:FindFirstChild("Ragdolled", true)
    if partOwner then
        if antiExplosionConnection then
            antiExplosionConnection:Disconnect()
        end
        antiExplosionConnection = partOwner:GetPropertyChangedSignal("Value"):Connect(function()
            if getgenv().AntiExplosionEnabled then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Anchored = partOwner.Value
                    end
                end
            else
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Anchored = false
                    end
                end
            end
        end)
        if getgenv().AntiExplosionEnabled then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = partOwner.Value
                end
            end
        end
    end
end

local function setupCharacter(char)
    RunService.Heartbeat:Connect(function()
        muteGrabSounds(char)
        preventVoidFall(char)
    end)
    setupAntiExplosion(char)
end

if localPlayer.Character then
    setupCharacter(localPlayer.Character)
end
localPlayer.CharacterAdded:Connect(setupCharacter)

local O = {
    me = localPlayer,
    backpack = backpack
}

local Lighting = game:GetService("Lighting")

Lighting.FogEnd = 1e12

if not Lighting:FindFirstChild("Sky") then
	local sky = Instance.new("Sky", Lighting)
	sky.Name = "Sky"
end

Lighting.Sky.StarCount = 5000
Lighting.Sky.SkyboxBk = "rbxassetid://1289067181"
Lighting.Sky.SkyboxDn = "rbxassetid://1289084895"
Lighting.Sky.SkyboxFt = "rbxassetid://1289065660"
Lighting.Sky.SkyboxLf = "rbxassetid://1289065992"
Lighting.Sky.SkyboxRt = "rbxassetid://1289066325"
Lighting.Sky.SkyboxUp = "rbxassetid://1289076870"
Lighting.Sky.SunTextureId = "rbxasset://sky/sun.jpg"
Lighting.Sky.MoonTextureId = "rbxasset://sky/moon.jpg"

Lighting.ShadowSoftness = 1

local sunrays = Lighting:FindFirstChildOfClass("SunRaysEffect") or Instance.new("SunRaysEffect", Lighting)
sunrays.Intensity = 0
sunrays.Spread = 0

local bloom = Lighting:FindFirstChildOfClass("BloomEffect") or Instance.new("BloomEffect", Lighting)
bloom.Intensity = 0
bloom.Size = 0
bloom.Threshold = 1

local Window = OrionLib:MakeWindow({
    Name = "Mega hub",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "megahubconfig",
    IntroEnabled = true,
    IntroText = "ようこそ"
})

OrionLib:MakeNotification({
    Name = "起動成功",
    Content = "スクリプトが正常に読み込まれました",
    Image = "rbxassetid://11472832266",
    Time = 3
})

OrionLib:MakeNotification({
    Name = "GUI キーバインド",
    Content = "初期キーバインド（K）",
    Image = "rbxassetid://7733799901",
    Time = 5
})

OrionLib:MakeNotification({
    Name = "スクリプトオーナー",
    Content = "knx4649",
    Image = "rbxassetid://11472832266",
    Time = 2
})

local HomeTab = Window:MakeTab({Name = "ホーム", Icon =  "rbxassetid://10723407389", PremiumOnly = false})

HomeTab:AddParagraph(" UI / Orion", "Orion Library By jadpy（suu）")
HomeTab:AddParagraph("ホーム項目","Megahubハブへようこそ。スクリプトをご利用いただきありがとうございます")
HomeTab:AddParagraph("情報ログ","スクリプトアップデート&修正ログ")
HomeTab:AddParagraph("[オーナーからへ]","[2025/09/02]｜なし")
HomeTab:AddParagraph("[スクリプトアップデート]","[2025/09/02]｜モバイル用スクリプトタブ追加（クリックtpやズーム等）")
HomeTab:AddParagraph("[スクリプト修正]","[2025/09/02] なし")

local GrabTab = Window:MakeTab({Name = "掴む", Icon =  "rbxassetid://10723404472", PremiumOnly = false})

local function spawnItem(name, position)
    local rotation = Vector3.new(0, 0, 0)
    ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(name, CFrame.new(position), rotation)
end

local function arson(part)
    if not toysFolder:FindFirstChild("Campfire") then
        spawnItem("Campfire", Vector3.new(-72.9304581, -5.96906614, -265.543732))
    end
    local campfire = toysFolder:FindFirstChild("Campfire")
    burnPart = campfire:FindFirstChild("FirePlayerPart") or campfire.FirePlayerPart
    burnPart.Size = Vector3.new(7, 7, 7)
    burnPart.Position = part.Position
    task.wait(0.3)
    burnPart.Position = Vector3.new(0, -50, 0)
end

local function fireGrab()
    while true do
        local success, err = pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                local grabbedPart = grabPart:FindFirstChild("WeldConstraint").Part1
                local head = grabbedPart.Parent:FindFirstChild("Head")
                if head then
                    arson(head)
                end
            end
        end)
        wait()
    end
end


local function getChar(part)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and part:IsDescendantOf(plr.Character) then
            return plr
        end
    end
    return nil
end

local function killPlayer(plr)
    if plr and plr.Character then
        local char = plr.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Dead)
            hum.Health = 0
        end
        char:BreakJoints()
    end
end

Workspace.ChildAdded:Connect(function(child)
    if child.Name == "GrabParts" and killg then
        local grabbedPart = child:FindFirstChild("GrabPart")
        if not grabbedPart then return end

        local weld = grabbedPart:FindFirstChildOfClass("WeldConstraint")
        if not weld or not weld.Part1 then return end

        local targetPlayer = getChar(weld.Part1)
        if targetPlayer then
            killPlayer(targetPlayer)
            fstatus("プレイヤー " .. targetPlayer.DisplayName .. " が死にましたwwww")
        end
    end
end)


GrabTab:AddToggle({
	Name = "投げる",
	Default = false,
	Callback = function(enabled)
		if enabled then
			strengthConnection = workspace.ChildAdded:Connect(function(model)
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
								local lastInput = game:GetService("UserInputService"):GetLastInputType()
								if lastInput == Enum.UserInputType.MouseButton2 or lastInput == Enum.UserInputType.Touch then
									velocityObj.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
									velocityObj.Velocity = workspace.CurrentCamera.CFrame.LookVector * nageru
									game:GetService("Debris"):AddItem(velocityObj, 1)
								else
									velocityObj:Destroy()
								end
							end
						end)
					end
				end
			end)
		elseif strengthConnection then
			strengthConnection:Disconnect()
			strengthConnection = nil
		end
	end
})

GrabTab:AddSlider({
	Name = "投げるパワー",
	Min = 300,
	Max = 4000,
	Default = 400,
    Color = Color3.fromRGB(206, 206, 206),
	Increment = 1,
	ValueName = "",
	Callback = function(value)
		nageru = value
	end
})

GrabTab:AddLabel("掴む項目")

GrabTab:AddToggle({
    Name = "毒掴む",
    Default = false,
    Save = true,
    Flag = "PoisonGrab",
    Callback = function(enabled)
        if enabled then
            poisonGrabCoroutine = coroutine.create(function()
                grabHandler("poison")
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
    Name = "火掴む",
    Default = false,
    Save = false,
    Flag = "FireGrab",
    Callback = function(enabled)
        if enabled then
            fireGrabCoroutine = coroutine.create(fireGrab)
            coroutine.resume(fireGrabCoroutine)
        else
            if fireGrabCoroutine then
                coroutine.close(fireGrabCoroutine)
                fireGrabCoroutine = nil
            end
        end
    end
})

GrabTab:AddToggle({
    Name = "Radioactive掴む",
    Default = false,
    Save = true,
    Flag = "RadioactiveGrab",
    Callback = function(enabled)
        if enabled then
            ufoGrabCoroutine = coroutine.create(function()
                grabHandler("radioactive")
            end)
            coroutine.resume(ufoGrabCoroutine)
        else
            if ufoGrabCoroutine then
                coroutine.close(ufoGrabCoroutine)
                ufoGrabCoroutine = nil
                for _, part in pairs(paintPlayerParts) do
                    part.Position = Vector3.new(0, -200, 0)
                end
            end
        end
    end
})

GrabTab:AddToggle({
    Name = "ノクリップ掴む",
    Default = false,
    Save = false,
    Callback = function(state)
        if state then
            noclipGrabCoroutine = coroutine.create(noclipGrab)
            coroutine.resume(noclipGrabCoroutine)
        elseif noclipGrabCoroutine then
            coroutine.close(noclipGrabCoroutine)
            noclipGrabCoroutine = nil
        end
    end
})

GrabTab:AddToggle({
    Name = "キル掴む",
    Default = false,
    Callback = function(Value)
        killg = Value
    end
})

GrabTab:AddToggle({
    Name = "上に上がる掴む",
    Default = false,
    Flag = "SkyGrab",
    Callback = function(Value)
        if Value then
            skygrabLoop = task.spawn(function()
                while task.wait(0.1) do
                    local grabParts = workspace:FindFirstChild("GrabParts")
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
            local grabParts = workspace:FindFirstChild("GrabParts")
            if grabParts and grabParts:FindFirstChild("GrabPart") then
                local weld = grabParts.GrabPart:FindFirstChild("WeldConstraint")
                local targetPart = weld and weld.Part1
                if targetPart and targetPart:FindFirstChild("SkyGrabBP") then
                    targetPart.SkyGrabBP:Destroy()
                end
            end
        end
    end
})

GrabTab:AddToggle({
    Name = "下に下がる掴む",
    Default = false,
    Flag = "GroundGrab",
    Callback = function(Value)
        if Value then
            groundgrabLoop = task.spawn(function()
                while task.wait(0.1) do
                    local grabParts = workspace:FindFirstChild("GrabParts")
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

            local grabParts = workspace:FindFirstChild("GrabParts")
            if grabParts and grabParts:FindFirstChild("GrabPart") then
                local weld = grabParts.GrabPart:FindFirstChild("WeldConstraint")
                local targetPart = weld and weld.Part1
                if targetPart then
                    local bp = targetPart:FindFirstChild("GroundGrabBP")
                    if bp then
                        bp.Position = targetPart.Position + Vector3.new(0, 5, 0)
                        task.delay(0.2, function()
                            if bp and bp.Parent then
                                bp:Destroy()
                            end
                        end)
                    end
                end
            end
        end
    end
})

local BlobmanTab = Window:MakeTab({Name = "ブロブマン", Icon =  "rbxassetid://7733916988", PremiumOnly = false})

local selectedPlayerName = nil
local playerDropdown

local function blobGrabPlayer(player, blobman)
    local targetHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end

    blobman.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
        blobman.LeftDetector,
        targetHRP,
        blobman.LeftDetector:FindFirstChild("LeftWeld")
    )
end

local function findBlobmanForLocalPlayer()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v.Name == "CreatureBlobman" and v:FindFirstChild("VehicleSeat") then
            local weld = v.VehicleSeat:FindFirstChild("SeatWeld")
            if weld and weld.Part1 and weld.Part1:IsDescendantOf(localPlayer.Character) then
                return v
            end
        end
    end
    return nil
end

local function getPlayerList()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
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
    Name = "Bring【❌️メンテナンス】",
    Callback = function()
        if not selectedPlayerName then return end

        local target = getPlayerByDisplayName(selectedPlayerName)
        local blobman = findBlobmanForLocalPlayer()

        if target and blobman then
            blobGrabPlayer(target, blobman)
        end
    end
})

BlobmanTab:AddLabel("オール")

local function gatherBlobs()
    local blobs = {}
    if backpacks then
        for _, backpack in pairs(backpacks:GetChildren()) do
            for _, toy in pairs(backpack:GetChildren()) do
                if toy.Name == "CreatureBlobman" then
                    table.insert(blobs, toy)
                end
            end
        end
    end
    return blobs
end

local function getHRP(plr)
    local char = plr.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
end

local function leftHandKick(blob, targetHRP)
    if blob and targetHRP and blob_kick then
        blob_kick(blob, targetHRP, "Left", 1)
    end
end

BlobmanTab:AddToggle({
    Name = "左手でオール【❌️メンテナンス】",
    Default = false,
    Callback = function(enabled)
        if enabled then
            coroutine.wrap(function()
                while enabled do
                    local blobs = gatherBlobs()
                    if #blobs == 0 then
                        warn("❌️左キックオールはメンテナンス中です。")
                        break
                    end

                    for _, plr in pairs(Players:GetPlayers()) do
                        if plr ~= localPlayer then
                            local hrp = getHRP(plr)
                            if hrp then
                                for _, blob in pairs(blobs) do
                                    leftHandKick(blob, hrp)
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)()
        end
    end
})

local function gatherBlobs()
    local blobs = {}
    if backpacks then
        for _, backpack in pairs(backpacks:GetChildren()) do
            for _, toy in pairs(backpack:GetChildren()) do
                if toy.Name == "CreatureBlobman" then
                    table.insert(blobs, toy)
                end
            end
        end
    end
    return blobs
end

local function getHRP(plr)
    local char = plr.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
end

local function rightHandKick(blob, targetHRP)
    if blob and targetHRP and blob_kick then
        blob_kick(blob, targetHRP, "Right", 1)
    end
end

BlobmanTab:AddToggle({
    Name = "右手オール【❌️メンテナンス】",
    Default = false,
    Callback = function(enabled)
        if enabled then
            coroutine.wrap(function()
                while enabled do
                    local blobs = gatherBlobs()
                    if #blobs == 0 then
                        warn("❌️右手オールはメンテナンス中です。")
                        break
                    end

                    for _, plr in pairs(Players:GetPlayers()) do
                        if plr ~= localPlayer then
                            local hrp = getHRP(plr)
                            if hrp then
                                for _, blob in pairs(blobs) do
                                    rightHandKick(blob, hrp)
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)()
        end
    end
})

local function blobGrabPlayer(player, blobman)
    local targetHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end

    if blobalter == 1 then
        blobman.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
            blobman.LeftDetector,
            targetHRP,
            blobman.LeftDetector:FindFirstChild("LeftWeld")
        )
        blobalter = 2
    else
        blobman.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
            blobman.RightDetector,
            targetHRP,
            blobman.RightDetector:FindFirstChild("RightWeld")
        )
        blobalter = 1
    end
end

local function findBlobmanForLocalPlayer()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "CreatureBlobman" and v:FindFirstChild("VehicleSeat") then
            local weld = v.VehicleSeat:FindFirstChild("SeatWeld")
            if weld and weld.Part1 and weld.Part1:IsDescendantOf(localPlayer.Character) then
                return v
            end
        end
    end
    return nil
end

local function startBlobmanGrabbing()
    local blobman = findBlobmanForLocalPlayer()
    if not blobman then return end

    blobmanCoroutine = coroutine.create(function()
        while true do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer then
                    blobGrabPlayer(player, blobman)
                    task.wait(all_Speed)
                end
            end
        end
    end)
    coroutine.resume(blobmanCoroutine)
end

local function stopBlobmanGrabbing()
    if blobmanCoroutine and coroutine.status(blobmanCoroutine) ~= "dead" then
        coroutine.close(blobmanCoroutine)
        blobmanCoroutine = nil
    end
end

BlobmanTab:AddToggle({
    Name = "高速オール【❌️メンテナンス】",
    Default = false,
    Callback = function(state)
        if state then
            startBlobmanGrabbing()
        else
            stopBlobmanGrabbing()
        end
    end
})

local function gatherBlobs()
    local blobs = {}
    if backpacks then
        for _, backpack in pairs(backpacks:GetChildren()) do
            for _, toy in pairs(backpack:GetChildren()) do
                if toy.Name == "CreatureBlobman" then
                    table.insert(blobs, toy)
                end
            end
        end
    end
    return blobs
end

local function getHRP(plr)
    local char = plr.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
end

local function grabBlob(blob, targetHRP)
    if blob and targetHRP and blob_kick then
        blob_kick(blob, targetHRP, "Left", 1)
        blob_kick(blob, targetHRP, "Right", 1)
    end
end

BlobmanTab:AddToggle({
    Name = "キックオール【❌️メンテナンス】",
    Default = false,
    Callback = function(enabled)
        if enabled then
            coroutine.wrap(function()
                while enabled do
                    local blobs = gatherBlobs()
                    if #blobs == 0 then
                        warn("❌️キックオールはメンテナンス中です。")
                        break
                    end

                    for _, plr in pairs(Players:GetPlayers()) do
                        if plr ~= localPlayer then
                            local hrp = getHRP(plr)
                            if hrp then
                                for _, blob in pairs(blobs) do
                                    grabBlob(blob, hrp)
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)()
        end
    end
})

local AntiTab = Window:MakeTab({Name = "アンチ", Icon =  "rbxassetid://10734951847", PremiumOnly = false})

AntiTab:AddToggle({
    Name = "アンチ掴む",
    Default = false,
    Save = false,
    Flag = "AntiGrab",
    Callback = function(enabled)
        if enabled then
            antiGrabConnection = RunService.Heartbeat:Connect(function()
                local character = localPlayer.Character
                if character and character:FindFirstChild("Head") and character:FindFirstChild("HumanoidRootPart") then
                    local head = character.Head
                    local partOwner = head:FindFirstChild("PartOwner")

                    if partOwner and partOwner.Value ~= localPlayer.Name then
                        Struggle:FireServer()
                        StopAllVelocity:FireServer()

                        for _, part in pairs(character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.Anchored = true
                            end
                        end

                        while localPlayer:IsDescendantOf(game) and localPlayer:FindFirstChild("IsHeld") and localPlayer.IsHeld.Value do
                            task.wait()
                        end

                        for _, part in pairs(character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.Anchored = false
                            end
                        end
                    end
                end
            end)
        else
            if antiGrabConnection then
                antiGrabConnection:Disconnect()
                antiGrabConnection = nil
            end
        end
    end
})

AntiTab:AddToggle({
	Name = "アンチ掴む Tp",
	Default = false,
	Callback = function(Value)
		AntiGrabTPEnabled = Value
		if AntiGrabTPEnabled then
			task.spawn(function()
				while AntiGrabTPEnabled do
					local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if hrp then
						hrp.CFrame = hrp.CFrame + Vector3.new(100, 0, 0)
						task.wait(0.08)
						hrp.CFrame = hrp.CFrame + Vector3.new(0, 0, 100)
						task.wait(0.08)
						hrp.CFrame = hrp.CFrame + Vector3.new(-100, 0, 0)
						task.wait(0.08)
						hrp.CFrame = hrp.CFrame + Vector3.new(0, 0, -100)
						task.wait(0.08)
					else
						break
					end
				end
			end)
		end
	end
})

AntiTab:AddToggle({
    Name = "アンチブロブマンキック",
    Default = false,
    Callback = function(Value)
        antiblob = Value

        if antiBlobConnection then
            antiBlobConnection:Disconnect()
            antiBlobConnection = nil
        end

        if antiblob then
            for _, obj in pairs(S.w:GetDescendants()) do
                if obj.Name == "CreatureBlobman" then
                    local v1 = obj:FindFirstChild("LeftDetector")
                    local v2 = obj:FindFirstChild("RightDetector")
                    if v1 and v2 then
                        local v3 = v1:FindFirstChild("AttachPlayer")
                        local v4 = v2:FindFirstChild("AttachPlayer")
                        if v3 then v3:Destroy() end
                        if v4 then v4:Destroy() end
                    end
                end
            end

            antiBlobConnection = S.w.DescendantAdded:Connect(function(obj)
                if obj.Name == "AttachPlayer" and obj.Parent then
                    local parentName = obj.Parent.Name
                    if parentName == "LeftDetector" or parentName == "RightDetector" then
                        local grandParent = obj.Parent.Parent
                        if grandParent and grandParent.Name == "CreatureBlobman" then
                            obj:Destroy()
                        end
                    end
                end
            end)
        end
    end
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function freezePlayer(state)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        return
    end

    if state then
        char.HumanoidRootPart.Anchored = true
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
        end
    else
        char.HumanoidRootPart.Anchored = false
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 24
        end
    end
end

AntiTab:AddToggle({
    Name = "フリーズ",
    Default = false,
    Callback = function(value)
        freezeEnabled = value
        freezePlayer(value)
    end
})

local function resetCharacter()
    if LocalPlayer.Character then
        LocalPlayer.Character:BreakJoints()
    end
end

AntiTab:AddToggle({
    Name = "自動キャラクターリセット",
    Default = false,
    Callback = function(Value)
        autoReset = Value
        if autoReset then
            task.spawn(function()
                while autoReset do
                    resetCharacter()
                    task.wait(0.5)
                end
            end)
        end
    end
})

AntiTab:AddToggle({
    Name = "アンチ爆発",
    Default = false,
    Flag = "AntiExplosionToggle",
    Callback = function(state)
        getgenv().AntiExplosionEnabled = state
    end
})

local function spawnExtinguisher()
    local character = localPlayer.Character
    local backpack = localPlayer:FindFirstChildOfClass("Backpack")
    if localPlayer:FindFirstChild("CanSpawnToy") and localPlayer.CanSpawnToy.Value and character and character:FindFirstChild("Head") then
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("FireExtinguisher", character.Head.CFrame, Vector3.new(0, 0, 0))
    end
end

local function extinguishFire()
    local character = localPlayer.Character
    local backpack = localPlayer:FindFirstChildOfClass("Backpack")
    if backpack and character then
        local extinguisher = backpack:FindFirstChild("FireExtinguisher")
        if extinguisher then
            local extinguishPart = extinguisher:FindFirstChild("ExtinguishPart")
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if extinguishPart and hrp then
                local original = extinguishPart.Position
                extinguishPart.Position = hrp.Position
                task.wait(0.3)
                extinguishPart.Position = original
            end
        end
    end
end

local function startAntiFire()
    local character = localPlayer.Character
    antiFireLoop = RunService.Heartbeat:Connect(function()
        character = localPlayer.Character
        if not character or not character.Parent then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:FindFirstChild("FireLight") then
            local backpack = localPlayer:FindFirstChildOfClass("Backpack")
            if not (backpack and backpack:FindFirstChild("FireExtinguisher")) then
                spawnExtinguisher()
                repeat task.wait() until backpack and backpack:FindFirstChild("FireExtinguisher")
            end
            extinguishFire()
        end
    end)
end

local function stopAntiFire()
    if antiFireLoop then
        antiFireLoop:Disconnect()
        antiFireLoop = nil
    end
end

AntiTab:AddToggle({
    Name = "アンチファイヤ（照準先にスポーン）",
    Default = false,
    Flag = "AntiBurn",
    Callback = function(state)
        if state then
            startAntiFire()
        else
            stopAntiFire()
        end
    end
})

AntiTab:AddToggle({
    Name = "アンチ落下",
    Default = false,
    Flag = "AntiVoid",
    Callback = function(value)
        antivoid = value
        if antivoid then
            S.w.FallenPartsDestroyHeight = -1000
        else
            S.w.FallenPartsDestroyHeight = -100
        end
    end
})

AntiTab:AddToggle({
    Name = "海の上を歩く",
    Default = false,
    Save = true,
    Flag = "WaterWalk",
    Callback = function(Value)
        local oceanModel = game:GetService("Workspace").Map.AlwaysHereTweenedObjects.Ocean.Object.ObjectModel
        for _, part in pairs(oceanModel:GetChildren()) do
            if part:IsA("Part") and part.Name == "Ocean" then
                part.CanCollide = Value
            end
        end
    end
})

AntiTab:AddLabel("掴まれた時の反撃モード")

_G.SelectedCounterMode = "Knockback"

AntiTab:AddToggle({
	Name = "オートアタッカー",
	Default = false,
	Flag = "EnableAirSuspend",
	Callback = function(enabled)
		airSuspendActive = enabled
		if enabled then
			airSuspendCoroutine = coroutine.create(function()
				while airSuspendActive do
					task.wait(0.02)

					local character = localPlayer.Character
					local localHRP = character and character:FindFirstChild("HumanoidRootPart")
					local head = character and character:FindFirstChild("Head")
					if not (character and head and localHRP) then continue end

					local partOwner = head:FindFirstChild("PartOwner")
					if not partOwner then continue end

					local attacker = Players:FindFirstChild(partOwner.Value)
					if not (attacker and attacker.Character) then continue end

					ReplicatedStorage.CharacterEvents.Struggle:FireServer()

					local hrp = attacker.Character:FindFirstChild("HumanoidRootPart")
					local torso = attacker.Character:FindFirstChild("Torso")
					if not (hrp or torso) then continue end

					if _G.SelectedCounterMode == "Knockback" and hrp then
						local knockback = Instance.new("BodyVelocity")
						knockback.Name = "KnockbackVel"
						knockback.MaxForce = Vector3.new(1e6, 1e6, 1e6)
						knockback.Velocity = (localHRP.CFrame.LookVector * 200) + Vector3.new(0, 50, 0)
						knockback.P = 1e5
						knockback.Parent = hrp
						Debris:AddItem(knockback, 1)

					elseif _G.SelectedCounterMode == "Fling" and torso then
						local velocity = torso:FindFirstChild("l") or Instance.new("BodyVelocity")
						velocity.Name = "l"
						velocity.Parent = torso
						velocity.Velocity = Vector3.new(0, 5000, 0)
						velocity.MaxForce = Vector3.new(0, math.huge, 0)
						Debris:AddItem(velocity, 1)

					elseif _G.SelectedCounterMode == "Freeze" and hrp then
						local freezeGyro = Instance.new("BodyGyro")
						freezeGyro.Name = "FreezeGyro"
						freezeGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
						freezeGyro.P = 1e5
						freezeGyro.CFrame = hrp.CFrame
						freezeGyro.Parent = hrp

						local freezeVel = Instance.new("BodyVelocity")
						freezeVel.Name = "FreezeVel"
						freezeVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
						freezeVel.Velocity = Vector3.new(0, 0, 0)
						freezeVel.P = 1e5
						freezeVel.Parent = hrp

						Debris:AddItem(freezeGyro, 2)
						Debris:AddItem(freezeVel, 2)
					end

					local attackerPart = attacker.Character:FindFirstChild("Head") or torso
					if attackerPart and hrp and hrp:FindFirstChild("FirePlayerPart") then
						ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(
							attackerPart,
							hrp.FirePlayerPart.CFrame
						)
					end
				end
			end)
			coroutine.resume(airSuspendCoroutine)
		else
			if airSuspendCoroutine then
				coroutine.close(airSuspendCoroutine)
				airSuspendCoroutine = nil
			end
		end
	end
})

AntiTab:AddDropdown({
	Name = "掴まれた時の反撃モード",
	Options = {"ノックバック", "飛ばす", "フリーズ"},
	Default = "ノックバック",
	Flag = "CounterMode",
	Callback = function(value)
		if value == "ノックバック" then
			_G.SelectedCounterMode = "Knockback"
		elseif value == "飛ばす" then
			_G.SelectedCounterMode = "Fling"
		elseif value == "フリーズ" then
			_G.SelectedCounterMode = "Freeze"
		end
	end
})

local PlayerTab = Window:MakeTab({Name = "プレイヤー", Icon =  "rbxassetid://11632434473", PremiumOnly = false})

PlayerTab:AddToggle({
    Name = "歩くスピード",
    Default = false,
    Callback = function(Value)
        walkSpeedEnabled = Value
        while walkSpeedEnabled do
            local char = localPlayer.Character
            if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local moveDir = char.Humanoid.MoveDirection
                hrp.CFrame = hrp.CFrame + moveDir * (walkSpeedValue / 10)
            end
            task.wait()
        end

        local char = localPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16
        end
    end
})

PlayerTab:AddSlider({
    Name = "スピード",
    Min = 0,
    Max = 300,
    Default = walkSpeedValue,
    Color = Color3.fromRGB(206, 206, 206),
    Increment = 1,
    Callback = function(Value)
        walkSpeedValue = Value
        local char = localPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = Value
        end
    end
})

PlayerTab:AddToggle({
    Name = "無限ジャンプ",
    Default = false,
    Callback = function(Value)
        infiniteJumpEnabled = Value

        if infiniteJumpEnabled then
            jumpConnection = UIS.JumpRequest:Connect(function()
                local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if jumpConnection then
                jumpConnection:Disconnect()
                jumpConnection = nil
            end
        end
    end
})

PlayerTab:AddSlider({
    Name = "ジャンプパワー",
    Min = 24,
    Max = 300,
    Default = jumpPowerValue,
    Color = Color3.fromRGB(206, 206, 206),
    Increment = 1,
    Callback = function(Value)
        jumpPowerValue = Value
        local char = localPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = Value
        end
    end
})

PlayerTab:AddToggle({
    Name = "重力",
    Default = false,
    Callback = function(Value)
        gt = Value
        task.spawn(function()
            while gt do
                S.w.Gravity = N.gs
                task.wait()
            end
            S.w.Gravity = 100
        end)
    end
})

PlayerTab:AddSlider({
    Name = "重力の力",
    Min = 0,
    Max = 1000,
    Default = 100,
    Color = Color3.fromRGB(206, 206, 206),
    Increment = 10,
    Callback = function(Value)
        N.gs = Value
        if gt then
            S.w.Gravity = Value
        end
    end
})

local ESPTab = Window:MakeTab({Name = "ESP", Icon =  "rbxassetid://7733774602", PremiumOnly = false})

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

local SkeletonLines = {}
local TracerLines = {}
local nameESPObjects = {}

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
			Head = Drawing.new("Line"), Neck = Drawing.new("Line"), Spine = Drawing.new("Line"),
			LeftArm = Drawing.new("Line"), RightArm = Drawing.new("Line"),
			LeftLeg = Drawing.new("Line"), RightLeg = Drawing.new("Line")
		}
	end
	return SkeletonLines[player]
end

local function createTracer(player)
	if player == LocalPlayer or TracerLines[player] then return end
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
	if not ESPEnabled or char:FindFirstChild("Highlight") then return end
	task.delay(1, function()
		if ESPEnabled and not char:FindFirstChild("Highlight") then
			local h = Instance.new("Highlight")
			h.Name = "Highlight"
			h.FillColor = HighlightColor
			h.FillTransparency = HighlightTransparency
			h.OutlineTransparency = 1
			h.Adornee = char
			h.Parent = char
		end
	end)
end

local function addBoxESP(char)
	if not ESPBoxEnabled or char:FindFirstChild("BoxESP") then return end
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
			box.Color3 = ESPBoxColor
			box.Parent = root
		end
	end)
end

local function updateESP()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local c = p.Character
			local h = c:FindFirstChild("Highlight")
			if ESPEnabled then
				if not h then
					highlightCharacter(c)
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

local function updateBoxESP()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local root = p.Character:FindFirstChild("HumanoidRootPart")
			if ESPBoxEnabled and root then
				if not root:FindFirstChild("BoxESP") then
					addBoxESP(p.Character)
				else
					root:FindFirstChild("BoxESP").Color3 = ESPBoxColor
				end
			elseif root and root:FindFirstChild("BoxESP") then
				root:FindFirstChild("BoxESP"):Destroy()
			end
		end
	end
end

local function setupPlayer(player)
	if player == LocalPlayer then return end
	if player.Character then
		if ESPEnabled then highlightCharacter(player.Character) end
		if ESPBoxEnabled then addBoxESP(player.Character) end
	end
	player.CharacterAdded:Connect(function(char)
		char:WaitForChild("HumanoidRootPart", 5)
		if ESPEnabled then highlightCharacter(char) end
		if ESPBoxEnabled then addBoxESP(char) end
	end)
end

for _, p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(p)
	if SkeletonLines[p] then
		for _, line in pairs(SkeletonLines[p]) do line:Remove() end
		SkeletonLines[p] = nil
	end
	if nameESPObjects[p] then nameESPObjects[p]:Remove() nameESPObjects[p] = nil end
	removeTracer(p)
end)

RunService.RenderStepped:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local char = player.Character
			local hrp = char:FindFirstChild("HumanoidRootPart")

			if SkeletonESPEnabled then
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
							l.Color = SkeletonColor
							l.Thickness = SkeletonThickness
							l.Visible = true
						else
							l.Visible = false
						end
					else l.Visible = false end
				end
				drawLine(lines.Head, bones.Head, bones.Torso)
				drawLine(lines.Neck, bones.Head, bones.Torso)
				drawLine(lines.Spine, bones.Torso, hrp)
				drawLine(lines.LeftArm, bones.Torso, bones.LeftArm)
				drawLine(lines.RightArm, bones.Torso, bones.RightArm)
				drawLine(lines.LeftLeg, hrp, bones.LeftLeg)
				drawLine(lines.RightLeg, hrp, bones.RightLeg)
			end

			if TracerESPEnabled then
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

			if not nameESPObjects[player] then
				local t = Drawing.new("Text")
				t.Center = true
				t.Outline = true
				t.Font = 2
				nameESPObjects[player] = t
			end
			local text = nameESPObjects[player]
			local head = char:FindFirstChild("Head")
			if NameESPEnabled and head then
				local pos, vis = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
				text.Text = player.Name
				text.Position = Vector2.new(pos.X, pos.Y)
				text.Color = ESPColor
				text.Size = ESPTextSize
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

ESPTab:AddToggle({
	Name = "ESP（ハイライト）",
	Default = false,
	Callback = function(value)
		ESPEnabled = value
		updateESP()
	end
})

ESPTab:AddColorpicker({
	Name = "ハイライトカラー",
	Default = HighlightColor,
	Callback = function(value)
		HighlightColor = value
		updateESP()
	end
})

ESPTab:AddSlider({
	Name = "ハイライトの透明度",
	Min = 0,
	Max = 1,
	Default = HighlightTransparency,
	Color = Color3.fromRGB(206, 206, 206),
	Increment = 0.05,
	Callback = function(value)
		HighlightTransparency = value
		updateESP()
	end
})

ESPTab:AddLabel("ボックス（箱）")

ESPTab:AddToggle({
	Name = "ESP（箱）",
	Default = false,
	Callback = function(value)
		ESPBoxEnabled = value
		updateBoxESP()
	end
})

ESPTab:AddColorpicker({
	Name = "箱のカラー",
	Default = ESPBoxColor,
	Callback = function(value)
		ESPBoxColor = value
		updateBoxESP()
	end
})

ESPTab:AddLabel("スケルトン（骨）")

ESPTab:AddToggle({
	Name = "ESP（スケルトン）",
	Default = false,
	Callback = function(state)
		SkeletonESPEnabled = state
		if not state then
			for _, parts in pairs(SkeletonLines) do
				for _, line in pairs(parts) do
					line.Visible = false
				end
			end
		end
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
		if not Value then
			for _, line in pairs(TracerLines) do
				line.Visible = false
			end
		end
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

local tpTab = Window:MakeTab({Name = "テレポート", Icon =  "rbxassetid://11647702726", PremiumOnly = false})

tpTab:AddLabel("建物にテレポート")

local locationNames = {
    "紫の家",
    "緑の家",
    "青い家",
    "和風の家",
    "オレンジの家？",
    "リス地",
    "赤い小屋",
    "毒の浮島",
    "海辺",
    "雪山",
    "スロット1",
    "スロット2",
    "スロット3",
    "スロット4"
}

local locations = {
    ["紫の家"] = Vector3.new(255, -7, 449),
    ["緑の家"] = Vector3.new(-534, -7, 93),
    ["青い家"] = Vector3.new(512, 83, -343),
    ["和風の家"] = Vector3.new(548, 123, -73),
    ["オレンジの家？"] = Vector3.new(-493, -7, -165),
    ["リス地"] = Vector3.new(0, -7, 0),
    ["赤い小屋"] = Vector3.new(-192, 60, -282),
    ["毒の浮島"] = Vector3.new(77, 346, 350),
    ["海辺"] = Vector3.new(-738, -7, -69),
    ["雪山"] = Vector3.new(-408, 231, 483),
    ["スロット1"] = Vector3.new(54, -7, -115),
    ["スロット2"] = Vector3.new(170, -7, 527),
    ["スロット3"] = Vector3.new(-213, 86, 421),
    ["スロット4"] = Vector3.new(-540, -7, -40)
}

local selectedLocation = nil

tpTab:AddDropdown({
    Name = "テレポートする場所",
    Default = locationNames[1],
    Options = locationNames,
    Callback = function(value)
        selectedLocation = locations[value]
    end
})

tpTab:AddButton({
    Name = "テレポートする",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and selectedLocation then
            char:MoveTo(selectedLocation)
        else
            warn("Location not selected or character missing.")
        end
    end
})

local HouseTPPoints = {
    Vector3.new(255, -7, 449),
    Vector3.new(-534, -7, 93),
    Vector3.new(-493, -7, -165),
    Vector3.new(548, 123, -73),
    Vector3.new(512, 83, -343)
}

local function teleportTo(position)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(position + Vector3.new(0, 5, 0))
    end
end

tpTab:AddToggle({
    Name = "オート家テレポート",
    Default = false,
    Flag = "AutoHousetp",
    Callback = function(state)
        AutoHouseTP = state
        if state then
            local i = 1
            AutoHouseTPConnection = RunService.Heartbeat:Connect(function()
                teleportTo(HouseTPPoints[i])
                i = i % #HouseTPPoints + 1
            end)
        else
            if AutoHouseTPConnection then
                AutoHouseTPConnection:Disconnect()
                AutoHouseTPConnection = nil
            end
        end
    end
})

tpTab:AddLabel("プレイヤーTP")

local localPlayer = Players.LocalPlayer
local teleportTarget = nil
local teleportLooping = false
local teleportDirection = "Back"
local teleportDistance = 1.5
local aimLocking = false
local aimConnection

local connection
local inputConnection

local playerDisplayMap = {}
local playerDropdown

local function getPlayerDropdownList()
    local names = {}
    playerDisplayMap = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= localPlayer then
            local label = string.format("%s (%s)", p.DisplayName, p.Name)
            playerDisplayMap[label] = p.Name
            table.insert(names, label)
        end
    end
    return names
end

local function updateDropdown()
    if playerDropdown then
        playerDropdown:Refresh(getPlayerDropdownList(), true)
    end
end

playerDropdown = tpTab:AddDropdown({
    Name = "テレポートするプレイヤーを選択",
    Options = getPlayerDropdownList(),
    Default = "",
    Callback = function(value)
        teleportTarget = playerDisplayMap[value]
    end
})

Players.PlayerAdded:Connect(updateDropdown)
Players.PlayerRemoving:Connect(updateDropdown)

tpTab:AddButton({
    Name = "テレポート",
    Callback = function()
        if teleportTarget then
            local target = Players:FindFirstChild(teleportTarget)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local char = localPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local targetHRP = target.Character.HumanoidRootPart
                    local backPos = targetHRP.Position - targetHRP.CFrame.LookVector * 5
                    char:MoveTo(backPos)
                end
            end
        else
            warn("No target selected")
        end
    end
})

tpTab:AddToggle({
    Name = "ループテレポート",
    Default = false,
    Callback = function(value)
        teleportLooping = value

        if value then
            connection = RunService.RenderStepped:Connect(function()
                local character = localPlayer.Character
                local myHRP = character and character:FindFirstChild("HumanoidRootPart")

                if teleportTarget and myHRP then
                    local target = Players:FindFirstChild(teleportTarget)
                    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHRP = target.Character.HumanoidRootPart
                        local offsetVec = Vector3.new()

                        if teleportDirection == "Back" then
                            offsetVec = -targetHRP.CFrame.LookVector * teleportDistance
                        elseif teleportDirection == "Front" then
                            offsetVec = targetHRP.CFrame.LookVector * teleportDistance
                        elseif teleportDirection == "Right" then
                            offsetVec = targetHRP.CFrame.RightVector * teleportDistance
                        elseif teleportDirection == "Left" then
                            offsetVec = -targetHRP.CFrame.RightVector * teleportDistance
                        end

                        myHRP.CFrame = CFrame.new(targetHRP.Position + offsetVec, targetHRP.Position)
                    end
                end
            end)
        else
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end
})

tpTab:AddToggle({
    Name = "ロックカメラ",
    Default = false,
    Callback = function(value)
        aimLocking = value

        if value then
            aimConnection = RunService.RenderStepped:Connect(function()
                local camera = workspace.CurrentCamera
                if not teleportTarget then return end
                local target = Players:FindFirstChild(teleportTarget)
                if target and target.Character then
                    local part = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
                    if part then
                        pcall(function()
                            camera.CFrame = CFrame.new(camera.CFrame.Position, part.Position)
                        end)
                    end
                end
            end)
        else
            if aimConnection then
                aimConnection:Disconnect()
                aimConnection = nil
            end
        end
    end
})

tpTab:AddToggle({
    Name = "その人の視点を見る",
    Default = false,
    Callback = function(state)
        viewing = state

        local targetPlayer = teleportTarget and Players:FindFirstChild(teleportTarget)
        if state and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = targetPlayer.Character.Humanoid
        else
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("Humanoid") then
                Camera.CameraSubject = myChar.Humanoid
            end
        end
    end
})

tpTab:AddSlider({
    Name = "距離",
    Min = 1,
    Max = 30,
    Default = 1.5,
    Color = Color3.fromRGB(206, 206, 206),
    Increment = 0.5,
    Callback = function(value)
        teleportDistance = value
    end
})

tpTab:AddDropdown({
    Name = "見る部位",
    Options = {"Back", "Front", "Left", "Right"},
    Default = "Back",
    Callback = function(value)
        teleportDirection = value
    end
})

local tp2Tab = Window:MakeTab({Name = "座標", Icon =  "rbxassetid://4483345998", PremiumOnly = false})

tp2Tab:AddButton({
	Name = "1000万座標",
	Callback = function()
		local player = game.Players.LocalPlayer
		if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10000000, 0)
		end
	end
})

tp2Tab:AddButton({
	Name = "2000万座標",
	Callback = function()
		local player = game.Players.LocalPlayer
		if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 20000000, 0)
		end
	end
})

tp2Tab:AddButton({
	Name = "3000万座標",
	Callback = function()
		local player = game.Players.LocalPlayer
		if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 30000000, 0)
		end
	end
})

tp2Tab:AddButton({
	Name = "4000万座標",
	Callback = function()
		local player = game.Players.LocalPlayer
		if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 40000000, 0)
		end
	end
})

tp2Tab:AddButton({
	Name = "5000万座標",
	Callback = function()
		local player = game.Players.LocalPlayer
		if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50000000, 0)
		end
	end
})

tp2Tab:AddButton({
	Name = "6000万座標",
	Callback = function()
		local player = game.Players.LocalPlayer
		if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 60000000, 0)
		end
	end
})

local LineTab = Window:MakeTab({Name = "カスタム線", Icon =  "rbxassetid://", PremiumOnly = false})

local lineColors = {}
for i = 1, 20 do
    lineColors[i] = Color3.fromRGB(0, 0, 0)
end

local function updateLineColors()
    local sequence = {}
    for i, color in ipairs(lineColors) do
        table.insert(sequence, ColorSequenceKeypoint.new((i - 1) / 19, color))
    end
    local colorSequence = ColorSequence.new(sequence)

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local DataEvents = ReplicatedStorage:FindFirstChild("DataEvents")
    local SetLineColorEvent = DataEvents and DataEvents:FindFirstChild("UpdateLineColorsEvent")

    if SetLineColorEvent then
        SetLineColorEvent:FireServer(colorSequence)
    else
        warn("UpdateLineColorsEvent が見つかりません")
    end
end

LineTab:AddColorpicker({
    Name = "線の色",
    Default = Color3.fromRGB(0, 0, 0),
    Callback = function(Color)
        lineColors[1] = Color
        updateLineColors()
    end
})

LineTab:AddColorpicker({
    Name = "線の色2",
    Default = Color3.fromRGB(0, 0, 0),
    Callback = function(Color)
        lineColors[2] = Color
        updateLineColors()
    end
})

LineTab:AddColorpicker({
    Name = "線の色3",
    Default = Color3.fromRGB(0, 0, 0),
    Callback = function(Color)
        lineColors[3] = Color
        updateLineColors()
    end
})

LineTab:AddColorpicker({
    Name = "線の色4",
    Default = Color3.fromRGB(0, 0, 0),
    Callback = function(Color)
        lineColors[4] = Color
        updateLineColors()
    end
})

LineTab:AddColorpicker({
    Name = "線の色5",
    Default = Color3.fromRGB(0, 0, 0),
    Callback = function(Color)
        lineColors[5] = Color
        updateLineColors()
    end
})

LineTab:AddColorpicker({
    Name = "線の色6",
    Default = Color3.fromRGB(0, 0, 0),
    Callback = function(Color)
        lineColors[6] = Color
        updateLineColors()
    end
})

LineTab:AddColorpicker({
    Name = "線の色7",
    Default = Color3.fromRGB(0, 0, 0),
    Callback = function(Color)
        lineColors[7] = Color
        updateLineColors()
    end
})

LineTab:AddColorpicker({
    Name = "線の色8",
    Default = Color3.fromRGB(0, 0, 0),
    Callback = function(Color)
        lineColors[8] = Color
        updateLineColors()
    end
})

LineTab:AddColorpicker({
    Name = "線の色9",
    Default = Color3.fromRGB(0, 0, 0),
    Callback = function(Color)
        lineColors[9] = Color
        updateLineColors()
    end
})

LineTab:AddColorpicker({
    Name = "線の色10",
    Default = Color3.fromRGB(0, 0, 0),
    Callback = function(Color)
        lineColors[10] = Color
        updateLineColors()
    end
})

LineTab:AddColorpicker({
    Name = "線の色11",
    Default = Color3.fromRGB(0, 0, 0),
    Callback = function(Color)
        lineColors[11] = Color
        updateLineColors()
    end
})

LineTab:AddColorpicker({
    Name = "線の色12",
    Default = Color3.fromRGB(0, 0, 0),
    Callback = function(Color)
        lineColors[12] = Color
        updateLineColors()
    end
})

LineTab:AddColorpicker({
    Name = "線の色13",
    Default = Color3.fromRGB(0, 0, 0),
    Callback = function(Color)
        lineColors[13] = Color
        updateLineColors()
    end
})

LineTab:AddColorpicker({
    Name = "線の色14",
    Default = Color3.fromRGB(0, 0, 0),
    Callback = function(Color)
        lineColors[14] = Color
        updateLineColors()
    end
})

LineTab:AddColorpicker({
    Name = "線の色15",
    Default = Color3.fromRGB(0, 0, 0),
    Callback = function(Color)
        lineColors[15] = Color
        updateLineColors()
    end
})

LineTab:AddColorpicker({
    Name = "線の色16",
    Default = Color3.fromRGB(0, 0, 0),
    Callback = function(Color)
        lineColors[16] = Color
        updateLineColors()
    end
})

LineTab:AddColorpicker({
    Name = "線の色17",
    Default = Color3.fromRGB(0, 0, 0),
    Callback = function(Color)
        lineColors[17] = Color
        updateLineColors()
    end
})

LineTab:AddColorpicker({
    Name = "線の色18",
    Default = Color3.fromRGB(0, 0, 0),
    Callback = function(Color)
        lineColors[18] = Color
        updateLineColors()
    end
})

LineTab:AddColorpicker({
    Name = "線の色19",
    Default = Color3.fromRGB(0, 0, 0),
    Callback = function(Color)
        lineColors[19] = Color
        updateLineColors()
    end
})

LineTab:AddColorpicker({
    Name = "線の色20",
    Default = Color3.fromRGB(0, 0, 0),
    Callback = function(Color)
        lineColors[20] = Color
        updateLineColors()
    end
})

local LoopTab  = Window:MakeTab({Name = "ループ", Icon =  "rbxassetid://", PremiumOnly = false})

local selectedPlayerName
local playerDropdown

local function blobGrabPlayer(player, blobman)
    local targetHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end

    blobman.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
        blobman.LeftDetector,
        targetHRP,
        blobman.LeftDetector:FindFirstChild("LeftWeld")
    )
end

local function findBlobmanForLocalPlayer()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v.Name == "CreatureBlobman" and v:FindFirstChild("VehicleSeat") then
            local weld = v.VehicleSeat:FindFirstChild("SeatWeld")
            if weld and weld.Part1 and weld.Part1:IsDescendantOf(localPlayer.Character) then
                return v
            end
        end
    end
    return nil
end

local function getPlayerList()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
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

LoopTab:AddDropdown({
    Name = "プレイヤーを選択",
    Options = getPlayerList(),
    Callback = function(value)
        selectedPlayerName = value
    end
})

LoopTab:AddToggle({
    Name = "ループBring【❌️メンテナンス】",
    Default = false,
    Callback = function(state)
        bringLooping = state
        if bringLoopThread then bringLoopThread = nil end
        if bringLooping then
            bringLoopThread = coroutine.create(function()
                while bringLooping do
                    local target = getPlayerByDisplayName(selectedPlayerName)
                    local blobman = findBlobmanForLocalPlayer()
                    if target and blobman then
                        blobGrabPlayer(target, blobman)
                    end
                    task.wait(1)
                end
            end)
            coroutine.resume(bringLoopThread)
        end
    end
})

Players.PlayerAdded:Connect(updateDropdown)
Players.PlayerRemoving:Connect(updateDropdown)

local VisualTab = Window:MakeTab({Name = "ビジュアル", Icon =  "rbxassetid://7733774602", PremiumOnly = false})

VisualTab:AddLabel("空")

VisualTab:AddSlider({
    Name = "時間帯",
    Min = 0,
    Max = 23,
    Default = 14,
    Color = Color3.fromRGB(206, 206, 206),
    Increment = 0.001,
    Callback = function(Value)
        game.Lighting.ClockTime = Value
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
                local data = game:GetService("HttpService"):JSONDecode(response.Body)
                game.Lighting.TimeOfDay = string.format("%02d:%02d:%02d", tonumber(data.hour)+1, tonumber(data.minute), tonumber(data.seconds))
                task.wait(1)
            end
        end)
    end
})

VisualTab:AddLabel("コイン")

VisualTab:AddTextbox({
    Name = "偽コインの枚数",
    Default = "",
    TextDisappear = false,
    Callback = function(text)
        skolko = text
    end
})

VisualTab:AddButton({
    Name = "偽のコインを適用",
    Callback = function()
        local coinAmount = tonumber(skolko) or 0
        local playerGui = game.Players.LocalPlayer.PlayerGui
        local coinText = playerGui.MenuGui.TopRight.CoinsFrame.CoinsDisplay.Coins
        if coinText then
            coinText.Text = tostring(coinAmount)
        end
    end
})

VisualTab:AddLabel("カメラ関係")

VisualTab:AddButton({
    Name = "三人称",
    Callback = function()
        local player = game.Players.LocalPlayer
        player.CameraMaxZoomDistance = 8000000
        player.CameraMode = Enum.CameraMode.Classic
    end
})

VisualTab:AddSlider({
    Name = "視野角",
    Min = 0,
    Max = 120,
    Default = 100,
    Color = Color3.fromRGB(206, 206, 206),
    Increment = 1,
    ValueName = "",
    Callback = function(siya)
        game.Workspace.CurrentCamera.FieldOfView = siya
    end
})

local scriptTab = Window:MakeTab({Name = "スクリプト", Icon =  "rbxassetid://7733920644", PremiumOnly = false})

scriptTab:AddButton({
    Name = "blitz",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/BlizTBr/scripts/main/FTAP.lua"))()
    end
})

scriptTab:AddButton({
    Name = "bliz crack",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/wploits/cp-s-roblox-script./main/bliztcrack"))()
    end
})

scriptTab:AddButton({
    Name = "Cosmic Hub（Key: CosmicSigma）",
    Callback = function()
        getgenv().gethui = function() return game.CoreGui end
loadstring(game:HttpGet("https://raw.githubusercontent.com/Jeffepicy/CosmicHub/main/CosmicHub",true))()
    end
})

scriptTab:AddButton({
    Name = "Dex",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end
})

local shaderTab = Window:MakeTab({Name = "シェーダー", Icon =  "rbxassetid://", PremiumOnly = false})

shaderTab:AddButton({
    Name = "シェーダー",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MZEEN2424/Graphics/main/Graphics.xml"))()
    end
})

shaderTab:AddButton({
    Name = "シェーダー2",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/randomstring0/pshade-ultimate/refs/heads/main/src/cd.lua'))()
    end
})

shaderTab:AddButton({
    Name = "シェーダー3",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Simple-Shader-37434"))()
    end
})

local bind1Tab = Window:MakeTab({Name = "モバイル用スクリプト", Icon =  "rbxassetid://7733799901", PremiumOnly = false})

bind1Tab:AddButton({
    Name = "クリップテレポート",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/ftap-bocchi/scripts/refs/heads/main/ClickTP.lua'))()
    end
})

bind1Tab:AddButton({
    Name = "ズーム",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/ftap-bocchi/scripts/main/Zoom.lua'))()
    end
})

bind1Tab:AddButton({
    Name = "視野角",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/ftap-bocchi/scripts/refs/heads/main/fov.lua'))()
    end
})

local bindTab = Window:MakeTab({Name = "キーバインド", Icon =  "rbxassetid://7733799901", PremiumOnly = false})

local function getHRP()
    local character = LocalPlayer.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

bindTab:AddBind({
    Name = "クリックTP",
    Default = Enum.KeyCode.Z,
    Callback = function()
        local targetPos = Mouse.Hit
        local hrp = getHRP()
        if targetPos and hrp then
            hrp.CFrame = CFrame.new(targetPos.X, targetPos.Y + 5, targetPos.Z)
        end
    end
})

local function get_all12(target)
    if not target then return end
    local char = target:FindFirstAncestorOfClass("Model")
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hd = char:FindFirstChild("Head")

    local lpChar = LocalPlayer.Character
    if not lpChar then return end
    local hrp1 = lpChar:FindFirstChild("HumanoidRootPart")
    local hum1 = lpChar:FindFirstChildOfClass("Humanoid")
    local hd1 = lpChar:FindFirstChild("Head")

    return hrp, hum, hd, hrp1, hum1, hd1
end

local function check_hum(hum)
    return hum and hum.Health > 0
end

local function check_prem(player)
    return true
end

local function plr_fling(hrp)
    if not hrp then return end

    for _, part in ipairs(hrp.Parent:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 1e8, 0)
    bv.MaxForce = Vector3.new(1e10, 1e10, 1e10)
    bv.P = 1e9
    bv.Parent = hrp
    game.Debris:AddItem(bv, 0.05)
end

bindTab:AddBind({
    Name = "プレイヤーを掴んで飛ばす",
    Default = Enum.KeyCode.F,
    Hold = false,
    Flag = "FlingPlayerBind",
    Callback = function()
        local target = Mouse.Target
        local hrp, hum, hd, hrp1, hum1, hd1 = get_all12(target)
        if hum and check_hum(hum) and hum1 and check_hum(hum1) and check_prem(hrp1.Parent) then
            plr_fling(hrp)
        end
    end
})

local function resetCharacter()
    if LocalPlayer.Character then
        LocalPlayer.Character:BreakJoints()
    end
end

bindTab:AddBind({
    Name = "キャラクターリセット",
    Default = Enum.KeyCode.K,
    Hold = false,
    Callback = function()
        resetCharacter()
    end
})

bindTab:AddBind({
    Name = "ズーム",
    Default = Enum.KeyCode.C,
    Hold = false,
    Callback = function()
        ZoomEnabled = not ZoomEnabled
        if ZoomEnabled then
            OriginalFOV = Camera.FieldOfView
            Camera.FieldOfView = 20
        else
            Camera.FieldOfView = OriginalFOV
        end
    end
})

local AuthorTab = Window:MakeTab({Name = "作者情報", Icon =  "rbxassetid://", PremiumOnly = false})

AuthorTab:AddParagraph(" DarkPulse_07", "ID: DarkPulse_pc")

AuthorTab:AddButton({
    Name = "Discord ID",
    Callback = function()
        setclipboard("knx4649")
        OrionLib:MakeNotification({
            Name = "コピー成功",
            Content = "クリップボードにコピーしました！",
            Image = "rbxassetid://",
            Time = 3
        })
    end
})

AuthorTab:AddButton({
    Name = "TikTok",
    Callback = function()
        setclipboard("tiktok.com/@botti_11")
        OrionLib:MakeNotification({
            Name = "コピー成功",
            Content = "クリップボードにコピーしました！",
            Image = "rbxassetid://",
            Time = 3
        })
    end
})

AuthorTab:AddButton({
    Name = "roblox ID",
    Callback = function()
        setclipboard("DarkPulse_pc")
        OrionLib:MakeNotification({
            Name = "コピー成功",
            Content = "クリップボードにコピーしました！",
            Image = "rbxassetid://",
            Time = 3
        })
    end
})

local InfoTab = Window:MakeTab({Name = "情報", Icon =  "rbxassetid://11472832266", PremiumOnly = false})

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer

InfoTab:AddParagraph("ユーザーネーム", LocalPlayer.Name)
InfoTab:AddParagraph("表示名", LocalPlayer.DisplayName)
InfoTab:AddParagraph("ユーザーID", tostring(LocalPlayer.UserId))
InfoTab:AddParagraph("アカウント時間", LocalPlayer.Name .. ": " .. tostring(LocalPlayer.AccountAge) .. "日目")

local success, info = pcall(function()
    return MarketplaceService:GetProductInfo(game.PlaceId)
end)

if success and info then
    InfoTab:AddParagraph("ゲーム名", info.Name)
else
    InfoTab:AddParagraph("Game Name", "取得失敗")
end

InfoTab:AddParagraph("ゲームID", tostring(game.PlaceId))
