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

foreach ($server in $servers)
{
    #function call to the custom function created to generated drive info for the particular drives in that server.
    Set-Location -Path C:
    $time = get-date -f 'yyyy/MM/dd HH:mm:ss'



    # Processor utilization
    $Processor = (Get-WmiObject -ComputerName $server -Class win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average
        
    # Memory utilization
    $ComputerMemory = Get-WmiObject -ComputerName $server -Class win32_operatingsystem -ErrorAction Stop
    $Memory = ((($ComputerMemory.TotalVisibleMemorySize - $ComputerMemory.FreePhysicalMemory)*100)/ $ComputerMemory.TotalVisibleMemorySize)
    $RoundMemory = [math]::Round($Memory, 2)
   $line = $time + "," + $Processor + "," + $RoundMemory + ","
   Write-Output $line | Out-File "C:\HealthCheck\ServerSpec\ServerSpecs.csv" -append 
   echo $line      
}

