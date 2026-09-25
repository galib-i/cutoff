/*
 * SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import org.kde.plasma.private.kicker as Kicker
import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kitemmodels as KItemModels

BasePage {
    id: root
    KItemModels.KSortFilterProxyModel {
        id: sortedFavoritesModel
        sourceModel: root.kickoffItem.rootModel.favoritesModel
        sortRole: KItemModels.KRoleNames.role("display")
        sortOrder: Qt.AscendingOrder

        function trigger(index, actionId, actionArgument) {
            const sourceIndex = mapToSource(this.index(index, 0));
            return root.kickoffItem.rootModel.favoritesModel.trigger(sourceIndex.row, actionId || "", actionArgument || null);
        }

    }


    contentAreaComponent: KickoffListView {
        id: applicationsListView
        kickoffItem: root.kickoffItem
        objectName: "applicationsListView"
        mainContentView: true

        property int appsModelRow: 1
        readonly property Kicker.AppsModel appsModel: root.kickoffItem.rootModel.modelForRow(appsModelRow)
        Connections {
            target: root.kickoffItem.rootModel
            function onRefreshed() {
                applicationsListView.appsModelRowChanged()
            }
        }

        model: applicationsListView.appsModel
        section.property: model && model.description === "KICKER_ALL_MODEL" ? "group" : "_unset"
        section.criteria: ViewSection.FirstCharacter
        focus: true

        view.header: Component {
            Column {
                width: applicationsListView.view.availableWidth
                visible: applicationsListView.appsModelRow === 1 && favoritesRepeater.count > 0
                height: visible ? implicitHeight : 0
                onHeightChanged: applicationsListView.view.contentY = applicationsListView.view.originY

                PlasmaExtras.ListSectionHeader {
                    width: parent.width
                    text: i18n("Favorites") // qmllint disable unqualified
                }

                ListView {
                    id: favoritesRepeater
                    width: parent.width
                    height: contentHeight
                    interactive: false
                    model: sortedFavoritesModel
                    delegate: KickoffListDelegate {
                        kickoffItem: root.kickoffItem
                        id: favDelegate

                        width: applicationsListView.view.availableWidth


                        mouseArea.onEntered: {
                            applicationsListView.view.currentIndex = -1
                        }

                        action: T.Action {
                            onTriggered: {
                                if (root.kickoffItem.rootModel.favoritesModel.trigger) {
                                    sortedFavoritesModel.trigger(favDelegate.index)
                                    if (root.kickoffItem.hideOnWindowDeactivate) {
                                        root.kickoffItem.closeMenu();
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
                    text: i18n("All Applications") // qmllint disable unqualified
                }
            }
        }

        Connections {
            target: root.kickoffItem
            function onIsMenuOpenChanged() {
                if (!root.kickoffItem.isMenuOpen && root.kickoffItem.contentArea) {
                    root.kickoffItem.contentArea.forceActiveFocus()
                }
            }
        }
    }

    // NormalPage doesn't get destroyed when deactivated, so the binding uses
    // StackView.status and visible. This way the bindings are reset when
    // NormalPage is Activated again.
    Binding {
        target: root.kickoffItem
        property: "contentArea"
        value: root.contentAreaItem
        when: root.T.StackView.status === T.StackView.Active && root.visible
        restoreMode: Binding.RestoreBinding
    }
}
