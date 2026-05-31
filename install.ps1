param(
    [switch]$English,
    [switch]$Russian,
    [switch]$SkipNode,
    [switch]$NoOpenLinks
)

$ErrorActionPreference = "Stop"

$PythonManagerUrl = "https://www.python.org/downloads/latest/pymanager/"
$WingetStoreUrl = "https://www.microsoft.com/store/productId/9NBLGGH4NNS1"
$WingetDocsUrl = "https://learn.microsoft.com/windows/package-manager/winget"
$PackageUrl = "https://github.com/Zhigalove/ytdl-ui-extension/archive/refs/heads/main.zip"
$ChromeExtensionsUrl = "chrome://extensions"
$YandexExtensionsUrl = "browser://extensions"
$ExtensionDir = Join-Path $env:USERPROFILE "ytdl7000_ext"

function Get-Language {
    if ($Russian) { return "ru" }
    if ($English) { return "en" }

    $culture = [Globalization.CultureInfo]::CurrentUICulture.Name
    if ($PSUICulture) { $culture = $PSUICulture }

    if ($culture -like "ru*") { return "ru" }
    return "en"
}

$Lang = Get-Language

$Text = @{
    en = @{
        Title = "ytdl-ui-extension installer"
        CheckingPython = "Checking Python..."
        PythonMissing = "Python 3.11 or newer was not found."
        PythonOpen = "Install Python Manager from this page, then run this command again:"
        PythonOld = "Python {0} was found, but Python 3.11 or newer is required."
        CheckingWinget = "Checking winget..."
        WingetMissing = "winget was not found. Install App Installer from Microsoft Store, then run this command again:"
        WingetDocs = "winget documentation:"
        CheckingFfmpeg = "Checking ffmpeg..."
        InstallingFfmpeg = "ffmpeg was not found. Installing the latest package with winget..."
        FfmpegFailed = "ffmpeg was installed, but is still unavailable in this terminal. Reopen PowerShell and run the installer again."
        FfmpegOk = "ffmpeg is available."
        CheckingNode = "Checking Node.js..."
        NodePrompt = "Node.js is recommended for more reliable YouTube downloads. Install it now? [Y/n]"
        InstallingNode = "Installing Node.js with winget..."
        NodeSkipped = "Node.js installation skipped."
        NodeFailed = "Node.js installation finished, but node is still unavailable. You can reopen PowerShell later; the extension installation will continue."
        UpdatingPip = "Installing/updating yt-dlp and helper packages..."
        PurgingCache = "Purging pip cache..."
        InstallingExtension = "Installing ytdl-ui-extension from GitHub..."
        VerifyingExtension = "Checking extension folder..."
        ExtensionMissing = "The extension folder was not created: {0}"
        Done = "Done."
        LoadTitle = "Load the extension in Chrome:"
        Step1 = "1. Open:"
        Step2 = "2. Enable Developer mode."
        Step3 = "3. Click Load unpacked."
        Step4 = "4. Select this folder:"
        YandexHint = "Yandex Browser users can open:"
        ReRun = "After updating the fork, run the same command again to update local files."
    }
    ru = @{
        Title = "Установщик ytdl-ui-extension"
        CheckingPython = "Проверяю Python..."
        PythonMissing = "Python 3.11 или новее не найден."
        PythonOpen = "Установите Python Manager с этой страницы, затем запустите команду еще раз:"
        PythonOld = "Найден Python {0}, но нужен Python 3.11 или новее."
        CheckingWinget = "Проверяю winget..."
        WingetMissing = "winget не найден. Установите App Installer из Microsoft Store, затем запустите команду еще раз:"
        WingetDocs = "Документация winget:"
        CheckingFfmpeg = "Проверяю ffmpeg..."
        InstallingFfmpeg = "ffmpeg не найден. Устанавливаю последнюю версию через winget..."
        FfmpegFailed = "ffmpeg установлен, но все еще недоступен в этом терминале. Откройте PowerShell заново и запустите установщик еще раз."
        FfmpegOk = "ffmpeg доступен."
        CheckingNode = "Проверяю Node.js..."
        NodePrompt = "Node.js рекомендуется для более надежного скачивания с YouTube. Установить сейчас? [Y/n]"
        InstallingNode = "Устанавливаю Node.js через winget..."
        NodeSkipped = "Установка Node.js пропущена."
        NodeFailed = "Node.js установлен, но node все еще недоступен. Можно позже открыть PowerShell заново; установка расширения продолжится."
        UpdatingPip = "Устанавливаю/обновляю yt-dlp и вспомогательные пакеты..."
        PurgingCache = "Очищаю кеш pip..."
        InstallingExtension = "Устанавливаю ytdl-ui-extension с GitHub..."
        VerifyingExtension = "Проверяю папку расширения..."
        ExtensionMissing = "Папка расширения не создана: {0}"
        Done = "Готово."
        LoadTitle = "Как загрузить расширение в Chrome:"
        Step1 = "1. Откройте:"
        Step2 = "2. Включите режим разработчика."
        Step3 = "3. Нажмите Загрузить распакованное."
        Step4 = "4. Выберите эту папку:"
        YandexHint = "Для Яндекс Браузера можно открыть:"
        ReRun = "После обновления форка запустите эту же команду еще раз, чтобы обновить локальные файлы."
    }
}[$Lang]

function Write-Info($Message) {
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-Ok($Message) {
    Write-Host "OK  $Message" -ForegroundColor Green
}

function Write-Warn($Message) {
    Write-Host "!!  $Message" -ForegroundColor Yellow
}

function Write-Link($Label, $Url) {
    Write-Host $Label
    Write-Host $Url -ForegroundColor Blue
}

function Open-Link($Url) {
    if ($NoOpenLinks) { return }
    try {
        Start-Process $Url | Out-Null
    } catch {
        # Printing the URL is enough if the shell cannot open browser links.
    }
}

function Refresh-Path {
    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"
}

function Invoke-Native($FilePath, [string[]]$Arguments) {
    & $FilePath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed: $FilePath $($Arguments -join ' ')"
    }
}

