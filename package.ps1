<#
.SYNOPSIS
    Assembles dist/ into the layout a mod manager expects, and optionally zips it.

.PARAMETER Zip
    Also write dist/<name>-<version>.zip, ready to upload.

.PARAMETER Symbols
    Include the .pdb. Useful for testers who report crash logs, too large for a normal release.
#>
[CmdletBinding()]
param(
    [switch]$Zip,
    [switch]$Symbols
)

$ErrorActionPreference = 'Stop'

$root = $PSScriptRoot
$name = 'OpenAnimationReplacer-IEDConditionExtensions'
$dist = Join-Path $root 'dist'
$built = Join-Path $root "build\release\$name.dll"

if (-not (Test-Path $built)) { throw "build first: $built does not exist" }

Remove-Item $dist -Recurse -Force -ErrorAction SilentlyContinue
$plugins = Join-Path $dist 'SKSE\Plugins'
New-Item -ItemType Directory -Force -Path $plugins | Out-Null

Copy-Item $built $plugins
if ($Symbols) { Copy-Item (Join-Path $root "build\release\$name.pdb") $plugins }

Get-ChildItem $dist -Recurse -File |
    ForEach-Object { '{0,-60} {1,11:N0}' -f $_.FullName.Substring($dist.Length + 1), $_.Length }

if ($Zip) {
    $version = (Select-String -Path (Join-Path $root 'CMakeLists.txt') -Pattern 'VERSION (\d+\.\d+\.\d+)').Matches[0].Groups[1].Value
    $archive = Join-Path $dist "$name-$version.zip"
    Compress-Archive -Path (Join-Path $dist 'SKSE') -DestinationPath $archive -Force
    Write-Host ''
    Write-Host ('{0}  {1:N0} bytes' -f $archive, (Get-Item $archive).Length)
}
