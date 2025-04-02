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
            workflowState = .welcome
        }

        func setupScrim() {
            workflowState = .setupScrim
        }

        func genBodyText() -> AttributedString {
            let srcText = [
              "Let's test your Emacs server setup by doing the following:\n",
              "  1. Launch Emacs.",
              "  2. Launch Terminal app.",
              ("  3. Run the following command from your home directory where\n" + "      `<user-emacs-directory>` is your Emacs initialization directory:\n\n" +
              "      `$ ls <user-emacs-directory>/server/server`\n"),
              "If all goes well then the file `server` should be listed."
            ]

            let bodyText = try! AttributedString(markdown: srcText.joined(separator: "  \n"),
                                                 options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))

            return bodyText
        }
    }
}

#Preview {
    @Previewable @State var workflowState: AuthenticationWorkflow.AuthenticationWorkflowState = .testServer
    AuthenticationWorkflow.TestServerView(workflowState: $workflowState)
}
