//
//  MessageController.swift
//  Discord WatchKit Extension
//
//  Created by Reuben on 25/05/19.
//  Copyright © 2019 Reuben. All rights reserved.
//

import WatchKit
import Network
import UserNotifications

class MessageController: WKInterfaceController{

    @IBOutlet weak var table: WKInterfaceTable?
    @IBOutlet weak var group: WKInterfaceGroup?
    @IBOutlet weak var ai: WKInterfaceImage?

    var channel: Channel?

    @IBOutlet weak var message: WKInterfaceTextField?
    
    var lastMessage: Message?

    var messages: [Message]? = []

    var seq: Int? = 0

    func startTimer(heartbeat: Int, connection: NWConnection){

        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(heartbeat) / 1000) {
            
                print("Fired")
                
                let response : [String: Any] = [
                    "op": 1,
                    "d": self.seq ?? 0
                ]
                
                guard let data = (try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)) else {
                    print("RIP")
                    return
                    
            }
                
            let metadata = NWProtocolWebSocket.Metadata(opcode: .binary)
                let context = NWConnection.ContentContext(identifier: "context", metadata: [metadata])
                
                connection.send(content: data, contentContext: context, isComplete: true, completion: .contentProcessed({ error in
                    print(error?.localizedDescription ?? "")
                    print("Sent")
                    
                    self.startTimer(heartbeat: heartbeat, connection: connection)
                }))
            
            }

    }

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

    func didRecieve(connection: NWConnection){

        connection.receiveMessage(completion: { data, context, complete, error in
            
            guard let data = data else { return }
            
            self.didRecieve(connection: connection)
            
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            guard let d = json?["d"] as? [String: Any] else { return }
            
            print(d)
            
            if let heartbeat = d["heartbeat_interval"] as? Int {
                
                print(heartbeat)
                
                self.startTimer(heartbeat: heartbeat, connection: connection)
            }
            
            guard let seq = json?["s"] as? Int else {
                return
            }
            
            self.seq = seq
            
            if json?["t"] as? String == "MESSAGE_CREATE" {
                
                do {
                    guard let d = json?["d"] as? [String: Any] else { return }
                    
                    let jsonData = try JSONSerialization.data(withJSONObject: d)
                    
                    let decoder = JSONDecoder()
                    
                    var message = try decoder.decode(Message.self, from: jsonData)
                    
                    if message.channel_id != self.channel?.id{
                        self.didRecieve(connection: connection)
                        return
                    }
                    
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
                    
                    if message.channel_id != self.channel?.id{
                        self.didRecieve(connection: connection)
                        return
                    }
                    
                    guard let index = self.messages?.firstIndex(where: {$0.id == message.id}) else { return }
                    
                    self.messages?.remove(at: index)
                    
                    let indices: IndexSet = [index]
                    
                    self.table?.removeRows(at: indices)
                    
                    
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
                    
                    if message.channel_id != self.channel?.id{
                        self.didRecieve(connection: connection)
                        return
                    }
                    
                    guard let index = self.messages?.firstIndex(where: {$0.id == message.id}) else { return }
                    
                    let row = self.table?.rowController(at: index) as? MessageRowController //get the row
                    
                    
                    let text = (message.content ?? "") + " (edited)"
                    
                    let markdownParser = MarkdownParser(font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body))
                    
                    guard let parse = markdownParser.parse(text) as? NSMutableAttributedString else { return }
                    
                    guard let range = (parse.string as? NSString)?.range(of: " (edited)") else { return }
                    
                    parse.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)], range: range)
                    
                    
                    row?.text?.setAttributedText(parse)
                    
                    
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
            
            self.didRecieve(connection: connection)
            
        })
    }

    

    override func awake(withContext context: Any?) {
        
        hide()
        
        guard let channel = context as? Channel else { return }
        
        self.channel = channel
        
        if let name = channel.name {
            
            self.setTitle("#" + name)
            
        } else {
            self.setTitle("@" + (channel.recipients?.first?.username ?? ""))
            
        }
        
        if let name = channel.name {
            
            self.message?.setPlaceholder("Message #" + name)
            
        } else {
            self.message?.setPlaceholder("Message @" + (channel.recipients?.first?.username ?? ""))
        }
        
        Discord.getMessages(channel: channel, limit: 20, completion: { messages in
            
            let messages = messages.reversed().map({$0})
            
            self.messages = messages
            
            self.table?.setNumberOfRows(messages.count, withRowType: "MessageRow")
            
            for index in 0..<(self.table?.numberOfRows ?? 0) {
                
                let row = self.table?.rowController(at: index) as? MessageRowController //get the row
                
                var message = messages[index]
                
                message.addServerAndChannel(server: channel.server ?? Server(), channel: channel)
                
                row?.message = message
                
                row?.lastMessage = self.lastMessage
                
                self.lastMessage = message
                
            }
            
            DispatchQueue.global().async {
                
                self.table?.scrollToRow(at: (self.table?.numberOfRows ?? 0) - 1)
                
                self.show()
                
            }

            
            
        })
            
        self.start_websocket()

        
        
    }
    
