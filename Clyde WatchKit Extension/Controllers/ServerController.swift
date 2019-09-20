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
                
                self.presentAlert(withTitle: "Oops", message: error, preferredStyle: .alert, actions: [WKAlertAction(title: "Ok", style: .default, handler: {
                    
                })])
                
            })
            
        }
        
        
    }
    
    
}

class ServerController: WKInterfaceController, WebSocketConnectionDelegate {
    func onMessage(connection: WebSocketConnection, text: String) {
        
    }
    
    
    func onConnected(connection: WebSocketConnection) {
        print("Connected to Server")
    }
    
    func onDisconnected(connection: WebSocketConnection, error: Error?) {
        print("Disconnected from Server")

        webSocketConnection.connect()
        
        webSocketConnection.delegate = self
            
        
        let json: [String : Any] = [
            "op": 2,
            "d": [
                "token": Discord.token,
                "properties": [
                    "os": "Linux",
                    "browser": "Firefox",
                    "device": ""
                ],
                "large_threshold": 250
            ]
        ]
        
        guard let data = (try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)) else { return }
        
        webSocketConnection.send(data: data)
    }
    
    func onError(connection: WebSocketConnection, error: Error) {
        print("ERROR")
    }
    
    func onMessage(connection: WebSocketConnection, data: Data) {
        
         let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        if let _seq = json?["s"] as? Int {
            
            seq = _seq
            
        }
        
       if let t = json?["t"] as? String {
       
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


                           row?.server = servers![index]



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

        if let heartbeat = d["heartbeat_interval"] as? Int {

            print(heartbeat)

            connection.startTimer(heartbeat: heartbeat)
        }
        
    }

    @IBOutlet weak var table: WKInterfaceTable?
    @IBOutlet weak var ai: WKInterfaceImage?
    
    var servers: [Server]?
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
 
        self.pushController(withName: "Channel", context: self.servers?[rowIndex] ?? Server())
        
    }
    
    var loadedServers = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        loadedServers = false
        
        addMenuItem(with: UIImage(systemName: "arrow.clockwise")!, title: "Refresh", action: #selector(start_websocket))
        
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

                
            }
                
        }
        
    }
    


    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    

    @objc func start_websocket(){
        
                webSocketConnection.delegate = self
                    
                
                let json: [String : Any] = [
                    "op": 2,
                    "d": [
                        "token": Discord.token,
                        "properties": [
                            "os": "Linux",
                            "browser": "Firefox",
                            "device": ""
                        ],
                        "large_threshold": 250
                    ]
                ]
                
                guard let data = (try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)) else { return }
                
                webSocketConnection.send(data: data)
      
                
            }
      



}

