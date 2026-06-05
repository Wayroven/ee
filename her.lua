local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local Library = {}

local FONT = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
local FONT_BOLD = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
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
	AccentStart = Color3.fromHex("#FF4500"), -- Deeper orange/red
	AccentEnd = Color3.fromHex("#FF8C00"),   -- Lighter orange to show gradient clearly
}

local function getGameName()
	local ok, info = pcall(function()
		return MarketplaceService:GetProductInfo(game.PlaceId)
	end)
	if ok and info then return info.Name end
	return "Unknown"
end

local function tween(obj, duration, props, style, direction)
	local t = TweenService:Create(obj, TweenInfo.new(duration, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end

local function accentGradient(parent)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Colors.AccentStart),
		ColorSequenceKeypoint.new(1, Colors.AccentEnd),
	})
	g.Parent = parent
end

local function makeDraggable(frame, handle)
	local dragging, dragInput, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
	local Window = {}
	Window._tabs = {}
	Window._activeTab = nil

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ScreenGui"
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ResetOnSpawn = false

	local ok, hui = pcall(gethui)
	if ok and hui then
		screenGui.Parent = hui
	else
		pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
		if not screenGui.Parent then
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
	corner(mainFrame, 11)
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
	headerLiner.BackgroundColor3 = Colors.Liner
	headerLiner.BorderSizePixel = 0
	headerLiner.AnchorPoint = Vector2.new(0, 1)
	headerLiner.Position = UDim2.fromScale(0, 1)
	headerLiner.Size = UDim2.new(1, 0, 0, 2)
	headerLiner.Parent = header

	local libIcon = Instance.new("ImageLabel")
	libIcon.Name = "LibaryIcon"
	libIcon.AnchorPoint = Vector2.new(0, 0.5)
	libIcon.BackgroundTransparency = 1
	libIcon.Image = "rbxassetid://0"
	libIcon.Position = UDim2.new(0, 14, 0.5, 0)
	libIcon.ScaleType = Enum.ScaleType.Fit
	libIcon.Size = UDim2.fromOffset(20, 20)
	libIcon.Parent = header

	local gameName = getGameName()
	local mutedHex = string.format("#%02x%02x%02x", math.floor(Colors.TextInactive.R * 255), math.floor(Colors.TextInactive.G * 255), math.floor(Colors.TextInactive.B * 255))

	local libName = Instance.new("TextLabel")
	libName.Name = "Libary_Name"
	libName.AnchorPoint = Vector2.new(0, 0.5)
	libName.BackgroundTransparency = 1
	libName.FontFace = FONT
	libName.Position = UDim2.new(0, 28, 0.5, 0)
	libName.RichText = true
	libName.Size = UDim2.new(0, 250, 1, 0)
	libName.Text = 'Stellarz.fun <font color="' .. mutedHex .. '">' .. gameName .. '</font>'
	libName.TextColor3 = Colors.TextActive
	libName.TextSize = 14
	libName.TextTruncate = Enum.TextTruncate.AtEnd
	libName.TextXAlignment = Enum.TextXAlignment.Left
	libName.Parent = libIcon

	local dateStr = os.date("%m/%d/%Y")
	local monthNames = {"January","February","March","April","May","June","July","August","September","October","November","December"}
	local monthName = monthNames[tonumber(os.date("%m"))]

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
	sidebarLiner.BackgroundColor3 = Colors.Liner
	sidebarLiner.BorderSizePixel = 0
	sidebarLiner.AnchorPoint = Vector2.new(1, 0.5)
	sidebarLiner.Position = UDim2.fromScale(1, 0.5)
	sidebarLiner.Size = UDim2.new(0, 2, 1, 0)
	sidebarLiner.Parent = sidebar

	local sidebarHolder = Instance.new("ScrollingFrame")
	sidebarHolder.Name = "Holder"
	sidebarHolder.AnchorPoint = Vector2.new(0.5, 0)
	sidebarHolder.BackgroundTransparency = 1
	sidebarHolder.Position = UDim2.new(0.5, 0, 0, 0)
	sidebarHolder.Size = UDim2.new(1, 0, 1, 0)
	sidebarHolder.ScrollBarThickness = 0
	sidebarHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sidebarHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
	sidebarHolder.Parent = sidebar

	local sidebarLayout = Instance.new("UIListLayout")
	sidebarLayout.Padding = UDim.new(0, 4)
	sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	sidebarLayout.Parent = sidebarHolder

	local sidebarPad = Instance.new("UIPadding")
	sidebarPad.PaddingTop = UDim.new(0, 8)
	sidebarPad.PaddingBottom = UDim.new(0, 8)
	sidebarPad.Parent = sidebarHolder

	Window._sidebarHolder = sidebarHolder

	local subHeader = Instance.new("Frame")
	subHeader.Name = "Sub-Header"
	subHeader.BackgroundTransparency = 1
	subHeader.Position = UDim2.fromOffset(75, 37)
	subHeader.Size = UDim2.fromOffset(620, 51)
	subHeader.ClipsDescendants = true
	subHeader.Parent = mainFrame

	local subLayout = Instance.new("UIListLayout")
	subLayout.FillDirection = Enum.FillDirection.Horizontal
	subLayout.Padding = UDim.new(0, 12)
	subLayout.SortOrder = Enum.SortOrder.LayoutOrder
	subLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	subLayout.Parent = subHeader

	local subPad = Instance.new("UIPadding")
	subPad.PaddingLeft = UDim.new(0, 18)
	subPad.Parent = subHeader

	Window._subHeader = subHeader

	local page = Instance.new("Frame")
	page.Name = "Page"
	page.AnchorPoint = Vector2.new(1, 1)
	page.BackgroundColor3 = Colors.PageBg
	page.ClipsDescendants = true
	page.Position = UDim2.fromScale(1, 1)
	page.Size = UDim2.fromOffset(620, 401)
	page.Parent = mainFrame
	corner(page, 11)
	Window._page = page

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.RightShift then
			mainFrame.Visible = not mainFrame.Visible
		end
	end)

	function Window:CreateTab(config)
		local tabName = config.Name or "Tab"
		local tabIconId = config.Icon or ""

		local Tab = {}
		Tab._name = tabName
		Tab._subTabs = {}
		Tab._activeSubTab = nil
		Tab._window = Window

		local tabFrame = Instance.new("Frame")
		tabFrame.Name = "Tab_" .. tabName
		tabFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		tabFrame.BackgroundTransparency = 1
		tabFrame.ClipsDescendants = false
		tabFrame.Size = UDim2.fromOffset(63, 62)
		corner(tabFrame, 5)

		local tabIcon = Instance.new("ImageLabel")
		tabIcon.Name = "Icon"
		tabIcon.AnchorPoint = Vector2.new(0.5, 0)
		tabIcon.BackgroundTransparency = 1
		tabIcon.Image = tabIconId
		tabIcon.ImageColor3 = Colors.TextInactive
		tabIcon.Position = UDim2.new(0.5, 0, 0, 10)
		tabIcon.Size = UDim2.fromOffset(20, 18)
		tabIcon.Parent = tabFrame

		local tabLabel = Instance.new("TextLabel")
		tabLabel.Name = "Label"
		tabLabel.AnchorPoint = Vector2.new(0.5, 0)
		tabLabel.AutomaticSize = Enum.AutomaticSize.X
		tabLabel.BackgroundTransparency = 1
		tabLabel.FontFace = FONT_BOLD
		tabLabel.Position = UDim2.new(0.5, 0, 0, 32)
		tabLabel.Size = UDim2.fromOffset(0, 14)
		tabLabel.Text = tabName
		tabLabel.TextColor3 = Colors.TextInactive
		tabLabel.TextSize = 10
		tabLabel.TextScaled = false
		tabLabel.Parent = tabFrame

		local indicatorBg = Instance.new("Frame")
		indicatorBg.Name = "IndicatorBg"
		indicatorBg.AnchorPoint = Vector2.new(0.5, 1)
		indicatorBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
		indicatorBg.BackgroundTransparency = 1
		indicatorBg.Position = UDim2.new(0.5, 0, 1, -2)
		indicatorBg.Size = UDim2.fromOffset(30, 4)
		corner(indicatorBg, 2)
		indicatorBg.Parent = tabFrame

		local indicatorFill = Instance.new("Frame")
		indicatorFill.Name = "Fill"
		indicatorFill.AnchorPoint = Vector2.new(0, 0.5)
		indicatorFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		indicatorFill.Position = UDim2.new(0, 0, 0.5, 0)
		indicatorFill.Size = UDim2.new(0, 0, 1, 0)
		corner(indicatorFill, 2)
		accentGradient(indicatorFill)
		indicatorFill.Parent = indicatorBg

		Tab._frame = tabFrame
		Tab._icon = tabIcon
		Tab._label = tabLabel
		Tab._indicatorBg = indicatorBg
		Tab._indicatorFill = indicatorFill

		local pageContainer = Instance.new("Frame")
		pageContainer.Name = tabName .. "_Page"
		pageContainer.BackgroundTransparency = 1
		pageContainer.Size = UDim2.fromScale(1, 1)
		pageContainer.Visible = false
		pageContainer.Parent = Window._page
		Tab._pageContainer = pageContainer

		local tabButton = Instance.new("TextButton")
		tabButton.BackgroundTransparency = 1
		tabButton.Size = UDim2.fromScale(1, 1)
		tabButton.Text = ""
		tabButton.ZIndex = 5
		tabButton.Parent = tabFrame

		tabButton.MouseButton1Click:Connect(function()
			Window:_selectTab(Tab)
		end)

		tabFrame.Parent = Window._sidebarHolder
		table.insert(Window._tabs, Tab)

		function Tab:CreateSubTab(subConfig)
			local subName = subConfig.Name or "SubTab"

			local SubTab = {}
			SubTab._name = subName
			SubTab._sections = {}
			SubTab._tab = Tab

			local contentFrame = Instance.new("Frame")
			contentFrame.Name = subName .. "_Content"
			contentFrame.BackgroundTransparency = 1
			contentFrame.Size = UDim2.fromScale(1, 1)
			contentFrame.Visible = false
			contentFrame.Parent = Tab._pageContainer

			local leftScroll = Instance.new("ScrollingFrame")
			leftScroll.Name = "LeftColumn"
			leftScroll.BackgroundTransparency = 1
			leftScroll.Position = UDim2.fromOffset(12, 12)
			leftScroll.Size = UDim2.fromOffset(281, 377)
			leftScroll.ScrollBarThickness = 1
			leftScroll.ScrollBarImageColor3 = Colors.Stroke
			leftScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
			leftScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
			leftScroll.Parent = contentFrame

			local leftLayout = Instance.new("UIListLayout")
			leftLayout.Padding = UDim.new(0, 10)
			leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
			leftLayout.Parent = leftScroll

			SubTab._leftColumn = leftScroll

			local rightScroll = Instance.new("ScrollingFrame")
			rightScroll.Name = "RightColumn"
			rightScroll.BackgroundTransparency = 1
			rightScroll.Position = UDim2.fromOffset(313, 12)
			rightScroll.Size = UDim2.fromOffset(281, 377)
			rightScroll.ScrollBarThickness = 1
			rightScroll.ScrollBarImageColor3 = Colors.Stroke
			rightScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
			rightScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
			rightScroll.Parent = contentFrame

			local rightLayout = Instance.new("UIListLayout")
			rightLayout.Padding = UDim.new(0, 10)
			rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
			rightLayout.Parent = rightScroll

			SubTab._rightColumn = rightScroll
			SubTab._contentFrame = contentFrame

			table.insert(Tab._subTabs, SubTab)

			function SubTab:CreateSection(secConfig)
				local secName = secConfig.Name or "Section"
				local side = secConfig.Side or "Left"
				local secIcon = secConfig.Icon or ""
				local hasToggle = secConfig.Toggle or false

				local Section = {}
				Section._name = secName
				Section._toggled = false

				local parent = (side == "Right") and SubTab._rightColumn or SubTab._leftColumn

				local sectionFrame = Instance.new("Frame")
				sectionFrame.Name = "Section"
				sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
				sectionFrame.BackgroundColor3 = Colors.SectionBg
				sectionFrame.ClipsDescendants = true
				sectionFrame.Size = UDim2.new(1, 0, 0, 60)
				corner(sectionFrame, 6)
				sectionFrame.Parent = parent
				Section._frame = sectionFrame

				local headerF = Instance.new("Frame")
				headerF.Name = "Header"
				headerF.AnchorPoint = Vector2.new(0.5, 0)
				headerF.BackgroundColor3 = Colors.SectionHeader
				headerF.Position = UDim2.fromScale(0.5, 0)
				headerF.Size = UDim2.new(1, 0, 0, 30)
				headerF.Parent = sectionFrame
				corner(headerF, 6)

				local hLiner = Instance.new("Frame")
				hLiner.BackgroundColor3 = Color3.fromRGB(26, 26, 37)
				hLiner.BorderSizePixel = 0
				hLiner.AnchorPoint = Vector2.new(0.5, 1)
				hLiner.Position = UDim2.fromScale(0.5, 1)
				hLiner.Size = UDim2.new(1, 0, 0, 1)
				hLiner.Parent = headerF

				local accentLine = Instance.new("Frame")
				accentLine.AnchorPoint = Vector2.new(0, 0.5)
				accentLine.BackgroundColor3 = Colors.AccentStart
				accentLine.Position = UDim2.new(0, -3, 0.5, 0)
				accentLine.Size = UDim2.fromOffset(6, 20)
				corner(accentLine, 30)
				accentGradient(accentLine)
				accentLine.Parent = headerF

				if secIcon ~= "" then
					local ic = Instance.new("ImageLabel")
					ic.AnchorPoint = Vector2.new(0, 0.5)
					ic.BackgroundTransparency = 1
					ic.Image = secIcon
					ic.Position = UDim2.new(0, 12, 0.5, 0)
					ic.Size = UDim2.fromOffset(15, 15)
					ic.Parent = headerF
				end

				local sLabel = Instance.new("TextLabel")
				sLabel.AnchorPoint = Vector2.new(0, 0.5)
				sLabel.AutomaticSize = Enum.AutomaticSize.XY
				sLabel.BackgroundTransparency = 1
				sLabel.FontFace = FONT_REGULAR
				sLabel.Position = UDim2.new(0, secIcon ~= "" and 35 or 12, 0.5, 0)
				sLabel.Size = UDim2.fromOffset(1, 1)
				sLabel.Text = secName
				sLabel.TextColor3 = Colors.TextActive
				sLabel.TextSize = 12
				sLabel.Parent = headerF

				if hasToggle then
					local tgl = Instance.new("Frame")
					tgl.AnchorPoint = Vector2.new(1, 0.5)
					tgl.BackgroundColor3 = Colors.ElementBg
					tgl.Position = UDim2.new(1, -12, 0.5, 0)
					tgl.Size = UDim2.fromOffset(16, 16)
					corner(tgl, 3)
					tgl.Parent = headerF

					local tglStroke = Instance.new("UIStroke")
					tglStroke.Color = Colors.Stroke
					tglStroke.Parent = tgl

					local chk = Instance.new("ImageLabel")
					chk.AnchorPoint = Vector2.new(0.5, 0.5)
					chk.BackgroundTransparency = 1
					chk.Image = "rbxassetid://83899464799881"
					chk.Position = UDim2.fromScale(0.5, 0.5)
					chk.Size = UDim2.fromOffset(8, 7)
					chk.ImageTransparency = 1
					chk.Parent = tgl

					local tglBtn = Instance.new("TextButton")
					tglBtn.BackgroundTransparency = 1
					tglBtn.Size = UDim2.fromScale(1, 1)
					tglBtn.Text = ""
					tglBtn.ZIndex = 5
					tglBtn.Parent = tgl

					tglBtn.MouseButton1Click:Connect(function()
						Section._toggled = not Section._toggled
						if Section._toggled then
							tween(tgl, 0.2, {BackgroundColor3 = Colors.AccentStart})
							tween(chk, 0.2, {ImageTransparency = 0})
							tglStroke.Color = Colors.AccentEnd
						else
							tween(tgl, 0.2, {BackgroundColor3 = Colors.ElementBg})
							tween(chk, 0.2, {ImageTransparency = 1})
							tglStroke.Color = Colors.Stroke
						end
					end)

					Section._toggle = tgl
				end

				local holder = Instance.new("Frame")
				holder.Name = "Holder"
				holder.AnchorPoint = Vector2.new(0.5, 0)
				holder.AutomaticSize = Enum.AutomaticSize.Y
				holder.BackgroundTransparency = 1
				holder.Position = UDim2.new(0.5, 0, 0, 30)
				holder.Size = UDim2.new(1, 0, 0, 0)
				holder.Parent = sectionFrame

				local hLayout = Instance.new("UIListLayout")
				hLayout.Padding = UDim.new(0, 4)
				hLayout.SortOrder = Enum.SortOrder.LayoutOrder
				hLayout.Parent = holder

				local hPad = Instance.new("UIPadding")
				hPad.PaddingTop = UDim.new(0, 5)
				hPad.PaddingBottom = UDim.new(0, 12)
				hPad.Parent = holder

				Section._holder = holder
				table.insert(SubTab._sections, Section)
				return Section
			end

			if #Tab._subTabs == 1 and Tab == Window._activeTab then
				task.defer(function()
					Window:_rebuildSubHeaders(Tab)
				end)
			end

			return SubTab
		end

		if #Window._tabs == 1 then
			task.defer(function()
				Window:_selectTab(Tab)
			end)
		end

		return Tab
	end

	function Window:_selectTab(tab)
		if Window._activeTab == tab then return end

		for _, t in Window._tabs do
			local active = (t == tab)

			tween(t._icon, 0.3, {ImageColor3 = active and Colors.TextActive or Colors.TextInactive})
			tween(t._label, 0.3, {TextColor3 = active and Colors.TextActive or Colors.TextInactive})
			tween(t._frame, 0.3, {BackgroundTransparency = active and 0.92 or 1})

			if active then
				tween(t._indicatorFill, 0.35, {Size = UDim2.new(1, 0, 1, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				t._indicatorBg.BackgroundTransparency = 0
			else
				tween(t._indicatorFill, 0.25, {Size = UDim2.new(0, 0, 1, 0)})
				t._indicatorBg.BackgroundTransparency = 1
			end

			t._pageContainer.Visible = active
		end

		Window._activeTab = tab
		Window:_rebuildSubHeaders(tab)
	end

	function Window:_rebuildSubHeaders(tab)
		for _, child in Window._subHeader:GetChildren() do
			if child:IsA("Frame") then child:Destroy() end
		end

		if #tab._subTabs == 0 then return end

		for i, subTab in tab._subTabs do
			local subFrame = Instance.new("Frame")
			subFrame.Name = "SubTab_" .. subTab._name
			subFrame.AutomaticSize = Enum.AutomaticSize.X
			subFrame.BackgroundTransparency = 1
			subFrame.Size = UDim2.fromOffset(0, 46)
			subFrame.LayoutOrder = i

			local label = Instance.new("TextLabel")
			label.AnchorPoint = Vector2.new(0.5, 0.5)
			label.AutomaticSize = Enum.AutomaticSize.XY
			label.BackgroundTransparency = 1
			label.FontFace = FONT_REGULAR
			label.Position = UDim2.new(0.5, 0, 0.5, -3)
			label.Size = UDim2.fromOffset(1, 1)
			label.Text = subTab._name
			label.TextColor3 = Colors.TextInactive
			label.TextSize = 13
			label.TextTransparency = 0.15
			label.Parent = subFrame
			corner(label, 4)

			local lPad = Instance.new("UIPadding")
			lPad.PaddingTop = UDim.new(0, 8)
			lPad.PaddingBottom = UDim.new(0, 8)
			lPad.PaddingLeft = UDim.new(0, 10)
			lPad.PaddingRight = UDim.new(0, 10)
			lPad.Parent = label

			subTab._headerLabel = label
			subTab._headerFrame = subFrame

			local subIndBg = Instance.new("Frame")
			subIndBg.AnchorPoint = Vector2.new(0.5, 1)
			subIndBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
			subIndBg.BackgroundTransparency = 1
			subIndBg.Position = UDim2.new(0.5, 0, 1, 0)
			subIndBg.Size = UDim2.fromOffset(30, 4)
			corner(subIndBg, 2)
			subIndBg.Parent = subFrame

			local subIndFill = Instance.new("Frame")
			subIndFill.AnchorPoint = Vector2.new(0, 0.5)
			subIndFill.BackgroundColor3 = Colors.AccentStart
			subIndFill.Position = UDim2.new(0, 0, 0.5, 0)
			subIndFill.Size = UDim2.new(0, 0, 1, 0)
			corner(subIndFill, 2)
			accentGradient(subIndFill)
			subIndFill.Parent = subIndBg

			subTab._headerIndBg = subIndBg
			subTab._headerIndFill = subIndFill

			local subBtn = Instance.new("TextButton")
			subBtn.BackgroundTransparency = 1
			subBtn.Size = UDim2.fromScale(1, 1)
			subBtn.Text = ""
			subBtn.ZIndex = 5
			subBtn.Parent = subFrame

			subBtn.MouseButton1Click:Connect(function()
				Window:_selectSubTab(tab, subTab)
			end)

			subFrame.Parent = Window._subHeader
		end

		local target = tab._activeSubTab
		if not target or not table.find(tab._subTabs, target) then
			target = tab._subTabs[1]
		end
		Window:_selectSubTab(tab, target)
	end

	function Window:_selectSubTab(tab, subTab)
		if tab._activeSubTab == subTab then return end

		for _, st in tab._subTabs do
			local active = (st == subTab)

			if st._headerLabel then
				if active then
					tween(st._headerLabel, 0.25, {TextColor3 = Colors.TextActive, BackgroundTransparency = 0.8, TextTransparency = 0})
				else
					tween(st._headerLabel, 0.25, {TextColor3 = Colors.TextInactive, BackgroundTransparency = 1, TextTransparency = 0.15})
				end
			end

			if st._headerIndFill then
				if active then
					st._headerIndBg.BackgroundTransparency = 0
					tween(st._headerIndFill, 0.3, {Size = UDim2.new(1, 0, 1, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				else
					tween(st._headerIndFill, 0.2, {Size = UDim2.new(0, 0, 1, 0)})
					task.delay(0.2, function()
						if tab._activeSubTab ~= st then
							st._headerIndBg.BackgroundTransparency = 1
						end
					end)
				end
			end

			st._contentFrame.Visible = active
		end

		tab._activeSubTab = subTab
	end

	return Window
end

return Library
