local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local Library = {}
Library.__index = Library

local FONT = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
local FONT_BOLD = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
local FONT_SEMIBOLD = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
local FONT_REGULAR = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

local Colors = {
	Background = Color3.fromRGB(15, 16, 20),
	SectionBg = Color3.fromRGB(17, 18, 22),
	SectionHeader = Color3.fromRGB(19, 20, 25),
	ElementBg = Color3.fromRGB(22, 23, 30),
	Stroke = Color3.fromRGB(30, 32, 42),
	Liner = Color3.fromRGB(28, 28, 40),
	PageBg = Color3.fromRGB(14, 15, 19),
	TextActive = Color3.fromRGB(255, 255, 255),
	TextInactive = Color3.fromRGB(75, 77, 95),
	TextMuted = Color3.fromRGB(55, 57, 72),
	AccentStart = Color3.fromRGB(200, 60, 30),
	AccentEnd = Color3.fromRGB(230, 120, 20),
}

local GameNames = {
	[2753915549] = "Bloxfruits",
	[4442272183] = "Bloxfruits",
	[7449423635] = "Bloxfruits",
}

local function getGameName()
	local name = GameNames[game.PlaceId]
	if name then return name end
	local ok, info = pcall(function()
		return MarketplaceService:GetProductInfo(game.PlaceId)
	end)
	if ok and info then return info.Name end
	return "Unknown"
end

local function tween(obj, duration, props, style, direction)
	local info = TweenInfo.new(duration, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

local function applyCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
	return corner
end

local function applyAccentGradient(parent)
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Colors.AccentStart),
		ColorSequenceKeypoint.new(1, Colors.AccentEnd),
	})
	grad.Parent = parent
	return grad
end

local function applyPadding(parent, top, right, bottom, left)
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, top or 0)
	pad.PaddingRight = UDim.new(0, right or 0)
	pad.PaddingBottom = UDim.new(0, bottom or 0)
	pad.PaddingLeft = UDim.new(0, left or 0)
	pad.Parent = parent
	return pad
end

local function applyListLayout(parent, direction, padding, sortOrder)
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = direction or Enum.FillDirection.Vertical
	layout.Padding = UDim.new(0, padding or 0)
	layout.SortOrder = sortOrder or Enum.SortOrder.LayoutOrder
	layout.Parent = parent
	return layout
end

local function makeDraggable(frame, handle)
	local dragging, dragInput, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

