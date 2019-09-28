//
//  MessageController.swift
//  Discord WatchKit Extension
//
//  Created by Reuben on 25/05/19.
//  Copyright © 2019 Reuben. All rights reserved.
//

import WatchKit

class MessageController: WKInterfaceController, WebSocketConnectionDelegate {
    
    func onConnected(connection: WebSocketConnection) {
        print("Connected to Message")
        
//        let json: [String : Any] = [
//                   "op": 12,
//                   "d": [server?.id ?? ""]
//            ]
//
//        guard let data = (try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)) else { return }
//
//        connection.send(data: data)
    }
    
    func onDisconnected(connection: WebSocketConnection, error: Error?) {
        print("Disconnected from Message")
        
        pop()

    }
    
    func onError(connection: WebSocketConnection, error: Error) {
        print("ERROR")
    }
    
    func onMessage(connection: WebSocketConnection, data: Data) {
        
                    
        let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    
        if let _seq = json?["s"] as? Int {
            seq = _seq
        }
        
        if let d = json?["d"] as? [String: Any] {
            
            if let heartbeat_interval = d["heartbeat_interval"] as? Int {
                
                print(heartbeat_interval)
                
                connection.startTimer(heartbeat: heartbeat_interval)
                
            }
            
            
        }
        

                    if json?["t"] as? String == "MESSAGE_CREATE" {
                        

                        do {
                            guard let d = json?["d"] as? [String: Any] else { return }

                            let jsonData = try JSONSerialization.data(withJSONObject: d)

                            let decoder = JSONDecoder()

                            var message = try decoder.decode(Message.self, from: jsonData)

                            if message.channel_id == self.channel?.id {

                            message.addServerAndChannel(server: self.channel?.server ?? Server(), channel: self.channel ?? Channel())

                            self.messages?.append(message)

                            self.table?.insertRows(at: IndexSet(integer: (self.messages?.count ?? 0) - 1), withRowType: "MessageRow")

                            let row = self.table?.rowController(at: (self.table?.numberOfRows ?? 0) - 1) as? MessageRowController //get the row

                             let cal = Calendar(identifier: .iso8601)

                             let formatter = DateFormatter()

                             formatter.calendar = cal
                             formatter.locale = Locale(identifier: "en_US_POSIX")
                             formatter.timeZone = TimeZone(secondsFromGMT: 0)
                             formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"

                            if let date = formatter.date(from: message.timestamp ?? "") {

                            if let lastDate = formatter.date(from: self.lastMessage?.timestamp ?? "") {

                                row?.top_group?.setHidden(cal.compare(lastDate, to: date, toGranularity: .hour) == .orderedSame && message.author?.username == self.lastMessage?.author?.username)

                            }

                            }


                            row?.message = message

                            self.lastMessage = message

                            self.table?.scrollToRow(at: (self.table?.numberOfRows ?? 0) - 1)
                                
                            }


                        } catch {
                            print(error.localizedDescription)
                        }
                    }

                    if json?["t"] as? String == "MESSAGE_DELETE" {

                        do {
                            guard let d = json?["d"] as? [String: Any] else { return }

                            let jsonData = try JSONSerialization.data(withJSONObject: d)

                            let decoder = JSONDecoder()

                            let message = try decoder.decode(Message.self, from: jsonData)

                            if message.channel_id == self.channel?.id{

                            guard let index = self.messages?.firstIndex(where: {$0.id == message.id}) else { return }

                            self.messages?.remove(at: index)

                            let indices: IndexSet = [index]

                            self.table?.removeRows(at: indices)
                                
                            }


                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    if json?["t"] as? String == "MESSAGE_UPDATE" {

                        do {
                            guard let d = json?["d"] as? [String: Any] else { return }

                            let jsonData = try JSONSerialization.data(withJSONObject: d)

                            let decoder = JSONDecoder()

                            let message = try decoder.decode(Message.self, from: jsonData)

                            if message.channel_id == self.channel?.id{

                            guard let index = self.messages?.firstIndex(where: {$0.id == message.id}) else { return }

                            let row = self.table?.rowController(at: index) as? MessageRowController //get the row


                            let text = (message.content ?? "") + " (edited)"

                            let markdownParser = MarkdownParser(font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body))

                            guard let parse = markdownParser.parse(text) as? NSMutableAttributedString else { return }

                                guard let range = (parse.string as NSString?)?.range(of: " (edited)") else { return }

                            parse.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)], range: range)


                            row?.text?.setAttributedText(parse)

                            }

                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    if json?["t"] as? String == "GUILD_MEMBERS_CHUNK" {

                        do {
                            guard let d = json?["d"] as? [String: Any] else { return }

                            let jsonData = try JSONSerialization.data(withJSONObject: d)

                            let decoder = JSONDecoder()

                            let members = try decoder.decode(ServerMemberWrapper.self, from: jsonData)

                            for index in 0..<(self.table?.numberOfRows ?? 0) {

                                guard var message = self.messages?[index] else { return }

                                let row = self.table?.rowController(at: index) as? MessageRowController //get the row

                                if let _ = message.member {


                                } else{

                                    message.addServerAndChannel(server: self.channel?.server ?? Server(), channel: self.channel ?? Channel())

                                   message.member = members.members?.first(where: {$0.user?.id == message.author?.id})

                                    row?.message = message
                                }


                            }


                        } catch {
                            print(error.localizedDescription)
                        }
                       
                        }
        
                    if json?["t"] as? String == "TYPING_START" {
                                   
                                   print("typing started")

                                         do {
                                             guard let d = json?["d"] as? [String: Any] else { return }

                                             let jsonData = try JSONSerialization.data(withJSONObject: d)

                                             let decoder = JSONDecoder()

                                             let typing = try decoder.decode(TypingStart.self, from: jsonData)

                                           if typing.channel_id == self.channel?.id {
                                               
                                               
                                            Discord.getServerMember(server: self.channel?.server ?? Server(), user: User(id: typing.user_id ?? ""), completion: { member in
                                                
                                                let message = (member.user?.username ?? "Someone") + " is typing..."
                                                   
                                                   
                                                    self.message?.setTitle(message)
                                                
                                                DispatchQueue.global().asyncAfter(deadline: .now() + TimeInterval(5)) {
                                                    
                                                    if let name = self.channel?.name {
                                                        
                                                        self.message?.setTitle("Message #" + name)
                                                        
                                                    } else {
                                                        self.message?.setTitle("Message @" + (self.channel?.recipients?.first?.username ?? ""))
                                                    }
                                                    
                                                }
                                                
                                                
                                                
                                            })
                                                
                                            
                                           }

                                           } catch {
                                                   print(error.localizedDescription)
                                           }
        }
                    
    }
    
    

