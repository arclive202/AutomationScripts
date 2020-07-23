#Get-Process | Select-String "chrome"



$NetCounters = (get-counter -list "Network Interface").paths

Get-Counter -Counter $NetCounters