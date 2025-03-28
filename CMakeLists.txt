cmake_minimum_required(VERSION 3.16)

project(Expenditure-manager VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Uncomment the following line to enable test_build with google_test
# add_compile_definitions(TEST_BUILD)

find_package(Qt6 REQUIRED COMPONENTS Quick Sql Widgets)

include_directories(${PROJECT_SOURCE_DIR}/dev/include)
include_directories(${PROJECT_SOURCE_DIR}/lib/googletest-1.15.2/include)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appExpenditure-manager
	dev/src/main.cpp
)

qt_add_qml_module(appExpenditure-manager
    URI Expenditure-manager
    VERSION 1.0
    QML_FILES qml/Main.qml
    SOURCES dev/include/custom_db.h dev/src/custom_db.cpp
    QML_FILES qml/AddExpenditureWidget.qml
    QML_FILES qml/AllListWidget.qml
    QML_FILES qml/ChartPage.qml
    QML_FILES qml/CreateCategory.qml
    QML_FILES qml/ExpenditureList.qml
    QML_FILES qml/ListPresentationCard.qml
    QML_FILES qml/MainPage.qml
    QML_FILES qml/MessageDisplayer.qml
    QML_FILES qml/Temp.qml
    SOURCES test/test_custom_db.cpp
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
    ${PROJECT_SOURCE_DIR}/lib/googletest-1.15.2/lib/libgmock.a
    ${PROJECT_SOURCE_DIR}/lib/googletest-1.15.2/lib/libgmock_main.a
    ${PROJECT_SOURCE_DIR}/lib/googletest-1.15.2/lib/libgtest.a
    ${PROJECT_SOURCE_DIR}/lib/googletest-1.15.2/lib/libgtest_main.a
)

include(GNUInstallDirs)
install(TARGETS appExpenditure-manager
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
