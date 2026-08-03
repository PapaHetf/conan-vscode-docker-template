from conan import ConanFile
from conan.tools.cmake import CMake, cmake_layout, CMakeToolchain, CMakeDeps
from conan.tools.files import copy
from conan.tools.build import can_run
import os


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
    options = {"shared": [True, False], "fPIC": [True, False]}
    default_options = {"shared": False, "fPIC": True}

    exports_sources = "src/*", "CMakeLists.txt", "include/*", "cmake/*"

    def config_options(self):
        if self.settings.os == "Windows":
            del self.options.fPIC

        self.options["boost"].without_all = True
        self.options["boost"].without_program_options = False
    def configure(self):
        if self.options.shared:
            del self.options.fPIC

    def requirements(self):
        self.requires("spdlog/1.12.0")       # Логирование
        self.requires("fmt/10.2.1")          # Форматирование строк
        self.requires("libpq/15.4")          # PostgreSQL C client library
        self.requires("libpqxx/7.9.2")       # PostgreSQL C++ client library
        self.requires("ctre/3.9.0")          # Compile-time regular expressions
        self.requires("openssl/3.0.15", force=True)        # OpenSSL cryptography
        self.requires("boost/1.86.0")

    def layout(self):
        cmake_layout(self)

    def generate(self):
        tc = CMakeToolchain(self)

        openssl_package_folder = self.dependencies["openssl"].package_folder
        engines_dir = f"{openssl_package_folder}/lib/engines-1.1"
        
        # Передаем переменную прямо в кэш CMake
        tc.cache_variables["OPENSSL_ENGINES_DIR"] = engines_dir
        tc.generate()

        deps = CMakeDeps(self)
        deps.generate()

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def test(self):
        if can_run(self):
            bin_path = os.path.join(self.cpp.build.bindirs[0], "program-{}".format(self.version))
            self.run(bin_path, env="conanrun")

    def package(self):
        # Динамическое имя таргета: program-{major}.{minor}.{patch}
        target_name = f"program-{self.version}"

        # Копировать бинарник из build/Release/bin
        copy(self, target_name,
             src=os.path.join(self.build_folder, "bin"),
             dst=os.path.join(self.package_folder, "bin"),
             keep_path=False)

        copy(self, "*.exe",
             src=os.path.join(self.build_folder, "bin"),
             dst=os.path.join(self.package_folder, "bin"),
             keep_path=False)

        # Копировать библиотеки
        copy(self, "*.lib",
             src=os.path.join(self.build_folder, "lib"),
             dst=os.path.join(self.package_folder, "lib"),
             keep_path=False)
        copy(self, "*.so*",
             src=os.path.join(self.build_folder, "lib"),
             dst=os.path.join(self.package_folder, "lib"),
             keep_path=False)
        copy(self, "*.dylib",
             src=os.path.join(self.build_folder, "lib"),
             dst=os.path.join(self.package_folder, "lib"),
             keep_path=False)
        copy(self, "*.a",
             src=os.path.join(self.build_folder, "lib"),
             dst=os.path.join(self.package_folder, "lib"),
             keep_path=False)

        # Копировать заголовочные файлы
        copy(self, "*.h",
             src=os.path.join(self.source_folder, "include"),
             dst=os.path.join(self.package_folder, "include"),
             keep_path=True)

    def package_info(self):
        self.cpp_info.bindirs = ["bin"]
        self.cpp_info.libdirs = ["lib"]
        self.cpp_info.includedirs = ["include"]