# ==========================================
# PENGINSTALAN APP BERSIH & GOD MODE PERMISSION
# ==========================================

$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# Buka gerbang eksekusi biar bebas dari blokir policy Windows
Set-ExecutionPolicy Bypass -Scope LocalMachine -Force

Write-Host "=== Membuka Semua Kunci Akses (God Mode) ==="
# Buka akses FULL ke folder runneradmin biar user lu bisa buka Discord/Spotify dari sana
icacls "C:\Users\runneradmin" /grant "Everyone:(OI)(CI)F" /T /C /Q | Out-Null
icacls "C:\Program Files" /grant "Everyone:(OI)(CI)F" /T /C /Q | Out-Null
icacls "C:\ProgramData" /grant "Everyone:(OI)(CI)F" /T /C /Q | Out-Null
Write-Host "[v] Akses tanpa batas diizinkan."

Write-Host "`n=== Menginstall Aplikasi Utama ==="
# Install NodeJS (buat Claude), VS Code, Discord, Spotify via Chocolatey
try {
    choco install nodejs vscode discord spotify -y --ignore-checksums --no-progress
    Write-Host "[v] Choco Apps (VSCode, Discord, Spotify, Node) sukses."
} catch { Write-Warning "Ada aplikasi Choco yang gagal." }

# Install Antigravity via Winget
try {
    winget install --id Google.Antigravity --machine --source winget --accept-source-agreements --accept-package-agreements --silent
    Write-Host "[v] Antigravity sukses."
} catch { Write-Warning "Antigravity gagal." }

Write-Host "`n=== Membuat Hardcoded Shortcut (Anti-Blank) ==="
try {
    $publicDesktop = "C:\Users\Public\Desktop"
    $wshShell = New-Object -ComObject WScript.Shell
    
    # 1. Shortcut VS Code (Global)
    $scVSCode = $wshShell.CreateShortcut("$publicDesktop\Visual Studio Code.lnk")
    $scVSCode.TargetPath = "C:\Program Files\Microsoft VS Code\Code.exe"
    $scVSCode.Save()

    # 2. Shortcut Discord (Nembak ke AppData runneradmin)
    $scDiscord = $wshShell.CreateShortcut("$publicDesktop\Discord.lnk")
    $scDiscord.TargetPath = "C:\Users\runneradmin\AppData\Local\Discord\Update.exe"
    $scDiscord.Arguments = "--processStart Discord.exe"
    $scDiscord.IconLocation = "C:\Users\runneradmin\AppData\Local\Discord\app.ico"
    $scDiscord.Save()

    # 3. Shortcut Spotify (Nembak ke AppData runneradmin)
    $scSpotify = $wshShell.CreateShortcut("$publicDesktop\Spotify.lnk")
    $scSpotify.TargetPath = "C:\Users\runneradmin\AppData\Roaming\Spotify\Spotify.exe"
    $scSpotify.Save()
    
    # Hapus shortcut bawaan dari runneradmin biar ga dobel & blank
    $runnerDesktop = "C:\Users\runneradmin\Desktop"
    if (Test-Path $runnerDesktop) { Remove-Item "$runnerDesktop\*.lnk" -Force -ErrorAction SilentlyContinue }

    Write-Host "[v] Shortcut Desktop berhasil dibuat dengan jalur absolut!"
} catch { Write-Warning "Gagal membuat shortcut." }

Write-Host "=== SETUP BERSIH SELESAI! ==="
exit 0
