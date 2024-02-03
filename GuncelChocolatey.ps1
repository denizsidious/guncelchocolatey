
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Process "cmd.exe" -ArgumentList "/c start powershell -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    $choice = $null
    while ($choice -ne 'E' -and $choice -ne 'H') {
        $choice = Read-Host @"
Chocolatey yüklü değil. Chocolatey yüklemesine onay veriyor musunuz? (E/H)
"@
        $choice = $choice.ToUpper()
    }

    if ($choice -eq 'E') {
        Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        Write-Host "Chocolatey başarıyla yüklendi."
    } else {
        Write-Host "Chocolatey yükleme işlemi iptal edildi."
        exit
    }
} else {
    Write-Host "`nChocolatey tespit edildi, devam ediliyor..."
}

@"

░█████╗░░█████╗░███████╗
██╔══██╗██╔══██╗╚════██║
██║░░██║██║░░██║░░░░██╔╝
██║░░██║██║░░██║░░░██╔╝░
╚█████╔╝╚█████╔╝░░░██║░░
░╚════╝░░╚════╝░░░░╚═╝░░

"@

$scriptContent = @"
Write-Host "Chocolatey paketleri güncelleniyor..."
choco upgrade all -y | Out-Null
Write-Host "Chocolatey paketleri güncellendi."
"@

$scriptPath = Join-Path $env:TEMP "ChocolateyGuncelleme.ps1"
$scriptContent | Out-File -FilePath $scriptPath -Encoding utf8

$shortcutPath = [System.IO.Path]::Combine($env:APPDATA, 'Microsoft\Windows\Start Menu\Programs\Startup\ChocolateyGuncelleme.lnk')
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = 'powershell.exe'
$shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
$shortcut.WorkingDirectory = $env:TEMP # Scriptin çalışacağı dizini ayarla
$shortcut.Save()

Write-Host "`nChocolateyGuncelleme scripti başlangıçta otomatik olarak sessiz olarak çalışacak şekilde ayarlandı." -ForegroundColor Green
Write-Host "`nÇıkış yapmak için herhangi bir tuşa basın..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
