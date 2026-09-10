# ==========================================
# SCRIPT INSTALASI APLIKASI & KONFIGURASI AI
# (GOD MODE - Global Path & Full Access)
# ==========================================

$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"
$hardcoded9routerUrl = "https://9router.nelsen.web.id/v1"

# Buka gerbang eksekusi biar bebas dari blokir policy Windows
Set-ExecutionPolicy Bypass -Scope LocalMachine -Force

Write-Host "=== Memulai Konfigurasi Environment & CLI ==="

# 1. GIT & NPM GLOBAL CONFIG (Relokasi keluar dari AppData biar aman)
try {
    git config --system user.name "$env:GH_USERNAME"
    git config --system user.email "$env:GH_USERNAME@users.noreply.github.com"
    $globalNpmPath = "C:\ProgramData\npm"
    if (-not (Test-Path $globalNpmPath)) { New-Item -ItemType Directory -Force -Path $globalNpmPath | Out-Null }
    npm config set prefix $globalNpmPath --global
    Write-Host "[v] Git & NPM Global Configured"
} catch { Write-Warning "Gagal setting Git/NPM" }

# 2. OLLAMA CLI (Portable)
try {
    Write-Host "[>] Setup Ollama CLI..."
    $ollamaZipUrl = "https://ollama.com/download/ollama-windows-amd64.zip"
    $ollamaZipPath = Join-Path $env:TEMP "ollama.zip"
    Invoke-WebRequest -Uri $ollamaZipUrl -OutFile $ollamaZipPath -UseBasicParsing
    Expand-Archive -Path $ollamaZipPath -DestinationPath "C:\Program Files\Ollama" -Force
    Write-Host "[v] Ollama CLI sukses"
} catch { Write-Warning "Gagal install Ollama" }

# 3. CLAUDE CODE CLI (NPM)
try {
    Write-Host "[>] Setup Claude Code CLI..."
    npm install -g @anthropic-ai/claude-code --no-progress --fund=false --audit=false | Out-Null
    Write-Host "[v] Claude Code CLI sukses"
} catch { Write-Warning "Gagal install CLI berbasis NPM" }

