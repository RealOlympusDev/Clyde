////
////  WebSocketConnection.swift
////  WebSockets
////
////  Created by zen on 6/17/19.
////  Copyright © 2019 AppSpector. All rights reserved.
////
//
//import Foundation
//import Network
//
//var webSocketConnection: WebSocketTaskConnection?
//var user: User?
//var seq: Int?
//var session_id: String?
//
//
//protocol WebSocketConnection {
//    func send(text: String)
//    func send(data: Data)
//    func connect()
//    func disconnect()
//    func startTimer(heartbeat: Int)
//    var delegate: WebSocketConnectionDelegate? {
//        get
//        set
//    }
//}
//
//protocol WebSocketConnectionDelegate {
//    func onConnected(connection: WebSocketConnection)
//    func onDisconnected(connection: WebSocketConnection, error: Error?)
//    func onError(connection: WebSocketConnection, error: Error)
//    func onMessage(connection: WebSocketConnection, data: Data)
//}
//
//class WebSocketTaskConnection: NSObject, WebSocketConnection {
//    var delegate: WebSocketConnectionDelegate?
//    var websocketConnection: NWConnection?
//    let delegateQueue = OperationQueue()
//
//    init(url: URL) {
//        super.init()
//
//        let parameters = NWParameters.tls
//        let websocketOptions = NWProtocolWebSocket.Options()
//        websocketOptions.autoReplyPing = true
//    parameters.defaultProtocolStack.applicationProtocols.insert(websocketOptions, at: 0)
//
//
//
//        // Create a connection with those parameters
//
//        websocketConnection = NWConnection(to: NWEndpoint.url(url), using: parameters)
//
//        websocketConnection?.stateUpdateHandler = self.stateDidChange(to:)
//
//    }
//    
//    func startTimer(heartbeat: Int){
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(heartbeat) / 1000) {
//            
//                print("Fired")
//                
//                let response : [String: Any] = [
//                    "op": 1,
//                    "d": seq ?? 0
//                ]
//                
//                guard let data = (try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)) else {
//                    print("RIP")
//                    return
//                    
//            }
//                
//            
//            self.send(data: data)
//            
//            self.startTimer(heartbeat: heartbeat)
//            
//            
//        }
//
//    }
//
//
//    func connect() {
//
//        let clientQueue = DispatchQueue(label: "clientQueue")
//
//        websocketConnection?.start(queue: clientQueue)
//
//        listen()
//
//    }
//
//    func disconnect() {
//        websocketConnection?.cancel()
//    }
//
//    func listen()  {
//        websocketConnection?.receiveMessage { data, context, complete, error  in
//
//            if let data = data {
//
//            self.delegate?.onMessage(connection: self, data: data)
//
//            self.listen()
//            }
//
//        }
//
//    }
//
//    func send(text: String) {
//
//        let metadata = NWProtocolWebSocket.Metadata(opcode: .binary)
//        let context = NWConnection.ContentContext(identifier: "context", metadata: [metadata])
//
//        websocketConnection?.send(content: text.data(using: .utf8), contentContext: context, isComplete: true, completion: .contentProcessed({ error in
//
//            if let error = error {
//                self.delegate?.onError(connection: self, error: error)
//            }
//
//
//        }))
//    }
//
//    func send(data: Data) {
//
//        let metadata = NWProtocolWebSocket.Metadata(opcode: .binary)
//        let context = NWConnection.ContentContext(identifier: "context", metadata: [metadata])
//
//        websocketConnection?.send(content: data, contentContext: context, isComplete: true, completion: .contentProcessed({
//
//            error in
//
//            if let error = error {
//                self.delegate?.onError(connection: self, error: error)
//            }
//
//
//        }))
//    }
//
//    func stateDidChange(to state: NWConnection.State) {
//        switch state {
//        case .setup:
//            print("Setting up...")
//        case .waiting:
//            print()
//        case .preparing:
//            print("Preparing...")
//        case .ready:
//            self.delegate?.onConnected(connection: self)
//        case .failed(let error):
//            self.delegate?.onDisconnected(connection: self, error: error)
//        case .cancelled:
//            self.delegate?.onDisconnected(connection: self, error: nil)
//        @unknown default:
//            print()
//        }
//    }
//}
