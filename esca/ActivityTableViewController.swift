//
//  ActivityTableViewController.swift
//  esca
//
//  Created by Tyler Wong on 12/16/16.
//
//

import UIKit
import Firebase

class ActivityTableViewController: UITableViewController {
    
    let dealsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("deals")
    let activityRef: FIRDatabaseReference = FIRDatabase.database().reference().child("activity")
    
    var activities: [Activity] = []
    var deal: Deal?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Activity"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ActivityTableViewController.showMenu))

        activityRef.observe(.childAdded, with: { (snapshot) in
            let tempActivity = Activity.toActivity(from: snapshot)
            
            self.activities.insert(tempActivity, at: 0)
            self.tableView.reloadData()
        })
    }
    
    func showMenu() {
        self.performSegue(withIdentifier: "ActivityOpenMenu", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return activities.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dealsRef.child(activities[indexPath.row].dealKey).observeSingleEvent(of: .value, with: { snapshot in
            let deal: Deal = Deal.toDeal(from: snapshot)
            self.deal = deal
            self.performSegue(withIdentifier: "showDealFromActivity", sender: self)
        })

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! ActivityCell
        let tempActivity = activities[indexPath.row]
        
        cell.dateTimeLabel.text = "\(tempActivity.time!) | \(tempActivity.date!)"
        
        if tempActivity.action != .add {
            dealsRef.child(tempActivity.dealKey).observeSingleEvent(of: .value, with: { snapshot in
                let dealsDict = snapshot.value as! [String : AnyObject]
                cell.descriptionLabel.text = tempActivity.getTemplate(targetUser: dealsDict["username"] as! String)
            })
        }
        else {
            cell.descriptionLabel.text = tempActivity.getTemplate(targetUser: "")
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
        if segue.identifier == "showDealFromActivity" {
            let controller = segue.destination as! DealDetailViewController
            controller.deal = self.deal
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
 

}
