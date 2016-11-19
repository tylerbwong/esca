//
//  FirebaseApi.swift
//  esca
//
//  Created by Tyler Wong on 11/18/16.
//
//

import Foundation
import Firebase

class FirebaseApi {
   var firebaseApi:FirebaseApi!
   var databaseRef:FIRDatabaseReference!
   
   static var USERS:String = "users"
   
   init() {
      databaseRef = FIRDatabase.database().reference()
   }
   
   func getInstance() -> FirebaseApi {
      if firebaseApi == nil {
         firebaseApi = FirebaseApi()
      }
      return firebaseApi
   }
   
   func addUser(user:User) -> Bool {
      let userRef:FIRDatabaseReference = databaseRef.child(FirebaseApi.USERS).child(String(user.id))
      
      userRef.child(User.NAME).setValue(user.name)
      userRef.child(User.EMAIL).setValue(user.email)
      userRef.child(User.NUM_DEALS).setValue(0)
      userRef.child(User.FEEDBACK_GIVEN).setValue(0)
      userRef.child(User.DEALS_USED).setValue(0)
      
      return true
   }
   
   func addUserFriends(id:String, friends:[User]) -> Bool {
      let userRef:FIRDatabaseReference =
         databaseRef.child(FirebaseApi.USERS).child(id).child(User.FRIENDS)
      var friendRef:FIRDatabaseReference
      
      for user in friends {
         friendRef = userRef.child(String(user.id))
         friendRef.child(User.NAME).setValue(user.name)
         friendRef.child(User.EMAIL).setValue(user.email)
         friendRef.child(User.NUM_DEALS).setValue(user.numDeals)
         friendRef.child(User.FEEDBACK_GIVEN).setValue(user.feedbackGiven)
         friendRef.child(User.DEALS_USED).setValue(user.dealsUsed)
      }
      
      return true
   }
   
   func addDeal(deal:Deal) -> Bool {
      return true
   }
   
   func addFeedback(dealId:Deal, feedback:Feedback) -> Bool {
      return true
   }
   
   func addActivityEntry(entry:ActivityEntry) -> Bool {
      return true
   }
}
