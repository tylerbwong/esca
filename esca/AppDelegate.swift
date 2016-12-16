//
//  AppDelegate.swift
//  esca
//
//  Created by Tyler Wong on 10/29/16.
//
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var currentDeal: Deal?
    
    let locationManager = CLLocationManager()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController:UIViewController;
        
        locationManager.delegate = self
        
        FIRApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        if FIRAuth.auth()?.currentUser != nil {
            let mainViewController = storyboard.instantiateViewController(withIdentifier: "DealViewController")
            initialViewController = UINavigationController(rootViewController: mainViewController)
        }
        else {
            initialViewController = storyboard.instantiateViewController(withIdentifier: "Login")
        }
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return self.application(application,
                                    open: url,
                                    sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                    annotation: [:])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let detailViewController = storyboard.instantiateViewController(withIdentifier: "DealDetail") as! DealDetailViewController
        detailViewController.deal = currentDeal
        
        let initialViewController = UINavigationController(rootViewController: detailViewController)
        
        self.window?.rootViewController = initialViewController
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
// MARK: - CLLocationManagerDelegate
extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
        }
    }
    
    func handleEvent(forRegion region: CLRegion!) {
        let notificaiton = UNMutableNotificationContent()
        let dealRef:FIRDatabaseReference = FIRDatabase.database().reference().child("deals").child(region.identifier)
        dealRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let deal = Deal.toDeal(from: snapshot)
            self.currentDeal = deal
            notificaiton.title = "Deal nearby! \(deal.name!)"
            notificaiton.body = deal.description
            notificaiton.sound = UNNotificationSound.default()
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            let identifier = region.identifier
            let request = UNNotificationRequest(identifier: identifier, content: notificaiton, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                if error != nil {
                    print(error.debugDescription)
                }
            })
            
            self.locationManager.stopMonitoring(for: region)
        })
    }
    
}

