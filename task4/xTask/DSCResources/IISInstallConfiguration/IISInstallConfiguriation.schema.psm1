Set-StrictMode -Version 'Latest'

Configuration xTaskCompo
{
    [CmdletBinding()]
    param(
 	    [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
    
 	    [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FileName,

 	    [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FileContent
    )
    
    Import-DscResource -ModuleName 'PsDesiredStateConfiguration'
    
    File FileContent 
    {
        Ensure = "Present"
        DestinationPath = $Path + $FileName
        Contents = $FileContent
        Type = "File"
    }
}
