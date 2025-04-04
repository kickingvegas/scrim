//
// EmacsClient.swift
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
import Network
import OSLog
import Darwin

enum KvClientNetworking {
}

extension KvClientNetworking {
    fileprivate static let logger = Logger(subsystem: "com.yummymelon.emacsclient", category: "networking")

    enum EmacsClientMessageType {
        case file
        case eval
    }

    @Observable
    class EmacsClient: @unchecked Sendable {
        @MainActor static let shared = EmacsClient()

        var connection : NWConnection?
        var hostEndpoint: NWEndpoint.Host?
        var portEndpoint: NWEndpoint.Port?
        var authKey: String?

        init() {
            logger.debug("Initializing emacsclient")
        }

        public func configure(host: String, port: Int, authKey: String) {
            guard let portEndpoint = NWEndpoint.Port(port.description) else {
                fatalError()
            }

            self.authKey = authKey
            self.hostEndpoint = NWEndpoint.Host(host)
            self.portEndpoint = portEndpoint
        }

        /// Initialize connection with receiveHandler.
        /// - Parameter receiveHandler: completion handler for received messages from emacs server.
        public func setup(_ receiveHandler: @escaping @Sendable (Result<String, Error>) -> Void) {
            guard let portEndpoint else {
                fatalError()
            }
            guard let hostEndpoint else {
                fatalError()
            }

            if connection == nil {
                let endPoint = NWEndpoint.hostPort(host: hostEndpoint, port: portEndpoint)
                connection = NWConnection(to: endPoint, using: .tcp)
            } else {
                logger.debug("Connection already established.")
            }

            if let connection {
                connection.receiveMessage { content, contentContext, isComplete, error in
                    if let error = error {
                        logger.debug("Receive error: \(error)")
                        receiveHandler(.failure(error))
                    } else {
                        if let content,
                           let stringContent = String(data: content, encoding: .utf8) {
                            logger.debug("Received: \(stringContent)")
                            receiveHandler(.success(stringContent))
                        }
                    }
                }
            }
        }


        public func connect(_ readyHandler: @escaping @Sendable () -> Void) {
            guard let connection else {
                fatalError()
            }

            if (connection.state == .setup) || (connection.state == .cancelled) {
                connection.stateUpdateHandler = { newState in
                    switch newState {
                    case .ready:
                        logger.debug("Client connected to server")

                        if let authKey = self.authKey {
                            let authmessage = "-auth \(authKey)\n".data(using: .utf8)
                            connection.send(content: authmessage, completion: .contentProcessed({ sendError in
                                if let sendError = sendError {
                                    logger.debug("Send error: \(sendError)")
                                } else {
                                    logger.debug("Message sent")
                                    readyHandler()
                                }
                            }))
                        }

                    case .failed(let error):
                        logger.debug("Connection failed with error: \(error)")

                    case .cancelled:
                        logger.debug("Cancelled connection")

                    case .preparing:
                        logger.debug("Preparing connection")

                    case .setup:
                        logger.debug("Setup connection")

                    case .waiting(_):
                        logger.debug("Waiting connection")
                        break

                    default:
                        logger.debug("WARNING: unexpected connection state.")
                    }
                }
                connection.start(queue: .main)

            } else if connection.state == .ready {
                readyHandler()

            } else {
                logger.debug("Unexpected condition")
            }
        }


        public func disconnect() {
            logger.debug("Disconnecting")
            self.connection?.cancel()
            self.connection = nil
        }


        public func send(payload: String, messageType: EmacsClientMessageType = .file, completion: NWConnection.SendCompletion) {
            var message: Data?
            switch messageType {
            case .eval:
                message = "-eval \(quote(payload))\n".data(using: .utf8)
            case .file:
                message = "-file \(quote(payload))\n".data(using: .utf8)
            }

            if let connection,
               let message,
               connection.state == .ready {
                connection.send(content: message, completion: completion)
            } else {
                logger.error("Unable to send on connection.")
            }
        }

        func quote(_ input: String) -> String {
            return input
                .replacingOccurrences(of: "&", with: "&&")
                .replacingOccurrences(of: "-", with: "&-")
                .replacingOccurrences(of: "\n", with: "&n")
                .replacingOccurrences(of: " ", with: "&_")
        }


    }
}
