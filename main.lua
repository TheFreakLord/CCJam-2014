--[[

# This is the main file of Freack100's program for the CCJam 2014
# You are not allowed to copy this program while watching my livestream :D

IDEAS:
- another boring puzzle game
- a screen lock
- a sandbox

]]

local handle = fs.open("startup","w")
handle.flush()
handle.close()
term.setCursorPos(5,5)
term.write("LUUUUL")
sleep(5)