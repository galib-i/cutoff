/*
 * SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

DropArea {
    id: root
    required property var kickoffItem
    required property var targetView
    readonly property bool enableAutoScroll: targetView.height < targetView.contentHeight
    property real scrollUpMargin: 0
    property real scrollDownMargin: 0
    enabled: Plasmoid.immutability !== PlasmaCore.Types.SystemImmutable

    // We keep track of the index changes as we drag and drop an item
    // to be able to undo them if the drag and drop ends outside the
    // DropArea, which allows to drag and drop items outside kickoff
    // without changing their order within the targetView.
    property var dragMoves: []

    onPositionChanged: drag => {
        if (drag.source === root.kickoffItem.dragSource) {
            const source = root.kickoffItem.dragSource.sourceItem
            if (source === null) {
                return
            }
            const targetView = source.targetView
            if (source.targetView === root.targetView && !targetView.move.running && !targetView.moveDisplaced.running) {
                const pos = mapToItem(targetView.contentItem, drag.x, drag.y)
                const targetIndex = targetView.indexAt(pos.x, pos.y)
                if (targetIndex >= 0 && targetIndex !== source.index) {
                    root.dragMoves.push([source.index, targetIndex])
                    targetView.model.moveRow(source.index, targetIndex)
                    // itemIndex changes directly after moving,
                    // we can just set the currentIndex to it then.
                    targetView.currentIndex = source.index
                }
            }
            drag.accept(Qt.MoveAction)
        }
    }
    onDropped: drag => {
        if ((drag.source !== root.kickoffItem.dragSource || root.kickoffItem.dragSource.sourceItem === null) && drag.hasUrls) {
            const pos = mapToItem(targetView.contentItem, drag.x, drag.y)
            let targetIndex = targetView.indexAt(pos.x, pos.y)
            if (targetIndex >= 0) {
                for (const url of drag.urls) {
                    targetView.model.addFavoriteTo(url, ":current", targetIndex++)
                }
            } else {
                for (const url of drag.urls) {
                    targetView.model.addFavoriteTo(url, ":current")
                }
            }
        }
    }
    onEntered: {
        root.dragMoves = []
    }
    onExited: {
        while (root.dragMoves.length > 0) {
            const [start, end] = root.dragMoves.pop()
            targetView.model.moveRow(end, start)
        }
        targetView.currentIndex = -1
    }

    function moveRow(targetIndex) {
        if (targetIndex < 0 || targetIndex >= targetView.count) {
            return;
        }

        targetView.model.moveRow(targetView.currentIndex, targetIndex);
        targetView.currentIndex = targetIndex;
    }

    Shortcut {
        enabled: root.targetView instanceof ListView && root.targetView.currentIndex > 0
        sequence: "Ctrl+Shift+Up"
        onActivated: root.moveRow(root.targetView.currentIndex - 1)
    }

    Shortcut {
        enabled: root.targetView instanceof ListView && root.targetView.currentIndex + 1 < root.targetView.count
        sequence: "Ctrl+Shift+Down"
        onActivated: root.moveRow(root.targetView.currentIndex + 1)
    }

    SmoothedAnimation {
        target: root.targetView
        property: "contentY"
        to: 0
        velocity: 200
        running: root.enableAutoScroll && root.containsDrag && root.drag.y <= root.scrollUpMargin
    }
    SmoothedAnimation {
        target: root.targetView
        property: "contentY"
        to: root.targetView.contentHeight - root.targetView.height
        velocity: 200
        running: root.enableAutoScroll && root.containsDrag && root.drag.y >= root.height - root.scrollDownMargin
    }
}
