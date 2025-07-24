import os
from conan import ConanFile
from conan.tools.cmake import CMake, CMakeToolchain, cmake_layout, CMakeDeps
from conan.tools.build import check_min_cppstd
from conan.tools.files import copy, rmdir


class FlavorRecipe(ConanFile):
    name = "ThemeJson"
    version = "0.7.0"
    description = "Palette/theme library for Qt/QML/JS"
    author = "whs31 <whs31@github.io>"
    topics = ("qt", "qml", "js", "theme", "palette")
    settings = "os", "arch", "compiler", "build_type"
    options = {
        "shared": [True, False],
        "editor": [True, False],
        "test": [True, False],
        "editor": [True, False],
        "qt": [5, 6]
    }
    default_options = {
        "shared": True,
        "test": False,
        "editor": True,
        "qt": 5
    }

    exports_sources = "*"

    @property
    def _min_cppstd(self):
        return "20"

    def requirements(self):
        self.requires("rolly/[>=2.1.45]@radar/dev", transitive_headers=True, transitive_libs=True)
        self.requires("flatbuffers/24.3.25")

    def layout(self):
        cmake_layout(self)

    def validate(self):
        if self.settings.get_safe("compiler.cppstd"):
            check_min_cppstd(self, self._min_cppstd)

    def configure(self):
        pass

    def generate(self):
        deps = CMakeDeps(self)
        deps.generate()
        tc = CMakeToolchain(self)
        tc.cache_variables["BUILD_SHARED_LIBS"] = self.options.shared
        tc.cache_variables["FLAVOR_EDITOR"] = self.options.editor
        tc.cache_variables["FLAVOR_TESTS"] = self.options.test
        tc.variables["FLAVOR_QT_VERSION"] = self.options.qt
        tc.generate()

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def package(self):
        cmake = CMake(self)
        cmake.install()
        rmdir(self, os.path.join(self.package_folder, "lib", "cmake"))
        rmdir(self, os.path.join(self.package_folder, "lib", "pkgconfig"))
        rmdir(self, os.path.join(self.package_folder, "res"))
        rmdir(self, os.path.join(self.package_folder, "share"))

    def package_info(self):
        self.cpp_info.set_property("cmake_file_name", "ThemeJson")
        self.cpp_info.set_property("cmake_target_name", "ThemeJson::ThemeJson")
        self.cpp_info.libs = ["ThemeJson"]
        self.cpp_info.requires = ["rolly::rolly", "flatbuffers::flatbuffers"]
