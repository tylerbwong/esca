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
   var additionalInfo:String!
   var startDate:Date?
   var endDate:Date?
   var photoUrl:String?
   var location:String?
   var feedback:[Feedback]?
   var accepted:Int?
   var rejected:Int?
   var userId:Int!
   var userName:String!
   
   init(id:Int, name:String, additionalInfo:String, startDate:Date, endDate:Date,
        photoUrl:String, location:String, userId:Int, userName:String) {
      self.id = id
      self.name = name
      self.additionalInfo = additionalInfo
      self.startDate = startDate
      self.endDate = endDate
      self.photoUrl = photoUrl
      self.location = location
      self.userId = userId
      self.userName = userName
   }
}
