param($minutes = 100)

$myshell = New-Object -com "Wscript.Shell"

for ($i = 0; $i -lt $minutes; $i++) {
  Start-Sleep -Seconds 60
  $myshell.sendkeys(".")
}





$username = "domain01\admin01"
$password =  ConvertTo-SecureString "P@ssW0rD!" -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential `
         -argumentlist $username, $password


........