# QuickStart
# 1. Import module into your PS session
Import-Module .\BombermanAPI.psm1 -Force

# 2. Set connection URI
[URI]$Global:BombermanURI = "ws://127.0.0.1:8080/codenjoy-contest/ws?user=username@users.org"

# 3. Start your Bomberman
while ($true) 
{
	move $(Random("act", "left", "right", "up", "down"))
}



# Basics

# to make a move use Invoke-GameSync function's -NextAction parameter
Invoke-GameSync -NextAction 'act, down'
# or pipe your action to Invoke-GameSync
'act, up' | Invoke-GameSync
# or use 'move' alias for Invoke-GameSync command
move "up"
move "left, act"



 

# make console GUI
while ($true)
{
	Clear-Host
	Invoke-GameSync
	Show-GameBoardRawGrid
}

# You can pipe Invoke-GameSync output gameboard string into another function's input 
Invoke-GameSync | Get-GameBoardCharArray

# You can store current gameboard string into variable and specify it within another function's parameter later
$GameString = Invoke-GameSync
Show-GameBoardCharArray -GameBoardRawString $GameString
Show-GameBoardCharArray($GameString)

# To start analyze gameboard
$GameString = Invoke-GameSync 
$GameBoard = Get-GameBoardElementArray -GameBoardRawString $GameString

# To start analyze gameboard's elements
$GameString = Invoke-GameSync
$AllWalls = Get-GameElementCollection -GameBoardRawString $GameString -Element Wall
$AllWalls.Count

$badGuys = Get-GameElementCollection -GameBoardRawString $GameString -Element OtherBomberman
$badGuys.Count
$badGuys[0]

$beware = Get-GameElementCollection -GameBoardRawString $GameString -Element OtherBombBomberman
$beware[0]







# A kind of algorithm of constatnly playing AI. Place a bomb then move to any free space. 
#region START
$myNextAction = "wait"
$GameTime = 5
$LastTimeBombPlaced = 0
while ($true)
{
	$GameTime++
	"`n NEW GameTime is " + $GameTime + " LastTimeBombPlaced was " + $LastTimeBombPlaced
	
	$GameString = Invoke-GameSync -NextAction $myNextAction
	$GameBoard = Get-GameBoardElementArray -GameBoardRawString $GameString
	
	# Get Bomber's position
	# If bomb just been placed, Bomberman is 'BombBomberman' game element
	$myBombBomber = Get-GameElementCollection -GameBoardRawString $GameString -Element BombBomberman
	If ($myBombBomber)
	{
		$x = $myBombBomber[0][0]
		$y = $myBombBomber[0][1]
	}
	# In general case Bomberman is 'Bomberman' game element
	$myBomber = Get-GameElementCollection -GameBoardRawString $GameString -Element Bomberman
	If ($myBomber)
	{
		$x = $myBomber[0][0]
		$y = $myBomber[0][1]
	}
	
	"Bomber at x=$($x) y=$($y)"
		
	
	# Place a bomb if has not been placed last 5 ticks 
	If (($LastTimeBombPlaced + 5) -lt $GameTime)
	{
		$myNextAction = "act"
		$LastTimeBombPlaced = $GameTime
		"Placing BOMB" + " at GameTime " + $GameTime
		Continue
	}
	
	# Look around for any free space to move
	if ($GameBoard[($x+1),($y)] -match "Space")
	{
		$myNextAction = "right"
		"Moving RIGHT" + " at GameTime " + $GameTime
		Continue
	}
	if ($GameBoard[($x-1),($y)] -match "Space")
	{
		$myNextAction = "left"
		"Moving LEFT" + " at GameTime " + $GameTime
		Continue
	}
	if ($GameBoard[($x),($y+1)] -match "Space")
	{
		$myNextAction = "up"
		"Moving UP" + " at GameTime " + $GameTime
		Continue
	}
	if ($GameBoard[($x),($y-1)] -match "Space")
	{
		$myNextAction = "down"
		"Moving DOWN" + " at GameTime " + $GameTime
		Continue
	}

}
#endregion END






while ($true) 
{
	move -NextAction $(Random("act", "left", "right", "up", "down"))
	Show-GameBoardRawGrid
}







	
	