/*
 * SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

////pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import org.kde.plasma.private.kicker as Kicker
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PC3
import QtQuick.Controls as QQC2

BasePage {
    id: root

    property real flashFavorite: 0

    // Flash favorites when adding one.
    SequentialAnimation {
        id: flashFavoriteAnimation
        loops: 2
        alwaysRunToEnd: true

        NumberAnimation {
            target: root
            property: "flashFavorite"
            from: 0
            to: 1
            duration: Kirigami.Units.veryLongDuration
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: root
            property: "flashFavorite"
            to: 0
            duration: Kirigami.Units.veryLongDuration
            easing.type: Easing.OutCubic
        }
    }

    Connections {
        target: kickoff.rootModel.favoritesModel
        function onFavoriteAdded() : void {
            flashFavoriteAnimation.restart();
        }
    }




    contentAreaComponent: VerticalStackView {
        id: stackView

        popEnter: Transition {
            NumberAnimation {
                property: "x"
                from: 0.5 * root.width
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
        }

        pushEnter: Transition {
            NumberAnimation {
                property: "x"
                from: 0.5 * -root.width
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
        }


        property int appsModelRow: 1
        readonly property Kicker.AppsModel appsModel: kickoff.rootModel.modelForRow(appsModelRow)
        Connections {
            target: kickoff.rootModel
            function onRefreshed() { // recalculate appsModel binding on rootModel refresh;
                stackView.appsModelRowChanged() // modelForRow does not create dependency
            }
        }
        focus: true
        initialItem: applicationsListViewComponent

        Component {
            id: applicationsListViewComponent

            KickoffListView {
                id: applicationsListView
                objectName: "applicationsListView"
                mainContentView: true
                model: stackView.appsModel
                // we want to semantically switch between group and "", disabling grouping, workaround for QTBUG-121797
                section.property: model && model.description === "KICKER_ALL_MODEL" ? "group" : "_unset"
                section.criteria: ViewSection.FirstCharacter

                view.header: Component {
                    Column {
                        width: applicationsListView.view.availableWidth
                        visible: stackView.appsModelRow === 1 && favoritesRepeater.count > 0

                        PlasmaExtras.ListSectionHeader {
                            width: parent.width
                            text: i18n("Favorites")
                        }

                        ListView {
                            id: favoritesRepeater
                            width: parent.width
                            height: contentHeight
                            interactive: false
                            model: kickoff.rootModel.favoritesModel
                            delegate: KickoffListDelegate {
                                id: favDelegate
                                width: applicationsListView.view.availableWidth

                                mouseArea.onEntered: {
                                    applicationsListView.view.currentIndex = -1
                                }

                                action: T.Action {
                                    onTriggered: {
                                        if (kickoff.rootModel.favoritesModel.trigger) {
                                            kickoff.rootModel.favoritesModel.trigger(index, "", null)
                                            if (kickoff.hideOnWindowDeactivate) {
                                                kickoff.expanded = false;
                                            }
                                        }
                                    }
                                }

                                background: PlasmaExtras.Highlight {
                                    anchors.fill: parent
                                    hovered: favDelegate.mouseArea.containsMouse
                                    active: favDelegate.mouseArea.containsMouse
                                    pressed: favDelegate.down
                                }
                            }
                        }

                        PlasmaExtras.ListSectionHeader {
                            width: parent.width
                            text: i18n("All Applications")
                        }
                    }
                }
            }
        }

        Connections {
            target: kickoff
            function onExpandedChanged() {
                if (!kickoff.expanded && kickoff.contentArea && kickoff.contentArea.currentItem) {
                    kickoff.contentArea.currentItem.forceActiveFocus()
                }
            }
        }
    }
    // NormalPage doesn't get destroyed when deactivated, so the binding uses
    // StackView.status and visible. This way the bindings are reset when
    // NormalPage is Activated again.
        Binding {
        target: kickoff
        property: "contentArea"
        value: root.contentAreaItem ? root.contentAreaItem.currentItem : null
        when: root.T.StackView.status === T.StackView.Active && root.visible
        restoreMode: Binding.RestoreBinding
    }
}
