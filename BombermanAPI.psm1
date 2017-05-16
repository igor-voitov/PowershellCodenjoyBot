
#[URI]$Global:BombermanURI = "ws://tetrisj.jvmhost.net:12270/codenjoy-contest/ws?user=donNetClient@dot.net"
[URI]$Global:BombermanURI = "ws://127.0.0.1:8080/codenjoy-contest/ws?user=username@users.org"
[string]$Global:BombermanAction = Get-Random("act, left","act, right","act, up","act, down")

function Invoke-GameAction {
[CmdletBinding()]
[Alias()]

Param
(
    # Enumeration of the possible bomberman's actions 
    [Parameter(Mandatory=$true, 
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true, 
               Position=0)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("act", "left", "right", "up", "down")]
	[String]$BombermanAction
)

Begin
{
	# Open websocket connection 
	$ClientWebSocket = New-Object System.Net.WebSockets.ClientWebSocket
	$CancellationToken = New-Object System.Threading.CancellationToken

	$ConnectAsync = $ClientWebSocket.ConnectAsync($Global:BombermanURI, $CancellationToken)                                                  
	
	$myCustomTimeout = New-TimeSpan -Seconds 2
	$myActionStartTime = Get-Date

	While (!$ConnectAsync.IsCompleted) 
	{ 
		$TimeTaken = (get-date) - $myActionStartTime
		If ($TimeTaken -gt $myCustomTimeout) 
			{
				Write-Warning ("Warning: ConnectAsync ID" + $ConnectAsync.Id.ToString() + " taking longer than " + ($myCustomTimeout.seconds) +" seconds.")
				Return
			}
		Start-Sleep -Milliseconds 100 
	}
		
	Write-Verbose ("ConnectAsync ID " + $ConnectAsync.Id.ToString() + " status: " + ($ConnectAsync.Status))
}
Process
{
	# Send websocket message
	$myOutgoingString = $BombermanAction
	
	$OutgoingBufferArray = [System.Text.Encoding]::UTF8.GetBytes($myOutgoingString)
	$OutgoingData = New-Object System.ArraySegment[byte]  -ArgumentList @(,$OutgoingBufferArray)
	$SendAsync = $ClientWebSocket.SendAsync($OutgoingData, [System.Net.WebSockets.WebSocketMessageType]::Text, [System.Boolean]::TrueString, $CancellationToken)
		
	$myCustomTimeout = New-TimeSpan -Seconds 2
	$myActionStartTime = Get-Date

	While (!$SendAsync.IsCompleted) 
	{ 
		$TimeTaken = (get-date) - $myActionStartTime
		If ($TimeTaken -gt $myCustomTimeout) 
			{
				Write-Warning ("Warning: SendAsync ID" + $SendAsync.Id.ToString() + " taking longer than " + ($myCustomTimeout.seconds) +" seconds.")
				Return
			}
		Start-Sleep -Milliseconds 100 
	}

	Write-Verbose ("SendAsync ID " + $SendAsync.Id.ToString() + " status: " + ($SendAsync.Status))
	
}
End
{
	$SendAsync.Dispose()
	$ClientWebSocket.Abort()
	$ClientWebSocket.Dispose()
}
}

