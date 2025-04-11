////
// scrimTests.swift
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

import Foundation
import Network
import Testing

struct FuzzUtils {
    static func randomString(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap { _ in characters.randomElement() })
    }
}

@MainActor
@Suite
struct ScrimTests {
        
    @MainActor
    @Suite("ScrimDefaults")
    struct ScrimDefaultsSuite {
        let scrimDefaults: ScrimDefaults = ScrimDefaults()
        
        
        @Test func setAuthBookmarkData() async throws {
            let testString = "hey they clittiak"
            let key = "setTest"
            
            if let data = testString.data(using: .utf8) {
                scrimDefaults.setAuthBookmarkData(data, key: key)
                if let result = UserDefaults.standard.data(forKey: key) {
                    #expect(result == data)
                }
            }
        }
        
        @Test func clearAuthBookmarkData() async throws {
            let testString = "hey they clittiak"
            let key = "clearTest"
            
            if let data = testString.data(using: .utf8) {
                scrimDefaults.setAuthBookmarkData(data, key: key)
                
                scrimDefaults.clearAuthBookmarkData(key: key)
                
                #expect(UserDefaults.standard.data(forKey: key) == nil)
            }
        }

        
    }
        
    @Suite("ScrimUtils")
    struct ScrimUtilsSuite {
        @Test(arguments: [
            ("scrim://emacs?file=mary.txt", "mary.txt"),
            ("scrim://emacs?file=~/fred.txt", "~/fred.txt"),
            ("scrim://emacs?frame=1&file=~/fred.txt&file=jane.txt", "~/fred.txt"),
            ("scrim://open?file=mary.txt", "mary.txt"),
            ("scrim://open?file=~/fred.txt", "~/fred.txt"),
            ("scrim://open?frame=1&file=~/fred.txt&file=jane.txt", "~/fred.txt"),
            ("scrim://open?file=~/hey%20you.txt&file=jane.txt", "~/hey you.txt"),
            ("scrim://open?file=~/what the.txt&file=jane.txt", "~/what the.txt"),
        ])
        func scrimProtocolOpen(testValues: (String, String)) async throws {
            let input = testValues.0
            let control = testValues.1
            
            if let components = URLComponents(string: input) {
                guard ["emacs", "open"].contains(components.host) else {
                    #expect(Bool(false))
                    return
                }
                
                if let result = ScrimUtils.findFirstQueryItem(components: components, key: "file") {
                    #expect(result == control)
                }
            }
        }
        
        @Test(arguments: [
            ("scrim://info?node=%28org%29%20Protocols",  "(org) Protocols"),
            ("scrim://info?node=(org) Protocols", "(org) Protocols"),
            ("scrim://info?node=(eshell) Control Flow",  "(eshell) Control Flow")
        ])
        func scrimProtocolInfo(testValues: (String, String)) async throws {
            let input = testValues.0
            let control = testValues.1
            
            if let components = URLComponents(string: input) {
                guard components.host == "info" else {
                    #expect(Bool(false))
                    return
                }
                
                if let result = ScrimUtils.findFirstQueryItem(components: components, key: "node") {
                    #expect(result == control)
                }
            }
        }
                
        @Test(arguments: [
            ("scrim://emacs?file=mary.txt", false),
            ("scrim://emacs?file=~/fred.txt", false),
            ("scrim://emacs?frame=1&file=~/fred.txt&file=jane.txt", true)
        ])
        func scrimIsFrame(testValues: (String, Bool)) async throws {
            let input = testValues.0
            let control = testValues.1
            
            if let components = URLComponents(string: input) {
                guard components.host == "emacs" else {
                    #expect(Bool(false))
                    return
                }
                
                let result = ScrimUtils.scrimIsFrame(components: components)
                #expect(result == control)
            }
        }
    }
    
    
    @MainActor
    @Suite("EmacsClient")
    struct EmacsClientSuite {
        let emacsClient = ScrimNetworking.EmacsClient()
        
        static func configureTestVector()  -> (String, Int, String) {
            return (FuzzUtils.randomString(length: 10), Int.random(in: 1...65535), FuzzUtils.randomString(length: 10))
        }
                
        //@Test(arguments: [await foo(), await foo()])
        // !!!: Thread 6: Fatal error: Internal inconsistency: No test reporter for test case argumentIDs: nil in test scrimTests.ScrimTests/EmacsClientSuite/configure(testValues:)/scrimTests.swift:105:10
        // @Test(arguments: await Array(repeating: foo(), count: 5))
        
