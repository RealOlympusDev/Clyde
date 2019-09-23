//
//  DMController.swift
//  Clyde WatchKit Extension
//
//  Created by Reuben Catchpole on 30/06/19.
//  Copyright © 2019 Reuben Catchpole. All rights reserved.
//

import WatchKit

class DMController: WKInterfaceController {
    
    @IBOutlet weak var table: WKInterfaceTable?
    @IBOutlet weak var ai: WKInterfaceImage?
    
    var channels: [Channel]?
    
    func show(){
        table?.setHidden(false)
        ai?.setHidden(true)
    }

    func hide(){
        table?.setHidden(true)
        ai?.setHidden(false)
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        self.pushController(withName: "Message", context: channels?[rowIndex])
        
    }
    
    override func awake(withContext context: Any?) {
        
        hide()
        
        let defaults = UserDefaults.standard
        
        if defaults.string(forKey: "token") != nil {
            
            Discord.token = defaults.string(forKey: "token")
            
        }
            
        Discord.getDMs(completion: { channels in
            
            let channels = channels.sorted(by: {($0.last_message_id ?? "") > ($1.last_message_id ?? "")})
                
            self.channels = channels
                
            self.table?.setNumberOfRows(channels.count, withRowType: "DMRow")
                
            for index in 0..<(self.table?.numberOfRows ?? 0) {
                    
                let row = self.table?.rowController(at: index) as? DMRowController //get the row
                    
                row?.channel = channels[index]
                    
            }
            
            self.show()
                
        })
    
        
    }
    
}