function Start-BombermanSessionWorker {
[CmdletBinding()]
[Alias()]

Param
()

Begin
{
	# Open websocket connection 
	$ClientWebSocket = New-Object System.Net.WebSockets.ClientWebSocket
	$CancellationToken = New-Object System.Threading.CancellationToken

	$ConnectAsync = $ClientWebSocket.ConnectAsync($Global:BombermanURI, $CancellationToken)                                                  
	
	$myCustomTimeout = New-TimeSpan -Seconds 2
	$myActionStartTime = Get-Date

	While (!$ConnectAsync.IsCompleted) 
	{ 
		$TimeTaken = (Get-Date) - $myActionStartTime
		If ($TimeTaken -gt $myCustomTimeout) 
			{
				Write-Warning ("Warning: ConnectAsync ID" + $ConnectAsync.Id.ToString() + " taking longer than " + ($myCustomTimeout.seconds) +" seconds.")
				Return
			}
		Start-Sleep -Milliseconds 100 
	}
		
	Write-Verbose ("ConnectAsync ID " + $ConnectAsync.Id.ToString() + " status: " + ($ConnectAsync.Status))
}
Process
{
	
	# Send websocket message
	
	# This enumeration of strings which game server able to accept and covert into game action 
	$PossibleActionsEnum = 	"act","left","right","up","down","act, left","act, right","act, up","act, down","left, act","right, act","up, act","down, act"

	[int]$verboseCounter = 0 

	# Infinite loop constatly checks $Global:BombermanAction variable value and sends content to game server 
	While ($true)
	{
		
		# Checks wether it is okay message
		If ($Global:BombermanAction -in $PossibleActionsEnum)
		{
			# Actually performing websocket SendAsync method 
			$OutgoingBufferArray = [System.Text.Encoding]::UTF8.GetBytes($Global:BombermanAction)
			$OutgoingData = New-Object System.ArraySegment[byte]  -ArgumentList @(,$OutgoingBufferArray)
			$SendAsync = $ClientWebSocket.SendAsync($OutgoingData, [System.Net.WebSockets.WebSocketMessageType]::Text, [System.Boolean]::TrueString, $CancellationToken)
			Start-Sleep -Milliseconds 1000	
			
			# Just verbose troubleshoot data
			Write-Verbose ("SendAsync performed $($verboseCounter) times")
			Write-Verbose ("Status: $($SendAsync.Status)")
			$verboseCounter++
			
			# Free up object resources 
			$SendAsync.Dispose()
		}
		
		# Notification about incorrect outgoing message.
		Else
		{
			Write-Warning ("Game action may not be proccessed. Try one of the following: ")
			$PossibleActionsEnum.ForEach({Write-Warning $_})
			Start-Sleep -Milliseconds 1000	
		}
		
	}
	
}
End
{
	$ClientWebSocket.Abort()
	$ClientWebSocket.Dispose()
}
}


function Get-GameBoardRawString {
[CmdletBinding()]
[Alias()]
[OutputType([String])]
Param ()

Begin
{
	# Open websocket connection 
	$ClientWebSocket = New-Object System.Net.WebSockets.ClientWebSocket
	$CancellationToken = New-Object System.Threading.CancellationToken

	$ConnectAsync = $ClientWebSocket.ConnectAsync($Global:BombermanURI, $CancellationToken)                                                  
	
	$myCustomTimeout = New-TimeSpan -Seconds 2
	$myActionStartTime = Get-Date

	While (!$ConnectAsync.IsCompleted) 
	{ 
		$TimeTaken = (get-date) - $myActionStartTime
		If ($TimeTaken -gt $myCustomTimeout) 
			{
				Write-Warning ("Warning: ConnectAsync ID" + $ConnectAsync.Id.ToString() + " taking longer than " + ($myCustomTimeout.seconds) +" seconds.")
				Return
			}
		Start-Sleep -Milliseconds 100 
	}
		
	Write-Verbose ("ConnectAsync ID " + $ConnectAsync.Id.ToString() + " status: " + ($ConnectAsync.Status))
}
Process
{
	# Recieve websocket message 
	$IncomingBufferArray = [byte[]] @(,0) * 1808
	$IncomingData = New-Object System.ArraySegment[byte]  -ArgumentList @(,$IncomingBufferArray)

	$ReceiveAsync = $ClientWebSocket.ReceiveAsync($IncomingData, $CancellationToken)
	$myCustomTimeout = New-TimeSpan -Seconds 2
	$myActionStartTime = Get-Date

	While (!$ReceiveAsync.IsCompleted) 
	{ 
		$TimeTaken = (get-date) - $myActionStartTime
		If ($TimeTaken -gt $myCustomTimeout) 
			{
				Write-Warning ("Warning: ReceiveAsync ID" + $ReceiveAsync.Id.ToString() + " taking longer than " + ($myCustomTimeout.seconds) +" seconds.")
				Return
			}
		Start-Sleep -Milliseconds 100 
	}

	Write-Verbose ("ReceiveAsync ID " + $ReceiveAsync.Id.ToString() + " status: " + ($ReceiveAsync.Status))
	Write-Verbose ("ReceiveAsync result: Count " + $ReceiveAsync.Result.Count + " EndOfMessage " + $ReceiveAsync.Result.EndOfMessage)

		
	$GameBoardRawString = [System.Text.Encoding]::UTF8.GetString($IncomingData.Array)
	

}
End
{
	
	$ReceiveAsync.Dispose()
	$ClientWebSocket.Abort()
	$ClientWebSocket.Dispose()
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
	[ValidateLength(1090,2000)]
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












