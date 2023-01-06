$FileName = "windows-vm.rdp"
if (Test-Path $FileName) {
  Remove-Item $FileName
}
$PublicIp = terraform output -raw windows_public_ip
$EncryptedPassword = (terraform output -raw windows_password | ConvertTo-SecureString -AsPlainText -Force) | ConvertFrom-SecureString;
Add-Content -Path $FileName -Value "auto connect:i:1"
Add-Content -Path $FileName -Value "full address:s:$PublicIp"
Add-Content -Path $FileName -Value "username:s:Administrator"
Add-Content -Path $FileName -Value "password 51:b:$EncryptedPassword"
Add-Content -Path $FileName -Value "screen mode id:i:1"
Add-Content -Path $FileName -Value "use multimon:i:0"
Add-Content -Path $FileName -Value "desktopwidth:i:1280"
Add-Content -Path $FileName -Value "desktopheight:i:800"

$FileName = "windows-vm-nopw.rdp"
if (Test-Path $FileName) {
  Remove-Item $FileName
}

$EncryptedPassword = ("SuperSecretPassw0rd" | ConvertTo-SecureString -AsPlainText -Force) | ConvertFrom-SecureString;
Add-Content -Path $FileName -Value "auto connect:i:1"
Add-Content -Path $FileName -Value "full address:s:$PublicIp"
Add-Content -Path $FileName -Value "username:s:ccc\admin"
Add-Content -Path $FileName -Value "password 51:b:$EncryptedPassword"
Add-Content -Path $FileName -Value "screen mode id:i:1"
Add-Content -Path $FileName -Value "use multimon:i:0"
Add-Content -Path $FileName -Value "desktopwidth:i:1280"
Add-Content -Path $FileName -Value "desktopheight:i:800"

