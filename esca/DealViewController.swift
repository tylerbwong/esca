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

class DealViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var dealTableView: UITableView!
    
    let defaults = UserDefaults.standard
    
    var dealsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("deals")
    var deals: [Deal] = []
    var filtered: [Deal] = []
    var searchActive: Bool = false
    var deal: Deal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dealsRef.observe(.childAdded, with: {(snapshot) in
            let tempDeal = Deal.toDeal(from: snapshot)
            
            self.deals.insert(tempDeal, at: 0)
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
    
    
    // MARK: - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDeal" {
            if let deal = self.deal {
                let controller = segue.destination as! DealDetailViewController
                controller.deal = deal
            }
            else if let indexPath = dealTableView.indexPathForSelectedRow {
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
