/*
 *    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
 *    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 *
 *    SPDX-License-Identifier: GPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import org.kde.plasma.components as PC3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

PlasmaExtras.PlasmoidHeading {
    id: root

    required property var kickoffItem

    readonly property alias leaveButtons: leaveButtons

    contentWidth: spacing
    contentHeight: leaveButtons.implicitHeight

    // We use an increased vertical padding to improve touch usability
    leftPadding: root.kickoffItem.backgroundMetrics.leftPadding
    rightPadding: root.kickoffItem.backgroundMetrics.rightPadding
    topPadding: Kirigami.Units.smallSpacing * 2
    bottomPadding: Kirigami.Units.smallSpacing * 2

    topInset: 0
    leftInset: 0
    rightInset: 0
    bottomInset: 0

    spacing: root.kickoffItem.backgroundMetrics.spacing
    position: PC3.ToolBar.Footer

    LeaveButtons {
        id: leaveButtons
        kickoffItem: root.kickoffItem

        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }

        // available width for leaveButtons

        maximumWidth: root.availableWidth - root.spacing // qmllint disable missing-property


        Keys.onUpPressed: event => {
            root.kickoffItem.lastCentralPane.forceActiveFocus(Qt.BacktabFocusReason);
        }
    }

    Behavior on height {
        enabled: root.kickoffItem.isMenuOpen
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InQuad
        }
    }


}
