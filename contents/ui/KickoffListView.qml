/*
    SPDX-FileCopyrightText: 2011 Martin Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2012 Gregor Taetzner <gregor@freenet.de>
    SPDX-FileCopyrightText: 2015-2018 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick

import org.kde.plasma.plasmoid
import org.kde.plasma.components as PC3
import org.kde.plasma.extras as PlasmaExtras

import org.kde.kirigami as Kirigami

// ScrollView makes it difficult to control implicit size using the contentItem.
// Using EmptyPage instead.
EmptyPage {
    id: root

    required property var kickoffItem

    property alias model: listViewItem.model
    property alias count: listViewItem.count
    property alias currentIndex: listViewItem.currentIndex
    property alias currentItem: listViewItem.currentItem
    property alias delegate: listViewItem.delegate
    property alias section: listViewItem.section
    property alias view: listViewItem
    property alias movedWithWheel: listViewItem.movedWithWheel
    property alias movedWithKeyboard: listViewItem.movedWithKeyboard

    property bool mainContentView: false
    property bool hasSectionView: false

    /**
     * Request showing the section view
     */

    clip: listViewItem.height < listViewItem.contentHeight

    header: MouseArea {
        implicitHeight: KickoffSingleton.listItemMetrics?.fixedMargins.top ?? 0
        hoverEnabled: root.mainContentView || Plasmoid.configuration.switchCategoryOnHover
        onEntered: {
            if (containsMouse) {
                const targetIndex = listViewItem.indexAt(mouseX + listViewItem.contentX, listViewItem.contentY)
                if (targetIndex >= 0) {
                    listViewItem.currentIndex = targetIndex
                    listViewItem.forceActiveFocus(Qt.MouseFocusReason)
                }
            }
        }
    }

    footer: MouseArea {
        implicitHeight: KickoffSingleton.listItemMetrics?.fixedMargins.bottom ?? 0
        hoverEnabled: root.mainContentView || Plasmoid.configuration.switchCategoryOnHover
        onEntered: {
            if (containsMouse) {
                const targetIndex = listViewItem.indexAt(mouseX + listViewItem.contentX, listViewItem.height + listViewItem.contentY - 1)
                if (targetIndex >= 0) {
                    listViewItem.currentIndex = targetIndex
                    listViewItem.forceActiveFocus(Qt.MouseFocusReason)
                }
            }
        }
    }

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth, // exclude padding to avoid scrollbars automatically affecting implicitWidth
                            implicitHeaderWidth2,
                            implicitFooterWidth2)

    leftPadding: verticalScrollBar.visible ? verticalScrollBar.implicitWidth : 0
    rightPadding: verticalScrollBar.visible && !root.mirrored ? verticalScrollBar.implicitWidth : 0

    contentItem: ListView {
        id: listViewItem

        readonly property real availableWidth: width - leftMargin - rightMargin
        readonly property real availableHeight: height - topMargin - bottomMargin
        property bool movedWithKeyboard: false
        property bool movedWithWheel: false

        Accessible.role: Accessible.List

        implicitWidth: {
            let totalMargins = leftMargin + rightMargin
            if (root.mainContentView) {
                if (root.kickoffItem.mayHaveGridWithScrollBar) {
                    totalMargins += verticalScrollBar.implicitWidth
                }
                return KickoffSingleton.gridCellSize * root.kickoffItem.minimumGridRowCount + totalMargins
            }
            return contentWidth + totalMargins
        }
        implicitHeight: {
            // use grid cells to determine size
            let h = KickoffSingleton.gridCellSize * root.kickoffItem.minimumGridRowCount
            return h + topMargin + bottomMargin
        }

        leftMargin: root.kickoffItem.backgroundMetrics.leftPadding
        rightMargin: root.kickoffItem.backgroundMetrics.rightPadding

        currentIndex: -1
        focus: true
        interactive: height < contentHeight
        pixelAligned: true
        reuseItems: false // explicitly disabled because it doesn't work correctly with switching models like we do
        boundsBehavior: Flickable.StopAtBounds
        // default keyboard navigation doesn't allow focus reasons to be used
        // and eats up/down key events when at the beginning or end of the list.
        keyNavigationEnabled: false
        keyNavigationWraps: false
        highlightResizeDuration: 0
        highlightFollowsCurrentItem: false

        HoverHandler {
            onHoveredChanged: {
                if (!hovered && !listViewItem.movedWithKeyboard) {
                    listViewItem.currentIndex = -1;
                }
            }
        }

        onCountChanged: {
            if (!activeFocus) {
                currentIndex = -1
            } else if (count > 0 && currentIndex !== -1) {
                positionViewAtIndex(currentIndex, ListView.Contain)
            }
        }

        delegate: KickoffListDelegate {
                viewMovedWithWheel: root.movedWithWheel
                viewMovedWithKeyboard: root.movedWithKeyboard
                kickoffItem: root.kickoffItem

                width: listViewItem.availableWidth // qmllint disable missing-property

        }

        // Without switch-on-hover, it's possible for the selected category and the hovered category to be adjacent.
        // When this happens, their highlights touch and look ugly without some artificial spacing added.
        spacing: 0

        section {
            property: "group"
            criteria: ViewSection.FullString
            delegate: PlasmaExtras.ListSectionHeader {
                required property string section


                width: listViewItem.availableWidth // qmllint disable missing-property

                height: KickoffSingleton.compactListDelegateHeight
                text: section.length === 1 ? section.toUpperCase() : section

                HoverHandler {
                    enabled: root.hasSectionView
                    cursorShape: enabled ? Qt.PointingHandCursor : undefined
                }
            }
        }

        move: normalTransition
        moveDisplaced: normalTransition

        Transition {
            id: normalTransition
            NumberAnimation {
                duration: Kirigami.Units.shortDuration
                properties: "x, y"
                easing.type: Easing.OutCubic
            }
        }

        PC3.ScrollBar.vertical: PC3.ScrollBar {
            id: verticalScrollBar
            parent: root
            z: 2
            height: root.height
            anchors.right: parent.right
            leftInset: 0
            rightInset: 0
            background: null
        }

        Kirigami.WheelHandler {
            target: listViewItem
            filterMouseEvents: true
            // `20 * Qt.styleHints.wheelScrollLines` is the default speed.

            horizontalStepSize: 20 * Qt.styleHints.wheelScrollLines // qmllint disable missing-property
            verticalStepSize: 20 * Qt.styleHints.wheelScrollLines // qmllint disable missing-property


            onWheel: wheel => {
                listViewItem.movedWithWheel = true // qmllint disable missing-property
                listViewItem.movedWithKeyboard = false // qmllint disable missing-property
                movedWithWheelTimer.restart()
            }
        }

        Connections {
            target: root.kickoffItem
            function onIsMenuOpenChanged() {
                if (!root.kickoffItem.isMenuOpen) {
                    listViewItem.currentIndex = -1
                    listViewItem.contentY = listViewItem.originY
                }
            }
        }

        Connections {
            target: root.kickoffItem.runnerModel
            enabled: launchMatchTimer.running
            function onQueryFinished() : void {
                launchMatchTimer.stop()
                Qt.callLater(launchMatchTimer.triggered) // callLater to give bindings time to update
            }
        }

        // Used to block hover events temporarily after using keyboard navigation.
        // If you have one hand on the touch pad or mouse and another hand on the keyboard,
        // it's easy to accidentally reset the highlight/focus position to the mouse position.
        Timer {
            id: movedWithKeyboardTimer
            interval: 200
            onTriggered: listViewItem.movedWithKeyboard = false // qmllint disable missing-property
        }

        Timer {
            id: movedWithWheelTimer
            interval: 200
            onTriggered: listViewItem.movedWithWheel = false // qmllint disable missing-property
        }

        Timer {
            id: launchMatchTimer
            interval: 750
            onTriggered: {

                listViewItem.currentItem?.action.trigger(); // qmllint disable missing-property

                root.currentItem.forceActiveFocus(Qt.ShortcutFocusReason);
            }
        }

        onCurrentItemChanged: {

            if (launchMatchTimer.running && listViewItem.currentItem?.text.toLowerCase().includes(root.kickoffItem.runnerModel.query.toLowerCase())) { // qmllint disable missing-property

                launchMatchTimer.stop()
                launchMatchTimer.triggered()
            }
        }

        function focusCurrentItem(event, focusReason) {
            root.currentItem.forceActiveFocus(focusReason)
            positionViewAtIndex(currentIndex, ListView.Contain)
            event.accepted = true
        }

        Keys.onMenuPressed: event => {
            const delegate = root.currentItem as AbstractKickoffItemDelegate;
            if (delegate !== null) {
                delegate.forceActiveFocus(Qt.ShortcutFocusReason)
                delegate.openActionMenu()
            }
        }
        Keys.onPressed: event => {
            const targetX = root.currentItem ? root.currentItem.x : contentX
            let targetY = root.currentItem ? root.currentItem.y : contentY
            let targetIndex = currentIndex
            const atFirst = currentIndex === 0
            const atLast = currentIndex === count - 1
            if (count >= 1 || (root.kickoffItem.runnerModel.querying && [Qt.Key_Return, Qt.Key_Enter].includes(event.key))) {
                switch (event.key) {
                    case Qt.Key_Up: if (!atFirst) {
                        decrementCurrentIndex()

                        if ((root.currentItem as AbstractKickoffItemDelegate)?.isSeparator) {
                            decrementCurrentIndex()
                        }

                        focusCurrentItem(event, Qt.BacktabFocusReason)
                    } break
                    case Qt.Key_K: if (!atFirst && event.modifiers & Qt.ControlModifier) {
                        decrementCurrentIndex()
                        focusCurrentItem(event, Qt.BacktabFocusReason)
                    } break
                    case Qt.Key_Down: if (!atLast) {
                        incrementCurrentIndex()

                        if ((root.currentItem as AbstractKickoffItemDelegate)?.isSeparator) {
                            incrementCurrentIndex()
                        }

                        focusCurrentItem(event, Qt.TabFocusReason)
                    } break
                    case Qt.Key_J: if (!atLast && event.modifiers & Qt.ControlModifier) {
                        incrementCurrentIndex()
                        focusCurrentItem(event, Qt.TabFocusReason)
                    } break
                    case Qt.Key_Home: if (!atFirst) {
                        currentIndex = 0
                        focusCurrentItem(event, Qt.BacktabFocusReason)
                    } break
                    case Qt.Key_End: if (!atLast) {
                        currentIndex = count - 1
                        focusCurrentItem(event, Qt.TabFocusReason)
                    } break
                    case Qt.Key_PageUp: if (!atFirst) {
                        targetY = targetY - height + 1
                        targetIndex = indexAt(targetX, targetY)
                        // TODO: Find a more efficient, but accurate way to do this
                        while (targetIndex === -1) {
                            targetY += 1
                            targetIndex = indexAt(targetX, targetY)
                        }
                        currentIndex = Math.max(targetIndex, 0)
                        focusCurrentItem(event, Qt.BacktabFocusReason)
                    } break
                    case Qt.Key_PageDown: if (!atLast) {
                        targetY = targetY + height - 1
                        targetIndex = indexAt(targetX, targetY)
                        // TODO: Find a more efficient, but accurate way to do this
                        while (targetIndex === -1) {
                            targetY -= 1
                            targetIndex = indexAt(targetX, targetY)
                        }
                        currentIndex = Math.min(targetIndex, count - 1)
                        focusCurrentItem(event, Qt.TabFocusReason)
                    } break
                    case Qt.Key_Return:
                        /* Fall through*/
                    case Qt.Key_Enter:
                        if (launchMatchTimer.running) {
                            launchMatchTimer.stop()
                            launchMatchTimer.triggered()

                        } else if (!root.kickoffItem.runnerModel.querying || listViewItem.currentItem?.text.toLowerCase().includes(root.kickoffItem.runnerModel.query.toLowerCase())) { // qmllint disable missing-property

                            launchMatchTimer.triggered()
                        } else {
                            launchMatchTimer.start()
                        }
                        event.accepted = true;
                        break;
                }
            }
            movedWithKeyboard = event.accepted
            if (movedWithKeyboard) {
                movedWithKeyboardTimer.restart()
            }
        }
    }
}
