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
local buttons = {
--Main Menu
	exit_mainmenu = buttonAPI.new({sX=23,sY=14,bg=colors.lightGray,fg=colors.gray,text="Exit",visible=true});
	edit_sandbox_menu = buttonAPI.new({sX=20,sY=12,bg=colors.lightGray,fg=colors.gray,text="Edit Sandbox",visible=true});
	run_in_sandbox = buttonAPI.new({sX=15,sY=10,bg=colors.lightGray,fg=colors.gray,text="Run Program In Sandbox",visible=true});
--Sandbox Menu
	new_sandbox = buttonAPI.new({sX=20,sY=8,bg=colors.lightGray,fg=colors.gray,text="New Sandbox",visible=false});
	exit_sandbox = buttonAPI.new({sX=20,sY=14,bg=colors.lightGray,fg=colors.gray,text="Back",visible=false});
	edit_sandbox = buttonAPI.new({sX=20,sY=12,bg=colors.lightGray,fg=colors.gray,text="Edit Existing Sandbox",visible=false});
	remove_sandbox = buttonAPI.new({sX=20,sY=10,bg=colors.lightGray,fg=colors.gray,text="Delete Sandbox",visible=false});
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
	end

	cls(colors.white)
	buttonAPI.drawButtons()

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
				if not config[sandbox] or (not fs.exists(path)) then
					cls(colors.white)
					term.setCursorPos(5,5)
					print("Sorry, but either the sandbox or \n    the file doesn't exist!")
					sleep(2)
				else
					cls(colors.black)
					term.setCursorPos(1,1)
					shell.run("sandbox.lua run "..path.." "..sandbox)
				end
				currentMenu = "MAIN"
				updateMenu()

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