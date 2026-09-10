# ==========================================
# SCRIPT INSTALASI APLIKASI & KONFIGURASI AI
# (Fix Profile, Hidden Startup & AppData Relocation)
# ==========================================

$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"
$hardcoded9routerUrl = "https://9router.nelsen.web.id/v1"

Set-ExecutionPolicy Bypass -Scope LocalMachine -Force

Write-Host "=== Memulai Konfigurasi Environment & CLI ==="

# 1. GIT & NPM GLOBAL CONFIG
try {
    git config --system user.name "$env:GH_USERNAME"
    git config --system user.email "$env:GH_USERNAME@users.noreply.github.com"
    New-Item -ItemType Directory -Force -Path "C:\ProgramData\npm" | Out-Null
    npm config set prefix "C:\ProgramData\npm" --global
} catch { }

# 2. OLLAMA CLI
try {
    $ollamaZipPath = Join-Path $env:TEMP "ollama.zip"
    Invoke-WebRequest -Uri "https://ollama.com/download/ollama-windows-amd64.zip" -OutFile $ollamaZipPath -UseBasicParsing
    Expand-Archive -Path $ollamaZipPath -DestinationPath "C:\Program Files\Ollama" -Force
} catch { }

# 3. CLAUDE & OPENCODE CLI

# 4. CLAUDE CODE CLI (NPM)
try {
    Write-Host "[>] Setup Claude Code CLI..."
    # HAPUS kata 'opencode' dari sini, sisa claude-code aja
    npm install -g @anthropic-ai/claude-code --no-progress --fund=false --audit=false | Out-Null
    Write-Host "[v] Claude Code CLI sukses"
} catch { Write-Warning "Gagal install CLI berbasis NPM" }


# 5. AUTO-SETUP AI CONFIG (Bikin Skripnya jalan hidden & pake Default User)
try {
    $startupFolder = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
    $initScriptPath = "C:\ProgramData\init_ai_configs.ps1"
    
    New-Item -ItemType File -Force -Path $initScriptPath | Out-Null
    # Skrip ini bakal jalan pas lu login, dia deteksi folder profil asli lu
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
    Add-Content -Path $initScriptPath -Value "Remove-Item -Path `$PSCommandPath -Force" # Hapus diri sendiri biar jalan sekali doang
    
    # Bikin VBScript pembungkus biar 100% GAK MUNCUL jendela terminal hitam
    $vbsPath = "$startupFolder\SilentStartup.vbs"
    Set-Content -Path $vbsPath -Value "CreateObject(`"WScript.Shell`").Run `"powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File C:\ProgramData\init_ai_configs.ps1`", 0, False"
} catch { }


Write-Host "`n=== Memulai Instalasi Aplikasi GUI & Tools ==="

# 6. CHOCOLATEY APPS (Discord, Spotify, VS Code)
try { choco install discord spotify vscode -y --ignore-checksums --no-progress } catch { }

# 7. WINGET APPS (Antigravity & Oh-My-Posh)
try { winget install --id Google.Antigravity --machine --source winget --accept-source-agreements --accept-package-agreements --silent } catch { }
try {
    winget install JanDeDobbeleer.OhMyPosh --machine -s winget --accept-source-agreements --accept-package-agreements --silent
    
    # Masukin config OhMyPosh ke folder DEFAULT. Biar Windows yang nge-copyin ke folder profil lu nanti!
    $defaultProfileDir = "C:\Users\Default\Documents\PowerShell"
    if (-not (Test-Path $defaultProfileDir)) { New-Item -ItemType Directory -Force -Path $defaultProfileDir | Out-Null }
    $defaultPsProfile = Join-Path $defaultProfileDir "Microsoft.PowerShell_profile.ps1"
    
    $themeCmd = "oh-my-posh init pwsh --config `"`$env:POSH_THEMES_PATH\jandedobbeleer.omp.json`" | Invoke-Expression"
    Set-Content -Path $defaultPsProfile -Value $themeCmd -Encoding UTF8
} catch { }

# 8. OPENCODE DESKTOP
try {
    $opencodePath = Join-Path $env:TEMP "opencode-setup.exe"
    Invoke-WebRequest -Uri "https://opencode.ai/download/stable/windows-x64-nsis" -OutFile $opencodePath -UseBasicParsing
    Start-Process $opencodePath -ArgumentList "/S" -Wait
} catch { }

# 9. HERMES AGENT (CLI + DESKTOP)
try {
    $env:CI = "true"
    $env:NPM_CONFIG_PROGRESS = "false"
    $env:NPM_CONFIG_FUND = "false"
    $env:NPM_CONFIG_AUDIT = "false"
    $env:PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1"
    Invoke-Expression (Invoke-RestMethod "https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.ps1")
    
    $hermesRel = Invoke-RestMethod -Uri "https://api.github.com/repos/fathah/hermes-desktop/releases/latest"
    $hermesAsset = $hermesRel.assets | Where-Object { $_.name -match '\.exe$' } | Select-Object -First 1
    if ($hermesAsset) {
        $hermesPath = Join-Path $env:TEMP "hermes-desktop-setup.exe"
        Invoke-WebRequest -Uri $hermesAsset.browser_download_url -OutFile $hermesPath -UseBasicParsing
        Start-Process $hermesPath -ArgumentList "/S" 
        Start-Sleep -Seconds 10
    }
} catch { }


