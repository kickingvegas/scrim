//
// ApplicationMenu.swift
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

@MainActor
class ApplicationMenu: NSObject {
    let menu = NSMenu()
    var homeWindowController: AuthenticationWindowController?
    @objc var kvDefaults = ScrimDefaults.shared
    var authKeyObserver: NSKeyValueObservation?

    var aboutMenuItem: NSMenuItem?
    var configureMenuItem: NSMenuItem?
    var resetDefaultsMenuItem: NSMenuItem?
    var evalMenuItem: NSMenuItem?
    var repoMenuItem: NSMenuItem?
    var quitMenuItem: NSMenuItem?


    func createMenu() -> NSMenu {
        aboutMenuItem = NSMenuItem(title: "About Scrim", action: #selector(about), keyEquivalent: "")
//        evalMenuItem = NSMenuItem(title: "Eval…", action: #selector(evalElisp), keyEquivalent: "")
        configureMenuItem = NSMenuItem(title: "Setup", action: #selector(configure), keyEquivalent: "")
        resetDefaultsMenuItem = NSMenuItem(title: "Reset", action: #selector(resetDefaults), keyEquivalent: "")
        repoMenuItem = NSMenuItem(title:"Source", action: #selector(openRepo), keyEquivalent: "")
        quitMenuItem = NSMenuItem(title: "Quit Scrim", action: #selector(quit), keyEquivalent: "q")
 
//        if let evalMenuItem {
//            evalMenuItem.target = self
//         //   evalMenuItem.view = ElispEntry()
//            menu.addItem(evalMenuItem)
//
//            if ScrimDefaults.shared.authKey == nil {
//                evalMenuItem.isHidden = true
//            }
//        }
        
        if let aboutMenuItem {
            aboutMenuItem.target = self
            menu.addItem(aboutMenuItem)
            menu.addItem(NSMenuItem.separator())
        }

        if let configureMenuItem {
            configureMenuItem.target = self
            menu.addItem(configureMenuItem)

            if ScrimDefaults.shared.authKey != nil {
                configureMenuItem.isHidden = true
            }
        }

        if let resetDefaultsMenuItem {
            resetDefaultsMenuItem.target = self
            menu.addItem(resetDefaultsMenuItem)

            if ScrimDefaults.shared.authKey == nil {
                resetDefaultsMenuItem.isHidden = true
            }
        }
                
        
        if let repoMenuItem {
            menu.addItem(NSMenuItem.separator())
            repoMenuItem.target = self
            menu.addItem(repoMenuItem)
        }



        if let quitMenuItem {
            menu.addItem(NSMenuItem.separator())
            quitMenuItem.target = self
            menu.addItem(quitMenuItem)
        }

        authKeyObserver = observe(\.kvDefaults.authKey,
                                   options: [.old, .new]) { appMenu, change in

            DispatchQueue.main.async {
                if let newValue = change.newValue {
                    if newValue == nil {
                        appMenu.resetDefaultsMenuItem?.isHidden = true
                        appMenu.evalMenuItem?.isHidden = true
                        appMenu.configureMenuItem?.isHidden = false
                    } else {
                        appMenu.resetDefaultsMenuItem?.isHidden = false
                        appMenu.evalMenuItem?.isHidden = false
                        appMenu.configureMenuItem?.isHidden = true
                    }
                }
            }
            

        }

        return menu
    }


    @objc func about(sender: NSMenuItem) {
        NSApp.orderFrontStandardAboutPanel()
    }

    @objc func quit(sender: NSMenuItem) {
        NSApp.terminate(self)
    }

    @objc func configure(sender: NSMenuItem) {
        if self.homeWindowController != nil {
            self.homeWindowController?.close()
        }
        
        self.homeWindowController = AuthenticationWindowController()
        self.homeWindowController?.showWindow(self)
    }
    
    @objc func openRepo(sender: NSMenuItem) {
        let url = URL(string: "https://github.com/kickingvegas/scrim")
        if let url {
            NSWorkspace.shared.open(url)
        }
    }

    @objc func resetDefaults(sender: NSMenuItem) {
        ScrimDefaults.shared.clearBookmark()
    }

    @objc func evalElisp(sender: NSMenuItem) {
        let emacsClient = KvClientNetworking.EmacsClient.shared

        let message = "(message \"hi there, hi.\")"

        if emacsClient.connection == nil {
            if let port = kvDefaults.port,
               let host = kvDefaults.host,
               let authKey = kvDefaults.authKey {

                emacsClient.configure(host: host, port: port, authKey: authKey)
                emacsClient.setup { result in
                    switch result {
                    case .success(_):
                        print("Connected")
                        emacsClient.disconnect()

                    case .failure(let error):
                        print("ERROR: \(error)")
                    }
                }
            }
        }

        emacsClient.connect {
            emacsClient.send(payload: message,
                             messageType: .eval,
                             completion: .contentProcessed({sendError in
                if let sendError = sendError {
                    print("Send error: \(sendError)")
                } else {
                    print("Sent command: \(message)")
                }
            }))
        }
    }
}
