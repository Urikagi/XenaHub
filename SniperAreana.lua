--// Clean Organized GUI
--// LocalScript inside StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local supportedGameNames = {
	["sniper arena"] = true,
}

local supportedPlaceIds = {
	-- add exact PlaceIds for supported games here if needed
}

local function isSupportedGame()
	local success, info = pcall(function()
		return MarketplaceService:GetProductInfo(game.PlaceId)
	end)

	local gameName = ""
	if success and info and info.Name then
		gameName = string.lower(info.Name)
	else
		gameName = string.lower(game.Name or "")
	end

	return supportedGameNames[gameName] or supportedPlaceIds[game.PlaceId]
end

local function showUnsupportedWarning()
	local unsupportedGui = Instance.new("ScreenGui")
	unsupportedGui.Name = "UnsupportedGameWarning"
	unsupportedGui.ResetOnSpawn = false
	unsupportedGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local warningLabel = Instance.new("TextLabel")
	warningLabel.Size = UDim2.new(0, 240, 0, 40)
	warningLabel.Position = UDim2.new(1, -20, 1, -20)
	warningLabel.AnchorPoint = Vector2.new(1, 1)
	warningLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	warningLabel.BorderSizePixel = 0
	warningLabel.Text = "game not supported"
	warningLabel.TextColor3 = Color3.new(1, 1, 1)
	warningLabel.TextScaled = true
	warningLabel.Font = Enum.Font.GothamBold
	warningLabel.Parent = unsupportedGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = warningLabel
end

if not isSupportedGame() then
	showUnsupportedWarning()
	return
end

--------------------------------------------------
-- STATES
--------------------------------------------------

local AimlockEnabled = false
local AutoM1Enabled = false
local ESPEnabled = false
local FlyEnabled = false

local WalkSpeedValue = 16
local FlySpeed = 60

local CurrentTarget

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "CleanHub"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 360, 0, 460)
main.Position = UDim2.new(0.5, -180, 0.5, -230)
main.BackgroundColor3 = Color3.fromRGB(24,24,24)
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)

--------------------------------------------------
-- TITLE
--------------------------------------------------

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,55)
title.BackgroundColor3 = Color3.fromRGB(18,18,18)
title.Text = "Sniper Arena Hub"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = main

Instance.new("UICorner", title).CornerRadius = UDim.new(0,14)

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1,0,0,24)
subtitle.Position = UDim2.new(0,0,0,55)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Only supported in Sniper Arena"
subtitle.TextColor3 = Color3.fromRGB(180,180,180)
subtitle.TextScaled = false
subtitle.TextSize = 16
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextYAlignment = Enum.TextYAlignment.Center
subtitle.Parent = main

--------------------------------------------------
-- CONTAINER
--------------------------------------------------

local container = Instance.new("Frame")
container.Size = UDim2.new(1,-20,1,-110)
container.Position = UDim2.new(0,10,0,90)
container.BackgroundTransparency = 1
container.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,10)
layout.Parent = container

--------------------------------------------------
-- TOGGLE CREATOR
--------------------------------------------------

local function createToggle(text)

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,0,0,55)
	frame.BackgroundColor3 = Color3.fromRGB(32,32,32)
	frame.Parent = container

	Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6,0,1,0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.new(1,1,1)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = frame

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0,90,0,35)
	button.Position = UDim2.new(1,-100,0.5,-17)
	button.BackgroundColor3 = Color3.fromRGB(45,45,45)
	button.Text = "OFF"
	button.TextScaled = true
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = Color3.new(1,1,1)
	button.Parent = frame

	Instance.new("UICorner", button).CornerRadius = UDim.new(1,0)

	local state = false

	local function update()
		if state then
			button.Text = "ON"
			button.BackgroundColor3 = Color3.fromRGB(0,170,0)
		else
			button.Text = "OFF"
			button.BackgroundColor3 = Color3.fromRGB(45,45,45)
		end
	end

	button.MouseButton1Click:Connect(function()
		state = not state
		update()
	end)

	update()

	return {
		Button = button,
		Get = function()
			return state
		end,
		Set = function(v)
			state = v
			update()
		end
	}
end

--------------------------------------------------
-- SLIDER CREATOR
--------------------------------------------------

local function createAdjuster(text, defaultValue)

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,0,0,70)
	frame.BackgroundColor3 = Color3.fromRGB(32,32,32)
	frame.Parent = container

	Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,0,0.5,0)
	label.BackgroundTransparency = 1
	label.Text = text .. ": " .. tostring(defaultValue)
	label.TextColor3 = Color3.new(1,1,1)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = frame

	local minus = Instance.new("TextButton")
	minus.Size = UDim2.new(0,40,0,30)
	minus.Position = UDim2.new(0,15,1,-38)
	minus.Text = "-"
	minus.TextScaled = true
	minus.Font = Enum.Font.GothamBold
	minus.BackgroundColor3 = Color3.fromRGB(45,45,45)
	minus.TextColor3 = Color3.new(1,1,1)
	minus.Parent = frame

	Instance.new("UICorner", minus)

	local plus = Instance.new("TextButton")
	plus.Size = UDim2.new(0,40,0,30)
	plus.Position = UDim2.new(1,-55,1,-38)
	plus.Text = "+"
	plus.TextScaled = true
	plus.Font = Enum.Font.GothamBold
	plus.BackgroundColor3 = Color3.fromRGB(45,45,45)
	plus.TextColor3 = Color3.new(1,1,1)
	plus.Parent = frame

	Instance.new("UICorner", plus)

	local value = defaultValue

	local function update()
		label.Text = text .. ": " .. tostring(value)
	end

	minus.MouseButton1Click:Connect(function()
		value = math.max(0, value - 2)
		update()
	end)

	plus.MouseButton1Click:Connect(function()
		value += 2
		update()
	end)

	return {
		Get = function()
			return value
		end
	}
