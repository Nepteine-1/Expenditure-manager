cmake_minimum_required(VERSION 3.16)

project(Expenditure-manager VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Sql Widgets)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appExpenditure-manager
    main.cpp
)

qt_add_qml_module(appExpenditure-manager
    URI Expenditure-manager
    VERSION 1.0
    QML_FILES
        Main.qml
        SOURCES custom_db.h custom_db.cpp
        QML_FILES Temp.qml
        QML_FILES
        SOURCES
        SOURCES
        QML_FILES ExpenditureList.qml
        QML_FILES
        QML_FILES AddExpenditureWidget.qml
        QML_FILES
        QML_FILES CreateCategory.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appExpenditure-manager PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.Expenditure-manager
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appExpenditure-manager
    PRIVATE Qt6::Quick Qt6::Sql Qt6::Widgets
)

include(GNUInstallDirs)
install(TARGETS appExpenditure-manager
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
