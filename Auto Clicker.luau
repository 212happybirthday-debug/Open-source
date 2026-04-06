local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoClickGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 120)
MainFrame.Position = UDim2.new(0, 0, 0.75, -60)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 182, 193)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 18)

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 2.5
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Auto Click"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 26
Title.TextColor3 = Color3.fromRGB(255, 105, 180)
Title.Parent = MainFrame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 25)
Status.Position = UDim2.new(0, 0, 0, 40)
Status.BackgroundTransparency = 1
Status.Text = "OFF"
Status.Font = Enum.Font.GothamBold
Status.TextSize = 18
Status.TextColor3 = Color3.fromRGB(255, 60, 60)
Status.Parent = MainFrame

local ToggleBG = Instance.new("Frame")
ToggleBG.Size = UDim2.new(0, 90, 0, 30)
ToggleBG.Position = UDim2.new(0.5, -45, 1, -40)
ToggleBG.BackgroundColor3 = Color3.fromRGB(255, 200, 200)
ToggleBG.BorderSizePixel = 0
ToggleBG.Parent = MainFrame

Instance.new("UICorner", ToggleBG).CornerRadius = UDim.new(0, 15)

local Toggle = Instance.new("Frame")
Toggle.Size = UDim2.new(0, 35, 0, 30)
Toggle.BackgroundColor3 = Color3.fromRGB(255, 240, 245)
Toggle.BorderSizePixel = 0
Toggle.Parent = ToggleBG

Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 15)

local Button = Instance.new("TextButton")
Button.Size = ToggleBG.Size
Button.Position = ToggleBG.Position
Button.BackgroundTransparency = 1
Button.Text = ""
Button.Parent = MainFrame

local dragging = false
local dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

local enabled = false
local clickPower = 5

local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local ON_POS = UDim2.new(1, -35, 0, 0)
local OFF_POS = UDim2.new(0, 0, 0, 0)

Button.MouseButton1Click:Connect(function()
	enabled = not enabled

	if enabled then
		Status.Text = "ON"
		Status.TextColor3 = Color3.fromRGB(0, 255, 150)
		TweenService:Create(Toggle, tweenInfo, {Position = ON_POS}):Play()
	else
		Status.Text = "OFF"
		Status.TextColor3 = Color3.fromRGB(255, 60, 60)
		TweenService:Create(Toggle, tweenInfo, {Position = OFF_POS}):Play()
	end
end)

RunService.RenderStepped:Connect(function()
	if enabled then
		for i = 1, clickPower do
			VirtualUser:ClickButton1(Vector2.new())
		end
	end
end)

local hue = 0
RunService.RenderStepped:Connect(function(dt)
	hue = (hue + dt * 0.4) % 1
	Stroke.Color = Color3.fromHSV(hue, 1, 1)
end)
