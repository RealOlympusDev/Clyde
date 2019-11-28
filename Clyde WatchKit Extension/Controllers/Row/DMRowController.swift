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
            
            
            if channel.type == 3 {
                
                var name = ""
                
                if let _name = channel.name {
                    
                    name = _name
                    
                } else {
                
                    for recipient in recipients.sorted(by: { ($0.username ?? "") < ($1.username ?? "")} ) {
                    
                    if name == "" {
                        name = recipient.username ?? ""
                    } else {
                    
                        name += ", " + (recipient.username ?? "")
                        
                    }
                    
                }
                    
                }
                
                if let icon = channel.icon {
                    
                    
                    let image_url = "https://cdn.discordapp.com/channel-icons/" + (channel.id ?? "") + "/"
                    let image_profile = image_url + icon + ".png?size=64"
                            
                    if let profile_pic = profile_pic {
                    
                        self.imageFromUrl(image_profile, image: profile_pic)
                        
                    }
                    
                }
                    
                self.name?.setText(name)
                    
                
                
                
            } else {
            
            self.name?.setText(recipients.first?.username)
            
            if let recipient = recipients.first?.id {
            
            if let avatar = recipients.first?.avatar {
            
            let image_url = "https://cdn.discordapp.com/avatars/" + recipient + "/"
            let image_profile = image_url + avatar + ".png?size=64"
                    
            if let profile_pic = profile_pic {
            
                self.imageFromUrl(image_profile, image: profile_pic)
                
            }
                
            }
                
            }
                
            }
            
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
