#region Quickstart

Import-Module .\BombermanAPI.psm1 -Force

[URI]$Global:BombermanURI = "ws://127.0.0.1:8080/codenjoy-contest/ws?user=username@users.org"
 
while ($true) 
{
	
	#Clear-Host
	#Measure-Command {Invoke-GameSync}
	Invoke-GameSync | Show-GameBoardRawGrid
	
}

#endregion

#region 



while ($true)
{
	
	$myBoardString = Get-GameBoardRawString 
	$myCurrentGameBoard = Get-GameBoardElementArray -GameBoardRawString $myBoardString

	$myBomber = Get-GameElementCollection -GameBoardRawString $myBoardString -Element Bomberman

	# X,Y of myBomber
	$x = $myBomber[0][0]
	$y = $myBomber[0][1]


	# Place bomb

	Measure-Command {Invoke-GameAction-rev205 -BombermanAction act}

	Invoke-GameAction-rev205 -BombermanAction act

	# Get out of boom aray
	if ($myCurrentGameBoard[($x+1),($y)] -notmatch "Wall","WallDestroyable")
	{
		Invoke-GameAction-rev205 -BombermanAction right
	}
	if ($myCurrentGameBoard[($x-1),($y)] -notmatch "Wall","WallDestroyable")
	{
		Invoke-GameAction-rev205 -BombermanAction left
	}
	if ($myCurrentGameBoard[($x),($y+1)] -notmatch "Wall","WallDestroyable")
	{
		Invoke-GameAction-rev205 -BombermanAction up
	}
	if ($myCurrentGameBoard[($x),($y-1)] -notmatch "Wall","WallDestroyable")
	{
		Invoke-GameAction-rev205 -BombermanAction down
	}



}


while ($true) {
	Invoke-GameAction -BombermanAction left
}



# realtime consile GUI
while ($true) {
	Get-GameBoardRawString | Show-GameBoardCharArray
	Clear-Host
}









$AllWalls = Get-GameElementCollection -GameBoardRawString $myBoardString -Element Wall
$AllWalls.Count

$badGuys = Get-GameElementCollection -GameBoardRawString $myBoardString -Element OtherBomberman
$badGuys.Count
$badGuys[0]
$badGuys[1]
$badGuys[2]

$takeCare = Get-GameElementCollection -GameBoardRawString $myBoardString -Element OtherBombBomberman
$takeCare[0]







	
	