
#default public server URI
#[URI]$Global:BombermanURI = "ws://tetrisj.jvmhost.net:12270/codenjoy-contest/ws?user=donNetClient@dot.net"

#default local server URI
[URI]$Global:BombermanURI = "ws://127.0.0.1:8080/codenjoy-contest/ws?user=username@users.org"

function Invoke-GameSync {
[CmdletBinding()]
[Alias("Move")]
[OutputType([String])]

Param
(
    # $Global:BombermanAction is the game action to send to server
    [Parameter(Mandatory=$false, 
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true, 
               Position=0)]
	[ValidateSet("wait","act","left","right","up","down","act, left","act, right","act, up","act, down","left, act","right, act","up, act","down, act")]
	[String]$NextAction = "act, up"
)

Begin
{
	# verbose info
	Write-Verbose ("`n`n`n Starting new sync")
	$SyncStartTime = (Get-Date)
	$SyncTime = (New-TimeSpan -Seconds 0)

	# Open websocket connection 
	If ($ClientWebSocket.State -ne "Open")
	{
		$global:ClientWebSocket = New-Object System.Net.WebSockets.ClientWebSocket
		$global:CancellationToken = New-Object System.Threading.CancellationToken
		
		$ConnectAsync = $ClientWebSocket.ConnectAsync($Global:BombermanURI, $CancellationToken)
		
		$myCustomTimeout = New-TimeSpan -Seconds 3
		$myActionStartTime = Get-Date

		While (!$ConnectAsync.IsCompleted) 
		{ 
			$TimeTaken = (get-date) - $myActionStartTime
			If ($TimeTaken -gt $myCustomTimeout) 
				{
					Write-Warning ("Warning: ConnectAsync ID" + $ConnectAsync.Id.ToString() + " taking longer than " + ($myCustomTimeout.seconds) +" seconds.")
					Return
				}
			Start-Sleep -Milliseconds 50 
		}
		
		Write-Verbose ("ConnectAsync ID " + $ConnectAsync.Id.ToString() + " status: " + ($ConnectAsync.Status))
	}
	Else 
	{
		Write-Verbose ("Websocked already opened")
	}
		

	# verbose info
	$SyncTime = ((Get-Date) - $SyncStartTime)
	Write-Verbose ("Synctime after connect $($SyncTime.TotalMilliseconds) Milliseconds " )
}

Process
{
		
	#region Send websocket message
	Write-Verbose ("----- Sync start. SendCounter: $global:SendCounter ReceiveCounter: $global:ReceiveCounter -------")

	# Enumeration of strings which game server able to accept and handle as proper bot action 
	$PossibleActionsEnum = 	"wait","act","left","right","up","down","act, left","act, right","act, up","act, down","left, act","right, act","up, act","down, act"
				
	# Check whether it is a proper string or not
	If ($NextAction -in $PossibleActionsEnum)
	{
		
		# Actually performing websocket SendAsync method 
		$OutgoingBufferArray = [System.Text.Encoding]::UTF8.GetBytes($NextAction)
		$OutgoingData = New-Object System.ArraySegment[byte]  -ArgumentList @(,$OutgoingBufferArray)
				
		$SendAsync = $ClientWebSocket.SendAsync($OutgoingData, [System.Net.WebSockets.WebSocketMessageType]::Text, [System.Boolean]::TrueString, $CancellationToken)
		Start-Sleep -Milliseconds 50

		$Timeout = (New-TimeSpan -Seconds 1)
		$TaskStartTime = (Get-Date)
		
		While (!$SendAsync.IsCompleted) 
		{ 
			$TimeTaken = (Get-Date) - $TaskStartTime
			If ($TimeTaken -gt $Timeout) 
				{
					Write-Warning ("Warning: $SendAsync ID" + $SendAsync.Id.ToString() + " taking longer than " + ($Timeout.seconds) +" seconds.")
					Return
				}
			Start-Sleep -Milliseconds 50
		}
		
		
		# Just verbose troubleshoot data
		$global:ACTUALSendCounter++
		Write-Verbose ("ACTUAL SendAsync performed $($global:ACTUALSendCounter) times")
		Write-Verbose ("ACTUAL SendAsync Status: $($SendAsync.Status)")
		
	}
		
	# Notification about incorrect outgoing message.
	Else
	{
		Write-Warning ("Next game action unrecognized. Try one of the following: ")
		$PossibleActionsEnum.ForEach({Write-Warning $_})
			
	}
		
	$global:SendCounter++
	
	$SyncTime = ((Get-Date) - $SyncStartTime)
	Write-Verbose ("Synctime after send $($SyncTime.TotalMilliseconds) Milliseconds " )
		
	#endregion Send websocket message





	#region RECIEVE websocket message 
		
	# recieve full websocket message until ReceiveAsync.Result.EndOfMessage will be true
	[string]$GameBoardRawString = ""
	[string]$partialGameBoardRawString = ""
	
	Do
	{
		$IncomingBufferArray = [byte[]] @(,0) * 2000
		$IncomingData = New-Object System.ArraySegment[byte]  -ArgumentList @(,$IncomingBufferArray)
		
		$ReceiveAsync = $ClientWebSocket.ReceiveAsync($IncomingData, $CancellationToken)
		
		$Timeout = (New-TimeSpan -Seconds 1)
		$TaskStartTime = (Get-Date)

		While (!$ReceiveAsync.IsCompleted) 
		{ 
			$TimeTaken = ((get-date) - $TaskStartTime)
			If ($TimeTaken -gt $Timeout) 
				{
					Write-Warning ("Warning: $ReceiveAsync ID" + $ReceiveAsync.Id.ToString() + " taking longer than " + ($Timeout.seconds) +" seconds.")
					Return
				}
			Start-Sleep -Milliseconds 100 
		}
		
		
		$partialGameBoardRawString = [System.Text.Encoding]::UTF8.GetString($IncomingData.Array)
		$partialGameBoardRawString = ($partialGameBoardRawString -replace "�", "")
		$GameBoardRawString = $GameBoardRawString + $partialGameBoardRawString.TrimEnd([char]$null)
		
		Write-Verbose ("ReceiveAsync ID " + $ReceiveAsync.Id.ToString() + " status: " + ($ReceiveAsync.Status))
		Write-Verbose ("ReceiveAsync result: Count " + $ReceiveAsync.Result.Count + " EndOfMessage " + $ReceiveAsync.Result.EndOfMessage)
		Write-Verbose ("Gameboard string lenght is $($GameBoardRawString.Length) " )

		$SyncTime = ((Get-Date) - $SyncStartTime)
		Write-Verbose ("Synctime after single receive cycle $($SyncTime.TotalMilliseconds) Milliseconds " )
		
	}
	Until ($ReceiveAsync.Result.EndOfMessage)
		
	$global:ReceiveCounter++
	#endregion Recieve websocket message 

	$SyncTime = ((Get-Date) - $SyncStartTime)
	Write-Verbose ("Synctime after all receives  $($SyncTime.TotalMilliseconds) Milliseconds " )
	
	# Aligning send/rcv sync with 1 sec timeframe
	If ($SyncTime.TotalMilliseconds -lt 900)
	{
		$delay = (900 - $SyncTime.TotalMilliseconds)
		Start-Sleep -Milliseconds $delay
		Write-Verbose ("Added delay  $($delay) Milliseconds " )
	}
	 
}
End
{
	# clean up system resources 
	$SendAsync.Dispose()
	$ReceiveAsync.Dispose()
	#$ClientWebSocket.Abort()
	#$ClientWebSocket.Dispose()
	
	# verbose info
	Write-Verbose ("----- Sync end. SendCounter: $global:SendCounter ReceiveCounter: $global:ReceiveCounter -------")
	$SyncTime = ((Get-Date) - $SyncStartTime)
	Write-Verbose ("Synctime before exit  $($SyncTime.TotalMilliseconds) Milliseconds " )
	
	# Function output
	Return [string]$GameBoardRawString 
}
}

