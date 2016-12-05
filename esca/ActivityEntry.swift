//
//  ActivityEntry.swift
//  esca
//
//  Created by Tyler Wong on 11/18/16.
//
//

import Foundation

enum Action {
    case ADD, ACCEPT, REJECT, FEEDBACK
}

class ActivityEntry {
    var userId:Int!
    var userName:String!
    var dealId:Int!
    var action:Action!
    
    init(userId:Int, userName:String, dealId:Int, action:Action) {
        self.userId = userId
        self.userName = userName
        self.dealId = dealId
        self.action = action
    }
}
