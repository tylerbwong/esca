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
   
   //let request = MKLocalSearchRequest()
   
   var dealsRef:FIRDatabaseReference = FIRDatabase.database().reference().child("deals")
   var deals:[Deal] = []
   var filtered:[Deal] = []
   var searchActive:Bool = false

   override func viewDidLoad() {
      super.viewDidLoad()
      locationManager.delegate = self
      locationManager.requestAlwaysAuthorization()
      self.locationManager.startUpdatingLocation()
    
//      request.naturalLanguageQuery = "Restaurants"
//      request.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(35.2539788, -120.6942357), MKCoordinateSpanMake(10.0, 10.0))
//      
//      let search = MKLocalSearch(request: request)
//      search.start(completionHandler: {(response, error) in
//         for item in response!.mapItems {
//            print("Name = \(item.name)")
//            print("Phone = \(item.phoneNumber)")
//         }
//      })
         
      dealsRef.observe(.childAdded, with: {(snapshot) in
         let postDict = snapshot.value as? [String : AnyObject] ?? [:]
         var tempDeal:Deal
         
         tempDeal = Deal(postDict["name"] as! String, postDict["description"] as! String, postDict["startDate"] as! String, postDict["endDate"] as! String, postDict["photoUrl"] as! String, "", postDict["username"] as! String)
         tempDeal.accepted = postDict["accepted"] as? Int
         tempDeal.rejected = postDict["rejected"] as? Int
         self.deals.append(tempDeal)
         self.dealTableView.reloadData()
      })
      
      dealsRef.observe(.childRemoved, with: {(snapshot) in
         let index = self.indexOfDeal(snapshot: snapshot)
         self.deals.remove(at: index)
         self.dealTableView.reloadData()
      })
    
      startMonitoring(coordinate: CLLocationCoordinate2D(latitude: 37.331695, longitude: -122.0322801), radius: 1000, identifier: "There's a new deal nearby")
   }
   
   func indexOfDeal(snapshot: FIRDataSnapshot) -> Int {
      var index = 0
      let postDict = snapshot.value as? [String : AnyObject] ?? [:]
      
      for deal in self.deals {
         if (postDict["photoUrl"] as? String == deal.photoUrl) {
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
    
   /*
   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      // Get the new view controller using segue.destinationViewController.
      // Pass the selected object to the new view controller.
   }
   */
   
   // MARK: - Table view data source
   
   func numberOfSections(in tableView: UITableView) -> Int {
      return 1
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if (searchActive) {
         return filtered.count
      }
      return deals.count
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "dealCell", for: indexPath) as? DealCell
      let curDeal:Deal
      
      if (searchActive) {
         curDeal = filtered[indexPath.row]
      }
      else {
         curDeal = deals[indexPath.row]
      }
      
      cell?.dealImage.kf.setImage(with: URL(string: curDeal.photoUrl!))
      cell?.dealTitleLabel.text = curDeal.name!
      cell?.dealAuthorLabel.text = "by \(curDeal.username!)"
      cell?.dealDateLabel.text = curDeal.startDate!
      cell?.dealDescriptionLabel.text = curDeal.description!
      
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
