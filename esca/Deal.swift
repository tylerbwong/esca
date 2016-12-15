//
//  Deal.swift
//  esca
//
//  Created by Tyler Wong on 11/18/16.
//
//

import Foundation

class Deal {
    var key:String!
    var name:String!
    var description:String!
    var startDate:String?
    var endDate:String?
    var photoUrl:String?
    var location:Location!
    var feedbackCount:Int!
    var accepted:Int?
    var rejected:Int?
    var percentage:String? {
        get {
            let percentage:String = String(format: "%.0f", (Float(accepted!) / Float(rejected! + accepted!)) * 100) + "%"
            
            if percentage != "nan%" {
                return percentage
            }
            else {
                return "0%"
            }
        }
    }
    var username:String!
    
    init(_ key:String, _ name:String, _ description:String, _ startDate:String, _ endDate:String,
         _ photoUrl:String, _ location:Location, _ username:String) {
        self.key = key
        self.name = name
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.photoUrl = photoUrl
        self.location = location
        self.username = username
    }
}
