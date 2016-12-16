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
import Kingfisher


class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    let locationManager = CLLocationManager()
    var annotations:[DealAnnotation] = []
    
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
            let photoUrl:String = postDict["photoUrl"] as! String
            
            let point = DealAnnotation(coordinate: coordinates)
            point.deal = postDict["name"] as? String
            point.dealDescription = postDict["description"] as? String
            point.restaurant = postDict["location"]?["name"] as? String
            point.image = photoUrl
            
            self.annotations.append(point)
            self.map.addAnnotation(point)
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
            if (postDict["location"]?["latitude"] as? Double == annotation.coordinate.latitude && postDict["location"]?["longitude"] as? Double == annotation.coordinate.longitude && postDict["location"]?["name"] as? String == annotation.deal && postDict["name"] as? String == annotation.dealDescription) {
                return index
            }
            index += 1
        }
        
        return -1
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation
        {
            return nil
        }
        var annotationView = self.map.dequeueReusableAnnotationView(withIdentifier: "Pin")
        annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "Pin")
        annotationView?.canShowCallout = false
        annotationView?.image = UIImage(named: "icon.png")
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView,
                 didSelect view: MKAnnotationView)
    {
        // 1
        if view.annotation is MKUserLocation
        {
            // Don't proceed with custom callout
            return
        }
        // 2
        let dealAnnotation = view.annotation as! DealAnnotation
        let views = Bundle.main.loadNibNamed("DealAnnotationView", owner: nil, options: nil)
        let calloutView = views?[0] as! DealAnnotationView
        calloutView.DealLabel.text = dealAnnotation.deal
        calloutView.DescLabel.text = dealAnnotation.dealDescription
        calloutView.RestLabel.text = dealAnnotation.restaurant
        
        // TODO: Keep for future reference to have the pin be clickable to the deal
        // let button = UIButton(frame: calloutView.RestLabel.frame)
        // button.addTarget(self, action: #selector(ViewController.toDealViewController(sender:)), for: .touchUpInside)
        // calloutView.addSubview(button)
        calloutView.RestImage.kf.setImage(with: URL(string: dealAnnotation.image))
        // 3
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
        view.addSubview(calloutView)
       // map.setCenter((view.annotation?.coordinate)!, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: AnnotationView.self)
        //    if view.isKind(of: DealAnnotationView.self)
        {
            for subview in view.subviews
            {
                subview.removeFromSuperview()
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        map.setRegion(region, animated: true)
    }
}
