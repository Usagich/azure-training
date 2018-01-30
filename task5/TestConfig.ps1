Configuration TestConfig
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node 'task5webserver'
    {
        WindowsFeature IIS
        {
            Ensure = "Present"
            Name = "Web-Server"
            IncludeAllSubFeature = $true
        }
    }

    Node 'task5nwebserver'
    {
        WindowsFeature IIS
        {
            Ensure = "Absent"
            Name = "Web-Server"
        }
    }
}