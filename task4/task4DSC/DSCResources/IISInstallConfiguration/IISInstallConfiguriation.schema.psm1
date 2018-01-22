Configuration IISInstallConfiguration
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    WindowsFeature WebServerRole
    {
      Name = "Web-Server"
      Ensure = "Present"
    }
    #WindowsFeature WebWebServerRole
    #{
    #  Name = "Web-WebServer"
    #  Ensure = "Present"
    #  DependsOn = "[WindowsFeature]WebServerRole"
    #}
    #WindowsFeature WebCommonHttp
    #{
    #  Name = "Web-Common-Http"
    #  Ensure = "Present"
    #  DependsOn = "[WindowsFeature]WebWebServerRole"
    #}
    WindowsFeature ASP
    {
      Ensure = "Present"
      Name = "Web-Asp-Net45"
    }
    #WindowsFeature WebServerManagementConsole
    #{
    #    Name = "Web-Mgmt-Console"
    #    Ensure = "Present"
    #}
}