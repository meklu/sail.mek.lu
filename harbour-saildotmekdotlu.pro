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
TARGET = harbour-saildotmekdotlu

CONFIG += sailfishapp

SOURCES += src/harbour-saildotmekdotlu.cpp \
    src/forkprocess.cpp

HEADERS += \
    src/forkprocess.h

OTHER_FILES += qml/harbour-saildotmekdotlu.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/SecondPage.qml \
    rpm/harbour-saildotmekdotlu.changes \
    rpm/harbour-saildotmekdotlu.spec \
    rpm/harbour-saildotmekdotlu.yaml \
    translations/*.ts \
    harbour-saildotmekdotlu.desktop \
    qml/pages/SettingsPage.qml \
    qml/js/db.js

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-saildotmekdotlu-fi.ts

mekdotlu.files = $$PWD/src/mekdotlu/mekdotlu
mekdotlu.commands = CFLAGS= make USE_CAPABILITIES=0 -C $$PWD/src/mekdotlu
mekdotlu.path = /usr/libexec/harbour-saildotmekdotlu

# qmake is stupid and will set 0644 by force
chmodit.commands = chmod +x $(INSTALL_ROOT)/usr/libexec/harbour-saildotmekdotlu/mekdotlu
chmodit.path = /
chmodit.depends = mekdotlu

QMAKE_EXTRA_TARGETS += mekdotlu
PRE_TARGETDEPS += mekdotlu
INSTALLS += mekdotlu chmodit
