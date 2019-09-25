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
                
            username?.setText(message?.author?.username)
            
            let member = message?.member

            var color = message?.server?.roles?.sorted(by: {$0.position! > $1.position!}).first(where: {(member?.roles?.contains($0.id) ?? false)})?.color ?? 0xFFFFFF
            
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
            
            print(message?.embeds ?? "")
            
            if text == "" {
                
                if let embed = message?.embeds?.first {
                    
                    if let name = embed?.author?.name {
                        text += ("**" + name + "**\n\n")
                    }
                    
                    if let title = embed?.title {
                        text += title + "\n\n"
                    }
                    
                    text += embed?.description ?? ""
                    
                }
                
            }
            
            let cal = Calendar(identifier: .iso8601)
            
            let formatter = DateFormatter()
            
            formatter.calendar = cal
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            
            if let date = formatter.date(from: message?.timestamp ?? "") {
            
            if let lastDate = formatter.date(from: lastMessage?.timestamp ?? "") {
            
            let _ = formatDate(date: date)
                
            top_group?.setHidden(cal.compare(lastDate, to: date, toGranularity: .hour) == .orderedSame && message?.author?.username == lastMessage?.author?.username)
                
                
            }
                
            }
            
            
            let regex1 = try! NSRegularExpression(pattern: "<(:[a-zA-z0-9_]+:)[0-9]+>", options: NSRegularExpression.Options.caseInsensitive)
            let range1 = NSMakeRange(0, text.count)
            text = regex1.stringByReplacingMatches(in: text, options: [], range: range1, withTemplate: "$1")
            
            let regex2 = try! NSRegularExpression(pattern: "<a(:[a-zA-z0-9_]+:)[0-9]+>", options: NSRegularExpression.Options.caseInsensitive)
            let range2 = NSMakeRange(0, text.count)
            text = regex2.stringByReplacingMatches(in: text, options: [], range: range2, withTemplate: "$1")
            
            
            
            if let mentions = message?.mentions {
                for mention in mentions{
                    
                    let old_text = "<@" + (mention?.id ?? "") + ">"
                    text = text.replacingOccurrences(of: old_text, with: "@" + (mention?.username ?? ""))
                    
                    let old_text2 = "<@!" + (mention?.id ?? "") + ">"
                    if let nick = message?.server?.members?.first(where: {$0.user?.id == mention?.id})?.nick {
                        text = text.replacingOccurrences(of: old_text2, with: "@" + nick)
                    } else {
                        text = text.replacingOccurrences(of: old_text2, with: "@" + (mention?.username ?? ""))
                    }
                    
                }
            }


            if let roles = message?.mention_roles {
                for role_id in roles{

                    let role = message?.server?.roles?.first(where: {$0.id == role_id})

                    let old_text = "<@&" + (role?.id ?? "") + ">"

                    text = text.replacingOccurrences(of: old_text, with: "@" + (role?.name ?? ""))
                }
            }
            
            
            if let channels = message?.server?.channels {
                for channel in channels{

                    let old_text = "<#" + (channel.id  ?? "") + ">"

                    text = text.replacingOccurrences(of: old_text, with: "#" + (channel.name ?? ""))
                }
            }
            
            if(message?.type == MessageTypes.CALL){
                top_group?.setHidden(true)
            
                text = "→ " + (message?.author?.username ?? "") + " started a call."
                
            } else if(message?.type == MessageTypes.GUILD_MEMBER_JOIN){
                top_group?.setHidden(true)
            
                text = "→ " + (message?.author?.username ?? "") + " joined the server!"
                
            } else if(message?.type == MessageTypes.RECIPIENT_ADD){
                top_group?.setHidden(true)
            
                text = "→ " + (message?.author?.username ?? "") + " added someone to the group."
                
            } else if(message?.type == MessageTypes.RECIPIENT_REMOVE){
                top_group?.setHidden(true)
            
                text = "→ " + (message?.author?.username ?? "") + " removed someone from the group."
                
            } else if(message?.type == MessageTypes.CHANNEL_NAME_CHANGE){
                top_group?.setHidden(true)
           
                text = "→ " + (message?.author?.username ?? "") + " changed the channel name."
               
            } else if(message?.type == MessageTypes.CHANNEL_ICON_CHANGE){
                top_group?.setHidden(true)
                      
                text = "→ " + (message?.author?.username ?? "") + " changed the channel icon."
                          
            } else if(message?.type == MessageTypes.CHANNEL_PINNED_MESSAGE){
                top_group?.setHidden(true)
                      
                text = "→ " + (message?.author?.username ?? "") + " pinned a message."
                          
            } else if(message?.type != MessageTypes.DEFAULT){
                top_group?.setHidden(true)
                      
                self.text?.setHidden(true)
                          
            }
            
            let markdownParser = MarkdownParser(font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body))
                
            guard let parse = markdownParser.parse(text) as? NSMutableAttributedString else { return }
            
                
            guard let range = (parse.string as NSString?)?.range(of: " (edited)") else { return }
            
            if(message?.type != MessageTypes.DEFAULT){
                
                parse.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray], range: NSMakeRange(0, text.count))
                
                guard let range = (parse.string as NSString?)?.range(of: "→") else { return }
                    
                parse.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(rgb: 0x43B581), NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)], range: range)
                
                
                
                guard let range2 = (parse.string as NSString?)?.range(of: message?.author?.username ?? "") else { return }
                    
                parse.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], range: range2)
                
            }
                
            parse.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)], range: range)
            
            
            
            if let mentions = message?.mentions {
                
                for mention in mentions{
                    guard let range = (parse.string as NSString?)?.range(of: "@" + (mention?.username ?? "")) else { return }
                    parse.addAttributes([NSAttributedString.Key.foregroundColor: MarkdownLink.defaultColor], range: range)
                }
                
                guard let range = (parse.string as NSString?)?.range(of: "@everyone") else { return }
                parse.addAttributes([NSAttributedString.Key.foregroundColor: MarkdownLink.defaultColor], range: range)
                
                guard let range2 = (parse.string as NSString?)?.range(of: "@here") else { return }
                parse.addAttributes([NSAttributedString.Key.foregroundColor: MarkdownLink.defaultColor], range: range2)
            }
            
            if let channels = message?.server?.channels {
                for channel in channels {
                    
                    guard let range = (parse.string as NSString?)?.range(of: "#" + (channel.name ?? "")) else { return }
                    parse.addAttributes([NSAttributedString.Key.foregroundColor: MarkdownLink.defaultColor], range: range)
                    
                }
            }
            
            if let roles = message?.mention_roles {
                for role_id in roles{

                    let role = message?.server?.roles?.first(where: {$0.id == role_id})

                    guard let range = (parse.string as NSString?)?.range(of: "@" + (role?.name ?? "")) else { return }

                    parse.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(rgb: role?.color ?? 0x0293CA)], range: range)
                }
            }

            
            self.text?.setAttributedText(parse)
            
            if let id = message?.author?.id {
                
                if let avatar = message?.author?.avatar {
            
                    let image_url = "https://cdn.discordapp.com/avatars/" + id + "/"
                    let image_profile = image_url + avatar + ".png?size=40"
            
                    imageFromUrl(image_profile, image: profile_pic)
                    
                }
                
            }
            
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

struct MessageTypes {
    static let DEFAULT = 0
    static let RECIPIENT_ADD = 1
    static let RECIPIENT_REMOVE = 2
    static let CALL = 3
    static let CHANNEL_NAME_CHANGE = 4
    static let CHANNEL_ICON_CHANGE = 5
    static let CHANNEL_PINNED_MESSAGE = 6
    static let GUILD_MEMBER_JOIN = 7
    static let USER_PREMIUM_GUILD_SUBSCRIPTION = 8
    static let USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_1 = 9
    static let USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_2 = 10
    static let USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_3 = 11
    static let CHANNEL_FOLLOW_ADD = 12
}
