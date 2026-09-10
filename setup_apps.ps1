# ==========================================
# SCRIPT INSTALASI APLIKASI & KONFIGURASI AI
# (Minimalist Pro Version + Full Permissions Fix)
# ==========================================

# 1. SETUP CORE & ANTI-SPAM
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"
$hardcoded9routerUrl = "https://9router.nelsen.web.id/v1"

# Buka akses full jalankan script PowerShell di PC ini tanpa diblokir
Set-ExecutionPolicy Bypass -Scope LocalMachine -Force

Write-Host "=== Memulai Konfigurasi Environment & CLI ==="

# 2. GIT & NPM GLOBAL CONFIG
try {
    git config --system user.name "$env:GH_USERNAME"
    git config --system user.email "$env:GH_USERNAME@users.noreply.github.com"
    New-Item -ItemType Directory -Force -Path "C:\ProgramData\npm" | Out-Null
    npm config set prefix "C:\ProgramData\npm" --global
    Write-Host "[v] Git & NPM Configured (Global)"
} catch { Write-Warning "Gagal setting Git/NPM" }

# 3. OLLAMA CLI (Portable)
try {
    Write-Host "[>] Setup Ollama CLI..."
    $ollamaZipUrl = "https://ollama.com/download/ollama-windows-amd64.zip"
    $ollamaZipPath = Join-Path $env:TEMP "ollama.zip"
    Invoke-WebRequest -Uri $ollamaZipUrl -OutFile $ollamaZipPath -UseBasicParsing
    Expand-Archive -Path $ollamaZipPath -DestinationPath "C:\Program Files\Ollama" -Force
    Write-Host "[v] Ollama CLI sukses"
} catch { Write-Warning "Gagal install Ollama" }

# 4. CLAUDE CODE & OPENCODE CLI (NPM)
try {
    Write-Host "[>] Setup Claude Code & OpenCode CLI..."
    npm install -g @anthropic-ai/claude-code opencode --no-progress --fund=false --audit=false | Out-Null
    Write-Host "[v] CLI AI (Claude & OpenCode) sukses"
} catch { Write-Warning "Gagal install CLI berbasis NPM" }

# 5. ENVIRONMENT VARIABLES (9ROUTER)
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

# 6. AUTO-SETUP JSON CONFIG (Via Startup)
try {
    $startupFolder = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
    $initScriptPath = "$startupFolder\init_ai_configs.ps1"
    
    New-Item -ItemType File -Force -Path $initScriptPath | Out-Null
    Add-Content -Path $initScriptPath -Value "`$userProfile = `"C:\Users\RDP`""
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

# 7. CHOCOLATEY APPS (Discord, Spotify, VS Code)
try {
    Write-Host "[>] Menginstall Discord, Spotify, VS Code..."
    choco install discord spotify vscode -y --ignore-checksums --no-progress
    Write-Host "[v] Choco Apps selesai!"
} catch { Write-Warning "Ada aplikasi Choco yang gagal" }

# 8. WINGET APPS (Antigravity & Oh-My-Posh via Machine Scope)
try { 
    Write-Host "[>] Menginstall Antigravity..."
    winget install --id Google.Antigravity --machine --source winget --accept-source-agreements --accept-package-agreements --silent 
    Write-Host "[v] Antigravity sukses"
} catch { Write-Warning "Antigravity gagal" }

try {
    Write-Host "[>] Menginstall Oh-My-Posh (Machine Scope)..."
    winget install JanDeDobbeleer.OhMyPosh --machine -s winget --accept-source-agreements --accept-package-agreements --silent
    Write-Host "[v] Oh-My-Posh sukses"
    
    # Auto Inject Oh-My-Posh Theme ke PowerShell Profile Spesifik RDP User
    $rdpProfileDir = "C:\Users\RDP\Documents\PowerShell"
    if (-not (Test-Path $rdpProfileDir)) { New-Item -ItemType Directory -Force -Path $rdpProfileDir | Out-Null }
    $rdpPsProfile = Join-Path $rdpProfileDir "Microsoft.PowerShell_profile.ps1"
    
    $themeCmd = "oh-my-posh init pwsh --config `"`$env:POSH_THEMES_PATH\jandedobbeleer.omp.json`" | Invoke-Expression"
    Set-Content -Path $rdpPsProfile -Value $themeCmd -Encoding UTF8
    Write-Host "[v] Tema Terminal Oh-My-Posh dipasang ke Profile RDP!"
} catch { Write-Warning "Oh-My-Posh gagal dipasang" }

# 9. OPENCODE DESKTOP
try {
    Write-Host "[>] Menginstall OpenCode Desktop..."
    $opencodeUrl = "https://opencode.ai/download/stable/windows-x64-nsis"
    $opencodePath = Join-Path $env:TEMP "opencode-setup.exe"
    Invoke-WebRequest -Uri $opencodeUrl -OutFile $opencodePath -UseBasicParsing
    Start-Process $opencodePath -ArgumentList "/S" -Wait
    Write-Host "[v] OpenCode Desktop sukses"
} catch { Write-Warning "OpenCode Desktop gagal" }