end

local function createSectionLabel(text)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,0,0,30)
	frame.BackgroundTransparency = 1
	frame.Parent = container

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,0,1,0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(170,170,170)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame
end

--------------------------------------------------
-- FEATURES
--------------------------------------------------

createSectionLabel("Combat")
local AimToggle = createToggle("Aimlock")
local M1Toggle = createToggle("Auto M1")

createSectionLabel("Movement")
local FlyToggle = createToggle("Fly")
local SpeedAdjust = createAdjuster("WalkSpeed",16)
local FlyAdjust = createAdjuster("FlySpeed",60)

createSectionLabel("Visual")
local ESPToggle = createToggle("ESP")

--------------------------------------------------
-- ESP
--------------------------------------------------

local ESPCache = {}

local function createESP(player)

	if ESPCache[player] then
		return
	end

	local character = player.Character
	if not character then return end

	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = character

	ESPCache[player] = highlight
end

--------------------------------------------------
-- ALIVE CHECK
--------------------------------------------------

local function isAlive(character)

	if not character then
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local head = character:FindFirstChild("Head")

	if not humanoid or not head then
		return false
	end

	if humanoid.Health <= 0 then
		return false
	end

	if humanoid:GetState() == Enum.HumanoidStateType.Dead then
		return false
	end

	return true
end

--------------------------------------------------
-- VISIBILITY CHECK
--------------------------------------------------

local function isVisible(character)

	local head = character:FindFirstChild("Head")
	if not head then return false end

	local origin = Camera.CFrame.Position
	local direction = head.Position - origin

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = {
		LocalPlayer.Character,
		Camera
	}

	local result = workspace:Raycast(origin, direction, params)

	if result then
		return result.Instance:IsDescendantOf(character)
	end

	return true
end

--------------------------------------------------
-- TARGET FINDER
--------------------------------------------------

local function getClosestPlayer()

	local closest = nil
	local shortest = math.huge

	for _,player in pairs(Players:GetPlayers()) do

		if player ~= LocalPlayer then

			local character = player.Character

			if isAlive(character) and isVisible(character) then

				local head = character:FindFirstChild("Head")

				local pos, visible =
					Camera:WorldToViewportPoint(head.Position)

				if visible then

					local mousePos =
						UserInputService:GetMouseLocation()

					local distance = (
						Vector2.new(pos.X,pos.Y) - mousePos
					).Magnitude

					if distance < shortest then
						shortest = distance
						closest = player
					end
				end
			end
		end
	end

	return closest
end

--------------------------------------------------
-- FLY
--------------------------------------------------

local bodyVelocity
local flyConnection

local function startFly()

	local character = LocalPlayer.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(999999,999999,999999)
	bodyVelocity.Parent = root

	flyConnection = RunService.RenderStepped:Connect(function()

		local moveDir = Vector3.zero

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			moveDir += Camera.CFrame.LookVector
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			moveDir -= Camera.CFrame.LookVector
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			moveDir -= Camera.CFrame.RightVector
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			moveDir += Camera.CFrame.RightVector
		end

		bodyVelocity.Velocity =
			moveDir.Unit * FlyAdjust:Get()
	end)
end

local function stopFly()

	if flyConnection then
		flyConnection:Disconnect()
	end

	if bodyVelocity then
		bodyVelocity:Destroy()
	end
end

--------------------------------------------------
-- MAIN LOOP
--------------------------------------------------

RunService.RenderStepped:Connect(function()

	------------------------------------------
	-- WALKSPEED
	------------------------------------------

	local character = LocalPlayer.Character

	if character then

		local humanoid =
			character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.WalkSpeed = SpeedAdjust:Get()
		end
	end

	------------------------------------------
	-- AIMLOCK
	------------------------------------------

	if AimToggle:Get() then

		CurrentTarget = getClosestPlayer()

		if CurrentTarget and CurrentTarget.Character then

			local head =
				CurrentTarget.Character:FindFirstChild("Head")

			if head then

				Camera.CFrame = CFrame.new(
					Camera.CFrame.Position,
					head.Position
				)

				if M1Toggle:Get() then

					VirtualInputManager:SendMouseButtonEvent(
						0,0,0,true,game,0
					)

					VirtualInputManager:SendMouseButtonEvent(
						0,0,0,false,game,0
					)
				end
			end
		end
	end

	------------------------------------------
	-- ESP
	------------------------------------------

	if ESPToggle:Get() then

		for _,player in pairs(Players:GetPlayers()) do

			if player ~= LocalPlayer then
				createESP(player)
			end
		end
	end

	------------------------------------------
	-- FLY
	------------------------------------------

	if FlyToggle:Get() and not FlyEnabled then
		FlyEnabled = true
		startFly()
	elseif not FlyToggle:Get() and FlyEnabled then
		FlyEnabled = false
		stopFly()
	end
end)

--------------------------------------------------
-- DRAGGING
--------------------------------------------------

local dragging = false
local dragStart
local startPos

title.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 then

		dragging = true
		dragStart = input.Position
		startPos = main.Position

		input.Changed:Connect(function()

			if input.UserInputState ==
				Enum.UserInputState.End then

				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if dragging and
		input.UserInputType ==
		Enum.UserInputType.MouseMovement then

		local delta = input.Position - dragStart

		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)