function Library:CreateWindow()
	local Window = setmetatable({}, {__index = Library})
	Window._tabs = {}
	Window._activeTab = nil
	Window._tabIndicator = nil

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ScreenGui"
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ResetOnSpawn = false

	local ok, hui = pcall(function() return gethui() end)
	if ok and hui then
		screenGui.Parent = hui
	else
		local ok2, _ = pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
		if not ok2 then
			screenGui.Parent = Player:WaitForChild("PlayerGui")
		end
	end

	Window._screenGui = screenGui

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.BackgroundColor3 = Colors.Background
	mainFrame.ClipsDescendants = true
	mainFrame.Position = UDim2.fromScale(0.5, 0.5)
	mainFrame.Size = UDim2.fromOffset(695, 489)
	mainFrame.Parent = screenGui
	applyCorner(mainFrame, 11)
	Window._mainFrame = mainFrame

	local header = Instance.new("Frame")
	header.Name = "Header"
	header.AnchorPoint = Vector2.new(0.5, 0)
	header.BackgroundTransparency = 1
	header.Position = UDim2.fromScale(0.5, 0)
	header.Size = UDim2.fromOffset(695, 37)
	header.Parent = mainFrame

	makeDraggable(mainFrame, header)

	local headerLiner = Instance.new("Frame")
	headerLiner.Name = "Liner"
	headerLiner.AnchorPoint = Vector2.new(0, 1)
	headerLiner.BackgroundColor3 = Colors.Liner
	headerLiner.BorderSizePixel = 0
	headerLiner.Position = UDim2.fromScale(0, 1)
	headerLiner.Size = UDim2.new(1, 0, 0, 2)
	headerLiner.Parent = header

	local libaryIcon = Instance.new("ImageLabel")
	libaryIcon.Name = "LibaryIcon"
	libaryIcon.AnchorPoint = Vector2.new(0, 0.5)
	libaryIcon.BackgroundTransparency = 1
	libaryIcon.Image = "rbxassetid://0"
	libaryIcon.Position = UDim2.new(0, 26, 0.5, 0)
	libaryIcon.ScaleType = Enum.ScaleType.Fit
	libaryIcon.Size = UDim2.fromOffset(20, 20)
	libaryIcon.Parent = header

	local gameName = getGameName()

	local libaryName = Instance.new("TextLabel")
	libaryName.Name = "Libary_Name"
	libaryName.AnchorPoint = Vector2.new(0, 0.5)
	libaryName.AutomaticSize = Enum.AutomaticSize.XY
	libaryName.BackgroundTransparency = 1
	libaryName.FontFace = FONT
	libaryName.Position = UDim2.new(0, 28, 0.5, 0)
	libaryName.RichText = true
	libaryName.Size = UDim2.fromOffset(1, 1)
	libaryName.Text = 'Stellarz.fun <font color="#' .. string.format("%02x%02x%02x", Colors.TextInactive.R * 255, Colors.TextInactive.G * 255, Colors.TextInactive.B * 255) .. '">' .. gameName .. '</font>'
	libaryName.TextColor3 = Colors.TextActive
	libaryName.TextSize = 14
	libaryName.Parent = libaryIcon
	Window._libaryIcon = libaryIcon

	local dateStr = os.date("%m/%d/%Y")
	local monthNames = {"January","February","March","April","May","June","July","August","September","October","November","December"}
	local monthName = monthNames[tonumber(os.date("%m"))]
	local mutedHex = string.format("#%02x%02x%02x", Colors.TextInactive.R * 255, Colors.TextInactive.G * 255, Colors.TextInactive.B * 255)

	local lastUpdated = Instance.new("TextLabel")
	lastUpdated.Name = "Last_Updated"
	lastUpdated.AnchorPoint = Vector2.new(1, 0.5)
	lastUpdated.AutomaticSize = Enum.AutomaticSize.XY
	lastUpdated.BackgroundTransparency = 1
	lastUpdated.FontFace = FONT_REGULAR
	lastUpdated.Position = UDim2.new(1, -12, 0.5, 0)
	lastUpdated.RichText = true
	lastUpdated.Size = UDim2.fromOffset(1, 1)
	lastUpdated.Text = 'Updated Last <font color="' .. mutedHex .. '">' .. dateStr .. '</font> <font color="#ffffff">' .. monthName .. '</font>'
	lastUpdated.TextColor3 = Colors.TextActive
	lastUpdated.TextSize = 12
	lastUpdated.Parent = header

	local updatedIcon = Instance.new("ImageLabel")
	updatedIcon.Name = "Icon"
	updatedIcon.AnchorPoint = Vector2.new(0, 0.5)
	updatedIcon.BackgroundTransparency = 1
	updatedIcon.Image = "rbxassetid://84304363968016"
	updatedIcon.Position = UDim2.new(0, -22, 0.5, 0)
	updatedIcon.Size = UDim2.fromOffset(15, 15)
	updatedIcon.Parent = lastUpdated

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.AnchorPoint = Vector2.new(0, 1)
	sidebar.BackgroundTransparency = 1
	sidebar.Position = UDim2.fromScale(0, 1)
	sidebar.Size = UDim2.fromOffset(75, 453)
	sidebar.Parent = mainFrame

	local sidebarLiner = Instance.new("Frame")
	sidebarLiner.Name = "Liner"
	sidebarLiner.AnchorPoint = Vector2.new(1, 0.5)
	sidebarLiner.BackgroundColor3 = Colors.Liner
	sidebarLiner.BorderSizePixel = 0
	sidebarLiner.Position = UDim2.fromScale(1, 0.5)
	sidebarLiner.Size = UDim2.new(0, 2, 1, 0)
	sidebarLiner.Parent = sidebar

	local sidebarHolder = Instance.new("Frame")
	sidebarHolder.Name = "Holder"
	sidebarHolder.AnchorPoint = Vector2.new(0.5, 0.5)
	sidebarHolder.BackgroundTransparency = 1
	sidebarHolder.Position = UDim2.fromScale(0.5, 0.5)
	sidebarHolder.Size = UDim2.fromOffset(75, 453)
	sidebarHolder.Parent = sidebar
	applyListLayout(sidebarHolder, Enum.FillDirection.Vertical, 5)
	applyPadding(sidebarHolder, 10, 0, 0, 9)
	Window._sidebarHolder = sidebarHolder

	local subHeader = Instance.new("Frame")
	subHeader.Name = "Sub-Header"
	subHeader.AnchorPoint = Vector2.new(0.5, 0.5)
	subHeader.BackgroundTransparency = 1
	subHeader.Position = UDim2.fromScale(0.554676, 0.127812)
	subHeader.Size = UDim2.fromOffset(621, 51)
	subHeader.ClipsDescendants = true
	subHeader.Parent = mainFrame
	applyListLayout(subHeader, Enum.FillDirection.Horizontal, 8)
	applyPadding(subHeader, 4, 0, 0, 25)
	Window._subHeader = subHeader

	local page = Instance.new("Frame")
	page.Name = "Page"
	page.AnchorPoint = Vector2.new(1, 1)
	page.BackgroundColor3 = Colors.PageBg
	page.ClipsDescendants = true
	page.Position = UDim2.fromScale(1, 1)
	page.Size = UDim2.fromOffset(620, 401)
	page.Parent = mainFrame
	applyCorner(page, 11)
	Window._page = page

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.RightShift then
			mainFrame.Visible = not mainFrame.Visible
		end
	end)

	return Window
