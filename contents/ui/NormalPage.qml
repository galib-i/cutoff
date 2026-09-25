/*
 * SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick

EmptyPage {
    id: root
    required property var kickoffItem

    contentItem: ApplicationsPage {
        id: applicationsPage
        kickoffItem: root.kickoffItem
    }

    footer: Footer {
        id: footer
        kickoffItem: root.kickoffItem
        Binding {
            target: root.kickoffItem
            property: "footer"
            value: footer
            restoreMode: Binding.RestoreBinding
        }
        // Eat down events to prevent them from reaching the contentArea or searchField
        Keys.onDownPressed: event => {}
    }
}
