//
//  ChannelRowController.swift
//  Discord WatchKit Extension
//
//  Created by Reuben on 25/05/19.
//  Copyright © 2019 Reuben. All rights reserved.
//

import WatchKit

class ChannelRowController: NSObject {
    
    @IBOutlet weak var channel_text: WKInterfaceLabel?
    
    var channel: Channel? {
        
        didSet {
            
            guard let channel = channel else { return }
            
            if channel.type == 4 {
                channel_text?.setText(channel.name?.uppercased())
            } else if channel.type == 0 {
                channel_text?.setText("#" + (channel.name?.lowercased() ?? ""))
            } else if channel.type == 2 {
                 channel_text?.setText("🔊 " + (channel.name ?? ""))
            }
            
        }
        
        
    }
    
    public func imageFromUrl(_ urlString: String, image: WKInterfaceImage?){
        
        if let url = NSURL(string: urlString) {
            
            let request = NSURLRequest(url: url as URL)
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
                
                if let imageData = data as Data? {
                    
                    DispatchQueue.global().async { [weak self] in
                        
                        guard let _ = self else {
                            session.invalidateAndCancel()
                            return
                        }
                        
                        image?.setImageData(imageData)
                        
                    }
                }
            });
            
            task.resume()
            
        }
    }
    
    
}