function Show-GameBoardRawGrid {
[CmdletBinding()]
[Alias()]
[OutputType([string])]
Param 
(
	# [string]GameBoardRawString
    [Parameter(Mandatory=$true, 
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true, 
                Position=0)]
    [ValidateNotNullOrEmpty()]
	[ValidateLength(1090,4000)]
    [string]$GameBoardRawString
)

Begin
{
}
Process
{

	# Cutting string to exclude board=
	$GridGameBoard = $GameBoardRawString.Substring(6)

	# Converting string into grid
	$offset = 0
	$newLineIndex = 33
	for ($newLineIndex = 33; $newLineIndex -lt 1089; $newLineIndex = $newLineIndex + 33)
	{ 
		$GridGameBoard = ($GridGameBoard.Insert(($newLineIndex + $offset),"`n"))
		$offset++		
	} 
	
}
End
{
	Write-Output $GridGameBoard
}
}

function Get-GameBoardCharArray {
[CmdletBinding()]
[Alias()]
[OutputType([String[,]])]
Param
(
	# [string]GameBoardRawString
    [Parameter(Mandatory=$true, 
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true, 
                Position=0)]
    [ValidateNotNullOrEmpty()]
	[ValidateLength(1090,2000)]
    [string]$GameBoardRawString

)
Begin
{
}
Process
{
	$boardString = $GameBoardRawString.Substring(6)
	[int]$GameStringCounter = 0
	$GameBoardCharsArray = New-Object 'string[,]' 33,33

	for ($y=0; $y -lt $GameBoardCharsArray.GetLength(1); $y++) 
	{
		for ($x=0; $x -lt $GameBoardCharsArray.GetLength(0); $x++) 
		{
			$GameBoardCharsArray[$x,$y] = $boardString[$GameStringCounter]
			$GameStringCounter++
		}
	}
}
End
{
	Return , [string[,]]$GameBoardCharsArray
}
}

