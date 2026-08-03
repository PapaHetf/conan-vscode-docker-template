add_library(module_src STATIC
    args/program_args.cpp
)

target_include_directories(module_src PUBLIC
    .
    ${CMAKE_BINARY_DIR}
    args
)

target_link_libraries(module_src
    PUBLIC
    Threads::Threads
    ${LIBRARIES}
    ${EXTERNAL_LIBRARIES}
)

set_project_warnings(module_src)
enable_sanitizers(module_src)
enable_clang_tidy(module_src)