end

function Library:CreateTab(config)
	local name = config.Name or "Tab"
	local icon = config.Icon or ""

	local Tab = {}
	Tab._name = name
	Tab._subTabs = {}
	Tab._activeSubTab = nil
	Tab._window = self

	local tabFrame = Instance.new("Frame")
	tabFrame.Name = "Tab"
	tabFrame.BackgroundTransparency = 1
	tabFrame.ClipsDescendants = true
	tabFrame.Size = UDim2.fromOffset(55, 60)
	applyCorner(tabFrame, 5)

	local tabIcon = Instance.new("ImageLabel")
	tabIcon.Name = "Icon"
	tabIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	tabIcon.BackgroundTransparency = 1
	tabIcon.Image = icon
	tabIcon.ImageColor3 = Colors.TextInactive
	tabIcon.Position = UDim2.new(0.5, 0, 0.5, -8)
	tabIcon.Size = UDim2.fromOffset(24, 22)
	tabIcon.Parent = tabFrame

	local tabLabel = Instance.new("TextLabel")
	tabLabel.Name = "TextLabel"
	tabLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	tabLabel.AutomaticSize = Enum.AutomaticSize.XY
	tabLabel.BackgroundTransparency = 1
	tabLabel.FontFace = FONT_BOLD
	tabLabel.Position = UDim2.new(0.5, 0, 0.5, 20)
	tabLabel.Size = UDim2.new(1, 1, 1, 1)
	tabLabel.Text = name
	tabLabel.TextColor3 = Colors.TextInactive
	tabLabel.TextSize = 12
	tabLabel.Parent = tabIcon

	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.AnchorPoint = Vector2.new(0.5, 1)
	indicator.BackgroundColor3 = Colors.AccentStart
	indicator.Position = UDim2.new(0.5, 0, 1, 3)
	indicator.Size = UDim2.fromOffset(25, 6)
	indicator.BackgroundTransparency = 1
	applyCorner(indicator, 12)
	applyAccentGradient(indicator)
	indicator.Parent = tabFrame

	Tab._frame = tabFrame
	Tab._icon = tabIcon
	Tab._label = tabLabel
	Tab._indicator = indicator

	local pageContainer = Instance.new("ScrollingFrame")
	pageContainer.Name = name .. "_Page"
	pageContainer.Active = true
	pageContainer.AnchorPoint = Vector2.new(0.5, 0.5)
	pageContainer.BackgroundTransparency = 1
	pageContainer.Position = UDim2.fromScale(0.5, 0.5)
	pageContainer.ScrollBarImageColor3 = Color3.new(0, 0, 0)
	pageContainer.ScrollBarThickness = 1
	pageContainer.Size = UDim2.fromOffset(620, 401)
	pageContainer.Visible = false
	pageContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
	pageContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	pageContainer.Parent = self._page
	applyListLayout(pageContainer, Enum.FillDirection.Horizontal, 20)
	applyPadding(pageContainer, 12, 0, 0, 12)
	Tab._pageContainer = pageContainer

	local tabButton = Instance.new("TextButton")
	tabButton.Name = "TabButton"
	tabButton.BackgroundTransparency = 1
	tabButton.Size = UDim2.fromScale(1, 1)
	tabButton.Text = ""
	tabButton.Parent = tabFrame

	tabButton.MouseButton1Click:Connect(function()
		self:_selectTab(Tab)
	end)

	tabFrame.Parent = self._sidebarHolder

	local divider = Instance.new("Frame")
	divider.Name = "Divider"
	divider.BackgroundTransparency = 1
	divider.Size = UDim2.fromOffset(55, 5)
	divider.Parent = self._sidebarHolder

	table.insert(self._tabs, Tab)

	if #self._tabs == 1 then
		task.defer(function()
			self:_selectTab(Tab)
		end)
	end

	return Tab
