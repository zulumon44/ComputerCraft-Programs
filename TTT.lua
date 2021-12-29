side = "left"

PC = os.getComputerID()
PL1 = "X" -- HOST
PL2 = "O" -- GUEST

gamemessage = "It's Your Turn!"

----- Create Board -----
board = {}
for i=0, 2 do
	board[i] = {}
	for k = 0, 2 do
		board[i][k] = nil
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
	if board[x][y] == nil then
		return " "
	else
		return board[x][y]
	end
end


function isEmpty(x, y)
	if board[x][y] == nil then
		return true
	else
		return false
	end
end


function checkForEnd()
	if checkForWin() == false then
		if checkForTie() == true then
			return true
		end
	else
		return true
	end
end
function printBoard()
local spot
io.write("\n")
for i = 0, 2 do
for k = 0, 2 do
	if k == 0 then
	io.write(" ")
	end
	spot = getSpot(i, k)
	io.write(spot)
	if k ~= 2 then
	io.write("|")
	else
	io.write("\n")
	end
end
	if i ~= 2 then
	io.write(" ")
	io.write("-----\n")
	end
end
io.write("\n")
end

function printBoardbuffer()
local spot
io.write("\n")
for i = 0, 2 do
for k = 0, 2 do
	if k == 0 then
	buffer()
	end
	spot = getSpot(i, k)
	io.write(spot)
	if k ~= 2 then
	io.write("|")
	else
	io.write("\n")
	end
end
	if i ~= 2 then
	buffer()
	io.write("-----\n")
	end
end
io.write("\n")
end

function checkForWin(x)
	-- horizontal
	if((board[0][0] == x) and (board[0][1] == x) and (board[0][2] == x)) or ((board[1][0] == x) and (board[01][1] == x) and (board[1][2] == x)) or ((board[2][0] == x) and (board[2][1] == x) and (board[2][2] == x)) then
		return true
		end
	-- diagonal
	if ((board[0][0] == x) and (board[1][1] == x) and (board[2][2] == x)) or ((board[2][0] == x) and (board[1][1] == x) and (board[0][2] == x)) then
		return true
		end
	-- vertical
	if ((board[0][0] == x) and (board[1][0] == x) and (board[2][0] == x)) or ((board[0][1] == x) and (board[1][1] == x) and (board[2][1] == x)) or ((board[0][2] == x) and (board[1][2] == x) and (board[2][2] == x)) then
		return true
		end
	-- else
	return false
	end


function play(p)
clear()
printBoard()
print(gamemessage)

while true do 

local event, button, x, y = os.pullEvent("mouse_click")

if x==1 then
bx = 0
elseif x==3 then
bx = 1
elseif x==5 then
bx = 2
end

if y == 2 then
by = 0
elseif y == 4 then
by = 1
elseif y == 6 then
by = 2
end

if isEmpty(by, bx) then
		board[by][bx] = p
		break
	else
		gamemessage = "That Spot is Taken!"

end



break
end
return by, bx
end




---------- START MAIN PROGRAM ----------

clear()
print("Tic-Tac-Toe!\nPress enter to start!")
	junk = read()
	clear()

	option = getOption()


----- Establish Connection -----
	
	clear()
	tPC = targetPC()
	rednet.open(side)
	
----- HOST -----
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
	
----- GUEST -----
if option == 2 then
id = -1
while true do
clear()
print("Connecting to Host...")
rednet.send(tPC, "join.game") 
id,message = rednet.receive(10)
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
	
-- NOTE: Will need one person to Search for connection and 1 to recieve

----- Play Game -----
while true do

-- Check --
if checkForWin(PL1) == true or checkForWin(PL2) == true then
	break
end

-- P1 Turn --
gamemessage = "It's Your Turn!"
retx, rety = play(PL1)


-- Check --
if checkForWin(PL1) == true or checkForWin(PL2) == true then
	break
end

-- P2 Turn --	
gamemessage = "It's Your Turn!"
retx, rety = play(PL2)

end

clear()
io.write("-----Final Board-----\n")
printBoardspaced()
io.write("\n")

-- Check who won --
if checkForWin(PL1) == false and checkForWin(PL2) == false then
	io.write("Tie!")
elseif checkForWin(PL1) == true then
	io.write("Player 1 Wins!")
else
	io.write("Player 2 Wins!")
end

rednet.close(side)