# 10. HERMES AGENT (CLI + DESKTOP)
try {
    Write-Host "[>] Menginstall Hermes Agent CLI..."
    Invoke-Expression (Invoke-RestMethod "https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.ps1")
    Write-Host "[v] Hermes Agent CLI sukses!"
    
    Write-Host "[>] Mendownload Hermes Desktop (GUI)..."
    $hermesRel = Invoke-RestMethod -Uri "https://api.github.com/repos/fathah/hermes-desktop/releases/latest"
    $hermesAsset = $hermesRel.assets | Where-Object { $_.name -match '\.exe$' } | Select-Object -First 1
    if ($hermesAsset) {
        $hermesPath = Join-Path $env:TEMP "hermes-desktop-setup.exe"
        Invoke-WebRequest -Uri $hermesAsset.browser_download_url -OutFile $hermesPath -UseBasicParsing
        Start-Process $hermesPath -ArgumentList "/S" -Wait
        Write-Host "[v] Hermes Desktop sukses!"
    }
} catch { Write-Warning "Hermes Agent gagal di-install" }


Write-Host "`n=== Finalisasi Environment, Permissions, & Shortcuts ==="

# 11. FIX SINKRONISASI PATH SYSTEM
try {
    $sysEnvRegistry = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
    $currentPath = (Get-ItemProperty -Path $sysEnvRegistry).Path
    
    # Path-path wajib biar CLI lancar dibaca user RDP
    $pathsToAdd = @(
        "C:\ProgramData\npm", 
        "C:\Program Files\nodejs", 
        "C:\Program Files\Git\cmd", 
        "C:\Program Files\Ollama", 
        "C:\Program Files\oh-my-posh\bin",
        "C:\Users\runneradmin\AppData\Local\Programs\oh-my-posh\bin",
        "C:\Users\runneradmin\AppData\Roaming\npm"
    )
    
    foreach ($p in $pathsToAdd) { if ($currentPath -notlike "*$p*") { $currentPath = "$currentPath;$p" } }
    Set-ItemProperty -Path $sysEnvRegistry -Name "Path" -Value $currentPath
    Write-Host "[v] System PATH Update"
} catch { Write-Warning "Gagal sync PATH" }

# 12. CLONE DASHBOARD REPO (TARUH DI C:\Users\RDP\Desktop BIAR AMAN)
try {
    $targetDesktop = "C:\Users\RDP\Desktop"
    if (-not (Test-Path $targetDesktop)) { New-Item -ItemType Directory -Force -Path $targetDesktop | Out-Null }
    
    if ($env:GH_PAT -and $env:GH_USERNAME) {
        $desktopPath = "$targetDesktop\nelsen-dashboard"
        $authenticatedUrl = "https://$($env:GH_USERNAME):$($env:GH_PAT)@github.com/nerusen/nelsen-dashboard.git"
        git clone -q $authenticatedUrl $desktopPath
        Set-Location $desktopPath
        git config user.name "$env:GH_USERNAME"
        git config user.email "$env:GH_USERNAME@users.noreply.github.com"
        Write-Host "[v] Nelsen Dashboard sukses diclone ke Desktop RDP"
    }
} catch { Write-Warning "Clone repo gagal" }

# 13. FIX PERMISSIONS SUPER MAXIMAL (Hajar Hak Akses Semua Folder Penting)
try {
    Write-Host "[>] Memberikan akses Full Control ke user RDP & Everyone..."
    
    # Folder NPM Biar ga error npm install
    icacls "C:\ProgramData\npm" /grant "Everyone:(OI)(CI)F" /T /C /Q | Out-Null
    
    # Folder NodeJS
    icacls "C:\Program Files\nodejs" /grant "Everyone:(OI)(CI)F" /T /C /Q | Out-Null
    
    # Repo Dashboard Biar bebas edit/jalanin script di VSCode tanpa Admin
    if (Test-Path "C:\Users\RDP\Desktop\nelsen-dashboard") {
        icacls "C:\Users\RDP\Desktop\nelsen-dashboard" /grant "Everyone:(OI)(CI)F" /T /C /Q | Out-Null
    }

    # Buka Akses Folder Profil RDP Biar bebas utak-atik VSCode config dll
    icacls "C:\Users\RDP" /grant "Everyone:(OI)(CI)F" /T /C /Q | Out-Null
    
    Write-Host "[v] Semua perizinan Folder (NPM, Project, Profile) berhasil di-unlock!"
} catch { Write-Warning "Gagal bypass perizinan folder" }

# 14. WHITELIST SHORTCUTS
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
    Write-Host "[v] Desktop Shortcuts disinkronkan"
} catch { Write-Warning "Gagal sync shortcut" }

Write-Host "=== SETUP SELESAI, READY TO USE! ==="
exit 0
