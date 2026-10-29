# Copies the latest app builds into downloads\ and play\. Run after rebuilding any app.
$ErrorActionPreference = 'Stop'
$site = $PSScriptRoot
$root = Split-Path $site -Parent

New-Item -ItemType Directory -Force "$site\downloads", "$site\play" | Out-Null

# Tip or Not? ships versioned APKs in dist\; take the newest one.
$tip = Get-ChildItem "$root\dist\TipOrNot-*.apk" |
    Sort-Object { [version]($_.BaseName -replace '^TipOrNot-', '') } |
    Select-Object -Last 1

# Builds made with Google's test ads (see ..\android-ads) leave TEST-ADS-BUILD.txt beside
# the app; those must never reach the site, so they are skipped.
function Copy-Apk($from, $to) {
    $marker = Join-Path (Split-Path $from) 'TEST-ADS-BUILD.txt'
    if (Test-Path $marker) { Write-Warning "Skipped $(Split-Path $from -Leaf): it was built with TEST ads."; return }
    Copy-Item $from $to
}

Copy-Item $tip.FullName                              "$site\downloads\TipOrNot.apk"
Copy-Apk "$root\tuesday-android\tuesday-again.apk"  "$site\downloads\Tuesday.apk"
Copy-Apk "$root\stance-android\stance.apk"          "$site\downloads\Stance.apk"
Copy-Apk "$root\daily-tasks-android\daily-tasks.apk" "$site\downloads\TaskTracker.apk"
Copy-Apk "$root\comeback-android\comeback.apk"      "$site\downloads\Comeback.apk"
Copy-Apk "$root\ten-million-android\ten-million-ticket.apk" "$site\downloads\TenMillionTicket.apk"
Copy-Apk "$root\one-button-trio-android\one-button-trio.apk" "$site\downloads\OneButtonTrio.apk"
Copy-Apk "$root\mayors-first-term-android\mayors-first-term.apk" "$site\downloads\MayorsFirstTerm.apk"

# Browser versions of the web-based apps.
Copy-Item "$root\tuesday\tuesday.html"      "$site\play\tuesday.html"
Copy-Item "$root\stance-android\index.html" "$site\play\stance.html"
Copy-Item "$root\ten-million-ticket\ten-million-ticket.html" "$site\play\ten-million-ticket.html"
Copy-Item "$root\one-button-trio\one-button-trio.html" "$site\play\one-button-trio.html"
Copy-Item "$root\mayors-first-term\index.html" "$site\play\mayors-first-term.html"

Write-Host "Copied $($tip.Name) and the other builds into $site"

# Every new version needs a release-notes entry in index.html (date, general change, version
# number, overinstall warning). Flag any app whose current version has no entry yet.
$versions = [ordered]@{
    'Tip or not?'  = (Get-Content "$root\tip-or-not\app.json" -Raw | ConvertFrom-Json).expo.version
    'Tuesday'      = ([xml](Get-Content "$root\tuesday-android\AndroidManifest.xml")).manifest.versionName
    'Stance'       = ([xml](Get-Content "$root\stance-android\AndroidManifest.xml")).manifest.versionName
    'Task Tracker' = ([xml](Get-Content "$root\daily-tasks-android\AndroidManifest.xml")).manifest.versionName
    'Comeback'     = ([xml](Get-Content "$root\comeback-android\AndroidManifest.xml")).manifest.versionName
    '$10M Ticket'  = ([xml](Get-Content "$root\ten-million-android\AndroidManifest.xml")).manifest.versionName
    'One-Button Trio' = ([xml](Get-Content "$root\one-button-trio-android\AndroidManifest.xml")).manifest.versionName
    # Its build.ps1 keeps this equal to the page's <meta name="version"> (the browser version).
    "Mayor's First Term" = ([xml](Get-Content "$root\mayors-first-term-android\AndroidManifest.xml")).manifest.versionName
}
$page = Get-Content "$site\index.html" -Raw
foreach ($app in $versions.Keys) {
    $section = [regex]::Match($page, "<h2>$([regex]::Escape($app))</h2>[\s\S]*?</section>").Value
    if ($section -notmatch "<strong>v$([regex]::Escape($versions[$app]))</strong>") {
        Write-Warning "$app is now v$($versions[$app]) but has no release notes for it in index.html."
    }
}
