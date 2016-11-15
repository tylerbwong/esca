//
//  ViewController.swift
//  esca
//
//  Created by Tyler Wong on 10/29/16.
//
//

import UIKit
import Firebase
import FBSDKLoginKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {

   @IBOutlet weak var loginButton: FBSDKLoginButton!
   
   @IBAction func logoutAction(_ sender: Any) {
      try! FIRAuth.auth()!.signOut()
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      loginButton.readPermissions = ["email"]
      loginButton.delegate = self
   }

   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error?) {
      if let error = error {
         print(error.localizedDescription)
         return
      }
      
      let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
      
      FIRAuth.auth()?.signIn(with: credential) { (user, error) in
         if let user = user {
            let welcomeMessage: String = "Welcome, \(user.displayName!)!"
            let alert = UIAlertController(title: "Login Success", message: welcomeMessage, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
         }
      }
   }
   
   func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
   
   }
}