function Invoke-Probe($FilePath, [string[]]$Arguments) {
    $oldErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"

    try {
        $output = & $FilePath @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    } catch {
        $output = @($_.Exception.Message)
        $exitCode = 1
    } finally {
        $ErrorActionPreference = $oldErrorActionPreference
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        Output = @($output | ForEach-Object { $_.ToString() })
    }
}

function Test-Command($Name) {
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Get-Python {
    $candidates = @(
        @{ File = "py"; Args = @("-3") },
        @{ File = "python"; Args = @() },
        @{ File = "python3"; Args = @() }
    )

    foreach ($candidate in $candidates) {
        if (-not (Test-Command $candidate.File)) { continue }

        $probeArgs = @($candidate.Args + @("-c", "import sys; print(sys.executable); print('{}.{}.{}'.format(*sys.version_info[:3]))"))
        $probe = Invoke-Probe $candidate.File $probeArgs
        if ($probe.ExitCode -ne 0 -or $probe.Output.Count -lt 2) { continue }

        $executable = $probe.Output[0]
        $versionText = $probe.Output[1]
        $version = $null

        if (-not [version]::TryParse($versionText, [ref]$version)) { continue }
        if ($executable -like "*\Microsoft\WindowsApps\*") { continue }

        return [pscustomobject]@{
            File = $candidate.File
            PrefixArgs = $candidate.Args
            Executable = $executable
            Version = $version
        }
    }

    return $null
}

function Invoke-Python($Python, [string[]]$Arguments) {
    Invoke-Native $Python.File @($Python.PrefixArgs + $Arguments)
}

function Ensure-Winget {
    Write-Info $Text.CheckingWinget
    if (Test-Command "winget") {
        Write-Ok "winget"
        return
    }

    Write-Warn $Text.WingetMissing
    Write-Link "Microsoft Store:" $WingetStoreUrl
    Write-Link $Text.WingetDocs $WingetDocsUrl
    Open-Link $WingetStoreUrl
    exit 1
}

function Ensure-Ffmpeg {
    Write-Info $Text.CheckingFfmpeg
    if (Test-Command "ffmpeg") {
        Write-Ok $Text.FfmpegOk
        return
    }

    Ensure-Winget
    Write-Info $Text.InstallingFfmpeg
    Invoke-Native "winget" @("install", "-e", "--id", "Gyan.FFmpeg", "--accept-package-agreements", "--accept-source-agreements")
    Refresh-Path

    if (-not (Test-Command "ffmpeg")) {
        throw $Text.FfmpegFailed
    }

    Write-Ok $Text.FfmpegOk
}

function Ensure-Node {
    if ($SkipNode) {
        Write-Warn $Text.NodeSkipped
        return
    }

    Write-Info $Text.CheckingNode
    if (Test-Command "node") {
        Write-Ok "Node.js"
        return
    }

    Ensure-Winget
    $answer = Read-Host $Text.NodePrompt
    $normalized = $answer.Trim().ToLowerInvariant()
    $yes = @("", "y", "yes", "д", "да")

    if ($yes -notcontains $normalized) {
        Write-Warn $Text.NodeSkipped
        return
    }

    Write-Info $Text.InstallingNode
    Invoke-Native "winget" @("install", "-e", "--id", "OpenJS.NodeJS", "--accept-package-agreements", "--accept-source-agreements")
    Refresh-Path

    if (-not (Test-Command "node")) {
        Write-Warn $Text.NodeFailed
    } else {
        Write-Ok "Node.js"
    }
}

Write-Host ""
Write-Host $Text.Title -ForegroundColor Magenta
Write-Host ""

Write-Info $Text.CheckingPython
$python = Get-Python

if (-not $python) {
    Write-Warn $Text.PythonMissing
    Write-Link $Text.PythonOpen $PythonManagerUrl
    Open-Link $PythonManagerUrl
    exit 1
}

if ($python.Version -lt [version]"3.11") {
    Write-Warn ($Text.PythonOld -f $python.Version)
    Write-Link $Text.PythonOpen $PythonManagerUrl
    Open-Link $PythonManagerUrl
    exit 1
}

Write-Ok "Python $($python.Version) ($($python.Executable))"

Ensure-Ffmpeg
Ensure-Node

Write-Info $Text.UpdatingPip
Invoke-Python $python @("-m", "pip", "install", "-U", "yt-dlp[default]", "yt-dlp-ejs")

Write-Info $Text.PurgingCache
Invoke-Python $python @("-m", "pip", "cache", "purge")

Write-Info $Text.InstallingExtension
Invoke-Python $python @("-m", "pip", "install", "-U", $PackageUrl)

Write-Info $Text.VerifyingExtension
if (-not (Test-Path (Join-Path $ExtensionDir "manifest.json"))) {
    throw ($Text.ExtensionMissing -f $ExtensionDir)
}

Write-Host ""
Write-Ok $Text.Done
Write-Host ""
Write-Host $Text.LoadTitle -ForegroundColor Cyan
Write-Host $Text.Step1
Write-Host $ChromeExtensionsUrl -ForegroundColor Blue
Write-Host $Text.Step2
Write-Host $Text.Step3
Write-Host $Text.Step4
Write-Host $ExtensionDir -ForegroundColor Green
Write-Host ""
Write-Link $Text.YandexHint $YandexExtensionsUrl
Write-Host ""
Write-Host $Text.ReRun -ForegroundColor DarkGray
