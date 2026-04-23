add_library(ProjectPotatoDLL SHARED
    src/main.cpp
    src/main_window.hpp
    src/worker_grid.hpp
)

target_link_libraries(ProjectPotatoDLL PRIVATE 
    potato_shared
    Qt6::Widgets 
    glaze::glaze 
    OpenSSL::SSL
)

# Enforce 4-byte alignment for 32-bit compat as per plan
target_compile_options(ProjectPotatoDLL PRIVATE /Zp4)

# Force the DLL to output to the shared bin folder
set_target_properties(ProjectPotatoDLL PROPERTIES 
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)