--!strict

local pathAttribute = script:GetAttribute("Path") :: string
local path = pathAttribute:split("/")

return require(script[path[1]][path[2]]) :: any