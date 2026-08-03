# ============================================================
# Предупреждения компилятора для таргетов проекта
# ============================================================
# Использование:
#   set_project_warnings(<target>)
#
# Сторонний код (libraries/, зависимости Conan) не затрагивается.
# -DWARNINGS_AS_ERRORS=ON превращает предупреждения в ошибки (удобно в CI).
# ============================================================

option(WARNINGS_AS_ERRORS "Treat compiler warnings as errors" OFF)

function(set_project_warnings target)
    if(MSVC)
        set(_warnings /W4 /permissive-)
        if(WARNINGS_AS_ERRORS)
            list(APPEND _warnings /WX)
        endif()
    else()
        set(_warnings
            -Wall
            -Wextra
            -Wpedantic
            -Wshadow
            -Wnon-virtual-dtor
            -Wold-style-cast
            -Wcast-align
            -Woverloaded-virtual
            -Wconversion
            -Wsign-conversion
            -Wnull-dereference
            -Wdouble-promotion
            -Wformat=2
            -Wimplicit-fallthrough
        )
        if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
            list(APPEND _warnings
                -Wmisleading-indentation
                -Wduplicated-cond
                -Wduplicated-branches
                -Wlogical-op
                -Wuseless-cast
            )
        endif()
        if(WARNINGS_AS_ERRORS)
            list(APPEND _warnings -Werror)
        endif()
    endif()

    target_compile_options(${target} PRIVATE $<$<COMPILE_LANGUAGE:CXX>:${_warnings}>)
endfunction()
