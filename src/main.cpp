#include <iostream>
#include "hello.h"

// Conan-зависимости: fmt и spdlog
#include <fmt/core.h>
#include <spdlog/spdlog.h>

int main(int argc, char* argv[]) {
    // spdlog — установка уровня логирования
    spdlog::set_level(spdlog::level::debug);
    spdlog::debug("Starting main() with {} argument(s)", argc);

    // fmt — форматированный вывод
    std::cout << fmt::format("Hello from Conan + Docker + VSCode!\n");
    printHello();

    // Демонстрация fmt с аргументами
    if (argc > 1) {
        spdlog::info("Processing {} command-line argument(s)", argc - 1);
        std::cout << fmt::format("\nArguments received:\n");
        for (int i = 1; i < argc; ++i) {
            std::cout << fmt::format("  [{}] {}\n", i, argv[i]);
        }
        // Демонстрация printFormatted с первым аргументом
        printFormatted(argv[1], argc);
    } else {
        spdlog::warn("No arguments provided");
        std::cout << fmt::format("\nNo arguments provided.\n");
    }

    std::cout << fmt::format("Usage: ./program-{{major}}.{{minor}}.{{patch}} [args...]\n");

    spdlog::info("Application finished successfully");
    return 0;
}