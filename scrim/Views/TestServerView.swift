////
// TestServerView.swift
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
    struct TestServerView: View {
        @Binding var workflowState: AuthenticationWorkflowState

        var body: some View {
            VStack(alignment: .leading) {
                Text("Test Emacs Server")
                    .font(.largeTitle)
                    .multilineTextAlignment(.leading)

                Text(genBodyText())
                    .font(.system(size: 14))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(CGFloat(2))

                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                    
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

                    Button(action:setupScrim) {
                        Label("Next: Setup Scrim", systemImage: "gearshape")
                            .font(.title2)
                            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                    }

                    Spacer()
                }
            }
            .padding(EdgeInsets(top: 15, leading: 20, bottom: 10, trailing: 20))
        }

        func goBack() {
            workflowState = .startServer
        }

        func setupScrim() {
            workflowState = .setupScrim
        }

        func genBodyText() -> AttributedString {
            let srcText = [
              "Do the following to test your Emacs server setup:\n",
              "  1. Relaunch Emacs to pick up the previous configuration changes.",
              "  2. Launch the Terminal app.",
              "  3. Change your directory using `cd` to `user-emacs-directory` (where your `init.el` file is).",
              "      Common locations for `user-emacs-directory` are (note: `~` is your home directory):",
              "        • `~/.emacs.d`",
              "        • `~/.config/emacs`",
              "  4. Run the following command in the Terminal app:\n",
              "      `$ ls server/server`"
            ]

            let bodyText = try! AttributedString(markdown: srcText.joined(separator: "  \n"),
                                                 options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))
            return bodyText
        }
        
        func genBodyText2() -> AttributedString {
            let srcText = [
                "If all goes well then the file named `server` should be listed."
            ]
            
            let bodyText = try! AttributedString(markdown: srcText.joined(separator: "  \n"),
                                                 options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))
            
            return bodyText
        }
        
        func copyToClipboard() {
            let textToCopy = "ls server/server"
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(textToCopy, forType: .string)
        }
    }
}

#Preview {
    @Previewable @State var workflowState: AuthenticationWorkflow.AuthenticationWorkflowState = .testServer
    AuthenticationWorkflow.TestServerView(workflowState: $workflowState).frame(width: 800, height: 500)
}
