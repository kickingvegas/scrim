////
// SetupTCPView.swift
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
    struct SetupTCPView: View {
        @Binding var workflowState: AuthenticationWorkflowState

        var body: some View {
            VStack(alignment: .leading) {
                Text("Setup Emacs TCP Server")
                    .font(.largeTitle)
                    .multilineTextAlignment(.leading)

                Text(genBodyText())
                    .font(.system(size: 14))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(CGFloat(2))
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                
                Button(action: copyToClipboard) {
                    Label("Copy server-use-tcp to clipboard", systemImage: "document.on.document")
                        .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
                }
                
                Text("After completing the above, proceed to the next section “Start Server”.")
                    .font(.system(size: 14))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(CGFloat(2))
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))

                Spacer()

                HStack {
                    Button(action: setupScrim) {
                        Label("Back", systemImage: "chevron.backward")
                            .font(.title2)
                            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))

                    }

                    Button(action:setupTCP) {
                        Label("Next: Start Server", systemImage: "desktopcomputer")
                            .font(.title2)
                            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                    }

                    Spacer()
                }
            }
            .padding(EdgeInsets(top: 15, leading: 20, bottom: 10, trailing: 20))
        }

        func setupScrim() {
            workflowState = .welcome
        }

        func setupTCP() {
            workflowState = .startServer
        }

        func genBodyText() -> AttributedString {
            let srcText = [
              "For Scrim to work it must be setup as a TCP server.\n",
              ("In your Emacs initialization file, set the variable `server‑use‑tcp` to a " +
                 "non-nil value. (typically `t`)\n"),
              ("This can be done by using the command `M-x customize‑variable` to set the variable " +
                 "`server‑use‑tcp`.\n")
            ]

            let bodyText = try! AttributedString(markdown: srcText.joined(separator: "  \n"),
                                                 options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))

            return bodyText
        }
        
        func copyToClipboard() {
            let textToCopy = "server-use-tcp"
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(textToCopy, forType: .string)
            
        }
    }
}

#Preview {
    @Previewable @State var workflowState: AuthenticationWorkflow.AuthenticationWorkflowState = .setupTCP
    AuthenticationWorkflow.SetupTCPView(workflowState: $workflowState)
}
