# ==========================================
# SCRIPT INSTALASI APLIKASI & KONFIGURASI AI
# ==========================================

# 1. SETUP ANTI-SPAM & ANTI-GAGAL
$ErrorActionPreference = "Continue"     # Kalo ada app gagal, tetep lanjut ke app berikutnya
$ProgressPreference = "SilentlyContinue" # Matiin spam loading indikator (/ - \ |) biar log bersih
$hardcoded9routerUrl = "https://9router.nelsen.web.id/v1"

Write-Host "=== Memulai Konfigurasi Environment & CLI ==="

# 2. GIT & NPM GLOBAL CONFIG
try {
    git config --system user.name "$env:GH_USERNAME"
    git config --system user.email "$env:GH_USERNAME@users.noreply.github.com"
    New-Item -ItemType Directory -Force -Path "C:\ProgramData\npm" | Out-Null
    npm config set prefix "C:\ProgramData\npm" --global
    Write-Host "[v] Git & NPM Configured"
} catch { Write-Warning "Gagal setting Git/NPM" }

# 3. OLLAMA (Portable Extraction - Anti Hang)
try {
    $ollamaZipUrl = "https://ollama.com/download/ollama-windows-amd64.zip"
    $ollamaZipPath = Join-Path $env:TEMP "ollama.zip"
    Invoke-WebRequest -Uri $ollamaZipUrl -OutFile $ollamaZipPath -UseBasicParsing
    Expand-Archive -Path $ollamaZipPath -DestinationPath "C:\Program Files\Ollama" -Force
    Write-Host "[v] Ollama CLI Terinstall"
} catch { Write-Warning "Gagal install Ollama" }

# 4. CLAUDE CODE CLI (Anti Spam Animasi)
try {
    npm install -g @anthropic-ai/claude-code --no-progress --fund=false --audit=false | Out-Null
    Write-Host "[v] Claude Code CLI Terinstall"
} catch { Write-Warning "Gagal install Claude Code" }

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

# 6. AUTO-SETUP CLAUDE & OPENCODE JSON (Via Startup Script)
try {
    $startupFolder = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
    $initScriptPath = "$startupFolder\init_ai_configs.ps1"
    
    New-Item -ItemType File -Force -Path $initScriptPath | Out-Null
    Add-Content -Path $initScriptPath -Value "`$userProfile = `$env:USERPROFILE"
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


Write-Host "`n=== Memulai Instalasi Aplikasi GUI (Skip jika gagal) ==="

# 7. WHATSAPP DESKTOP
try { 
    Write-Host "[>] Menginstall WhatsApp Desktop..."
    winget install --id WhatsApp.WhatsApp --source winget --accept-source-agreements --accept-package-agreements --silent 
    Write-Host "[v] WhatsApp sukses"
} catch { Write-Warning "WhatsApp gagal di-install." }


# 8. MASS INSTALL VIA CHOCO (Telegram, Discord, Android Studio, Brave, PDF24, Spotify)
try {
    Write-Host "[>] Menginstall Apps via Chocolatey (Proses cepat)..."
    choco install telegram discord androidstudio brave pdf24 spotify -y --ignore-checksums --no-progress
    Write-Host "[v] Choco Apps selesai!"
} catch { Write-Warning "Ada aplikasi Choco yang gagal" }

# 9. TRAE CODE
try { 
    Write-Host "[>] Menginstall Trae Code..."
    winget install --id ByteDance.Trae --source winget --accept-source-agreements --accept-package-agreements --silent 
    Write-Host "[v] Trae Code sukses"
} catch { Write-Warning "Trae Code gagal" }

# 10. ANTIGRAVITY
try { 
    Write-Host "[>] Menginstall Antigravity..."
    winget install --id Google.Antigravity --source winget --accept-source-agreements --accept-package-agreements --silent 
    Write-Host "[v] Antigravity sukses"
} catch { Write-Warning "Antigravity gagal" }

# 11. OPENCODE DESKTOP
try {
    Write-Host "[>] Menginstall OpenCode Desktop..."
    $opencodeUrl = "https://opencode.ai/download/stable/windows-x64-nsis"
    $opencodePath = Join-Path $env:TEMP "opencode-setup.exe"
    Invoke-WebRequest -Uri $opencodeUrl -OutFile $opencodePath -UseBasicParsing
    Start-Process $opencodePath -ArgumentList "/S" -Wait
    Write-Host "[v] OpenCode sukses"
} catch { Write-Warning "OpenCode Desktop gagal" }

# 12. CANVA DESKTOP
try {
    Write-Host "[>] Menginstall Canva Desktop..."
    $canvaUrl = "https://desktop-release.canva.com/Canva%20Setup.exe"
    $canvaPath = Join-Path $env:TEMP "CanvaSetup.exe"
    Invoke-WebRequest -Uri $canvaUrl -OutFile $canvaPath -UseBasicParsing
    Start-Process $canvaPath -ArgumentList "/S" -Wait
    Write-Host "[v] Canva sukses"
} catch { Write-Warning "Canva Desktop gagal" }


Write-Host "`n=== Finalisasi Environment & Shortcuts ==="

# 13. SINKRONISASI PATH & PERMISSIONS
try {
    $sysEnvRegistry = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
    $currentPath = (Get-ItemProperty -Path $sysEnvRegistry).Path
    $pathsToAdd = @("C:\ProgramData\npm", "C:\Program Files\nodejs", "C:\Program Files\Git\cmd", "C:\Program Files\Git\bin", "C:\Program Files\Ollama")
    
    foreach ($p in $pathsToAdd) { if ($currentPath -notlike "*$p*") { $currentPath = "$currentPath;$p" } }
    Set-ItemProperty -Path $sysEnvRegistry -Name "Path" -Value $currentPath

    icacls "C:\Users\runneradmin" /grant "Users:(OI)(CI)RX" /T /q | Out-Null
    icacls "C:\ProgramData\npm" /grant "Users:(OI)(CI)F" /T /q | Out-Null
    Write-Host "[v] System PATH & Permissions Update"
} catch { Write-Warning "Gagal sync PATH" }

# 14. WHITELIST SHORTCUTS KE PUBLIC DESKTOP (Biar RDP bersih)
try {
    $publicDesktop = "C:\Users\Public\Desktop"
    $runnerDesktop = "C:\Users\runneradmin\Desktop"
    $allowedApps = @("Brave", "Canva", "Discord", "Telegram", "Spotify", "Android Studio", "Trae", "OpenCode", "PDF24", "Antigravity", "Ollama", "WhatsApp")
    
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

# 15. AUTO CLONE DASHBOARD REPO
if ($env:GH_PAT -and $env:GH_USERNAME) {
    try {
        $desktopPath = "C:\Users\Public\Desktop\nelsen-dashboard"
        $authenticatedUrl = "https://$($env:GH_USERNAME):$($env:GH_PAT)@github.com/nerusen/nelsen-dashboard.git"
        git clone -q $authenticatedUrl $desktopPath
        Set-Location $desktopPath
        git config user.name "$env:GH_USERNAME"
        git config user.email "$env:GH_USERNAME@users.noreply.github.com"
        Write-Host "[v] Nelsen Dashboard sukses diclone"
    } catch { Write-Warning "Clone repo gagal" }
}

Write-Host "=== SETUP SELESAI, READY TO USE! ==="
exit 0
