--!strict

local Packages = game.ReplicatedStorage.Packages
local DevPackages = game.ReplicatedStorage.DevPackages

local function mergePackages(into: Folder, from: Folder)
	local intoIndex = into:FindFirstChild("_Index") :: Folder
	local fromIndex = from:FindFirstChild("_Index") :: Folder

	for _, child in from:GetChildren() do
		if child:IsA("ModuleScript") then
			child.Parent = into
		end
	end

	for _, folder in fromIndex:GetChildren() do
		folder.Parent = intoIndex
	end

	from:Destroy()
end

mergePackages(Packages, DevPackages)

local WallyPackageExport = require(Packages:WaitForChild("WallyPackageExport")) :: any

local knit = WallyPackageExport.get("Knit")
knit.Parent = workspace

local knitRequired = require(knit) :: any
print(knitRequired)
