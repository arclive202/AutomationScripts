

$cred = Get-Credential
$username = $cred.UserName
$pswd = $cred.Password
$ConnString = "Connection String to Database" -f $username,$pswd
$SqlConn = New-Object System.Data.SqlClient.SqlConnection
$SqlConn.ConnectionString = $ConnString


$SqlCmdString = "Query to be executed"
$SqlCmdTimeout = 120

$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
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