    @IBOutlet weak var table: WKInterfaceTable?
    @IBOutlet weak var group: WKInterfaceGroup?
    @IBOutlet weak var ai: WKInterfaceImage?

    var channel: Channel?

    @IBOutlet weak var message: WKInterfaceButton?
    
    var lastMessage: Message?

    var messages: [Message]? = []

    func show(){
        table?.setHidden(false)
        group?.setHidden(false)
        ai?.setHidden(true)
    }

    func hide(){
        table?.setHidden(true)
        group?.setHidden(true)
        ai?.setHidden(false)
    }
    
    var server: Server?

    override func awake(withContext context: Any?) {
        
        hide()
        
        guard let channel = context as? Channel else { return }
        
        self.channel = channel
        
        server = channel.server
        
        if let name = channel.name {
            
            if channel.type == 3 {
            
                self.setTitle(name)
                
            } else {
                
                self.setTitle("#" + name)
                
            }
            
        } else {
            self.setTitle("@" + (channel.recipients?.first?.username ?? ""))
            
        }
        
        if let name = channel.name {
            
            if channel.type == 3 {
            
                self.message?.setTitle("Message " + name)
                
            } else {
                
                self.message?.setTitle("Message #" + name)
                
            }
            
        } else {
            self.message?.setTitle("Message @" + (channel.recipients?.first?.username ?? ""))
        }
        
        if (compute_permissions(member: server?.member ?? ServerMember(), channel: channel) & PermissionType.SEND_MESSAGES) != PermissionType.SEND_MESSAGES {
            self.message?.setTitle("You can't send messages here!")
            self.message?.setEnabled(false)
        }
        
        
        Discord.getMessages(channel: channel, completion: { messages in
            
            let messages = messages.reversed().map({$0})
            
            self.messages = messages
            
            self.table?.setNumberOfRows(messages.count, withRowType: "MessageRow")
            
            for index in 0..<(self.table?.numberOfRows ?? 0) {
                
                let row = self.table?.rowController(at: index) as? MessageRowController //get the row
                
                var message = messages[index]
                
                message.addServerAndChannel(server: channel.server ?? Server(), channel: channel)
                
                row?.message = message
                
                if (message.type == MessageTypes.DEFAULT){
                    row?.lastMessage = self.lastMessage
                    self.lastMessage = message
                }
                
            }
            
                let members = channel.server?.members
                
                 for index in 0..<(self.table?.numberOfRows ?? 0) {
                                       
                       guard var message = self.messages?[index] else { return }

                       let row = self.table?.rowController(at: index) as? MessageRowController //get the row
                       
                       if let _ = message.member {

                           
                       } else{
                           
                           message.addServerAndChannel(server: self.channel?.server ?? Server(), channel: self.channel ?? Channel())
                           
                          message.member = members?.first(where: {$0.user?.id == message.author?.id})
                           
                           row?.message = message
                       }

                }
                
                print(self.table?.numberOfRows ?? 0)
            
            self.show()
            
            DispatchQueue.global().asyncAfter(deadline: .now() + TimeInterval(0.1)) {
                
                self.table?.scrollToRow(at: (self.table?.numberOfRows ?? 0) - 1)
                
                    
            }
            
        })
        
        self.start_websocket()

        
        
    }
    
    
     func start_websocket(){
        
        guard let url = URL(string: "wss://gateway.discord.gg/?encoding=json&v=6") else { return }

        let websocket = WebSocketTaskConnection(url: url)
        
        websocket.connect()
        
        websocket.delegate = self
        
        let json: [String : Any] = [
            "op": 2,
            "d": [
                "token": Discord.token ?? "",
                "properties": [
                    "os": "Linux",
                    "browser": "Firefox",
                    "device": "",
                    "referrer": "",
                    "referring_domain": ""
                ],
                "large_threshold": 100,
                "compress": true
            ]
        ]
        
         guard let data = (try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)) else { return }
        
        websocket.send(data: data)
        
                
    }
    
    
    @IBAction func send_message() {
        
      self.presentTextInputController(withSuggestions:nil, allowedInputMode: .allowEmoji, completion: { (results) in
                      
        guard let responses = results else { return }
                      
        var text = responses[0] as? String
        
        guard let channel = self.channel else { return }
        
        Discord.sendStartTyping(channel: channel)
        
        let message = WKAlertAction(title: "Message", style: .default) {
            
            
            
            for channel in channel.server?.channels ?? [] {
                
                text = text?.replacingOccurrences(of: "#" + (channel.name ?? ""), with: "<#" + (channel.id ?? "") + ">")
                
            }
            
            
            Discord.sendMessage(channel: channel, message: text ?? "", completion: { message in
                
                
            })
            
        }
        
        self.presentAlert(withTitle: nil, message: text, preferredStyle: .actionSheet, actions: [message])
        
    })
    }
    
    
    
}

public struct ServerMemberWrapper: Codable {
    var guild_id: String?
    var members: [ServerMember]?
}

public struct TypingStart: Codable {
    var channel_id: String?
    var guild_id: String?
    var user_id: String?
    var timestamp: Int?
}
