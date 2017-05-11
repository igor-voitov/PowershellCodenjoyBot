<# 
 .Synopsis
  Displays a visual representation of a calendar.

 .Description
  Displays a visual representation of a calendar. This function supports multiple months
  and lets you highlight specific date ranges or days.

 .Parameter Start
  The first month to display.

 .Parameter End
  The last month to display.

 .Parameter FirstDayOfWeek
  The day of the month on which the week begins.

 .Parameter HighlightDay
  Specific days (numbered) to highlight. Used for date ranges like (25..31).
  Date ranges are specified by the Windows PowerShell range syntax. These dates are
  enclosed in square brackets.

 .Parameter HighlightDate
  Specific days (named) to highlight. These dates are surrounded by asterisks.


 .Example
   # Show a default display of this month.
   Show-Calendar

 .Example
   # Display a date range.
   Show-Calendar -Start "March, 2010" -End "May, 2010"

 .Example
   # Highlight a range of days.
   Show-Calendar -HighlightDay (1..10 + 22) -HighlightDate "December 25, 2008"
#>

$VerbosePreference = "continue"
#[URI]$Global:BombermanURI = "ws://tetrisj.jvmhost.net:12270/codenjoy-contest/ws?user=donNetClient@dot.net"
[URI]$Global:BombermanURI = "ws://127.0.0.1:8080/codenjoy-contest/ws?user=username@users.org"

function Get-GameBoardRawString {
[CmdletBinding()]
[Alias()]
[OutputType([String])]
Param ()

Begin
{
	# Opening connection via websocket
	$ClientWebSocket = New-Object System.Net.WebSockets.ClientWebSocket
	#$myOptions = New-Object System.Net.WebSockets.ClientWebSocketOptions
	#keepalive 30sec ClientWebSocketOptions
	$CancellationToken = New-Object System.Threading.CancellationToken

	#$ConnectAsync = $ClientWebSocket.ConnectAsync(, $CancellationToken)                                                  
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
	# Recieve message via websocket
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
	Return [string]$GameBoardRawString
	$ReceiveAsync.Dispose()
	$ClientWebSocket.Abort()
	$ClientWebSocket.Dispose()
	
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
	[ValidateLength(1094,2000)]
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
	[String]
    $BombermanAction
)

Begin
{
	# Opening connection via websocket
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
	[ValidateLength(1094,2000)]
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
	[ValidateLength(1094,2000)]
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
				'?'
				{
					$GameBoardElementArray[$x,$y] = 'BombBomberman'
				} 
				
				# Your dead Bomberman. Don't worry, he will appear somewhere in next move. You're getting -200 for each death
				'?'
				{
					$GameBoardElementArray[$x,$y] = 'DeadBomberman'
				}

				# This is other players alive Bomberman
				'?'
				{
					$GameBoardElementArray[$x,$y] = 'OtherBomberman'
				}
				
				# This is other players Bomberman -  just set the bomb
				'?'
				{
					$GameBoardElementArray[$x,$y] = 'OtherBombBomberman'
				}

				# Other players Bomberman's corpse. It will disappear shortly, right on the next move. If you've done it you'll get +1000
				'?'
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
				'?'
				{
					$GameBoardElementArray[$x,$y] = 'Boom'
				}

				# Wall that can't be destroyed. Indestructible wall will not fall from bomb.
				'?'
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

        
         












# export-modulemember -function 













