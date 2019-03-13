#----------------UNZIP FUNCTION-----------------------------------------------
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}
#---------------Check ZIP----------------------------------------------------

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

#-------------------Normal Program-------------------------------------
$path = "C:\CBI Deployments\" 

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
                        Write-Host "Will be executing SSIE"
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
               Move-Item -Path $patchpath -Destination "C:\CBIArchive"
               Move-Item -Path $element.Name -Destination "C:\CBIArchive"
            }

}