//    override func didAppear() {
//        self.start_websocket()
//    }
//
//    override func didDeactivate() {
//        print("deactivated")
//        websocketConnection?.cancel()
//    }
    
  
    func start_websocket(){
        
        // Create parameters for WebSocket over TLS
        let parameters = NWParameters.tls
        let websocketOptions = NWProtocolWebSocket.Options()
        websocketOptions.autoReplyPing = true
        parameters.defaultProtocolStack.applicationProtocols.insert(websocketOptions, at: 0)
        
        // Create a connection with those parameters
        
        websocketConnection = NWConnection(to: NWEndpoint.url(URL(string: "wss://gateway.discord.gg/?encoding=json&v=6")!), using: parameters)
        
        websocketConnection?.stateUpdateHandler = self.stateDidChange(to:)
        
        let clientQueue = DispatchQueue(label: "clientQueue")
        
        websocketConnection?.start(queue: clientQueue)
        
        didRecieve(connection: websocketConnection!)
        
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
                "synced_guilds": [],
                "presence": [
                    "status": "online",
                    "since": 0,
                    "afk": false,
                    "game": nil
                ],
                "compress": true
            ]
        ]
        
        guard let data = (try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)) else { return }
        
        let metadata = NWProtocolWebSocket.Metadata(opcode: .binary)
        let context = NWConnection.ContentContext(identifier: "context", metadata: [metadata])
        
        websocketConnection?.send(content: data, contentContext: context, isComplete: true, completion: .contentProcessed({ error in
            print(error?.localizedDescription ?? "")
            print("Sent")
        }))
        
        let json2: [String : Any] = [
                "op": 8,
                "d": [
                    "guild_id": channel?.guild_id ?? "",
                    "query": "",
                    "limit": 0
                ]
        ]
        
        guard let data2 = (try? JSONSerialization.data(withJSONObject: json2, options: .prettyPrinted)) else { return }
        
        
        websocketConnection?.send(content: data2, contentContext: context, isComplete: true, completion: .contentProcessed({ error in
            print(error?.localizedDescription ?? "")
            print("Sent 2")
        }))
        
        
        
    }
    
    func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .setup:
            print("Setting up...")
        case .waiting(let error):
            print("failed")
        case .preparing:
            print("Preparing...")
        case .ready:
            print("Connected")
        case .failed(let error):
            print("failed")
        case .cancelled:
            print("CANCELLED")
        }
    }
    
    @IBAction func send_message(_ value: NSString?) {
        
        let text = value as String?
        
        if text == "" {
            return
        }
        
        guard let channel = self.channel else { return }
        
        Discord.sendStartTyping(channel: channel)
        
        let message = WKAlertAction(title: "Message", style: .default) {
            
            Discord.sendMessage(channel: channel, message: text ?? "", completion: { message in
                
            })
            
        }
        
        self.presentAlert(withTitle: nil, message: text, preferredStyle: .actionSheet, actions: [message])
        
        self.message?.setText("")
        
    }
    
}

public struct ServerMemberWrapper: Codable {
    var guild_id: String?
    var members: [ServerMember]?
}
