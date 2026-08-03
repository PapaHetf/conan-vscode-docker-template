# ============================================================
# Санитайзеры (AddressSanitizer + UndefinedBehaviorSanitizer)
# ============================================================
# Использование:
#   enable_sanitizers(<target>)
#
# По умолчанию включены в Debug и выключены в остальных сборках.
# Переопределить:  -DENABLE_SANITIZERS=OFF  (или ON для Release)
#
# Под gdb ASan работает без доп. настроек; в Docker для LeakSanitizer
# нужен SYS_PTRACE (уже задан в docker-compose.yml и devcontainer.json).
# ============================================================

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(_sanitizers_default ON)
else()
    set(_sanitizers_default OFF)
endif()
option(ENABLE_SANITIZERS "Enable ASan + UBSan for project targets" ${_sanitizers_default})

if(ENABLE_SANITIZERS AND NOT MSVC)
    message(STATUS "Sanitizers: address, undefined")
endif()

function(enable_sanitizers target)
    if(NOT ENABLE_SANITIZERS OR MSVC)
        return()
    endif()
    set(_flags -fsanitize=address,undefined -fno-omit-frame-pointer -fno-sanitize-recover=undefined)
    target_compile_options(${target} PRIVATE ${_flags})
    # PUBLIC: для статических библиотек флаги линковки уходят в итоговый исполняемый файл
    target_link_options(${target} PUBLIC -fsanitize=address,undefined)
endfunction()
