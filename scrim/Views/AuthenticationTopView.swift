//
// HomeWindowView.swift
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

enum AuthenticationWorkflow {
}

extension AuthenticationWorkflow {
    enum AuthenticationWorkflowState: Hashable {
        case welcome
        case setupTCP
        case startServer
        case testServer
        case setupScrim
    }

    struct AuthenticationTopView: View {
        @Environment(ScrimDefaults.self) var scrimDefaults
        @State var authButtonDisabled = false
        @State var workflowState: AuthenticationWorkflowState = .welcome

        var body: some View {
            TabView(selection: $workflowState) {
                WelcomeView(workflowState: $workflowState).tabItem {
                    Label("Welcome", systemImage: "house")
                }.tag(AuthenticationWorkflowState.welcome)

                SetupTCPView(workflowState: $workflowState).tabItem {
                    Label("Setup TCP", systemImage: "network")
                }.tag(AuthenticationWorkflowState.setupTCP)

                StartServerView(workflowState: $workflowState).tabItem {
                    Label("Start Server", systemImage: "desktopcomputer")
                }.tag(AuthenticationWorkflowState.startServer)

                TestServerView(workflowState: $workflowState).tabItem {
                    Label("Test Server", systemImage: "testtube.2")
                }.tag(AuthenticationWorkflowState.testServer)

                SetupScrimView(workflowState: $workflowState).tabItem {
                    Label("Setup Scrim", systemImage: "gearshape")
                }.environment(scrimDefaults)
                    .tag(AuthenticationWorkflowState.setupScrim)
            }
            .tabViewStyle(.sidebarAdaptable)
            .animation(.easeInOut(duration: 0.2), value: workflowState)
            .transition(.scale)
        }

        func gotoWelcome() {
            workflowState = .welcome
        }

        private func dismiss() {
            NSApplication.shared.keyWindow?.close()
        }

        private func openAuthFile() {
            let kvDefaults = ScrimDefaults.shared
            let emacsClient = KvClientNetworking.EmacsClient.shared

            if let port = kvDefaults.port,
               let host = kvDefaults.host,
               let authKey = kvDefaults.authKey {

                emacsClient.configure(host: host, port: port, authKey: authKey)
                emacsClient.setup { result in
                    switch result {
                    case .success(_):
                        emacsClient.disconnect()
                    case .failure(let error):
                        print("ERROR: \(error)")
                    }
                }

                emacsClient.connect {
                    emacsClient.send(payload: "(message \"oh dang\")",
                                     messageType: .eval,
                                     completion: .contentProcessed({ error in
                        if let error {
                            print("ERROR: \(error)")
                        } else {
                            print("opening hey.txt")
                        }
                    }))

                }
            } else {
                print("ERROR: unable to connect")
            }
        }
     }
}

#Preview {
    AuthenticationWorkflow.AuthenticationTopView().environment(ScrimDefaults.shared).frame(width: 700, height: 380)
}
