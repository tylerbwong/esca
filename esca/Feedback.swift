//
//  Feedback.swift
//  esca
//
//  Created by Tyler Wong on 11/18/16.
//
//

import Foundation

class Feedback {
   var approved:Bool!
   var description:String?
   var userId:Int!
   var userName:String!
   var timestamp:Date!
   
   init(approved:Bool, description:String, userId:Int, userName:String, timestamp:Date) {
      self.approved = approved
      self.description = description
      self.userId = userId
      self.userName = userName
      self.timestamp = timestamp
   }
}
