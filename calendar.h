#ifndef CALENDAR_H
#define CALENDAR_H

#include <QCalendarWidget>
#include <QQuickItem>

class CustomCalendar : public QQuickItem
{
    Q_OBJECT

public:
    CustomCalendar(QQuickItem *parent = nullptr);
    ~CustomCalendar();

    QCalendarWidget* calendarWidget() const;

public slots:
    void initialize();

private slots:
    void updateCalendarWidgetPosition();

private:
    QCalendarWidget *m_calendarWidget;
    QWidget *m_container;
};

#endif // CALENDAR_H
