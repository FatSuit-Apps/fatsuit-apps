# Copies the latest app builds into downloads\ and play\. Run after rebuilding any app.
$ErrorActionPreference = 'Stop'
$site = $PSScriptRoot
$root = Split-Path $site -Parent

New-Item -ItemType Directory -Force "$site\downloads", "$site\play" | Out-Null

# Tip or Not? ships versioned APKs in dist\; take the newest one.
$tip = Get-ChildItem "$root\dist\TipOrNot-*.apk" |
    Sort-Object { [version]($_.BaseName -replace '^TipOrNot-', '') } |
    Select-Object -Last 1

Copy-Item $tip.FullName                              "$site\downloads\TipOrNot.apk"
Copy-Item "$root\tuesday-android\tuesday-again.apk"  "$site\downloads\Tuesday.apk"
Copy-Item "$root\stance-android\stance.apk"          "$site\downloads\Stance.apk"
Copy-Item "$root\daily-tasks-android\daily-tasks.apk" "$site\downloads\TaskTracker.apk"
Copy-Item "$root\comeback-android\comeback.apk"      "$site\downloads\Comeback.apk"

# Browser versions of the two web-based apps.
Copy-Item "$root\tuesday\tuesday.html"      "$site\play\tuesday.html"
Copy-Item "$root\stance-android\index.html" "$site\play\stance.html"

Write-Host "Copied $($tip.Name) and the other builds into $site"
