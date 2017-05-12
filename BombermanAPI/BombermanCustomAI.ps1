# Poweshell script to control your Bomberman
# Prerequesits: .NET Framework since 4.5, 
# Jetty server, Java WAR accepting WebSockets connections,
# Follow link below to quickly build your own local gameserver:
# Read more https://github.com/codenjoyme/codenjoy/tree/master/CodingDojo
# Bobmberman games rules avaliable at
# https://github.com/codenjoyme/codenjoy/blob/master/CodingDojo/games/bomberman/src/main/webapp/resources/help/bomberman.html
# 

# How to start

# Import BombermanAPI.psm1 module to access helper cmdlets 
Import-Module .\BombermanAPI.psm1 -Force

# Change your GameServer URL and Username in the $Global:BombermanURI variable if needed
[URI]$Global:BombermanURI = "ws://127.0.0.1:8080/codenjoy-contest/ws?user=username@users.org"

# You are ready to go! 
# Surround Invoke-GameAction cmdlet with infinite loop to quicktest.
# Your Bomber will start move. Below sample represents not a clever but constanly playing bot.
while ($true)
{
	Invoke-GameAction -BombermanAction $(Get-Random("act", "left", "right", "up", "down"))
}


# How to analyze game and make intelligent moves

# Gameserver constantly sends [string] gameboard with current situation, here it is
# board=☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼                     #  ##     ☼☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼#☼ ☼#☼#☼ ☼ ☼#☼ ☼ ☼☼ #        ##  ###        #  #  ☼☼ ☼ ☼ ☼ ☼#☼ ☼ ☼ ☼#☼ ☼ ☼ ☼ ☼#☼ ☼#☼☼  ###  #                   #  #☼☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼#☼ ☼ ☼ ☼ ☼ ☼ ☼#☼2☼☼             # #            ♥  ☼☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼☼ &           #  #              ☼☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼☼                #              ☼☼ ☼ ☼ ☼ ☼ ☼ ☼#☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼☼&#         &       #           ☼☼ ☼ ☼#☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼☼ #    #          #             ☼☼ ☼ ☼#☼ ☼ ☼ ☼#☼ ☼ ☼#☼ ☼ ☼ ☼ ☼ ☼ ☼☼# #  # #                       ☼☼ ☼ ☼#☼#☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼☼  ### ##  ## #   # #           ☼☼ ☼ ☼ ☼ ☼#☼ ☼ ☼ ☼#☼#☼ ☼ ☼ ☼ ☼ ☼ ☼☼    # # ##  #   #              ☼☼ ☼ ☼ ☼ ☼#☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼☼       #          &        #   ☼☼ ☼#☼ ☼ ☼#☼ ☼ ☼ ☼ ☼#☼ ☼ ☼ ☼ ☼ ☼ ☼☼             #    #            ☼☼ ☼ ☼ ☼#☼#☼ ☼ ☼ ☼ ☼#☼ ☼ ☼ ☼&☼ ☼ ☼☼        #    ###              &☼☼ ☼ ☼ ☼ ☼ ☼#☼#☼ ☼ ☼#☼#☼ ☼ ☼ ☼ ☼&☼☼  #         #&##   ##  ☺  &    ☼☼ ☼#☼#☼ ☼ ☼#☼ ☼#☼#☼ ☼ ☼ ☼ ☼ ☼ ☼ ☼☼#  ###♥ #  ##  ###         &#  ☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼☼
# Use Get-GameBoardRawString cmdlet to recieve gameboard raw string
Get-GameBoardRawString 

# To make it readable pipe it into Show-GameBoardRawGrid cmdlet
Get-GameBoardRawString | Show-GameBoardRawGrid

# To get a [char] Two-Dimensional array of gameboard use Get-GameBoardCharArray
$myGameboard = Get-GameBoardRawString | Get-GameBoardCharArray
# Now you can access any point(x,y) of the board to get a char in it
$myGameboard[10,20]

# To get readable chararray array representation pipe gamestring into Show-GameBoardCharArray
Get-GameBoardRawString | Show-GameBoardCharArray

# Now you are ready to build a game console realtime GUI, make an infinite loop like
while ($true)
{
	Get-GameBoardRawString | Show-GameBoardRawGrid
	Clear-Host
}

# You can populate your array with raw gamestrings for future use
while ($true)
{
	[string[]]$myGameHistory += Get-GameBoardRawString
}
[string[]]$myGameHistory.ForEach({Show-GameBoardCharArray -GameBoardRawString $_})


# To get gameboard array represented as human readeble elements use Get-GameBoardElementArray
$myCurrentGameBoard = Get-GameBoardElementArray -GameBoardRawString $myBoardString
# Thus you have recieved a Two-Dimensional string array populated with readeble game elements
# Get any element by index that is its X-asis and Y-asis gameboard coordinates respectively 
$myCurrentGameBoard[30,5]

# This way you can construct a decision. For instance, let's check whether it's okay to move into X=30 Y=5
if ($myCurrentGameBoard[30,5] -match "Wall","WallDestroyable","MeatChopper")
{
	"Cant move through a $($myCurrentGameBoard[15,15])"
}
else 
{
	"A $($myCurrentGameBoard[15,15]) there, let's move"
}

# To access all game elements use Get-GameElementCollection cmdlet.
# This commands returns all possible elements of the board, count and coordinates as a collection object.
# You have to specify required elements collection via -Element parameter
# Command will return a collection of all x,y points for all given elements

# Let's find our bomberman
$myBoardString = Get-GameBoardRawString 
$myBomber = Get-GameElementCollection -GameBoardRawString $myBoardString -Element Bomberman
$myBomber

# Let's count all the walls in the game
$AllWalls = Get-GameElementCollection -GameBoardRawString $myBoardString -Element Wall
$AllWalls.Count

# To find other bombermans position
$badGuys = Get-GameElementCollection -GameBoardRawString $myBoardString -Element OtherBomberman
$badGuys.Count
$badGuys[0]
$badGuys[1]
$badGuys[2]

# To be aware of placed enemies bombs
$takeCare = Get-GameElementCollection -GameBoardRawString $myBoardString -Element OtherBombBomberman
$takeCare[0]







	
	