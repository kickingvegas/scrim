//
// AuthFileButton.swift
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

struct AuthFileButton: View {
    @State private var showFileImporter = false
    @Environment(ScrimDefaults.self) var kvDefaults

    @Binding var authButtonDisabled: Bool

    var body: some View {
        Button {
            showFileImporter = true
        } label: {
            Label("Choose Server File", systemImage: "folder.circle")
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.data]
        ) { result in
            switch result {
            case .success(let file):
                // gain access to the directory

                guard file.isFileURL else {
                    // This should always be true.
                    return
                }

                if file.lastPathComponent != "server" {
                    // TODO: need to handle
                    print("Nope")
                }


                let serverRegex = /server\/server$/

                if file.absoluteString.contains(serverRegex) {
                    print("ok found!")
                } else {
                    // TODO: need to handle
                }

                let gotAccess = file.startAccessingSecurityScopedResource()
                if !gotAccess { return }
                // access the directory URL
                // (read templates in the directory, make a bookmark, etc.)
                // onTemplatesDirectoryPicked(directory)
                // release access

                print(file.absoluteString)

                do {
                    let bd = try file.bookmarkData(
                        options: [.withSecurityScope]
                    )

                    print ("bookmark data created")

                    var stale: Bool = false

                    let bURL = try URL(resolvingBookmarkData: bd, bookmarkDataIsStale: &stale)
                    print(bURL.absoluteString)

                    // TODO: need to figure out how to get top level
                    //let kvDefaults = KvDefaults()

                    kvDefaults.setBookmark(bd)

                } catch {
                    print("ERROR: can not create bookmark data")
                }

                do {

                    let data = try Data(contentsOf: file)
                    if let buf = String(data: data, encoding: .utf8) {
                        print(buf)
                    }

                } catch {
                    print("ERROR: can not read auth file")
                }

                file.stopAccessingSecurityScopedResource()
                authButtonDisabled = kvDefaults.authKey != nil


            case .failure(let error):
                // handle error
                print(error)
            }
        }

        .fileDialogBrowserOptions([.includeHiddenFiles])

    }


}

#Preview {
    @Previewable @State var authButtonDisabled: Bool = false
    AuthFileButton(authButtonDisabled: $authButtonDisabled)
}
