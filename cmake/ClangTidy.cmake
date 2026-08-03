# ============================================================
# clang-tidy во время сборки (необязательно)
# ============================================================
# По умолчанию выключено: clang-tidy и так работает в редакторе через clangd,
# а отдельный прогон есть в scripts/tidy.sh.
# Включить проверку при компиляции:  -DENABLE_CLANG_TIDY=ON
# Правила берутся из .clang-tidy в корне проекта.
# ============================================================

option(ENABLE_CLANG_TIDY "Run clang-tidy while compiling project targets" OFF)

if(ENABLE_CLANG_TIDY)
    find_program(CLANG_TIDY_EXE NAMES clang-tidy REQUIRED)
    message(STATUS "clang-tidy: ${CLANG_TIDY_EXE}")
endif()

function(enable_clang_tidy target)
    if(ENABLE_CLANG_TIDY)
        set_target_properties(${target} PROPERTIES CXX_CLANG_TIDY "${CLANG_TIDY_EXE}")
    endif()
endfunction()
