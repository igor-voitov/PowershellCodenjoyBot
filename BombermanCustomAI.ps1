# QuickStart
# 1. Import module into your PS session 
# (specify full path to the .psm1 module if its location differs from this script location )
Import-Module .\BombermanAPI.psm1 -Force

# 2. Set connection URI (you should have Java websockets game server to be already up and running)
[URI]$Global:BombermanURI = "ws://127.0.0.1:8080/codenjoy-contest/ws?user=username@users.org"

# 3. Start your Bomberman (Execute a loop below). Your Bomber will start moving randomly every 1sec.
while ($true) 
{
	move $(Random("act", "left", "right", "up", "down"))
}



# Basics function usage/how-to

# to make a move use Invoke-GameSync function's -NextAction parameter
Invoke-GameSync -NextAction 'act, down'
# or pipe your action to Invoke-GameSync
'act, up' | Invoke-GameSync
# or use 'move' alias for Invoke-GameSync command
move "up"
move "left, act"
 
# to get current gameboard and to show it within console output
Invoke-GameSync
Show-GameBoardRawGrid


# to make a console GUI (show current gameboard every 1sec)
while ($true)
{
	Clear-Host
	Invoke-GameSync
	Show-GameBoardRawGrid
}

# You can pipe Invoke-GameSync output gameboard string into another function's input 
Get-GameBoardCharArray

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



#region Helper function usage and examples

#позиция моего бомбера на доске
#Point getBomberman()
getBomberman

#позиции всех остальных бомберов (противников) на доске
#Collection<Point> getOtherBombermans()
#boolean isMyBombermanDead()
getOtherBombermans

#жив ли мой бомбер
#boolean isAt(int x, int y, Element element)
isMyBombermanDead

#находится ли в позиции  x, y заданный элемент?
#находится ли в позиции  x, y что-нибудь из заданного набора
#boolean isAt(int x, int y, Element element)
#boolean isAt(int x, int y, Collection<Element> elements)
isAt -X 32 -Y 15 -Element MeatChopper
isAt 32 15 Space,Boom,BombTimer1,Wall

#есть ли вокруг клеточки с координатой x,y заданный элемент
#boolean isNear(int x, int y, Element element)
#examples
isNear -x 29 -y 31 -Element MeatChopper

#есть ли препятствие в клеточке x, y
#boolean isBarrierAt(int x, int y) 
#examples
isBarrierAt -X 32 -Y 32

#сколько элементов заданного типа есть вокруг клетки с x, y
#int countNear(int x, int y, Element element)
#examples
countNear -X 16 -Y 15 -Element Wall

#возвращает элемент в текущей клетке
#Element getAt(int x, int y)
getAt -X 15 -Y 16

# возвращает размер доски
# int boardSize()
boardSize

# координаты всех объектов препятствующих движению
# Collection<Point> getBarriers() 
getBarriers

# координаты всех чудиков которые могут убить бомбера
# Collection<Point> getMeatChoppers()
getMeatChoppers

# координаты всех бетонных стен
#Collection<Point> getWalls()
getWalls

# координаты всех кирпичных стен (их можно разрушать)
# Collection<Point> getDestroyWalls()
getDestroyWalls

# координаты всех бомб
# Collection<Point> getBombs()
getBombs

#координаты потенциально опасных мест, где бомба может разорваться. (бомба взрывается на N {решим перед началом игры} клеточек в стороны: вверх, вниз, вправо, влево)
#Collection<Point> getFutureBlasts()
getFutureBlasts





	
	