//
//  RestaurantSearchTableViewController.swift
//  esca
//
//  Created by Brittany Berlanga on 12/5/16.
//
//

import UIKit
import MapKit

class RestaurantSearchTableViewController: UITableViewController {
    let request = MKLocalSearchRequest()
    let locationManager = CLLocationManager()
    let searchController  = UISearchController(searchResultsController: nil)
    var locations = [Location]()
    var region: MKCoordinateRegion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return locations.count
        }
        return 0
    }
    
    func filterRestaurants(searchText: String) {
        request.naturalLanguageQuery = searchText
        request.region = region!
        
        locations.removeAll()
        var newLocation: Location?
        let search = MKLocalSearch(request: request)
        search.start(completionHandler: {(response, error) in
            if let response = response {
                for item in response.mapItems {
                    let clLocation = item.placemark.location
                    let addressInfo = item.placemark.addressDictionary
                    var addressString = ""
                    if let lines: Array<String> = addressInfo?["FormattedAddressLines"] as? Array<String> {
                        addressString = lines.joined(separator: ", ")
                    }
                    newLocation = Location(item.name!, addressString, (clLocation?.coordinate.latitude)!, (clLocation?.coordinate.longitude)!)
                    self.locations.append(newLocation!)
                }
                self.tableView.reloadData()
            }
        })
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantInfoCell", for: indexPath) as! RestaurantSearchTableViewCell
        if locations.count > indexPath.row {
            let location = locations[indexPath.row]
            cell.restaurantInfoLabel.text = location.formattedString
        }
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        locationManager.stopUpdatingLocation()
     }
}

extension RestaurantSearchTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterRestaurants(searchText: searchController.searchBar.text!)
    }
}
extension RestaurantSearchTableViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    }
}
