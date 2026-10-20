import QtQuick
import org.kde.plasma.configuration
import "../ui"

ConfigModel {
    ConfigCategory {
        name: Translations.tr("General")
        icon: "preferences-desktop-plasma"
        source: "ConfigGeneral.qml"
    }
}
