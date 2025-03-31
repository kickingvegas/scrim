//
// scrimApp.swift
// scrim

// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// © 2025 Charles Choi

import SwiftUI
import SwiftData

@main
struct scrimApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var emacsClient = KvClientNetworking.EmacsClient.shared
    var kvDefaults = ScrimDefaults.shared

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }

}
