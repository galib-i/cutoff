/*
    SPDX-FileCopyrightText: 2011 Martin Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2015-2018 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick

FocusScope {
    id: root

    required property var kickoffItem

    property alias contentAreaComponent: contentAreaLoader.sourceComponent
    property alias contentAreaItem: contentAreaLoader.item

    implicitWidth: contentAreaLoader.implicitWidth
    implicitHeight: Math.max(contentAreaLoader.implicitHeight, Math.round(Screen.desktopAvailableHeight * 0.75))

    Loader {
        id: contentAreaLoader
        focus: true
        anchors.fill: parent

        Keys.onTabPressed: event => {
            root.kickoffItem.footer.nextItemInFocusChain().forceActiveFocus(Qt.TabFocusReason)
        }
        Keys.onBacktabPressed: event => {
            root.kickoffItem.header.avatar.forceActiveFocus(Qt.BacktabFocusReason)
        }
        Keys.onUpPressed: event => {
            root.kickoffItem.searchField.forceActiveFocus(Qt.BacktabFocusReason);
        }
        Keys.onDownPressed: event => {
            root.kickoffItem.footer.leaveButtons.nextItemInFocusChain().forceActiveFocus(Qt.TabFocusReason)
        }
    }
}
