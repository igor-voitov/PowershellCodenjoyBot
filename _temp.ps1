
function Invoke-GameSync-rev2.2 {
[CmdletBinding()]
[Alias()]
[OutputType([String])]

Param
(
    # $Global:BombermanAction is the game action to send to server
    [Parameter(Mandatory=$false, 
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true, 
               Position=0)]
    [ValidateNotNullOrEmpty()]
	[String]$NextBotAction = $Global:BombermanAction
)

Begin
{
	Write-Verbose ("`n`n`n Starting new sync")
	
	# Open websocket connection 
	If ($ClientWebSocket.State -ne "Open")
	{
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
	Else 
	{
		Write-Verbose ("Websocked already opened")
	}
}

Process
{
	
	

	Write-Verbose ("----- Sync start. SendCounter: $global:SendCounter ReceiveCounter: $global:ReceiveCounter -------")

	#region Send websocket message

	

	# This enumeration of strings which game server able to accept and covert into game action 
	$PossibleActionsEnum = 	"act","left","right","up","down","act, left","act, right","act, up","act, down","left, act","right, act","up, act","down, act"
				
	# Checks wether it is okay message
	If ($NextBotAction -in $PossibleActionsEnum)
	{
		
		
		# Actually performing websocket SendAsync method 
		$OutgoingBufferArray = [System.Text.Encoding]::UTF8.GetBytes($NextBotAction)
		$OutgoingData = New-Object System.ArraySegment[byte]  -ArgumentList @(,$OutgoingBufferArray)
		$SendAsync = $ClientWebSocket.SendAsync($OutgoingData, [System.Net.WebSockets.WebSocketMessageType]::Text, [System.Boolean]::TrueString, $CancellationToken)
				
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
		Start-Sleep -Milliseconds 1000	
	}

	$global:SendCounter++
	#endregion Send websocket message


	#region Recieve websocket message 
	$IncomingBufferArray = [byte[]] @(,0) * 2000
	$IncomingData = New-Object System.ArraySegment[byte]  -ArgumentList @(,$IncomingBufferArray)
	
	Do {}
	$ReceiveAsync = $ClientWebSocket.ReceiveAsync($IncomingData, $CancellationToken)
	
	$GameBoardRawString = [System.Text.Encoding]::UTF8.GetString($IncomingData.Array)
	
	Write-Verbose ("ReceiveAsync ID " + $ReceiveAsync.Id.ToString() + " status: " + ($ReceiveAsync.Status))
	Write-Verbose ("ReceiveAsync result: Count " + $ReceiveAsync.Result.Count + " EndOfMessage " + $ReceiveAsync.Result.EndOfMessage)
	
	$global:ReceiveCounter++
	#endregion Recieve websocket message 

	Start-Sleep -Milliseconds 1000	
}
End
{
	# Free up object resources 
	#$SendAsync.Dispose()
	$ReceiveAsync.Dispose()
	#$ClientWebSocket.Abort()
	#$ClientWebSocket.Dispose()
	Write-Verbose ("----- Sync end. SendCounter: $global:SendCounter ReceiveCounter: $global:ReceiveCounter -------")
	Return [string]$GameBoardRawString
}
}



$global:SendCounter = 0
$global:ReceiveCounter = 0
$global:ACTUALSendCounter = 0
while ($true) {

	Invoke-GameSync-rev2.2

}


