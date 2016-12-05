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

class DealViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
   @IBOutlet weak var dealTableView: UITableView!
   
   //let request = MKLocalSearchRequest()
   
   var dealsRef:FIRDatabaseReference = FIRDatabase.database().reference().child("deals")
   var deals:[Deal] = []

   override func viewDidLoad() {
      super.viewDidLoad()
      
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

   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
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
      return deals.count
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "dealCell", for: indexPath) as? DealCell
      let curDeal = deals[indexPath.row]
      
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
