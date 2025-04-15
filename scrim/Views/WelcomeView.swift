////
// WelcomeView.swift
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

// © 2025 Charles Choi.

import SwiftUI

extension AuthenticationWorkflow {
    struct WelcomeView: View {
        @Binding var workflowState: AuthenticationWorkflowState

        var body: some View {
            VStack(alignment: .leading) {
                Text("Welcome to Scrim!")
                    .font(.largeTitle)
                    .multilineTextAlignment(.leading)

                Text(genBodyText())
                    .font(.system(size: 14))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(CGFloat(2))

                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))

                Spacer()


                HStack {
                    Button(action: setupScrim) {
                        Label("My Emacs server is setup for TCP", systemImage: "gearshape")
                            .font(.title2)
                            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                    }

                    Button(action:setupTCP) {
                        Label("My Emacs server is not setup", systemImage: "network")
                            .font(.title2)
                            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                    }

                    Spacer()
                }
            }
            .padding(EdgeInsets(top: 15, leading: 20, bottom: 10, trailing: 20))
        }

        func setupScrim() {
            workflowState = .setupScrim
        }

        func setupTCP() {
            workflowState = .setupTCP
        }

        func genBodyText() -> AttributedString {
            let srcText = [
              ("For **Scrim** to work, Emacs server must be setup to use a TCP socket " +
               "and to have the `org‑protocol` package loaded.\n"),
              ("**Scrim** requires TCP socket access due to " +
                 "macOS security policy restrictions.\n"),
              ("If your Emacs server is already setup for TCP, please click on the “My Emacs server is setup for TCP” button below. "
               + "Otherwise click on “My Emacs server is not setup”.")
            ]

            let bodyText = try! AttributedString(markdown: srcText.joined(separator: "  \n"),
                                                 options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))

            return bodyText
        }
    }
}

#Preview {
    @Previewable @State var workflowState: AuthenticationWorkflow.AuthenticationWorkflowState = .welcome
    AuthenticationWorkflow.WelcomeView(workflowState: $workflowState).frame(width: 800, height: 412)
}
