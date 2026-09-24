/*
 * SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T

EmptyPage {
    id: root
    contentItem: ApplicationsPage {
        id: applicationsPage
    }

    footer: Footer {
        id: footer
        Binding {
            target: kickoff
            property: "footer"
            value: footer
            restoreMode: Binding.RestoreBinding
        }
        // Eat down events to prevent them from reaching the contentArea or searchField
        Keys.onDownPressed: event => {}
    }
}
