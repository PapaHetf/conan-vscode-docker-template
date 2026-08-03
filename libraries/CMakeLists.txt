# gost-engine использует -Werror, что вызывает ложные ошибки на некоторых компиляторах
# Отключаем -Werror только для gost-engine через сохранение/восстановление CMAKE_C_FLAGS
set(_saved_cflags "${CMAKE_C_FLAGS}")
string(APPEND CMAKE_C_FLAGS " -Wno-error=stringop-overflow")
add_subdirectory(gost-engine)
set(CMAKE_C_FLAGS "${_saved_cflags}")

set(LIBRARIES
    gost_core
    gost_prov_static
    libprov
    PARENT_SCOPE
)
