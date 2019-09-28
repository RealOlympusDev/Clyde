//
//  InterfaceController.swift
//  Discord WatchKit Extension
//
//  Created by Reuben on 24/05/19.
//  Copyright © 2019 Reuben. All rights reserved.
//

import WatchKit

class CodeController: WKInterfaceController {

    
    @IBAction func code(_ value: NSString?) {
        
        let code = value as String?
        
        if code != "" {
            
            Discord.mfa(code: code ?? "", completion: { token in
                 
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
    
    #if DEBUG
    
    var email: String? = "reuben.catchpole@gmail.com"
    var password: String? = "Computer1233"
    
    #else
    
    var email: String? = ""
    var password: String? = ""
    
    #endif
    
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
    
    

    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        let defaults = UserDefaults.standard
                
        table?.setHidden(true)
                
        Discord.token = defaults.string(forKey: "token")
                
        loadServers()
    }
        
    
        func loadServers(){
            
        Discord.getServers(completion: { servers in
        
        Discord.getUser(completion: { user in
           
            
            let servers = servers.sorted(by: { ($0.name ?? "") < ($1.name ?? "") })
                
            self.table?.setNumberOfRows(servers.count, withRowType: "ServerRow")
            
            for index in 0..<(self.table?.numberOfRows ?? 0) {
                
                //Discord.getRoles(server: servers[index], completion: { roles in

                    //Discord.getChannels(server: servers[index], completion: { channels in

//                            Discord.getServerMember(server: servers[index], user: user, completion: { member in
                                
                                //Discord.getServerMembers(server: server, completion: { members in
                                
                                let row = self.table?.rowController(at: index) as? ServerRowController //get the row
                                    
                                var _server = servers[index]
                                //_server.addChannels(channels: channels)
                                _server.addUser(user: user)
                                //_server.addRoles(roles: roles)
                                //_server.addMembers(members: members)
                                    
                                row?.server = _server
                                
                                let last = (self.table?.numberOfRows ?? 0) - 1
                                
                                if index == last {
                                
                                    self.table?.setHidden(false)
                                    self.ai?.setHidden(true)
                                    
                                }
                                    
                            //})
                                
                            //})
//                        })
                        
                    //})
                    
                    
                    
                }
            
            })
                
            
        }, errorHandler: { error in
            
            if error.contains("401") {
                
                let defaults = UserDefaults.standard
                defaults.set(nil, forKey: "token")
                
                Discord.token = nil
                
                self.popToRootController()
                
            }
            
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

