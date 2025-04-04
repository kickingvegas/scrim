//
// AppDelegate.swift
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

import Foundation
import AppKit
import SwiftUI


class AppDelegate: NSObject, NSApplicationDelegate, @unchecked Sendable {
    lazy var statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var menu: ApplicationMenu?
    var didLaunch: Bool = false

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    
    func application(_ application: NSApplication, open urls: [URL]) {
        let emacsClient = KvClientNetworking.EmacsClient.shared
        let kvDefaults = ScrimDefaults.shared

        if let port = kvDefaults.port,
           let host = kvDefaults.host,
           let authKey = kvDefaults.authKey,
           let url = urls.first {

            emacsClient.configure(host: host, port: port, authKey: authKey)
            emacsClient.setup { [weak self] result in
                switch result {
                case .success(_):
                    emacsClient.disconnect()
                    // TODO: need to determine logic if app is already running to not call this.
                    if let self {
                        if self.didLaunch == false {
                            DispatchQueue.main.async {
                                application.terminate(self)
                            }
                        }
                    }
                case .failure(let error):
                    print("ERROR: \(error)")
                }
            }

            emacsClient.connect {
                emacsClient.send(payload: url.absoluteString, completion: .contentProcessed({sendError in
                    if let sendError = sendError {
                        print("Send error: \(sendError)")
                    } else {
                        print("Org Protocol: \(url.absoluteString)")
                    }
                }))
            }

        } else {
            print("ERROR: unable to connect")
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let value = userInfo["NSApplicationLaunchIsDefaultLaunchKey"] as? NSNumber {
            didLaunch = value.boolValue
        }

        NSApplication.shared.windows.first?.tabbingMode = .disallowed
        statusBarItem.button?.image = NSImage(named: NSImage.Name("Scrim Status Icon"))
        statusBarItem.button?.imagePosition = .imageLeading

        menu = ApplicationMenu()

        if let menu = self.menu {
            statusBarItem.menu = menu.createMenu()
        }


    }
}
