cmake_minimum_required(VERSION 3.16)

project(appWebMRISequenceEditor VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Quick QuickControls2 Widgets)

qt_standard_project_setup()

qt_add_executable(appWebMRISequenceEditor
    main.cpp
    backend.cpp
    backend.h
)

qt_add_resources(appWebMRISequenceEditor "icons"
    PREFIX "/"
    FILES
        icons/arrow.png
        icons/arrow_gray.png
        icons/delete_white.png
        icons/delete_black.png
        icons/dark/angle.png
        icons/dark/clock.png
        icons/dark/misc.png
        icons/dark/readout.png
        icons/dark/rf.png
        icons/dark/plus.png
        icons/dark/epi.png
        icons/light/angle.png
        icons/light/clock.png
        icons/light/misc.png
        icons/light/readout.png
        icons/light/rf.png
        icons/light/plus.png
        icons/light/epi.png
        icons/balloon.png
)

qt_add_qml_module(appWebMRISequenceEditor
    URI WebMRISequenceEditor
    RESOURCE_PREFIX /
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/BlockItem.qml
        qml/ConfigMenu.qml
        qml/GlobalMenu.qml
        qml/TextInputItem.qml
        qml/MenuLabel.qml
        qml/ButtonsMenu.qml
        qml/PopUp.qml
        qml/DeleteButton.qml
        qml/LoadedSequence.qml
        qml/Seq_Example.qml
)


# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appWebMRISequenceEditor PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appFooWasm
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appWebMRISequenceEditor
    PRIVATE Qt6::Quick
    PRIVATE Qt6::QuickControls2
    PRIVATE Qt6::Widgets
)

include(GNUInstallDirs)
install(TARGETS appWebMRISequenceEditor
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
