$log = 'C:\Users\PERSONAL\Archivos\_registro\formateo-disco-externo.txt'
try {
  $d = @(Get-Disk | Where-Object { $_.BusType -eq 'USB' -and $_.FriendlyName -match 'RTL9210' -and $_.Size -gt 200GB -and $_.Size -lt 300GB -and -not $_.IsBoot -and -not $_.IsSystem })
  if ($d.Count -ne 1) { "ABORTADO: no se encontro exactamente un disco USB RTL9210 de ~238 GB (encontrados: $($d.Count))" | Out-File $log -Encoding utf8; exit }
  $n = $d[0].Number
  Clear-Disk -Number $n -RemoveData -RemoveOEM -Confirm:$false -ErrorAction Stop
  Initialize-Disk -Number $n -PartitionStyle GPT -ErrorAction SilentlyContinue
  New-Partition -DiskNumber $n -UseMaximumSize -DriveLetter D -ErrorAction Stop | Format-Volume -FileSystem NTFS -NewFileSystemLabel 'Disco JP' -Confirm:$false -ErrorAction Stop | Out-Null
  $v = Get-Volume -DriveLetter D
  "OK: Disco $n formateado. Etiqueta: $($v.FileSystemLabel) | $([math]::Round($v.Size/1GB,1)) GB | libres $([math]::Round($v.SizeRemaining/1GB,1)) GB" | Out-File $log -Encoding utf8
} catch { "ERROR: $($_.Exception.Message)" | Out-File $log -Encoding utf8 }