Write-Host "`n=== Relokasi AppData & Finalisasi ==="

# 10. PINDAHKAN APLIKASI BANDEL KE PROGRAM FILES (Biar semua user bisa buka)
try {
    # Relokasi Discord
    if (Test-Path "C:\Users\runneradmin\AppData\Local\Discord") {
        Move-Item "C:\Users\runneradmin\AppData\Local\Discord" "C:\Program Files\Discord" -Force -Recurse -ErrorAction SilentlyContinue
    }
    # Relokasi Spotify
    if (Test-Path "C:\Users\runneradmin\AppData\Roaming\Spotify") {
        Move-Item "C:\Users\runneradmin\AppData\Roaming\Spotify" "C:\Program Files\Spotify" -Force -Recurse -ErrorAction SilentlyContinue
    }
    # Relokasi Hermes Desktop
    if (Test-Path "C:\Users\runneradmin\AppData\Local\Programs\hermes-desktop") {
        Move-Item "C:\Users\runneradmin\AppData\Local\Programs\hermes-desktop" "C:\Program Files\HermesDesktop" -Force -Recurse -ErrorAction SilentlyContinue
    }
} catch { }

# 11. BIKIN SHORTCUT MANUAL DI PUBLIC DESKTOP (Anti Rusak)
try {
    $publicDesktop = "C:\Users\Public\Desktop"
    $wshShell = New-Object -ComObject WScript.Shell
    
    # Shortcut Discord
    if (Test-Path "C:\Program Files\Discord\Update.exe") {
        $sc = $wshShell.CreateShortcut("$publicDesktop\Discord.lnk")
        $sc.TargetPath = "C:\Program Files\Discord\Update.exe"
        $sc.Arguments = "--processStart Discord.exe"
        $sc.Save()
    }
    # Shortcut Spotify
    if (Test-Path "C:\Program Files\Spotify\Spotify.exe") {
        $sc = $wshShell.CreateShortcut("$publicDesktop\Spotify.lnk")
        $sc.TargetPath = "C:\Program Files\Spotify\Spotify.exe"
        $sc.Save()
    }
    # Shortcut Hermes Desktop
    if (Test-Path "C:\Program Files\HermesDesktop\hermes-desktop.exe") {
        $sc = $wshShell.CreateShortcut("$publicDesktop\Hermes Desktop.lnk")
        $sc.TargetPath = "C:\Program Files\HermesDesktop\hermes-desktop.exe"
        $sc.Save()
    }
    
    # Hapus shortcut bawaan runneradmin yang rusak biar desktop lu bersih
    $runnerDesktop = "C:\Users\runneradmin\Desktop"
    if (Test-Path $runnerDesktop) {
        $allShortcuts = Get-ChildItem -Path $runnerDesktop -Include *.lnk, *.url -Recurse
        foreach ($shortcut in $allShortcuts) {
            if ($shortcut.Name -match "Visual Studio Code|OpenCode|Ollama") { 
                Copy-Item -Path $shortcut.FullName -Destination $publicDesktop -Force
            }
        }
    }
} catch { }

# 12. FIX SYSTEM PATH
try {
    $sysEnvRegistry = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
    $currentPath = (Get-ItemProperty -Path $sysEnvRegistry).Path
    $pathsToAdd = @(
        "C:\ProgramData\npm", 
        "C:\Program Files\nodejs", 
        "C:\Program Files\Git\cmd", 
        "C:\Program Files\Ollama", 
        "C:\Program Files\oh-my-posh\bin",
        "C:\Users\runneradmin\AppData\Local\Hermes",               
        "C:\Users\runneradmin\AppData\Local\Hermes\hermes-agent"
    )
    foreach ($p in $pathsToAdd) { if ($currentPath -notlike "*$p*") { $currentPath = "$currentPath;$p" } }
    Set-ItemProperty -Path $sysEnvRegistry -Name "Path" -Value $currentPath
} catch { }

# 13. CLONE DASHBOARD & FIX PERMISSIONS
try {
    # Hajar semua folder profil pake Full Control biar lu bebas ngapain aja
    icacls "C:\Users\runneradmin" /grant "Everyone:(OI)(CI)F" /T /C /Q | Out-Null
    icacls "C:\Program Files" /grant "Everyone:(OI)(CI)F" /T /C /Q | Out-Null
    
    if ($env:GH_PAT -and $env:GH_USERNAME) {
        $pubDashPath = "C:\Users\Public\Desktop\nelsen-dashboard"
        git clone -q "https://$($env:GH_USERNAME):$($env:GH_PAT)@github.com/nerusen/nelsen-dashboard.git" $pubDashPath
        Set-Location $pubDashPath
        git config user.name "$env:GH_USERNAME"
        git config user.email "$env:GH_USERNAME@users.noreply.github.com"
        icacls $pubDashPath /grant "Everyone:(OI)(CI)F" /T /C /Q | Out-Null
    }
} catch { }

Write-Host "=== SETUP SELESAI, READY TO USE! ==="
exit 0
