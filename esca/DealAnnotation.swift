//
//  DealAnnotation.swift
//  esca
//
//  Created by Brandon Vo on 12/5/16.
//
//


import MapKit

class DealAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var deal: String!
    var dealDescription: String!
    var restaurant: String!
    var image: String!
    
    
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
