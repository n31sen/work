# ==========================================
# PENGINSTALAN APP BERSIH & DYNAMIC SHORTCUTS
# ==========================================

$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

Set-ExecutionPolicy Bypass -Scope LocalMachine -Force

Write-Host "=== Membuka Kunci Akses (God Mode) ==="
icacls "C:\Users\runneradmin" /grant "Everyone:(OI)(CI)F" /T /C /Q 2>&1 | Out-Null
icacls "C:\Program Files" /grant "Everyone:(OI)(CI)F" /T /C /Q 2>&1 | Out-Null
icacls "C:\ProgramData" /grant "Everyone:(OI)(CI)F" /T /C /Q 2>&1 | Out-Null
Write-Host "[v] Akses tanpa batas diizinkan."

Write-Host "`n=== Menginstall Aplikasi Utama ==="
# VS Code & Antigravity (Winget lebih stabil buat pasang di Program Files)
try {
    winget install --id Microsoft.VisualStudioCode --machine --accept-source-agreements --accept-package-agreements --silent
    winget install --id Google.Antigravity --machine --accept-source-agreements --accept-package-agreements --silent
} catch {}

# Discord, Spotify, NodeJS (Choco)
try { choco install nodejs discord spotify -y --ignore-checksums --no-progress } catch {}


Write-Host "`n=== Membuat Shortcut Cerdas (Otomatis Nyari Jalur .exe) ==="
try {
    $publicDesktop = "C:\Users\Public\Desktop"
    $wshShell = New-Object -ComObject WScript.Shell
    
    # 1. VS Code (Cari di Program Files ATAU AppData)
    $vscodeExe = Get-ChildItem -Path "C:\Program Files", "C:\Users\runneradmin\AppData" -Filter "Code.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($vscodeExe) {
        $sc = $wshShell.CreateShortcut("$publicDesktop\Visual Studio Code.lnk")
        $sc.TargetPath = $vscodeExe.FullName
        $sc.Save()
    }

    # 2. Discord (Cari Update.exe atau Discord.exe yang asli)
    $discordExe = Get-ChildItem -Path "C:\Users\runneradmin\AppData" -Filter "Update.exe" -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.DirectoryName -match "Discord"} | Select-Object -First 1
    if ($discordExe) {
        $sc = $wshShell.CreateShortcut("$publicDesktop\Discord.lnk")
        $sc.TargetPath = $discordExe.FullName
        $sc.Arguments = "--processStart Discord.exe"
        $sc.IconLocation = "$($discordExe.DirectoryName)\app.ico"
        $sc.Save()
    }

    # 3. Spotify (Cari Spotify.exe yang asli, bukan pajangan Choco)
    $spotifyExe = Get-ChildItem -Path "C:\Users\runneradmin\AppData" -Filter "Spotify.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($spotifyExe) {
        $sc = $wshShell.CreateShortcut("$publicDesktop\Spotify.lnk")
        $sc.TargetPath = $spotifyExe.FullName
        $sc.Save()
    }

    # Bersihin desktop dari shortcut ampas bawaan instalasi
    Remove-Item "C:\Users\runneradmin\Desktop\*.lnk" -Force -ErrorAction SilentlyContinue
    Write-Host "[v] Shortcut bersih dan akurat berhasil dibuat!"
} catch { Write-Warning "Gagal membuat shortcut." }

Write-Host "=== SETUP BERSIH SELESAI! ==="
exit 0
