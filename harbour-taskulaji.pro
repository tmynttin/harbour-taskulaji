# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-taskulaji

CONFIG += sailfishapp_qml

DISTFILES += \
    qml/components/AudioPlayer.qml \
    qml/components/BarChart.qml \
    qml/components/DynamicMapWidget.qml \
    qml/components/LineChart.qml \
    qml/components/StaticMapWidget.qml \
    qml/cover/CoverPage.qml \
    qml/js/areas.js \
    qml/pages/*.qml \
    qml/components/*.qml \
    qml/js/*.js \
    qml/pages/OccurrencePage.qml \
    qml/pages/StatisticsPage.qml \
    qml/pages/UnitListPage.qml \
    rpm/harbour-taskulaji.changes.in \
    rpm/harbour-taskulaji.changes.run.in \
    rpm/harbour-taskulaji.spec \
    rpm/harbour-taskulaji.yaml \
    translations/*.ts \
    harbour-taskulaji.desktop \
    qml/harbour-taskulaji.qml \
    translations/harbour-taskulaji-fi_FI.qm \
    translations/harbour-taskulaji-sv.qm \
    qml/pages/TaxoInfoPage.qml \
    qml/pages/ImagePage.qml \
    qml/pages/TextPage.qml \
    qml/pages/UnitPage.qml \
    qml/pages/WebPage.qml \
    qml/components/TaxoListDelegate.qml \
    qml/pages/ObservationMapPage.qml \
    qml/pages/ObservationMapSettingPage.qml \
    qml/pages/DocumentInfoPage.qml \
    qml/pages/ObservationConfirmationPage.qml \
    qml/pages/ResendPage.qml \
    qml/pages/SettingsPage.qml

SAILFISHAPP_ICONS = 86x86 108x108 128x128

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

QT += positioning location

# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-taskulaji-sv.ts \
                translations/harbour-taskulaji-fi_FI.ts

lupdate_only{
    SOURCES = \
        qml/*.qml \
        qml/components/*.qml \
        qml/cover/*.qml \
        qml/pages/*.qml
}
