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

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var table: WKInterfaceTable?
    
    var servers: [Server]?
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
            
        Discord.getServer(server: self.servers?[rowIndex] ?? Server(), completion: { server in
        
            self.pushController(withName: "Channel", context: server)
    
            
        })
        
        
    }
    
    var serversLoaded = false

    
    override func didAppear() {
        super.didAppear()
        
        // Configure interface objects here.
        
        let defaults = UserDefaults.standard
        
        if defaults.string(forKey: "token") == nil {
            
            self.presentController(withName: "Login", context: nil)
            
        } else {
            
            if serversLoaded == false {
            
                serversLoaded = true
                   
                Discord.token = defaults.string(forKey: "token")
                
                loadServers()
                
            }
                
        }
        
    }
    
    func loadServers(){
        
        Discord.getServers(completion: { servers in
            
            let servers = servers.sorted(by: {($0.id ?? "") > ($1.id ?? "")})
            
            self.table?.setNumberOfRows(servers.count, withRowType: "ServerRow")
            
            for index in 0..<(self.table?.numberOfRows ?? 0) {
                
                let row = self.table?.rowController(at: index) as? ServerRowController //get the row
                
                Discord.getServer(server: servers[index], completion: { server in
                    
                    row?.server = server
                    
                })
                
                
            }
            
            self.servers = servers
            
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
