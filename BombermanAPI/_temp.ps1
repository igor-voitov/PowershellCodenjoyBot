#
# Script.ps1
#


Finally
{
	# Closing connection via websocket 
	If ($ClientWebSocket.State -eq 'Open') 
	{ 
		$WebSocketCloseStatus = New-Object System.Net.WebSockets.WebSocketCloseStatus                                          
		$myAction = $ClientWebSocket.CloseOutputAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "NormalClosure", $CancellationToken) 
		do { Start-Sleep -Milliseconds 100 }
		until ($myAction.IsCompleted)
		Write-Verbose ("CloseOutputAsync ID " + $myAction.Id.ToString() + " status: " + ($myAction.Status))
	}
}



 $ClientWebSocket.CloseAsync(WebSocketCloseStatus.NormalClosure, "Close response received", CancellationToken.None);


 # sort out
Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1"



## SlackBot.psm1
Export-ModuleMember -Function dwadwad
Export-ModuleMember -Variable dwadwadd
Export-ModuleMember -Function Get-MyUptime -Alias *
##




[CmdletBinding()]
    param(
        # Specifies a path to one or more locations. Wildcards are permitted.
        [Parameter(Mandatory=$false,
                   Position=0,
                   ParameterSetName="Path",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Path to one or more locations.")]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]
        $Path = [string[]]("$Env:Homedrive\$Env:HomePath\.vscode\extensions\*\snippets\*.json",'C:\Program Files (x86)\Microsoft VS Code\resources\app\extensions\*\snippet*\*.json')
        
)

[cmdletbinding()]
    Param(
        [string]$Token = (Import-Clixml "$PSscriptPath\..\Token.xml"),
        [string]$LogPath = "$Env:USERPROFILE\Logs\SlackBot.log",
        [string]$PSSlackConfigPath = "$PSscriptPath\..\PSSlackConfig.xml"
    )