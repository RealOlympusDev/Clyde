//
//  InterfaceController.swift
//  Discord WatchKit Extension
//
//  Created by Reuben on 24/05/19.
//  Copyright © 2019 Reuben. All rights reserved.
//

import WatchKit

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

class ServerController: WKInterfaceController {

    @IBOutlet weak var table: WKInterfaceTable?
    @IBOutlet weak var ai: WKInterfaceImage?
    
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        let row = self.table?.rowController(at: rowIndex) as? ServerRowController //get the row
 
        self.pushController(withName: "Channel", context: row?.server)
        
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
                
            loadServers()

                
            }
                
        }
        
    }
    
        func loadServers(){
        
        Discord.getServers(completion: { servers in
            
            
            let servers = servers.sorted(by: {($0.id ?? "") > ($1.id ?? "")})
            
            self.table?.setNumberOfRows(servers.count, withRowType: "ServerRow")
            
            for index in 0..<(self.table?.numberOfRows ?? 0) {
                
                Discord.getChannels(server: servers[index], completion: { channels in
                    
                    let row = self.table?.rowController(at: index) as? ServerRowController //get the row
                    
                    var server = servers[index]
                    server.addChannel(channels: channels)
                        
                    row?.server = server
                    
                    self.table?.setHidden(false)
                    self.ai?.setHidden(true)
                    
                })
                
            }
            
        })
        
    }

    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
      



}

