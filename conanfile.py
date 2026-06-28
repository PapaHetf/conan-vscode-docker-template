from conan import ConanFile
from conan.tools.cmake import CMake, cmake_layout, CMakeToolchain, CMakeDeps
from conan.tools.files import copy
import os


class ExConanConan(ConanFile):
    name = "ex_conan"
    version = "1.0"
    description = "Example C++ project with Conan and Docker"
    
    settings = "os", "compiler", "build_type", "arch"
    options = {"shared": [True, False], "fPIC": [True, False]}
    default_options = {"shared": False, "fPIC": True}
    
    exports_sources = "src/*", "CMakeLists.txt", "include/*"
    
    def config_options(self):
        if self.settings.os == "Windows":
            del self.options.fPIC
    
    def configure(self):
        if self.options.shared:
            del self.options.fPIC
    
    def layout(self):
        cmake_layout(self)
    
    def generate(self):
        tc = CMakeToolchain(self)
        tc.generate()
        
        deps = CMakeDeps(self)
        deps.generate()
    
    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()
    
    def package(self):
        # Копировать бинарник из build/Release/bin
        copy(self, "ex_conan_app", 
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