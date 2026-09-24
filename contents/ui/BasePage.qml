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
import QtQuick.Layouts
import QtQuick.Templates as T
import org.kde.ksvg as KSvg
import org.kde.plasma.plasmoid

FocusScope {
    id: root

    property alias contentAreaComponent: contentAreaLoader.sourceComponent
    property alias contentAreaItem: contentAreaLoader.item

    implicitWidth: contentAreaLoader.implicitWidth
    implicitHeight: Math.max(contentAreaLoader.implicitHeight, Math.round(Screen.desktopAvailableHeight * 0.75))

    Loader {
        id: contentAreaLoader
        focus: true
        anchors.fill: parent

        Keys.onTabPressed: event => {
            kickoff.footer.nextItemInFocusChain().forceActiveFocus(Qt.TabFocusReason)
        }
        Keys.onBacktabPressed: event => {
            kickoff.header.avatar.forceActiveFocus(Qt.BacktabFocusReason)
        }
        Keys.onUpPressed: event => {
            kickoff.searchField.forceActiveFocus(Qt.BacktabFocusReason);
        }
        Keys.onDownPressed: event => {
            kickoff.footer.leaveButtons.nextItemInFocusChain().forceActiveFocus(Qt.TabFocusReason)
        }
    }
}
