# Define the executable
add_executable(ProjectPotato 
    launcher_main.cpp
)

# Force the .exe to build into the exact same folder as the .dll
# This ensures LoadLibrary("ProjectPotatoDLL.dll") works instantly
set_target_properties(ProjectPotato PROPERTIES 
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)