//
//  ServerRowController.swift
//  Discord WatchKit Extension
//
//  Created by Reuben on 25/05/19.
//  Copyright © 2019 Reuben. All rights reserved.
//

import WatchKit

class ServerRowController: NSObject {
    
    @IBOutlet weak var icon: WKInterfaceImage!

     var server: Server? {
        
        didSet {
            
            guard let server = server else { return }
            
            guard let icon = server.icon else { return }
        
            let icon_url = "https://cdn.discordapp.com/icons/" + (server.id ?? "") + "/"
        
            let icon_image = icon_url + icon + ".png?size=128"
            
            print(icon_image)
        
            imageFromUrl(icon_image)
            
        }
        
        
    }
    
    public func imageFromUrl(_ urlString: String){
        
        if let url = URL(string: urlString) {
            
            let request = URLRequest(url: url)
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
                
                if let imageData = data as Data? {
                    
                    DispatchQueue.global().async {
                        self.icon.setImageData(imageData)
                        
                    }
                }
            });
            
            task.resume()
            
        }
    }

}
