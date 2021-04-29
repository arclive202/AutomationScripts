$username = "EUROPE\ITS-APP-IMAPP-S"
$password =  ConvertTo-SecureString "Fq15sLCxTK513XY" -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
$cred.Password.MakeReadOnly()
$sqlCred = New-Object System.Data.SqlClient.SqlCredential($cred.username,$cred.password)


$ConnString = "Data Source=10.255.130.90;Initial Catalog=QAR_CGI_APP_CONFIG_PROD;Trusted_Connection=False;"
$SqlConn = New-Object System.Data.SqlClient.SqlConnection
$SqlConn.ConnectionString = $ConnString
$SqlConn.Credential = $sqlCred


$SqlCmdString = "select ConnectionString from [QAR_CGI_APP_CONFIG_PROD].[Configuration].[QARDBConfiguration]with(nolock) where DBType = 'Crawl' and ContainsItemData = 0"
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
$value = $dataset.Tables[0] # -split ";" #| Export-Csv "C:\testquery\DocumentCrawler.CSV" -NoTypeInformation

foreach ($val in $value)
{
    $StrVal1 =  $val.ConnectionString -split '"'
    $Strval = $StrVal1[1] -split "True;"
    $ConnString =  $StrVal[0] + "False;Integrated Security=True"
    }

$ConnString

$SqlConn.ConnectionString = $ConnString
$SqlConn.Credential = $sqlCred


$SqlCmdString = "select status, count(*) DocumentCrawl, getdate() as ObservationTime from [QAR_CGI_PRODUCTION].lists.QARlistforDocumentcrawl with(nolock) group by status"
$SqlCmdTimeout = 120

$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
#$SqlCmd.CommandType = [System.Data.CommandType]::StoredProcedure
$SqlCmd.CommandText = $SqlCmdString
$SqlCmd.CommandTimeout = $SqlCmdTimeout
$SqlCmd.Connection = $ConnString


#temptable = New-Object System.Data.DataTable

$SqlConn.Open()
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter $SqlCmd
$dataset1 = New-Object System.Data.DataSet
Write-Output $adapter.Fill($dataset1) 
$SqlConn.close()
Write-Output $dataset1.Tables[0] #| Export-Csv "C:\testquery\DocumentCrawler.CSV" -NoTypeInformation
foreach ($Row in $dataset1.Tables[0].Rows)
        { 
          write-host "$($Row[0]) "
          exit 1
        }

