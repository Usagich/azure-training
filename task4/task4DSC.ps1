Configuration task4DSC
{
    Import-DscResource -ModuleName 'task4DSC'
        

    IISInstallConfiguration IIS
	{        
	   Ensure = "Present"
	}
}