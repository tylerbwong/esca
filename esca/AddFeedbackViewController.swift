//
//  AddFeedbackViewController.swift
//  esca
//
//  Created by Brittany Berlanga on 12/15/16.
//
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class AddFeedbackViewController: UIViewController {
    @IBOutlet weak var feedbackTypeButton: UIButton!
    @IBOutlet weak var feedbackField: UITextField!
    
    var positiveFeedback = true
    var dealKey: String?
    let feedbackRef:FIRDatabaseReference = FIRDatabase.database().reference().child("feedback")
    let activityRef:FIRDatabaseReference = FIRDatabase.database().reference().child("activity")
    let scoresRef:FIRDatabaseReference = FIRDatabase.database().reference().child("scores")

    override func viewDidLoad() {
        super.viewDidLoad()
        updateFeedbackType()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddFeedbackViewController.addFeedback))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickTypeButton(_ sender: UIButton) {
        positiveFeedback = !positiveFeedback
        updateFeedbackType()
    }
    
    func updateFeedbackType() {
        if positiveFeedback {
            feedbackTypeButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 60)
            feedbackTypeButton.setTitle(String.fontAwesomeIcon(name: .check), for: .normal)
            feedbackTypeButton.setTitleColor(.green, for: .normal)
        }
        else {
            feedbackTypeButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 60)
            feedbackTypeButton.setTitle(String.fontAwesomeIcon(name: .close), for: .normal)
            feedbackTypeButton.setTitleColor(.red, for: .normal)
        }
    }
    
    func addFeedback() {
        if let auth = FIRAuth.auth(), let dealKey = self.dealKey {
            let newFeedback:FIRDatabaseReference = feedbackRef.childByAutoId()
            let newActivity:FIRDatabaseReference = activityRef.childByAutoId()
            let feedbackText = feedbackField.text ?? ""
            let dateFormatter = DateFormatter()
            let timeFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/d/YY"
            timeFormatter.dateFormat = "h:mm a"
            let date = dateFormatter.string(from: Date())
            let time = timeFormatter.string(from: Date())
            newFeedback.setValue(["approved": positiveFeedback, "content": feedbackText, "date": date, "dealKey": dealKey, "time": time, "username": auth.currentUser!.displayName!])
            let dealRef = FIRDatabase.database().reference().child("deals").child(dealKey)
            dealRef.observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let feedbackCount = value?["feedbackCount"] as? NSNumber
                var feedbackType: String?
                var typeCount: NSNumber?
                if self.positiveFeedback {
                    feedbackType = "accepted"
                    typeCount = value?["accepted"] as? NSNumber
                }
                else {
                    feedbackType = "rejected"
                    typeCount = value?["rejected"] as? NSNumber
                }
                dealRef.updateChildValues(["feedbackCount": (feedbackCount?.intValue)! + 1, feedbackType!: (typeCount?.intValue)! + 1])
                _ = self.navigationController?.popViewController(animated: true)
            })
            
            var actionType:Action
            
            if self.positiveFeedback {
                actionType = .accept
            }
            else {
                actionType = .reject
            }
            
            newActivity.setValue(["action": actionType.rawValue,
                                  "dealKey": dealKey,
                                  "username": auth.currentUser!.displayName!,
                                  "date": date,
                                  "time": time])
            
            scoresRef.child(auth.currentUser!.displayName!).observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.hasChild("feedback") {
                    let scoresDict = snapshot.value as! [String : AnyObject]
                    self.scoresRef.child(auth.currentUser!.displayName!).child("feedback").setValue(scoresDict["feedback"] as! Int + 1)
                }
                else {
                    self.scoresRef.child(auth.currentUser!.displayName!).child("feedback").setValue(1)
                }
            })
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
