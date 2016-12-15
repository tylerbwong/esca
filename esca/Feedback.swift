//
//  Feedback.swift
//  esca
//
//  Created by Tyler Wong on 11/18/16.
//
//

import Foundation

class Feedback {
    var dealKey: String!
    var approved: Bool?
    var content: String?
    var username: String!
    var date: String!
    var time: String!
    
    init(_ dealKey: String, _ approved: Bool, _ content: String, _ username: String, _ date: String, _ time: String) {
        self.approved = approved
        self.content = content
        self.username = username
        self.date = date
        self.time = time
    }
}
