cmake_minimum_required(VERSION 3.14)
project(ThemeJson LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(QT_QML_GENERATE_QMLLS_INI ON)

find_package(Qt5 COMPONENTS Core Gui Widgets Quick REQUIRED)

qt5_add_resources(QML_RESOURCES src/qml/qml.qrc)

add_executable(ThemeJson 
    src/c++/${PROJECT_NAME}/main.cc
    src/c++/${PROJECT_NAME}/palette_model.cc

    ${QML_RESOURCES}
)

target_include_directories(ThemeJson PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/c++)

target_link_libraries(ThemeJson PRIVATE Qt5::Core Qt5::Gui Qt5::Widgets Qt5::Quick)
