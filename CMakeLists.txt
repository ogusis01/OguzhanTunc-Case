cmake_minimum_required(VERSION 3.16)

project(bozankaya VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appbozankaya
    Main.cpp
)

qt_add_qml_module(appbozankaya
    URI bozankaya
    VERSION 1.0
    QML_FILES
        Main.qml
    SOURCES
        xmlparser.h
        xmlparser.cpp
        udpscanner.h
        udpscanner.cpp
        udplistener.h
        udplistener.cpp
        udppublisher.h
        udppublisher.cpp
        canmanager.h
        canmanager.cpp
    RESOURCES
        resources.qrc
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appbozankaya PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appbozankaya
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appbozankaya
    PRIVATE
    Qt6::Quick
    Qt6::Core
    Qt6::Qml
    Qt6::Quick
    Qt6::Xml
)

include(GNUInstallDirs)
install(TARGETS appbozankaya
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
find_package(Qt6 REQUIRED COMPONENTS Core Qml Quick Xml)

qt_add_resources(appbozankaya "resources"
    PREFIX "/"
    FILES
        Main.qml
        images/sample.png
)
