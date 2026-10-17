# Changelog

## 1.1.1

No change to the plugin's behaviour. This release only makes the distributed archive carry what
GPL-3.0 requires of a binary release.

### Added

- GPL-3.0 notices at the top of the project's own source files. The headers under `src/API` are
  third-party plugin interfaces and are left as published.
- `README.txt`, carrying the copyright notice, the warranty disclaimer and a link to this repository.
- `LICENSE.txt`, `EXCEPTIONS.txt` and the complete corresponding source are now placed in the
  archive by `package.ps1`, which previously shipped the DLL on its own.

## 1.1.0

Forked from [SlavicPotato/OpenAnimationReplacer-IEDConditionExtensions](https://github.com/SlavicPotato/OpenAnimationReplacer-IEDConditionExtensions)
at commit `e3e0d07`.

### Fixed

- Rebuilt against [alandtse/CommonLibSSE-NG](https://github.com/alandtse/CommonLibSSE-NG) `v11.0.0`
  so the plugin loads on Skyrim SE/AE 1.7.99 and 1.7.104. The released binary was built against
  `commonlibsse-ng v3.7.0`, which cannot parse the Address Library format introduced by Skyrim 1.7.x
  and aborts with "Unsupported address library format". No condition logic changed for this.

### Added

- `IED_CurrentLocationHasKeyword`, reconstructed. The released 1.0.2 binary registers this condition
  but it is absent from the published source, so a plain rebuild of upstream would drop it and break
  any OAR config using it. Its name, description and argument format are taken verbatim from that
  binary; the component name could not be recovered and is assumed to be `Keyword`.

### Changed

- Ported the build from xmake to CMake, so it consumes CommonLibSSE-NG's `add_commonlibsse_plugin`
  directly. The plugin name, author and `SKSEPlugin_Version` layout are unchanged.
- Dropped the `SKSE::WinAPI` namespace alias from `pch.h`. It was unused and the namespace no longer
  exists in current CommonLibSSE-NG.
- `stl::to_underlying` to `std::to_underlying`, which replaced it.
- `static_cast` to `reinterpret_cast` when converting the address of `RequestPluginAPI_Conditions` to
  a function pointer, which is only well formed that way outside `/permissive`.
- VR is no longer built. Upstream enabled it, but VR is stuck on 1.4.15 where the original plugin
  still works, so building it would only pull in the openvr dependency for no benefit.
- Debug symbols are emitted for the optimised build so crash logs can resolve frames in this plugin.