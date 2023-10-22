$file = "C:\Windows\System32\drivers\etc\hosts"
$hostfile = Get-Content $file
$hostfile += "192.168.75.132        testpki.local	ca.testpki.local"
Set-Content -Path $file -Value $hostfile -Force