# 4. ENVIRONMENT VARIABLES (9ROUTER)
try {
    [Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", $hardcoded9routerUrl, "Machine")
    [Environment]::SetEnvironmentVariable("OPENAI_BASE_URL", $hardcoded9routerUrl, "Machine")
    if ($env:CLAUDE_API_KEY) {
        [Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", $env:CLAUDE_API_KEY, "Machine")
        [Environment]::SetEnvironmentVariable("ANTHROPIC_AUTH_TOKEN", $env:CLAUDE_API_KEY, "Machine")
        [Environment]::SetEnvironmentVariable("OPENAI_API_KEY", $env:CLAUDE_API_KEY, "Machine")
    }
    Write-Host "[v] Environment Variables 9Router Terpasang"
} catch { Write-Warning "Gagal setting Env Var" }

# 5. AUTO-SETUP JSON CONFIG (Via Startup buat User Custom)
try {
    $startupFolder = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
    $initScriptPath = "$startupFolder\init_ai_configs.ps1"
    
    New-Item -ItemType File -Force -Path $initScriptPath | Out-Null
    # Gunakan RDP_USERNAME lu yang diset di env action
    Add-Content -Path $initScriptPath -Value "`$userProfile = `"C:\Users\$env:RDP_USERNAME`""
    Add-Content -Path $initScriptPath -Value "`$claudeDir = Join-Path `$userProfile '.claude'"
    Add-Content -Path $initScriptPath -Value "if (-not (Test-Path `$claudeDir)) { New-Item -ItemType Directory -Force -Path `$claudeDir }"
    Add-Content -Path $initScriptPath -Value "`$claudeJson = @{ env = @{ ANTHROPIC_BASE_URL = '$hardcoded9routerUrl' } }"
    Add-Content -Path $initScriptPath -Value "`$claudeJson | ConvertTo-Json -Depth 5 | Set-Content -Path (Join-Path `$claudeDir 'settings.json') -Encoding UTF8"
    Add-Content -Path $initScriptPath -Value "`$opencodeDirs = @( (Join-Path `$userProfile '.config\opencode'), (Join-Path `$userProfile '.opencode'), (Join-Path `$userProfile 'AppData\Roaming\opencode') )"
    Add-Content -Path $initScriptPath -Value "foreach (`$d in `$opencodeDirs) { if (-not (Test-Path `$d)) { New-Item -ItemType Directory -Force -Path `$d } }"
    Add-Content -Path $initScriptPath -Value "`$opencodeObj = @{ '`$schema' = 'https://opencode.ai/config.json'; provider = @{ '9router' = @{ npm = '@ai-sdk/openai'; name = '9router'; options = @{ baseURL = '$hardcoded9routerUrl'; apiKey = '$env:CLAUDE_API_KEY' }; models = @{ 'nelsen-up' = @{ name = 'nelsen-up' }; 'nelsen-over' = @{ name = 'nelsen-over' }; 'nelsen-vibe' = @{ name = 'nelsen-vibe' } } } }; model = '9router/nelsen-up' }"
    Add-Content -Path $initScriptPath -Value "`$opencodeJsonStr = `$opencodeObj | ConvertTo-Json -Depth 10"
    Add-Content -Path $initScriptPath -Value "foreach (`$d in `$opencodeDirs) { Set-Content -Path (Join-Path `$d 'config.json') -Value `$opencodeJsonStr -Encoding UTF8 }"
    Add-Content -Path $initScriptPath -Value "Remove-Item -Path `$PSCommandPath -Force"
    
    $wshShell = New-Object -ComObject WScript.Shell
    $shortcut = $wshShell.CreateShortcut("$startupFolder\InitAIConfigs.lnk")
    $shortcut.TargetPath = "powershell.exe"
    $shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$initScriptPath`""
    $shortcut.Save()
    Write-Host "[v] Auto-Config JSON Script Siap"
} catch { Write-Warning "Gagal membuat script auto-config JSON" }


Write-Host "`n=== Memulai Instalasi Aplikasi GUI & Tools ==="

# 6. CHOCOLATEY APPS (Discord, Spotify, VS Code)
try {
    Write-Host "[>] Menginstall Discord, Spotify, VS Code..."
    choco install discord spotify vscode -y --ignore-checksums --no-progress
    Write-Host "[v] Choco Apps selesai!"
} catch { Write-Warning "Ada aplikasi Choco yang gagal" }

# 7. WINGET APPS (Antigravity & Oh-My-Posh via Machine Scope)
try { 
    Write-Host "[>] Menginstall Antigravity..."
    winget install --id Google.Antigravity --machine --source winget --accept-source-agreements --accept-package-agreements --silent 
    Write-Host "[v] Antigravity sukses"
} catch { Write-Warning "Antigravity gagal" }

try {
    Write-Host "[>] Menginstall Oh-My-Posh..."
    winget install JanDeDobbeleer.OhMyPosh --machine -s winget --accept-source-agreements --accept-package-agreements --silent
    Write-Host "[v] Oh-My-Posh sukses"
    
    # Auto Inject Oh-My-Posh Theme ke PowerShell Profile
    $rdpProfileDir = "C:\Users\$env:RDP_USERNAME\Documents\PowerShell"
    if (-not (Test-Path $rdpProfileDir)) { New-Item -ItemType Directory -Force -Path $rdpProfileDir | Out-Null }
    $rdpPsProfile = Join-Path $rdpProfileDir "Microsoft.PowerShell_profile.ps1"
    
    $themeCmd = "oh-my-posh init pwsh --config `"`$env:POSH_THEMES_PATH\jandedobbeleer.omp.json`" | Invoke-Expression"
    Set-Content -Path $rdpPsProfile -Value $themeCmd -Encoding UTF8
} catch { Write-Warning "Oh-My-Posh gagal dipasang" }

# 8. OPENCODE DESKTOP
try {
    Write-Host "[>] Menginstall OpenCode Desktop..."
    $opencodeUrl = "https://opencode.ai/download/stable/windows-x64-nsis"
    $opencodePath = Join-Path $env:TEMP "opencode-setup.exe"
    Invoke-WebRequest -Uri $opencodeUrl -OutFile $opencodePath -UseBasicParsing
    Start-Process $opencodePath -ArgumentList "/S" -Wait
    Write-Host "[v] OpenCode Desktop sukses"
} catch { Write-Warning "OpenCode Desktop gagal" }

# 9. HERMES AGENT (CLI + DESKTOP)
try {
    Write-Host "[>] Menginstall Hermes Agent CLI..."
    # Suntikan Anti-Stuck & Auto-Yes buat NPM
    $env:CI = "true"
    $env:NPM_CONFIG_PROGRESS = "false"
    $env:NPM_CONFIG_FUND = "false"
    $env:NPM_CONFIG_AUDIT = "false"
    $env:PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1"
    
    Invoke-Expression (Invoke-RestMethod "https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.ps1")
    Write-Host "[v] Hermes Agent CLI sukses!"
    
    Write-Host "[>] Mendownload Hermes Desktop (GUI)..."
    $hermesRel = Invoke-RestMethod -Uri "https://api.github.com/repos/fathah/hermes-desktop/releases/latest"
    $hermesAsset = $hermesRel.assets | Where-Object { $_.name -match '\.exe$' } | Select-Object -First 1
    if ($hermesAsset) {
        $hermesPath = Join-Path $env:TEMP "hermes-desktop-setup.exe"
        Invoke-WebRequest -Uri $hermesAsset.browser_download_url -OutFile $hermesPath -UseBasicParsing
        Start-Process $hermesPath -ArgumentList "/S" 
        Start-Sleep -Seconds 10
        Write-Host "[v] Hermes Desktop sukses di background!"
    }
} catch { Write-Warning "Hermes Agent gagal di-install" }


Write-Host "`n=== FINALISASI GOD MODE (PATH & PERMISSION) ==="

# 10. HACK SYSTEM PATH BIAR GLOBAL (Biar bisa manggil command dimana aja)
try {
    $sysEnvRegistry = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
    $currentPath = (Get-ItemProperty -Path $sysEnvRegistry).Path
    
    $pathsToAdd = @(
        "C:\ProgramData\npm", 
        "C:\Program Files\nodejs", 
        "C:\Program Files\Git\cmd", 
        "C:\Program Files\Ollama", 
        "C:\Program Files\oh-my-posh\bin",
        "C:\Users\runneradmin\AppData\Local\Hermes",               # Jalur Hermes CLI
        "C:\Users\runneradmin\AppData\Local\Hermes\hermes-agent"   # Jalur Hermes CLI Script
    )
    
    foreach ($p in $pathsToAdd) { 
        if (Test-Path $p) { # Pastikan path ada sebelum dimasukkan
            if ($currentPath -notlike "*$p*") { $currentPath = "$currentPath;$p" }
        }
    }
    Set-ItemProperty -Path $sysEnvRegistry -Name "Path" -Value $currentPath
    Write-Host "[v] System PATH berhasil di-set jadi Global!"
} catch { Write-Warning "Gagal update PATH" }

# 11. CLONE DASHBOARD REPO
try {
    $targetDesktop = "C:\Users\$env:RDP_USERNAME\Desktop"
    if (-not (Test-Path $targetDesktop)) { New-Item -ItemType Directory -Force -Path $targetDesktop | Out-Null }
    
    if ($env:GH_PAT -and $env:GH_USERNAME) {
        $desktopPath = "$targetDesktop\nelsen-dashboard"
        $authenticatedUrl = "https://$($env:GH_USERNAME):$($env:GH_PAT)@github.com/nerusen/nelsen-dashboard.git"
        git clone -q $authenticatedUrl $desktopPath
        Set-Location $desktopPath
        git config user.name "$env:GH_USERNAME"
        git config user.email "$env:GH_USERNAME@users.noreply.github.com"
        Write-Host "[v] Dashboard sukses diclone ke Desktop"
    }
} catch { Write-Warning "Clone repo gagal" }

# 12. PERMISSION UNLOCKER (Hanya Tembak Folder Spesifik Biar Gak Kena Jebakan Windows)
try {
    Write-Host "[>] Membuka kunci folder dengan hak akses Everyone Full Control..."
    
    # Kumpulan folder yang butuh akses mutlak buat RDP Custom user
    $targetFolders = @(
        "C:\ProgramData\npm",
        "C:\Program Files\nodejs",
        "C:\Users\runneradmin\AppData\Local\Hermes",
        "C:\Users\$env:RDP_USERNAME"
    )

    foreach ($folder in $targetFolders) {
        if (Test-Path $folder) {
            # Parameter /C itu penting banget! Artinya "Continue", jadi kalo nemu file error, dia tetep gas
            icacls $folder /grant "Everyone:(OI)(CI)F" /T /C /Q | Out-Null
        }
    }
    Write-Host "[v] Akses penuh sukses diterapkan, bebas modifikasi sesuka hati!"
} catch { Write-Warning "Gagal unlock folder" }

# 13. WHITELIST SHORTCUTS
try {
    $publicDesktop = "C:\Users\Public\Desktop"
    $runnerDesktop = "C:\Users\runneradmin\Desktop"
    $allowedApps = @("Discord", "Spotify", "Antigravity", "Visual Studio Code", "OpenCode", "Hermes", "Ollama")
    
    if (Test-Path $runnerDesktop) {
        $allShortcuts = Get-ChildItem -Path $runnerDesktop -Include *.lnk, *.url -Recurse -ErrorAction SilentlyContinue
        foreach ($shortcut in $allShortcuts) {
            foreach ($app in $allowedApps) {
                if ($shortcut.Name -match $app) { Copy-Item -Path $shortcut.FullName -Destination $publicDesktop -Force -ErrorAction SilentlyContinue; break }
            }
        }
    }
} catch { Write-Warning "Gagal sync shortcut" }

Write-Host "=== SETUP SELESAI, WELCOME TO GOD MODE! ==="
exit 0
m"
        icacls $pubDashPath /grant "Everyone:(OI)(CI)F" /T /C /Q | Out-Null
    }
} catch { }

Write-Host "=== SETUP SELESAI, READY TO USE! ==="
exit 0
