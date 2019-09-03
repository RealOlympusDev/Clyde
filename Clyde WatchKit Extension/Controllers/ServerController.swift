//
//  InterfaceController.swift
//  Discord WatchKit Extension
//
//  Created by Reuben on 24/05/19.
//  Copyright © 2019 Reuben. All rights reserved.
//

import WatchKit
import Network

class LoginController: WKInterfaceController {
    
    @IBOutlet weak var text: WKInterfaceButton?
    
    var email: String? = ""
    
    var password: String? = ""
    
    @IBAction func email(_ value: NSString?) {
        email = value as String?
    }
    
    @IBAction func password(_ value: NSString?) {
        password = value as String?
    }
    
    
    @IBAction func login() {
        
        if email != "" && password != "" {
            
            Discord.login(email: email ?? "", password: password ?? "", completion: { (token) in
                
                let defaults = UserDefaults.standard
                
                defaults.set(token, forKey: "token")
                
                self.dismiss()
                
            }, errorHandler: { (error) in
                
                self.text?.setTitle(error)
                
            })
            
        }
        
        
    }
    
    
}

class ServerController: WKInterfaceController {

    @IBOutlet weak var table: WKInterfaceTable?
    @IBOutlet weak var ai: WKInterfaceImage?
    
    var servers: [Server]?
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        stop = true
        
        self.pushController(withName: "Channel", context: self.servers?[rowIndex] ?? Server())
        
    }
    
    var loadedServers = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        loadedServers = false
        
    }

    
    override func didAppear() {
        super.didAppear()
        
        // Configure interface objects here.
        
        let defaults = UserDefaults.standard
        
        if defaults.string(forKey: "token") == nil {
            
            self.presentController(withName: "Login", context: nil)
            
        } else {
            
            if loadedServers == false {
                
            table?.setHidden(true)
                
            loadedServers = true
                
            Discord.token = defaults.string(forKey: "token")
                
            print(Discord.token)
                
             self.start_websocket()
                    
            
//            loadServers()
                
            }
                
        }
        
    }
    
//    func loadServers(){
//        
//        Discord.getServers(completion: { servers in
//            
//            let servers = servers.sorted(by: {($0.id ?? "") > ($1.id ?? "")})
//            
//            self.table?.setNumberOfRows(servers.count, withRowType: "ServerRow")
//            
//            for index in 0..<(self.table?.numberOfRows ?? 0) {
//                
//                let row = self.table?.rowController(at: index) as? ServerRowController //get the row
//                
////                Discord.getServer(server: servers[index], completion: { server in
//                    
//                    row?.server = servers[index]
//                    
////                })
//                
//                
//            }
//            
//            self.servers = servers
//            
//            self.table?.setHidden(false)
//            
//            self.ai?.setHidden(true)
//            
//        })
//        
//    }
    

    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    var stop = false
    
    func didRecieve(connection: NWConnection){
        
        connection.receiveMessage(completion: { data, context, complete, error in
            
            guard let data = data else { return }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            if let t = json?["t"] as? String {
            
            print(t)
            
            if(t == "READY") {
            
            
            let decoder = JSONDecoder()

            do {
                
                session_id = try! decoder.decode(Socket.self, from: data).d?.session_id
                
                user = try! decoder.decode(Socket.self, from: data).d?.user

                var servers = try! decoder.decode(Socket.self, from: data).d?.guilds

                servers = servers?.sorted(by: {($0.id ?? "") > ($1.id ?? "")})

                self.table?.setNumberOfRows(servers!.count, withRowType: "ServerRow")

                            for index in 0..<(self.table?.numberOfRows ?? 0) {

                                let row = self.table?.rowController(at: index) as? ServerRowController //get the row

                //                Discord.getServer(server: servers[index], completion: { server in

                                row?.server = servers![index]

                //                })


                            }

                            self.servers = servers

                            self.table?.setHidden(false)

                            self.ai?.setHidden(true)
                
                            return

            } catch {

                    print(error.localizedDescription)

            }
                
                
            }
            }
                
            
            guard let d = json?["d"] as? [String: Any] else { return }


            for (key, _) in d {
                print(key)

            }

             if let heartbeat = d["heartbeat_interval"] as? Int {

                 print(heartbeat)

                 startTimer(heartbeat: heartbeat, connection: connection)
             }
            
            self.didRecieve(connection: connection)
            
        })
    }


