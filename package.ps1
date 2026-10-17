<#
.SYNOPSIS
    Assembles dist/ into the layout a mod manager expects, and optionally zips it.

.DESCRIPTION
    The archive carries the GPL-3.0 licence text, the exceptions that apply to it, a
    README with the copyright notice, and the complete corresponding source. All four
    are licence obligations for a GPL binary, not optional extras, so they are always
    included rather than gated behind a switch.

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

# Licence paperwork. COPYING is the unmodified GPL-3.0 text; Nexus moderation asks for it
# under the .txt name so that it opens on a double click.
Copy-Item (Join-Path $root 'COPYING') (Join-Path $dist 'LICENSE.txt')
Copy-Item (Join-Path $root 'EXCEPTIONS') (Join-Path $dist 'EXCEPTIONS.txt')
Copy-Item (Join-Path $root 'README.txt') $dist

# Complete corresponding source, minus the submodule and build output.
$source = Join-Path $dist 'Source'
New-Item -ItemType Directory -Force -Path $source | Out-Null
Copy-Item (Join-Path $root 'src') $source -Recurse
Copy-Item (Join-Path $root 'cmake') $source -Recurse
foreach ($file in 'CMakeLists.txt', 'CMakePresets.json', 'vcpkg.json', 'build.ps1', 'package.ps1',
    'README.md', 'CHANGELOG.md', 'COPYING', 'EXCEPTIONS', '.gitmodules', '.clang-format') {
    Copy-Item (Join-Path $root $file) $source
}

Get-ChildItem $dist -Recurse -File |
    ForEach-Object { '{0,-68} {1,11:N0}' -f $_.FullName.Substring($dist.Length + 1), $_.Length }

if ($Zip) {
    $version = (Select-String -Path (Join-Path $root 'CMakeLists.txt') -Pattern 'VERSION (\d+\.\d+\.\d+)').Matches[0].Groups[1].Value
    $archive = Join-Path $dist "$name-$version.zip"
    Compress-Archive -Path (Join-Path $dist 'SKSE'), (Join-Path $dist 'Source'),
        (Join-Path $dist 'LICENSE.txt'), (Join-Path $dist 'EXCEPTIONS.txt'), (Join-Path $dist 'README.txt') `
        -DestinationPath $archive -Force
    Write-Host ''
    Write-Host ('{0}  {1:N0} bytes' -f $archive, (Get-Item $archive).Length)
}
