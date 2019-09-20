//
//  ChannelController.swift
//  Discord WatchKit Extension
//
//  Created by Reuben on 25/05/19.
//  Copyright © 2019 Reuben. All rights reserved.
//

import WatchKit

class ChannelController: WKInterfaceController {
    
    @IBOutlet weak var table: WKInterfaceTable?
    @IBOutlet weak var ai: WKInterfaceImage?
    
    var channels: [Channel]?
    
    var categories: [Channel]? = []
    
    func show(){
        table?.setHidden(false)
        ai?.setHidden(true)
    }

    func hide(){
        table?.setHidden(true)
        ai?.setHidden(false)
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        if channels?[rowIndex].type != 4 {
            
            self.pushController(withName: "Message", context: self.channels?[rowIndex])
           
            
        }
        
    }
    
    func compute_base_permissions(member: ServerMember, guild: Server) -> Int {
        if(guild.owner ?? false){
            return PermissionType.ALL
        }

        let role_everyone = guild.getRole(id: guild.id!)
        
        var permissions = role_everyone.permissions ?? PermissionType.VIEW_CHANNEL

        for role in member.roles ?? [] {
            
            permissions |= guild.roles?.first(where: { $0.id == role})?.permissions ?? PermissionType.NONE
            
        }

        if permissions & PermissionType.ADMINISTRATOR == PermissionType.ADMINISTRATOR {
            return PermissionType.ALL
        }

        return permissions
        
    }
    
    func compute_overwrites(base_permissions: Int, member: ServerMember, channel: Channel) -> Int{
        // ADMINISTRATOR overrides any potential permission overwrites, so there is nothing to do here.
        if base_permissions & PermissionType.ADMINISTRATOR == PermissionType.ADMINISTRATOR {
            return PermissionType.ALL
        }

        var permissions = base_permissions
        
        if let overwrite_everyone = channel.permission_overwrites?.first(where: { $0?.id == channel.server?.id}) {

            permissions &= ~overwrite_everyone!.deny!
            permissions |= overwrite_everyone!.allow!
        
        } 

        // Apply role specific overwrites.
        
        let overwrites = channel.permission_overwrites
        var allow = PermissionType.NONE
        var deny = PermissionType.NONE
        
        for role_id in member.roles ?? [] {
            if let overwrite_role = overwrites?.first(where: { $0?.id == role_id}) {
                allow |= overwrite_role?.allow ?? 0
                deny |= overwrite_role?.deny ?? 0
            }
            
        }

        permissions &= ~deny
        permissions |= allow

        // Apply member specific overwrite if it exist.
        
        if let overwrite_member = overwrites?.first(where: { $0?.id == member.user?.id} ) {
            permissions &= ~overwrite_member!.deny!
            permissions |= overwrite_member?.allow ?? 0
        }
        
        return permissions
        
    }
    
    func compute_permissions(member: ServerMember, channel: Channel) -> Int {
        
        let base_permissions = compute_base_permissions(member: member, guild: channel.server ?? Server())
        
        return compute_overwrites(base_permissions: base_permissions, member: member, channel: channel)
        
        
    }
    
    override func awake(withContext context: Any?) {
        
        hide()
        
        if let server = context as? Server {
                
            var channels = server.channels ?? []
            
            print(channels)
                
                var index = 0
                
                for _ in channels{
                    
                    channels[index].addServer(server: server)
                    
                    index += 1
                }
            


            channels = channels.sorted(by: { $0.position ?? 0 < $1.position ?? 0 }).filter({$0.type == 0 && (self.compute_permissions(member: server.user ?? ServerMember(), channel: $0) & PermissionType.VIEW_CHANNEL) == PermissionType.VIEW_CHANNEL})

                
                    self.channels = channels
                    
                    self.categories = channels.filter {$0.type == 4}
                    
                    self.table?.setNumberOfRows(channels.count, withRowType: "ChannelRow")
                                
                    for index in 0..<(self.table?.numberOfRows ?? 0) {
                                    
                        let row = self.table?.rowController(at: index) as? ChannelRowController //get the row
                                    
                        var channel = channels[index]
                                    
                        channel.addServer(server: server)
                                    
                        row?.channel = channel
                                    
                    }
                                
                    self.show()

            
                            
                
        }
        
    }
    
}
