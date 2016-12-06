//
//  ViewController.swift
//  esca
//
//  Created by Tyler Wong on 10/29/16.
//
//

import UIKit
import GameKit
import Firebase
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var loginButton: FBSDKLoginButton!

    let player:GKLocalPlayer = GKLocalPlayer.localPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player.authenticateHandler = {(viewController: UIViewController?, error: Error?) -> Void in
            
        }
        
        loginButton.readPermissions = ["email"]
        loginButton.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NavController" {
            print("yay")
        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        var credential:FIRAuthCredential
        
        if FBSDKAccessToken.current() != nil {
            credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                if user != nil {
                    print("\(self.player.isAuthenticated) - This means that we are authenticated with Game Center!")
                    self.goToMain()
                }
            }
        }
    }
    
    func goToMain() {
        let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "NavController") as! UINavigationController
        self.present(mainViewController, animated: true, completion: nil)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
}

