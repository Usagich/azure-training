Set-StrictMode -Version 'Latest'

Configuration IISInstallConfiguration
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Absent", "Present")]$Ensure

    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    WindowsFeature WebServerRole
    {
      Name = "Web-Server"
      Ensure = "Present"
    }
    WindowsFeature ASP
    {
      Ensure = "Present"
      Name = "Web-Asp-Net45"
    }

}