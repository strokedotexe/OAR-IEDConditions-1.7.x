E-mail para support@nexusmods.com pedindo a revisao do arquivo em quarentena.
Preencha o link da pagina do mod antes de enviar.

---

**Subject:** Quarantined file review request - OpenAnimationReplacer IEDConditionExtensions 1.1.1 (SKSE plugin, source available)

Hello,

My file has been quarantined by the automated safety checks. It is an SKSE64 plugin, so the archive contains a compiled DLL, which I believe is what triggered the scan. The archive contains no nested archives and no installer or executable other than that plugin DLL.

Mod page: <COLE AQUI O LINK DA PAGINA DO MOD>
File: OpenAnimationReplacer-IEDConditionExtensions-1.1.1.zip
SHA-256 of the archive: B2A7AFDE6451D6ECD4409FD72C4E471EB54A4EC9AEF0F02B907C5A3A69E8B3D6
SHA-256 of the DLL inside it: E9668028F3A3B9A5E04CC686E7DECFF122B8CCED67AC545E70D11212BA9E36B6

The mod is free software under GPL-3.0. The complete corresponding source is published at:

    https://github.com/strokedotexe/OAR-IEDConditions-1.7.x

It is also included in full inside the uploaded archive, under the Source folder, alongside
LICENSE.txt and README.txt. The exact commit this build was made from is d71615a, tagged v1.1.1,
and the same archive is attached to that tag's release:

    https://github.com/strokedotexe/OAR-IEDConditions-1.7.x/releases/tag/v1.1.1

What the mod is: it is a recompilation of SlavicPotato's "Open Animation Replacer - IED Condition
Extensions" (https://github.com/SlavicPotato/OpenAnimationReplacer-IEDConditionExtensions). The
original was built against CommonLibSSE-NG v3.7.0, which cannot parse the Address Library format
introduced by Skyrim 1.7.x, so it aborts on load with "Unsupported address library format: 5".
Rebuilding it against the maintained CommonLibSSE-NG v11 is the whole of the fix. The changes are
listed in CHANGELOG.md in the repository.

Steps to build it:

1. Install Visual Studio with the Desktop development with C++ workload, which provides MSVC, the
   Windows SDK, CMake and Ninja. This build used Visual Studio Community 2026 (18.6.11822.322).
2. Clone and bootstrap vcpkg from https://github.com/microsoft/vcpkg. The manifest pins the
   builtin baseline 2976266a3b2aa358e0eed9e89bde2e0cf59daf0a, so the dependency versions are fixed.
3. Clone the repository with its submodule, which pins CommonLibSSE-NG to v11.0.0, commit
   94faaed0c60eddd8347767f2d4d29a97c93bde8c:

       git clone --recurse-submodules https://github.com/strokedotexe/OAR-IEDConditions-1.7.x.git
       cd OAR-IEDConditions-1.7.x

4. Point vcpkg at your checkout and build:

       $env:VCPKG_ROOT = 'C:\path\to\vcpkg'
       .\build.ps1

   build.ps1 is a thin wrapper that runs vcvars64 and then `cmake --preset release` followed by
   `cmake --build build\release`. The output is build\release\OpenAnimationReplacer-IEDConditionExtensions.dll.

5. Assemble the uploaded archive:

       .\package.ps1 -Zip

   This writes dist\OpenAnimationReplacer-IEDConditionExtensions-1.1.1.zip, which is the file I uploaded.

Happy to provide anything else you need. Thank you for taking a look.

Regards,
strokedotexe
