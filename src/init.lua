--!strict

local ForwarderModule = script:WaitForChild("Forwarder")
local WallyPackageAccess = require(script.Parent:WaitForChild("WallyPackageAccess")) :: any

local module = {}

-- Private

local function followPath(parent: Instance, path: {string}): Instance
	local found = parent :: Instance
	for i = 1, #path do
		found = found:FindFirstChild(path[i]) :: Instance
	end
	return found
end

local function getPath(parent: Instance, descendant: Instance): {string}
	assert(descendant:IsDescendantOf(parent), `Cannot find path because {descendant.Name} is not a descendant of {parent.Name}`)
	
	local path = {}
	while descendant ~= parent do
		table.insert(path, 1, descendant.Name)
		descendant = descendant.Parent :: Instance
	end
	
	return path
end

-- Public

function module.get(name: string): ModuleScript
	local entry = WallyPackageAccess.contents[name]
	assert(entry, `No package found with name {name}`)

	local packagesCopy = WallyPackageAccess.packages:Clone()
	local packagesCopyIndex = packagesCopy:FindFirstChild("_Index") :: Folder

	local paths = {getPath(WallyPackageAccess.packages, entry.content)}
	for i, dependency in entry.dependencies do
		table.insert(paths, getPath(WallyPackageAccess.packages, dependency.content))
	end

	local includedContentParentsSet = {}
	for _, path in paths do
		local content = followPath(packagesCopy, path)
		includedContentParentsSet[content.Parent] = true
	end
	
	for _, contentParent in packagesCopyIndex:GetChildren() do
		if not includedContentParentsSet[contentParent] then
			contentParent:Destroy()
		end
	end

	for _, moduleInstance in packagesCopy:GetChildren() do
		if moduleInstance:IsA("ModuleScript") and moduleInstance.Name ~= name then
			moduleInstance:Destroy()
		end
	end

	local forwarder = ForwarderModule:Clone()
	forwarder.Name = name
	forwarder:SetAttribute("Path", "Packages/" .. name)

	packagesCopy.Parent = forwarder

	return forwarder :: ModuleScript
end

return module