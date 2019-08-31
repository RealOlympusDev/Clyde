//
//  ChannelController.swift
//  Discord WatchKit Extension
//
//  Created by Reuben on 25/05/19.
//  Copyright © 2019 Reuben. All rights reserved.
//

import WatchKit

class ChannelController: WKInterfaceController {
    
    @IBOutlet weak var table: WKInterfaceTable?
    @IBOutlet weak var ai: WKInterfaceImage?
    
    
    var channels: [Channel]?
    
    var categories: [Channel]? = []
    
    func show(){
        table?.setHidden(false)
        ai?.setHidden(true)
    }

    func hide(){
        table?.setHidden(true)
        ai?.setHidden(false)
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        if categories?.isEmpty ?? true {
            
            self.pushController(withName: "Message", context: channels?[rowIndex])
           
            
        } else {
            
            let channels = self.channels?.filter {$0.parent_id == categories?[rowIndex].id}
            
            if channels?.isEmpty ?? true{
                return
            }
            
            self.pushController(withName: "Channel", context: channels)
            
        }
        
    }
    
    override func awake(withContext context: Any?) {
        
        hide()
        
        if let server = context as? Server {
            
            Discord.getChannels(server: server, completion: { channels in
                
                var channels = channels
                
                var index = 0
                
                for _ in channels{
                    
                    channels[index].addServer(server: server)
                    
                    index += 1
                }
                
                channels = channels.sorted(by: { $0.position! < $1.position! }).filter({$0.type != 2})
                
                self.channels = channels
                
                channels = channels.filter {$0.type == 4}
                
                self.categories = channels
                
                self.table?.setNumberOfRows(channels.count, withRowType: "ChannelRow")
                
                for index in 0..<(self.table?.numberOfRows ?? 0) {
                    
                    let row = self.table?.rowController(at: index) as? ChannelRowController //get the row
                    
                    var channel = channels[index]
                    
                    channel.addServer(server: server)
                    
                    row?.channel = channel
                    
                }
                
                self.show()
                
            })
            
        } else if let channels = context as? [Channel] {
            
            self.table?.setNumberOfRows(channels.count, withRowType: "ChannelRow")
            
            for index in 0..<(self.table?.numberOfRows ?? 0) {
                
                let row = self.table?.rowController(at: index) as? ChannelRowController //get the row
                
                row?.channel = channels[index]
                
            }
            
            self.channels = channels
            
            self.show()
            
        }
        
    }
    
}
