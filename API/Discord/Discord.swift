//
//  Discord.swift
//  Discord
//
//  Created by Reuben on 25/05/19.
//  Copyright © 2019 Reuben. All rights reserved.
//

import WatchKit

public class Discord {
    
    public static var token: String?
    
    public static var message_count: Int = 0
    
    public static func login(email: String, password: String, completion: @escaping (String) -> (),  errorHandler: @escaping (String) -> ()) {
        
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        var request = URLRequest(url: URL(string: "https://discordapp.com/api/v6/auth/login")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession(configuration: .default)
        
                        DispatchQueue.main.async {
        
        let task = session.dataTask(with: request, completionHandler: { result, response , error  in
            
                        guard let json = result else {
                            errorHandler("Invaild username or password.")
                            return }
            
                        guard let result = try? JSONSerialization.jsonObject(with: json, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: String] else {
                            errorHandler("Invaild username or password.")
                            return
                            
                        }
            
                        guard let token = result["token"] else {
                            errorHandler("Invaild username or password.")
                            return
                        }
            
                        Discord.token = token
            
                        completion(token)

            
        })
                            
                     task.resume()
        }
        

        
    }
    
    public static func sendStartTyping(channel: Channel){
        
        guard let token = Discord.token else { return }
        
        guard let id = channel.id else { return }
        
        var request = URLRequest(url: URL(string: "https://discordapp.com/api/v6/channels/" + id + "/typing")!)
        
        request.httpMethod = "POST"
        
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request, completionHandler: { result, response , error  in
            
        })
        
        task.resume()
        
    }
    
    public static func sendMessage(channel: Channel, message: String, completion: @escaping (Message) -> ()){
        
        guard let token = Discord.token else { return }
        
        let parameters: [String: Any]  = [
            "content": message,
            "tts": false,
            "nonce": Discord.message_count
        ]
        
        Discord.message_count += 1
        
        guard let id = channel.id else { return }
        
        var request = URLRequest(url: URL(string: "https://discordapp.com/api/v6/channels/" + id + "/messages")!)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request, completionHandler: { result, response , error  in
            
                guard let json = result else { return }
    
                let decoder = JSONDecoder()
    
                do {
                    let message = try decoder.decode(Message.self, from: json)
    
                    completion(message)
    
                } catch {
                    print(error.localizedDescription)
                }
            
        })
        
        task.resume()

    }
    
    public static func getDMs(completion: @escaping ([Channel]) -> ()){
        
        guard let token = Discord.token else { return }
        
        var request = URLRequest(url: URL(string: "https://discordapp.com/api/v6/users/@me/channels")!)
        
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request, completionHandler: { result, response , error  in
            
            guard let json = result else { return }
            
            let decoder = JSONDecoder()
            
            do {
                print(String(data: json, encoding: .utf8)!)
                
                let channel = try decoder.decode([Channel].self, from: json)
                
                completion(channel)
                
            } catch {
                print(error.localizedDescription)
            }
            
            
        })
        
        task.resume()
        

        
    }
    
    public static func getServerMembers(server: Server, limit: Int = 1000, completion: @escaping ([ServerMember]) -> ()){
        
        guard let token = Discord.token else { return }
        
        var request = URLRequest(url: URL(string: "https://discordapp.com/api/v6/guilds/" + (server.id ?? "") + "/members?limit=" + String(limit))!)
        
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request, completionHandler: { result, response , error  in
            
            guard let json = result else { return }
            
            let decoder = JSONDecoder()
            
            do {
                
                let member = try decoder.decode([ServerMember].self, from: json)
                
                completion(member)
                
            } catch {
                print(error.localizedDescription)
            }
            
            
        })
        
        task.resume()
        
        
    }
    
    public static func getServerMember(server: Server, user: User, completion: @escaping (ServerMember) -> ()){
        
        guard let token = Discord.token else { return }
        
        var request = URLRequest(url: URL(string: "https://discordapp.com/api/v6/guilds/" + (server.id ?? "") + "/members/" + (user.id ?? ""))!)
        
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request, completionHandler: { result, response , error  in
            
            guard let json = result else { return }
            
            let decoder = JSONDecoder()
            
            do {
                
                let member = try decoder.decode(ServerMember.self, from: json)
                
                completion(member)
                
            } catch {
                print(error.localizedDescription)
            }
            
            
        })
        
        task.resume()
        
        
    }
    
    public static func getUser(completion: @escaping (User) -> ()){
        
        guard let token = Discord.token else { return }
        
        var request = URLRequest(url: URL(string: "https://discordapp.com/api/v6/users/@me")!)
        
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request, completionHandler: { result, response , error  in
            
            guard let json = result else { return }
            
            let decoder = JSONDecoder()
            
            do {
                
                let user = try decoder.decode(User.self, from: json)
                
                completion(user)
                
            } catch {
                print(error.localizedDescription)
            }
            
            
        })
        
        task.resume()
        
        
    }
    
    public static func getServer(server: Server, completion: @escaping (Server) -> ()){
        
        guard let token = Discord.token else { return }
        
        var request = URLRequest(url: URL(string: "https://discordapp.com/api/v6/guilds/" + (server.id ?? ""))!)
        
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request, completionHandler: { result, response , error  in
            
            guard let json = result else { return }
            
            let decoder = JSONDecoder()
            
            do {
                
                let server = try decoder.decode(Server.self, from: json)
                
                completion(server)
                
            } catch {
                print(error.localizedDescription)
            }
            
            
        })
        
        task.resume()
        
        
    }
    
    
    public static func getServers(completion: @escaping ([Server]) -> ()){
        
        guard let token = Discord.token else { return }
        
        var request = URLRequest(url: URL(string: "https://discordapp.com/api/v6/users/@me/guilds")!)
        
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request, completionHandler: { result, response , error  in
            
            guard let json = result else { return }
            
            let decoder = JSONDecoder()

            do {
                
                let server = try decoder.decode([Server].self, from: json)

                completion(server)

            } catch {
                print(error.localizedDescription)
            }
            
            
        })
        
        task.resume()
        
        
    }
    
    public static func getChannels(server: Server, completion: @escaping ([Channel]) -> ()) {
        
        
        guard let token = Discord.token else { return }
        
        var request = URLRequest(url: URL(string: "https://discordapp.com/api/v6/guilds/" + (server.id ?? "") + "/channels")!)
        
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request, completionHandler: { result, response , error  in
            
            guard let json = result else { return }

            let decoder = JSONDecoder()

            do {
                let channel = try decoder.decode([Channel].self, from: json)

                completion(channel)

            } catch {
                print(error.localizedDescription)
            }

            
        })
        
        task.resume()
        
        
    }
    
    public static func getMessages(channel: Channel, limit: Int = 50, completion: @escaping ([Message]) -> ()) {
        
        
        guard let token = Discord.token else { return }

        guard let id = channel.id else { return }
        
        var request = URLRequest(url: URL(string: "https://discordapp.com/api/v6/channels/" + id + "/messages?limit=" + String(limit))!)
        
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request, completionHandler: { result, response , error  in
            
            guard let json = result else { return }
            
            let decoder = JSONDecoder()

            do {
                let message = try decoder.decode([Message].self, from: json)

                completion(message)

            } catch {

                do{

                    let message = try decoder.decode(Message.self, from: json)

                    completion([message])

                } catch {

                    print(error.localizedDescription)

                }
            }
            
            
        })
        
        task.resume()

        
    }
    
}
