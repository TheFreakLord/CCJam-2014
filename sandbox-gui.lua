--[[

#This is just a GUI for my sandbox.
#It was made so you can use the sandbox without knowing each command

]]

if not fs.exists("sandbox.lua") then
	print("Sorry, this program needs sandbox.lua to run")
	return
end

if not fs.exists("sandboxAPI") then
	print("Sorry, this program needs sandboxAPI to run")
	return
end

os.unloadAPI("sandboxAPI")
os.unloadAPI("buttonAPI")
os.loadAPI("sandboxAPI")
os.loadAPI("buttonAPI")



local function cls(cl)
	term.setBackgroundColor(cl)
	term.clear()
end

local config = {}
config = sandboxAPI.parseConfig()

local function reloadConfig()

	config = sandboxAPI.parseConfig()

end

local buttons = {
--Main Menu
	exit_mainmenu = buttonAPI.new({sX=23,sY=14,bg=colors.lightGray,fg=colors.gray,text="Exit",visible=true});
	edit_sandbox_menu = buttonAPI.new({sX=20,sY=12,bg=colors.lightGray,fg=colors.gray,text="Edit Sandbox",visible=true});
	run_in_sandbox = buttonAPI.new({sX=15,sY=10,bg=colors.lightGray,fg=colors.gray,text="Run Program In Sandbox",visible=true});
--Sandbox Menu
	new_sandbox = buttonAPI.new({sX=20,sY=6,bg=colors.lightGray,fg=colors.gray,text="New Sandbox",visible=false});
	exit_sandbox = buttonAPI.new({sX=23,sY=14,bg=colors.lightGray,fg=colors.gray,text="Back",visible=false});
	edit_sandbox = buttonAPI.new({sX=15,sY=10,bg=colors.lightGray,fg=colors.gray,text="Edit Existing Sandbox",visible=false});
	remove_sandbox = buttonAPI.new({sX=19,sY=8,bg=colors.lightGray,fg=colors.gray,text="Delete Sandbox",visible=false});
	list_sandbox = buttonAPI.new({sX=19,sY=12,bg=colors.lightGray,fg=colors.gray,text="List Sandboxes"});
}
local currentMenu = "MAIN"

local function updateMenu()

	--every button get's invisible
	for k,v in pairs(buttons) do
		buttonAPI.invisible(v)
	end

	--Only activate buttons you need
	if currentMenu == "MAIN" then
		buttonAPI.visible(buttons["exit_mainmenu"])
		buttonAPI.visible(buttons.edit_sandbox_menu)
		buttonAPI.visible(buttons.run_in_sandbox)
	end
	if currentMenu == "RUN" then

	end

	if currentMenu == "SANDBOX_MAIN" then
		buttonAPI.visible(buttons.new_sandbox)
		buttonAPI.visible(buttons.exit_sandbox)
		buttonAPI.visible(buttons.edit_sandbox)
		buttonAPI.visible(buttons.remove_sandbox)
		buttonAPI.visible(buttons.list_sandbox)
	end

	cls(colors.white)
	buttonAPI.drawButtons()

end

local function listSandboxes()

	cls(colors.white)
	term.setTextColor(colors.gray)
	term.setCursorPos(1,2)
	local count = 1
	for k,v in pairs(config) do

		print(count, ":", k)
		sleep(.1)
		count = count+1

	end
	sleep(2)

end

local function newSandbox()
	currentMenu = "CREATE_NEW_SANDBOX"
	updateMenu()
	term.setCursorPos(10,5)
	term.setTextColor(colors.black)
	term.write("Please enter the sandbox name")
	term.setCursorPos(10,6)
	local name = read()
	updateMenu()
	term.setCursorPos(10,5)
	term.write("Please enter the sandbox path")
	term.setCursorPos(10,6)
	local path = read()
	shell.run("sandbox.lua new "..name.." "..path)
	reloadConfig()
	currentMenu = "SANDBOX_MAIN"
	updateMenu()
end

local function newSandboxNoQuestions(name, path)
	shell.run("sandbox.lua new "..name.." "..path)
end

local function deleteSandboxNoQuestions(name)
	shell.run("sandbox.lua remove "..name)
end

