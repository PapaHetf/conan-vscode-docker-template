# ============================================================
# Модульные тесты (GoogleTest)
# ============================================================
# Включаются опцией Conan with_tests (по умолчанию True) -> BUILD_TESTING.
#
# Добавить тест:
#   1. создать tests/<name>_test.cpp;
#   2. добавить файл в add_executable ниже.
# Код проекта доступен через module_src (те же include-пути и зависимости).
#
# Запуск:  ./scripts/test.sh   или   ctest --test-dir build/<Type>/tests
# ============================================================

find_package(GTest CONFIG REQUIRED)
include(GoogleTest)

add_executable(unit_tests
    sample_test.cpp
    program_args_test.cpp
)

target_link_libraries(unit_tests
    PRIVATE
    module_src
    GTest::gtest
    GTest::gtest_main
)

set_target_properties(unit_tests PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)
set_project_warnings(unit_tests)
enable_sanitizers(unit_tests)

# Каждый TEST() регистрируется в ctest отдельно
gtest_discover_tests(unit_tests
    DISCOVERY_MODE PRE_TEST
)
