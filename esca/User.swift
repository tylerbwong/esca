//
//  User.swift
//  esca
//
//  Created by Tyler Wong on 11/18/16.
//
//

import Foundation

class User {
    var id:Int!
    var name:String?
    var profileUrl:String?
    var email:String?
    var numDeals:Int?
    var feedbackGiven:Int?
    var dealsUsed:Int?
    var friends:[User]?
    
    static var NAME:String = "name"
    static var EMAIL:String = "email"
    static var NUM_DEALS:String = "deals"
    static var FEEDBACK_GIVEN:String = "feedbak"
    static var DEALS_USED:String = "used"
    static var FRIENDS:String = "friends"
    
    init(id:Int, name:String, profileUrl:String, email:String) {
        self.id = id
        self.name = name
        self.profileUrl = profileUrl
        self.email = email
        self.numDeals = 0
        self.feedbackGiven = 0
        self.dealsUsed = 0
        self.friends = []
    }
}
