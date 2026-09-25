import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        // qmllint disable unqualified
        name: i18nc("@title:group for configuration dialog page", "General")
        // qmllint enable unqualified
        icon: "preferences-desktop-plasma"
        source: "ConfigGeneral.qml"
    }
}
