//
//  MessageRowController.swift
//  Discord WatchKit Extension
//
//  Created by Reuben on 25/05/19.
//  Copyright © 2019 Reuben. All rights reserved.
//

import WatchKit

class MessageRowController: NSObject {
    
    @IBOutlet weak var username: WKInterfaceLabel?
    @IBOutlet weak var text: WKInterfaceLabel?
    @IBOutlet weak var profile_pic: WKInterfaceImage?
    @IBOutlet weak var image: WKInterfaceImage!
    
    var lastDate: Date?
    
    func formatDate(date: Date) -> String {
        
        let formatter = DateFormatter()
        
        if formatter.calendar.isDateInToday(date){
            
            formatter.dateFormat = "h:mm a"
            
        } else {
            
            formatter.dateFormat = "dd MMMM, h:mm a"
            
        }
        
        var newDate = formatter.string(from: date)
        
        if let lastDate = lastDate {
            
            if formatter.calendar.compare(lastDate, to: date, toGranularity: .minute) == .orderedSame {
                
                newDate = ""
                
            }
            
            
        }
        
        lastDate = date
        
        return newDate
    }
    
    var message: Message? {
        
        didSet {
            
            let cal = Calendar(identifier: .iso8601)
            
            let formatter = DateFormatter()
            
            formatter.calendar = cal
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            
            let date = formatter.date(from: message?.timestamp ?? "")!
            
            let string = formatDate(date: date)
            
            username?.setText(message?.author?.username)
            
            let member = message?.member

            var color = message?.server?.roles?.first(where: {$0.id == member?.roles?.first})?.color ?? 0xFFFFFF
            
            if color == 0 {
                color = 0xFFFFFF
            }
            
            username?.setTextColor(UIColor(rgb: color))
            
            var text = ""
            
            if let _ = message?.edited_timestamp {
            
            text = (message?.content ?? "") + " (edited)"
                
            } else {
                
            text = (message?.content ?? "")
                
            }
            
            if let mentions = message?.mentions {
                for mention in mentions{
                    text = text.replacingOccurrences(of: mention?.id ?? "", with: mention?.username ?? "")
                }
            }
            
            if let roles = message?.mention_roles {
                for role_id in roles{
                    
                    let role = message?.server?.roles?.first(where: {$0.id == role_id})
                    
                    text = text.replacingOccurrences(of: role?.id ?? "", with: role?.name ?? "")
                }
            }
            
            let markdownParser = MarkdownParser(font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body))
            
            guard let parse = markdownParser.parse(text) as? NSMutableAttributedString else { return }
            
            guard let range = (parse.string as? NSString)?.range(of: " (edited)") else { return }
            
        
            parse.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)], range: range)
            
            self.text?.setAttributedText(parse)
            
            let image_url = "https://cdn.discordapp.com/avatars/" + (message?.author?.id ?? "") + "/"
            let image_profile = image_url + (message?.author?.avatar ?? "") + ".png"
            imageFromUrl(image_profile, image: profile_pic)
            
            guard let attachments = message?.attachments else {
                image.setHidden(true)
                return }
            
            for a in attachments {
                
                if let url = a?.url {
                
                    imageFromUrl(url, image: image)
                    
                } else {
                    image.setHidden(true)
                }
                
                let name = a?.filename ?? ""
                
                print(name)
                
                
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
                    
                    DispatchQueue.global().async {
                        
                        image?.setImageData(imageData)
                        
                    }
                }
            });
            
            task.resume()
            
        }
    }
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