end

function Library:_selectTab(tab)
	if self._activeTab == tab then return end

	for _, t in self._tabs do
		local isActive = (t == tab)

		tween(t._icon, 0.3, {ImageColor3 = isActive and Colors.TextActive or Colors.TextInactive})
		tween(t._label, 0.3, {TextColor3 = isActive and Colors.TextActive or Colors.TextInactive})
		tween(t._frame, 0.3, {BackgroundTransparency = isActive and 0.9 or 1})
		tween(t._indicator, 0.3, {BackgroundTransparency = isActive and 0 or 1})

		if isActive then
			t._pageContainer.Visible = true
			t._pageContainer.GroupTransparency = 1
			tween(t._pageContainer, 0.25, {GroupTransparency = 0})
		else
			t._pageContainer.Visible = false
		end
	end

	self._activeTab = tab
	self:_rebuildSubHeaders(tab)
end

function Library:_rebuildSubHeaders(tab)
	for _, child in self._subHeader:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	if #tab._subTabs == 0 then return end

	for i, subTab in tab._subTabs do
		local subFrame = Instance.new("Frame")
		subFrame.Name = "SubTab"
		subFrame.AutomaticSize = Enum.AutomaticSize.X
		subFrame.BackgroundTransparency = 1
		subFrame.Size = UDim2.fromOffset(80, 49)
		subFrame.LayoutOrder = i

		local tabName = Instance.new("TextLabel")
		tabName.Name = "TabName"
		tabName.AnchorPoint = Vector2.new(0.5, 0.5)
		tabName.AutomaticSize = Enum.AutomaticSize.XY
		tabName.BackgroundTransparency = 1
		tabName.FontFace = FONT_REGULAR
		tabName.Position = UDim2.new(0.5, 0, 0.5, -3)
		tabName.Size = UDim2.fromOffset(1, 1)
		tabName.Text = subTab._name
		tabName.TextColor3 = Colors.TextInactive
		tabName.TextSize = 13
		tabName.TextTransparency = 0.15
		tabName.Parent = subFrame
		applyCorner(tabName, 4)
		applyPadding(tabName, 10, 8, 10, 8)
		subTab._headerLabel = tabName
		subTab._headerFrame = subFrame

		local subIndicator = Instance.new("Frame")
		subIndicator.Name = "Indicator"
		subIndicator.AnchorPoint = Vector2.new(0.5, 1)
		subIndicator.BackgroundColor3 = Colors.AccentStart
		subIndicator.Position = UDim2.new(0.5, 0, 1, 2)
		subIndicator.Size = UDim2.fromOffset(34, 6)
		subIndicator.BackgroundTransparency = 1
		applyCorner(subIndicator, 12)
		applyAccentGradient(subIndicator)
		subIndicator.Parent = subFrame
		subTab._headerIndicator = subIndicator

		local subButton = Instance.new("TextButton")
		subButton.Name = "SubTabButton"
		subButton.BackgroundTransparency = 1
		subButton.Size = UDim2.fromScale(1, 1)
		subButton.Text = ""
		subButton.Parent = subFrame

		subButton.MouseButton1Click:Connect(function()
			tab:_selectSubTab(subTab)
		end)

		subFrame.Parent = self._subHeader
	end

	if tab._activeSubTab and table.find(tab._subTabs, tab._activeSubTab) then
		tab:_selectSubTab(tab._activeSubTab)
	else
		tab:_selectSubTab(tab._subTabs[1])
	end
end