//    func didRecieve(connection: NWConnection){
//
//        connection.receiveMessage(completion: { data, context, complete, error in
//
//            guard let data = data else { return }
//
//            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//
//            guard let t = json?["t"] as? String else {         self.didRecieve(connection: connection)
//                return }
//
//            print(t)
//
//            if(t != "READY") {         self.didRecieve(connection: connection)
//                return}
//
//
//
//            let decoder = JSONDecoder()
//
//            do {
//
//                var servers = try! decoder.decode(Socket.self, from: data).d?.guilds
//
//                servers = servers?.sorted(by: {($0.id ?? "") > ($1.id ?? "")})
//
//                self.table?.setNumberOfRows(servers!.count, withRowType: "ServerRow")
//
//                            for index in 0..<(self.table?.numberOfRows ?? 0) {
//
//                                let row = self.table?.rowController(at: index) as? ServerRowController //get the row
//
//                //                Discord.getServer(server: servers[index], completion: { server in
//
//                                row?.server = servers![index]
//
//                //                })
//
//
//                            }
//
//                            self.servers = servers
//
//                            self.table?.setHidden(false)
//
//                            self.ai?.setHidden(true)
//
//            } catch {
//
//                    print(error.localizedDescription)
//
//            }
//
//
//            guard let d = json?["d"] as? [String: Any] else { return }
//
//
//    //        if let g = d["guilds"] {
//    //            for guild in g as! [[String: Any]] {
//    //                for (key, value) in guild {
//    //                    print(key)
//    //                    if(key == "roles"){
//    //                        print(value)
//    //                    }
//    //                }            }
//    //        }
//
//    //        print(d)
//
//
//            if let heartbeat = d["heartbeat_interval"] as? Int {
//
//                print(heartbeat)
//
//                self.startTimer(heartbeat: heartbeat, connection: connection)
//            }
//
//            guard let seq = json?["s"] as? Int else {
//                return
//            }
//
//            self.seq = seq
//
//        })
//    }

     func start_websocket(){
                
                // Create parameters for WebSocket over TLS
                let parameters = NWParameters.tls
                let websocketOptions = NWProtocolWebSocket.Options()
                websocketOptions.autoReplyPing = true
                parameters.defaultProtocolStack.applicationProtocols.insert(websocketOptions, at: 0)
                
                // Create a connection with those parameters
                
                websocketConnection = NWConnection(to: NWEndpoint.url(URL(string: "wss://gateway.discord.gg/?encoding=json&v=6")!), using: parameters)
        
                
                websocketConnection?.stateUpdateHandler = stateDidChange(to:)
       
                
                let clientQueue = DispatchQueue(label: "clientQueue")
                
                websocketConnection?.start(queue: clientQueue)
                
                didRecieve(connection: websocketConnection!)
                
                let json: [String : Any] = [
                    "op": 2,
                    "d": [
                        "token": Discord.token,
                        "properties": [
                            "os": "Linux",
                            "browser": "Firefox",
                            "device": ""
                        ]
                    ],
                    "large_threshold": 250
                ]
                
                guard let data = (try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)) else { return }
                
                let metadata = NWProtocolWebSocket.Metadata(opcode: .binary)
                let context = NWConnection.ContentContext(identifier: "context", metadata: [metadata])
                
                websocketConnection?.send(content: data, contentContext: context, isComplete: true, completion: .contentProcessed({ error in
                    print(error?.localizedDescription ?? "")
                    print("Sent")
                }))
                
    //            let json2: [String : Any] = [
    //                    "op": 8,
    //                    "d": [
    //                        "guild_id": channel?.guild_id ?? "",
    //                        "query": "",
    //                        "limit": 0
    //                    ]
    //            ]
    //
    //            guard let data2 = (try? JSONSerialization.data(withJSONObject: json2, options: .prettyPrinted)) else { return }
    //
    //
    //            websocketConnection?.send(content: data2, contentContext: context, isComplete: true, completion: .contentProcessed({ error in
    //                print(error?.localizedDescription ?? "")
    //                print("Sent 2")
    //            }))
    //
                
                
            }
      



}

