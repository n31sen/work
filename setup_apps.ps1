# ==========================================
# PENGINSTALAN APP BERSIH & FIXED ICONS
# ==========================================

$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

Set-ExecutionPolicy Bypass -Scope LocalMachine -Force

Write-Host "=== Membuka Kunci Akses (Super Admin) ==="
# Matikan UAC biar akun RDP lu dapet akses Dewa
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0 -Force

icacls "C:\Users\runneradmin\AppData\Local" /grant "Everyone:(OI)(CI)F" /C /Q 2>&1 | Out-Null
icacls "C:\Users\runneradmin\AppData\Roaming" /grant "Everyone:(OI)(CI)F" /C /Q 2>&1 | Out-Null
Write-Host "[v] UAC Dimatikan, Akses Dewa diaktifkan!"

Write-Host "`n=== Menginstall Aplikasi Utama ==="
# Antigravity pake Winget
try { winget install --id Google.Antigravity --machine --accept-source-agreements --accept-package-agreements --silent } catch {}

# VS Code, Discord, Spotify, NodeJS kita borong pake Choco biar pasti ke-install!
try { choco install nodejs vscode discord spotify -y --ignore-checksums --no-progress } catch {}


Write-Host "`n=== Membuat Shortcut Cerdas (Dengan Paksaan Icon) ==="
try {
    $publicDesktop = "C:\Users\Public\Desktop"
    $wshShell = New-Object -ComObject WScript.Shell
    
    # 1. Cari VS Code (Karena pake Choco, biasanya di Program Files)
    $vscodeExe = Get-ChildItem -Path "C:\Program Files", "C:\Users\runneradmin\AppData" -Filter "Code.exe" -Recurse -Depth 4 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($vscodeExe) {
        $sc = $wshShell.CreateShortcut("$publicDesktop\Visual Studio Code.lnk")
        $sc.TargetPath = $vscodeExe.FullName
        $sc.IconLocation = $vscodeExe.FullName # PAKSA ICON MUNCUL!
        $sc.Save()
    }

    # 2. Cari Discord
    $discordExe = Get-ChildItem -Path "C:\Users\runneradmin\AppData" -Filter "Update.exe" -Recurse -Depth 5 -ErrorAction SilentlyContinue | Where-Object {$_.DirectoryName -match "Discord"} | Select-Object -First 1
    if ($discordExe) {
        $sc = $wshShell.CreateShortcut("$publicDesktop\Discord.lnk")
        $sc.TargetPath = $discordExe.FullName
        $sc.Arguments = "--processStart Discord.exe"
        $sc.IconLocation = "$($discordExe.DirectoryName)\app.ico" # PAKSA ICON MUNCUL!
        $sc.Save()
    }

    # 3. Cari Spotify (Fokus ke AppData Roaming tempat aslinya)
    $spotifyExe = Get-ChildItem -Path "C:\Users\runneradmin\AppData\Roaming\Spotify" -Filter "Spotify.exe" -Recurse -Depth 3 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($spotifyExe) {
        $sc = $wshShell.CreateShortcut("$publicDesktop\Spotify.lnk")
        $sc.TargetPath = $spotifyExe.FullName
        $sc.IconLocation = $spotifyExe.FullName # PAKSA ICON MUNCUL!
        $sc.Save()
    }

    # Bersihin desktop ampas
    Remove-Item "C:\Users\runneradmin\Desktop\*.lnk" -Force -ErrorAction SilentlyContinue
    Write-Host "[v] Shortcut + Icon akurat berhasil dibuat!"
} catch { Write-Warning "Gagal membuat shortcut." }

Write-Host "=== SETUP BERSIH SELESAI! ==="
exit 0