function Library.CreateSubTab(tab, config)
	local name = config.Name or "SubTab"

	local SubTab = {}
	SubTab._name = name
	SubTab._sections = {}
	SubTab._tab = tab

	local contentFrame = Instance.new("Frame")
	contentFrame.Name = name .. "_Content"
	contentFrame.BackgroundTransparency = 1
	contentFrame.Size = UDim2.fromScale(1, 1)
	contentFrame.Visible = false
	contentFrame.Parent = tab._pageContainer

	local leftColumn = Instance.new("Frame")
	leftColumn.Name = "LeftColumn"
	leftColumn.AutomaticSize = Enum.AutomaticSize.Y
	leftColumn.BackgroundTransparency = 1
	leftColumn.Size = UDim2.fromOffset(281, 0)
	leftColumn.Position = UDim2.fromOffset(0, 0)
	leftColumn.Parent = contentFrame
	applyListLayout(leftColumn, Enum.FillDirection.Vertical, 12)
	SubTab._leftColumn = leftColumn

	local rightColumn = Instance.new("Frame")
	rightColumn.Name = "RightColumn"
	rightColumn.AutomaticSize = Enum.AutomaticSize.Y
	rightColumn.BackgroundTransparency = 1
	rightColumn.Size = UDim2.fromOffset(281, 0)
	rightColumn.Position = UDim2.fromOffset(301, 0)
	rightColumn.Parent = contentFrame
	applyListLayout(rightColumn, Enum.FillDirection.Vertical, 12)
	SubTab._rightColumn = rightColumn

	SubTab._contentFrame = contentFrame

	table.insert(tab._subTabs, SubTab)

	if #tab._subTabs == 1 then
		task.defer(function()
			if tab == tab._window._activeTab then
				tab._window:_rebuildSubHeaders(tab)
			end
		end)
	end

	return SubTab
end

function Library._selectSubTab(tab, subTab)
	if tab._activeSubTab == subTab then return end

	for _, st in tab._subTabs do
		local isActive = (st == subTab)

		if st._headerLabel then
			if isActive then
				tween(st._headerLabel, 0.25, {
					TextColor3 = Colors.TextActive,
					BackgroundTransparency = 0.8,
					TextTransparency = 0,
				})
			else
				tween(st._headerLabel, 0.25, {
					TextColor3 = Colors.TextInactive,
					BackgroundTransparency = 1,
					TextTransparency = 0.15,
				})
			end
		end

		if st._headerIndicator then
			tween(st._headerIndicator, 0.25, {BackgroundTransparency = isActive and 0 or 1})
		end

		if isActive then
			st._contentFrame.Visible = true
		else
			st._contentFrame.Visible = false
		end
	end

	tab._activeSubTab = subTab
end

