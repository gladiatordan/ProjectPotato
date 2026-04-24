cmake_minimum_required(VERSION 3.25)

project(ProjectPotato VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

option(PROJECTPOTATO_ENABLE_LEGACY_EXPERIMENTS "Build legacy projects under projects/ as well." OFF)

find_package(Qt6 REQUIRED COMPONENTS Widgets)

qt_standard_project_setup()

qt_add_executable(ProjectPotato
    WIN32
    MANUAL_FINALIZATION
    src/app/main.cpp
    src/core/AppPaths.cpp
    src/core/AppPaths.hpp
    src/core/BuildInfo.hpp
    src/core/ServiceCommand.cpp
    src/core/ServiceCommand.hpp
    src/services/GameService.cpp
    src/services/GameService.hpp
    src/services/IService.hpp
    src/services/LauncherService.cpp
    src/services/LauncherService.hpp
    src/services/LogService.cpp
    src/services/LogService.hpp
    src/services/QueuedServiceBase.cpp
    src/services/QueuedServiceBase.hpp
    src/services/ServiceManager.cpp
    src/services/ServiceManager.hpp
    src/services/ThreadSafeQueue.hpp
    src/services/UpdateService.cpp
    src/services/UpdateService.hpp
    src/services/WorkerService.cpp
    src/services/WorkerService.hpp
    src/ui/MainController.cpp
    src/ui/MainController.hpp
    src/ui/MainWindow.cpp
    src/ui/MainWindow.hpp
    src/ui/delegates/ActionButtonDelegate.cpp
    src/ui/delegates/ActionButtonDelegate.hpp
    src/ui/delegates/CharacterComboDelegate.cpp
    src/ui/delegates/CharacterComboDelegate.hpp
    src/ui/models/AccountTableModel.cpp
    src/ui/models/AccountTableModel.hpp
    src/ui/pages/LauncherPage.cpp
    src/ui/pages/LauncherPage.hpp
    src/ui/pages/SettingsPage.cpp
    src/ui/pages/SettingsPage.hpp
    src/ui/pages/WorkersPage.cpp
    src/ui/pages/WorkersPage.hpp
    src/ui/widgets/LogConsole.cpp
    src/ui/widgets/LogConsole.hpp
    src/ui/widgets/NineSliceFrame.cpp
    src/ui/widgets/NineSliceFrame.hpp
    src/ui/widgets/PotatoHeader.cpp
    src/ui/widgets/PotatoHeader.hpp
    src/ui/widgets/PotatoSidebar.cpp
    src/ui/widgets/PotatoSidebar.hpp
    src/ui/widgets/PotatoWindowControls.cpp
    src/ui/widgets/PotatoWindowControls.hpp
    resources/resources.qrc
)

target_include_directories(ProjectPotato PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src)

target_link_libraries(ProjectPotato PRIVATE Qt6::Widgets)

target_compile_features(ProjectPotato PRIVATE cxx_std_23)

if(MSVC)
    target_compile_options(ProjectPotato PRIVATE /W4 /permissive- /utf-8 /Zc:__cplusplus)
endif()

if(WIN32)
    set(PROJECTPOTATO_QT_PLUGIN_ROOT
        "${CMAKE_BINARY_DIR}/vcpkg_installed/${VCPKG_TARGET_TRIPLET}/$<$<CONFIG:Debug>:debug/>Qt6/plugins")

    add_custom_command(TARGET ProjectPotato POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "$<TARGET_FILE_DIR:ProjectPotato>/platforms"
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            "${PROJECTPOTATO_QT_PLUGIN_ROOT}/platforms"
            "$<TARGET_FILE_DIR:ProjectPotato>/platforms"
        COMMAND ${CMAKE_COMMAND} -E make_directory "$<TARGET_FILE_DIR:ProjectPotato>/imageformats"
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            "${PROJECTPOTATO_QT_PLUGIN_ROOT}/imageformats"
            "$<TARGET_FILE_DIR:ProjectPotato>/imageformats"
        COMMAND ${CMAKE_COMMAND} -E make_directory "$<TARGET_FILE_DIR:ProjectPotato>/styles"
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            "${PROJECTPOTATO_QT_PLUGIN_ROOT}/styles"
            "$<TARGET_FILE_DIR:ProjectPotato>/styles"
        COMMENT "Copying Qt plugin folders for ProjectPotato"
        VERBATIM
    )
endif()

qt_finalize_executable(ProjectPotato)

if(PROJECTPOTATO_ENABLE_LEGACY_EXPERIMENTS)
    find_package(glaze REQUIRED)
    find_package(OpenSSL REQUIRED)

    add_subdirectory(projects/shared)
    add_subdirectory(projects/potato_dll)
    add_subdirectory(projects/app)
endif()
