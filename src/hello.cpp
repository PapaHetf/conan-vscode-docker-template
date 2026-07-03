#include "hello.h"
#include <iostream>

// Conan-зависимости: fmt и spdlog
#include <fmt/core.h>
#include <spdlog/spdlog.h>

void printHello() {
    // spdlog — логирование с уровнями
    spdlog::info("Application started");

    // fmt — форматирование строк (как std::format в C++20)
    std::cout << fmt::format("This is a sample C++ application\n");
}

void printFormatted(const std::string& name, int version) {
    // fmt с именованными аргументами
    auto msg = fmt::format("Hello, {0}! You are running version {1}.{2}.{3}",
                           name, version, version + 1, version + 2);
    spdlog::info("Formatted message: {}", msg);
    std::cout << msg << std::endl;
}