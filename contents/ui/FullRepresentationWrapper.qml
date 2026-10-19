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
import QtQuick.Layouts
import org.kde.plasma.plasmoid

// Fixed wrapper where the Loader inside swaps the real content.
// libplasma only builds the full representation once, so the component itself can't be swapped on a config change.
FocusScope {
    id: root

    required property var kickoffItem

    readonly property Item innerItem: popupLoader.item as Item

    // Let the popup size itself from the content's real size.
    Layout.minimumWidth: innerItem ? innerItem.Layout.minimumWidth : 0
    Layout.minimumHeight: innerItem ? innerItem.Layout.minimumHeight : 0
    Layout.preferredWidth: innerItem ? innerItem.Layout.preferredWidth : -1
    Layout.preferredHeight: innerItem ? innerItem.Layout.preferredHeight : -1
    Layout.maximumWidth: innerItem ? innerItem.Layout.maximumWidth : Infinity
    Layout.maximumHeight: innerItem ? innerItem.Layout.maximumHeight : Infinity
    Layout.fillWidth: innerItem ? innerItem.Layout.fillWidth : false
    Layout.fillHeight: innerItem ? innerItem.Layout.fillHeight : false
    implicitWidth: innerItem ? innerItem.implicitWidth : 0
    implicitHeight: innerItem ? innerItem.implicitHeight : 0

    Loader {
        id: popupLoader
        anchors.fill: parent
        sourceComponent: Plasmoid.configuration.centerOnScreen ? root.kickoffItem.compactRepresentation : defaultFullRepresentation
    }

    Component {
        id: defaultFullRepresentation
        FullRepresentation { focus: true; kickoffItem: root.kickoffItem }
    }
}
