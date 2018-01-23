Configuration IISInstallConfiguration
{
    param
    (
        [string]$Port = "8080",
		[string[]]$ComputerName	= "localhost"

    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

	Node $ComputerName
	{
        WindowsFeature WebServerRole
        {
            Name = "Web-Server"
            Ensure = "Present"
        }
        WindowsFeature ASP
        {
            Ensure = "Present"
            Name = "Web-Asp-Net45"
            DependsOn = "[WindowsFeature]WebServerRole"
        }
	    Script BindingPort 
		{
            GetScript = { return @{ 'Result' = "Binding port ${Port}" } }
            TestScript = { return $false }
            SetScript = { C:\Windows\System32\inetsrv\appcmd.exe set SITE "Default Web Site" /bindings:http/*:${Port}: }
            DependsOn = "[WindowsFeature]ASP"
		}
        Script OpeningPort
		{
            GetScript = { return @{ 'Result' = "Opening port ${Port}" } }
            TestScript = { return $false }
            SetScript = { netsh advfirewall firewall add rule name="Zoo TCP Port ${Port}" dir=in action=allow protocol=TCP localport=${Port} }
            DependsOn = "[Script]BindingPort"
		}
        

	}
}