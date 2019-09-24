//
//  InterfaceController.swift
//  Discord WatchKit Extension
//
//  Created by Reuben on 24/05/19.
//  Copyright © 2019 Reuben. All rights reserved.
//

import WatchKit

class CodeController: WKInterfaceController {

   var code: String? = ""
    
    @IBAction func code(_ value: NSString?) {
        
        code = value as? String
        
    }
    
    @IBAction func enterCode() {
        
        if code != "" {
            
            Discord.mfa(code: code!, completion: { token in
                 
                let defaults = UserDefaults.standard
                 
                 defaults.set(token, forKey: "token")
                 
                 self.dismiss()
                 
             }, errorHandler: { error in
                
                self.presentAlert(withTitle: "Oops", message: error, preferredStyle: .alert, actions: [WKAlertAction(title: "Ok", style: .default, handler: {
                    
                    
                })])
                 
             })
            
            
        }
        
    }
    
    
}

class LoginController: WKInterfaceController {
    
    @IBOutlet weak var text: WKInterfaceButton?
    
    override func didAppear() {
        
        let defaults = UserDefaults.standard
    
        if(defaults.string(forKey: "token") != nil){
            self.dismiss()
        }
    }
    
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
                
                if error == "MFA Required." {
                    
                    self.presentController(withName: "Code", context: nil)
                    
                } else {
                
                self.presentAlert(withTitle: "Oops", message: error, preferredStyle: .alert, actions: [WKAlertAction(title: "Ok", style: .default, handler: {
                    
                })])
                    
                }
                
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
    
    @IBAction func logout() {
        
        let defaults = UserDefaults.standard
        defaults.set(nil, forKey: "token")
        
        Discord.token = nil
        
        loadedServers = false
        
        self.table?.setHidden(true)
        self.ai?.setHidden(false)
        
        didAppear()
        
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
            
            let last = (self.table?.numberOfRows ?? 0) - 1
            
            for index in 0..<(self.table?.numberOfRows ?? 0) {
                
                Discord.getServer(server: servers[index], completion: { server in
                    
                    Discord.getChannels(server: server, completion: { channels in
                        
                        let row = self.table?.rowController(at: index) as? ServerRowController //get the row
                        
                        Discord.getUser(completion: { user in

                            Discord.getServerMember(server: server, user: user, completion: { member in
                                    
                                var _server = server
                                _server.addChannels(channels: channels)
                                _server.addUser(user: member)
                                    
                                row?.server = _server
                                
                                if index == last {
                                
                                    self.table?.setHidden(false)
                                    self.ai?.setHidden(true)
                                    
                                }
                                
                            })
                        })
                        
                    })
                    
                    
                    
                })
                
                
            }
            
        }, errorHandler: { error in
            
            self.presentAlert(withTitle: "Oops", message: error, preferredStyle: .alert, actions: [WKAlertAction(title: "Ok", style: .default, handler: {
                
            })])
            
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

