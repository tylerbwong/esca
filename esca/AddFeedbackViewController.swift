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
            let feedbackText = feedbackField.text ?? ""
            let dateFormatter = DateFormatter()
            let timeFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/d/YY"
            timeFormatter.dateFormat = "h:mm a"
            newFeedback.setValue(["approved": positiveFeedback, "content": feedbackText, "date": dateFormatter.string(from: Date()), "dealKey": dealKey, "time": timeFormatter.string(from: Date()), "username": auth.currentUser!.displayName!])
            _ = self.navigationController?.popViewController(animated: true)
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
