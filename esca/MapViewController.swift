//
//  MapViewController.swift
//  esca
//
//  Created by Brandon Vo on 12/4/16.
//
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase
import SideMenu


class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    let locationManager = CLLocationManager()
    var annotations:[MKPointAnnotation] = []
    
    var dealsRef:FIRDatabaseReference = FIRDatabase.database().reference().child("deals")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        map.delegate = self
        map.mapType = .standard
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.userTrackingMode = .follow
        
        dealsRef.observe(.childAdded, with: {(snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]

            let coordinates = CLLocationCoordinate2DMake(postDict["location"]?["latitude"] as! Double, postDict["location"]?["longitude"] as! Double)
            let dropPin = MKPointAnnotation()
            dropPin.coordinate = coordinates
            dropPin.title = postDict["location"]?["name"] as? String
            dropPin.subtitle = postDict["name"] as? String
            self.annotations.append(dropPin)
            self.map.addAnnotation(dropPin)
        })
        dealsRef.observe(.childRemoved, with: {(snapshot) in
            let index = self.indexOfDeal(snapshot: snapshot)
            self.map.removeAnnotation(self.annotations.remove(at: index))
        })
    }
    
    func indexOfDeal(snapshot: FIRDataSnapshot) -> Int {
        var index = 0
        let postDict = snapshot.value as? [String : AnyObject] ?? [:]
        
        for annotation in self.annotations {
            if (postDict["location"]?["latitude"] as? Double == annotation.coordinate.latitude) {
                return index
            }
            index += 1
        }
        
        return -1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        
        map.setRegion(region, animated: true)
    }
}
