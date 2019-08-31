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
    @IBOutlet weak var image: WKInterfaceImage?
    @IBOutlet weak var top_group: WKInterfaceGroup?
    
    var lastMessage: Message?
    
    func formatDate(date: Date) -> String {
        
        let formatter = DateFormatter()
        
        if formatter.calendar.isDateInToday(date){
            
            formatter.dateFormat = "h:mm a"
            
        } else {
            
            formatter.dateFormat = "dd MMMM, h:mm a"
            
        }
        
        return formatter.string(from: date)

    }
    
    var message: Message? {
        
        didSet {
            
            image?.setHidden(true)
            
            let cal = Calendar(identifier: .iso8601)
            
            let formatter = DateFormatter()
            
            formatter.calendar = cal
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            
            if let date = formatter.date(from: message?.timestamp ?? "") {
            
            if let lastDate = formatter.date(from: lastMessage?.timestamp ?? "") {
            
            let string = formatDate(date: date)

            print(string)
            
            top_group?.setHidden(cal.compare(lastDate, to: date, toGranularity: .hour) == .orderedSame && message?.author?.username == lastMessage?.author?.username)
                
            }
                
            }
                
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
                    let old_text = "<@" + (mention?.id ?? "") + ">"
                    text = text.replacingOccurrences(of: old_text, with: "@" + (mention?.username ?? ""))
                }
            }
            
            if let roles = message?.mention_roles {
                for role_id in roles{
                    
                    let role = message?.server?.roles?.first(where: {$0.id == role_id})
                    
                    let old_text = "<@&" + (role?.id ?? "") + ">"
                    
                    text = text.replacingOccurrences(of: old_text, with: "@" + (role?.name ?? ""))
                }
            }
            
            let markdownParser = MarkdownParser(font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body))
                
            guard let parse = markdownParser.parse(text) as? NSMutableAttributedString else { return }
                
            guard let range = (parse.string as? NSString)?.range(of: " (edited)") else { return }
                
        parse.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)], range: range)
            
            
            if let mentions = message?.mentions {
                for mention in mentions{
                    
                    guard let range2 = (parse.string as? NSString)?.range(of: "@" + (mention?.username ?? "")) else { return }
                    parse.addAttributes([NSAttributedString.Key.foregroundColor: MarkdownLink.defaultColor], range: range2)
                }
            }
            
            if let roles = message?.mention_roles {
                for role_id in roles{
                    
                    let role = message?.server?.roles?.first(where: {$0.id == role_id})
                    
                    guard let range3 = (parse.string as? NSString)?.range(of: "@" + (role?.name ?? "")) else { return }
                    
                    parse.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(rgb: role?.color ?? 0x0293CA)], range: range3)
                }
            }
            
            self.text?.setAttributedText(parse)
            
            let image_url = "https://cdn.discordapp.com/avatars/" + (message?.author?.id ?? "") + "/"
            let image_profile = image_url + (message?.author?.avatar ?? "") + ".png?size=40"
            
            imageFromUrl(image_profile, image: profile_pic)
            
            guard let attachments = message?.attachments else {
                
                return
                
            } 
            
            for a in attachments {
                
                if let url = a?.url {
                
                    imageFromUrl(url, image: image)
                    
                    image?.setHidden(false)
                    
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
                    
                    DispatchQueue(label: "image").async {
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
