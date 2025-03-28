#include <QApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <custom_db.h>
#include <gtest/gtest.h>

int main(int argc, char *argv[])
{
    #ifdef TEST_BUILD
        testing::InitGoogleTest(&argc, argv);
        return RUN_ALL_TESTS();
    #else
        QApplication app(argc, argv);
        qmlRegisterType<CustomDB>("CustomComponents",1,0,"CustomDB");
        QQmlApplicationEngine engine;
        QObject::connect(
            &engine,
            &QQmlApplicationEngine::objectCreationFailed,
            &app,
            []() { QCoreApplication::exit(-1); },
            Qt::QueuedConnection);
        engine.loadFromModule("Expenditure-manager", "Main");

        return app.exec();
    #endif
}
