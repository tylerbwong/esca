//
//  MainViewController.swift
//  esca
//
//  Created by Tyler Wong on 11/22/16.
//
//

import UIKit

class DealViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
   @IBOutlet weak var dealTableView: UITableView!
   
   var deals:[Deal] = []

   override func viewDidLoad() {
      super.viewDidLoad()

      // Do any additional setup after loading the view.
      let tempDeal1:Deal = Deal(0, "Buffalo Wild Wings", "35 cent wings on Tuesday!", Date(), Date(),
                           "http://s.thestreet.com/files/tsc/v2008/photos/contrib/uploads/buffalo-wild-wings-outside-3.jpg",
                           "Madonna Road", 0, "Brandon Vo")
      tempDeal1.accepted = 85
      tempDeal1.rejected = 15
      
      let tempDeal2:Deal = Deal(1, "Sylvester's Burgers", "Free burgers with coupon!", Date(), Date(),
                                "https://c1.staticflickr.com/7/6155/6188142428_86c62860d9_b.jpg",
                                "Los Osos", 0, "Brittany Berlanga")
      tempDeal2.accepted = 10
      tempDeal2.rejected = 0
      
      deals.append(tempDeal1)
      deals.append(tempDeal2)
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
      cell?.dealDateLabel.text = "11/15/16"
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
