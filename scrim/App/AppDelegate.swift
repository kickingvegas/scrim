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
import OSLog

class AppDelegate: NSObject, NSApplicationDelegate, @unchecked Sendable {
    lazy var statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var launchedByURL: Bool = false
    
    fileprivate let logger = Logger(subsystem: "com.yummymelon.scrim", category: "app")

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        let emacsClient = ScrimNetworking.EmacsClient.shared
        let scrimDefaults = ScrimDefaults.shared
        
        launchedByURL = urls.count > 0
        
        if let port = scrimDefaults.port,
           let host = scrimDefaults.host,
           let authKey = scrimDefaults.authKey,
           let url = urls.first,
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            
            let receiveHandler: @Sendable (Result<String, Error>) -> Void = { [weak self] result in
                switch result {
                case .success(_):
                    emacsClient.disconnect()
                    if let self {
                        if self.launchedByURL {
                            DispatchQueue.main.async {
                                application.terminate(self)
                            }
                        }
                    }
                case .failure(let error):
                    self?.logger.error("ERROR: \(error)")
                }
            }
            
            do {
                switch components.scheme {
                case "org-protocol":
                    try emacsClient.configure(host: host, port: port, authKey: authKey)
                    try emacsClient.setup(receiveHandler)
                    try emacsClient.connect {
                        emacsClient.send(payload: url.absoluteString, completion: .contentProcessed({sendError in
                            if let sendError = sendError {
                                self.logger.error("Send error: \(sendError)")
                                
                            } else {
                                self.logger.debug("Org Protocol: \(url.absoluteString)")
                            }
                        }))
                    }
                    
                case "scrim":
                    if ["emacs", "open"].contains(components.host) {
                        if let filename = ScrimUtils.findFirstQueryItem(components: components, key: "file") {
                            try emacsClient.configure(host: host, port: port, authKey: authKey)
                            try emacsClient.setup(receiveHandler)
                            try emacsClient.connect {
                                emacsClient.send(payload: filename, messageType: .file, completion: .contentProcessed({sendError in
                                    if let sendError = sendError {
                                        self.logger.error("Send error: \(sendError)")
                                    } else {
                                        self.logger.debug("Filename: \(filename)")
                                    }
                                }))
                            }
                        }
                    } else if components.host == "info" {
                        if let node = ScrimUtils.findFirstQueryItem(components: components, key: "node") {
                            try emacsClient.configure(host: host, port: port, authKey: authKey)
                            try emacsClient.setup(receiveHandler)
                            try emacsClient.connect {
                                let infoMessage = "(info \"\(node)\")"
                                emacsClient.send(payload: infoMessage, messageType: .eval, completion: .contentProcessed({sendError in
                                    if let sendError = sendError {
                                        self.logger.error("Send error: \(sendError)")
                                    } else {
                                        self.logger.debug("Info node: \(node)")
                                    }
                                }))
                            }
                        }
                        
                    } else {
                        self.logger.error("unknown host/sub-protocol \(String(describing: components.host))")
                    }

                default:
                    // THIS SHOULD NEVER HAPPEN.
                    self.logger.error("unknown scheme \(String(describing: components.scheme))")
                }
                        
            } catch {
                self.logger.error("\(error)")
            }
        } else {
            self.logger.error("ERROR: unable to connect")
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
    }
}
