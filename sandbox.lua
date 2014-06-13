--[[

# This is the main file of Freack100's program for the CCJam 2014
# You are not allowed to copy this program while watching my livestream :D


WHAT IS THIS:
This program allows you to create sandbox folders where you can run programs in.

]]

local currentSandboxes = {}
local nativeFileSystem = fs
local config = {}

local function parseConfig()

	local parsedConfig = {}
	local configContent = {}
	local h = nativeFileSystem.open("sandbox/config", "r")
	local line = h.readLine()
	local currentSection = ""

	while line do
		configContent[#configContent+1] = line
		line = handle.readLine()
	end
	handle.close()

	for k,v in pairs(configContent) do

		if(string.find(v,"(.+)%[")) then --it starts a new section
			if(currentSection == "") then --Checks if it is currently in no section
				parsedConfig[string.match(v,"(.+)%[")] = {}
				currentSection = string.match(v,"(.+)%[")
			end
		end

		if(string.find(v,"(.+) : (.+)")) then --It writes a new variable in the section
			if(currentSection ~= "") then --If it is in a section
				local key, value = string.match(v,"(.+) : (.+)")
				parsedConfig[currentSection][key] = value
			end
		end

		if v == "]" then --It closes the current section
			currentSection = ""
		end


	end

	return parsedConfig
end

local function generateConfigFromTable(configTable)

	local content = {}
	local section = ""
	local function insert(str)
		content[#content+1] = str
	end
	
	for k,v in pairs(configTable) do

		if(type(v) == "table") then
			insert(tostring(k) .. "[")
			for i,j in pairs(v) do
				insert(tostring(i) .. " : " .. tostring(j))
			end
			insert("]")
		end
		insert("\n")
	end
end

config = parseConfig()
local reparsedConfig = generateConfigFromTable(config)
for k,v in pairs(reparsedConfig) do
	print(v)
end

