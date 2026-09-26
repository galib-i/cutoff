/*
    SPDX-FileCopyrightText: 2011 Martin Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2012 Gregor Taetzner <gregor@freenet.de>
    SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013 2014 David Edmundson <davidedmundson@kde.org>
    SPDX-FileCopyrightText: 2014 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import QtQuick.Layouts
import org.kde.plasma.private.kicker as Kicker
import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras

EmptyPage {
    id: root

    required property var kickoffItem

    // kickoff is Kickoff.qml
    leftPadding: -root.kickoffItem.backgroundMetrics.leftPadding
    rightPadding: -root.kickoffItem.backgroundMetrics.rightPadding
    topPadding: 0
    bottomPadding: -root.kickoffItem.backgroundMetrics.bottomPadding
    readonly property var appletInterface: root.kickoffItem

    Layout.minimumWidth: Kirigami.Units.gridUnit * 10
    Layout.minimumHeight: Kirigami.Units.gridUnit * 10

    Layout.maximumWidth: Kirigami.Units.gridUnit * 50
    Layout.maximumHeight: Kirigami.Units.gridUnit * 50

    Layout.preferredWidth: Kirigami.Units.gridUnit * 30
    Layout.preferredHeight: Kirigami.Units.gridUnit * 20

    property alias normalPage: normalPage
    property bool blockingHoverFocus: true
    property var interceptedPosition: null

    /* NOTE: Important things to know about keyboard input handling:
     *
     * - Key events are passed up to parent items until the end is reached.
     * Be mindful of this when using `Keys.forwardTo`.
     *
     * - Keys defaults to BeforeItem while KeyNavigation defaults to AfterItem.
     *
     * - When Keys and KeyNavigation are using the same priority, it seems like
     * the one declared first in the QML file gets priority over the other.
     *
     * - Except for Keys.onPressed, all Keys.on*Pressed signals automatically
     * set `event.accepted = true`.
     *
     * - If you do `item.forceActiveFocus()` and `item` is a focus scope, the
     * children of `item` won't necessarily get focus. It seems like
     * `forceActiveFocus()` is better for forcing a specific thing to be focused
     * while KeyNavigation is better at passing focus down to children of the
     * thing you want to focus when dealing with focus scopes.
     *
     * - KeyNavigation uses BacktabFocusReason (TabFocusReason if mirrored) for left,
     * TabFocusReason (BacktabFocusReason if mirrored) for right,
     * BacktabFocusReason for up and TabFocusReason for down.
     *
     * - KeyNavigation does not seem to respect dynamic changes to focus chain
     * rules in the reverse direction, which can lead to confusing results.
     * It is therefore safer to use Keys for items whose position in the Tab
     * order must be changed on demand. (Tested with Qt 5.15.8 on X11.)
     */

    header: Header {
        id: header
        kickoffItem: root.kickoffItem
        fullRepresentationRoot: root
        Binding {
            target: root.kickoffItem
            property: "header"
            value: header
            restoreMode: Binding.RestoreBinding
            when: root.kickoffItem.realFullRep === root
        }
    }

    contentItem: VerticalStackView {
        id: contentItemStackView
        focus: true
        movementTransitionsEnabled: true
        implicitHeight: normalPage.implicitHeight + topPadding + bottomPadding
        implicitWidth: normalPage.implicitWidth + leftPadding + rightPadding
        // Not using a component to prevent it from being destroyed
        initialItem: NormalPage {
            id: normalPage
            objectName: "normalPage"
            kickoffItem: root.kickoffItem
        }

        Component {
            id: searchViewComponent
            KickoffListView {
                id: searchView
                objectName: "searchView"
                kickoffItem: root.kickoffItem
                mainContentView: true
                // Forces the function be re-run every time runnerModel.count changes.
                // This is absolutely necessary to make the search view work reliably.
                model: root.kickoffItem.runnerModel.count ? root.kickoffItem.runnerModel.modelForRow(0) : null
                delegate: KickoffListDelegate {
                    viewMovedWithWheel: searchView.movedWithWheel
                    viewMovedWithKeyboard: searchView.movedWithKeyboard
                    kickoffItem: root.kickoffItem

                    width: searchView.view.availableWidth // qmllint disable missing-property

                    isSearchResult: true
                }
                section.property: "group"
                activeFocusOnTab: true
                Keys.onTabPressed: event => {
                    root.kickoffItem.firstHeaderItem.forceActiveFocus(Qt.TabFocusReason);
                }
                Keys.onBacktabPressed: event => {
                    root.kickoffItem.lastHeaderItem.forceActiveFocus(Qt.BacktabFocusReason);
                }
                Keys.onUpPressed: event => {
                    root.kickoffItem.searchField.forceActiveFocus(Qt.BacktabFocusReason)
                }
                T.StackView.onStatusChanged: {
                    if (T.StackView.status === T.StackView.Activating) {
                        root.kickoffItem.contentArea = searchView
                    }
                }

                Loader {
                    anchors.centerIn: searchView.view
                    width: searchView.view.width - (Kirigami.Units.gridUnit * 4)

                    active: searchView.view.count === 0
                    visible: active
                    asynchronous: true

                    sourceComponent: PlasmaExtras.PlaceholderMessage {
                        id: emptyHint

                        iconName: "edit-none"
                        opacity: 0
                        text: i18nc("@info:status", "No matches") // qmllint disable unqualified

                        Connections {
                            target: root.kickoffItem.runnerModel
                            function onQueryFinished() {
                                showAnimation.restart()
                            }
                        }

                        NumberAnimation {
                            id: showAnimation
                            duration: Kirigami.Units.longDuration
                            easing.type: Easing.OutCubic
                            property: "opacity"
                            target: emptyHint
                            to: 1
                        }
                    }
                }
            }
        }

        Connections {
            target: root.kickoffItem
            function onIsMenuOpenChanged() {
                if (!root.kickoffItem.isMenuOpen) {
                    root.blockingHoverFocus = true
                    root.interceptedPosition = null
                }
            }
        }

        Connections {
            target: blockHoverFocusHandler
            enabled: blockHoverFocusHandler.enabled && !root.interceptedPosition
            function onPointChanged() {
                root.interceptedPosition = blockHoverFocusHandler.point.position
            }
        }

        Connections {
            target: blockHoverFocusHandler
            enabled: blockHoverFocusHandler.enabled && root.interceptedPosition && root.blockingHoverFocus
            function onPointChanged() {
                if (blockHoverFocusHandler.point.position === root.interceptedPosition) {
                    return;
                }
                root.blockingHoverFocus = false
            }
        }

        HoverHandler {
            id: blockHoverFocusHandler
            enabled: !contentItemStackView.busy && (!root.interceptedPosition || root.blockingHoverFocus)
        }

        Keys.priority: Keys.AfterItem
        // This is here rather than root because events are implicitly forwarded
        // to parent items. Don't want to send multiple events to searchField.
        Keys.forwardTo: root.kickoffItem.searchField

        Connections {
            target: root.header
            function onSearchTextChanged() {
                if ((root.header as Header).searchText.length === 0 &&
                    contentItemStackView.currentItem.objectName !== "normalPage") {
                    contentItemStackView.reverseTransitions = true
                    contentItemStackView.replace(normalPage)
                } else if ((root.header as Header).searchText.length > 0) {
                    if (contentItemStackView.currentItem.objectName !== "searchView") {
                        contentItemStackView.reverseTransitions = false
                        contentItemStackView.replace(searchViewComponent)
                    } else {
                        contentItemStackView.contentItem.currentIndex = 0
                    }
                }
                root.blockingHoverFocus = true
                root.interceptedPosition = null
            }
        }
    }

    Loader {
        active: !!root.kickoffItem.dragSource.sourceItem
        anchors.fill: parent
        sourceComponent: DropArea {
            id: favoriteRemoveDropArea

            // should be  "as AbstractKickoffItemDelegate", but the type system gets confused when changing view style at runtime
            readonly property var draggedItem: root.kickoffItem.dragSource.sourceItem

            onEntered: event => {

                if (draggedItem?.view.model instanceof Kicker.KAStatsFavoritesModel) { // qmllint disable missing-property

                    event.accept (Qt.MoveAction)
                    draggedItem.removalPlaceholderActive = true
                } else {
                    event.accepted = false
                }
            }

            onDropped: event => {

                if (draggedItem && root.kickoffItem.rootModel.favoritesModel.isFavorite(draggedItem.model.favoriteId) && draggedItem.view.model instanceof Kicker.KAStatsFavoritesModel) { // qmllint disable missing-property

                    root.kickoffItem.rootModel.favoritesModel.removeFavorite(draggedItem.model.favoriteId);
                    event.accept(Qt.MoveAction)
                } else {
                    draggedItem.removalPlaceholderActive = false
                    event.accepted = false
                }
            }

            onExited: {
                if (draggedItem) {
                    draggedItem.removalPlaceholderActive = false
                }
            }
        }
    }

    Component.onCompleted: {
        root.kickoffItem.rootModel.refresh();
    }
}
