param([array]$servers='localhost')

#$c = Get-Credential

<#
.Synopsis
   Gets Disk Space of the given remote computer name
.DESCRIPTION
   Get-RemoteDiskInfo cmdlet gets the used, free and total space with the drive name.
.EXAMPLE
   Get-RemoteDiskInfo -RemoteComputerName "abc.contoso.com"
   Drive    UsedSpace(in GB)    FreeSpace(in GB)    TotalSpace(in GB)
   C        75                  52                  127
   D        28                  372                 400

.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Get-RemoteDiskInfo
{
    
    Param
    (
        $RemoteComputerName
    )

    Begin
    {
        $output="Drive `t UsedSpace(in GB) `t FreeSpace(in GB) `t TotalSpace(in GB) `n"
    }
    Process
    {
        #creating an array to store the name of the drives.
        $drives=Get-WmiObject Win32_LogicalDisk -ComputerName $RemoteComputerName
        
        #loop through each drive for finding out the details
        foreach ($drive in $drives){
            
            $drivename=$drive.DeviceID
            $freespace=[int]($drive.FreeSpace/1GB)
            $totalspace=[int]($drive.Size/1GB)
            $usedspace=$totalspace - $freespace
            $output=$output+$drivename+"`t"+$usedspace+"`t"+$freespace+"`t"+$totalspace+"`n"
        }
    }
    End
    {
        return $output
    }
}

#Specify servers in an array variable
#[array]$servers = #input server names.
#Step through each server in the array and perform an IISRESET
#Also show IIS service status after the reset has completed
foreach ($server in $servers)
{
    Write-Output "================================================== $server ==================================================" | Out-File "C:HealthCheck\DiskSpace.csv" -append       
    #function call to the custom function created to generated drive info for the particular drives in that server.
    Write-Output "`n`n   DISK USAGE: " | Out-File "C:HealthCheck\DiskSpace.csv" -append       
    Get-RemoteDiskInfo $server | Out-File "C:HealthCheck\DiskSpace.csv" -Append

    
    # Processor utilization
    $Processor = (Get-WmiObject -ComputerName $server -Class win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average
    Write-Output "`n   CPU UTILIZATION:`t`t" $Processor | Out-File "C:HealthCheck\DiskSpace.csv" -append       
        
    # Memory utilization
    $ComputerMemory = Get-WmiObject -ComputerName $server -Class win32_operatingsystem -ErrorAction Stop
    $Memory = ((($ComputerMemory.TotalVisibleMemorySize - $ComputerMemory.FreePhysicalMemory)*100)/ $ComputerMemory.TotalVisibleMemorySize)
    $RoundMemory = [math]::Round($Memory, 2)
    Write-Output "`n   MEMORY UTILIZATION:`t`t" $RoundMemory "`n`n"| Out-File "C:HealthCheck\DiskSpace.csv" -append       

    #$test = Write-Output "NewFile test."


    #Server Uptime
     $wmi = gwmi Win32_OperatingSystem -computer localhost
     $LBTime = $wmi.ConvertToDateTime($wmi.Lastbootuptime) 
     Write-Output "`n   SERVER UPTIME:`t`t" $LBTime"`n`n"| Out-File "C:HealthCheck\DiskSpace.csv" -append       

#Logged in users
     $usernames = query user 
     Write-Output "`n   LOGGED ON USER STATUS: `n" $usernames | Out-File "C:HealthCheck\DiskSpace.csv" -append  
            
}

#$tempuser = $c.UserName
Copy-Item -Path C:HealthCheck\DiskSpace.csv -Destination "C:\HealthCheck\HealthReports\SanityCheck_$(get-date -f yyyy-MM-dd_HH-mm-ss).csv"
Remove-Item -Path C:HealthCheck\DiskSpace.csv

$limit = (Get-Date).AddDays(-15)
$path = "C:\HealthCheck\HealthReports"

# Delete files older than the $limit.
Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item
