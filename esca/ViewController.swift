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
   
   let loginButton = FBSDKLoginButton()
   let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)

   override func viewDidLoad() {
      super.viewDidLoad()
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
      
      FIRAuth.auth()?.signIn(with: credential) { (user, error) in
         // ...
      }
   }
   
   func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
   
   }
}

