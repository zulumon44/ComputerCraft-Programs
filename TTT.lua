-------------------------------
-- Network Based Tic-Tac-Toe --
-- Written for ComputerCraft --
--      By Tyler Thomas      --
-------------------------------


-- Change where your Modem is on the Computer
side = "left"

-- Change Pieces per player
PL1 = "X" -- HOST
PL2 = "O" -- GUEST

----- Global Variables -----
gamemessage = "It's Your Turn!"
PC = os.getComputerID()
turns = 0



----- Create Board -----
board = {}
for i=1, 3 do
	board[i] = {}
	for k = 1, 3 do
		board[i][k] = "E"
	end
end

function buffer()
io.write("        ")
end

function clear()
	term.clear()
	term.setCursorPos(1,1)
end

local function targetPC()
	local PCnum
	print("What PC Would You like to play against?")

	while true do
		PCnum = tonumber(read())
		if PCnum==nil then
			print("A Number was not entered, Try again\n")
		else
			break
		end
	end
return PCnum
end

local function getOption()
print("Click 1 to host or 2 to join!")
print ("1. Host")
print ("2. Join")

local option = 0

while true do 

local event, button, x, y = os.pullEvent("mouse_click")

for n = 1, 7 do 
if x == n and y == 2 and button == 1 then
	option = 1
	break
end
end

for n = 1, 7 do 
if x == n and y == 3 and button == 1 then
	option = 2
	break
end
end

if option ~= 0 then
break
end
end
return option
end



function getSpot(x, y)
	if board[x][y] == "E" then
		return " "
	else
		return board[x][y]
	end
end


function isEmpty(x, y)
	if board[x][y] == "E" then
		return true
	else
		return false
	end
end

function printBoard()
local spot
io.write("\n")
for i = 1, 3 do
for k = 1, 3 do
	if k == 1 then
	io.write(" ")
	end
	spot = getSpot(i, k)
	io.write(spot)
	if k ~= 3 then
	io.write("|")
	else
	io.write("\n")
	end
end
	if i ~= 3 then
	io.write(" ")
	io.write("-----\n")
	end
end
io.write("\n")
end

function printBoardSpaced()
local spot
io.write("\n")
for i = 1, 3 do
for k = 1, 3 do
	if k == 1 then
	buffer()
	end
	spot = getSpot(i, k)
	io.write(spot)
	if k ~= 3 then
	io.write("|")
	else
	io.write("\n")
	end
end
	if i ~= 3 then
	buffer()
	io.write("-----\n")
	end
end
io.write("\n")
end

function checkForWin(x)
	-- horizontal
	if((board[1][1] == x) and (board[1][2] == x) and (board[1][3] == x)) or ((board[2][1] == x) and (board[2][2] == x) and (board[2][3] == x)) or ((board[3][1] == x) and (board[3][2] == x) and (board[3][3] == x)) then
		return true
		end
	-- diagonal
	if ((board[1][1] == x) and (board[2][2] == x) and (board[3][3] == x)) or ((board[3][1] == x) and (board[2][2] == x) and (board[1][3] == x)) then
		return true
		end
	-- vertical
	if ((board[1][1] == x) and (board[2][1] == x) and (board[3][1] == x)) or ((board[1][2] == x) and (board[2][2] == x) and (board[3][2] == x)) or ((board[1][3] == x) and (board[2][3] == x) and (board[3][3] == x)) then
		return true
		end
	-- else
	return false
	end


function play(p)
while true do 

clear()
printBoard()
print(gamemessage)
local event, button, x, y = os.pullEvent("mouse_click")

if x==2 then
bx = 1
elseif x==4 then
bx = 2
elseif x==6 then
bx = 3
else
bx=0
end

if y == 2 then
by = 1
elseif y == 4 then
by = 2
elseif y == 6 then
by = 3
else
by=0
end

