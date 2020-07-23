
#Get-WmiObject -List | Out-File  "C:\Users\aditya.roychoudhary\Desktop\SQLQuery\GetWmiList.txt" 
#get-command | Out-File  "C:\Users\aditya.roychoudhary\Desktop\SQLQuery\cmdletlist.txt"


############
#
#
#Get-WmiObject - Whenever we need to discover just about any information about a Windows computer and it's components,
#                we can do so with Get-WmiObject.
#
#
#
#
############


#Get-Help Get-WmiObject

$drives=Get-WmiObject -Class Win32_LogicalDisk -ComputerName "10.25.130.94"  -Credential $cred
#echo $drives
#like a dictionary


 #loop through each drive for finding out the details
        foreach ($drive in $drives){
            
            $drivename=$drive.DeviceID
            $freespace=[int]($drive.FreeSpace/1GB)
            $totalspace=[int]($drive.Size/1GB)
            $usedspace=$totalspace - $freespace
            
            $output=$output + $drivename + "`t" + $usedspace  +"`t"+$freespace+"`t"+$totalspace+"`n"

            
        }

        echo $output


#CPU percentage
$Processor = (Get-WmiObject -ComputerName "localhost" -Class win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average

#memory percentage
$ComputerMemory = Get-WmiObject -ComputerName "localhost" -Class win32_operatingsystem -ErrorAction Stop
$Memory = ((($ComputerMemory.TotalVisibleMemorySize - $ComputerMemory.FreePhysicalMemory)*100)/ $ComputerMemory.TotalVisibleMemorySize)
    
$RoundMemory = [math]::Round($Memory,2)


#COPY , REMOVE, CUSTOM FILE NAME
Copy-Item -Path C:HealthCheck\DiskSpace.csv -Destination "C:\HealthCheck\HealthReports\SanityCheck_$(get-date -f yyyy-MM-dd_HH-mm-ss).csv"
Remove-Item -Path C:HealthCheck\DiskSpace.csv

# Delete files older than the $limit.
Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item


###############################
#
#
#
# schtasks.exe - 
#
#
#
############################

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



#################################
#
#
#
# Database related queries
#
#
#
###########################



# CREATING A NEW CONNECTION WITH PARAMETERS
$cred = Get-Credential
$username = $cred.UserName
$pswd = $cred.Password
$ConnString = "Data Source=10.255.130.93;Initial Catalog=QAR_CGI_PRODUCTION;User Id= {0}; Password = {1}; Trusted_Connection=True;" -f $username,$pswd
$SqlConn = New-Object System.Data.SqlClient.SqlConnection
$SqlConn.ConnectionString = $ConnString

$SqlConn.ClientConnectionId

# KEEPING THE QUERY READY
$SqlCmdString = "select status,count(*) DocumentCrawler from [QAR_CGI_PRODUCTION].lists.QARlistforDocumentcrawl with(nolock) group by status"
$SqlCmdTimeout = 120


$SqlCmd = New-Object System.Data.SqlClient.SqlCommand #classes defined
#$SqlCmd.CommandType = [System.Data.CommandType]::StoredProcedure
$SqlCmd.CommandText = $SqlCmdString
$SqlCmd.CommandTimeout = $SqlCmdTimeout
$SqlCmd.Connection = $SqlConn

#temptable = New-Object System.Data.DataTable

$SqlConn.Open()
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter $SqlCmd
$dataset = New-Object System.Data.DataSet
Write-Output $adapter.Fill($dataset) 
$SqlConn.close()
$dataset.Tables[0] | Export-Csv "C:\testquery\DocumentCrawler.CSV" -NoTypeInformation



s