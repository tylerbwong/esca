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
   
    let ourQueue = OperationQueue()
    let mainQueue = OperationQueue.main
   
    let dealsRef:FIRDatabaseReference = FIRDatabase.database().reference().child("deals")
    let storageRef:FIRStorageReference = FIRStorage.storage().reference()

    override func viewDidLoad() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddDealTableViewController.addDeal))
    }
    
    func addDeal() {
        let newDeal:FIRDatabaseReference = dealsRef.childByAutoId()
        let metaData:FIRStorageMetadata = FIRStorageMetadata()
      
        let newImage:FIRStorageReference = storageRef.child("deals").child("\(newDeal.key).jpg")
      
      self.ourQueue.addOperation {
          if let uploadData = self.dealImage.image!.jpegData(.medium) {
              newImage.put(uploadData, metadata: metaData) {(metaData, error) in
                  let photoUrl = metaData!.downloadURL()!.absoluteString
                  let date = Date()
                  let formatter = DateFormatter()
                  formatter.dateFormat = "MM/d/YY"
                  let startDate = formatter.string(from: date)
               
                  newDeal.setValue(["name": self.dealTitleField.text!,
                                    "description": self.additionalInfoField.text!,
                                    "location": self.locationField.text!,
                                    "accepted": 0,
                                    "rejected": 0,
                                    "endDate": "never",
                                    "startDate": startDate,
                                    "username": FIRAuth.auth()?.currentUser?.displayName ?? "User",
                                    "photoUrl": photoUrl])
            }
         }
         self.mainQueue.addOperation {
             _ = self.navigationController?.popViewController(animated: true)
         }
      }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let photoMedia = info[UIImagePickerControllerOriginalImage] as? UIImage {
            dealImage.image = photoMedia
            dealImage.contentMode = UIViewContentMode.scaleAspectFill
        }
        dismiss(animated: true, completion: nil)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
