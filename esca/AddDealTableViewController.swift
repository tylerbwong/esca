//
//  AddDealTableViewController.swift
//  esca
//
//  Created by Brittany Berlanga on 12/3/16.
//
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class AddDealTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var dealImage: UIImageView!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var dealTitleField: UITextField!
    @IBOutlet weak var additionalInfoField: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateSwitch: UISwitch!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    
    let blueTextColor = UIColor(red: 0, green: 122.0/255.0, blue: 1, alpha: 1)
    let dateFormatter = DateFormatter()
    
    let ourQueue = OperationQueue()
    let mainQueue = OperationQueue.main
    
    let dealsRef:FIRDatabaseReference = FIRDatabase.database().reference().child("deals")
    let activityRef:FIRDatabaseReference = FIRDatabase.database().reference().child("activity")
    let scoresRef:FIRDatabaseReference = FIRDatabase.database().reference().child("scores")
    let storageRef:FIRStorageReference = FIRStorage.storage().reference()
    
    var location: Location?
    var startDateSelected: Bool = false
    var endDateSelected: Bool = false
    
    override func viewDidLoad() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddDealTableViewController.addDeal))
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        dateFormatter.dateFormat = "MMMM d, yyyy"
        let today = Date()
        startDateLabel.text = dateFormatter.string(from: today)
        endDateLabel.text = dateFormatter.string(from: today)
        endDatePicker.minimumDate = today
        
    }
    
    func addDeal() {
        let newDeal:FIRDatabaseReference = dealsRef.childByAutoId()
        let newActivity:FIRDatabaseReference = activityRef.childByAutoId()
        let metaData:FIRStorageMetadata = FIRStorageMetadata()
        
        let newImage:FIRStorageReference = storageRef.child("deals").child("\(newDeal.key).jpg")
        
        if let uploadData = self.dealImage.image!.jpegData(.medium), let location = self.location, let auth = FIRAuth.auth() {
            self.ourQueue.addOperation {
                
                newImage.put(uploadData, metadata: metaData) {(metaData, error) in
                    let photoUrl = metaData!.downloadURL()!.absoluteString
                    
                    let date = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/d/YY"
                    var startDate: String = ""
                    var endDate: String = ""
                    let dateString = formatter.string(from: date)
                    
                    if self.dateSwitch.isOn {
                        startDate = formatter.string(from: self.startDatePicker.date)
                        endDate = formatter.string(from: self.endDatePicker.date)
                    }
                    else {
                        startDate = formatter.string(from: date)
                        endDate = "never"
                    }
                    
                    formatter.dateFormat = "h:mm a"
                    formatter.amSymbol = "AM"
                    formatter.pmSymbol = "PM"
                    let time = formatter.string(from: date)
                    
                    newDeal.setValue(["name": self.dealTitleField.text!,
                                      "description": self.additionalInfoField.text!,
                                      "location": ["name": location.name,
                                                   "address": location.address,
                                                   "latitude": location.latitude,
                                                   "longitude": location.longitude],
                                      "accepted": 0,
                                      "rejected": 0,
                                      "endDate": endDate,
                                      "startDate": startDate,
                                      "feedbackCount": 0,
                                      "username": auth.currentUser!.displayName!,
                                      "photoUrl": photoUrl])
                    newActivity.setValue(["action": Action.add,
                                          "dealKey": newDeal.key,
                                          "username": auth.currentUser!.displayName!,
                                          "date": dateString,
                                          "time": time])
                    
                    self.scoresRef.child(auth.currentUser!.displayName!).observeSingleEvent(of: .value, with: { snapshot in
                        if snapshot.hasChild("deals") {
                            let scoresDict = snapshot.value as! [String : AnyObject]
                            self.scoresRef.child(auth.currentUser!.displayName!).child("deals").setValue(scoresDict["deals"] as! Int + 1)
                        }
                        else {
                            self.scoresRef.child(auth.currentUser!.displayName!).child("deals").setValue(1)
                        }
                    })
                }
                self.mainQueue.addOperation {
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchChanged(_ sender: Any) {
        if !dateSwitch.isOn {
            startDateSelected = false
            endDateSelected = false
            startDateLabel.textColor = .black
            endDateLabel.textColor = .black
        }
        self.tableView.reloadData()
    }
    
    @IBAction func startDateChanged(_ sender: UIDatePicker) {
        startDateLabel.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func endDateChanged(_ sender: UIDatePicker) {
        endDateLabel.text = dateFormatter.string(from: sender.date)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        // if the image was selected
        if (section == 0 && row == 0) {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
                imagePicker.allowsEditing = true
                present(imagePicker,animated: true, completion: nil)
            }
        }
            // if the location field was selected
        else if section == 1 && row == 0 {
            performSegue(withIdentifier: "restaurantSearch", sender: self)
        }
        else if section == 2 && row == 1 {
            startDateSelected = !startDateSelected
            if startDateSelected {
                startDateLabel.textColor = blueTextColor
            }
            else {
                startDateLabel.textColor = .black
            }
            self.tableView.reloadData()
        }
        else if section == 2 && row == 3 {
            endDateSelected = !endDateSelected
            if endDateSelected {
                endDateLabel.textColor = blueTextColor
            }
            else {
                endDateLabel.textColor = .black
            }
            self.tableView.reloadData()
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let photoMedia = info[UIImagePickerControllerOriginalImage] as? UIImage {
            dealImage.image = photoMedia
            dealImage.contentMode = UIViewContentMode.scaleAspectFill
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction
    func unwindFromSearch(for unwindSegue: UIStoryboardSegue) {
        let searchViewController = unwindSegue.source as! RestaurantSearchTableViewController
        let row = searchViewController.tableView.indexPathForSelectedRow?.row
        location = searchViewController.locations[row!]
        locationLabel.text = location?.formattedString
        locationLabel.textColor = .black
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 214.0
        }
        if indexPath.section == 1 && indexPath.row == 2 {
            return 71.0
        }
        if indexPath.section == 2 && indexPath.row == 1 && !dateSwitch.isOn {
            return 0.0
        }
        if indexPath.section == 2 && indexPath.row == 3 && !dateSwitch.isOn {
            return 0.0
        }
        if indexPath.section == 2 && indexPath.row == 2 {
            if dateSwitch.isOn && startDateSelected {
                return 216.0
            }
            else {
                return 0.0
            }
        }
        if indexPath.section == 2 && indexPath.row == 4 {
            if dateSwitch.isOn && endDateSelected {
                return 216.0
            }
            else {
                return 0.0
            }
        }
        return 44.0
    }
    
    
    // MARK: - Table view data source
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in PNG format
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    ///
    /// Returns a data object containing the PNG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    var pngData: Data? { return UIImagePNGRepresentation(self) }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpegData(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
}
