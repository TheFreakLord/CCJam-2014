--[[

# This is the main file of Freack100's program for the CCJam 2014
# You are not allowed to copy this program while watching my livestream :D


WHAT IS THIS:
This program allows you to create sandbox folders where you can run programs in.

]]

os.unloadAPI("sandboxAPI")
os.loadAPI("sandboxAPI")

local currentSandboxes = {}
local _fs = {}
for k,v in pairs(_G["fs"]) do
	_fs[k] = v
end
local config = {}
local defaultConfig = {
	["defaultSandbox"] = {
	path = "sandbox/defaultSandbox"
}
}
local args = {...}

--Autosave when you terminate the program
local pullEvent = os.pullEvent
function os.pullEvent(filter)

	local eventData = {os.pullEventRaw(filter)}
	if eventData[1] == "terminate" then
		saveConfig()
		os.pullEvent = pullEvent
	else
		return unpack(eventData)
	end

end


local function parseConfig()

	local parsedConfig = {}
	local configContent = {}
	local h = _fs.open("sandbox/config", "r")
	local line = h.readLine()
	local currentSection = ""

	while line do
		configContent[#configContent+1] = line
		line = h.readLine()
	end
	h.close()

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
			insert(tostring(k) .. "[" .. "\n")
			for i,j in pairs(v) do
				insert(tostring(i) .. " : " .. tostring(j) .. "\n")
			end
			insert("]\n")
		end
		insert("\n")
	end
	return content
end

local function setupDefaultConfig()

	if(not _fs.isDir("sandbox")) then
		_fs.makeDir("sandbox")
	end
	if(not _fs.exists("sandbox/config")) then
	local h = _fs.open("sandbox/config","w")
		for k,v in pairs(generateConfigFromTable(defaultConfig)) do
			h.write(v)
		end
		h.flush()
		h.close()
	end

end

local function setupSandboxFolders()

	for k,v in pairs(config) do
		if not _fs.exists("sandbox/"..k) then
			_fs.makeDir("sandbox/"..k)
		end
	end

end

local function saveConfig()
	local h = _fs.open("sandbox/config","w")
	local conf = generateConfigFromTable(config)
	for k,v in pairs(conf) do
		h.write(v)
	end
end

local function createNewSandbox(name, path)
	config[name] = {["path"] = path}
end

local function deleteSandbox(name)
	config[name] = null
end

local function runProgramInSandbox(path,sandbox)
	local p = config[sandbox].path
	local h = _fs.open(path, "r")
	local content = h.readAll()
	local preparepath = function(path)
		path = string.gsub(path,"../","")
		path = p .. "/" .. path
		return path 
	end
	h.close()
	local func = loadstring(content)


	local env = {__index = _G, fs = {

	

	list = function(path)
		return _fs.list(preparepath(path))
	end;

	exists = function(path)
		return _fs.exists(preparepath(path))
	end;

	isDir =  function(path)
		return _fs.isDir(preparepath(path))
	end;

	isReadOnly = function(path)
		return _fs.isReadOnly(preparepath(path))
	end;

	getName = function(path)
		return _fs.getName(preparepath(path))
	end;

	getDrive = function(path)
		return _fs.getDrive(preparepath(path))
	end;

	getSize = function(path)
		return _fs.getSize(preparepath(path))
	end;

	getFreeSpace = function(path)
		return _fs.getFreeSpace(preparepath(path))
	end;

	makeDir = function(path)
		return _fs.makeDir(preparepath(path))
	end;

	move = function(fromPath,toPath)
		return _fs.move(preparepath(fromPath), preparepath(toPath))
	end;

	copy = function(fromPath,toPath)
		return _fs.copy(preparepath(fromPath), preparepath(toPath))
	end;

	delete = function(path)
		return _fs.delete(preparepath(path))
	end;

	combine = function(basePath, localPath)
		return _fs.combine(preparepath(basePath), preparepath(localPath))
	end;

	open = function(path, mode)
		return _fs.open(preparepath(path), mode)
	end;

	find = function(wildcard)
		return _fs.find(wildcard)
	end;

	getDir = function(path)
		return _fs.getDir(preparepath(path))
	end;

	}}

	setmetatable(env,env)
	setfenv(func,env)
	func()

end

local function addOverride(func,path)

end

local function showHelp()

	print("usage: sandbox.lua <arguments>")
	print("       new <sandbox name> <path>")
	print("       remove <sandbox name>")
	print("       run <path to program> <sandbox name>")
	print("       addOverride <function name> <path>")
	print("       noHelp")

end

local function main()

	setupDefaultConfig()
	config = parseConfig()
	setupSandboxFolders()

	if args[1] == "help" then
		showHelp()
	elseif args[1] == "new" and (args[2] ~= nil and args[3] ~= nil) then
		createNewSandbox(args[2],args[3])
	elseif args[1] == "remove" and args[2] ~= nil and config[args[2]] ~= nil then
		deleteSandbox(args[2])
	elseif args[1] == "run" and args[2] ~= nil and args[3] ~= nil then
		if not _fs.exists(args[2]) then return end
		if not config[args[3]] then return end
		runProgramInSandbox(args[2], args[3])
	elseif args[1] == "addOverride" and #args >= 3 then
		addOverride(args[2],args[3])
	elseif args[1] == "noHelp" then

	else
		showHelp()
	end


	--Restore pullEvent if it ran as expected
	os.pullEvent = pullEvent

end

main()