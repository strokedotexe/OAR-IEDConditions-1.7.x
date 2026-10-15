# OAR IED Conditions — Skyrim 1.7.x Update

A rebuilt `OpenAnimationReplacer-IEDConditionExtensions.dll` that loads on Skyrim Special Edition
1.7.99 and 1.7.104, where the 2023 release of
[Open Animation Replacer - IED Conditions](https://www.nexusmods.com/skyrimspecialedition/mods/98308)
refuses to start.

This replaces the whole mod: that release ships nothing but the one DLL, so the original does not
need to be installed alongside it.

## Why the original stopped loading

The shipped binary was built against `commonlibsse-ng v3.7.0`, the CharmedBaryon fork that has been
unmaintained since September 2024. Skyrim 1.7.x introduced a new Address Library format that v3.7.0
cannot parse, so the plugin aborts during initialisation with its own error:

> Unsupported address library format: {}
>
> This means this script extender plugin is incompatible with the address library available for this
> version of the game, and thus does not support it.

The fix is to build against [alandtse/CommonLibSSE-NG](https://github.com/alandtse/CommonLibSSE-NG)
`v11.0.0`, the actively maintained fork that reads the new format. No condition logic needed to
change for this.

## The condition missing from the public source

The published source is behind the released binary: `xmake.lua` on `master` says `1.0.1`, while the
DLL distributed as 1.0.2 registers an eighth condition, `IED_CurrentLocationHasKeyword`, that does
not exist anywhere in the repository. Building `master` as-is would therefore silently drop a
condition and break any OAR config that uses it.

It has been reconstructed here. The name, the description and the argument format string are taken
verbatim from the released binary, which also fixes its registration order and confirms it is
registered unconditionally, before the IED interface is queried. The implementation reads the
reference's current location and asks the keyword component whether it matches, which `BGSLocation`
supports directly since it derives from `BGSKeywordForm`.

One detail could not be recovered from the binary: the **component name**. MSVC pools `"Keyword"` as
a suffix of `"IED_CurrentLocationHasKeyword"`, so it leaves no separate string to read. `Keyword` is
used here, matching the naming OAR uses elsewhere. If a config was authored against a different name,
that one parameter would need to be set again.

| Condition                           | Released 1.0.2 | `master` | Here |
| ----------------------------------- | -------------- | -------- | ---- |
| `IED_GearNodePlacementHint`         | yes            | yes      | yes  |
| `IED_GearNodeEquippedPlacementHint` | yes            | yes      | yes  |
| `IED_GearNodeParentName`            | yes            | yes      | yes  |
| `IED_HasEquipSlot`                  | yes            | yes      | yes  |
| `IED_IsBoundWeaponEquipped`         | yes            | yes      | yes  |
| `IED_PluginOption`                  | yes            | yes      | yes  |
| `IED_CurrentLocationHasKeyword`     | yes            | **no**   | yes  |
| `SDS_IsShieldOnBackEnabled`         | yes            | yes      | yes  |

## Requirements

- Skyrim SE/AE 1.6.x – 1.7.104. **VR is not supported**; upstream built with VR enabled, but VR is
  stuck on 1.4.15 where the original plugin still works, so there is no reason to install this there.
- SKSE64
- Address Library for SKSE Plugins
- Open Animation Replacer
- Immersive Equipment Displays, for the `IED_*` conditions other than `IED_CurrentLocationHasKeyword`
- Simple Dual Sheath, for `SDS_IsShieldOnBackEnabled`

The IED and SDS interfaces are queried at runtime and their conditions are only registered when the
corresponding mod is present, so neither is strictly required for the plugin to load.

## Installation

Install with a mod manager. The original mod can be disabled, since this contains a complete
replacement of its only file. If you keep it enabled, load this one after it.

## Building

Needs Visual Studio with the C++ workload (MSVC, Windows SDK, CMake, Ninja) and a bootstrapped
[vcpkg](https://github.com/microsoft/vcpkg).

```powershell
git clone --recurse-submodules https://github.com/strokedotexe/OAR-IEDConditions-1.7.x.git
cd OAR-IEDConditions-1.7.x
$env:VCPKG_ROOT = 'C:\path\to\vcpkg'
.\build.ps1
.\package.ps1 -Zip
```

Upstream builds with xmake; this uses CMake so it can consume CommonLibSSE-NG's
`add_commonlibsse_plugin` directly. The plugin name, author and the generated `SKSEPlugin_Version`
struct are unchanged, because OAR keys its registered conditions off the plugin name and it is also
the `.log` filename.

## Credits

[SlavicPotato](https://github.com/SlavicPotato) wrote this plugin and Immersive Equipment Displays.
Ersh wrote [Open Animation Replacer](https://github.com/ersh1/OpenAnimationReplacer) and the
condition API this plugs into.

Licensed under the GNU General Public License v3.0 with the modding linking exceptions, the same as
upstream. See `COPYING` and `EXCEPTIONS` for the terms and `CHANGELOG.md` for the changes made here.
