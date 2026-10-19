/*
    SPDX-FileCopyrightText: 2011 Martin Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2012 Gregor Taetzner <gregor@freenet.de>
    SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013 David Edmundson <davidedmundson@kde.org>
    SPDX-FileCopyrightText: 2015 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// qmllint disable missing-property
pragma ComponentBehavior: Bound

import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

// "Center on screen" mode: a floating dialog holding a separate full
// representation. The representation is created lazily by ensure() so a second
// launcher tree isn't kept in memory while the option is off.
Item {
    id: root

    required property var kickoffItem

    property alias popupVisible: centerDialog.visible
    property Item floatingFullRepItem: null

    function ensure() {
        if (!floatingFullRepItem) {
            floatingFullRepItem = floatingFullRepComponent.createObject(host)
        }
    }

    // Hidden host gives the created object a deterministic parent without
    // painting it; the dialog reparents it into its content item when shown.
    Item {
        id: host
        visible: false
        width: 0
        height: 0
    }

    PlasmaCore.Dialog {
        id: centerDialog
        location: PlasmaCore.Types.Floating
        visible: false
        onVisibleChanged: visible => {
            if (visible) {
                const item = root.floatingFullRepItem
                if (item) {
                    x = Math.round((Screen.width - item.width) / 2)
                    y = Math.round((Screen.height - item.height) / 2)
                }

                // Force KWin to give the dialog keyboard focus
                centerDialog.requestActivate()

                // Force the search box to grab typing cursor
                if (root.kickoffItem.searchField) {
                    root.kickoffItem.searchField.forceActiveFocus(Qt.OtherFocusReason)
                }
            }
        }
        hideOnWindowDeactivate: root.kickoffItem.hideOnWindowDeactivate
        flags: root.kickoffItem.hideOnWindowDeactivate ? (Qt.Dialog | Qt.FramelessWindowHint) : (Qt.Dialog | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint)
        onWindowDeactivated: {
            if (root.kickoffItem.hideOnWindowDeactivate) {
                visible = false;
            }
        }

        mainItem: root.floatingFullRepItem
    }

    Component {
        id: floatingFullRepComponent
        FullRepresentation {
            id: floatingFullRep
            kickoffItem: root.kickoffItem
            width: Plasmoid.configuration.popupWidth > 0 ? Plasmoid.configuration.popupWidth : Math.max(Kirigami.Units.gridUnit * 36, implicitWidth)
            height: Plasmoid.configuration.popupHeight > 0 ? Plasmoid.configuration.popupHeight : Kirigami.Units.gridUnit * 20
            focus: true
        }
    }
}
