//
// HomeWindowController.swift
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

import Cocoa
import SwiftUI

class AuthenticationWindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

    convenience init() {
        let authenticationTopView = AuthenticationWorkflow.AuthenticationTopView()
            .environment(ScrimDefaults.shared)
            .frame(width: 700, height: 380)

        let hostingController = NSHostingController(rootView: authenticationTopView)
        let window = NSWindow(contentViewController: hostingController)
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.title = "Setup Scrim"
        self.init(window: window)
    }
}
