cmake_minimum_required(VERSION 3.16)

project(appWebMRISeq VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Quick QuickControls2 Widgets)

include(ExternalProject)

qt_standard_project_setup()


# The JSON for modern C++ package
set(JSON_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/contrib)
set(JSON_LIB ${JSON_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/libjson.so)

ExternalProject_Add(nlohmann_json GIT_REPOSITORY
                https://github.com/nlohmann/json
                CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${JSON_INSTALL_PREFIX}
                BUILD_BYPRODUCTS ${JSON_LIB})

# Incluye el directorio de encabezados de la biblioteca JSON para que puedas incluir sus archivos de encabezado en tu código
include_directories(${JSON_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR})


qt_add_executable(appWebMRISeq
    main.cpp
    backend.cpp
    backend.h
)

add_dependencies(appWebMRISeq nlohmann_json)

set(qml_resource_files
    "qml/Main.qml"
    "qml/BlockItem.qml"
    "qml/ConfigMenu.qml"
    "qml/GlobalMenu.qml"
    "qml/TextInputItem.qml"
    "qml/MenuLabel.qml"
    "qml/ButtonsMenu.qml"
    "qml/PopUp.qml"
    "qml/DeleteButton.qml"
    "qml/Seq_Example.qml"
    "qml/ComboBoxItem.qml"
    "icons/arrow.png"
    "icons/arrow_gray.png"
    "icons/delete_white.png"
    "icons/delete_black.png"
    "icons/dark/angle.png"
    "icons/dark/clock.png"
    "icons/dark/misc.png"
    "icons/dark/readout.png"
    "icons/dark/rf.png"
    "icons/dark/plus.png"
    "icons/dark/epi.png"
    "icons/light/angle.png"
    "icons/light/clock.png"
    "icons/light/misc.png"
    "icons/light/readout.png"
    "icons/light/rf.png"
    "icons/light/plus.png"
    "icons/light/epi.png"
    "icons/balloon.png"
)

qt6_add_resources(appWebMRISeq "qml"
    PREFIX
        "/"
    FILES
        ${qml_resource_files}
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appWebMRISeq PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appFooWasm
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appWebMRISeq
    PRIVATE Qt6::Quick
    PRIVATE Qt6::QuickControls2
    PRIVATE Qt6::Widgets
)

include(GNUInstallDirs)
install(TARGETS appWebMRISeq
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)



