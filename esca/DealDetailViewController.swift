//
//  DealDetailViewController.swift
//  esca
//
//  Created by Tyler Wong on 12/10/16.
//
//

import UIKit
import MapKit
import Kingfisher

class DealDetailViewController: UIViewController {
    @IBOutlet weak var dealImageView: UIImageView!
    @IBOutlet weak var dealTitleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBAction func directionsAction(_ sender: UIButton) {
        getDirections()
    }
    
    var deal:Deal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let deal = self.deal {
            dealImageView.kf.setImage(with: URL(string: deal.photoUrl!))
            dealTitleLabel.text = deal.name
            self.title = deal.name
            authorLabel.text = "by \(deal.username!)"
            
            if deal.percentage != "nan%" {
                percentLabel.text = deal.percentage;
            }
            else {
                percentLabel.text = "0%"
            }
            
            descriptionLabel.text = deal.description
            addressLabel.text = deal.location.address
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getDirections() {
        if let location = deal?.location {
            let latitude: CLLocationDegrees = location.latitude
            let longitude: CLLocationDegrees = location.longitude
            let regionDistance: CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan:regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            
            if let deal = self.deal {
                mapItem.name = deal.name
            }
            mapItem.openInMaps(launchOptions: options)
        }
    }
}
