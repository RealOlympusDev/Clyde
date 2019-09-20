//
//  DMRowController.swift
//  Clyde WatchKit Extension
//
//  Created by Reuben Catchpole on 30/06/19.
//  Copyright © 2019 Reuben Catchpole. All rights reserved.
//

import WatchKit

class DMRowController: NSObject {
    
    @IBOutlet weak var name: WKInterfaceLabel?
    
    @IBOutlet weak var profile_pic: WKInterfaceImage?
    
    
    var channel: Channel? {
        
        didSet {
            
            guard let channel = channel else { return }
            
            guard let recipients = channel.recipients else { return }
            
            self.name?.setText(recipients.first?.username)
            
            guard let recipient = recipients.first?.id else { return }
            
            guard let avatar = recipients.first?.avatar else { return }
            
            let image_url = "https://cdn.discordapp.com/avatars/" + recipient + "/"
            let image_profile = image_url + avatar + ".png"
            
            imageFromUrl(image_profile, image: profile_pic!)
            
        }
        
        
    }
    
    public func imageFromUrl(_ urlString: String, image: WKInterfaceImage){
        
        if let url = URL(string: urlString) {
            
            let request = URLRequest(url: url)
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
                
                if let imageData = data as Data? {
                    
                    DispatchQueue.global().async {
                        
                        image.setImageData(imageData)
                        
                    }
                }
            });
            
            task.resume()
            
        }
    }
    
}
