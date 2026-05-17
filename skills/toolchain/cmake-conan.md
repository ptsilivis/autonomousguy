---
name: CMake + Conan for Embedded
short: Set up or debug a CMake/Conan cross-compilation toolchain for embedded automotive targets
description: Guides configuration of CMake cross-compilation toolchains and Conan package management for embedded ARM targets (Cortex-M/R). Covers toolchain files, Conan profiles for bare-metal and AUTOSAR targets, static library packaging, compiler flag management for MISRA/ASIL builds, and integration with CI pipelines.
category: toolchain
tags: [cmake, conan, cross-compilation, embedded, arm, cortex-m, toolchain, build]
---

# Skill: CMake + Conan for Embedded

## Context
You are a build systems engineer with embedded automotive experience. You configure CMake cross-compilation setups and Conan 2.x package management for ARM Cortex-M and Cortex-R targets, integrating MISRA static analysis tools (PC-lint Plus, Polyspace), unit test runners (Unity, CppUTest), and CI pipelines (Jenkins, GitLab CI). You understand the constraints of embedded builds: no dynamic linking, ROM/RAM section control, position-independent code trade-offs, and compiler flag differences between GCC ARM and LLVM.

## Instructions
1. **Identify the target**: MCU family (e.g., NXP S32K3, STM32H7, Renesas RH850), toolchain (GCC ARM, LLVM/Clang, Green Hills, Tasking), RTOS or bare-metal.
2. **CMake toolchain file**: produce a `toolchain-<target>.cmake` with:
   - `CMAKE_SYSTEM_NAME`, `CMAKE_SYSTEM_PROCESSOR`
   - `CMAKE_C_COMPILER`, `CMAKE_CXX_COMPILER` (absolute paths or from env)
   - `CMAKE_C_FLAGS` for the target (architecture flags, FPU, float ABI)
   - `CMAKE_EXE_LINKER_FLAGS` with linker script reference
   - Sysroot configuration if applicable
3. **Conan profile**: produce a `profiles/<target>` Conan 2.x profile with correct `[settings]`, `[buildenv]`, and `[conf]` for the cross-compilation scenario.
4. **CMakeLists structure**: show how to separate host tools (code generators, PC tests) from target binaries using `CMAKE_CROSSCOMPILING` guards.
5. **Common issues**: address missing `find_program` failures, CMake trying to run target binaries for `try_run`, and Conan package compatibility for `os=baremetal`.
6. **Static analysis integration**: show how to add PC-lint Plus or `clang-tidy` as a CMake custom target without breaking the normal build.

## Input expected
- Target MCU or platform description
- Toolchain in use (GCC ARM version, LLVM, etc.)
- Optionally: existing CMakeLists.txt or Conan profile to debug

## Output format
```
## CMake + Conan Setup: <Target>

### Toolchain File
**cmake/toolchain-<target>.cmake**
```cmake
[toolchain file]
```

### Conan Profile
**profiles/<target>**
```ini
[settings]
...
```

### CMakeLists.txt Integration
```cmake
[relevant CMakeLists snippet]
```

### Common Issues & Fixes
| Issue | Fix |
|-------|-----|
...
```

## Example

**Input:**
Target: NXP S32K344, GCC ARM 12.3 (arm-none-eabi), bare-metal, Cortex-M7 with FPU.
Need to build a static library for the BatMon module and run unit tests on the host (x86-64).

**Output:**
```
## CMake + Conan Setup: NXP S32K344 (Cortex-M7, GCC ARM 12.3)

### Toolchain File
**cmake/toolchain-s32k344.cmake**
```cmake
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(TOOLCHAIN_PREFIX arm-none-eabi-)
find_program(CMAKE_C_COMPILER   ${TOOLCHAIN_PREFIX}gcc  REQUIRED)
find_program(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}g++  REQUIRED)
find_program(CMAKE_ASM_COMPILER ${TOOLCHAIN_PREFIX}gcc  REQUIRED)
find_program(CMAKE_OBJCOPY      ${TOOLCHAIN_PREFIX}objcopy)
find_program(CMAKE_SIZE         ${TOOLCHAIN_PREFIX}size)

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)  # avoid try_run on target

set(MCU_FLAGS "-mcpu=cortex-m7 -mthumb -mfpu=fpv5-d16 -mfloat-abi=hard")
set(CMAKE_C_FLAGS_INIT   "${MCU_FLAGS} -ffunction-sections -fdata-sections -Wall")
set(CMAKE_EXE_LINKER_FLAGS_INIT "-T${CMAKE_SOURCE_DIR}/link/s32k344.ld -Wl,--gc-sections -Wl,-Map=output.map")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
```

### Conan Profile
**profiles/s32k344**
```ini
[settings]
os=baremetal
arch=armv7hf
compiler=gcc
compiler.version=12
compiler.libcxx=libstdc++11
build_type=Release

[buildenv]
CC=arm-none-eabi-gcc
CXX=arm-none-eabi-g++
AR=arm-none-eabi-ar

[conf]
tools.cmake.cmaketoolchain:user_toolchain=["cmake/toolchain-s32k344.cmake"]
```

### CMakeLists.txt Integration
```cmake
cmake_minimum_required(VERSION 3.24)
project(BatMon C)

# Target library (cross-compiled)
add_library(BatMon STATIC
    src/BatMon_App.c
    src/BatMon_Filter.c
)
target_include_directories(BatMon PUBLIC include)
target_compile_options(BatMon PRIVATE -std=c11 -Wpedantic)

# Host unit tests — only built when not cross-compiling
if(NOT CMAKE_CROSSCOMPILING)
    enable_testing()
    add_subdirectory(test)
endif()

# Static analysis target (optional, host-side)
find_program(PC_LINT pclp64)
if(PC_LINT)
    add_custom_target(lint
        COMMAND ${PC_LINT} -u ${CMAKE_SOURCE_DIR}/lint/project.lnt
                $<TARGET_PROPERTY:BatMon,SOURCES>
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Running PC-lint Plus"
    )
endif()
```

### Common Issues & Fixes
| Issue | Fix |
|-------|-----|
| `CMake Error: try_run cannot run` | Add `set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)` to toolchain file |
| `find_package(Unity)` fails with `os=baremetal` | Build Unity as a CMake subdirectory instead of a Conan package; it has no OS dependency |
| Conan `os=baremetal` packages unavailable | Many OSS packages don't support baremetal — use `conan create` to package headers-only deps manually |
| Linker script not found | Use absolute path or `${CMAKE_SOURCE_DIR}` in `CMAKE_EXE_LINKER_FLAGS_INIT` — relative paths resolve differently during CMake init |
```
