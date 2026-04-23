add_library(potato_shared INTERFACE)
target_include_directories(potato_shared INTERFACE include/)
target_link_libraries(potato_shared INTERFACE glaze::glaze)