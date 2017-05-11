Import-Module .\BombermanAPI.psm1 -Force 




function Get-GameElements {
[CmdletBinding()]
[Alias()]
Param
(
	# [string]GameBoardRawString
    [Parameter(Mandatory=$true, 
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true, 
                Position=0)]
    [ValidateNotNullOrEmpty()]
	[ValidateLength(1094,2000)]
    [string]$GameBoardRawString

)
Begin
{
}
Process
{

	$boardString = $GameBoardRawString.Substring(6)
		
	$GameBoardElementArray = New-Object 'string[,]' 33,33

	$BombermanCollection = New-Object System.Collections.Generic.List[System.Object]
	$BombBombermanCollection = New-Object System.Collections.Generic.List[System.Object]
	$DeadBombermanCollection = New-Object System.Collections.Generic.List[System.Object]
	$OtherBombermanCollection = New-Object System.Collections.Generic.List[System.Object]
	$OtherBombBomberman = New-Object System.Collections.Generic.List[System.Object]
	$OtherDeadBombermanCollection = New-Object System.Collections.Generic.List[System.Object]
	$BombTimer5Collection = New-Object System.Collections.Generic.List[System.Object]
	$BombTimer4Collection = New-Object System.Collections.Generic.List[System.Object]
	$BombTimer3Collection = New-Object System.Collections.Generic.List[System.Object]
	$BombTimer2Collection = New-Object System.Collections.Generic.List[System.Object]
	$BombTimer1Collection = New-Object System.Collections.Generic.List[System.Object]
	$BoomCollection = New-Object System.Collections.Generic.List[System.Object]
	$WallCollection = New-Object System.Collections.Generic.List[System.Object]
	$WallDestroyableCollection = New-Object System.Collections.Generic.List[System.Object]
	$DestroyedWallCollection = New-Object System.Collections.Generic.List[System.Object]
	$MeatChopperCollection = New-Object System.Collections.Generic.List[System.Object]
	$DeadMeatChopperCollection = New-Object System.Collections.Generic.List[System.Object]
	$SpaceCollection = New-Object System.Collections.Generic.List[System.Object]
	
	[int]$GameStringCounter = 0

	for ($y=0; $y -lt $GameBoardElementArray.GetLength(1); $y++) 
	{
		for ($x=0; $x -lt $GameBoardElementArray.GetLength(0); $x++) 
		{
			
			switch ($boardString[$GameStringCounter])
			{
				# This is your Bomberman. This is what he usually looks like
				'☺'
				{
					$GameBoardElementArray[$x,$y] = 'Bomberman'
					$point = $null
					$point = ($x,$y)
					$BombermanCollection.Add($point)
					$point = $null
				}

				# Your bomberman is sitting on own bomb
				'?'
				{
					$GameBoardElementArray[$x,$y] = 'BombBomberman'
					$point = $null
					$point = ($x,$y)
					$BombBombermanCollection.Add($point)
					$point = $null
				} 
				
				# Your dead Bomberman. Don't worry, he will appear somewhere in next move. You're getting -200 for each death
				'?'
				{
					$GameBoardElementArray[$x,$y] = 'DeadBomberman'
					$point = $null
					$point = ($x,$y)
					$DeadBombermanCollection.Add($point)
					$point = $null
				}

				# This is other players alive Bomberman
				'?'
				{
					$GameBoardElementArray[$x,$y] = 'OtherBomberman'
					$point = $null
					$point = ($x,$y)
					$OtherBombermanCollection.Add($point)
					$point = $null
				}
				
				# This is other players Bomberman -  just set the bomb
				'?'
				{
					$GameBoardElementArray[$x,$y] = 'OtherBombBomberman'
					$point = $null
					$point = ($x,$y)
					$OtherBombBomberman.Add($point)
					$point = $null
				}

				# Other players Bomberman's corpse. It will disappear shortly, right on the next move. If you've done it you'll get +1000
				'?'
				{
					$GameBoardElementArray[$x,$y] = 'OtherDeadBomberman'
					$point = $null
					$point = ($x,$y)
					$OtherDeadBombermanCollection.Add($point)
					$point = $null
				}
		
				# Bomb with timer "5 tacts to boo-o-o-m!". After bomberman set the bomb, the timer starts (5 tacts)
				'5'
				{
					$GameBoardElementArray[$x,$y] = 'BombTimer5'
					$point = $null
					$point = ($x,$y)
					$BombTimer5Collection.Add($point)
					$point = $null
				}

				# Bomb with timer "4 tacts to boom"
				'4'
				{
					$GameBoardElementArray[$x,$y] = 'BombTimer4'
					$point = $null
					$point = ($x,$y)
					$BombTimer4Collection.Add($point)
					$point = $null
				}

				# Bomb with timer "3 tacts to boom"
				'3'
				{
					$GameBoardElementArray[$x,$y] = 'BombTimer3'
					$point = $null
					$point = ($x,$y)
					$BombTimer3Collection.Add($point)
					$point = $null
				}

				# Bomb with timer "2 tacts to boom"
				'2'
				{
					$GameBoardElementArray[$x,$y] = 'BombTimer2'
					$point = $null
					$point = ($x,$y)
					$BombTimer2Collection.Add($point)
					$point = $null
				}

				# Bomb with timer "1 tacts to boom"
				'1'
				{
					$GameBoardElementArray[$x,$y] = 'BombTimer1'
					$point = $null
					$point = ($x,$y)
					$BombTimer1Collection.Add($point)
					$point = $null
				}

				# Boom! This is what is bomb does, everything that is destroyable got destroyed
				'?'
				{
					$GameBoardElementArray[$x,$y] = 'Boom'
					$point = $null
					$point = ($x,$y)
					$BoomCollection.Add($point)
					$point = $null
				}

				# Wall that can't be destroyed. Indestructible wall will not fall from bomb.
				'?'
				{
					$GameBoardElementArray[$x,$y] = 'Wall'
					$point = $null
					$point = ($x,$y)
					$WallCollection.Add($point)
					$point = $null
				}
				
				# Destroyable wall. It can be blowed up with a bomb (+10 points)
				'#'
				{
					$GameBoardElementArray[$x,$y] = 'WallDestroyable'
					$point = $null
					$point = ($x,$y)
					$WallDestroyableCollection.Add($point)
					$point = $null
				}

				# Walls ruins. This is how broken wall looks like, it will dissapear on next move.
				'H'
				{
					$GameBoardElementArray[$x,$y] = 'DestroyedWall'
					$point = $null
					$point = ($x,$y)
					$DestroyedWallCollection.Add($point)
					$point = $null
				}

				# Meat chopper. This guys runs over the board randomly and gets in the way all the time. If it will touch bomberman - bomberman dies.
				'&'
				{
					$GameBoardElementArray[$x,$y] = 'MeatChopper'
					$point = $null
					$point = ($x,$y)
					$MeatChopperCollection.Add($point)
					$point = $null
				}

				# Dead meat chopper. +100 point for killing.
				'x'
				{
					$GameBoardElementArray[$x,$y] = 'DeadMeatChopper'
					$point = $null
					$point = ($x,$y)
					$DeadMeatChopperCollection.Add($point)
					$point = $null
				}

				# Empty space on a map. This is the only place where you can move your Bomberman
				Default
				{
					$GameBoardElementArray[$x,$y] = 'Space'
					$point = $null
					$point = ($x,$y)
					$SpaceCollection.Add($point)
					$point = $null
				}
			}
			
			$GameStringCounter++
		}
	}
}
End
{
	
}
}






while ($true)
{
	Measure-Command {Invoke-GameAction -BombermanAction $(Get-Random("act", "left", "right", "up", "down"))} | select Milliseconds
}

while ($true)
{
	Get-GameBoardVisualGrid
}


while ($true)
{
	Invoke-GameAction -BombermanAction $(Get-Random("act", "left", "right", "up", "down"))
}
	
	