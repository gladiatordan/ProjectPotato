# Define the executable
add_executable(ProjectPotato 
    launcher_main.cpp
)

# Force vcpkg to deploy Qt plugins (like platforms/qwindows.dll) next to the .exe
target_link_libraries(ProjectPotato PRIVATE Qt6::Core)

# Force the .exe to build into the exact same folder as the .dll
# This ensures LoadLibrary("ProjectPotatoDLL.dll") works instantly
set_target_properties(ProjectPotato PROPERTIES 
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

# Dynamically copy the platforms folder based on Debug/Release build
add_custom_command(TARGET ProjectPotato POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory "$<TARGET_FILE_DIR:ProjectPotato>/platforms"
    COMMAND ${CMAKE_COMMAND} -E copy_directory
    "${CMAKE_BINARY_DIR}/vcpkg_installed/${VCPKG_TARGET_TRIPLET}/$<$<CONFIG:Debug>:debug/>plugins/platforms"
    "$<TARGET_FILE_DIR:ProjectPotato>/platforms"
)