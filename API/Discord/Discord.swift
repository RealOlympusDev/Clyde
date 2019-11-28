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
    public static var ticket: String?
    
    public static var message_count: Int = 0
    
    public static func mfa(code: String, completion: @escaping (String) -> (),  errorHandler: @escaping (String) -> ()){
        
          
          let parameters: [String: Any] = [
                  "code": code,
                  "ticket": Discord.ticket ?? ""
              ]
        
            guard let url = URL(string: "https://discordapp.com/api/v6/auth/mfa/totp") else { return }
              
              var request = URLRequest(url: url)
              request.httpMethod = "POST"
              request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
              request.addValue("application/json", forHTTPHeaderField: "Content-Type")
              
              let session = URLSession(configuration: .default)
              
              let task = session.dataTask(with: request, completionHandler: { result, response , error  in
                  
                  guard let json = result else {
                    errorHandler("Invaild code.")
                    return }
                  
                guard let result = try? JSONSerialization.jsonObject(with: json, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else {
                    errorHandler("Invaild code.")
                    return }
                
                  guard let token = result["token"] as? String else {
                    errorHandler("Invaild code.")
                    return
                    }
                
                    Discord.token = token
                
                    completion(token)
                
                  
              })
        
            task.resume()
                                
    }
    
    public static func login(email: String, password: String, completion: @escaping (String) -> (),  errorHandler: @escaping (String) -> ()) {
        
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        
        
        guard let url = URL(string: "https://discordapp.com/api/v6/auth/login") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession(configuration: .default)
        
                        DispatchQueue.main.async {
        
        let task = session.dataTask(with: request, completionHandler: { result, response , error  in
            
                        guard let json = result else {
                            errorHandler("Invaild username or password.")
                            return
                            
                    }
            
                        guard let result = try? JSONSerialization.jsonObject(with: json, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else {
                            errorHandler("Invaild username or password.")
                            return
                        }
            
                        print(result)
            
                        guard let token = result["token"] as? String else {
                            
                            if let _ = result["captcha_key"] as? [Any]  {
                                errorHandler("Captcha key required. Please login via Discord and then try again.")
                                return
                            }
                            
                            guard let mfa = result["mfa"] as? Bool else {
                                errorHandler("Invaild username or password.")
                                return
                            }
                            
                            
                            if mfa {
                                
                                guard let ticket = result["ticket"] as? String else {
                                  errorHandler("Invaild username or password.")
                                      return
                                }
                                
                                Discord.ticket = ticket
                
                                errorHandler("MFA Required.")
                                
                            } else {
                                errorHandler("Invaild username or password.")
                            }
                            
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
        
        guard let url = URL(string: "https://discordapp.com/api/v6/channels/" + id + "/typing") else { return }
        
        var request = URLRequest(url: url)
        
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
            "nonce": String(Discord.message_count)
        ]
        
        Discord.message_count += 1
        
        guard let id = channel.id else { return }
        
        guard let url = URL(string: "https://discordapp.com/api/v6/channels/" + id + "/messages") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
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
        
        guard let url = URL(string: "https://discordapp.com/api/v6/users/@me/channels") else { return }
        
        var request = URLRequest(url: url)
        
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
    
    public static func getServerMembers(server: Server, limit: Int = 1000, completion: @escaping ([ServerMember]) -> ()){
        
        guard let token = Discord.token else { return }
        
        guard let url = URL(string: "https://discordapp.com/api/v6/guilds/" + (server.id ?? "") + "/members?limit=" + String(limit)) else { return }
        
        var request = URLRequest(url: url)
        
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
        
        guard let url = URL(string: "https://discordapp.com/api/v6/guilds/" + (server.id ?? "") + "/members/" + (user.id ?? "")) else { return }
        
        var request = URLRequest(url: url)
        
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
        
        guard let url = URL(string: "https://discordapp.com/api/v6/users/@me") else { return }
        
        var request = URLRequest(url: url)
        
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
    
    public static func getRoles(server: Server, completion: @escaping ([Role]) -> ()){
        
        guard let token = Discord.token else { return }
        
        guard let url = URL(string: "https://discordapp.com/api/v6/guilds/" + (server.id ?? "") + "/roles") else { return }
        
        var request = URLRequest(url: url)
        
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request, completionHandler: { result, response , error  in
            
            guard let json = result else { return }
            
            let decoder = JSONDecoder()
            
            do {
                
                let server = try decoder.decode([Role].self, from: json)
                
                completion(server)
                
            } catch {
                
                
                
            }
            
            
        })
        
        task.resume()
        
        
    }
    
    public static func getServer(server: Server, completion: @escaping (Server) -> ()){
        
        guard let token = Discord.token else { return }
        
        guard let url = URL(string: "https://discordapp.com/api/v6/guilds/" + (server.id ?? "")) else { return }
        
        var request = URLRequest(url: url)
        
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request, completionHandler: { result, response , error  in
            
            guard let json = result else { return }
            
            let decoder = JSONDecoder()
            
            do {
                
                let server = try decoder.decode(Server.self, from: json)
                
                completion(server)
                
            } catch {
                
                
                
            }
            
            
        })
        
        task.resume()
        
        
    }
    
    
    public static func getServers(completion: @escaping ([Server]) -> (), errorHandler: @escaping (String) -> ()){
        
        guard let token = Discord.token else { return }
        
        guard let url = URL(string: "https://discordapp.com/api/v6/users/@me/guilds") else { return }
        
        var request = URLRequest(url: url)
        
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request, completionHandler: { result, response , error  in
            
            guard let json = result else { return }
            
            let decoder = JSONDecoder()

            do {
                
                let server = try decoder.decode([Server].self, from: json)

                completion(server)

            } catch {
                
                if(String(data: json, encoding: .utf8)?.contains("401") ?? false){
                    errorHandler("401")
                }
                
                errorHandler(error.localizedDescription)
                
            }
            
            
        })
        
        task.resume()
        
        
    }
    
    public static func getChannels(server: Server, completion: @escaping ([Channel]) -> ()) {
        
        
        guard let token = Discord.token else { return }
        
        guard let url = URL(string: "https://discordapp.com/api/v6/guilds/" + (server.id ?? "") + "/channels") else { return }
        
        var request = URLRequest(url: url)
        
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
        
        guard let url = URL(string: "https://discordapp.com/api/v6/channels/" + id + "/messages?limit=" + String(limit)) else { return }
        
        var request = URLRequest(url: url)
        
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default)
        
        print("started")
        
        let task = session.dataTask(with: request, completionHandler: { result, response , error  in
            
            guard let json = result else { return }
            
            let decoder = JSONDecoder()

            do {
                let message = try! decoder.decode([Message].self, from: json)

                completion(message)

            } catch {

                do{

                    let message = try! decoder.decode(Message.self, from: json)

                    completion([message])

                } catch {

                    print(error.localizedDescription)

                }
            }
            
            print(error?.localizedDescription)
            
            
        })
        
        task.resume()

        
    }
    
}