function Show-GameBoardCharArray {
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
	[ValidateLength(1090,2000)]
    [string]$GameBoardRawString
)
Begin
{
}
Process
{
	$boardString = $GameBoardRawString.Substring(6)
	[int]$GameStringCounter = 0
	$GameCharsArray = New-Object 'string[,]' 33,33

	for ($y=0; $y -lt $GameCharsArray.GetLength(1); $y++) 
	{
		[string]$CharsLine = ""
		for ($x=0; $x -lt $GameCharsArray.GetLength(0); $x++) 
		{
			$CharsLine = $CharsLine + $boardString[$GameStringCounter]
			$GameStringCounter++
		}
		Write-Output $CharsLine
	}
}
End
{
}
}

function Get-GameBoardElementArray {
[CmdletBinding()]
[Alias()]
[OutputType([String[,]])]
Param
(
	# [string]GameBoardRawString
    [Parameter(Mandatory=$true, 
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true, 
                Position=0)]
    [ValidateNotNullOrEmpty()]
	[ValidateLength(1090,2000)]
    [string]$GameBoardRawString

)
Begin
{		
}
Process
{
	$boardString = $GameBoardRawString.Substring(6)
	$GameBoardElementArray = New-Object 'string[,]' 33,33
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
				}

				# Your bomberman is sitting on own bomb
				'☻'
				{
					$GameBoardElementArray[$x,$y] = 'BombBomberman'
				} 
				
				# Your dead Bomberman. Don't worry, he will appear somewhere in next move. You're getting -200 for each death
				'Ѡ'
				{
					$GameBoardElementArray[$x,$y] = 'DeadBomberman'
				}

				# This is other players alive Bomberman
				'♥'
				{
					$GameBoardElementArray[$x,$y] = 'OtherBomberman'
				}
				
				# This is other players Bomberman -  just set the bomb
				'♠'
				{
					$GameBoardElementArray[$x,$y] = 'OtherBombBomberman'
				}

				# Other players Bomberman's corpse. It will disappear shortly, right on the next move. If you've done it you'll get +1000
				'♣'
				{
					$GameBoardElementArray[$x,$y] = 'OtherDeadBomberman'
				}
		
				# Bomb with timer "5 tacts to boo-o-o-m!". After bomberman set the bomb, the timer starts (5 tacts)
				'5'
				{
					$GameBoardElementArray[$x,$y] = 'BombTimer5'
				}

				# Bomb with timer "4 tacts to boom"
				'4'
				{
					$GameBoardElementArray[$x,$y] = 'BombTimer4'
				}

				# Bomb with timer "3 tacts to boom"
				'3'
				{
					$GameBoardElementArray[$x,$y] = 'BombTimer3'
				}

				# Bomb with timer "2 tacts to boom"
				'2'
				{
					$GameBoardElementArray[$x,$y] = 'BombTimer2'
				}

				# Bomb with timer "1 tacts to boom"
				'1'
				{
					$GameBoardElementArray[$x,$y] = 'BombTimer1'
				}

				# Boom! This is what is bomb does, everything that is destroyable got destroyed
				'҉'
				{
					$GameBoardElementArray[$x,$y] = 'Boom'
				}

				# Wall that can't be destroyed. Indestructible wall will not fall from bomb.
				'☼'
				{
					$GameBoardElementArray[$x,$y] = 'Wall'
				}
				
				# Destroyable wall. It can be blowed up with a bomb (+10 points)
				'#'
				{
					$GameBoardElementArray[$x,$y] = 'WallDestroyable'
				}

				# Walls ruins. This is how broken wall looks like, it will dissapear on next move.
				'H'
				{
					$GameBoardElementArray[$x,$y] = 'DestroyedWall'
				}

				# Meat chopper. This guys runs over the board randomly and gets in the way all the time. If it will touch bomberman - bomberman dies.
				'&'
				{
					$GameBoardElementArray[$x,$y] = 'MeatChopper'
				}

				# Dead meat chopper. +100 point for killing.
				'x'
				{
					$GameBoardElementArray[$x,$y] = 'DeadMeatChopper'
				}

				# Empty space on a map. This is the only place where you can move your Bomberman
				Default
				{
					$GameBoardElementArray[$x,$y] = 'Space'
				}
			}
			
			$GameStringCounter++
		}
	}
}
End
{
	Return , [string[,]]$GameBoardElementArray
}
}