local function getSandboxByID(id)
	local count = 1
	for k,v in pairs(config) do
		if id == count then
			return k
		end
		count = count+1
	end
end

local function deleteSandbox()
	currentMenu = "SANDBOX_DELETE"
	updateMenu()
	term.setTextColor(colors.black)
	term.setCursorPos(10,5)
	term.write("Please enter the sandbox you want to remove")
	term.setCursorPos(10,6)
	local input = read()
	local sandbx = nil
	if tonumber(input) == nil then sandbx = input else sandbx = getSandboxByID(tonumber(input)) end
	shell.run("sandbox.lua remove ".. sandbx)
	reloadConfig()
	currentMenu = "SANDBOX_MAIN"
	updateMenu()
end

local function editSandbox()

	currentMenu = "SANDBOX_EDIT"
	updateMenu()
	term.setTextColor(colors.black)
	term.setCursorPos(10,5)
	term.write("Please enter the current sandbox")
	term.setCursorPos(10,6)
	local currentBox = read()
	cls(colors.white)
	term.setCursorPos(10,5)
	term.write("Please enter a new name for the sandbox")
	term.setCursorPos(10,7)
	local newName = read()
	cls(colors.white)
	term.setCursorPos(10,5)
	term.write("Please enter a new path")
	term.setCursorPos(10,7)
	local newPath = read()
	cls(colors.white)
	term.setCursorPos(10,5)
	term.write("wiping old sandbox, creating new one...")


	newPath = newPath=="" and "sandbox/newPath" or newPath
	newName = newName=="" and "NewSandbox" or newName
	local sandbx = tonumber(currentBox)==nil and currentBox or getSandboxByID(tonumber(currentBox))

	newSandboxNoQuestions(newName,newPath)
	deleteSandboxNoQuestions(sandbx)

	reloadConfig()

	currentMenu = "SANDBOX_MAIN"
	updateMenu()


end

shell.run("sandbox.lua noHelp") --to be sure the config and the folders are created


cls(colors.white)
buttonAPI.drawButtons()
updateMenu()

while true do

	local evt = {os.pullEvent()}
	if evt[1] == "mouse_click" then
		term.setBackgroundColor(colors.green)
		term.setTextColor(colors.white)
		if(buttonAPI.checkMouseClick(evt[3],evt[4])) then
			id = buttonAPI.checkMouseClick(evt[3],evt[4])
			if id == buttons.exit_mainmenu then
				break
			elseif id == buttons.run_in_sandbox then
				currentMenu = "RUN"
				updateMenu()
				term.setCursorPos(10,5)
				term.setTextColor(colors.black)
				term.write("Please Enter The File Path")
				term.setCursorPos(10,6)
				local path = read()
				cls(colors.white)
				term.setCursorPos(10,5)
				term.write("Please Enter The Sandbox You Want To Use")
				term.setCursorPos(10,6)
				local sandbox = read()
				local sandbx = nil
				if tonumber(sandbox) then sandbx = getSandboxByID(tonumber(sandbox)) else sandbx = sandbox end
				if not config[sandbx] or (not fs.exists(path)) then
					cls(colors.white)
					term.setCursorPos(5,5)
					print("Sorry, but either the sandbox or \n    the file doesn't exist!")
					sleep(2)
				else
					cls(colors.black)
					term.setCursorPos(1,1)

					shell.run("sandbox.lua run "..path.." "..sandbx)
				end
				currentMenu = "MAIN"
				updateMenu()

			elseif id == buttons.list_sandbox then
				currentMenu = "LIST_SANDBOX"
				updateMenu()
				listSandboxes()
				currentMenu = "SANDBOX_MAIN"
				updateMenu()

			elseif id == buttons.new_sandbox then
				newSandbox()

			elseif id == buttons.remove_sandbox then
				deleteSandbox()

			elseif id == buttons.edit_sandbox then
				editSandbox()

			elseif id == buttons.edit_sandbox_menu then
				currentMenu = "SANDBOX_MAIN"
				updateMenu()
			elseif id == buttons.exit_sandbox then
				currentMenu = "MAIN"
				updateMenu()
			end
		end
	end
end
cls(colors.black)
term.setCursorPos(1,1)