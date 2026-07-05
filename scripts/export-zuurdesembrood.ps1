param(
    [string]$Source,
    [string]$Output,
    [switch]$KeepHtml
)

$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$cssPath = Resolve-Path (Join-Path $root "brood\zuurdesembrood.print.css")

if ($Source) {
    if (-not $Output) {
        $Output = [System.IO.Path]::ChangeExtension($Source, ".pdf")
    }

    $exports = @(
        @{
            Source = $Source
            Output = $Output
            PageTitle = [System.IO.Path]::GetFileNameWithoutExtension($Output)
        }
    )
} else {
    $exports = @(
        @{
            Source = "brood\zuurdesembrood.md"
            Output = "brood\zuurdesembrood.pdf"
            PageTitle = "Zuurdesembrood"
        },
        @{
            Source = "brood\sourdough-bread.md"
            Output = "brood\sourdough-bread.pdf"
            PageTitle = "Sourdough bread"
        }
    )
}

$browserCandidates = @(
    "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    "C:\Program Files\Microsoft\Edge\Application\msedge.exe",
    "C:\Program Files\Google\Chrome\Application\chrome.exe",
    "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
)

$browser = $browserCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $browser) {
    throw "Geen Edge of Chrome gevonden."
}

foreach ($export in $exports) {
    $sourcePath = Resolve-Path (Join-Path $root $export.Source)
    $outputPath = Join-Path $root $export.Output
    $pdfPath = [System.IO.Path]::GetFullPath($outputPath)

    $outputDir = Split-Path -Parent $pdfPath
    if (-not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir | Out-Null
    }

    if ($KeepHtml) {
        $htmlPath = [System.IO.Path]::ChangeExtension($outputPath, ".html")
    } else {
        $htmlPath = Join-Path ([System.IO.Path]::GetTempPath()) ("zuurdesembrood-" + [System.Guid]::NewGuid() + ".html")
    }

    pandoc $sourcePath `
        --standalone `
        --from gfm+footnotes `
        --to html5 `
        --css $cssPath `
        --metadata "pagetitle=$($export.PageTitle)" `
        --output $htmlPath

    $fileUrl = (New-Object System.Uri((Resolve-Path $htmlPath))).AbsoluteUri
    $tempPdfPath = Join-Path ([System.IO.Path]::GetTempPath()) ("zuurdesembrood-" + [System.Guid]::NewGuid() + ".pdf")

    & $browser `
        --headless `
        --disable-gpu `
        --no-pdf-header-footer `
        "--print-to-pdf=$tempPdfPath" `
        $fileUrl | Out-Null

    if (-not (Test-Path $tempPdfPath)) {
        throw "PDF-export mislukt: browser heeft geen PDF aangemaakt."
    }

    try {
        [System.IO.File]::Copy($tempPdfPath, $pdfPath, $true)
    } catch [System.IO.IOException] {
        throw "Kon '$pdfPath' niet overschrijven. Sluit het geopende doelbestand en probeer opnieuw."
    } finally {
        if (Test-Path $tempPdfPath) {
            Remove-Item -LiteralPath $tempPdfPath
        }

        if (-not $KeepHtml -and (Test-Path $htmlPath)) {
            Remove-Item -LiteralPath $htmlPath
        }
    }

    if ($KeepHtml) {
        Write-Host "HTML: $htmlPath"
    }
    Write-Host "PDF:  $pdfPath"
}
