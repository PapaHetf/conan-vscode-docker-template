add_library(module_src STATIC
    args/program_args.cpp
)   

target_include_directories(module_src PUBLIC
    .
    ${CMAKE_BINARY_DIR}
    inc
    args
    pfx
)

target_link_libraries(module_src
    PUBLIC
    pthread
    rt
    ${LIBRARIES}
    ${EXTERNAL_LIBRARIES}
)
