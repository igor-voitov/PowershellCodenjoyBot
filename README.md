## PowershellCodenjoyBot
Powershell helper/client module for 
[CodingDojo project](https://github.com/codenjoyme/codenjoy/tree/master/CodingDojo/) **Bomberman game**.  
*Prerequisites: .NET Framework since 4.5*

[Bobmberman game rules.](https://github.com/codenjoyme/codenjoy/blob/master/CodingDojo/games/bomberman/src/main/webapp/resources/help/bomberman.html)

Powershell WebSockets implementation based on the following ideas:  
https://github.com/markwragg/Powershell-SlackBot  
https://github.com/brianddk/ripple-ps-websocket  

---------------
### Quickstart

0. [Build/Run local gameserver](https://github.com/codenjoyme/codenjoy/tree/master/CodingDojo/) and [Register your player](http://127.0.0.1:8080/codenjoy-contest/register)

1. Import **`BombermanAPI.psm1`** module to access helper cmdlets 
```powershell
Import-Module .\BombermanAPI.psm1 -Force
```

2. Change/Set your Gameserver websocket connection URI and your Username in the **`$Global:BombermanURI`** variable
```powershell
[URI]$Global:BombermanURI = "ws://127.0.0.1:8080/codenjoy-contest/ws?user=username@users.org"
```

3. Surround **`Invoke-GameAction`** cmdlet with infinite loop to quicktest.
Your Bomber will start moving and acting constantly
```powershell
while ($true)
{
	Invoke-GameAction -BombermanAction $(Get-Random("act", "left", "right", "up", "down"))
}
```
---------------------
### How to analyze the game and to make intelligent moves


* Gameserver constantly sends [string] gameboard with current situation, here is how it looks like:  
board=0000000000000000000000000000000000                     #  ##     00 0 0 0 0 0 0 0#0 0#0#0 0 ...  
BoardSize is 33x33 point, so you will get a string of 33x33+6(prefix)=1095 UFT8 chars every tick(second) 
Use **`Get-GameBoardRawString`** cmdlet to recieve gameboard rawstring
```powershell
Get-GameBoardRawString
```


* To make it readable pipe it into Show-GameBoardRawGrid cmdlet. It will insert newline every 33 symbols:
```powershell
Get-GameBoardRawString | Show-GameBoardRawGrid
```


* To get a [char]Two-Dimensional Array of gameboard use **`Get-GameBoardCharArray`** :
```powershell
$myGameboard = Get-GameBoardRawString | Get-GameBoardCharArray
```


* Now you have the full board, chars and coordinates(x,y) of these chars. Here is how to get char at X=10,Y=20 :
```powershell
$myGameboard[10,20]
```


* To get a single visual gameboard snaphot, pipe gamestring into **`Show-GameBoardCharArray`**:
```powershell
Get-GameBoardRawString | Show-GameBoardCharArray
```


* You can reciece a realtime console GUI, just append a kind of infinite loop:
```powershell
while ($true)
{
	Get-GameBoardRawString | Show-GameBoardCharArray
	Clear-Host
}
```


* You can store raw gamestrings to analyze later:
```powershell
while ($true)
{
	[string[]]$myGameHistory += Get-GameBoardRawString
}
[string[]]$myGameHistory.ForEach({Show-GameBoardCharArray -GameBoardRawString $_})
```


* To get gameboard elements represented as readeble words use **`Get-GameBoardElementArray`**  
This way you will recieve a Two-Dimensional string array populated with game elements values like Bomberman, BombBomberman, BombTimer2 and so forth:
```powershell
$myCurrentGameBoard = Get-GameBoardElementArray -GameBoardRawString $myBoardString
```


* Get any element by its array index (which are X-asis,Y-asis coordinates)
```powershell
$myCurrentGameBoard[30,5]
```


* Here is how to construct a basic decision.  
For instance, let's check whether it's okay to move into X=30 Y=5. IF Wall,WallDestroyable or MeatChopper 
```powershell
if ($myCurrentGameBoard[30,5] -match "Wall","WallDestroyable","MeatChopper")
{
	"Cant move through a $($myCurrentGameBoard[15,15])"
}
else 
{
	"A $($myCurrentGameBoard[15,15]) there, let's move"
}
```


* To access all game elements you can use Get-GameElementCollection cmdlet.
Get-GameElementCollection capable to return all possible game elements and them coordinates represented as a collection of (X,Y) points.
You have to specify required elements collection via -Element parameter.
Command will return a collection of all x,y points for all given elements.
By analyzing a given collection you will get inside about how many elements of a given type gameboard contains and where they are located.
For instance:

Let's find our bomberman
$myBoardString = Get-GameBoardRawString 
$myBomber = Get-GameElementCollection -GameBoardRawString $myBoardString -Element Bomberman
$myBomber

Let's count all the walls in the game
$AllWalls = Get-GameElementCollection -GameBoardRawString $myBoardString -Element Wall
$AllWalls.Count

To find other bombermans position
$badGuys = Get-GameElementCollection -GameBoardRawString $myBoardString -Element OtherBomberman
$badGuys.Count
$badGuys[0]
$badGuys[1]
$badGuys[2]

To be aware of placed enemies bombs
$takeCare = Get-GameElementCollection -GameBoardRawString $myBoardString -Element OtherBombBomberman
$takeCare[0]
