////
// AuthenticatedView.swift
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

struct AuthenticatedView: View {
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text("Scrim is setup.")
                    .font(.largeTitle)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0 ))
                
                Text(genBodyText())
                    .font(.system(size: 14))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(CGFloat(2))
                
                Button(action: quit) {
                    Label("Exit Scrim", systemImage: "door.left.hand.open")
                        .font(.title2)
                        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                }
                
                Spacer()
                
                Text("Enjoy using **Scrim**!")
                    .font(.system(size: 18))
            }

            Spacer()
        }
        .padding(EdgeInsets(top: 24, leading: 24, bottom: 24, trailing: 24))
    }
    
    func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    func genBodyText() -> AttributedString {
        let srcText = [
            "With **Scrim**, you can open URL requests with the scheme `org-protocol://` from any app.\n",
            "In addition, **Scrim** has its own custom URL scheme, `scrim://`.\nWith it you can:\n",
            "  - Open a file or directory in Emacs",
            "  - Open an Info page (node) in Emacs\n",
            "For more information on the above, refer to “Scrim Help” in the menu bar.\n",
            ("Note that **Scrim** is designed to be run by macOS in the background "
             + "whenever an `org‑protocol://` or `scrim://` URL request is made. "
             + "**Scrim** is not intended to be running continuously.\n"
            )
        ]
        
        let bodyText = try! AttributedString(markdown: srcText.joined(separator: "  \n"),
                                             options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))
        return bodyText
    }
}

#Preview {
    AuthenticatedView().frame(width: 800, height: 500)

}
