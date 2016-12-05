//
//  Location.swift
//  esca
//
//  Created by Tyler Wong on 12/4/16.
//
//

import Foundation

class Location {
    var name: String!
    var address: String!
    var latitude: Double!
    var longitude: Double!
    
    var formattedString: String {
        return "\(name!) \(address!) (\(latitude!), \(longitude!))"
    }
    
    init(_ name: String, _ address: String, _ latitude: Double, _ longitude: Double) {
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
    
}