if (x==2 or x==4 or x==6) and (y==2 or y==4 or y==6) and button==1 then
if isEmpty(by, bx) == true then
		board[by][bx] = p
		turns = turns + 1
		break
	else
		gamemessage = "That Spot is Taken!"
end
end
end

return by, bx
end




---------- START MAIN PROGRAM ----------

clear()
print("Tic-Tac-Toe!\nClick Anywhere to start!")

while true do 
local event, button, x, y = os.pullEvent("mouse_click")
if button == 1 then
break
end
end

----- Set Host/Guest -----
	
	clear()
	option = getOption()
	
----- Get Ready for Connection -----
	
	clear()
	tPC = targetPC()
	rednet.open(side)
	
----- HOST Connection -----
if option == 1 then
id = -1
while true do
clear()
print("Waiting for Connection...\n")
id,message = rednet.receive() 
if id==tPC and message == "join.game" then
print("Connection Recieved!")
sleep(.5)
rednet.send(tPC, "confirm.game") 
id,message = rednet.receive(10)
if id==tPC and message == "confirm.game" then
print("Connection Established!")
sleep(2)
break
else
print("Connection Error.")
print("Please Terminate and Try Again.")
sleep(120)
do return end
end
end
end
end
	
----- GUEST Connection -----
if option == 2 then
id = -1
while true do
clear()
print("Connecting to Host...")
rednet.send(tPC, "join.game") 
id,message = rednet.receive(5)
if id == tPC and message == "confirm.game" then
print("Connection Recieved!")
sleep(.5)
rednet.send(tPC, "confirm.game")
sleep(.5)
print("Connection Established!")
sleep(2)
break
else
clear()
print("Connection Error.")
print("Please Terminate and Try Again.")
sleep(120)
do return end
end
end
end	

----- Play Game -----
while true do

-- Check --
if checkForWin(PL1) == true or checkForWin(PL2) == true or turns == 9 then
	break
end

-- P1 Turn --
--host--
if option == 1 then
	gamemessage = "It's Your Turn!"
	retx, rety = play(PL1)

	ret = retx .. " " .. rety
	rednet.send(tPC, ret)
	gamemessage = "Waiting for Opponent..."
	clear()
	printBoard()
	print(gamemessage)

--guest--
else
	gamemessage = "Waiting for Opponent..."
	clear()
	printBoard()
	print(gamemessage)
while true do
	id,message = rednet.receive()
	if id == tPC then
		break
	end
end
space = " "
local messageString = {}
for w in message:gmatch("%S+") do 
table.insert(messageString, w)
end
print(messageString[1])
local s1 = tonumber(messageString[1])
print(messageString[2])
local s2 = tonumber(messageString[2])
board[s1][s2] = PL1
turns = turns + 1
end

-- Check --
if checkForWin(PL1) == true or checkForWin(PL2) == true or turns == 9 then
	break
end

-- P2 Turn --	

--guest--
if option == 2 then
	gamemessage = "It's Your Turn!"
	retx, rety = play(PL2)

	ret = retx .. " " .. rety
	rednet.send(tPC, ret)

--host--
else
while true do
	id,message = rednet.receive()
	if id == tPC then
		break
	end
end
space = " "
local messageString = {}
for w in message:gmatch("%S+") do 
table.insert(messageString, w)
end
print(messageString[1])
local s1 = tonumber(messageString[1])
print(messageString[2])
local s2 = tonumber(messageString[2])
board[s1][s2] = PL2
turns = turns + 1
end

end 
-- End Game Loop --

clear()
io.write("-----Final Board-----\n")
printBoardSpaced()
io.write("\n")

-- Check who won --
if checkForWin(PL1) == false and checkForWin(PL2) == false then
	io.write("Tie!\n")
elseif checkForWin(PL1) == true then
	io.write("Player ")
	io.write(PL1)
	io.write(" Wins!\n")
else
	io.write("Player ")
	io.write(PL2)
	io.write(" Wins!\n")
end

rednet.close(side)
