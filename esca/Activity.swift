//
//  Activity.swift
//  esca
//
//  Created by Tyler Wong on 12/15/16.
//
//

import Foundation
import Firebase

enum Action: String {
    case add = "add"
    case accept = "accept"
    case reject = "reject"
}

class Activity {
    var username:String!
    var dealKey:String!
    var date:String!
    var time:String!
    var action:Action
    
    init(_ username: String, _ dealKey: String, _ action: Action, _ date: String, _ time: String) {
        self.username = username
        self.dealKey = dealKey
        self.action = action
        self.date = date
        self.time = time
    }
    
    func getTemplate(targetUser:String) -> String {
        var template:String!
        
        switch self.action {
        case .add:
            template = "\(username!) added a new deal"
        case .accept:
            template = "\(username!) approved \(targetUser)'s deal"
        case .reject:
            template = "\(username!) rejected \(targetUser)'s deal"
        }
        
        return template
    }
    
    static func toActivity(from snapshot: FIRDataSnapshot) -> Activity {
        let activityDict = snapshot.value as! [String : AnyObject]
        var activity: Activity
        
        activity = Activity(activityDict["username"] as! String, activityDict["dealKey"] as! String, Action(rawValue: activityDict["action"] as! String)!, activityDict["date"] as! String, activityDict["time"] as! String)
        return activity
    }
}
