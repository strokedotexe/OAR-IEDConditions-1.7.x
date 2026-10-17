Open Animation Replacer - IED Conditions - Skyrim 1.7.x Update
==============================================================

A rebuild of SlavicPotato's "Open Animation Replacer - IED Condition Extensions"
so that it loads on Skyrim Special Edition 1.7.104 (SKSE 2.3.1).


COPYRIGHT AND LICENCE
---------------------

Copyright (C) 2023 SlavicPotato
Copyright (C) 2026 strokedotexe (Skyrim 1.7.x compatibility rebuild)

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version, with the additional permissions stated in EXCEPTIONS.txt.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see <https://www.gnu.org/licenses/>.

The full licence text is in LICENSE.txt in this archive, and is also published at
<https://www.gnu.org/licenses/gpl-3.0.txt>.


SOURCE CODE
-----------

The complete corresponding source for this build is included in the Source folder
of this archive, and is also published at:

    https://github.com/strokedotexe/OAR-IEDConditions-1.7.x

The Source folder does not contain the CommonLibSSE-NG submodule, which is fetched
during the build. Clone the repository with --recurse-submodules to get it, or see
<https://github.com/alandtse/CommonLibSSE-NG> directly.


THIRD-PARTY COMPONENTS
----------------------

Open Animation Replacer - IED Condition Extensions
    Copyright (C) 2023 SlavicPotato
    https://github.com/SlavicPotato/OpenAnimationReplacer-IEDConditionExtensions
    GNU General Public License v3.0 or later, with the exceptions in EXCEPTIONS.txt.
    This project is a recompilation of that plugin.

CommonLibSSE-NG
    Copyright (c) CharmedBaryon, Ryan-rsm-McKenzie and contributors
    https://github.com/alandtse/CommonLibSSE-NG
    GNU General Public License v3.0 or later, with the modding linking exceptions
    stated in its EXCEPTIONS.md. Linked statically into the plugin.

The headers under Source/src/API are the plugin interfaces published by the authors
of Open Animation Replacer, Immersive Equipment Displays and Simple Dual Sheath, and
are redistributed unmodified apart from the two build fixes noted in CHANGELOG.md.


WHY THE ORIGINAL STOPS WORKING
------------------------------

Skyrim 1.7.x shipped a new Address Library layout, format 5. The original 1.0.2
plugin links CommonLibSSE-NG v3.7.0, which was abandoned in September 2024 and only
knows formats 1 and 2, so it aborts during load with "Unsupported address library
format: 5". Rebuilding against CommonLibSSE-NG v11, which reads format 5, is all
that was required.

This build also restores IED_CurrentLocationHasKeyword, a condition the released
1.0.2 binary registers but which is absent from the published source, so existing
OAR configurations keep resolving. See README.md in the source for details.


REQUIREMENTS
------------

- Skyrim Special Edition 1.7.104
- SKSE64 2.3.1
- Address Library for SKSE Plugins
- Open Animation Replacer
- Immersive Equipment Displays
- Simple Dual Sheath (optional, only for the SDS condition)


INSTALLATION
------------

Install with a mod manager and disable the original mod. Both provide the same
SKSE/Plugins/OpenAnimationReplacer-IEDConditionExtensions.dll and must not be
loaded at the same time.
