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
            GetScript = { return @{ 'Result' = "Binding port 8080" } }
            TestScript = { return $false }
            SetScript = { C:\Windows\System32\inetsrv\appcmd.exe set SITE "Default Web Site" /bindings:http/*:8080: }
            DependsOn = "[WindowsFeature]ASP"
		}
        Script OpeningPort
		{
            GetScript = { return @{ 'Result' = "Opening port 8080" } }
            TestScript = { return $false }
            SetScript = { netsh advfirewall firewall add rule name="Zoo TCP Port 8080" dir=in action=allow protocol=TCP localport=8080 }
            DependsOn = "[Script]BindingPort"
		}
        

	}
}