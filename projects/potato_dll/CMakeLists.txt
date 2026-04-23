add_library(ProjectPotatoDLL SHARED
    src/main.cpp
)

target_link_libraries(ProjectPotatoDLL PRIVATE 
    potato_shared
    Qt6::Widgets 
    glaze::glaze 
    OpenSSL::SSL
)

# Enforce 4-byte alignment for 32-bit compat as per plan
target_compile_options(ProjectPotatoDLL PRIVATE /Zp4)