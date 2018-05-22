Add-Type -AssemblyName System.IO.Compression.FileSystem

# ----------------------FUNCIONES---------------------- #
function Execute-Sql {
	param([string]$file)
	Write-Host "`n constructing backup from BackUp_DataBase_Ligera_Clubes.sql"
    Invoke-SqlCmd -InputFile $file -ServerInstance ".\SQL2012" -QueryTimeout 7200
	Write-Host "`n Success!"
}

function Zip {
	param([string]$name)
	set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"
	Write-Host "`n Compressioning backup:"
	sz a -tzip $name "C:\ZeusDataBackUp"
	Write-Host "`n success!"
}

function Copy-Backup {
    param([string]$fromPath, [parameter(Mandatory)][ValidateScript({Test-Path $_})][string]$toPath)
	Write-Host "`n About to copy $fromPath file to $toPath directory..."
	Copy-Item -Path $fromPath -Destination $toPath
	Write-Host "`n Success!"
    Write-Host "`n Now removing local $date.zip file"
	Remove-Item "C:\$date.zip"
    Write-Host "`n Success"
}

function Remove-FilesCreatedBeforeDate([parameter(Mandatory)][ValidateScript({Test-Path $_})][string] $Path, [parameter(Mandatory)][DateTime] $DateTime, [switch] $DeletePathIfEmpty, [switch] $OutputDeletedPaths, [switch] $WhatIf)
{
    Write-Host "`n Searching old backups to cleanup"
    Get-ChildItem -Path $Path -Recurse -Force -File -Include "*.zip" | Where-Object { $_.CreationTime -lt $DateTime } | 
		ForEach-Object { if ($OutputDeletedPaths) { Write-Output $_.FullName } Remove-Item -Path $_.FullName -Force -WhatIf:$WhatIf }
    Write-Host "`n Success!"
}

<#function self-Kill{

Get-Process | Where-Object { $_.Name -eq "powershell" } | Select-Object -First 1 | Stop-Process

}#>
# -------------------FIN DE FUNCIONES------------------ #

# Variables del sistema para realizar el backup
$date = Get-Date -Format d-MMMM-yyyy
$zipFileName = "C:\$date.zip" 
$server = "130.103.97.7"
$destination = "Microsoft.PowerShell.Core\FileSystem::\\zeus10\C$\Shared\BackupBases\$server"

# Ejecuta script SqlCmd
Execute-Sql "$PSScriptRoot\BackUp_DataBase_Ligera_Clubes.sql"

# Realiza compresión de archivos
Zip $zipFileName

#Realiza Copia del BackUp a la carpeta destino
Copy-Backup $zipFileName $destination

# Borrar archivos con 5 dÃƒÂ­as de antigüedad.
Remove-FilesCreatedBeforeDate -Path $destination -DateTime ((Get-Date).AddDays(-4))

# Terminar proceso powershell.exe
#self-Kill

<# Powershell.exe#>
<# add arguments -NoProfile -NoLogo -NonInteractive -ExecutionPolicy Bypass C:\DataBase-BackUp-V2.ps1#>
<# C:\ #>