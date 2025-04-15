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
    var emacsClient = ScrimNetworking.EmacsClient.shared
    var scrimDefaults = ScrimDefaults.shared
    
    var body: some Scene {
        Window("Scrim", id: "main") {
            if scrimDefaults.authKey != nil {
                AuthenticatedView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                AuthenticationWorkflow.AuthenticationTopView()
                    .environment(scrimDefaults)
                    .environment(emacsClient)
            }
        }
        .commands {
            CommandGroup(after: .appInfo) {
                if scrimDefaults.authKey != nil {
                    Divider()
                    Button("Reset") {
                        scrimDefaults.clearAuthBookmarkData()
                    }
                    .help("This will reset Scrim.")
                }
            }
            
            CommandGroup(after: .help) {
                Divider()
                
                Button("Send Feedback…") {
                    openMailFeedback()
                }
                .help("Your feedback is important to us! Please let us know what you think is up with Scrim.")
                
                Divider()
                
            }
            //            CommandGroup(after: .help) {
            //                Divider()
            //
            //                Button("Rate and Review") {
            //                    guard let url = URL(string: "https://apps.apple.com/us/app/captee/id6446053750?action=write-review") else {
            //                        fatalError("unable to generate URL")
            //                    }
            //                    NSWorkspace.shared.open(url)
            //                }
            //                .help("Your feedback is important to us! Please rate and review Captee on the App Store.")
            
            //                Divider()
            
            //                Button("Online Discussions") {
            //                    guard let url = URL(string: "https://github.com/kickingvegas/scrim/discussions") else {
            //                        fatalError("unable to generate URL")
            //                    }
            //                    NSWorkspace.shared.open(url)
            //                }
            //                .help("Join the community on GitHub and discuss how you use Scrim with others!")
            
            //                Divider()
            
            //                Button("Scrim Source") {
            //                    guard let url = URL(string: "https://github.com/kickingvegas/scrim") else {
            //                        fatalError("unable to generate URL")
            //                    }
            //                    NSWorkspace.shared.open(url)
            //                }
            //                .help("Want to know what's inside? Peruse the source code for Scrim on GitHub.")
            //            }
        }
        
        
        //        Window("Setup", id: "setup") {
        //            AuthenticationWorkflow.AuthenticationTopView().environment(scrimDefaults).environment(emacsClient)
        //        }
    }
    
    func openMailFeedback() {
        let datestamp = Date()
        var urlComponents = URLComponents()
        urlComponents.scheme = "mailto"
        urlComponents.path = "kickingvegas@gmail.com"
        
        var queryItems: [URLQueryItem] = []
        
        queryItems.append(URLQueryItem(name: "subject", value: "Scrim Feedback: \(datestamp)"))
        queryItems.append(URLQueryItem(name: "body",
                                       value: ("# Title\n\n"
                                               + "# Description\n\n"
                                               + "# Step to Reproduce\n\n"
                                               + "# Expected Result\n\n"
                                               + "# Actual Result\n\n")))
        urlComponents.queryItems = queryItems
        
        if let url = urlComponents.url {
            NSWorkspace.shared.open(url)
        }
    }
}
