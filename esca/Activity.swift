//
//  Activity.swift
//  esca
//
//  Created by Tyler Wong on 12/15/16.
//
//

import Foundation

enum Action {
    case add
    case accept
    case reject
    
    var description: String {
        switch self {
        case .add:
            return "add"
        case .accept:
            return "accept"
        case .reject:
            return "reject"
        }
    }
}

class Activity {
    var username:String!
    var dealKey:Int!
    var date:String!
    var time:String!
    var action:Action
    
    init(username:String, dealKey:Int, action:Action) {
        self.username = username
        self.dealKey = dealKey
        self.action = action
    }
    
    func getTemplate(targetUser:String) -> String {
        var template:String!
        
        switch self.action {
        case .add:
            template = "\(username) added a new deal"
        case .accept:
            template = "\(username) approved \(targetUser)'s deal"
        case .reject:
            template = "\(username) rejected \(targetUser)'s deal"
        }
        
        return template
    }
}
