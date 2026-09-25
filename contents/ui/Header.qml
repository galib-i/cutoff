/*
    SPDX-FileCopyrightText: 2014 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2020 Carl Schwan <carl@carlschwan.eu>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PC3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

PlasmaExtras.PlasmoidHeading {
    id: root

    required property var kickoffItem

    property alias searchText: searchField.text
    property Item configureButton: configureButton
    property Item pinButton: pinButton


    contentHeight: layoutContainer.height
        + root.kickoffItem.backgroundMetrics.topPadding
        + root.kickoffItem.backgroundMetrics.bottomPadding

    spacing: root.kickoffItem.backgroundMetrics.spacing

    function tabSetFocus(event, normalTarget) {
        // Set input focus depending on whether layout order matches focus chain order
        const reason = event.key == Qt.Key_Tab ? Qt.TabFocusReason : Qt.BacktabFocusReason
        if (normalTarget !== undefined) {
            normalTarget.forceActiveFocus(reason)
        } else {
            event.accepted = false
        }
    }

    contentItem: Item {
        Item {
            id: layoutContainer

            height: Math.max(searchField.implicitHeight, configureButton.implicitHeight)
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: root.kickoffItem.backgroundMetrics.leftPadding
                right: parent.right
                rightMargin: root.kickoffItem.backgroundMetrics.rightPadding
            }

            Keys.forwardTo: searchField.activeFocus ? null : searchField

            RowLayout {
                id: rowLayout
                spacing: root.spacing
                height: parent.height
                anchors {
                    left: parent.left
                    right: parent.right
                }

                Keys.onDownPressed: event => {
                    root.kickoffItem.contentArea.forceActiveFocus(Qt.TabFocusReason);
                }

                PlasmaExtras.SearchField {
                    id: searchField
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    Layout.fillWidth: true
                    Layout.leftMargin: root.kickoffItem.backgroundMetrics.leftPadding
                    focus: true

                    Binding {
                        target: root.kickoffItem
                        property: "searchField"
                        value: searchField
                        // there's only one header ever, so don't waste resources
                        restoreMode: Binding.RestoreNone
                    }
                    Connections {
                        target: root.kickoffItem
                        function onIsMenuOpenChanged() {
                            if (!root.kickoffItem.isMenuOpen) {
                                searchField.clear()
                            }
                        }
                    }
                    onTextEdited: {
                        searchField.forceActiveFocus(Qt.ShortcutFocusReason)
                    }
                    Keys.priority: Keys.AfterItem
                    Keys.forwardTo: {
                        if (root.kickoffItem.contentArea === null) {
                            return []
                        }
                        return root.kickoffItem.contentArea.view
                    }

                    Keys.onTabPressed: event => {
                        root.tabSetFocus(event, nextItemInFocusChain(false));
                    }
                    Keys.onBacktabPressed: event => {
                        root.tabSetFocus(event, nextItemInFocusChain());
                    }
                    Keys.onLeftPressed: event => {
                    }
                    Keys.onRightPressed: event => {
                        if (activeFocus) {
                            configureButton.forceActiveFocus(
                                Application.layoutDirection === Qt.RightToLeft ? Qt.BacktabFocusReason : Qt.TabFocusReason)
                        }
                    }
                }

                PC3.ToolButton {
                    id: configureButton
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    visible: Plasmoid.internalAction("configure").enabled && Plasmoid.configuration.showConfigureButton
                    icon.name: "configure"
                    text: Plasmoid.internalAction("configure").text
                    display: PC3.ToolButton.IconOnly

                    PC3.ToolTip.text: text
                    PC3.ToolTip.delay: Kirigami.Units.toolTipDelay
                    PC3.ToolTip.visible: hovered
                    Keys.onTabPressed: event => {
                        root.tabSetFocus(event, nextItemInFocusChain(false));
                    }
                    Keys.onBacktabPressed: event => {
                        root.tabSetFocus(event, nextItemInFocusChain());
                    }
                    Keys.onLeftPressed: event => {
                        searchField.forceActiveFocus(
                            Application.layoutDirection == Qt.RightToLeft ? Qt.TabFocusReason : Qt.BacktabFocusReason)
                    }
                    Keys.onRightPressed: event => {
                        pinButton.forceActiveFocus(
                            Application.layoutDirection == Qt.RightToLeft ? Qt.BacktabFocusReason : Qt.TabFocusReason)
                    }
                    onClicked: {
                        root.kickoffItem.closeMenu()
                        Plasmoid.internalAction("configure").trigger()
                    }
                }
                PC3.ToolButton {
                    id: pinButton
                    checkable: true
                    checked: Plasmoid.configuration.pin
                    icon.name: "window-pin"
                    text: i18nc("@action:button Pin widget open if it loses focus, icon-only button, for tooltip/Accessible", "Keep Open") // qmllint disable unqualified
                    display: PC3.ToolButton.IconOnly
                    PC3.ToolTip.text: text
                    PC3.ToolTip.delay: Kirigami.Units.toolTipDelay
                    PC3.ToolTip.visible: hovered
                    Binding {
                        target: root.kickoffItem
                        property: "hideOnWindowDeactivate"
                        value: !pinButton.checked
                        // there should be no other bindings, so don't waste resources
                        restoreMode: Binding.RestoreNone
                    }
                    Keys.onTabPressed: event => {
                        root.tabSetFocus(event, root.kickoffItem.firstCentralPane || nextItemInFocusChain());
                    }
                    Keys.onBacktabPressed: event => {
                        root.tabSetFocus(event, nextItemInFocusChain(false));
                    }
                    Keys.onLeftPressed: event => {
                        nextItemInFocusChain(false).forceActiveFocus(Application.layoutDirection == Qt.RightToLeft ? Qt.TabFocusReason : Qt.BacktabFocusReason)
                    }
                    Keys.onRightPressed: event => {}
                    onToggled: Plasmoid.configuration.pin = checked
                }
            }
        }
    }
}
