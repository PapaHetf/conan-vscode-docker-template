from conan import ConanFile
from conan.tools.cmake import CMake, cmake_layout, CMakeToolchain, CMakeDeps
from conan.tools.files import copy
from conan.tools.build import can_run
import os


# Компилируемые компоненты Boost, которые проекту НЕ нужны.
# Нужные (container, program_options) сюда не входят.
# Чтобы включить компонент — удалите его из списка.
_BOOST_DISABLED = (
    "atomic", "charconv", "chrono", "cobalt", "context", "contract",
    "coroutine", "date_time", "exception", "fiber", "filesystem", "graph",
    "graph_parallel", "iostreams", "json", "locale", "log", "math", "mpi",
    "nowide", "process", "python", "random", "regex", "serialization",
    "stacktrace", "system", "test", "thread", "timer", "type_erasure", "url",
    "wave",
)


class ProjectConan(ConanFile):
    # Имя и версия берутся из переменных окружения (с запасными значениями)
    name = os.environ.get("PROJECT_NAME", "my_app")
    version = os.environ.get(
        "PROJECT_VERSION_STRING",
        f'{os.environ.get("PROJECT_VERSION_MAJOR", "0")}'
        f'.{os.environ.get("PROJECT_VERSION_MINOR", "1")}'
        f'.{os.environ.get("PROJECT_VERSION_PATCH", "0")}'
    )
    description = "C++ project with Conan and Docker"

    settings = "os", "compiler", "build_type", "arch"
    options = {
        "shared": [True, False],
        "fPIC": [True, False],
        # Опциональные зависимости шаблона. Включение:
        #   conan install . -o "&:with_postgres=True"
        "with_tests": [True, False],     # GoogleTest + каталог tests/
        "with_postgres": [True, False],  # libpq + libpqxx
        "with_ctre": [True, False],      # compile-time regex
        "with_spdlog": [True, False],    # логирование
    }
    default_options = {
        "shared": False,
        "fPIC": True,
        "with_tests": True,
        "with_postgres": False,
        "with_ctre": False,
        "with_spdlog": False,
        **{f"boost/*:without_{c}": True for c in _BOOST_DISABLED},
    }

    exports_sources = (
        "src/*", "include/*", "cmake/*", "libraries/*", "tests/*",
        "CMakeLists.txt",
    )

    def config_options(self):
        if self.settings.os == "Windows":
            del self.options.fPIC

    def configure(self):
        if self.options.shared:
            self.options.rm_safe("fPIC")

    def requirements(self):
        self.requires("fmt/10.2.1")                  # Форматирование строк
        self.requires("boost/1.86.0")                # program_options, outcome, container
        self.requires("openssl/3.0.15", force=True)  # OpenSSL cryptography

        if self.options.with_spdlog:
            self.requires("spdlog/1.12.0")           # Логирование
        if self.options.with_postgres:
            self.requires("libpq/15.4")              # PostgreSQL C client library
            self.requires("libpqxx/7.9.2")           # PostgreSQL C++ client library
        if self.options.with_ctre:
            self.requires("ctre/3.9.0")              # Compile-time regular expressions

    def build_requirements(self):
        if self.options.with_tests:
            self.test_requires("gtest/1.15.0")

    def layout(self):
        cmake_layout(self)

    def generate(self):
        tc = CMakeToolchain(self)

        # Опции Conan -> переменные CMake
        tc.cache_variables["BUILD_TESTING"] = bool(self.options.with_tests)
        tc.cache_variables["WITH_POSTGRES"] = bool(self.options.with_postgres)
        tc.cache_variables["WITH_CTRE"] = bool(self.options.with_ctre)
        tc.cache_variables["WITH_SPDLOG"] = bool(self.options.with_spdlog)
        tc.generate()

        deps = CMakeDeps(self)
        deps.generate()

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()
        # Запускаем только тесты проекта (у сабмодулей в libraries/ могут быть свои ctest-тесты)
        if self.options.with_tests and can_run(self) \
                and not self.conf.get("tools.build:skip_test", check_type=bool):
            self.run(f'ctest --test-dir "{os.path.join(self.build_folder, "tests")}" '
                     f'--output-on-failure', env="conanrun")

    def package(self):
        # Бинарник: {name}-{major}.{minor}.{patch} (см. cmake/project-config.cmake)
        target_name = f"{self.name}-{self.version}"
        copy(self, target_name,
             src=os.path.join(self.build_folder, "bin"),
             dst=os.path.join(self.package_folder, "bin"),
             keep_path=False)
        copy(self, f"{target_name}.exe",
             src=os.path.join(self.build_folder, "bin"),
             dst=os.path.join(self.package_folder, "bin"),
             keep_path=False)

        # Заголовочные файлы
        copy(self, "*.h",
             src=os.path.join(self.source_folder, "include"),
             dst=os.path.join(self.package_folder, "include"),
             keep_path=True)

    def package_info(self):
        self.cpp_info.bindirs = ["bin"]
        self.cpp_info.libdirs = []
        self.cpp_info.includedirs = ["include"]
