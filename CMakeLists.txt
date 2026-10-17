cmake_minimum_required(VERSION 3.21)

project(
        OpenAnimationReplacer-IEDConditionExtensions
        VERSION 1.1.1
        DESCRIPTION "SKSE64 plugin that lets OAR read data from IED and SDS via conditions"
        LANGUAGES CXX)

set(PROJECT_FRIENDLY_NAME "Open Animation Replacer - IED Conditions")

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)

########################################################################################################################
## CommonLibSSE NG (alandtse fork -- the one that reads address library format 5 / Skyrim 1.7.x)
########################################################################################################################
# Upstream built with skyrim_vr enabled. VR is stuck on 1.4.15, where the original plugin still
# works, and enabling it here would drag in the openvr submodule for no benefit on 1.7.x.
set(ENABLE_SKYRIM_SE ON CACHE BOOL "" FORCE)
set(ENABLE_SKYRIM_AE ON CACHE BOOL "" FORCE)
set(ENABLE_SKYRIM_VR OFF CACHE BOOL "" FORCE)
set(BUILD_TESTS OFF CACHE BOOL "" FORCE)

add_subdirectory(extern/CommonLibSSE-NG CommonLibSSE EXCLUDE_FROM_ALL)
get_target_property(COMMONLIB_SRC_DIR CommonLibSSE SOURCE_DIR)
include(${COMMONLIB_SRC_DIR}/cmake/CommonLibSSE.cmake)

configure_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/cmake/version.rc.in
        ${CMAKE_CURRENT_BINARY_DIR}/version.rc
        @ONLY)

########################################################################################################################
## Plugin
########################################################################################################################
# NAME must stay "OpenAnimationReplacer-IEDConditionExtensions": OAR keys its registered conditions
# off it, and it is also the .log filename.
add_commonlibsse_plugin(${PROJECT_NAME}
        NAME "OpenAnimationReplacer-IEDConditionExtensions"
        AUTHOR "SlavicPotato"
        VERSION 1.1.1
        USE_ADDRESS_LIBRARY
        SOURCES
        src/main.cpp
        src/Conditions.cpp
        src/Interface.cpp
        src/API/OpenAnimationReplacer-ConditionTypes.cpp
        src/API/OpenAnimationReplacerAPI-Conditions.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/version.rc)

target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_23)

# Upstream builds with warnings-as-errors, which a newer CommonLibSSE does not satisfy.
target_compile_options(${PROJECT_NAME} PRIVATE /W4 /Zi)
target_link_options(${PROJECT_NAME} PRIVATE /DEBUG:FULL /OPT:REF /OPT:ICF)

# UNICODE is deliberately left undefined: the vendored API headers call GetModuleHandle with
# narrow string literals, which only resolve against the ANSI variant. Upstream builds the same way.
target_compile_definitions(${PROJECT_NAME}
        PRIVATE
        WIN32_LEAN_AND_MEAN
        NOMINMAX)

target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src)

target_precompile_headers(${PROJECT_NAME} PRIVATE src/pch.h)
