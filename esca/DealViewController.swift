//
//  MainViewController.swift
//  esca
//
//  Created by Tyler Wong on 11/22/16.
//
//

import UIKit
import MapKit
import Kingfisher
import FirebaseDatabase
import CoreLocation

class DealViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var dealTableView: UITableView!
    
    let locationManager = CLLocationManager()
    let defaults = UserDefaults.standard
    
    var dealsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("deals")
    var deals: [Deal] = []
    var filtered: [Deal] = []
    var searchActive: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        
        dealsRef.observe(.childAdded, with: {(snapshot) in
            let tempDeal = Deal.toDeal(from: snapshot)
            
            self.deals.append(tempDeal)
            self.dealTableView.reloadData()
        })
        
        dealsRef.observe(.childRemoved, with: {(snapshot) in
            let index = self.indexOfDeal(snapshot: snapshot)
            self.defaults.removeObject(forKey: self.deals[index].key)
            self.deals.remove(at: index)
            self.dealTableView.reloadData()
        })
        
        dealsRef.observe(.childChanged, with: {(snapshot) in
            let index = self.indexOfDeal(snapshot: snapshot)
            let tempDeal = Deal.toDeal(from: snapshot)
            self.deals[index] = tempDeal
            
            self.dealTableView.reloadData()
        })
        
        // Implemented Geofencing! Use LocationTest.gpx when mocking location (close app when preforming test)
        startMonitoring(coordinate: CLLocationCoordinate2D(latitude: 37.331695, longitude: -122.0322801), radius: 1000, identifier: "There's a new deal nearby")
    }
    
    func indexOfDeal(snapshot: FIRDataSnapshot) -> Int {
        var index = 0
        
        for deal in self.deals {
            if (snapshot.key == deal.key) {
                return index
            }
            index += 1
        }
        
        return -1
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtered = deals.filter() {
            $0.name!.lowercased().range(of: searchText.lowercased()) != nil || $0.username!.lowercased().range(of: searchText.lowercased()) != nil
        }
        
        if(filtered.count == 0){
            searchActive = false;
        }
        else {
            searchActive = true;
        }
        
        self.dealTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startMonitoring(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            print("Error: Geofencing is not supported on this device!")
            return
        }
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            print("Warning: Your geotification is saved but will only be activated once you grant Geotify permission to access the device location.")
        }
        let region = CLCircularRegion(center: coordinate, radius: radius, identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = !region.notifyOnEntry
        locationManager.startMonitoring(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
    
    
    // MARK: - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDeal" {
            if let indexPath = dealTableView.indexPathForSelectedRow {
                let deal:Deal
                if filtered.count > 0 {
                    deal = filtered[indexPath.row]
                }
                else {
                    deal = deals[indexPath.row]
                }
                let controller = segue.destination as! DealDetailViewController
                controller.deal = deal
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filtered.count
        }
        return deals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dealCell", for: indexPath) as? DealCell
        let curDeal:Deal
        
        if filtered.count > 0 {
            curDeal = filtered[indexPath.row]
        }
        else {
            curDeal = deals[indexPath.row]
        }
        
        cell?.dealImage.kf.setImage(with: URL(string: curDeal.photoUrl!))
        cell?.dealTitleLabel.text = curDeal.location.name!
        cell?.dealAuthorLabel.text = "by \(curDeal.username!)"
        cell?.dealDateLabel.text = curDeal.startDate!
        cell?.dealDescriptionLabel.text = curDeal.name!
        
        if curDeal.percentage != "nan%" {
            cell?.dealPercentLabel.text = curDeal.percentage;
        }
        else {
            cell?.dealPercentLabel.text = "0%"
        }
        
        return cell!
        
    }
}

// MARK: - CLLocationManagerDelegate
extension DealViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
            return
        }
        
        if UIApplication.shared.applicationState == .active {
            print("The app is updating", mostRecentLocation)
        } else {
            print("App is backgrounded. New location is %@", mostRecentLocation)
        }
    }
    
}
