//
//  ServerRowController.swift
//  Discord WatchKit Extension
//
//  Created by Reuben on 25/05/19.
//  Copyright © 2019 Reuben. All rights reserved.
//

import WatchKit

class ServerRowController: NSObject {
    
    @IBOutlet weak var icon: WKInterfaceImage?
    @IBOutlet weak var label: WKInterfaceLabel?
    @IBOutlet weak var server_name: WKInterfaceLabel?
    
     var server: Server? {
        
        didSet {
            
            guard let server = self.server else { return }
            
            guard let name = server.name else { return }
            
            self.server_name?.setText(name)
            
            if let icon = server.icon {
            
            let icon_url = "https://cdn.discordapp.com/icons/" + (server.id ?? "") + "/"
        
            let icon_image = icon_url + icon + ".png?size=64"
            
            print(icon_image)
        
            imageFromUrl(icon_image)
                
            } else {
                
                let nameArr = name.components(separatedBy: " ")
                var title = ""

                for string in nameArr {
                    title = title + String(string.first ?? Character(""))
                }
                
                self.label?.setText(title)
                
            }
            
        }
            
        }
        
        
    
    public func imageFromUrl(_ urlString: String){
        
        if let url = NSURL(string: urlString) {
            
            let request = NSURLRequest(url: url as URL)
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
                
                if let imageData = data as Data? {
                    
                    DispatchQueue(label: "image").async {
                        self.icon?.setImageData(imageData)
                    }

                }
            });
            
            task.resume()
    }
    }

}