        @Test(arguments: await [configureTestVector(),
                                configureTestVector(),
                                configureTestVector(),
                                configureTestVector(),
                                configureTestVector()])
        func configure(testValues: (String, Int, String)) throws {
            let host = testValues.0
            let port = testValues.1
            let authKey = testValues.2
            try emacsClient.configure(host: host, port: port, authKey: authKey)
            
            let hostControl = NWEndpoint.Host(host)
            let portControl = NWEndpoint.Port(port.description)
            
            #expect(hostControl == emacsClient.hostEndpoint)
            #expect(portControl == emacsClient.portEndpoint)
            #expect(authKey == emacsClient.authKey)
        }
        
        
        @Test
        func configurePortError() throws {
            let error = #expect(throws: ScrimNetworking.EmacsClientError.undefinedPortError) {
                try emacsClient.configure(host: "127.0.0.1", port: -1, authKey: "Nope")
            }
            #expect(error == .undefinedPortError)
        }
        
        @Test("setup with no port")
        func setupPortError() throws {
            let error = #expect(throws: ScrimNetworking.EmacsClientError.undefinedPortError) {
                try emacsClient.setup { result in
                    print("hey")
                }
            }
            #expect(error == .undefinedPortError)
        }

        @Test("setup with no port")
        func setupHostError() throws {
            try emacsClient.configure(host: "127.0.0.1", port: 989, authKey: "Nope")
            emacsClient.hostEndpoint = nil
            let error = #expect(throws: ScrimNetworking.EmacsClientError.undefinedHostError) {
                try emacsClient.setup { result in
                    print("hey")
                }
            }
            #expect(error == .undefinedHostError)
        }

        
        @Test func setup() async throws {
            try emacsClient.configure (host: "127.0.0.1", port: 989, authKey: "Nope")
            try emacsClient.setup { result in
                print("hey")
            }
            
            #expect(emacsClient.connection != nil)
            
            try emacsClient.setup { result in
                print("hey")
            }
            
            #expect(emacsClient.connection != nil)
        }
        
        @Test func disconnect() async throws {
            try emacsClient.configure (host: "127.0.0.1", port: 989, authKey: "Nope")
            try emacsClient.setup { result in
                print("hey")
            }
            emacsClient.disconnect()
            #expect(emacsClient.connection == nil)
        }
        
                        
        @Test(arguments: [
            ("&", "&&"),
            ("-", "&-"),
            ("\n", "&n"),
            (" ", "&_")
        ])
        func emacsClientQuote(testValues: (String, String)) async throws {
            let input = testValues.0
            let control = testValues.1
            
            let result = emacsClient.quote(input)
            
            #expect(control == result)
        }
        
        @Test(arguments: [
            ("mary.txt", ScrimNetworking.EmacsClientMessageType.file, "-nowait -file mary.txt\n"),
            ("~/.bashrc", ScrimNetworking.EmacsClientMessageType.file, "-nowait -file ~/.bashrc\n"),
            ("org-protocol://store-link?url=https://emacs.org&title=Emacs",
             ScrimNetworking.EmacsClientMessageType.orgProtocol,
             "-file org&-protocol://store&-link?url=https://emacs.org&&title=Emacs\n"),
            ("org-protocol://capture?url=http://yummymelon.com/devnull/finally-supporting-os-appearance-changes.html&title=nfdn:%20NFDN%20Finally%20Supporting%20OS%20Appearance%20Changes&template=c&body=oh%20hai.%0A%0Athis%20is%20a%20message.",
             ScrimNetworking.EmacsClientMessageType.orgProtocol,
             "-file org&-protocol://capture?url=http://yummymelon.com/devnull/finally&-supporting&-os&-appearance&-changes.html&&title=nfdn:%20NFDN%20Finally%20Supporting%20OS%20Appearance%20Changes&&template=c&&body=oh%20hai.%0A%0Athis%20is%20a%20message.\n")
        ])
        func wrapClientPayload(testValues: (String, ScrimNetworking.EmacsClientMessageType, String))  {
            let input = testValues.0
            let messageType = testValues.1
            let control = testValues.2
            
            let emacsClient = ScrimNetworking.EmacsClient.shared
            
            let result = emacsClient.wrapClientPayload(payload: input, messageType: messageType)
            #expect(result == control)
        }
    }

}
    
