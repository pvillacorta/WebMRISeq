cmake_minimum_required(VERSION 3.16)

project(MRISequenceEditor VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Quick)

qt_standard_project_setup()

qt_add_executable(MRISequenceEditor
    main.cpp
)

qt_add_qml_module(MRISequenceEditor
    URI WebMRISequenceEditor
    RESOURCE_PREFIX /qt/qml
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/BlockItem.qml
        qml/ConfigMenu.qml
        qml/GlobalMenu.qml
        qml/TextInputItem.qml
        qml/MenuLabel.qml
)

qt_add_resources(MRISequenceEditor "icons"
    PREFIX "/"
    FILES
        icons/arrow.png
        icons/delete_white.png
        icons/delete_red.png
        icons/delete_black.png
        icons/loading.gif
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(MRISequenceEditor PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appFooWasm
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(MRISequenceEditor
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS MRISequenceEditor
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
