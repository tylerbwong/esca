//
//  LeaderboardViewController.swift
//  esca
//
//  Created by Brandon Vo on 12/16/16.
//
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import GameKit

class LeaderboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var leaderBoardTable: UITableView!
    
    var dealsRef:FIRDatabaseReference = FIRDatabase.database().reference().child("scores")

    
    var submittedArr: [LeaderBoard] = []
    var feedbackArr: [LeaderBoard] = []
    let FEEDBACK_SEGMENT = 0
    let SUBMIT_SEGMENT = 1
    var segmentVal: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Leaderboards"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", style: UIBarButtonItemStyle.plain, target: self, action: #selector(LeaderboardViewController.showMenu))

        dealsRef.observe(.childAdded, with: {(snapshot) in
            let scoreDict = snapshot.value as! [String : AnyObject]
            let name: String = snapshot.key
            if let deals = scoreDict["deals"] as? Int {
                let submittedScore: LeaderBoard = LeaderBoard(name: name, score: deals)
                self.submittedArr.append(submittedScore)
                self.submittedArr = self.submittedArr.sorted(by: { $0.score! > $1.score! })
            }
            
            if let feedback = scoreDict["feedback"] as? Int {
                let feedbackScore: LeaderBoard = LeaderBoard(name: name, score: feedback)
                self.feedbackArr.append(feedbackScore)
                self.feedbackArr = self.feedbackArr.sorted(by: { $0.score! > $1.score! })
            }
            
            self.leaderBoardTable.reloadData()
        })
    }
    
    func showMenu() {
        self.performSegue(withIdentifier: "LeaderboardOpenMenu", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (segmentVal == FEEDBACK_SEGMENT){
            return feedbackArr.count
        }
        return submittedArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaderBoardCell", for: indexPath) as? LeaderBoardTVC
        var curScore:LeaderBoard
        
        if (segmentVal == FEEDBACK_SEGMENT){
            curScore = feedbackArr[indexPath.row]
        }
        else {
            curScore = submittedArr[indexPath.row]
        }
        
    
        cell?.scoreLabel.text = String(describing: curScore.score!)
        cell?.nameLabel.text = curScore.name
        
        return cell!
        
    }

    @IBAction func segControlChanged(_ sender: Any) {
        segmentVal = (sender as AnyObject).selectedSegmentIndex
        self.leaderBoardTable.reloadData()
    }
  /*
    //This is the code that would be used if we had access to iTunes Connect to create GameCenter Leaderboards
    
    //The name of the leaderboards
    let USED_LEADERBOARD_ID = "com.score.used"
    let SUBMIT_LEADERBOARD_ID = "com.score.submit"
    let FEEDBACK_LEADERBOARD_ID = "com.score.feedback"
     
    var dealsRef:FIRDatabaseReference = FIRDatabase.database().reference().child("score").child(FIRAuth.auth()?.currentUser?.displayName)
    
     func authenticatePlayer(){
        //Authenticate player on GameCenter
        let player: GKLocalPlayer = GKLocalPlayer.localPlayer()
        player.authenticateHandler = {(ViewController, error) -> Void in
        if((ViewController) != nil) {
            self.present(ViewController!, animated: true, completion: nil)
        } else {
            print(player.isAuthenticated)
        }
     
     }
 
     // retrieve the score from firebase and then save it
     func retrieveHighscore(){
            var usedScore: Int?
            var submitScore: Int?
            var feedbackScore: Int?
            
            dealsRef.observeSingleEvent(.value, with: {(snapshot) in
                let postDict = snapshot.value as? [String : AnyObject] ?? [:]
                usedScore = postDict["used"] as? Int
                submitScore = postDict["submit"] as? Int
                feedbackScore = postDict["feedback"] as? Int
                
            })
            
            saveScore(leaderboard: USED_LEADERBOARD_ID, score: usedScore)
            saveScore(leaderboard: SUBMIT_LEADERBOARD_ID, score: submitScore)
            saveScore(leaderboard: FEEDBACK_LEADERBOARD_ID, score: feedbackScore)
            
        }
     
        //Save the newest score onto GameCenter
        func saveScore(leaderboard: String, score: Int){
            let bestScoreInt = GKScore(leaderboardIdentifier: leaderboard)
            bestScoreInt.value = Int64(score)
            GKScore.report([bestScoreInt]) { (error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("updated score submitted to " + leaderboard)
                }
            }
        }
        
        
        //show game center
        func callGameCenter(){
            let gcVC = GKGameCenterViewController()
            gcVC.gameCenterDelegate = self
            present(gcVC, animated: true, completion: nil)
        }
        
        //dismiss game center view
        func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
            gameCenterViewController.dismiss(animated: true, completion: nil)
        }
        
        */
    


}
