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
import FontAwesome_swift

class DealDetailViewController: UIViewController {
    @IBOutlet weak var dealImageView: UIImageView!
    @IBOutlet weak var dealTitleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var acceptedButton: UIButton!
    @IBOutlet weak var rejectedButton: UIButton!
    @IBAction func rejectedAction(_ sender: UIButton) {
        // rejected deal
    }
    @IBAction func acceptedAction(_ sender: UIButton) {
        // accepted deal
    }
    @IBAction func directionsAction(_ sender: UIButton) {
        getDirections()
    }
    
    let defaults = UserDefaults.standard
    
    var deal:Deal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem()
        navigationItem.rightBarButtonItem?.target = self
        navigationItem.rightBarButtonItem?.action = #selector(markFavorite)
        let attributes = [NSFontAttributeName: UIFont.fontAwesome(ofSize: 20)]
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
        acceptedButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 30)
        acceptedButton.setTitle(String.fontAwesomeIcon(name: .check), for: .normal)
        acceptedButton.setTitleColor(.green, for: .normal)
        rejectedButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 30)
        rejectedButton.setTitle(String.fontAwesomeIcon(name: .close), for: .normal)
        rejectedButton.setTitleColor(.red, for: .normal)
        
        if defaults.object(forKey: (deal?.key)!) != nil {
            navigationItem.rightBarButtonItem?.title = String.fontAwesomeIcon(name: .star)
        }
        else {
            navigationItem.rightBarButtonItem?.title = String.fontAwesomeIcon(name: .starO)
        }
        
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
            addressLabel.text = "\(deal.location.name!)\n\(deal.location.address!)"
            feedbackButton.setTitle("Feedback (\(deal.feedbackCount!))", for: .normal)
            feedbackButton.contentHorizontalAlignment = .left
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func markFavorite() {
        if defaults.object(forKey: (deal?.key)!) != nil {
            defaults.removeObject(forKey: (deal?.key)!)
            navigationItem.rightBarButtonItem?.title = String.fontAwesomeIcon(name: .starO)
        }
        else {
            defaults.set(nil, forKey: (deal?.key)!)
            navigationItem.rightBarButtonItem?.title = String.fontAwesomeIcon(name: .star)
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFeedback" {
            let controller = segue.destination as! FeedbackViewController
            controller.dealKey = deal?.key
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        if segue.identifier == "positiveFeedback" {
            let controller = segue.destination as! AddFeedbackViewController
            controller.dealKey = deal?.key
            controller.positiveFeedback = true
        }
        if segue.identifier == "negativeFeedback" {
            let controller = segue.destination as! AddFeedbackViewController
            controller.dealKey = deal?.key
            controller.positiveFeedback = false
        }
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
