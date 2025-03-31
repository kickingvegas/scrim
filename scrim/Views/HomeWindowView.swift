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

struct HomeWindowView: View {
    @Environment(ScrimDefaults.self) var kvDefaults
    @State var authButtonDisabled = false


    let instructions = try! AttributedString(markdown:
    """
Scrim is a utility that enables you to send links and text clippings from other macOS apps directly to Emacs.  Scrim
achieves this by communicating to an Emacs server instance as a native client instead of using the `emacsclient` command line
utility.  \nScrim requires that Emacs be configured as follows:  \n1.
Emacs must be configured as a [TCP server](https://www.gnu.org/software/emacs/manual/html_node/emacs/TCP-Emacs-server.html).
This is done by setting the Elisp variable `server-use-tcp` to a non-nil value, typically `t` in your Emacs
initialization file.  \n2.
Add `(require 'org-protocol)` to your Emacs initialization file.  This will allow Emacs to process `org-protocol`
commands sent to Emacs server.  \n3.
Start Emacs.  \n4.
At this point you must let Scrim access a temporary run-time file named `server` that is created by Emacs server.
This file is typically created in your folder where you initialization file is located (for example
`~/.emacs.d/server/server`. Click on the button **Choose Server File** below.  \nNote
that Scrim requires access to this file because it is located outside of Scrim's sandbox. Once accessed, Scrim will
remember this file location and you will not need to do this operation again.
""")


    var body: some View {
        VStack {

            Text("Hello!")
                .font(.system(size: 18, weight: .bold))

            Text(instructions)
                .font(.system(size: 16))
                .multilineTextAlignment(.leading)
                .lineSpacing(CGFloat(2))
                .padding(EdgeInsets(top: 2, leading: 15, bottom: 2, trailing: 15))

            AuthFileButton(authButtonDisabled: $authButtonDisabled).disabled(authButtonDisabled)

            Button(action:openAuthFile) {
                Label("Connect to socket", systemImage: "cable.connector")
            }

            Button(action: dismiss) {
                Text("Close")
            }

            Spacer()
        }
        .onAppear {
            if kvDefaults.authKey != nil {
                authButtonDisabled = false
            }
        }
        .frame(maxWidth: .infinity,
               maxHeight: .infinity)
        .background(Color.white)

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

#Preview {
    HomeWindowView().environment(ScrimDefaults.shared).frame(width: 600, height: 800)
}
