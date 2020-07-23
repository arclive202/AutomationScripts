#----------------UNZIP FUNCTION---------------------------------------------------------------------
 # A zipped file and a desired output path are passed as the parametes to the function
# which upon execution unzips the file.
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}
#------------------------------------Check ZIP----------------------------------------------------
#this function is used to return either truw or false up on the basis of checking if
#file name passed as the parameter is a zipped file or not.
function checkZIP
{
    param([string]$fp)

    $isZ = $false
    try {
                $stream = New-Object System.IO.StreamReader -ArgumentList @($filePath)
                $reader = New-Object System.IO.BinaryReader -ArgumentList @($stream.BaseStream)
                $bytes = $reader.ReadBytes(4)
                if ($bytes.Length -eq 4) {
                    if ($bytes[0] -eq 80 -and
                        $bytes[1] -eq 75 -and
                        $bytes[2] -eq 3 -and
                        $bytes[3] -eq 4) {
                        $isZ = $true
                    }
                }
            }
            finally {
                if ($reader) {
                    $reader.Dispose()
                }
                if ($stream) {
                    $stream.Dispose()
                }
            }


            return $isZ
}

#-------------------Checking the directory-------------------------------------
$path = "C:\CodeDeployments\" 

Get-ChildItem -Path $path | Export-Csv -Path .\temp1.csv -NoTypeInformation 

$csv=Import-CSV "temp1.csv"


Foreach ($element in $csv)
{

    write-host "Name = "$element.Name
    $filepath = $path + $element.Name 
     $isZip = checkZip $filepath
      Write-Host $isZip
            if($isZip)
            {
               Unzip $filepath $path
               $filename = [System.IO.Path]::GetFileNameWithoutExtension($element.Name)
               $patchpath = $path + $filename 
               Get-ChildItem -Path $patchpath | Export-Csv -Path .\temp2.csv -NoTypeInformation 
               $csv1=Import-CSV "temp2.csv"
               foreach ($ele in $csv1)
               {
                    if($ele.Name -eq "SSDE")
                    {
                        Write-Host "Will be executing SSDE"
                    }
                    elseif($ele.Name -eq "SSIS")
                    {
                        Write-Host "Will be executing SSIS"
                    }
                    elseif($ele.Name -eq "SSAS")
                    {
                        Write-Host "Will be executing SSAS"
                    }
                    elseif($ele.Name -eq "SSRS")
                    {
                        Write-Host "Will be executing SSRS"
                    }
               }
               # The below two lines of code is used for moving the zipped file and the extracted folder after the supposed deployment is completed.
               Move-Item -Path $patchpath -Destination "C:\DeploymentArchive"
               Move-Item -Path $element.Name -Destination "C:\DeploymentArchive"
            }

}
