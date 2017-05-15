Import-Module .\BombermanAPI.psm1 -Force
[URI]$Global:BombermanURI = "ws://127.0.0.1:8080/codenjoy-contest/ws?user=username@users.org"

while ($true)
{
	Invoke-GameAction -BombermanAction $(Get-Random("act", "left", "right", "up", "down"))
}


while ($true)
{
	Get-GameBoardRawString | Show-GameBoardCharArray
	Clear-Host
}


$myCurrentGameBoard = Get-GameBoardElementArray -GameBoardRawString $myBoardString
$myCurrentGameBoard[30,5]


$myBoardString = Get-GameBoardRawString 
$myBomber = Get-GameElementCollection -GameBoardRawString $myBoardString -Element Bomberman
$myBomber

$AllWalls = Get-GameElementCollection -GameBoardRawString $myBoardString -Element Wall
$AllWalls.Count

$badGuys = Get-GameElementCollection -GameBoardRawString $myBoardString -Element OtherBomberman
$badGuys.Count
$badGuys[0]
$badGuys[1]
$badGuys[2]

$takeCare = Get-GameElementCollection -GameBoardRawString $myBoardString -Element OtherBombBomberman
$takeCare[0]







	
	