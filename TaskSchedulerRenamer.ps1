#renaming task scheduler


function Rename-TaskScheduler
{
    param
    (
        [Parameter(Mandatory=$true)][string]$oldtaskname,
        [Parameter(Mandatory=$true)][string]$newtaskname
        #[Parameter(Mandatory=$false)][string]$path = ""
        
    )
    $oldtaskpath = "C:\Windows\System32\Tasks\" + $oldtaskname
    $newtaskpath = "C:\Windows\System32\Tasks\" + $newtaskname
    schtasks /Create /tn $newtaskname /xml $oldtaskpath

    schtasks /delete /tn $oldtaskname /f


}

Rename-TaskScheduler