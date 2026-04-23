cmake_minimum_required(VERSION 3.25)
project(ProjectPotato LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Global compiler settings for MSVC
if(MSVC)
    add_compile_options(/W4 /permissive- /utf-8)
endif()

# Find global dependencies
find_package(Qt6 REQUIRED COMPONENTS Widgets Gui)
find_package(glaze REQUIRED)
find_package(OpenSSL REQUIRED)

# Include sub-projects
add_subdirectory(projects/shared)
add_subdirectory(projects/potato_dll)
add_subdirectory(projects/app)