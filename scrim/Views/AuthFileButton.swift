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
    @Environment(ScrimDefaults.self) var scrimDefaults
    @Binding var authButtonDisabled: Bool
    
    @State private var showingAlert = false
    @State private var alertMessage: String = "Alert"


    var body: some View {
        Button {
            showFileImporter = true
        } label: {
            Label("Choose Secret File", systemImage: "lock")
                .font(.title2)
                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
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
                    alertMessage = "ERROR: Unexpected file format. Please check your Emacs configuration and try again."
                    showingAlert = true
                    return
                }
                
                if file.lastPathComponent != "server" {
                    alertMessage = ("ERROR: Scrim expects this shared secret file to be named 'server'. " +
                                    "Please check your Emacs configuration and try again.")
                    showingAlert = true
                    return
                }
                
                let serverRegex = /server\/server$/
                
                if file.absoluteString.contains(serverRegex) {
                    // print("ok found!")
                    let gotAccess = file.startAccessingSecurityScopedResource()
                    if !gotAccess {
                        alertMessage = "ERROR: unable to access security scoped resource."
                        showingAlert = true
                        return
                    }
                    // access the directory URL
                    // (read templates in the directory, make a bookmark, etc.)
                    // onTemplatesDirectoryPicked(directory)
                    // release access
                    
                    // print(file.absoluteString)
                    
                    do {
                        let bd = try file.bookmarkData(
                            options: [.withSecurityScope]
                        )
                        
                        // print ("bookmark data created")
                        /// Test code to inspect bd
                        // var stale: Bool = false
                        // let bURL = try URL(resolvingBookmarkData: bd, bookmarkDataIsStale: &stale)
                        // print(bURL.absoluteString)
                        
                        scrimDefaults.setBookmark(bd)
                        
                    } catch {
                        alertMessage = "ERROR: can not create bookmark data."
                        showingAlert = true
                        return
                    }
                    
                    do {
                        
                        let data = try Data(contentsOf: file)
                        if let buf = String(data: data, encoding: .utf8) {
                            print(buf)
                        }
                        
                    } catch {
                        alertMessage = "ERROR: can not read shared secrete file."
                        showingAlert = true
                    }
                    
                    file.stopAccessingSecurityScopedResource()
                    authButtonDisabled = scrimDefaults.authKey != nil
                } else {
                    alertMessage = ("ERROR: The shared secret file should be in a folder named 'server'. " +
                                    "Please try again.")
                    showingAlert = true
                }
                
            case .failure(let error):
                alertMessage = error.localizedDescription
                showingAlert = true
            }
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {
                showingAlert = false
            }
        }
        .fileDialogBrowserOptions([.includeHiddenFiles])
    }
}

#Preview {
    @Previewable @State var authButtonDisabled: Bool = false
    AuthFileButton(authButtonDisabled: $authButtonDisabled).environment(ScrimDefaults.shared)
}
