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
            let dealDict = snapshot.value as? [String : AnyObject] ?? [:]
            var tempDeal: Deal
            
            tempDeal = Deal(snapshot.key, dealDict["name"] as! String, dealDict["description"] as! String, dealDict["startDate"] as! String, dealDict["endDate"] as! String, dealDict["photoUrl"] as! String, Location(dealDict["location"]?["name"] as! String, dealDict["location"]?["address"] as! String, dealDict["location"]?["latitude"] as! Double, dealDict["location"]?["longitude"] as! Double), dealDict["username"] as! String)
            tempDeal.feedbackCount = dealDict["feedbackCount"] as? Int
            tempDeal.accepted = dealDict["accepted"] as? Int
            tempDeal.rejected = dealDict["rejected"] as? Int

            let coordinates = CLLocationCoordinate2DMake(dealDict["location"]?["latitude"] as! Double, dealDict["location"]?["longitude"] as! Double)
            let photoUrl:String = tempDeal.photoUrl!
            
            let point = DealAnnotation(coordinate: coordinates)
            point.deal = tempDeal.name
            point.dealDescription = tempDeal.description
            point.restaurant = dealDict["location"]?["name"] as? String
            point.image = photoUrl
            point.dealObj = tempDeal
            
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
        
        for annotation in self.annotations {
            if (snapshot.key == annotation.dealObj.key) {
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
        calloutView.deal = dealAnnotation.dealObj
        
        // TODO: Keep for future reference to have the pin be clickable to the deal
         let button = UIButton(frame: calloutView.RestLabel.frame)
         button.addTarget(self, action: #selector(toDealViewController(sender:)), for: .touchUpInside)
         calloutView.addSubview(button)
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
    
    func toDealViewController(sender: UIButton){
        let dealAnnotation = sender.superview as! DealAnnotationView
        let dealViewController = self.storyboard?.instantiateViewController(withIdentifier: "DealDetail") as? DealDetailViewController
        dealViewController?.deal = dealAnnotation.deal
        self.navigationController?.pushViewController(dealViewController!, animated: true)

        
    }
}
