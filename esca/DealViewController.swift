//
//  MainViewController.swift
//  esca
//
//  Created by Tyler Wong on 11/22/16.
//
//

import UIKit
import FirebaseDatabase

class DealViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
   @IBOutlet weak var dealTableView: UITableView!
   
   var dealsRef:FIRDatabaseReference = FIRDatabase.database().reference().child("deals")
   var deals:[Deal] = []

   override func viewDidLoad() {
      super.viewDidLoad()
      
      dealsRef.observe(.childAdded, with: {(snapshot) in
         let postDict = snapshot.value as? [String : AnyObject] ?? [:]
         var tempDeal:Deal
         
         tempDeal = Deal(postDict["id"] as! Int, postDict["name"] as! String, postDict["description"] as! String, postDict["startDate"] as! String, postDict["endDate"] as! String, postDict["photoUrl"] as! String, "", 0, postDict["username"] as! String)
         tempDeal.accepted = postDict["accepted"] as? Int
         tempDeal.rejected = postDict["rejected"] as? Int
         self.deals.append(tempDeal)
         
         self.dealTableView.reloadData()
      })
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
      
      cell?.dealImage.downloadedFrom(link: curDeal.photoUrl!)
      cell?.dealTitleLabel.text = curDeal.name!
      cell?.dealAuthorLabel.text = "by \(curDeal.username!)"
      cell?.dealDateLabel.text = curDeal.startDate!
      cell?.dealDescriptionLabel.text = curDeal.description!
      cell?.dealPercentLabel.text = curDeal.percentage;
      
      return cell!
      
   }
}

extension UIImageView {
   func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
      contentMode = mode
      URLSession.shared.dataTask(with: url) { (data, response, error) in
         guard
            let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
            let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
            let data = data, error == nil,
            let image = UIImage(data: data)
            else {
               return
         }
         DispatchQueue.main.async() { () -> Void in
            self.image = image
         }
         }.resume()
   }
   func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
      guard let url = URL(string: link) else { return }
      downloadedFrom(url: url, contentMode: mode)
   }
}
