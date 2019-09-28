//
//  ClydeController.swift
//  Clyde WatchKit Extension
//
//  Created by Reuben Catchpole on 27/09/19.
//  Copyright © 2019 Reuben Catchpole. All rights reserved.
//

import WatchKit

class ClydeController: WKInterfaceController {
    
    @IBAction func servers() {
        
        self.pushController(withName: "Servers", context: nil)
        
    }
    
    @IBAction func messages() {
        
        self.pushController(withName: "DM", context: nil)
        
    }
    
    @IBAction func settings() {
        
        self.pushController(withName: "Settings", context: nil)
        
    }
    
    override func didAppear() {
            
        let defaults = UserDefaults.standard
            
        if defaults.string(forKey: "token") == nil {
                
            self.presentController(withName: "Login", context: nil)
                
        }
    }
    

}

class SettingsController: WKInterfaceController {
    
    @IBAction func logout() {
        
        let defaults = UserDefaults.standard
        defaults.set(nil, forKey: "token")
        
        Discord.token = nil
        
        popToRootController()
        
        
    }
    
    

}
