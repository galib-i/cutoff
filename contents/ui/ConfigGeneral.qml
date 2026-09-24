/*
    SPDX-FileCopyrightText: 2013 David Edmundson <davidedmundson@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
    SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg as KSvg
import org.kde.iconthemes as KIconThemes
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.config as KConfig
import org.kde.plasma.plasmoid

import "code/tools.js" as Tools

KCM.SimpleKCM {
    id: root

    property string cfg_menuLabel: menuLabel.text
    property string cfg_icon: Plasmoid.configuration.icon
    property alias cfg_appNameFormat: appNameFormat.currentIndex
    property var cfg_systemFavorites: String(Plasmoid.configuration.systemFavorites)
    property int cfg_primaryActions: Plasmoid.configuration.primaryActions
    property alias cfg_showActionButtonCaptions: showActionButtonCaptions.checked
    property alias cfg_compactMode: compactModeCheckbox.checked
    property alias cfg_centerOnScreen: centerOnScreenCheckbox.checked
    property alias cfg_popupWidth: popupWidthSpinBox.value
    property alias cfg_popupHeight: popupHeightSpinBox.value
    property alias cfg_showConfigureButton: showConfigureButtonCheckbox.checked
    property alias cfg_highlightNewlyInstalledApps: highlightNewlyInstalledAppsCheckbox.checked

    // Catch these to avoid warnings
    property int cfg_appNameFormatDefault
    property bool cfg_compactModeDefault
    property bool cfg_centerOnScreenDefault
    property int cfg_popupWidthDefault
    property int cfg_popupHeightDefault
    property bool cfg_showConfigureButtonDefault
    property bool cfg_highlightNewlyInstalledAppsDefault
    property string cfg_iconDefault
    property string cfg_menuLabelDefault
    property int cfg_primaryActionsDefault
    property bool cfg_showActionButtonCaptionsDefault
    property var cfg_systemFavoritesDefault

    Kirigami.FormLayout {
        QQC2.Button {
            id: iconButton

            Kirigami.FormData.label: i18nc("@label prefix for icon-only button", "Icon:")

            implicitWidth: previewFrame.width + Kirigami.Units.smallSpacing * 2
            implicitHeight: previewFrame.height + Kirigami.Units.smallSpacing * 2
            hoverEnabled: true

            Accessible.name: i18nc("@action:button", "Change Application Launcher's icon")
            Accessible.description: i18nc("@info:whatsthis", "Current icon is %1. Click to open menu to change the current icon or reset to the default icon.", root.cfg_icon)
            Accessible.role: Accessible.ButtonMenu

            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
            QQC2.ToolTip.text: i18nc("@info:tooltip", "Icon name is \"%1\"", root.cfg_icon)
            QQC2.ToolTip.visible: iconButton.hovered && root.cfg_icon.length > 0

            KIconThemes.IconDialog {
                id: iconDialog
                onAccepted: {
                    root.cfg_icon = iconName || Tools.defaultIconName;
                }
            }

            onPressed: iconMenu.opened ? iconMenu.close() : iconMenu.open()

            KSvg.FrameSvgItem {
                id: previewFrame
                anchors.centerIn: parent
                imagePath: Plasmoid.formFactor === PlasmaCore.Types.Vertical || Plasmoid.formFactor === PlasmaCore.Types.Horizontal
                        ? "widgets/panel-background" : "widgets/background"
                width: Kirigami.Units.iconSizes.large + fixedMargins.left + fixedMargins.right
                height: Kirigami.Units.iconSizes.large + fixedMargins.top + fixedMargins.bottom

                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.large
                    height: width
                    source: Tools.iconOrDefault(Plasmoid.formFactor, root.cfg_icon)
                }
            }

            QQC2.Menu {
                id: iconMenu

                // Appear below the button
                y: parent.height

                QQC2.MenuItem {
                    text: i18nc("@item:inmenu Open icon chooser dialog", "Choose…")
                    icon.name: "document-open-folder"
                    Accessible.description: i18nc("@info:whatsthis", "Choose an icon for Application Launcher")
                    onClicked: iconDialog.open()
                }
                QQC2.MenuItem {
                    text: i18nc("@item:inmenu Reset icon to default", "Reset to default icon")
                    icon.name: "edit-clear"
                    enabled: root.cfg_icon !== Tools.defaultIconName
                    onClicked: root.cfg_icon = Tools.defaultIconName
                }
                QQC2.MenuItem {
                    text: i18nc("@action:inmenu", "Remove icon")
                    icon.name: "delete"
                    enabled: root.cfg_icon !== "" && menuLabel.text && Plasmoid.formFactor !== PlasmaCore.Types.Vertical
                    onClicked: root.cfg_icon = ""
                }
            }
        }

        Kirigami.ActionTextField {
            id: menuLabel
            enabled: Plasmoid.formFactor !== PlasmaCore.Types.Vertical
            Kirigami.FormData.label: i18nc("@label:textbox", "Text label:")
            text: Plasmoid.configuration.menuLabel
            placeholderText: i18nc("@info:placeholder", "Type here to add a text label")
            onTextEdited: {
                root.cfg_menuLabel = menuLabel.text

                // This is to make sure that we always have a icon if there is no text.
                // If the user remove the icon and remove the text, without this, we'll have no icon and no text.
                // This is to force the icon to be there.
                if (!menuLabel.text) {
                    root.cfg_icon = root.cfg_icon || Tools.defaultIconName
                }
            }
            rightActions: QQC2.Action {
                icon.name: "edit-clear"
                enabled: menuLabel.text !== ""
                text: i18nc("@action:button", "Reset menu label")
                onTriggered: {
                    menuLabel.clear()
                    root.cfg_menuLabel = ""
                    root.cfg_icon = root.cfg_icon || Tools.defaultIconName
                }
            }
        }

        QQC2.Label {
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 25
            visible: Plasmoid.formFactor === PlasmaCore.Types.Vertical
            text: i18nc("@info", "A text label cannot be set when the Panel is vertical.")
            wrapMode: Text.Wrap
            font: Kirigami.Theme.smallFont
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.ComboBox {
            id: appNameFormat
            Kirigami.FormData.label: i18nc("Appearance options", "Appearance:")
            model: [i18nc("@item:inlistbox", "Name only"), i18nc("@item:inlistbox", "Description only"), i18nc("@item:inlistbox", "Name (Description)"), i18nc("@item:inlistbox", "Description (Name)")]
        }

        QQC2.CheckBox {
            id: compactModeCheckbox
            text: i18nc("@option:check", "Use compact list item style")
            checked: Plasmoid.configuration.compactMode
        }

        QQC2.CheckBox {
            id: showConfigureButtonCheckbox
            text: i18n("Show settings icon in menu")
            checked: Plasmoid.configuration.showConfigureButton
        }

        QQC2.CheckBox {
            id: highlightNewlyInstalledAppsCheckbox
            text: i18nc("@option:check", "Highlight newly-installed applications")
        }

        Item {
            Kirigami.FormData.isSection: true
        }
        
        QQC2.CheckBox {
            id: centerOnScreenCheckbox
            Kirigami.FormData.label: i18n("Menu:")
            text: i18nc("@option:check", "Center on screen")
            checked: Plasmoid.configuration.centerOnScreen
        }

        RowLayout {
            Kirigami.FormData.label: i18nc("@label:spinbox", "Popup Width:")
            QQC2.SpinBox {
                id: popupWidthSpinBox
                enabled: centerOnScreenCheckbox.checked
                from: 0
                to: 1000
                stepSize: 50
                value: Plasmoid.configuration.popupWidth
            }
            QQC2.Label {
                text: "(0 = Auto)"
            }
        }
        
        RowLayout {
            Kirigami.FormData.label: i18nc("@label:spinbox", "Popup Height:")
            QQC2.SpinBox {
                id: popupHeightSpinBox
                enabled: centerOnScreenCheckbox.checked
                from: 0
                to: 1000
                stepSize: 50
                value: Plasmoid.configuration.popupHeight
            }
            QQC2.Label {
                text: "(0 = Auto)"
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.RadioButton {
            id: powerActionsButton
            Kirigami.FormData.label: i18nc("@title:group prefix for radio button group", "Footer Buttons:")
            text: i18nc("@option:radio Show buttons for", "Power")
            QQC2.ButtonGroup.group: radioGroup
            property string actions: "suspend,hibernate,reboot,shutdown"
            property int index: 0
            checked: Plasmoid.configuration.primaryActions === index
        }

        QQC2.RadioButton {
            id: sessionActionsButton
            text: i18nc("@option:radio Show buttons for", "Session")
            QQC2.ButtonGroup.group: radioGroup
            property string actions: "lock-screen,logout,save-session,switch-user"
            property int index: 1
            checked: Plasmoid.configuration.primaryActions === index
        }

        QQC2.RadioButton {
            id: allActionsButton
            text: i18nc("@option:radio Show buttons for", "Power and session")
            QQC2.ButtonGroup.group: radioGroup
            property string actions: "lock-screen,logout,save-session,switch-user,suspend,hibernate,reboot,shutdown"
            property int index: 3
            checked: Plasmoid.configuration.primaryActions === index
        }

        QQC2.CheckBox {
            id: showActionButtonCaptions
            text: i18nc("@option:check", "Show action button captions")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.Button {
            Kirigami.FormData.label: i18n("Search:")
            enabled: KConfig.KAuthorized.authorizeControlModule("kcm_plasmasearch")
            icon.name: "settings-configure"
            text: i18nc("@action:button opens plasmasearch kcm", "Configure Search Plugins…")
            onClicked: KCM.KCMLauncher.openSystemSettings("kcm_plasmasearch")
        }
    }

    QQC2.ButtonGroup {
        id: radioGroup
        onCheckedButtonChanged: {
            if (checkedButton) {
                root.cfg_primaryActions = checkedButton.index
                root.cfg_systemFavorites = checkedButton.actions
            }
        }
    }
}
