Configuration TestConfig
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "task5WebServer"
    {
        WindowsFeature IIS
        {
            Ensure = "Present"
            Name = "Web-Server"
            IncludeAllSubFeature = $true
        }
    }

    Node "task5NWebServer"
    {
        WindowsFeature IIS
        {
            Ensure = "Absent"
            Name = "Web-Server"
        }
    }
}