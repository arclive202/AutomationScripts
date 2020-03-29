

$cred = Get-Credential
$username = $cred.UserName
$pswd = $cred.Password
$ConnString = "Data Source=10.255.130.93;Initial Catalog=QAR_CGI_PRODUCTION;User Id= {0}; Password = {1}; Trusted_Connection=True;" -f $username,$pswd
$SqlConn = New-Object System.Data.SqlClient.SqlConnection
$SqlConn.ConnectionString = $ConnString


$SqlCmdString = "select status,count(*) DocumentCrawler from [QAR_CGI_PRODUCTION].lists.QARlistforDocumentcrawl with(nolock) group by status"
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