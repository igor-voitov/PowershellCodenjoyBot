## PowershellCodenjoyBot
Powershell helper/client module for 
[CodingDojo project](https://github.com/codenjoyme/codenjoy/tree/master/CodingDojo/) **Bomberman game**.  
*Prerequisites: .NET Framework since 4.5*

[Bobmberman game rules.](https://github.com/codenjoyme/codenjoy/blob/master/CodingDojo/games/bomberman/src/main/webapp/resources/help/bomberman.html)

Powershell WebSockets implementation based on the following:  
https://github.com/markwragg/Powershell-SlackBot  
https://github.com/brianddk/ripple-ps-websocket  

---------------
## Quickstart

1. [Build/Run local gameserver](https://github.com/codenjoyme/codenjoy/tree/master/CodingDojo/) and [Register your player](http://127.0.0.1:8080/codenjoy-contest/register)

2. Import **`BombermanAPI.psm1`** module into your PS session to access basic/helper functions  
(specify full path to the .psm1 module if module location differs from shell location )
```powershell
Import-Module .\BombermanAPI.psm1 -Force
```

3. Change/Set your Gameserver websocket connection URI and your Username in the **`$Global:BombermanURI`** variable
```powershell
[URI]$Global:BombermanURI = "ws://127.0.0.1:8080/codenjoy-contest/ws?user=username@users.org"
```

3. Execute a loop below. Your Bomber will start moving randomly every 1sec.
```powershell
while ($true)
{
	Invoke-GameAction -BombermanAction $(Get-Random("act", "left", "right", "up", "down"))
}
```
---------------------
## How to play

* Gameserver constantly sends string gameboard describing current game situation, here is how it looks like:  

board=☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼        #   # #               #☼☼ ☼ ☼ ☼ ☼ ☼#☼#☼#☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼#☼☼              ##     ♥     ### ☼☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼&☼ ☼ ☼ ☼ ☼ ☼ ☼#☼☼                #        #     ☼☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼#☼ ☼☼                           # ##☼☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼☼&                             #☼☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼☼                               ☼☼ ☼ ☼ ☼ ☼ ☼ ☼&☼ ☼ ☼ ☼ ☼ ☼#☼ ☼ ☼#☼☼                 #       ##    ☼☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼#☼☼                        # #    ☼☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼#☼#☼ ☼#☼ ☼☼    &           #    #       # ☼☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼#☼#☼ ☼ ☼ ☼☼                     #    #  # ☼☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼☼         ##  #          ## ## #☼☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼#☼#☼#☼#☼ ☼ ☼☼##        &       # #  ##   #  ☼☼#☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼#☼#☼ ☼ ☼ ☼☼###  #  #         #    # ###   ☼☼ ☼#☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼#☼#☼#☼ ☼☼# # # #       # #♥##   # ####  ☼☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼#☼#☼ ☼#☼#☼☺☼ ☼ ☼☼&   #  #      #   &  ## ###   &☼☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼#☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼☼    #     #     # #     # & # &☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼    
BoardSize is 33x33 points, therefore you will get a string of 33x33+6(prefix)=1095 UFT8 characters every tick(second) 
---------------






* Here is how to construct a basic decision.  
For instance, let's check whether it's okay to move into X=30 Y=5.  
If Wall,WallDestroyable or MeatChopper there than we can't move, else can move 
```powershell
if ($myCurrentGameBoard[30,5] -match "Wall","WallDestroyable","MeatChopper")
{
	"Can`t move"
}
else 
{
	"Let's move"
}
```


* To access all game elements you can use **`Get-GameElementCollection`** cmdlet.
**`Get-GameElementCollection`** capable to return all possible game elements and their coordinates represented as a collection of (X,Y) points.    
You must specify/choose target output collection utilzing **`-Element`** cmdlet parameter.  
Command returns a collection of (X,Y) points for all elements.  
By analyzing a given output collection you can get inside about elements count/ coordinates within gameboard. For instance:

  * Your Bomberman
  ```powershell
  $myBomber = Get-GameElementCollection -GameBoardRawString $myBoardString -Element Bomberman
  $myBomber
  ```
  
  * All walls
  ```powershell
  $AllWalls = Get-GameElementCollection -GameBoardRawString $myBoardString -Element Wall
  $AllWalls.Count
  ```

  * Other players bombermans
  ```powershell
  $badGuys = Get-GameElementCollection -GameBoardRawString $myBoardString -Element OtherBomberman
  $badGuys.Count
  $badGuys[0]
  $badGuys[1]
  $badGuys[2]
  ```

  * Bombs
  ```powershell
  $beware = Get-GameElementCollection -GameBoardRawString $myBoardString -Element OtherBombBomberman
  $beware[0]
  ```
