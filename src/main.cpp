#include <iostream>
#include "hello.h"

int main(int argc, char* argv[]) {
    std::cout << "Hello from Conan + Docker + VSCode!" << std::endl;
    printHello();

    // Демонстрация аргументов командной строки
    if (argc > 1) {
        std::cout << "\nArguments received:" << std::endl;
        for (int i = 1; i < argc; ++i) {
            std::cout << "  [" << i << "] " << argv[i] << std::endl;
        }
    } else {
        std::cout << "\nNo arguments provided." << std::endl;
    }

    std::cout << "Usage: ./program-{major}.{minor}.{patch} [args...]" << std::endl;

    return 0;
}