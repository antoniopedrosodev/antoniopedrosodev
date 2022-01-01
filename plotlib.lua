--by unauth

local HttpService = game:GetService('HttpService')
local Numbers = {'0'}
for i=1, 9 do
	table.insert(Numbers, tostring(i))
end
local AllowedCharactersOnCFrame = {
	'-';
	',';
	'.';
	' ';
	unpack(Numbers);
	'e'
}
local function GetPlotType(Plot)
	return Plot.Name:sub(1, -2) -- AKA Remove last character
end
local function GetCurrentOwnedPlot()
   for _,Building in pairs(workspace.PlayerPlots:GetChildren()) do
	   for _,Plot in pairs(Building:GetChildren()) do
		 if Plot:FindFirstChildOfClass("Folder") then
			if Plot.Properties.Owner.Value == game.Players.LocalPlayer.Name then
				return Plot
			end
		 end
	   end
	end
	return nil
end

local function GetPlotFromUsername(Username)
	assert(type(Username) == 'string', 'smh username please')
	for _,Building in pairs(workspace.PlayerPlots:GetChildren()) do
		for _,Plot in pairs(Building:GetChildren()) do
		 if Plot:FindFirstChildOfClass("Folder") then
			if Plot.Properties.Owner.Value:lower() == Username:lower() then
				return Plot
			end
		 end
		end
	end
	return nil
end
local function FindPlotByID(Identifier)
	for _,Building in pairs(workspace.PlayerPlots:GetChildren()) do
		for _,Plot in pairs(Building:GetChildren()) do
			if Plot:FindFirstChildOfClass("Folder") then
				print(Plot:WaitForChild('OwnerBox'):WaitForChild('BBGui').CFrame.Position, StringToCFrame(Identifier).Position)
				if rawequal(tostring(Plot:WaitForChild('OwnerBox'):WaitForChild('BBGui').CFrame), Identifier) then
					return Plot
				end
			end
		end
	end
	return nil
end
local function IsCFrameSafe(String)
	assert(type(String) == 'string', 'only string or insane homosexual')
	local arr = String:split('')
	for _, Character in next, arr do
		if table.find(AllowedCharactersOnCFrame, Character) == nil then
			return false
		end
	end
	return true
end
local function StringToCFrame(StringifiedCF)
	assert(type(StringifiedCF) == 'string', 'only string or gay')
	if IsCFrameSafe(StringifiedCF) == false then return CFrame.new(0,0,0) end -- DO NOT REMOVE, or you're vulnerable to code execution.
	return loadstring(string.format('return CFrame.new(%s)', StringifiedCF))()
end
local GenuineFurnitureNames = {}
for _, Template in next, game:GetService("ReplicatedStorage"):WaitForChild('Furniture'):GetChildren() do
	table.insert(GenuineFurnitureNames, Template.Name)
end
local function PlaceItem(Name, CFrame, Color)
	print(Name, CFrame,Color, typeof(CFrame), typeof(Color))
	Color = Color or Color3.new(0,0,0)
	assert(type(Name) == 'string','1 arg must be string')
	assert(typeof(CFrame) == 'CFrame', '2 arg must be a CFrame')
	assert(typeof(Color) == 'Color3', '3 arg must be a Color3')
	game:GetService("ReplicatedStorage")["_CS.Events"].PlaceItem:FireServer(CFrame, Name, Color)
end
local function ConvertColor(ColorName)
		return BrickColor.new(ColorName).Color
end
local function ConvertPlotFurniture(Plot)
	assert(typeof(Plot) == 'Instance', 'send a plot next time bbg')
	if Plot:IsDescendantOf(workspace.PlayerPlots) == false then error('dis no real worky plot 2021 real') end
	local Data = {}
	for _, Furniture in next, Plot:WaitForChild('Furniture'):GetChildren() do
		if table.find(GenuineFurnitureNames, tostring(Furniture)) == nil then continue end
		local Color = (function() if Furniture:FindFirstChild('Paintable') then return Furniture:WaitForChild('Paintable').BrickColor.Name end end)()
		if Furniture:FindFirstChild('Paintable') == nil then Color = Furniture.PrimaryPart.BrickColor.Name end
		table.insert(Data, {Name = Furniture.Name;Color = Color;CFrame = tostring(Furniture.PrimaryPart.CFrame)})
	end
	return Data
end

local function BuildPlotFromData(Data)
	for _, FurnitureData in next, Data do
		wait(2)
		PlaceItem(FurnitureData.Name, StringToCFrame(FurnitureData.CFrame), ConvertColor(FurnitureData.Color))
	end
	wait(2)
end
local function ClaimPlot(Plot)
	game:GetService("ReplicatedStorage")["_CS.Events"].ClaimPlot:FireServer(Plot)
end

local function ExportPlot(Plot)
	local BuildData = ConvertPlotFurniture(Plot)
	local PlotData = {
		PlotType = GetPlotType(Plot);
		BuildData = BuildData;
		FurnitureAmmount = #BuildData;
		OldOwner = (function() return Plot:WaitForChild('Properties'):WaitForChild('Owner').Value end)();
		OriginPlotID = tostring(Plot:WaitForChild('OwnerBox'):WaitForChild('BBGui').CFrame)
	}
	return PlotData
end
local function ImportPlot(PlotData)
	assert(type(PlotData) == 'table', 'not a table, try harder.')
	local Plot = FindPlotByID(PlotData.OriginPlotID)
	if Plot == nil or Plot:WaitForChild('Properties'):WaitForChild('Owner').Value ~= 'NA' then
		return true -- Means failed, we couldn't find an avaiable plot for construction.
	end
	ClaimPlot(Plot)
	wait(5)
	BuildPlotFromData(PlotData.BuildData)
	game:GetService('Players').LocalPlayer.Character.HumanoidRootPart.CFrame = (StringToCFrame(PlotData.OriginPlotID) + Vector3.new(0,5,0))
end

return ImportPlot, ExportPlot, GetPlotFromUsername, GetPlotType
