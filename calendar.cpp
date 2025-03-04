#include <calendar.h>
#include <QQuickWindow>
#include <QWidget>

CustomCalendar::CustomCalendar(QQuickItem *parent)
    : QQuickItem(parent), m_calendarWidget(new QCalendarWidget), m_container(nullptr)
{
    setFlag(ItemHasContents, true);
}

CustomCalendar::~CustomCalendar()
{
    delete m_calendarWidget;
    delete m_container;
}

QCalendarWidget* CustomCalendar::calendarWidget() const
{
    return m_calendarWidget;
}

void CustomCalendar::initialize()
{
    if (window()) {
        qDebug() << "Window is valid, creating container.";
        m_container = QWidget::createWindowContainer(m_calendarWidget, window());
        if (m_container) {
            qDebug() << "Container created, setting geometry.";
            m_container->setGeometry(mapToGlobal(QPoint(0, 0)).x(),
                                     mapToGlobal(QPoint(0, 0)).y(),
                                     width(), height());
            m_container->setVisible(true);
        } else {
            qDebug() << "Failed to create container.";
        }
    } else {
        qDebug() << "Window is not valid.";
    }

    if (m_calendarWidget) {
        qDebug() << "CalendarWidget is valid.";
    } else {
        qDebug() << "CalendarWidget is not valid.";
    }
}

void CustomCalendar::updateCalendarWidgetPosition()
{
    if (m_container && window()) {
        qDebug() << "Updating CalendarWidget position.";
        m_container->setGeometry(mapToGlobal(QPoint(0, 0)).x(),
                                 mapToGlobal(QPoint(0, 0)).y(),
                                 width(), height());
    } else {
        qDebug() << "Container or Window is not valid.";
    }
}
