//
//  Deal.swift
//  esca
//
//  Created by Tyler Wong on 11/18/16.
//
//

import Foundation

class Deal {
   var id:Int!
   var name:String!
   var description:String!
   var startDate:String?
   var endDate:String?
   var photoUrl:String?
   var location:String?
   var feedback:[Feedback]?
   var accepted:Int?
   var rejected:Int?
   var percentage:String {
      get {
         return String(format: "%.0f", (Float(accepted!) / Float(rejected! + accepted!)) * 100) + "%";
      }
   }
   var userId:Int!
   var username:String!
   
   init(_ id:Int, _ name:String, _ description:String, _ startDate:String, _ endDate:String,
        _ photoUrl:String, _ location:String, _ userId:Int, _ username:String) {
      self.id = id
      self.name = name
      self.description = description
      self.startDate = startDate
      self.endDate = endDate
      self.photoUrl = photoUrl
      self.location = location
      self.userId = userId
      self.username = username
   }
}
