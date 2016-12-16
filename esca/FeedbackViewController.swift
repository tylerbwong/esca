//
//  FeedbackViewController.swift
//  esca
//
//  Created by Tyler Wong on 12/14/16.
//
//

import UIKit
import FirebaseDatabase

class FeedbackViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let feedbackRef = FIRDatabase.database().reference().child("feedback")
    
    var feedback: [Feedback] = []
    var dealKey: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Feedback"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFeedback))
        
        // all feedback is contained in a separate node away from the deals node
        // each feedback child contains a field "dealKey" that has the deal key of the
        // deal that it is associated with.
        // The below calls get the specific feedback items with that dealkey that we get from
        // the previous view controller
        feedbackRef.queryOrdered(byChild: "dealKey").queryEqual(toValue: dealKey!).observe(.childAdded, with: { snapshot in
            let feedbackDict = snapshot.value as! [String : AnyObject]
            var tempFeedback: Feedback
            
            tempFeedback = Feedback(snapshot.key, feedbackDict["approved"] as! Bool, feedbackDict["content"] as! String, feedbackDict["username"] as! String, feedbackDict["date"] as! String, feedbackDict["time"] as! String)
            self.feedback.insert(tempFeedback, at: 0)
            // refresh the table view of feedback objects
            // see DealViewController for reference
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addFeedback() {
        // Go to add feedback
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
        return feedback.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedbackCell", for: indexPath) as? FeedbackCell
        let tempFeedback = feedback[indexPath.row]
        cell?.userLabel.text = tempFeedback.username
        cell?.dateTimeLabel.text = "\(tempFeedback.time!) | \(tempFeedback.date!)"
        cell?.contentLabel.text = tempFeedback.content
        cell?.typeLabel.font = UIFont.fontAwesome(ofSize: 30)
        
        if tempFeedback.approved! {
            cell?.typeLabel.text = String.fontAwesomeIcon(name: .check)
            cell?.typeLabel.textColor = .green
        }
        else {
            cell?.typeLabel.text = String.fontAwesomeIcon(name: .close)
            cell?.typeLabel.textColor = .red
        }
        
        return cell!
        
    }


}
