//
// ScrimDefaults.swift
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

import Foundation
import OSLog

@Observable
public class ScrimDefaults: NSObject {
    var port: Int?
    @objc dynamic var authKey: String?
    var host: String?
    var pid: Int?

    let logger = Logger(subsystem: "com.yummymelon.emacsclient", category: "userdefaults")

    static let shared = ScrimDefaults()

    override init() {
        super.init()
        let defaults = UserDefaults.standard

        let abd = defaults.data(forKey: "authBookmark")

        if let abd {
            logger.debug("authBookmark found")
            var stale = false;

            do {
                let bURL = try URL(resolvingBookmarkData: abd,
                                   options: [.withSecurityScope],
                                   bookmarkDataIsStale: &stale)
                if bURL.startAccessingSecurityScopedResource() {

                    let data = try Data(contentsOf: bURL)
                    if let buf = String(data: data, encoding: .utf8) {
                        let tempList = buf.components(separatedBy: .newlines)

                        if let first = tempList.first {
                            let tempList = first.components(separatedBy: .whitespaces)
                            if let hostPort = tempList.first {
                                let tempList2 = hostPort.components(separatedBy: ":")
                                if tempList2.count > 1 {
                                    host = tempList2[0]
                                    port = Int(tempList2[1])
                                    logger.debug("Host: \(self.host ?? "unknown"), Port: \(self.port ?? 0)")
                                }
                            }
                        }

                        if let last = tempList.last {
                            authKey = last
                            // logger.debug("AuthKey: \(self.authKey ?? "unknown")")
                        }

                        bURL.stopAccessingSecurityScopedResource()
                    }

                } else {
                    logger.error("unable to access scoped resource")
                }


            } catch {
                logger.error("can not resolve bookmark data")
            }

        } else {
            logger.debug("no authBookmark")
        }

    }

    func authBookmark () -> Data? {
        let defaults = UserDefaults.standard
        return defaults.data(forKey: "authBookmark")
    }

    func setBookmark (_ bookmark: Data) {
        let defaults = UserDefaults.standard
        defaults.set(bookmark, forKey: "authBookmark")

        let abd = bookmark
        var stale = false;

        do {
            let bURL = try URL(resolvingBookmarkData: abd, options: [.withSecurityScope], bookmarkDataIsStale: &stale)
            if bURL.startAccessingSecurityScopedResource() {

                let data = try Data(contentsOf: bURL)
                if let buf = String(data: data, encoding: .utf8) {
                    let tempList = buf.components(separatedBy: .newlines)

                    if let first = tempList.first {
                        let tempList = first.components(separatedBy: .whitespaces)
                        if let hostPort = tempList.first {
                            let tempList2 = hostPort.components(separatedBy: ":")
                            if tempList2.count > 1 {
                                host = tempList2[0]
                                port = Int(tempList2[1])
                                logger.debug("Host: \(self.host ?? "unknown"), Port: \(self.port ?? 0)")
                            }
                        }
                    }

                    if let last = tempList.last {
                        authKey = last
                        // logger.debug("AuthKey: \(self.authKey ?? "unknown")")
                    }

                }
            } else {
                logger.error("unable to access scoped resource")
            }


        } catch {
            logger.error("can not resolve bookmark data")
        }




    }

    func clearBookmark () {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "authBookmark")
        port = nil
        host = nil
        authKey = nil
        pid = nil
    }
}