function Get-GameElementCollection {
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
	[ValidateLength(1090,2000)]
    [string]$GameBoardRawString,

	# [string]Element
    [Parameter(Mandatory=$true, 
               Position=1)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet(
		"Bomberman",
		"BombBomberman",
		"DeadBomberman",
		"OtherBomberman",
		"OtherBombBomberman",
		"OtherDeadBomberman",
		"BombTimer5",
		"BombTimer4",
		"BombTimer3",
		"BombTimer2",
		"BombTimer1",
		"Boom",
		"Wall",
		"WallDestroyable",
		"DestroyedWall",
		"MeatChopper",
		"DeadMeatChopper",
		"Space")]
    [string]$Element

)
Begin
{
}
Process
{
	$BombermanCollection = New-Object System.Collections.Generic.List[System.Object]
	$BombBombermanCollection = New-Object System.Collections.Generic.List[System.Object]
	$DeadBombermanCollection = New-Object System.Collections.Generic.List[System.Object]
	$OtherBombermanCollection = New-Object System.Collections.Generic.List[System.Object]
	$OtherBombBombermanCollection = New-Object System.Collections.Generic.List[System.Object]
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
	
	$boardString = $GameBoardRawString.Substring(6)
	[int]$GameStringCounter = 0
	$GameBoardElementArray = New-Object 'string[,]' 33,33

	for ($y=0; $y -lt $GameBoardElementArray.GetLength(1); $y++) 
	{
		for ($x=0; $x -lt $GameBoardElementArray.GetLength(0); $x++) 
		{
			
			switch ($boardString[$GameStringCounter])
			{
				# This is your Bomberman. This is what he usually looks like
				'☺'
				{
					$point = $null
					$point = ($x,$y)
					$BombermanCollection.Add($point)
					$point = $null
				}

				# Your bomberman is sitting on own bomb
				'☻'
				{
					$point = $null
					$point = ($x,$y)
					$BombBombermanCollection.Add($point)
					$point = $null
				} 
				
				# Your dead Bomberman. Don't worry, he will appear somewhere in next move. You're getting -200 for each death
				'Ѡ'
				{
					$point = $null
					$point = ($x,$y)
					$DeadBombermanCollection.Add($point)
					$point = $null
				}

				# This is other players alive Bomberman
				'♥'
				{
					$point = $null
					$point = ($x,$y)
					$OtherBombermanCollection.Add($point)
					$point = $null
				}
				
				# This is other players Bomberman -  just set the bomb
				'♠'
				{
					$point = $null
					$point = ($x,$y)
					$OtherBombBombermanCollection.Add($point)
					$point = $null
				}

				# Other players Bomberman's corpse. It will disappear shortly, right on the next move. If you've done it you'll get +1000
				'♣'
				{
					$point = $null
					$point = ($x,$y)
					$OtherDeadBombermanCollection.Add($point)
					$point = $null
				}
		
				# Bomb with timer "5 tacts to boo-o-o-m!". After bomberman set the bomb, the timer starts (5 tacts)
				'5'
				{
					$point = $null
					$point = ($x,$y)
					$BombTimer5Collection.Add($point)
					$point = $null
				}

				# Bomb with timer "4 tacts to boom"
				'4'
				{
					$point = $null
					$point = ($x,$y)
					$BombTimer4Collection.Add($point)
					$point = $null
				}

				# Bomb with timer "3 tacts to boom"
				'3'
				{
					$point = $null
					$point = ($x,$y)
					$BombTimer3Collection.Add($point)
					$point = $null
				}

				# Bomb with timer "2 tacts to boom"
				'2'
				{
					$point = $null
					$point = ($x,$y)
					$BombTimer2Collection.Add($point)
					$point = $null
				}

				# Bomb with timer "1 tacts to boom"
				'1'
				{
					$point = $null
					$point = ($x,$y)
					$BombTimer1Collection.Add($point)
					$point = $null
				}

				# Boom! This is what is bomb does, everything that is destroyable got destroyed
				'҉'
				{
					$point = $null
					$point = ($x,$y)
					$BoomCollection.Add($point)
					$point = $null
				}

				# Wall that can't be destroyed. Indestructible wall will not fall from bomb.
				'☼'
				{
					$point = $null
					$point = ($x,$y)
					$WallCollection.Add($point)
					$point = $null
				}
				
				# Destroyable wall. It can be blowed up with a bomb (+10 points)
				'#'
				{
					$point = $null
					$point = ($x,$y)
					$WallDestroyableCollection.Add($point)
					$point = $null
				}

				# Walls ruins. This is how broken wall looks like, it will dissapear on next move.
				'H'
				{
					$point = $null
					$point = ($x,$y)
					$DestroyedWallCollection.Add($point)
					$point = $null
				}

				# Meat chopper. This guys runs over the board randomly and gets in the way all the time. If it will touch bomberman - bomberman dies.
				'&'
				{
					$point = $null
					$point = ($x,$y)
					$MeatChopperCollection.Add($point)
					$point = $null
				}

				# Dead meat chopper. +100 point for killing.
				'x'
				{
					$point = $null
					$point = ($x,$y)
					$DeadMeatChopperCollection.Add($point)
					$point = $null
				}

				# Empty space on a map. This is the only place where you can move your Bomberman
				Default
				{
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
	switch ($Element)
	{
	"Bomberman" {Return , $BombermanCollection}
	"BombBomberman" {Return , $BombBombermanCollection}
	"DeadBomberman"{Return , $DeadBombermanCollection}
	"OtherBomberman"{Return , $OtherBombermanCollection}
	"OtherBombBomberman"{Return , $OtherBombBombermanCollection}
	"OtherDeadBomberman"{Return , $OtherDeadBombermanCollection}
	"BombTimer5"{Return , $BombTimer5Collection}
	"BombTimer4"{Return , $BombTimer4Collection}
	"BombTimer3"{Return , $BombTimer3Collection}
	"BombTimer2"{Return , $BombTimer2Collection}
	"BombTimer1"{Return , $BombTimer1Collection}
	"Boom"{Return , $BoomCollection}
	"Wall"{Return , $WallCollection}
	"WallDestroyable"{Return , $WallDestroyableCollection}
	"DestroyedWall"{Return , $DestroyedWallCollection}
	"MeatChopper"{Return , $MeatChopperCollection}
	"DeadMeatChopper"{Return , $DeadMeatChopperCollection}
	"Space"{Return , $SpaceCollection}
    Default {Write-Output "Something went wrong."}
	}
}
}
  
         
Export-ModuleMember -Function *












