# ==========================================
# PENGINSTALAN APP BERSIH & ANTI-STUCK
# ==========================================

$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

Set-ExecutionPolicy Bypass -Scope LocalMachine -Force

Write-Host "=== Membuka Kunci Akses (Super Admin) ==="
# Matikan UAC (User Account Control) Windows. 
# Ini bikin akun lu jadi kebal dan bisa ngakses semua folder/install manual tanpa diblokir!
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0 -Force

# Kasih izin tipis-tipis aja tanpa sapu jagat rekursif (/T) biar GAK STUCK!
icacls "C:\Users\runneradmin\AppData\Local" /grant "Everyone:(OI)(CI)F" /C /Q 2>&1 | Out-Null
icacls "C:\Users\runneradmin\AppData\Roaming" /grant "Everyone:(OI)(CI)F" /C /Q 2>&1 | Out-Null
Write-Host "[v] UAC Dimatikan, Akses Dewa diaktifkan!"

Write-Host "`n=== Menginstall Aplikasi Utama ==="
# VS Code & Antigravity via Winget
try {
    winget install --id Microsoft.VisualStudioCode --machine --accept-source-agreements --accept-package-agreements --silent
    winget install --id Google.Antigravity --machine --accept-source-agreements --accept-package-agreements --silent
} catch {}

# Discord, Spotify, NodeJS via Choco
try { choco install nodejs discord spotify -y --ignore-checksums --no-progress } catch {}


Write-Host "`n=== Membuat Shortcut Cerdas (Otomatis Nyari Jalur .exe) ==="
try {
    $publicDesktop = "C:\Users\Public\Desktop"
    $wshShell = New-Object -ComObject WScript.Shell
    
    # Cari VS Code (Dikasih Depth biar nyarinya cepet dan ga stuck)
    $vscodeExe = Get-ChildItem -Path "C:\Program Files", "C:\Users\runneradmin\AppData" -Filter "Code.exe" -Recurse -Depth 5 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($vscodeExe) {
        $sc = $wshShell.CreateShortcut("$publicDesktop\Visual Studio Code.lnk")
        $sc.TargetPath = $vscodeExe.FullName
        $sc.Save()
    }

    # Cari Discord
    $discordExe = Get-ChildItem -Path "C:\Users\runneradmin\AppData" -Filter "Update.exe" -Recurse -Depth 5 -ErrorAction SilentlyContinue | Where-Object {$_.DirectoryName -match "Discord"} | Select-Object -First 1
    if ($discordExe) {
        $sc = $wshShell.CreateShortcut("$publicDesktop\Discord.lnk")
        $sc.TargetPath = $discordExe.FullName
        $sc.Arguments = "--processStart Discord.exe"
        $sc.IconLocation = "$($discordExe.DirectoryName)\app.ico"
        $sc.Save()
    }

    # Cari Spotify
    $spotifyExe = Get-ChildItem -Path "C:\Users\runneradmin\AppData" -Filter "Spotify.exe" -Recurse -Depth 5 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($spotifyExe) {
        $sc = $wshShell.CreateShortcut("$publicDesktop\Spotify.lnk")
        $sc.TargetPath = $spotifyExe.FullName
        $sc.Save()
    }

    # Bersihin desktop ampas
    Remove-Item "C:\Users\runneradmin\Desktop\*.lnk" -Force -ErrorAction SilentlyContinue
    Write-Host "[v] Shortcut bersih dan akurat berhasil dibuat!"
} catch { Write-Warning "Gagal membuat shortcut." }

Write-Host "=== SETUP BERSIH SELESAI! ==="
exit 0
