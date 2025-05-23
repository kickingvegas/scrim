////
// StartServerView.swift
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
    struct StartServerView: View {
        @Binding var workflowState: AuthenticationWorkflowState
        var body: some View {
            VStack(alignment: .leading) {
                Text("Start Emacs Server")
                    .font(.largeTitle)
                    .multilineTextAlignment(.leading)

                Text(genBodyText())
                    .font(.system(size: 14))
                    .textSelection(.enabled)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(CGFloat(2))
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                
                Button(action: copyToClipboard) {
                    Label("Copy to clipboard", systemImage: "document.on.document")
                        .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
                }
                
                Text(genBodyText2())
                    .font(.system(size: 14))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(CGFloat(2))
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))


                Spacer()

                HStack {
                    Button(action: goBack) {
                        Label("Back", systemImage: "chevron.backward")
                            .font(.title2)
                            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))

                    }

                    Button(action:testServer) {
                        Label("Next: Test Server", systemImage: "testtube.2")
                            .font(.title2)
                            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                    }

                    Spacer()
                }
            }
            .padding(EdgeInsets(top: 15, leading: 20, bottom: 10, trailing: 20))
        }

        func goBack() {
            workflowState = .setupTCP
        }

        func testServer() {
            workflowState = .testServer
        }

        func genBodyText() -> AttributedString {
            let srcText = [
              "In your Emacs initialization file you will need to:\n",
              "  1. Start the Emacs server.",
              "  2. Load the library `org‑protocol`.\n",
              ("Open your Emacs initialization file (`~/.emacs`, `init.el`) " +
               "using the command `M-x find-file` " +
               "and append these lines at the end " +
               "of the file to do this.\n"),
              "    `(server-start)`",
              "    `(require 'org-protocol)`"
            ]

            let bodyText = try! AttributedString(markdown: srcText.joined(separator: "  \n"),
                                                 options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))

            return bodyText
        }
        
        func genBodyText2() -> AttributedString {
            let srcText = [
                ("After completing the above, let's test that your server with `org‑protocol` " +
                 "support is running.")
            ]
            
            let bodyText = try! AttributedString(markdown: srcText.joined(separator: "  \n"),
                                                 options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))
            
            return bodyText
        }
        
        func copyToClipboard() {
            let textToCopy = "(server-start)\n(require 'org-protocol)"
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(textToCopy, forType: .string)
        }
    }
}

#Preview {
    @Previewable @State var workflowState: AuthenticationWorkflow.AuthenticationWorkflowState = .startServer
    AuthenticationWorkflow.StartServerView(workflowState: $workflowState).frame(width: 800, height: 500)
}