function Library.CreateSection(subTab, config)
	local name = config.Name or "Section"
	local side = config.Side or "Left"
	local sectionIcon = config.Icon or ""
	local hasToggle = config.Toggle or false

	local Section = {}
	Section._name = name
	Section._toggled = false

	local parent = (side == "Right") and subTab._rightColumn or subTab._leftColumn

	local sectionFrame = Instance.new("Frame")
	sectionFrame.Name = "Section_" .. side
	sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
	sectionFrame.BackgroundColor3 = Colors.SectionBg
	sectionFrame.ClipsDescendants = true
	sectionFrame.Size = UDim2.fromOffset(281, 60)
	applyCorner(sectionFrame, 6)
	sectionFrame.Parent = parent
	Section._frame = sectionFrame

	local headerFrame = Instance.new("Frame")
	headerFrame.Name = "Header"
	headerFrame.AnchorPoint = Vector2.new(0.5, 0)
	headerFrame.BackgroundColor3 = Colors.SectionHeader
	headerFrame.Position = UDim2.fromScale(0.5, 0)
	headerFrame.Size = UDim2.fromOffset(281, 30)
	headerFrame.Parent = sectionFrame
	applyCorner(headerFrame, 6)

	local headerLiner = Instance.new("Frame")
	headerLiner.Name = "Liner"
	headerLiner.AnchorPoint = Vector2.new(0.5, 1)
	headerLiner.BackgroundColor3 = Color3.fromRGB(26, 26, 37)
	headerLiner.BorderSizePixel = 0
	headerLiner.Position = UDim2.fromScale(0.5, 1)
	headerLiner.Size = UDim2.new(1, 0, 0, 1)
	headerLiner.Parent = headerFrame

	local headerHolder = Instance.new("Frame")
	headerHolder.Name = "Header_Holder"
	headerHolder.AnchorPoint = Vector2.new(0.5, 0.5)
	headerHolder.BackgroundTransparency = 1
	headerHolder.ClipsDescendants = true
	headerHolder.Position = UDim2.fromScale(0.5, 0.5)
	headerHolder.Size = UDim2.fromOffset(281, 30)
	headerHolder.Parent = headerFrame

	local accentLine = Instance.new("Frame")
	accentLine.Name = "Line"
	accentLine.AnchorPoint = Vector2.new(0, 0.5)
	accentLine.BackgroundColor3 = Colors.AccentStart
	accentLine.Position = UDim2.new(0, -3, 0.5, 0)
	accentLine.Size = UDim2.fromOffset(6, 20)
	applyCorner(accentLine, 30)
	applyAccentGradient(accentLine)
	accentLine.Parent = headerHolder

	if sectionIcon ~= "" then
		local iconLabel = Instance.new("ImageLabel")
		iconLabel.Name = "ImageLabel"
		iconLabel.AnchorPoint = Vector2.new(0, 0.5)
		iconLabel.BackgroundTransparency = 1
		iconLabel.Image = sectionIcon
		iconLabel.Position = UDim2.new(0, 12, 0.5, 0)
		iconLabel.Size = UDim2.fromOffset(15, 15)
		iconLabel.Parent = headerHolder
	end

	local sectionName = Instance.new("TextLabel")
	sectionName.Name = "Section_Name"
	sectionName.AnchorPoint = Vector2.new(0, 0.5)
	sectionName.AutomaticSize = Enum.AutomaticSize.XY
	sectionName.BackgroundTransparency = 1
	sectionName.FontFace = FONT_REGULAR
	sectionName.Position = UDim2.new(0, sectionIcon ~= "" and 35 or 12, 0.5, 0)
	sectionName.Size = UDim2.fromOffset(1, 1)
	sectionName.Text = name
	sectionName.TextColor3 = Colors.TextActive
	sectionName.TextSize = 12
	sectionName.Parent = headerHolder

	if hasToggle then
		local toggleFrame = Instance.new("Frame")
		toggleFrame.Name = "Toggle"
		toggleFrame.AnchorPoint = Vector2.new(1, 0.5)
		toggleFrame.BackgroundColor3 = Colors.ElementBg
		toggleFrame.Position = UDim2.new(1, -12, 0.5, 0)
		toggleFrame.Size = UDim2.fromOffset(16, 16)
		applyCorner(toggleFrame, 3)
		toggleFrame.Parent = headerHolder

		local toggleStroke = Instance.new("UIStroke")
		toggleStroke.Color = Colors.Stroke
		toggleStroke.Parent = toggleFrame

		local checkIcon = Instance.new("ImageLabel")
		checkIcon.Name = "Check_Icon"
		checkIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		checkIcon.BackgroundTransparency = 1
		checkIcon.Image = "rbxassetid://83899464799881"
		checkIcon.Position = UDim2.fromScale(0.5, 0.5)
		checkIcon.Size = UDim2.fromOffset(8, 7)
		checkIcon.ImageTransparency = 1
		checkIcon.Parent = toggleFrame

		local toggleButton = Instance.new("TextButton")
		toggleButton.BackgroundTransparency = 1
		toggleButton.Size = UDim2.fromScale(1, 1)
		toggleButton.Text = ""
		toggleButton.Parent = toggleFrame

		toggleButton.MouseButton1Click:Connect(function()
			Section._toggled = not Section._toggled
			if Section._toggled then
				tween(toggleFrame, 0.2, {BackgroundColor3 = Colors.AccentStart})
				tween(checkIcon, 0.2, {ImageTransparency = 0})
				applyAccentGradient(toggleFrame)
				toggleStroke.Color = Colors.AccentStart
			else
				tween(toggleFrame, 0.2, {BackgroundColor3 = Colors.ElementBg})
				tween(checkIcon, 0.2, {ImageTransparency = 1})
				for _, g in toggleFrame:GetChildren() do
					if g:IsA("UIGradient") then g:Destroy() end
				end
				toggleStroke.Color = Colors.Stroke
			end
		end)

		Section._toggle = toggleFrame
		Section._checkIcon = checkIcon
	end

	local holder = Instance.new("Frame")
	holder.Name = "Holder"
	holder.AnchorPoint = Vector2.new(0.5, 0)
	holder.AutomaticSize = Enum.AutomaticSize.XY
	holder.BackgroundTransparency = 1
	holder.Position = UDim2.fromScale(0.5, 1)
	holder.Size = UDim2.fromOffset(1, 1)
	holder.Parent = headerFrame
	applyListLayout(holder, Enum.FillDirection.Vertical, 4)
	applyPadding(holder, 5, 0, 45, 0)
	Section._holder = holder

	table.insert(subTab._sections, Section)

	return Section
end

return Library
