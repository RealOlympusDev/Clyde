//
//  WebSocket.swift
//  Clyde WatchKit Extension
//
//  Created by Reuben Catchpole on 10/07/19.
//  Copyright © 2019 Reuben Catchpole. All rights reserved.
//

import Foundation
import Network

var webSocketConnection: WebSocketTaskConnection!
var user: User?
var seq: Int? = 0
var session_id: String? = ""

func stateDidChange(to state: NWConnection.State) {
    switch state {
    case .setup:
        print("Setting up...")
    case .waiting(let error):
        print("failed")
    case .preparing:
        print("Preparing...")
    case .ready:
        print("Connected")
    case .failed(let error):
      print("failed")
    case .cancelled:
        print("CANCELLED")
    }
}

func startTimer(heartbeat: Int, connection: WebSocketConnection){

    DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(heartbeat) / 1000) {
        
            print("Fired")
            
            let response : [String: Any] = [
                "op": 1,
                "d": seq ?? 0
            ]
            
            guard let data = (try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)) else {
                print("RIP")
                return
                
        }
            
        
        connection.send(data: data)
        
        
        }

}

