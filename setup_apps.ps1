# ==========================================
# SCRIPT INSTALASI APLIKASI & KONFIGURASI AI
# (ARCHITECTURE: C:\GodMode - ONE FOR ALL)
# ==========================================

$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# Bikin markas besar yang kebal dari aturan Windows
$godMode = "C:\GodMode"
if (-not (Test-Path $godMode)) { New-Item -ItemType Directory -Force -Path $godMode | Out-Null }

# Tembak Full Control buat markas besar ini biar lu bebas masukin apapun
icacls $godMode /grant "Everyone:(OI)(CI)F" /T /Q | Out-Null

Write-Host "=== Memulai Instalasi di C:\GodMode ==="

# 1. NPM GLOBAL PREFIX -> MASUKIN KE GODMODE
try {
    $npmPath = "$godMode\npm"
    if (-not (Test-Path $npmPath)) { New-Item -ItemType Directory -Force -Path $npmPath | Out-Null }
    npm config set prefix $npmPath --global
    Write-Host "[v] NPM Global dipindah ke C:\GodMode\npm"
} catch {}

# 2. OLLAMA CLI -> MASUKIN KE GODMODE
try {
    Write-Host "[>] Setup Ollama CLI..."
    $ollamaZipPath = Join-Path $env:TEMP "ollama.zip"
    Invoke-WebRequest -Uri "https://ollama.com/download/ollama-windows-amd64.zip" -OutFile $ollamaZipPath -UseBasicParsing
    Expand-Archive -Path $ollamaZipPath -DestinationPath "$godMode\Ollama" -Force
    Write-Host "[v] Ollama CLI siap di C:\GodMode\Ollama"
} catch {}

# 3. CLAUDE CODE CLI
try {
    npm install -g @anthropic-ai/claude-code --no-progress --fund=false --audit=false | Out-Null
} catch {}

# 4. CHOCOLATEY APPS
try {
    Write-Host "[>] Menginstall Discord, Spotify, VS Code..."
    choco install discord spotify vscode -y --ignore-checksums --no-progress
} catch {}

# 5. WINGET APPS
try { 
    winget install --id Google.Antigravity --machine --source winget --accept-source-agreements --accept-package-agreements --silent 
    winget install JanDeDobbeleer.OhMyPosh --machine -s winget --accept-source-agreements --accept-package-agreements --silent
} catch {}

# 6. OPENCODE DESKTOP
try {
    $opencodePath = Join-Path $env:TEMP "opencode-setup.exe"
    Invoke-WebRequest -Uri "https://opencode.ai/download/stable/windows-x64-nsis" -OutFile $opencodePath -UseBasicParsing
    Start-Process $opencodePath -ArgumentList "/S" -Wait
} catch {}

# 7. HERMES AGENT CLI (DENGAN FIX "SELECT AN APP")
try {
    Write-Host "[>] Menginstall Hermes Agent CLI..."
    $env:CI = "true"
    $env:NPM_CONFIG_PROGRESS = "false"
    Invoke-Expression (Invoke-RestMethod "https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.ps1")
    
    # PINDAHIN HERMES DARI RUNNERADMIN KE GODMODE BIAR LU BISA PAKE
    $hermesAsli = "C:\Users\runneradmin\AppData\Local\Hermes"
    $hermesGodMode = "$godMode\Hermes"
    if (Test-Path $hermesAsli) {
        Copy-Item -Path $hermesAsli -Destination $hermesGodMode -Recurse -Force
        
        # BIKIN WRAPPER (.CMD) BIAR WINDOWS NGERTI CARA JALANIN HERMES
        $cmdWrapper = "$hermesGodMode\hermes-agent\hermes.cmd"
        $scriptIsi = "@echo off`npython `"$hermesGodMode\hermes-agent\hermes`" %*"
        Set-Content -Path $cmdWrapper -Value $scriptIsi -Encoding UTF8
        Write-Host "[v] Hermes Agent Fix dibuat di C:\GodMode\Hermes"
    }

    # BUKA HERMES DESKTOP
    $hermesRel = Invoke-RestMethod -Uri "https://api.github.com/repos/fathah/hermes-desktop/releases/latest"
    $hermesAsset = $hermesRel.assets | Where-Object { $_.name -match '\.exe$' } | Select-Object -First 1
    if ($hermesAsset) {
        $hermesDesktopPath = Join-Path $env:TEMP "hermes-desktop-setup.exe"
        Invoke-WebRequest -Uri $hermesAsset.browser_download_url -OutFile $hermesDesktopPath -UseBasicParsing
        Start-Process $hermesDesktopPath -ArgumentList "/S" 
        Start-Sleep -Seconds 10
    }
} catch {}

# 8. DASHBOARD REPO -> MASUKIN KE GODMODE
try {
    if ($env:GH_PAT -and $env:GH_USERNAME) {
        $desktopPath = "$godMode\nelsen-dashboard"
        git clone -q "https://$($env:GH_USERNAME):$($env:GH_PAT)@github.com/nerusen/nelsen-dashboard.git" $desktopPath
        Set-Location $desktopPath
        git config user.name "$env:GH_USERNAME"
        git config user.email "$env:GH_USERNAME@users.noreply.github.com"
        Write-Host "[v] Dashboard sukses diclone ke C:\GodMode"
    }
} catch {}

Write-Host "`n=== FINALISASI GOD MODE (PATH & PERMISSION) ==="

# 9. SET SYSTEM PATH LANGSUNG KE ENGINE WINDOWS (Fix Ollama ga ketemu)
try {
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    
    $pathsToAdd = @(
        "C:\GodMode\npm", 
        "C:\GodMode\Ollama", 
        "C:\GodMode\Hermes\hermes-agent",
        "C:\Program Files\oh-my-posh\bin"
    )
    
    foreach ($p in $pathsToAdd) { 
        if ($currentPath -notlike "*$p*") { $currentPath = "$currentPath;$p" }
    }
    
    # Pake cara ini biar Windows langsung ngebroadcast PATH baru ke semua User
    [Environment]::SetEnvironmentVariable("Path", $currentPath, "Machine")
    Write-Host "[v] System PATH berhasil di-set secara Global Mutlak!"
} catch {}

# 10. KUMPULIN SEMUA SHORTCUT KE FOLDER PUBLIC
try {
    $publicDesktop = "C:\Users\Public\Desktop"
    $runnerDesktop = "C:\Users\runneradmin\Desktop"
    
    if (Test-Path $runnerDesktop) {
        Get-ChildItem -Path $runnerDesktop -Include *.lnk, *.url -Recurse -ErrorAction SilentlyContinue | 
        Copy-Item -Destination $publicDesktop -Force -ErrorAction SilentlyContinue
    }
    
    # Bikin shortcut C:\GodMode ke desktop biar lu gampang ngaksesnya
    $wshShell = New-Object -ComObject WScript.Shell
    $shortcut = $wshShell.CreateShortcut("$publicDesktop\GOD_MODE.lnk")
    $shortcut.TargetPath = "C:\GodMode"
    $shortcut.Save()
} catch {}

Write-Host "=== SETUP SELESAI, WELCOME TO GOD MODE! ==="
exit 0
